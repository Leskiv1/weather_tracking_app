# 🌤️ WeatherTracker

A modern cross-platform weather application built with a **Flutter** frontend and a **Python FastAPI** backend. 

This project demonstrates the development of a production-style application featuring responsive UI, REST API integration, MQTT communication, Cubit state management, feature-based architecture, and native Android plugin development.

## ✨ Features

* **🔐 User Authentication:** Secure login and registration system using JWT.
* **🌤️ Real-time Weather Data:** Current weather conditions and forecasts via OpenMeteo integration.
* **📡 Live Updates:** Real-time data synchronization using the MQTT protocol.
* **📍 Location Management:** Save and manage multiple locations.
* **👤 User Profile:** Personalized user settings and saved places.
* **🌐 Network Monitoring:** Real-time network connectivity status monitoring.
* **🔦 Native Integration:** Device flashlight control via a custom Android plugin.
* **📱 Responsive UI:** Optimized for mobile, tablet, and web viewing.

---

## 🏗️ Full-Stack Architecture

This project consists of two main components, ensuring a clear separation of concerns:

### 1. Frontend (Flutter)
* **State Management:** Uses `flutter_bloc` (Cubit) for reactive state management. Business logic is strictly separated from the UI.
* **Architecture:** Feature-Based Architecture combined with a shared `core` module.
* **Dependency Injection:** Implemented via `RepositoryProvider` to keep the application loosely coupled.

### 2. Backend (Python FastAPI)
* **API:** RESTful API built with the high-performance FastAPI framework.
* **Database:** SQLite database for persistent storage (managed via SQLAlchemy).
* **Security:** JWT authentication and bcrypt password hashing for secure user sessions.

---

## 🚀 Technologies

| Category | Technologies |
| :--- | :--- |
| **Frontend Framework** | Flutter, Dart |
| **State Management** | `flutter_bloc` (Cubit) |
| **Frontend Networking**| `http`, `mqtt_client`, `internet_connection_checker_plus` |
| **Native Integration** | Kotlin, `MethodChannel` (`flashlight_plugin`) |
| **Backend Framework** | Python, FastAPI, Uvicorn |
| **Backend DB & Auth** | SQLAlchemy, PyJWT, passlib, bcrypt |
| **External APIs** | OpenMeteo SDK |

---

## 📁 Project Structure

### Frontend (Flutter)
```text
lib/
├── core/
│   ├── theme/           # App theming and colors
│   ├── data/            # Shared data repositories
│   ├── models/          # Data models
│   ├── services/        # API, Network, and MQTT services
│   ├── cubit/           # Global state management
│   ├── widgets/         # Reusable UI components
│   └── utils/           # Utility functions and helpers
│
├── features/
│   ├── auth/            # Authentication feature (Login/Register)
│   ├── home/            # Weather dashboard and main screen
│   └── profile/         # User profile and settings
│
└── main.dart            # App entry point

```

### Backend (Python FastAPI)

```text
weather_backend/
├── api/
│   ├── weather_router.py    # Weather data endpoints
│   └── auth_router.py       # Authentication endpoints
├── core/
│   └── security.py          # JWT and security utilities
├── services/
│   ├── auth_service.py      # Authentication logic
│   └── weather_service.py   # Weather data processing
├── repository/
│   ├── database.py          # Database configuration
│   └── user_repository.py   # User database operations
├── main.py                  # FastAPI app entry point
├── requirements.txt         # Python dependencies
└── weather.db               # SQLite database

```

---

## ⚙️ Installation & Getting Started

### Prerequisites

* Flutter SDK 3.11.1 or higher
* Python 3.8+
* Android Studio / VS Code

### 1. Running the Backend

Navigate to the backend directory and set up the Python environment:

```bash
cd weather_backend

# Create and activate virtual environment
python -m venv .venv

# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --reload

```

*The API will be available at `http://localhost:8000*`
*Swagger API documentation: `http://localhost:8000/docs*`

### 2. Running the Frontend

Open a new terminal, navigate to the project root, and run:

```bash
# Install Flutter dependencies
flutter pub get

# Run the app
flutter run

```

*Note: During dependency installation, Flutter will automatically download the custom `flashlight_plugin` directly from GitHub.*

---

## 🔦 Easter Egg & Native Plugin

The application contains a hidden feature demonstrating native platform integration via a custom Flutter plugin.

**To activate it:**

1. Launch the application on a physical **Android device** or Emulator.
2. Locate the blue cloud ☁️ icon in the Top Navigation Bar.
3. Perform a **long press** on the icon.
4. This invokes the custom `MethodChannel` implementation and toggles the device flashlight.
*(On unsupported platforms like Web or iOS, an informational dialog is displayed instead).*

👉 **Plugin Repository:** [Leskiv1/flashlight_plugin](https://github.com/Leskiv1/flashlight_plugin)

---

## 🎓 Academic Background & Progression

This project was originally developed as part of a University Mobile Application Development course. Throughout the course, the application was progressively enhanced:

* **Labs 1-3:** Responsive UI development, custom design system, and routing.
* **Labs 4-5:** REST API integration and real-time MQTT communication.
* **Lab 6:** Complete architectural refactoring to 3-Tier Architecture, implementing Cubit state management and Dependency Injection.
* **Lab 7:** Native Android plugin development using `MethodChannel` and safe platform handling (`dart:ffi` concepts).

🙏 **Acknowledgements & Course Materials:** * Course Repository: [DenysDoskochynskyi/IoT-flutter](https://github.com/DenysDoskochynskyi/IoT-flutter)

---
