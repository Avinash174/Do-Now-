# ✨ Do Now

> **Your Productivity Companion** - Stay focused, stay organized, achieve more! 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.41.4-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-orange?style=for-the-badge&logo=firebase)](https://firebase.google.com)

---

## 📋 About Do Now

**Do Now** is a modern, high-performance task management application built with Flutter. It combines a premium design aesthetic with real-time cloud synchronization to help you stay productive across all your devices.

Whether you're managing complex projects or simple daily habits, Do Now provides a glassmorphism-inspired interface with powerful search, filtering, and notification features.

---

## ✨ Key Features

- 📝 **Advanced Task Management** - Create, schedule, and track tasks with real-time status updates.
- 🔍 **Global Search & Filter** - High-speed search bars on Home and Help Center with instant results.
- 🌓 **Adaptive Dark Mode** - Premium dark and light theme support with auto-detection.
- 🔐 **Zero-Config Auth** - Secure Firebase Authentication with optimized email handling.
- ☁️ **Real-time Sync** - Instant updates across devices using Firebase Realtime Database.
- 📸 **Cloud Profile** - Customizable user profiles with Firebase Storage photo uploads.
- 🔔 **Custom Alerts** - Push notifications with granular sound and vibration controls.
- 🎨 **Premium UI/UX** - Fluid animations using `flutter_animate` and curated typography.
- 🛠️ **Robust Architecture** - Clean code structure powered by Riverpod state management.

---

## 🛠️ Tech Stack

### Frontend & UI

- **Framework**: Flutter 3.41.4 (Stable)
- **State Management**: Riverpod (Reactive Provider Pattern)
- **UI Design**: Modern Material 3 / Glassmorphism
- **Animations**: `flutter_animate` for micro-interactions
- **Typography**: Plus Jakarta Sans (Google Fonts)

### Backend Services

- **Authentication**: Firebase Auth (Email/Password)
- **Database**: Firebase Realtime Database
- **Storage**: Firebase Cloud Storage (Media handling)
- **Cloud Messaging**: Firebase FCM (Push Notifications)

### Dependency Highlights

- `firebase_core` & `firebase_database`: Core infrastructure
- `flutter_local_notifications`: Advanced notification scheduling
- `image_picker`: Camera and Gallery integration
- `shared_preferences`: Local settings persistence

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Android Studio / VS Code
- A Firebase Project

### Installation & Setup

1. **Clone the Project**

   ```bash
   git clone https://github.com/Avinash174/do_now.git
   cd do_now
   ```

2. **Initialize Environment**

   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Download your `google-services.json` from the Firebase Console.
   - Place it in `android/app/google-services.json`.

4. **⚠️ Critical Setup: Firebase Storage**
   To enable profile photo uploads, you **must** manually activate Storage:
   - Go to [Firebase Console > Storage](https://console.firebase.google.com).
   - Click **"Get Started"** and follow the prompts.
   - Deploy the storage rules using `firebase deploy --only storage`.

5. **Run Development Build**
   ```bash
   flutter run
   ```

---

## 📱 Project Structure

```
lib/
├── main.dart                 # App entry point
├── const/
│   ├── app_colors.dart      # Centralized color palette
│   └── app_theme.dart       # Material 3 theme definitions
├── services/
│   ├── auth_service.dart     # Firebase Auth logic
│   ├── database_service.dart  # RTDB & Storage operations
│   ├── settings_service.dart  # Local preference management
│   └── notification_service.dart # Local & Push notifications
├── view/                     # UI Layer
│   ├── home_view.dart        # Dashboard with search
│   ├── profile_view.dart     # User profile & settings
│   ├── help_center_view.dart # Searchable FAQ & Support
│   └── edit_profile_view.dart # Photo & info updates
└── utils/                    # Helper functions
    ├── snackbar_utils.dart
    └── widgets_utils.dart
```

---

## 🎨 Design Highlights

- **Dynamic Search UI**: Real-time filtering in Help Center with "No Results" empty states.
- **Glassmorphism Elements**: Subtle blurs and gradients for a premium feel.
- **Haptic Feedback**: Taptic integration for button presses and task completions.
- **Desugarized Builds**: Optimized for modern Android versions (desugar_jdk_libs 2.1.4).

---

## 👨‍💻 Author

**Avinash Magar**  
📧 [avinashmagar15@gmail.com](mailto:avinashmagar15@gmail.com)  
🐙 [@Avinash174](https://github.com/Avinash174)  
🔗 [LinkedIn](https://www.linkedin.com/in/avinash-magar-1ba853168/)

---

<div align="center">

**Made with ❤️ by Avinash Magar**

⭐ If you find this project helpful, please give it a star!

</div>
