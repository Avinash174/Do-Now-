# ✨ Do Now

> **Your Productivity Companion** - Stay focused, stay organized, achieve more! 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-orange?style=for-the-badge&logo=firebase)](https://firebase.google.com)

---

## 📋 About Do Now

**Do Now** is a modern, feature-rich task management application built with Flutter. Taking inspiration from productivity best practices, Do Now helps you organize your tasks, track your productivity, and achieve your goals with ease.

Whether you're managing personal projects, work tasks, or daily habits, Do Now provides an intuitive interface with powerful features to keep you on track.

---

## ✨ Key Features

- 📝 **Smart Task Management** - Create, edit, and organize tasks effortlessly
- 🌓 **Dark & Light Themes** - Beautiful Material 3 design with full theme support
- 🔐 **Secure Authentication** - Firebase Auth with email/password
- ☁️ **Cloud Sync** - Real-time sync with Firebase Realtime Database
- 📊 **Productivity Analytics** - Track your stats and visualize your progress
- 📸 **Profile Customization** - Upload custom profile photos to Firebase Storage
- 🔔 **Smart Notifications** - Push notifications with Firebase Cloud Messaging
- ⚙️ **Granular Settings** - Security, privacy, and notification preferences
- 🎨 **Beautiful UI** - Smooth animations and responsive design for all devices
- 🌐 **Multi-Platform** - iOS, Android, Web, Windows, macOS, and Linux support

---

## 🛠️ Tech Stack

### Frontend

- **Framework**: Flutter 3.0+
- **State Management**: flutter_riverpod (reactive provider pattern)
- **UI Library**: Material 3 Design System
- **Animations**: flutter_animate for smooth transitions
- **Fonts**: Google Fonts (Plus Jakarta Sans)

### Backend & Services

- **Authentication**: Firebase Auth (Email/Password)
- **Database**: Firebase Realtime Database
- **Storage**: Firebase Cloud Storage (Profile photos)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Local Caching**: SharedPreferences

### Additional Packages

- **firebase_auth** - Authentication
- **firebase_database** - Real-time data sync
- **firebase_storage** - File storage
- **firebase_messaging** - Push notifications
- **flutter_local_notifications** - Local notification handling
- **image_picker** - Photo selection
- **flutter_timezone** - Timezone support
- **path_provider** - File system access

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Dart 2.17+
- Firebase project setup
- Android SDK / Xcode (for native development)

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Avinash174/do_now.git
   cd do_now
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 📱 Project Structure

```
lib/
├── main.dart                 # App entry point
├── const/
│   └── app_theme.dart       # Material 3 theme definitions
├── model/                    # Data models
├── services/
│   ├── auth_service.dart       # Firebase authentication
│   ├── database_service.dart    # Firestore operations
│   └── notification_service.dart # FCM integration
├── view/                     # UI screens
│   ├── home_view.dart
│   ├── stats_view.dart
│   ├── profile_view.dart
│   ├── auth_views/
│   └── settings_views/
├── view_model/               # Business logic & state
│   ├── theme_view_model.dart
│   └── task_view_model.dart
└── utils/                    # Utilities
    ├── app_utils.dart
    └── shimmer_utils.dart
```

---

## 🎨 Design Highlights

- **Material 3 Compliance** - Modern design with custom color schemes
- **Full Dark Mode Support** - Adaptive UI that responds to system theme
- **Smooth Animations** - Polished transitions and interactions
- **Responsive Layout** - Optimized for phones, tablets, and web
- **Accessibility** - Semantic widgets and proper color contrast

---

## 🔐 Security & Privacy

- 🔒 Firebase Security Rules for data protection
- 🚫 User authentication required for all operations
- 📱 Local storage with SharedPreferences
- 🔑 Secure password handling with Firebase Auth

---

## 📸 Screenshots

| Dashboard        | Statistics               | Profile            |
| ---------------- | ------------------------ | ------------------ |
| 📋 Task Overview | 📊 Productivity Insights | 👤 User Profile    |
| Manage all tasks | Track your progress      | Customize settings |

---

## 🐛 Troubleshooting

### Firebase Connection Issues

- Ensure Firebase project is properly configured
- Check Firebase Security Rules
- Verify network permissions in AndroidManifest.xml

### Theme Not Changing

- Rebuild the app: `flutter clean && flutter pub get`
- Restart the development server

### Notification Issues

- Check Firebase Cloud Messaging setup
- Verify notification permissions are granted
- Review FCM debug messages in logs

---

## 🤝 Contributing

We'd love your contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing-feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)

## 👨‍💻 Author

**Avinash Magar**  
📧 Email: [avinashmagar15@gmail.com](mailto:avinashmagar15@gmail.com)  
🐙 GitHub: [@Avinash174](https://github.com/Avinash174)  
🔗 LinkedIn: [Avinash Magar](https://www.linkedin.com/in/avinash-magar-1ba853168/)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Material Design team for design guidelines
- All contributors and testers

---

<div align="center">

**Made with ❤️ by Avinash Magar**

⭐ If you find this project helpful, please give it a star!

</div>
