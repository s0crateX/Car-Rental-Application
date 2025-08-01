<div align="center">
  <img src="assets/images/logo/logo.png" alt="Car Rental App Logo" width="120" height="120">
  
  # Car Rental App
  
  **A comprehensive Flutter-based car rental platform connecting car owners with customers**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue.svg)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 About

Car Rental App is a modern, feature-rich mobile application built with Flutter that facilitates seamless car rental experiences. The platform serves two primary user types: **Car Owners** who want to rent out their vehicles and **Customers** who need to rent cars for various purposes.

## ✨ Key Features

### 🚗 For Customers
- **Browse & Search**: Explore available cars with advanced filtering options
- **Car Details**: View comprehensive car information, photos, and specifications
- **Interactive Maps**: Locate cars and plan pickup/return locations
- **Booking System**: Easy booking process with calendar integration
- **Document Verification**: Secure identity verification system
- **Reviews & Ratings**: Rate and review rental experiences
- **Profile Management**: Manage personal information and preferences
- **Booking History**: Track past and current rentals

### 🏢 For Car Owners
- **Car Management**: Add, edit, and manage vehicle listings
- **Booking Management**: Handle rental requests and approvals
- **Revenue Tracking**: Monitor earnings and rental history
- **Document Verification**: Verify business credentials
- **Analytics Dashboard**: View booking statistics and performance
- **Customer Communication**: Direct communication with renters

### 🔧 Technical Features
- **Firebase Integration**: Real-time database, authentication, and storage
- **Responsive Design**: Optimized for various screen sizes
- **Offline Support**: Core functionality available offline
- **Push Notifications**: Real-time updates and alerts
- **Secure Payments**: Integrated payment processing
- **Location Services**: GPS-based car location and navigation

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: Provider
- **Maps**: Flutter Map with OpenStreetMap
- **Image Handling**: Cached Network Image, Image Picker
- **Local Storage**: Shared Preferences
- **UI Components**: Custom widgets with Material Design

## 📋 Prerequisites

Before running this application, ensure you have the following installed:

- **Flutter SDK**: Version 3.7.0 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Android Studio** with Flutter and Dart plugins
- **Android SDK** (API level 21 or higher)
- **Git** for version control
- **Java Development Kit (JDK)**: Version 8 or higher
- **Firebase CLI** (optional, for Firebase configuration)

### Android Development Requirements:
- Android Studio or VS Code with Flutter extensions
- Android SDK Command-line Tools
- Android Emulator or physical Android device for testing

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/s0crateX/Car-Rental-Application
cd car_rental_app
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android Setup:
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project with package name: `com.example.car_rental_app`
3. Download `google-services.json` and place it in `android/app/` directory
4. The Firebase configuration is already set up in the project files
5. Ensure the following Firebase services are enabled in your Firebase console:
   - **Authentication** (Email/Password sign-in method)
   - **Cloud Firestore** (Database)
   - **Firebase Storage** (File uploads)
   - **Firebase Cloud Messaging** (Push notifications - optional)

### 5. Update Dependencies
```bash
flutter pub upgrade
```

### 6. Generate App Icons (Optional)
```bash
flutter pub run flutter_launcher_icons:main
```

## 🏃‍♂️ Running the Application

### Development Mode

#### Prerequisites for Running:
1. Ensure you have an Android device connected via USB with Developer Options enabled, OR
2. Have an Android emulator running from Android Studio

#### Run the App:
```bash
# Check connected devices/emulators
flutter devices

# Run on connected Android device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run on specific device (if multiple devices connected)
flutter run -d [device-id]
```

### Production Build

#### Android APK (for testing):
```bash
flutter build apk --release
```

#### Android App Bundle (recommended for Google Play Store):
```bash
flutter build appbundle --release
```

#### Install APK on device:
```bash
# After building APK
flutter install
```


## 📁 Project Structure

```
lib/
├── config/                 # App configuration
│   ├── constants.dart      # App constants
│   ├── routes.dart         # Route definitions
│   └── theme.dart          # App theme configuration
├── core/                   # Core functionality
│   ├── authentication/     # Authentication services
│   ├── services/          # Business logic services
│   └── utils/             # Utility functions
├── models/                # Data models
│   ├── car_owner_models/  # Car owner specific models
│   ├── customer_models/   # Customer specific models
│   └── review_model.dart  # Review data model
├── presentation/          # UI layer
│   └── screens/          # App screens
│       ├── Car Owner/    # Car owner interface
│       ├── customer/     # Customer interface
│       └── Login and Signup/ # Authentication screens
├── shared/               # Shared components
│   ├── common_widgets/   # Reusable UI components
│   ├── constants/        # Shared constants
│   ├── data/            # Static data
│   └── utils/           # Shared utilities
└── main.dart            # App entry point
```

## 🧪 Testing

### Run Unit Tests:
```bash
flutter test
```

### Run Integration Tests:
```bash
flutter drive --target=test_driver/app.dart
```

### Run Widget Tests:
```bash
flutter test test/widget_test.dart
```

## 📱 Supported Platforms

- ✅ **Android** (API 21+ / Android 5.0+)
  - Minimum SDK: API 21 (Android 5.0 Lollipop)
  - Target SDK: API 34 (Android 14)
  - Supports both ARM and x86 architectures

## 🐛 Troubleshooting

### Common Issues:

#### 1. Firebase Configuration Issues:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 2. Gradle Build Errors (Android):
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 3. Android SDK Issues:
```bash
# Check if Android SDK is properly configured
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses
```

#### 4. Dependencies Conflicts:
```bash
flutter pub deps
flutter pub upgrade --major-versions
```

#### 5. Device Connection Issues:
```bash
# Check if device is connected and recognized
adb devices

# Restart ADB server if needed
adb kill-server
adb start-server
```

#### 6. Build Cache Issues:
```bash
# Clear all caches
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
```

## 🔄 Version History

- **v1.0.0** - Initial release with core features
- **v1.1.0** - Added review system and improved UI
- **v1.2.0** - Enhanced booking system and notifications

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>© 2025 Car Rental App. All rights reserved.</p>
</div>
