# api/auth_router.py
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel

from repository.database import get_db
from services.auth_service import AuthService

router = APIRouter()
auth_service = AuthService()

# Описуємо, як має виглядати JSON для реєстрації
class UserCreate(BaseModel):
    email: str
    password: str

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    """Реєстрація нового користувача"""
    result = auth_service.register_user(db, user.email, user.password)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """
    Вхід та отримання JWT токена.
    Зверни увагу: OAuth2 вимагає поля 'username', тому ми передаємо email туди.
    """
    result = auth_service.login_user(db, form_data.username, form_data.password)
    if "error" in result:
        raise HTTPException(status_code=401, detail=result["error"])
    return result