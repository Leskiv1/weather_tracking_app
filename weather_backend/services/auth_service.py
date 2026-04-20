# services/auth_service.py
from sqlalchemy.orm import Session
from repository.database import UserDB
from core.security import get_password_hash, verify_password, create_access_token


class AuthService:
    def register_user(self, db: Session, email: str, password: str):
        # 1. Перевіряємо, чи немає вже такого email
        existing_user = db.query(UserDB).filter(UserDB.email == email).first()
        if existing_user:
            return {"error": "Користувач з таким email вже існує"}

        # 2. Хешуємо пароль і зберігаємо юзера
        hashed_pw = get_password_hash(password)
        new_user = UserDB(email=email, hashed_password=hashed_pw)

        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        return {"message": "Успішно зареєстровано!"}

    def login_user(self, db: Session, email: str, password: str):
        # 1. Шукаємо користувача
        user = db.query(UserDB).filter(UserDB.email == email).first()
        if not user:
            return {"error": "Невірний email або пароль"}

        # 2. Перевіряємо пароль
        if not verify_password(password, user.hashed_password):
            return {"error": "Невірний email або пароль"}

        # 3. Успіх! Видаємо токен
        access_token = create_access_token(data={"sub": user.email})
        return {"access_token": access_token, "token_type": "bearer"}