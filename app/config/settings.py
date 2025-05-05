from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache
import os
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    """Uygulama yapılandırma ayarları"""
    # Uygulama ayarları
    APP_NAME: str = "AI Career Planning API"
    APP_VERSION: str = "0.1.0"
    APP_DESCRIPTION: str = "AI destekli kariyer planlama uygulaması"
    
    # Veritabanı ayarları
    DATABASE_URL: str = "sqlite+aiosqlite:///./career_planner.db"
    
    # Gemini API ayarları
    GEMINI_API_KEY: Optional[str] = os.getenv("GEMINI_API_KEY")
    GEMINI_MODEL: str = "gemini-1.5-flash"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings() -> Settings:
    return Settings() 