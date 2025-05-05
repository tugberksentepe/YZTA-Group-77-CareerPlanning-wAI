from google import genai
import logging
from typing import Dict, List, Optional, Any
from app.config.settings import get_settings

# Loglama
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Ayarlar
settings = get_settings()

# Gemini API
if settings.GEMINI_API_KEY:
    client = genai.Client(api_key=settings.GEMINI_API_KEY)
else:
    logger.warning("GEMINI_API_KEY bulunamadı. API çağrıları başarısız olacak.")

async def generate_first_question() -> str:
    """İlk soruyu oluşturulur"""
    try:
        if not settings.GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY bulunamadı. Standart soru döndürülüyor.")
            return "Kariyer yolculuğunuzda hangi alanlar veya endüstriler sizi en çok heyecanlandırıyor?"
            
        prompt = """
        Profesyonel bir kariyer danışmanısın. Kullanıcıya kariyer planlaması yapmak için 
        kişisel ilgi alanları, becerileri, değerleri ve hedefleri hakkında sormak 
        istediğin ilk soruyu yaz. Bu, anket serinin ilk sorusu olacak.
        Sadece soruyu yaz, başka bir açıklama yapma.
        """
        
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        logger.error(f"İlk soru oluşturma hatası: {e}")
        return "Kariyer yolculuğunuzda hangi alanlar veya endüstriler sizi en çok heyecanlandırıyor?"

async def generate_next_question(previous_questions_answers: List[Dict[str, Any]]) -> str:
    """Önceki sorulara ve cevaplara dayalı olarak bir sonraki soru oluşturulur"""
    try:
        if not settings.GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY bulunamadı. Standart soru döndürülüyor.")
            return "Kariyer hedeflerinize ulaşmak için ne tür beceriler geliştirmeniz gerektiğini düşünüyorsunuz?"
        
        # Soru-cevap geçmişi
        qa_history = ""
        for qa in previous_questions_answers:
            qa_history += f"Soru {qa['question_number']}: {qa['question']}\nCevap: {qa['answer']}\n\n"
        
        prompt = f"""
        Kariyer danışmanı rolündesin. Aşağıda kullanıcının daha önce cevapladığı soru ve cevaplar bulunmaktadır:
        
        {qa_history}
        
        Önceki cevaplarına dayanarak, kariyer planlaması için kullanıcıya sormak üzere anlamlı bir sonraki soruyu oluştur.
        Soru, kullanıcının becerilerini, ilgi alanlarını, değerlerini veya kariyer hedeflerini daha derinlemesine keşfetmelidir.
        Sadece soruyu yaz, başka bir açıklama yapma.
        """
        
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        logger.error(f"Sonraki soru oluşturma hatası: {e}")
        return "Kariyer hedeflerinize ulaşmak için ne tür beceriler geliştirmeniz gerektiğini düşünüyorsunuz?"

async def generate_career_plan(questions_answers: List[Dict[str, Any]]) -> str:
    """Kullanıcının cevaplarına dayalı olarak kişiselleştirilmiş bir kariyer planı oluşturur"""
    try:
        if not settings.GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY bulunamadı. Standart kariyer planı döndürülüyor.")
            return "Standart kariyer planı (API anahtarı eksik)"
        
        # Soru-cevap geçmişi
        qa_content = ""
        for qa in questions_answers:
            qa_content += f"Soru: {qa['question']}\nCevap: {qa['answer']}\n\n"
        
        prompt = f"""
        Kariyer danışmanı rolündesin. Aşağıdaki soru-cevap geçmişine dayanarak, kullanıcı için 
        kişiselleştirilmiş, kapsamlı bir kariyer planı oluştur:
        
        {qa_content}
        
        Kariyer planı şunları içermelidir:
        1. Kullanıcının ilgi alanları, becerileri ve değerlerine dayalı kariyer önerileri
        2. Önerilen kariyerler için gerekli eğitim ve beceri gereksinimleri
        3. Kısa vadeli hedefler (6 ay - 1 yıl)
        4. Orta vadeli hedefler (1-3 yıl)
        5. Uzun vadeli hedefler (3-5 yıl)
        6. Tavsiye edilen kaynaklar ve öğrenme yolları
        
        Her bölüm için başlıklar kullan ve kullanıcının verdiği cevaplara dayalı olarak 
        olabildiğince kişiselleştirilmiş tavsiyeler ver.
        """
        
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        logger.error(f"Kariyer planı oluşturma hatası: {e}")
        return "Kariyer planı oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyin."

async def process_user_query(user_id: int, user_query: str, career_plan: Optional[str], 
                            conversation_history: List[Dict[str, Any]]) -> str:
    """Kullanıcının sorgusu için bir yanıt oluşturur"""
    try:
        if not settings.GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY bulunamadı. Standart yanıt döndürülüyor.")
            return "API anahtarı eksik olduğu için yanıt üretilemedi."
        
        # Konuşma geçmişi
        chat_history = ""
        for msg in reversed(conversation_history):
            prefix = "Kullanıcı" if msg["is_user"] else "AI"
            chat_history += f"{prefix}: {msg['message']}\n"
        
        career_plan_content = career_plan if career_plan else "Kariyer planı henüz oluşturulmadı."
        
        prompt = f"""
        Kariyer danışmanı rolündesin. Kullanıcı için aşağıdaki kariyer planı oluşturuldu:
        
        {career_plan_content}
        
        Konuşma geçmişi:
        {chat_history}
        
        Kullanıcı şu soruyu sordu: "{user_query}"
        
        Bu soruya, kariyer planına ve konuşma geçmişine dayanarak yardımcı ve bilgilendirici bir şekilde yanıt ver.
        Yanıtın, kullanıcının kariyer planını ilerletmesine yardımcı olacak özel tavsiyeleri içermelidir.
        """
        
        response = client.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        logger.error(f"Kullanıcı sorgusu işleme hatası: {e}")
        return "Sorgunuz işlenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin." 