# repository/database.py
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker

# Вказуємо, що база буде лежати у файлі weather.db поруч з кодом
SQLALCHEMY_DATABASE_URL = "sqlite:///./weather.db"

# Створюємо "двигун" бази даних
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Створюємо фабрику сесій (щоб кожен запит мав своє підключення)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Базовий клас для наших моделей
Base = declarative_base()

# Описуємо таблицю користувачів
class UserDB(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)

# Створюємо таблиці в базі даних (якщо їх ще немає)
Base.metadata.create_all(bind=engine)

# Функція, яка видає сесію для БД і автоматично її закриває
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()