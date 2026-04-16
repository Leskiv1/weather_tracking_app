from fastapi import APIRouter, Depends
from services.weather_service import WeatherService
from core.security import oauth2_scheme # Імпортуємо наш "замок"

router = APIRouter()
weather_service = WeatherService()

# ДОДАЄМО Depends(oauth2_scheme) сюди:
@router.get("/forecast")
def get_forecast(token: str = Depends(oauth2_scheme)):
    """
    Ендпоінт для отримання прогнозу погоди на 5 днів.
    ЗАХИЩЕНО JWT ТОКЕНОМ!
    """
    # Якщо токен недійсний або його немає, сюди код навіть не дійде (FastAPI сам викине помилку)
    return weather_service.get_5_days_forecast()

@router.get("/current")
def get_current_weather():
    """Відкритий ендпоінт для поточної погоди (без JWT)"""
    return weather_service.get_current_weather()