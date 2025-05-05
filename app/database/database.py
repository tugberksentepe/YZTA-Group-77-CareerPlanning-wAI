import aiosqlite
import logging
from typing import Any, Dict, List, Optional

# Log
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Veritabanı
DATABASE_URL = "career_planner.db"

async def init_db() -> None:
    """Veritabanı başlatılır ve gerekli tablolar oluşturulur""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            # Kullanıcılar tablosu
            await db.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    email TEXT UNIQUE NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Sorular ve cevaplar tablosu
            await db.execute("""
                CREATE TABLE IF NOT EXISTS questionnaire (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    question_number INTEGER NOT NULL,
                    question TEXT NOT NULL,
                    answer TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users (id)
                )
            """)
            
            # Kariyer planları tablosu
            await db.execute("""
                CREATE TABLE IF NOT EXISTS career_plans (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    plan_content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users (id)
                )
            """)
            
            # Konuşma geçmişi tablosu
            await db.execute("""
                CREATE TABLE IF NOT EXISTS conversations (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    message TEXT NOT NULL,
                    is_user BOOLEAN NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users (id)
                )
            """)
            
            await db.commit()
            logger.info("Veritabanı tabloları başarıyla oluşturuldu")
    except Exception as e:
        logger.error(f"Veritabanı başlatma hatası: {e}")
        raise

async def get_user_by_email(email: str) -> Optional[Dict[str, Any]]:
    """E-posta adresine göre kullanıcıyı getirir"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            db.row_factory = aiosqlite.Row
            async with db.execute(
                "SELECT * FROM users WHERE email = ?", (email,)
            ) as cursor:
                result = await cursor.fetchone()
                if result:
                    return dict(result)
                return None
    except Exception as e:
        logger.error(f"Kullanıcı alma hatası: {e}")
        return None

async def create_user(email: str) -> Optional[int]:
    """Yeni bir kullanıcı oluşturur ve kullanıcı ID'sini döndürür"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            cursor = await db.execute(
                "INSERT INTO users (email) VALUES (?)", (email,)
            )
            await db.commit()
            return cursor.lastrowid
    except Exception as e:
        logger.error(f"Kullanıcı oluşturma hatası: {e}")
        return None

async def save_question_answer(user_id: int, question_number: int, question: str, answer: str) -> bool:
    """Soru ve cevabın kaydedilmesi"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            await db.execute(
                """
                INSERT INTO questionnaire (user_id, question_number, question, answer) 
                VALUES (?, ?, ?, ?)
                """,
                (user_id, question_number, question, answer)
            )
            await db.commit()
            return True
    except Exception as e:
        logger.error(f"Soru-cevap kaydetme hatası: {e}")
        return False

async def get_user_answers(user_id: int) -> List[Dict[str, Any]]:
    """Kullanıcının tüm cevaplarının alınması"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            db.row_factory = aiosqlite.Row
            async with db.execute(
                """
                SELECT question_number, question, answer 
                FROM questionnaire 
                WHERE user_id = ? 
                ORDER BY question_number
                """,
                (user_id,)
            ) as cursor:
                results = await cursor.fetchall()
                return [dict(row) for row in results]
    except Exception as e:
        logger.error(f"Kullanıcı cevaplarını alma hatası: {e}")
        return []

async def save_career_plan(user_id: int, plan_content: str) -> bool:
    """Kariyer planının kaydedilmesi"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            await db.execute(
                "INSERT INTO career_plans (user_id, plan_content) VALUES (?, ?)",
                (user_id, plan_content)
            )
            await db.commit()
            return True
    except Exception as e:
        logger.error(f"Kariyer planı kaydetme hatası: {e}")
        return False

async def get_career_plan(user_id: int) -> Optional[str]:
    """Kullanıcının kariyer planının alınması"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            db.row_factory = aiosqlite.Row
            async with db.execute(
                "SELECT plan_content FROM career_plans WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                (user_id,)
            ) as cursor:
                result = await cursor.fetchone()
                if result:
                    return result["plan_content"]
                return None
    except Exception as e:
        logger.error(f"Kariyer planı alma hatası: {e}")
        return None

async def save_conversation_message(user_id: int, message: str, is_user: bool) -> bool:
    """Konuşma mesajının kaydedilmesi"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            await db.execute(
                "INSERT INTO conversations (user_id, message, is_user) VALUES (?, ?, ?)",
                (user_id, message, is_user)
            )
            await db.commit()
            return True
    except Exception as e:
        logger.error(f"Konuşma mesajı kaydetme hatası: {e}")
        return False

async def get_conversation_history(user_id: int, limit: int = 10) -> List[Dict[str, Any]]:
    """Kullanıcının konuşma geçmişinin alınması"""
    try:
        async with aiosqlite.connect(DATABASE_URL) as db:
            db.row_factory = aiosqlite.Row
            async with db.execute(
                """
                SELECT message, is_user, created_at 
                FROM conversations 
                WHERE user_id = ? 
                ORDER BY created_at DESC 
                LIMIT ?
                """,
                (user_id, limit)
            ) as cursor:
                results = await cursor.fetchall()
                return [dict(row) for row in results]
    except Exception as e:
        logger.error(f"Konuşma geçmişi alma hatası: {e}")
        return [] 