from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
import logging

from app.schemas.schemas import (
    QuestionResponse,
    AnswerCreate,
    SuccessResponse,
    ErrorResponse,
    QuestionnaireCompletionResponse
)
from app.services.gemini_service import generate_first_question, generate_next_question
from app.database.database import (
    get_user_by_email,
    create_user,
    save_question_answer,
    get_user_answers
)

# Loglama yapılandırması
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/questionnaire",
    tags=["questionnaire"],
    responses={404: {"model": ErrorResponse}}
)

# Yardımcı fonksiyonlar
async def get_or_create_user(email: str) -> int:
    """E-posta ile kullanıcıyı alır veya oluşturur ve ID'sini döndürür"""
    user = await get_user_by_email(email)
    if user:
        return user["id"]
    
    user_id = await create_user(email)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Kullanıcı oluşturulamadı"
        )
    return user_id

@router.get("/status", response_model=QuestionnaireCompletionResponse)
async def check_questionnaire_status(email: str) -> QuestionnaireCompletionResponse:
    """Kullanıcının anket tamamlama durumunu kontrol eder"""
    try:
        user_id = await get_or_create_user(email)
        answers = await get_user_answers(user_id)
        
        total_questions = 10
        current_question = len(answers)
        
        if current_question >= total_questions:
            return QuestionnaireCompletionResponse(
                is_complete=True,
                total_questions=total_questions,
                current_question=current_question
            )
        
        # Sonraki soruyu hazırla
        if current_question == 0:
            next_question = await generate_first_question()
        else:
            next_question = await generate_next_question(answers)
            
        return QuestionnaireCompletionResponse(
            is_complete=False,
            total_questions=total_questions,
            current_question=current_question,
            next_question=next_question
        )
    except Exception as e:
        logger.error(f"Anket durumu kontrol hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Anket durumu kontrol edilemedi: {str(e)}"
        )

@router.get("/question", response_model=QuestionResponse)
async def get_next_question(email: str) -> QuestionResponse:
    """Kullanıcı için sonraki soruyu getirir"""
    try:
        user_id = await get_or_create_user(email)
        answers = await get_user_answers(user_id)
        
        question_number = len(answers) + 1
        if question_number > 10:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Anket zaten tamamlandı"
            )
        
        # Soruyu oluştur
        if question_number == 1:
            question = await generate_first_question()
        else:
            question = await generate_next_question(answers)
            
        return QuestionResponse(
            question=question,
            question_number=question_number
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Soru getirme hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Soru alınamadı: {str(e)}"
        )

@router.post("/answer", response_model=SuccessResponse)
async def submit_answer(
    email: str, 
    question_number: int, 
    answer_data: AnswerCreate
) -> SuccessResponse:
    """Kullanıcının cevabını kaydeder"""
    try:
        user_id = await get_or_create_user(email)
        answers = await get_user_answers(user_id)
        
        # Cevabın geçerli olup olmadığını kontrol et
        current_question_number = len(answers) + 1
        if question_number != current_question_number:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Geçersiz soru numarası. Beklenen: {current_question_number}, Alınan: {question_number}"
            )
            
        # Soruyu belirle
        if question_number == 1:
            question = await generate_first_question()
        else:
            question = await generate_next_question(answers)
        
        # Cevabı kaydet
        success = await save_question_answer(
            user_id=user_id,
            question_number=question_number,
            question=question,
            answer=answer_data.answer
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Cevap kaydedilemedi"
            )
            
        return SuccessResponse(message="Cevap başarıyla kaydedildi")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Cevap gönderme hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Cevap gönderilemedi: {str(e)}"
        )

@router.get("/answers", response_model=List[Dict[str, Any]])
async def get_all_answers(email: str) -> List[Dict[str, Any]]:
    """Kullanıcının tüm cevaplarını getirir"""
    try:
        user_id = await get_or_create_user(email)
        answers = await get_user_answers(user_id)
        return answers
    except Exception as e:
        logger.error(f"Cevapları getirme hatası: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Cevaplar alınamadı: {str(e)}"
        ) 