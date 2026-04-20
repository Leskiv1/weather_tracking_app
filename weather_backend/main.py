# main.py
from fastapi import FastAPI
from api.weather_router import router as weather_router
from api.auth_router import router as auth_router

app = FastAPI(title="Weather IoT Backend")

# Підключаємо наш роутер погоди
app.include_router(auth_router, prefix="/api/auth", tags=["Auth"])
app.include_router(weather_router, prefix="/api", tags=["Weather"])

@app.get("/")
async def root():
    return {"message": "Бекенд працює! Перейдіть на /docs для документації."}