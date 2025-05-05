from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, Optional
import logging
from datetime import datetime

from app.schemas.schemas import (
    SuccessResponse,
    ErrorResponse,
    CareerPlanResponse,
    UserMessage
)
from app.services.gemini_service import generate_career_plan, process_user_query
from app.database.database import (
    get_user_by_email,
    create_user,
    get_user_answers,
    save_career_plan,
    get_career_plan,
    save_conversation_message,
    get_conversation_history
)
from app.routers.questionnaire import get_or_create_user

# Loglama
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/career-plan",
    tags=["career_plan"],
    responses={404: {"model": ErrorResponse}}
)

@router.post("/generate", response_model=SuccessResponse)
async def generate_user_career_plan(email: str) -> SuccessResponse:
    """Kullanıcının cevaplarına dayalı olarak kariyer planı oluşturur"""
    try:
        user_id = await get_or_create_user(email)
        answers = await get_user_answers(user_id)
        
        # Tüm soruların cevaplandı mı konrol edilir 
        if len(answers) < 10:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Lütfen önce anketi tamamlayın. {len(answers)}/10 soru cevaplandı."
            )
            
        # Kariyer planını oluşturms işlemi
        career_plan = await generate_career_plan(answers)
        
        # Oluşturulan planı kaydetme işlemi
        success = await save_career_plan(user_id, career_plan)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Kariyer planı kaydedilemedi"
            )
            
        return SuccessResponse(message="Kariyer planı başarıyla oluşturuldu ve kaydedildi")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Kariyer planı oluşturma hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Kariyer planı oluşturulamadı: {str(e)}"
        )

@router.get("/", response_model=CareerPlanResponse)
async def get_user_career_plan(email: str) -> Dict[str, Any]:
    """Kullanıcının kariyer planını getirir"""
    try:
        user_id = await get_or_create_user(email)
        
        # Kariyer planını alma işlemi
        plan_content = await get_career_plan(user_id)
        
        if not plan_content:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Kariyer planı bulunamadı"
            )
            
        return {
            "plan_content": plan_content,
            "created_at": datetime.now() 
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Kariyer planı getirme hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Kariyer planı alınamadı: {str(e)}"
        )

@router.post("/chat", response_model=Dict[str, str])
async def chat_with_career_ai(email: str, user_message: UserMessage) -> Dict[str, str]:
    """Kullanıcının kariyer planı hakkında AI ile sohbet etmesini sağlar"""
    try:
        user_id = await get_or_create_user(email)
        
        # Kullanıcı mesajını kaydetme işlemi
        await save_conversation_message(user_id, user_message.message, is_user=True)
        
        # Kariyer planını alma işlemi
        career_plan = await get_career_plan(user_id)
        
        # Sohbet geçmişini alma işlemi
        conversation_history = await get_conversation_history(user_id, limit=10)
        
        # AI yanıtını oluşturma işlemi
        ai_response = await process_user_query(
            user_id=user_id,
            user_query=user_message.message,
            career_plan=career_plan,
            conversation_history=conversation_history
        )
        
        # AI yanıtını kaydetme işlemi
        await save_conversation_message(user_id, ai_response, is_user=False)
        
        return {"response": ai_response}
    except Exception as e:
        logger.error(f"Sohbet işleme hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Mesaj işlenemedi: {str(e)}"
        )

@router.get("/chat-history", response_model=Dict[str, Any])
async def get_chat_history(email: str, limit: int = 10) -> Dict[str, Any]:
    """Kullanıcının sohbet geçmişini getirir"""
    try:
        user_id = await get_or_create_user(email)
        
        # Sohbet geçmişini alma işlemi
        conversation_history = await get_conversation_history(user_id, limit=limit)
        
        return {"history": conversation_history}
    except Exception as e:
        logger.error(f"Sohbet geçmişi alma hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Sohbet geçmişi alınamadı: {str(e)}"
        ) 