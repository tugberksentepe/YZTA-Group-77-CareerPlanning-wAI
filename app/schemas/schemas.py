from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional
from datetime import datetime

# Kullanıcı tablosu
class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Soru-cevap tablosu
class QuestionAnswerBase(BaseModel):
    question: str
    answer: Optional[str] = None

class QuestionAnswer(QuestionAnswerBase):
    question_number: int

class QuestionResponse(BaseModel):
    question: str
    question_number: int

class AnswerCreate(BaseModel):
    answer: str

# Kariyer planı tablosu
class CareerPlanResponse(BaseModel):
    plan_content: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Konuşma tablosu
class MessageBase(BaseModel):
    message: str

class UserMessage(MessageBase):
    pass

class AIMessage(MessageBase):
    pass

class ConversationMessage(MessageBase):
    is_user: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

# API yanıt tablosu
class SuccessResponse(BaseModel):
    success: bool = True
    message: str

class ErrorResponse(BaseModel):
    success: bool = False
    error: str
    
class QuestionnaireCompletionResponse(BaseModel):
    is_complete: bool
    total_questions: int = 10
    current_question: Optional[int] = None
    next_question: Optional[str] = None 