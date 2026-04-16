import openmeteo_requests
import requests_cache
from retry_requests import retry
from datetime import datetime, timedelta

URL = "https://api.open-meteo.com/v1/forecast"
class WeatherService:
    def __init__(self):
        # Налаштовуємо клієнт з кешем на 1 годину (3600 секунд)
        cache_session = requests_cache.CachedSession('.cache', expire_after=3600)
        retry_session = retry(cache_session, retries=5, backoff_factor=0.2)
        self.openmeteo = openmeteo_requests.Client(session=retry_session)

    def get_5_days_forecast(self):

        today = datetime.now().date()
        end_date = today + timedelta(days=4)

        params = {
            "latitude": 49.8397,
            "longitude": 24.0297,
            "daily": ["temperature_2m_max", "temperature_2m_min", "weathercode"],
            "timezone": "Europe/Kiev",
            "start_date": today.strftime("%Y-%m-%d"),  # Початок - сьогодні
            "end_date": end_date.strftime("%Y-%m-%d")  # Кінець - через 4 дні
        }

        responses = self.openmeteo.weather_api(URL, params=params)
        response = responses[0]

        # Обробляємо щоденні дані (Порядок має співпадати з params!)
        daily = response.Daily()
        daily_temperature_2m_max = daily.Variables(0).ValuesAsNumpy()
        daily_temperature_2m_min = daily.Variables(1).ValuesAsNumpy()
        daily_weathercode = daily.Variables(2).ValuesAsNumpy()


        forecast_list = []
        for i in range(5):
            current_date = today + timedelta(days=i)
            forecast_list.append({
                "date": current_date.strftime('%Y-%m-%d'),
                "max_temp": round(float(daily_temperature_2m_max[i])),
                "min_temp": round(float(daily_temperature_2m_min[i])),
                "weather_code": int(daily_weathercode[i])
            })

        return {"city": "Львів", "forecast": forecast_list}

    def get_current_weather(self):

        # Запитуємо лише ПОТОЧНІ дані (current)
        params = {
            "latitude": 49.8397,
            "longitude": 24.0297,
            "current": ["temperature_2m", "relative_humidity_2m", "surface_pressure", "wind_speed_10m", "weathercode"],
            "timezone": "Europe/Kiev"
        }

        responses = self.openmeteo.weather_api(URL, params=params)
        current = responses[0].Current()

        return {
            "temp": round(current.Variables(0).Value()),
            "humidity": round(current.Variables(1).Value()),
            "pressure": round(current.Variables(2).Value()),
            "wind": round(current.Variables(3).Value(), 1),
            "code": int(current.Variables(4).Value())
        }