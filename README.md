# 💇 Salon Booking Flutter App

A modern Flutter-based salon booking application with authentication, appointment scheduling, online payments, notifications, and Google Maps integration.

---

# 📱 Features

- User Authentication
- Google Sign-In
- Salon Discovery
- Treatment Booking
- Appointment Scheduling
- Google Places Integration
- Notifications
- Responsive UI
- REST API Integration
- Clean Architecture

---

# 🚀 Tech Stack

- Flutter
- Dart
- REST API
- Google Sign-In
- Google Places API
- Firebase (Optional)
- Provider / Bloc / Riverpod

---

# 📋 Prerequisites

Before running the project, make sure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Git
- Android Emulator or Physical Device
- Xcode (for iOS development on macOS)

---

# 🔧 Flutter Installation

Install Flutter from:

https://flutter.dev/docs/get-started/install

Verify installation:

```bash
flutter doctor
```

---

# 📥 Clone the Repository

```bash
git clone https://github.com/LegitFR/ProBeauty-App.git
```

# 📦 Install Dependencies

```bash
flutter pub get
```

---

# 🌍 Environment Setup

Create a `.env` file in the assets/ directory of the project. refer the .env.example

Example `.env` file:

```env
# =========================================================
# API CONFIGURATION
# =========================================================

# Production API URL
# API_BASE_URL=http://vps-9ebf5d76.vps.ovh.net:5000

# Development / Ngrok API URL
API_BASE_URL=https://628a-2405-201-e057-a867-e0ea-a675-6b3a-396b.ngrok-free.app


# =========================================================
# STRIPE CONFIGURATION
# =========================================================

STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here


# =========================================================
# GOOGLE AUTH CONFIGURATION
# =========================================================

GOOGLE_WEB_CLIENT_ID=your_google_web_client_id_here


# =========================================================
# IFTHENPAY CONFIGURATION
# =========================================================

IFTHENPAY_ANTI_PHISHING_KEY=your_ifthenpay_anti_phishing_key_here


# =========================================================
# GOOGLE PLACES / MAPS CONFIGURATION
# =========================================================

GOOGLE_PLACES_API_KEY=your_google_places_api_key_here
```

---

# ⚠️ Important Security Notes

- Never expose production secrets publicly.
- Never commit `.env` files to GitHub.
- Always use environment variables for sensitive keys.

Add `.env` to your `.gitignore`:

```gitignore
.env
```

---

# ▶️ Running the Application

## Check Connected Devices

```bash
flutter devices
```

---

## Run the Application

```bash
flutter run
```

---

## Run on Chrome

```bash
flutter run -d chrome
```

---

## Run on Android Emulator

```bash
flutter run -d emulator-5554
```

---

# 🏗️ Building the App

## Build Debug APK

```bash
flutter build apk --debug
```

---

## Build Release APK

```bash
flutter build apk --release
```

Generated APK Location:

```plaintext
build/app/outputs/flutter-apk/
```

---

# 🍎 Build iOS App

```bash
flutter build ios
```

> Requires macOS and Xcode.

---

# 🧹 Cleaning the Project

```bash
flutter clean
```

Then reinstall dependencies:

```bash
flutter pub get
```

---

# 🔍 Useful Flutter Commands

## Analyze Project

```bash
flutter analyze
```

---

## Check Flutter Setup

```bash
flutter doctor
```

---

## Upgrade Flutter

```bash
flutter upgrade
```

---
