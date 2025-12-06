README.md (Complete Project Documentation)

```markdown
# 🧠 MEMORIA - Your Second Brain

![MEMORIA Logo](assets/images/splash_logo.png)

**A universal second-brain app that instantly saves, organizes, and protects all your important information locally with AI-powered features.**

---

## ✨ Features

### 🎯 **Universal Capture**
- 📝 **Text** - Notes, ideas, tasks
- 📸 **Photos & Screenshots** - With AI-powered OCR
- 📄 **Documents** - PDFs, Word, Excel, PowerPoint
- 🧾 **Bills & Receipts** - Auto-categorization
- 🆔 **IDs & Certificates** - Secure storage
- 🎤 **Voice Notes** - Real-time transcription
- 🔗 **Links & URLs** - Web content saving
- 📱 **WhatsApp/Instagram** - Forwarded items support

### 🧠 **AI-Powered Intelligence**
- 🤖 **Auto-Categorization** - AI detects content type automatically
- 🏷️ **Smart Tagging** - Automatic keyword extraction
- 🔍 **NLP Smart Search** - Search naturally: "Find my passport from last year"
- ⏰ **AI Reminders** - Auto-detect due dates, expiry dates
- 📊 **Smart Folders** - Auto-organize based on rules

### 🔒 **Military-Grade Security**
- 🛡️ **AES-256 Encryption** - Bank-level security
- 🔐 **LifeVault** - PIN + Biometric protected storage
- 📱 **100% Offline** - No cloud, no internet required
- 🔗 **Device-Locked** - Subscription tied to device
- 🚫 **No Backend** - Everything stored locally

### 💰 **Subscription Plans**

| Plan | Price | Storage | Retention | Features |
|------|-------|---------|-----------|----------|
| **Free** | $0 | 100 Saves | 30 days | Basic features, Ad-supported |
| **Basic** | $1.99/mo | 10GB | 60 days | AI categorization, No ads |
| **Pro** | $3.99/mo | Unlimited | 1 year | AI reminders, Smart search |
| **Vault+** | $9.99/yr | Unlimited | 1 year | LifeVault, Premium AI |

### 📱 **Platform Support**
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Dark/Light Mode**
- ✅ **Biometric Authentication**
- ✅ **Local Currency Support**

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0.0 or higher
- Android Studio / Xcode
- Java 11+ (for Android)
- CocoaPods (for iOS)

### Installation

1. **Clone and Setup**
```bash
flutter create memoria
cd memoria
```

1. Copy Project Files

```bash
# Replace all files with provided code
# All 143 files are provided in the repository
```

1. Generate Assets

```bash
# Generate splash logo and icons
python create_splash_logo.py
python create_onboarding_images.py
```

1. Install Dependencies

```bash
flutter pub get
```

1. Generate Hive Adapters

```bash
flutter packages pub run build_runner build
```

1. Generate Splash Screen

```bash
flutter pub run flutter_native_splash:create
```

Running the App

Development:

```bash
flutter run
```

Build Release APK:

```bash
flutter build apk --release
```

Build App Bundle:

```bash
flutter build appbundle --release
```

Build for iOS:

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

---

⚙️ Configuration

🔑 API Keys Setup

1. AdMob Configuration (Get from Google AdMob)

```dart
// Update in lib/constants/constants.dart
static const String admobAppId = 'YOUR_ADMOB_APP_ID';
static const String admobBannerId = 'YOUR_BANNER_AD_ID';
static const String admobInterstitialId = 'YOUR_INTERSTITIAL_AD_ID';
static const String admobRewardedId = 'YOUR_REWARDED_AD_ID';
```

2. Razorpay Configuration (Get from Razorpay Dashboard)

```dart
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET';
```

3. Fonts Setup
Download these fonts and place inassets/fonts/:

· Inter Regular → Inter-Regular.ttf
· Inter Bold → Inter-Bold.ttf
· Use iOS default font or download SF Pro

📱 Platform Configuration

Android (android/app/build.gradle):

```gradle
applicationId "tech.mymemoria.memoria"
minSdkVersion 21
targetSdkVersion flutter.targetSdkVersion
```

Android Manifest (android/app/src/main/AndroidManifest.xml):

· Update AdMob app ID
· Update package name
· Set permissions

iOS (ios/Runner/Info.plist):

· Update bundle identifier
· Add AdMob app ID
· Set permission descriptions

---

📁 Project Structure

```
memoria/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/                        # Flutter application
│   ├── constants/             # App constants, routes, colors
│   ├── models/               # Data models (User, Item, Subscription)
│   ├── providers/            # State management (Provider)
│   ├── screens/              # 28 app screens
│   ├── services/             # Business logic services
│   ├── utils/                # Helpers, validators, themes
│   └── widgets/              # Reusable UI components
├── assets/
│   ├── images/              # App images, icons
│   ├── icons/               # SVG icons
│   ├── fonts/               # Custom fonts
│   └── lottie/              # Animation files
├── pubspec.yaml             # Dependencies
├── README.md               # This file
└── .gitignore              # Git ignore rules
```

📊 Screen Architecture

```
Splash → Onboarding → Signup/Login → Device Binding → Home
     ↓
Save Anything Flow:
     ├── Text/Link/Note/Task
     ├── Photo Upload + OCR
     ├── Document Upload
     └── Voice to Text
     ↓
Organization:
     ├── Auto-Categorization
     ├── Smart Folders
     ├── AI Reminders
     └── Smart Search
     ↓
Security:
     ├── LifeVault (AES-256)
     └── Encrypted Backup
     ↓
Subscription:
     ├── Plan Selection
     ├── Razorpay Payment
     └── Feature Unlock
```

---

🔧 Technical Implementation

Database & Storage

· Hive - Lightweight, fast NoSQL database
· Encrypted Boxes - AES-256 encryption for sensitive data
· File System - Local file storage for documents/images

State Management

· Provider - For app-wide state
· Hive - For persistent storage
· Streams - For real-time updates

AI & Machine Learning

· On-Device ML - No cloud processing
· Google ML Kit - Text recognition, image labeling
· Custom NLP - Natural language processing
· OCR - Optical character recognition

Security Features

· AES-256 Encryption - For vault items
· Biometric Auth - Face ID / Touch ID / Fingerprint
· Device Locking - Subscription tied to device ID
· Anti-Tamper - Clock rollback detection

Payment Integration

· Razorpay - Payment gateway
· In-App Purchases - Platform-native payments
· Currency Conversion - Automatic localization

Ads Integration

· Google AdMob - Banner, interstitial, rewarded ads
· Ad Control - Ads only for free plan users
· Rewarded Ads - Watch ads for extra saves

---

🛠️ Development

Code Generation

```bash
# Generate Hive adapters
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean build
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Specific test file
flutter test test/unit_test.dart
```

Code Quality

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Check dependencies
flutter pub outdated
```

Build Flavors

```bash
# Development build
flutter run --flavor dev

# Production build
flutter run --flavor prod

# Build APK with flavor
flutter build apk --flavor prod --release
```

---

🔐 Security Considerations

Data Protection

· All sensitive data encrypted with AES-256
· Encryption keys stored in secure storage (Keychain/Keystore)
· No data leaves the device
· Local backups are password-protected

Subscription Security

· Device ID binding prevents sharing
· HMAC verification for payments
· Anti-tamper mechanisms
· Grace period for expired subscriptions

Permissions

```
Android:
- Camera: For capturing photos/documents
- Storage: For saving files
- Microphone: For voice notes
- Biometric: For LifeVault

iOS:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSMicrophoneUsageDescription
- NSFaceIDUsageDescription
```

---

📱 Platform-Specific Notes

Android

```xml
<!-- Minimum SDK: 21 -->
<!-- Target SDK: Latest -->
<!-- Uses Material Design 3 -->
<!-- Adaptive icons support -->
<!-- Deep linking support -->
```

iOS

```swift
// Minimum iOS: 12.0
// Swift version: 5.0
// Uses SwiftUI for some components
// Face ID/Touch ID support
// App Groups for sharing
```

Web (Future)

· Planned for future release
· IndexedDB for storage
· Service workers for offline
· PWA support

---

🚨 Troubleshooting

Common Issues

1. AdMob ads not showing
   · Verify AdMob IDs are correct
   · Check network connectivity
   · Test with test device IDs
   · Wait 24 hours for new AdMob accounts
2. Razorpay payment failing
   · Verify Razorpay keys
   · Check internet connection
   · Test with Razorpay test cards
   · Verify webhook configuration
3. Storage permission issues
   · Check AndroidManifest permissions
   · Verify iOS Info.plist permissions
   · Request permissions at runtime
   · Check storage space
4. Build errors
   ```bash
   # Clean project
   flutter clean
   
   # Delete pubspec.lock
   rm pubspec.lock
   
   # Reinstall packages
   flutter pub get
   
   # For iOS
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```
5. Hive errors
   ```bash
   # Delete Hive boxes
   rm -rf android/app/data
   
   # Regenerate adapters
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

Debug Mode

```dart
// Enable debug logs
void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      print('MEMORIA: $message');
    }
  };
  runApp(MyApp());
}
```

---

📈 Performance Optimization

Image Optimization

· Compress images before saving
· Use appropriate resolutions
· Lazy loading for lists
· Cache frequently used images

Database Optimization

· Use Hive for fast read/write
· Index frequently queried fields
· Batch operations for bulk data
· Regular cleanup of old data

Memory Management

· Dispose controllers properly
· Use const constructors where possible
· Implement EfficientListView
· Monitor memory usage in DevTools

Battery Optimization

· Background tasks limited
· Efficient use of sensors
· Batch network requests
· Proper lifecycle management

---

📋 Deployment Checklist

Pre-Launch

· Replace all dummy API keys
· Update app icons and splash screen
· Configure Firebase (if using)
· Update privacy policy URLs
· Test subscription flows end-to-end
· Verify ads are working correctly
· Test on multiple devices and OS versions
· Enable ProGuard/R8 (Android)
· Configure app signing certificates

Android Play Store

· Generate signed APK/AAB
· Create store listing
· Add screenshots and videos
· Set up pricing and distribution
· Configure in-app products
· Set up content rating
· Configure data safety form
· Submit for review

iOS App Store

· Create App Store Connect record
· Generate distribution certificate
· Create provisioning profile
· Archive and upload build
· Configure app metadata
· Set up in-app purchases
· Submit for App Review

Post-Launch

· Monitor crash reports
· Track analytics
· Gather user feedback
· Plan update roadmap
· Monitor revenue and ads performance

---

📚 Documentation

API Reference

· Flutter Documentation
· Hive Documentation
· AdMob Documentation
· Razorpay Documentation
· Google ML Kit

Design Resources

· Colors: Royal Blue (#1F6FEB), Deep Gold (#D4AF37)
· Typography: Inter (Primary), SF Pro (iOS)
· Icons: Custom SVG icons provided
· Spacing: 8px grid system
· Radius: 22px for cards, 16px for buttons

Support

· GitHub Issues: For bug reports and feature requests
· Email: support@mymemoria.tech
· Documentation: https://docs.mymemoria.tech
· Community: Discord/Slack (coming soon)

---

🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

Code Style

· Follow Dart style guide
· Use meaningful variable names
· Add comments for complex logic
· Write unit tests for new features

Commit Guidelines

```
feat: Add new feature
fix: Bug fix
docs: Documentation changes
style: Code style changes
refactor: Code refactoring
test: Add tests
chore: Maintenance tasks
```

---

📄 License

```
©Copyright 2025 MEMORIA

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Third-Party Licenses

· Flutter - BSD 3-Clause
· Hive - Apache 2.0
· Google ML Kit - Apache 2.0
· AdMob - Proprietary
· Razorpay - MIT

---

🎯 Roadmap

Q1 2025 (Current)

· ✅ Core app development
· ✅ Local AI implementation
· ✅ Subscription system
· ✅ Security features

Q2 2025

· 🔄 Web version
· 🔄 Cloud sync (optional)
· 🔄 Advanced AI features
· 🔄 Team collaboration

Q3 2025

· 📅 API for developers
· 📅 Browser extension
· 📅 Wear OS / WatchOS app
· 📅 Advanced analytics

Q4 2025

· 🚀 Enterprise features
· 🚀 White-label solutions
· 🚀 Advanced automation
· 🚀 Marketplace for plugins

---

🙏 Acknowledgments

· Flutter Team - For the amazing framework
· Hive Team - For the lightweight database
· Google ML Kit Team - For on-device AI
· Razorpay - For payment solutions
· All Contributors - For making this possible

---

📞 Contact

Website: https://mymemoria.tech
Email: hello@mymemoria.tech
Twitter: @memoria_app
GitHub: github.com/memoria-app
