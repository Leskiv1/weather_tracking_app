import os
import jwt
import bcrypt  # Використовуємо чистий bcrypt
from datetime import datetime, timedelta, timezone
from fastapi.security import OAuth2PasswordBearer # <--- ДОДАЙ ЦЕ
from dotenv import load_dotenv

load_dotenv()
# Цей рядок каже Swagger'у, куди стукати, щоб отримати токен
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

def get_password_hash(password: str) -> str:
    """Генерує безпечний хеш з пароля"""
    # Перетворюємо пароль у байти
    pwd_bytes = password.encode('utf-8')
    # Генеруємо "сіль" (випадкові дані для ускладнення злому)
    salt = bcrypt.gensalt()
    # Створюємо хеш і повертаємо його як звичайний рядок (щоб зберегти в БД)
    hashed_password = bcrypt.hashpw(pwd_bytes, salt)
    return hashed_password.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Перевіряє, чи збігається введений пароль із тим, що в базі"""
    password_byte_enc = plain_password.encode('utf-8')
    hashed_password_byte_enc = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password_byte_enc, hashed_password_byte_enc)

def create_access_token(data: dict) -> str:
    """Генерує JWT токен, який діє 7 днів"""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=7)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt