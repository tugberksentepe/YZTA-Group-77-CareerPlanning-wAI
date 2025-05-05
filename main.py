from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
from contextlib import asynccontextmanager

from app.routers import questionnaire, career_plan
from app.database.database import init_db
from app.config.settings import get_settings

# Loglama yapılandırması
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Ayarları al
settings = get_settings()

# Uygulama yaşam döngüsü
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Başlangıç
    logger.info("Uygulama başlatılıyor...")
    await init_db()
    logger.info("Veritabanı başlatıldı")
    yield
    # Kapanış
    logger.info("Uygulama kapatılıyor...")

# FastAPI uygulamasını oluştur
app = FastAPI(
    title=settings.APP_NAME,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    lifespan=lifespan
)

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Üretimde spesifik URL'leri belirt
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Genel istisna işleyici
@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    logger.error(f"Genel istisna: {exc}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"success": False, "error": f"İşlenmeyen hata: {str(exc)}"},
    )

# Yönlendiricileri ekle
app.include_router(questionnaire.router)
app.include_router(career_plan.router)

# Ana sayfa
@app.get("/")
async def root():
    return {
        "app_name": settings.APP_NAME, 
        "version": settings.APP_VERSION,
        "description": settings.APP_DESCRIPTION
    }

# Test endpoint'i
@app.get("/health")
async def health_check():
    return {"status": "OK", "app_version": settings.APP_VERSION}

# Direkt çalışırsa
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
