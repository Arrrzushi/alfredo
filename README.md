<div align="center">

# 🍝 **ALFREDO** 
### *AI-Powered Nutrition Companion*

[![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://gemini.google.com)
[![ML Kit](https://img.shields.io/badge/ML_Kit-FF6F00?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/ml-kit)

**Voice-First AI Cooking Assistant | Real-Time Vision Analysis | Smart Pantry Management**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Installation](#-installation) • [Demo](#-demo)

---

</div>

## 🎯 **Overview**

**Alfredo** is a cutting-edge, voice-first AI nutrition companion that revolutionizes how you interact with your kitchen. Built with Flutter and powered by Google Gemini 2.5 Flash, it combines real-time computer vision, natural language processing, and intelligent recipe generation to create a seamless cooking experience.

### **Core Philosophy**
> *"Cooking should be hands-free, intelligent, and delightful. Alfredo makes that possible."*

---

## ✨ **Features**

### 🎤 **Voice-First Interaction**
- **Real-time Speech-to-Text** using Google Speech Recognition
- **Natural Text-to-Speech** responses with Flutter TTS
- **Hands-free operation** - perfect for cooking
- **Interrupt handling** - AI stops speaking when you start

### 🤖 **AI Video Call Mode**
- **Real-time camera feed** with periodic frame capture
- **Google ML Kit** object detection & image labeling
- **Gemini 2.5 Flash Vision** for direct image analysis
- **Context-aware responses** based on what you're cooking
- **Safety hazard detection** (knives, hot surfaces, steam)

### 📦 **Smart Pantry Management**
- **CRUD operations** via voice commands
- **Expiry date tracking** with smart notifications
- **Category organization** (Fruits, Vegetables, Dairy, etc.)
- **Quantity management** with units (g, kg, pieces, L)
- **Real-time Firestore sync** across devices

### 🍳 **Intelligent Recipe Generation**
- **Context-based recipes** from available pantry items
- **Dietary preference support** (Vegetarian, Vegan, Keto, etc.)
- **Nutrition-aware suggestions** based on user goals
- **Community recipe sharing** with ratings
- **Step-by-step voice guidance**

### 📊 **Nutrition Tracking & Analytics**
- **BMI, BMR, TDEE calculations** (Mifflin-St Jeor equation)
- **Macro tracking** (Protein, Carbs, Fats)
- **Visual dashboards** with fl_chart
- **Goal-based recommendations** (Lose/Gain/Maintain/Build Muscle)
- **Daily progress tracking**

### 🛒 **Intelligent Shopping Lists**
- **Auto-generated** from missing ingredients
- **Category-based organization**
- **Completion tracking**
- **Voice-controlled** additions

---

## 🛠️ **Tech Stack**

### **Frontend**
```
Flutter 3.7.0+          → Cross-platform UI framework
Dart 3.7.0+             → Type-safe, compiled language
Material Design 3       → Modern, adaptive UI components
Provider                → State management
fl_chart               → Beautiful data visualizations
Google Fonts (Inter)    → Typography system
```

### **Backend & Services**
```
Firebase Firestore      → NoSQL database (real-time sync)
Firebase Auth           → Anonymous authentication
Google Gemini 2.5 Flash → Vision-capable LLM
ML Kit Object Detection → Real-time object recognition
ML Kit Image Labeling   → Food & kitchen item classification
Camera (CameraX)        → High-resolution image capture
```

### **Voice & Speech**
```
speech_to_text 7.0.0    → Speech recognition
flutter_tts 4.0.2       → Text-to-speech synthesis
```

### **Key Dependencies**
```yaml
firebase_core: ^3.6.0
cloud_firestore: ^5.4.3
firebase_auth: ^5.3.1
camera: ^0.11.0+2
google_mlkit_object_detection: ^0.15.0
google_mlkit_image_labeling: ^0.14.1
http: ^1.2.0
provider: ^6.1.1
```

---

## 🏗️ **Architecture**

### **Project Structure**
```
lib/
├── main.dart                 # App entry, navigation, theme
├── models/                   # Data models (6 models)
│   ├── recipe.dart
│   ├── pantry_item.dart
│   ├── meal.dart
│   ├── shopping_item.dart
│   ├── nutrition_data.dart
│   └── ai_call_state.dart
├── screens/                  # UI screens (6 screens)
│   ├── home_screen.dart
│   ├── ai_call_screen.dart
│   ├── smart_pantry_screen.dart
│   ├── diet_nutrition_screen.dart
│   ├── community_screen.dart
│   └── user_profile_screen.dart
├── services/                 # Business logic (11 services)
│   ├── ai_call_service.dart      # Gemini API integration
│   ├── camera_service.dart       # Camera operations
│   ├── ml_kit_service.dart       # ML Kit detection
│   ├── pantry_service.dart        # Pantry CRUD
│   ├── recipe_service.dart        # Recipe management
│   ├── meal_service.dart          # Meal tracking
│   ├── shopping_service.dart      # Shopping lists
│   ├── auth_service.dart          # Firebase Auth
│   ├── firestore_service.dart     # Firebase base
│   ├── user_data_service.dart     # User calculations
│   └── user_profile_service.dart  # Profile management
├── providers/                # State management
│   └── ai_call_provider.dart
├── widgets/                  # Reusable components
│   ├── voice_button.dart
│   ├── search_bar.dart
│   └── neomorphic_container.dart
└── theme/                    # App theming
    └── app_theme.dart
```

### **Design Patterns**
- **Service Layer Architecture** - Separation of business logic
- **Provider Pattern** - Reactive state management
- **Repository Pattern** - Data access abstraction
- **MVVM-like** - Clear separation of concerns

### **Data Flow**
```
User Voice Input
    ↓
Speech-to-Text
    ↓
AI Call Provider
    ↓
Camera Capture → ML Kit Detection
    ↓
Gemini API (Vision + Text)
    ↓
Tool Calls → Firebase Services
    ↓
State Update → UI Refresh
    ↓
Text-to-Speech Response
```

---

## 📈 **Project Statistics**

<div align="center">

| Metric | Value |
|:------:|:-----:|
| **Total Dart Files** | 30 |
| **Lines of Code** | ~5,000+ |
| **Screens** | 6 |
| **Services** | 11 |
| **Models** | 6 |
| **Widgets** | 3 |
| **Dependencies** | 15+ |
| **Platform Support** | Android (Primary), iOS, Web, Desktop |

</div>

### **Code Distribution**
```
Services:     35%  (Business logic, API integrations)
Screens:      30%  (UI implementation)
Models:       15%  (Data structures)
Widgets:      10%  (Reusable components)
Theme/Config: 10%  (Styling, configuration)
```

---

## 🚀 **Installation**

### **Prerequisites**
- Flutter SDK 3.7.0+
- Android SDK (API 21+)
- Java JDK 11+
- Firebase project configured
- Google Gemini API key

### **Setup Steps**

1. **Clone the repository**
   ```bash
   git clone https://github.com/Arrrzushi/alfredo.git
   cd alfredo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Place `google-services.json` in `android/app/`
   - Enable Anonymous Authentication in Firebase Console
   - Deploy Firestore rules: `firebase deploy --only firestore:rules`

4. **Configure Gemini API**
   - Update API key in `lib/services/ai_call_service.dart`
   - Or use environment variables (recommended)

5. **Run the app**
   ```bash
   flutter run
   ```

### **Firebase Setup**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Enable **Anonymous Authentication** (Sign-in method → Anonymous → Enable)
3. Deploy Firestore rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## 🎬 **Demo**

### **AI Video Call Flow**
1. Open AI Call screen → Camera initializes
2. User speaks → Speech-to-Text converts to text
3. Camera captures frame → ML Kit analyzes image
4. Frame + ML Kit data + text → Gemini API
5. Gemini responds with:
   - Text response (spoken via TTS)
   - Tool calls (pantry operations, timers)
   - State updates (recipe progress)

### **Voice Commands**
```
"Add apple to my pantry"
"What's in my pantry?"
"Generate a recipe with my available ingredients"
"Set a timer for 10 minutes"
"Log this meal"
"Add tomatoes to shopping list"
```

---

## 🔐 **Security**

### **Firebase Security Rules**
- **User isolation** - Users can only access their own data
- **Authentication required** - All operations require auth
- **Anonymous auth** - Automatic sign-in for seamless experience
- **Server-side validation** - Firestore rules enforce data integrity

### **Data Privacy**
- All data stored in user-scoped Firestore collections
- Anonymous authentication (no personal info required)
- Local ML Kit processing (no images sent to Google ML)
- Only processed frames sent to Gemini API

---

## 🧮 **Nutrition Calculations**

### **BMI Calculation**
```dart
BMI = weight (kg) / (height (m))²
```

### **BMR (Mifflin-St Jeor)**
```dart
Male:   10 × weight + 6.25 × height - 5 × age + 5
Female: 10 × weight + 6.25 × height - 5 × age - 161
```

### **TDEE**
```dart
TDEE = BMR × Activity Multiplier (1.55 for moderate activity)
```

### **Macro Goals**
- **Protein**: 1.6-2.2g per kg (based on goal)
- **Fat**: 25% of total calories
- **Carbs**: Remaining calories after protein & fat

---

## 🎨 **UI/UX Design**

### **Color Palette**
- **Primary**: Orange (`#FD6F24`) - Warm, inviting
- **Accent**: Yellow (`#F1F3C2`) - Fresh, energetic
- **Success**: Green (`#4CAF50`)
- **Typography**: Inter (Google Fonts)

### **Design Principles**
- **Voice-first** - Optimized for hands-free interaction
- **Minimal UI** - Clean, uncluttered interface
- **Real-time feedback** - Visual indicators for all actions
- **Accessibility** - High contrast, readable fonts

---

## 🐛 **Troubleshooting**

### **Common Issues**

**"User not authenticated"**
- Enable Anonymous Authentication in Firebase Console
- Restart the app

**"Permission denied" in Firestore**
- Deploy Firestore rules: `firebase deploy --only firestore:rules`
- Verify user is authenticated (check logs)

**Camera not working**
- Grant camera permission
- Check device compatibility

**ML Kit detection failing**
- Verify ML Kit dependencies are installed
- Check device has sufficient resources

---

## 📝 **License**

This project is part of **HackCBS 8.0**.

---

## 🤝 **Contributing**

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📧 **Contact**

For questions or support, please open an issue on GitHub.

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

⭐ **Star this repo if you find it helpful!** ⭐

[![GitHub stars](https://img.shields.io/github/stars/Arrrzushi/alfredo?style=social)](https://github.com/Arrrzushi/alfredo/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Arrrzushi/alfredo?style=social)](https://github.com/Arrrzushi/alfredo/network/members)

</div>
