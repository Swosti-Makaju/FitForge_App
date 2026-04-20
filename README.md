🏋️ FitForge – Fitness App (Flutter)

FitForge is a Flutter-based fitness application designed to help users manage workouts, track habits, and stay consistent on their fitness journey. This project is currently a work-in-progress, with some features fully functional and others using placeholder (dummy) data for UI demonstration.

🚀 Features

✅ Implemented Features

🔐 Authentication
User login and signup flow (UI / basic logic)

🏠 Home Dashboard
Track daily water intake 💧
Start a workout session
Quick overview of fitness activity

💪 Workout Module
Workout timer functionality ⏱️
Basic workout interaction

📈 Progress Tracking
Currently uses dummy data
UI is complete, but not connected to real workout or health data

👤 Profile Page
User profile interface and settings

🔔 Notifications Page
UI for alerts and reminders

🆘 Help & Support
Static support and help interface

🛠️ Tech Stack
Framework: Flutter
Language: Dart

📱 Screens
Authentication (Login / Signup)
Home Dashboard (Water tracking + Start workout)
Workout (Different workouts available)
Progress (Dummy data UI)
Profile
Notifications(Displays preloaded/static notifications)
Help & Support

📂 Project Structure
lib/
│── main.dart                  # App entry point
│
├── fonts.poppins/            # Custom fonts
│
├── models/
│   └── app_data.dart         # App data models / dummy data  / notifications
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── home_screen.dart
│   ├── workout_screen.dart
│   ├── progress_screen.dart
│   ├── profile_screen.dart
│   ├── notification_screen.dart      # Displays pre-inserted notifications
│   └── help_support_screen.dart
│
├── state/
│   └── app_state.dart       
│
├── theme/
│   └── app_theme.dart        
│
└── widgets/
├── stat_card.dart        
└── workout_category_card.dart

⚙️ Installation
git clone https://github.com/Swosti-Makaju/FitForge_App.git
cd fitforge
flutter pub get
flutter run

🤝 Contributing
Feel free to fork this project and improve it!