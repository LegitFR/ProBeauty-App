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

Create a `.env` file in the root directory of the project.

Example `.env` file:

```env
# API Base URL

# Production Server
# API_BASE_URL=http://vps-9ebf5d76.vps.ovh.net:5000

# Development / Ngrok URL
API_BASE_URL=https://628a-2405-201-e057-a867-e0ea-a675-6b3a-396b.ngrok-free.app


# Stripe Publishable Key
STRIPE_PUBLISHABLE_KEY=pk_test_51SSLPXFg60Wha3A5QhjKRseEZTKPkpEIfQdfGp0p2TKi7ScL6CSbJmsQUB6VzDwpZsN9foPJfmFZYVq5Z9JSX2I700VsaiuHRe


# Google OAuth Web Client ID
GOOGLE_WEB_CLIENT_ID=744378484852-l7o5h92lorsucarblhjh4i1t4v019or5.apps.googleusercontent.com


# IFTHENPAY Anti Phishing Key
IFTHENPAY_ANTI_PHISHING_KEY=60f29776c24a01b29e97201cc3c94c51


# Google Places API Key
GOOGLE_PLACES_API_KEY=YOUR_GOOGLE_PLACES_API_KEY
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
