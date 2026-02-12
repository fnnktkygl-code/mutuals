# Famille.io 👨‍👩‍👧‍👦

**Ultimate Safe Space - Never get the wrong size again!**

A beautiful Flutter mobile app for tracking family and friends' clothing sizes, favorite brands, and gift wishes.

## 🌟 Features

- **👥 Member Profiles** - Store detailed info for family, friends, and loved ones
- **👕 Wardrobe Tracking** - Track sizes for tops, bottoms, shoes, and accessories
- **🎁 Monthly Wishes** - One unique gift wish per month with 12-month history
- **📅 Yearly Timeline** - Visual timeline showing everyone's wishes across 12 months
- **🎨 Glassmorphism UI** - Beautiful frosted glass design with dark mode
- **💾 Data Persistence** - All data saved locally with SharedPreferences
- **🌓 Dark Mode** - Seamless light/dark theme switching
- **📤 Share** - Export member summary to WhatsApp or other apps

## 📱 Screenshots

The app features:
- 3-step onboarding flow
- Member list with gradient avatars
- Detailed member profiles with edit mode
- 12-month rolling timeline
- Settings screen with dark mode toggle

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone or navigate to the project:
   ```bash
   cd /Users/richard/Desktop/famille_io
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # iOS Simulator
   flutter run

   # Or specify a device
   flutter run -d <device_id>
   ```

### Building for Release

```bash
# iOS
flutter build ios

# Android
flutter build apk  # APK file
flutter build appbundle  # Google Play Store
```

## 📦 Dependencies

- **provider** - State management
- **shared_preferences** - Local data storage
- **intl** - Internationalization and date formatting
- **share_plus** - Native sharing functionality
- **flutter_animate** - Smooth animations
- **google_fonts** - Inter font family

## 🎨 Design System

### Glassmorphism
- Frosted glass effect with backdrop blur
- Subtle gradients and shadows
- Smooth transitions and animations

### Color Gradients
Six beautiful gradients for member avatars:
- 💜 Purple (default)
- 💙 Blue
- 💗 Pink-Rose
- 🧡 Orange-Amber
- 💚 Emerald-Teal
- 🖤 Slate

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular (400), Medium (500), Bold (700), Black (900)

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # All app screens
├── widgets/                  # Reusable components
├── services/                 # Business logic & state
├── utils/                    # Helper functions
└── theme/                    # Design system
```

## 💡 Usage

### Adding a Member
1. Tap "Ajouter un profil" on home screen
2. Enter name and relationship
3. Select category (Family, Friends, Other)
4. Choose a gradient color
5. Add wardrobe items and sizes
6. Set fit preference
7. Add monthly wish and permanent wishlist

### Tracking Monthly Wishes
- Each month, set one special gift wish per member
- View wish history for past 12 months
- Mark wishes as "gifted" when fulfilled
- Timeline screen shows all wishes at a glance

### Sharing
Use the share feature to export a summary of:
- Member names and relationships
- Key sizes (shoes, tops)
- Current month wishes

Perfect for coordinating family gift purchases!

## 🧪 Sample Data

The app comes with 6 pre-configured members:
- **Fenneko** (Owner) - Complete profile with size S-M clothing
- **Lugia** (Mother) - Oversize preference, size XXL
- **Embrylex** (Little Brother) - Kids sizes, age 10
- **Gaara** (Brother) - Outdoor/utility style
- **Suzuki** (Sister) - Motorcycle gear enthusiast
- **Kaneki** (Friend) - Slim fit, dark aesthetic

## 🔒 Privacy

- All data stored locally on device
- No internet connection required
- No data collected or shared with third parties
- Reset app at any time from settings

## 🛠️ Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib/
```

## 📝 License

This project is private and not licensed for public use.

## 🙏 Credits

- **Original Design**: HTML/React web application
- **Flutter Migration**: Complete transformation to native mobile
- **Icons**: Material Icons & Lucide Icons
- **Fonts**: Inter by Google Fonts

## 📧 Support

For questions or issues, please contact the project maintainer.

---

**Made with ❤️ using Flutter**
