# Alfredo - AI Nutrition Assistant

A voice-first AI-powered nutrition companion for Android built with Flutter.

## Features

- 🎤 **Voice-First Interaction**: Conversational voice interface powered by Google Speech-to-Text and Flutter TTS
- 🤖 **AI-Powered Recipe Generation**: Intelligent, context-based recipes from pantry data
- 📦 **Smart Pantry Management**: Track pantry items with expiry dates, quantities, and categories
- 📊 **Nutrition Tracking & Analytics**: Visual dashboards showing daily calorie & macro breakdown
- 🛒 **Intelligent Shopping Lists**: Auto-generated shopping lists based on missing ingredients
- 👥 **Community Recipes**: Share and discover recipes from the community
- 🎨 **Modern UI**: Clean, intuitive interface with smooth animations

## Screenshots

- Home Screen with AI recipes and voice interface
- Diet & Nutrition tracking with BMI, BMR, TDEE calculations
- Community recipes with ratings and reviews
- Smart Pantry with quantity management
- User Profile with editable information

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Charts**: fl_chart
- **Voice**: speech_to_text, flutter_tts
- **Fonts**: Google Fonts (Inter)
- **Icons**: Material Icons, Font Awesome

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2+)
- Android SDK
- Java JDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Prthmsh7/HackCBS8.0.git
cd HackCBS8.0
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # App screens
├── widgets/                  # Reusable widgets
├── theme/                    # App theme configuration
└── services/                # Business logic services
```

## Permissions

The app requires the following Android permissions:
- `RECORD_AUDIO` - For voice recognition
- `INTERNET` - For API calls

## License

This project is part of HackCBS 8.0.
