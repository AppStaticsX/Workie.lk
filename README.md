# Workie - Empowering People 🔧

<div align="center">
  <img src="assets/icon/ic_launcher-web.png" alt="Workie Logo" width="120" height="120">
  
  **A comprehensive job marketplace platform connecting skilled workers with clients**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 About Workie

Workie is a Flutter-based mobile application that serves as a marketplace platform connecting skilled workers (masons, carpenters, tile workers, plumbers, and other tradespeople) with individuals and businesses seeking their services. The app provides a seamless experience for both job seekers and job posters.

### 🎯 Key Features

#### For Workers
- **Profile Creation**: Create detailed professional profiles with skills, experience, and portfolio
- **Job Discovery**: Browse and search for relevant job opportunities
- **Application System**: Apply for jobs with custom proposals and pricing
- **Real-time Notifications**: Stay updated on job applications and client responses
- **Review System**: Build reputation through client reviews and ratings
- **Verification Process**: Secure profile verification for credibility

#### For Clients/Employers
- **Job Posting**: Create detailed job listings with requirements and budgets
- **Worker Search**: Find skilled workers based on location, skills, and ratings
- **Application Management**: Review worker proposals and select the best fit
- **Communication**: Direct messaging with workers
- **Payment Integration**: Secure payment processing
- **Review & Rating**: Rate workers after job completion

#### Additional Features
- **Multi-language Support**: Available in English, Sinhala, and Tamil
- **Location Services**: GPS-based job matching and location tracking
- **Dark/Light Theme**: Customizable UI themes
- **Real-time Chat**: Socket.io integration for instant messaging
- **Push Notifications**: Stay informed about important updates
- **Background Services**: Automated notifications and updates
- **Media Support**: Upload photos and videos for job descriptions and portfolios

## 🚀 Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.7.2+
- **Language**: Dart
- **State Management**: Provider pattern
- **Navigation**: GetX routing
- **Local Storage**: Hive database & SharedPreferences
- **UI Components**: Material Design with custom themes
- **Animations**: Lottie animations for enhanced UX
- **Maps**: Google Maps integration
- **Media**: Image/video picker and display

### Backend (Node.js)
- **Runtime**: Node.js with Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT-based authentication
- **Real-time Communication**: Socket.io
- **File Storage**: Cloudinary integration
- **AI Services**: Integrated AI service for job recommendations

### Key Dependencies
```yaml
# Core Flutter packages
flutter_localization: ^0.3.2    # Multi-language support
provider: ^6.1.5                # State management
get: ^4.7.2                     # Navigation and utilities
hive_flutter: ^1.1.0           # Local database

# UI & Animations
flutter_svg: ^2.1.0            # SVG support
flame_lottie: ^0.4.2+16        # Lottie animations
iconsax_flutter: ^1.0.0        # Modern icons
shimmer_ai: ^1.3.0             # Loading animations

# Location & Maps
google_maps_flutter: ^2.13.1   # Google Maps
geolocator: ^14.0.2            # GPS location
geocoding: ^4.0.0              # Address geocoding

# Communication & Auth
http: ^1.5.0                   # HTTP requests
google_sign_in: ^6.2.1         # Google authentication
socket_io_client: ^3.1.1       # Real-time messaging

# Media & Files
image_picker: ^1.1.2           # Camera/gallery access
video_player: ^2.10.0          # Video playback
file_picker: ^10.3.2           # File selection

# Notifications & Background
flutter_local_notifications: ^19.3.1  # Local notifications
workmanager: ^0.9.0+3                 # Background tasks
permission_handler: ^12.0.1           # App permissions
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── authentication/              # Auth-related screens and logic
├── controllers/                 # Business logic controllers
├── generated/                   # Auto-generated localization files
├── hive_db/                    # Local database models
├── l10n/                       # Localization files (en, si, ta)
├── models/                     # Data models
├── pages/                      # Main application pages
├── pofile_setup/               # Profile setup flow
├── providers/                  # State management providers
├── screens/                    # UI screens
├── secrets/                    # API keys and secrets
├── services/                   # API and business services
├── themes/                     # App theming
├── values/                     # Constants and values
└── widgets/                    # Reusable UI components

assets/
├── animation/                  # Lottie animation files
├── font/                      # Custom fonts (Google Sans, Montserrat, Lato)
├── icon/                      # App icons and profession icons
├── image/                     # Static images
└── video/                     # Video assets

backend/
├── server.js                  # Express server entry point
├── config/                    # Configuration files
├── middleware/                # Custom middleware
├── models/                    # Database models
├── routes/                    # API routes
├── services/                  # Business logic services
└── utils/                     # Utility functions
```

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Node.js (16+ for backend)
- MongoDB (for backend)

### Flutter App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/AppStaticsX/Workie.lk.git
   cd Workie
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run build runner (for Hive models)**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Configure API endpoints**
   - Update base URLs in service files to point to your backend
   - Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`

6. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database and service credentials
   ```

4. **Start the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the backend directory:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/workie
JWT_SECRET=your_jwt_secret_key
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_key
CLOUDINARY_API_SECRET=your_cloudinary_secret
GOOGLE_MAPS_API_KEY=your_google_maps_key
```

### Flutter Configuration
Update the following files with your API endpoints:
- `lib/services/auth_service.dart`
- `lib/services/job_service.dart`
- `lib/services/user_service.dart`

## 🌍 Localization

Workie supports three languages:
- **English** (en)
- **Sinhala** (si)
- **Tamil** (ta)

Localization files are located in `lib/l10n/` directory. To add new translations:

1. Update the `.arb` files in `lib/l10n/`
2. Run `flutter gen-l10n` to generate translation classes
3. Use translations in code: `AppLocalizations.of(context).keyName`

## 🧪 Testing

Run tests using:

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Building for Production

### Android
```bash
# Generate signed APK
flutter build apk --release --split-per-abi

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter's official style guide
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure code is properly formatted (`flutter format .`)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

- **Email**: support.workie@gmail.com
- **GitHub Issues**: [Report bugs or request features](https://github.com/AppStaticsX/Workie.lk/issues)
- **Developer**: AppStaticsX

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google for Maps and authentication services
- MongoDB for database solutions
- Cloudinary for media management
- The open-source community for various packages used

---

<div align="center">
  <p><strong>Made with ❤️ by AppStaticsX</strong></p>
  <p><em>Empowering People Through Technology</em></p>
</div>
