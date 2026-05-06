# 🧮 Toán Trắc Nghiệm - Math Quiz Cho Bé

Ứng dụng trắc nghiệm Toán học dành cho học sinh Tiểu học, được xây dựng bằng **Flutter** và **Firebase Firestore**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Mục Lục

- [Tính Năng](#-tính-năng)
- [Sơ Đồ Cấu Trúc Dự Án](#-sơ-đồ-cấu-trúc-dự-án)
- [Yêu Cầu Hệ Thống](#-yêu-cầu-hệ-thống)
- [Hướng Dẫn Cài Đặt](#-hướng-dẫn-cài-đặt)
- [Cấu Trúc Database](#-cấu-trúc-database-firestore)
- [Giải Thích Chi Tiết Code](#-giải-thích-chi-tiết-code)
- [Chạy Ứng Dụng](#-chạy-ứng-dụng)

---

## ✨ Tính Năng

| Tính Năng | Mô Tả |
|---|---|
| 🎮 **3 Cấp Độ** | Cấp 1 (+/- ≤10), Cấp 2 (+/- ≤100), Cấp 3 (×/÷) |
| ⏱️ **Time Attack** | Đếm ngược 10 giây, điểm thưởng theo thời gian còn lại |
| 📝 **60 Câu Hỏi Có Sẵn** | 20 câu/cấp độ, lưu trên Firestore |
| 👤 **Hồ Sơ Người Chơi** | Chọn avatar emoji, đặt tên, theo dõi thành tích |
| 🔐 **Admin Panel** | Đăng nhập PIN, CRUD câu hỏi, quản lý cài đặt |
| 🔊 **Âm Thanh** | Nhạc nền, hiệu ứng đúng/sai ngẫu nhiên, tiếng vỗ tay |
| 🔥 **Firebase Firestore** | Đồng bộ dữ liệu realtime, lưu lịch sử chơi |
| 🎨 **UI Sinh Động** | Animation mượt mà, màu sắc pastel thân thiện trẻ em |

---

## 📁 Sơ Đồ Cấu Trúc Dự Án

```
matchquizapp/
├── lib/                          # Source code chính
│   ├── main.dart                 # Entry point + Màn hình chính (MainScreen)
│   ├── firebase_options.dart     # Cấu hình Firebase (auto-generated)
│   │
│   ├── models/                   # Data Models
│   │   ├── question.dart         # Model câu hỏi (auto-generate + custom)
│   │   ├── custom_question.dart  # Model câu hỏi từ Firestore
│   │   └── user_profile.dart     # Model hồ sơ người chơi
│   │
│   ├── providers/                # State Management (Provider pattern)
│   │   ├── game_provider.dart    # Logic game: điểm, câu hỏi, vòng chơi
│   │   ├── user_provider.dart    # Quản lý profile người dùng
│   │   └── admin_provider.dart   # Quản lý Admin Panel
│   │
│   ├── screens/                  # Giao diện màn hình
│   │   ├── game_screen.dart      # Màn hình chơi game (timer, options)
│   │   ├── result_screen.dart    # Màn hình kết quả
│   │   ├── profile_screen.dart   # Màn hình hồ sơ người chơi
│   │   └── admin/                # Admin Panel
│   │       ├── admin_login_screen.dart     # Đăng nhập PIN
│   │       ├── admin_dashboard_screen.dart # Dashboard quản trị
│   │       └── question_form_screen.dart   # Form thêm/sửa câu hỏi
│   │
│   ├── services/                 # Business Logic & API
│   │   ├── database_service.dart # CRUD Firestore + Seed data
│   │   └── audio_service.dart    # Quản lý âm thanh (BGM + SFX)
│   │
│   └── utils/                    # Tiện ích
│       └── math_generator.dart   # Tự động sinh câu hỏi toán
│
├── assets/
│   └── audio/                    # File âm thanh
│       ├── bgm.mp3               # Nhạc nền
│       ├── correct1-3.mp3        # Hiệu ứng trả lời đúng (3 bản)
│       ├── wrong1-4.mp3          # Hiệu ứng trả lời sai (4 bản)
│       └── applause.mp3          # Tiếng vỗ tay kết thúc
│
├── pubspec.yaml                  # Dependencies & cấu hình Flutter
├── firebase.json                 # Cấu hình Firebase hosting
└── README.md                     # File này
```

---

## 💻 Yêu Cầu Hệ Thống

- **Flutter SDK** ≥ 3.11.4
- **Dart SDK** ≥ 3.11.4
- **Node.js** (cho Firebase CLI, tùy chọn)
- **Trình duyệt Chrome** (cho Flutter Web)
- **Tài khoản Firebase** (miễn phí)

---

## 🚀 Hướng Dẫn Cài Đặt

### Bước 1: Clone dự án

```bash
git clone https://github.com/chau2512/ltddtgruop.git
cd ltddtgruop
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase

#### 3.1. Tạo project Firebase
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Nhấn **"Add Project"** → đặt tên → tạo
3. Vào **Firestore Database** → **Create Database** → chọn **Test Mode**
4. Chọn location: `asia-southeast1` (Singapore)

#### 3.2. Đăng ký Web App
1. Trong Firebase Console → **Project Settings** → **Your Apps**
2. Nhấn icon **`</>`** (Web) → đặt tên → Register
3. Copy đoạn `firebaseConfig`

#### 3.3. Cập nhật cấu hình
Mở file `lib/firebase_options.dart` và thay thế các giá trị:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT.firebasestorage.app',
);
```

#### 3.4. Thiết lập Firestore Security Rules
Vào **Firestore → Rules** → paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```
> ⚠️ Đây là rules cho development. Khi deploy production cần thắt chặt lại.

### Bước 4: Chạy ứng dụng

```bash
flutter run -d chrome
```

> Khi chạy lần đầu, app sẽ tự động **seed 60 câu hỏi mẫu** + cài đặt mặc định vào Firestore.

---

## 🗄️ Cấu Trúc Database (Firestore)

```
Firestore Database
│
├── 📁 app_settings/
│   ├── 📄 admin
│   │   └── pin: "123456"              # Mã PIN đăng nhập Admin
│   └── 📄 audio
│       ├── bgmEnabled: true           # Bật/tắt nhạc nền
│       ├── sfxEnabled: true           # Bật/tắt hiệu ứng âm thanh
│       ├── bgmVolume: 0.5            # Âm lượng nhạc nền (0.0 - 1.0)
│       └── sfxVolume: 1.0            # Âm lượng SFX (0.0 - 1.0)
│
├── 📁 custom_questions/              # 60 câu hỏi (20 câu × 3 level)
│   └── 📄 {auto-id}
│       ├── questionText: "3 + 5 = ?" # Nội dung câu hỏi
│       ├── correctAnswer: 8          # Đáp án đúng
│       ├── options: [6, 7, 8, 9]     # 4 lựa chọn
│       ├── level: 1                   # Cấp độ (1, 2, 3)
│       ├── isActive: true             # Trạng thái bật/tắt
│       └── createdAt: Timestamp       # Thời gian tạo
│
└── 📁 game_sessions/                 # Lịch sử chơi game
    └── 📄 {auto-id}
        ├── userId: "user_abc123"      # ID người chơi
        ├── level: 1                   # Cấp độ đã chơi
        ├── score: 85                  # Điểm đạt được
        └── createdAt: Timestamp       # Thời gian chơi
```

---

## 📖 Giải Thích Chi Tiết Code

### 1. `lib/main.dart` — Entry Point & Màn Hình Chính

**Chức năng:** Khởi tạo app, cấu hình Firebase, hiển thị màn hình chính.

- **`main()`**: Khởi tạo Firebase → Seed dữ liệu ban đầu → Chạy app với 3 Provider (Game, User, Admin).
- **`MathQuizApp`**: Cấu hình Material theme với màu `deepOrange`, font `Nunito`.
- **`MainScreen`**: Hiển thị logo (có shimmer animation), 3 nút chọn Level, nút Profile (góc phải trên), nút Admin (góc trái dưới).
- **`_startGame()`**: Chuyển sang `GameScreen` ngay lập tức, tải câu hỏi Firestore song song (không blocking UI).

### 2. `lib/models/` — Data Models

#### `question.dart`
- Model cơ bản cho 1 câu hỏi: `numA`, `numB`, `operatorSymbol`, `correctAnswer`, `options` (4 đáp án).
- Getter `questionText`: Nếu có `customQuestionText` → dùng nó, nếu không → tự tạo từ `numA operator numB = ?`.

#### `custom_question.dart`
- Model cho câu hỏi lưu trên Firestore, có thêm: `id` (document ID), `level`, `isActive`, `createdAt`.
- **`fromFirestore()`**: Chuyển Firestore document → Dart object.
- **`toFirestore()`**: Chuyển Dart object → Map để lưu lên Firestore.

#### `user_profile.dart`
- Lưu `userId`, `name`, `avatarIndex`.
- 16 emoji avatar: 🦁🐼🐱🐶🐰🦊🐸🐵🐧🦄🐲🐻🐯🐮🐷🐤.

### 3. `lib/providers/` — State Management

#### `game_provider.dart` — Logic Game
- **`startGame(level)`**: Reset điểm → tải câu hỏi custom từ Firestore → xáo trộn → bắt đầu.
- **`_generateNextQuestion()`**: Ưu tiên câu hỏi Firestore, hết thì auto-generate bằng `MathGenerator`.
- **`checkAnswer()`**: Kiểm tra đáp án, tính điểm (base 10 + bonus theo thời gian còn lại).
- Khi hết 10 câu → `isGameOver = true` → lưu session lên Firestore.

#### `user_provider.dart` — Hồ Sơ Người Dùng
- **`loadProfile()`**: Đọc từ `SharedPreferences`. Lần đầu tạo `userId` ngẫu nhiên dạng `user_xxxxxxxx`.
- **`updateProfile()`**: Lưu tên và avatar vào `SharedPreferences`.

#### `admin_provider.dart` — Admin Panel
- Quản lý state Admin: danh sách câu hỏi, CRUD operations.
- Gọi `DatabaseService` cho mọi thao tác Firestore.
- Quản lý cài đặt âm thanh thông qua `AudioService`.

### 4. `lib/screens/` — Giao Diện

#### `game_screen.dart` — Màn Hình Chơi
- **Timer Bar**: Đếm ngược 10 giây với `AnimationController`, đổi màu xanh → vàng → đỏ.
- **4 Nút Đáp Án**: Hiệu ứng shake khi sai, scale khi đúng.
- **Tích hợp Audio**: Phát nhạc nền khi vào, SFX đúng/sai ngẫu nhiên.

#### `result_screen.dart` — Kết Quả
- Hiển thị điểm với animation + tiếng vỗ tay.
- 2 nút: Chơi lại / Về trang chủ.

#### `profile_screen.dart` — Hồ Sơ
- Grid 16 avatar emoji để chọn.
- Hiển thị thống kê: tổng ván chơi, điểm cao nhất theo level.
- Dữ liệu lấy từ Firestore `game_sessions`.

#### `admin/` — Admin Panel
- **`admin_login_screen.dart`**: 6 ô nhập PIN, xác thực qua Firestore (fallback PIN local nếu offline).
- **`admin_dashboard_screen.dart`**: Dashboard tối màu, danh sách câu hỏi theo level, toggle bật/tắt, xóa.
- **`question_form_screen.dart`**: Form thêm/sửa câu hỏi với validation đầy đủ.

### 5. `lib/services/` — Business Logic

#### `database_service.dart` — Firebase Firestore
- **Singleton pattern**: 1 instance duy nhất trong toàn app.
- **Game Sessions**: `saveGameSession()`, `getUserStats()` — lưu/đọc lịch sử chơi.
- **Custom Questions**: CRUD (`add`, `update`, `delete`, `getCustomQuestions`, `getActiveQuestions`).
- **Admin Auth**: `verifyAdminPin()` (có fallback local), `changeAdminPin()`.
- **Audio Settings**: `getAudioSettings()`, `updateAudioSettings()`.
- **`seedInitialData()`**: Khởi tạo 60 câu hỏi + cài đặt mặc định nếu database trống.

#### `audio_service.dart` — Âm Thanh
- **Singleton pattern**: Quản lý 2 AudioPlayer (BGM + SFX).
- BGM loop tự động, SFX random (3 bản correct, 4 bản wrong).
- Cài đặt đồng bộ từ Firestore thông qua Admin Panel.

### 6. `lib/utils/math_generator.dart` — Sinh Câu Hỏi Tự Động

- **Level 1**: Cộng/trừ trong phạm vi 10, đảm bảo kết quả dương.
- **Level 2**: Cộng/trừ trong phạm vi 100.
- **Level 3**: Nhân bảng cửu chương 2-10, chia luôn tròn.
- **Đáp án giả**: Sinh 3 đáp án sai gần đáp án đúng (±5) để tăng độ khó.

---

## 🏃 Chạy Ứng Dụng

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# Xem danh sách devices
flutter devices
```

### Tài khoản Admin mặc định
- **PIN**: `123456`
- Truy cập: Nút **"Admin"** ở góc dưới trái màn hình chính

---

## 📦 Dependencies

| Package | Phiên Bản | Mục Đích |
|---|---|---|
| `provider` | ^6.1.5 | State management |
| `google_fonts` | ^8.0.2 | Font chữ Nunito, Fredoka |
| `flutter_animate` | ^4.5.2 | Animation mượt mà |
| `audioplayers` | ^6.6.0 | Phát nhạc nền + hiệu ứng |
| `shared_preferences` | ^2.5.5 | Lưu profile local |
| `firebase_core` | ^4.6.0 | Firebase SDK core |
| `cloud_firestore` | ^6.2.0 | Firestore database |
| `lottie` | ^3.3.2 | Lottie animations |

---

## 👥 Nhóm Phát Triển

- **Dự án**: Lập Trình Đa Nền Tảng — Nhóm
- **Framework**: Flutter (Dart)
- **Backend**: Firebase Cloud Firestore

---

## 📄 License

Dự án này được phát triển cho mục đích học tập.