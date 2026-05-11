# 🎮 MatchQuizApp — Trò Chơi Toán Học Thông Minh Cho Trẻ Em

> Ứng dụng giáo dục giúp trẻ em Tiểu học rèn luyện kỹ năng tính toán qua 4 cấp độ, tích hợp **Trợ lý AI thông minh** và quản lý dữ liệu qua **Firebase Firestore**.

---

## 📋 Mục Lục

1. [Tổng Quan Dự Án](#-tổng-quan-dự-án)
2. [Tính Năng Chính](#-tính-năng-chính)
3. [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
4. [Cấu Trúc Dự Án](#-cấu-trúc-dự-án-chi-tiết)
5. [Hướng Dẫn Cài Đặt](#-hướng-dẫn-cài-đặt-từng-bước)
6. [Thiết Lập Firebase](#-thiết-lập-firebase-database)
7. [Tích Hợp Trợ Lý AI](#-tích-hợp-trợ-lý-ai-groq)
8. [Hướng Dẫn Sử Dụng](#-hướng-dẫn-sử-dụng)
9. [Kiểm Thử (Testing)](#-kiểm-thử-testing)
10. [Thành Viên Nhóm](#-thành-viên-nhóm)

---

## 🌟 Tổng Quan Dự Án

**MatchQuizApp** là ứng dụng đa nền tảng (Android, iOS, Web, Windows) được xây dựng bằng **Flutter**. Ứng dụng cung cấp các bài trắc nghiệm toán học từ dễ đến khó, kèm theo hiệu ứng âm thanh sinh động và bảng xếp hạng cá nhân. Điểm nổi bật là trang **Admin Panel** cho phép giáo viên/phụ huynh quản lý ngân hàng câu hỏi và sử dụng **Trợ lý AI (Llama 3.3)** để tự động sinh câu hỏi mới vào cơ sở dữ liệu Firebase.

### 4 Cấp Độ Chơi

| Cấp | Nội dung | Ví dụ |
|-----|----------|-------|
| ⭐ Cấp 1 | Cộng, Trừ trong phạm vi 10 | `3 + 4 = ?` |
| ⭐⭐ Cấp 2 | Cộng, Trừ trong phạm vi 100 | `48 + 29 = ?` |
| ⭐⭐⭐ Cấp 3 | Nhân, Chia | `7 × 8 = ?` |
| 🌟 Cấp 4 | Phép tính hỗn hợp | `3 + 5 × 2 = ?` |

---

## ✨ Tính Năng Chính

### Dành cho Người Chơi (Trẻ em)
- 🎯 **4 cấp độ** với độ khó tăng dần
- ⏱️ **Chế độ Time Attack** — đếm ngược 10 giây, tính điểm thưởng theo thời gian còn lại
- 🔊 **Âm thanh phản hồi** — hiệu ứng vui khi trả lời đúng, hiệu ứng "kinh dị" khi sai
- 👤 **Hồ sơ cá nhân** — đặt tên, chọn avatar emoji, xem thống kê điểm cao

### Dành cho Admin (Giáo viên / Phụ huynh)
- 🔐 **Đăng nhập bằng mã PIN** (mặc định: `123456`)
- 📝 **CRUD câu hỏi** — Thêm, Sửa, Xóa câu hỏi theo từng cấp độ
- 🤖 **Trợ lý AI** — Tự động tạo câu hỏi bằng ngôn ngữ tự nhiên qua Groq API
- 🔇 **Cài đặt âm thanh** — Bật/tắt nhạc nền và hiệu ứng âm thanh

---

## 🛠️ Công Nghệ Sử Dụng

| Thư viện | Phiên bản | Chức năng |
|----------|-----------|-----------|
| `flutter` | SDK 3.11+ | Framework chính xây dựng giao diện đa nền tảng |
| `firebase_core` | ^4.6.0 | Khởi tạo kết nối Firebase |
| `cloud_firestore` | ^6.2.0 | Cơ sở dữ liệu NoSQL thời gian thực |
| `provider` | ^6.1.5 | Quản lý trạng thái (State Management) |
| `google_fonts` | ^8.0.2 | Font chữ đẹp (Nunito, Fredoka) |
| `audioplayers` | ^6.6.0 | Phát nhạc nền và hiệu ứng âm thanh |
| `shared_preferences` | ^2.5.5 | Lưu trữ cục bộ (tên, avatar người chơi) |
| `flutter_animate` | ^4.5.2 | Hiệu ứng chuyển động (animation) |
| `lottie` | ^3.3.2 | Hiệu ứng hoạt hình Lottie |
| `http` | ^1.6.0 | Gọi API tới Groq (Trợ lý AI) |
| `flutter_markdown` | ^0.7.7 | Hiển thị câu trả lời AI dạng Markdown |

---

## 📂 Cấu Trúc Dự Án Chi Tiết

Dự án tuân theo kiến trúc **Layer-First** chuẩn quốc tế của Flutter:

```
matchquizapp/
├── lib/                          # 📁 Thư mục mã nguồn chính
│   ├── main.dart                 #    Điểm khởi chạy ứng dụng, khởi tạo Firebase & Provider
│   ├── firebase_options.dart     #    Cấu hình Firebase (tự sinh bởi FlutterFire CLI)
│   │
│   ├── models/                   # 📦 LỚP DỮ LIỆU — Định nghĩa cấu trúc đối tượng
│   │   ├── custom_question.dart  #    Câu hỏi tùy chỉnh từ Admin (questionText, correctAnswer, options, level)
│   │   └── question.dart         #    Câu hỏi tự sinh từ thuật toán (numA, numB, operatorSymbol)
│   │
│   ├── providers/                # 🧠 LỚP LOGIC — Quản lý trạng thái & nghiệp vụ
│   │   ├── admin_provider.dart   #    Logic Admin: xác thực PIN, CRUD câu hỏi, giao tiếp AI
│   │   ├── game_provider.dart    #    Logic Game: tải câu hỏi, tính điểm, đếm ngược, kết thúc ván
│   │   └── user_provider.dart    #    Logic Profile: lưu/tải tên & avatar từ SharedPreferences
│   │
│   ├── screens/                  # 🖥️ LỚP GIAO DIỆN — Các màn hình hiển thị
│   │   ├── main_screen.dart      #    Trang chủ: chọn cấp độ, nút Admin & Profile
│   │   ├── game_screen.dart      #    Màn hình chơi: hiển thị câu hỏi, 4 nút đáp án, thanh thời gian
│   │   ├── result_screen.dart    #    Màn hình kết quả: điểm số, số câu đúng/sai
│   │   ├── profile_screen.dart   #    Hồ sơ người chơi: đổi tên, chọn emoji, xem thống kê
│   │   └── admin/                #    Thư mục con: giao diện quản trị
│   │       ├── admin_login_screen.dart   # Màn hình nhập PIN
│   │       ├── admin_dashboard_screen.dart # Bảng điều khiển chính (3 tab)
│   │       ├── question_form_screen.dart   # Form thêm/sửa câu hỏi
│   │       └── ai_chat_tab.dart            # Giao diện chat với Trợ lý AI
│   │
│   ├── services/                 # ⚙️ LỚP DỊCH VỤ — Kết nối hệ thống bên ngoài
│   │   ├── database_service.dart #    Kết nối Firebase Firestore (CRUD, Auth, Seed Data)
│   │   ├── audio_service.dart    #    Quản lý phát nhạc nền & hiệu ứng âm thanh
│   │   ├── ai_service.dart       #    Gọi API Groq, xử lý Function Calling, parse kết quả
│   │   └── ai_rules.dart         #    System Prompt — giới hạn phạm vi trả lời của AI
│   │
│   └── utils/                    # 🛠️ LỚP TIỆN ÍCH — Các hàm hỗ trợ
│       └── math_generator.dart   #    Thuật toán sinh câu hỏi ngẫu nhiên theo cấp độ
│
├── assets/audio/                 # 🔊 Tài nguyên âm thanh
│   ├── bgm.mp3                   #    Nhạc nền
│   ├── correct.mp3, correct1-3   #    Hiệu ứng trả lời đúng (phát ngẫu nhiên)
│   ├── wrong.mp3, wrong1-4       #    Hiệu ứng trả lời sai (phát ngẫu nhiên)
│   └── applause.mp3              #    Hiệu ứng hoàn thành ván chơi
│
├── test/                         # 🧪 Kiểm thử tự động
│   ├── widget_test.dart          #    Test giao diện widget cơ bản
│   ├── game_provider_test.dart   #    Test logic game (tính điểm, chuyển câu)
│   ├── math_generator_test.dart  #    Test thuật toán sinh câu hỏi 4 cấp độ
│   ├── admin_login_test.dart     #    Test xác thực PIN Admin
│   ├── result_screen_test.dart   #    Test màn hình kết quả
│   └── app_integration_mock_test.dart # Test tích hợp toàn ứng dụng
│
├── pubspec.yaml                  # 📋 Khai báo thư viện & tài nguyên
└── firebase.json                 # 🔥 Cấu hình Firebase CLI
```

---

## 📥 Hướng Dẫn Cài Đặt Từng Bước

### Bước 1: Cài đặt môi trường

1. Tải và cài đặt **Flutter SDK**: https://docs.flutter.dev/get-started/install
2. Cài đặt **VS Code** + Extension "Flutter" và "Dart"
3. Kiểm tra Flutter đã sẵn sàng:
   ```bash
   flutter doctor
   ```

### Bước 2: Clone dự án

```bash
git clone https://github.com/chau2512/ltddtgruop.git
cd ltddtgruop
```

### Bước 3: Cài đặt thư viện

```bash
flutter pub get
```

### Bước 4: Chạy ứng dụng

**Cách 1 — Chạy trên Windows Desktop (Khuyên dùng):**
```bash
flutter run -d windows
```
> Lần đầu sẽ mất 5-10 phút để build C++ native. Các lần sau rất nhanh.

**Cách 2 — Chạy trên Web (cần tắt CORS):**
```bash
flutter run -d chrome --web-browser-flag="--disable-web-security"
```
> ⚠️ **Bắt buộc phải thêm `--disable-web-security`** nếu muốn dùng tính năng Trợ lý AI trên Web, vì trình duyệt mặc định chặn các request tới API bên ngoài (Groq).

**Cách 3 — Chạy trên Android:**
```bash
flutter run -d android
```

---

## 🔥 Thiết Lập Firebase (Database)

Dự án sử dụng **Cloud Firestore** để lưu trữ câu hỏi, phiên chơi và cài đặt. Dưới đây là cách thiết lập từ đầu nếu bạn muốn dùng Firebase project của riêng mình:

### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Nhấn **"Add project"** → Đặt tên (ví dụ: `matchquizapp`) → Tạo
3. Vào mục **Build > Firestore Database** → Nhấn **"Create database"**
4. Chọn **"Start in test mode"** (cho phép đọc/ghi tự do trong 30 ngày) → Nhấn **Done**

### Bước 2: Đăng ký App vào Firebase

1. Trên Firebase Console, nhấn biểu tượng **Web `</>`** để thêm Web App
2. Đặt tên app (ví dụ: `matchquizapp-web`) → Nhấn **Register app**
3. Firebase sẽ hiện ra đoạn config chứa `apiKey`, `projectId`, `storageBucket`...

### Bước 3: Cập nhật file cấu hình

Mở file `lib/firebase_options.dart` và thay thế các giá trị sau bằng thông tin từ Firebase Console:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',                    // ← Thay bằng apiKey của bạn
  appId: 'YOUR_APP_ID',                      // ← Thay bằng appId
  messagingSenderId: 'YOUR_SENDER_ID',       // ← Thay bằng messagingSenderId
  projectId: 'YOUR_PROJECT_ID',             // ← Thay bằng projectId
  storageBucket: 'YOUR_STORAGE_BUCKET',      // ← Thay bằng storageBucket
);
```

### Bước 4: Cấu hình Firestore Security Rules

Vào **Firestore > Rules**, dán nội dung sau (cho phép đọc/ghi tự do trong lúc phát triển):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

> ⚠️ **Lưu ý:** Rules trên chỉ dùng cho môi trường phát triển. Khi triển khai chính thức (production), hãy giới hạn quyền truy cập.

### Bước 5: Khởi tạo dữ liệu ban đầu (Seed Data)

Khi chạy ứng dụng lần đầu tiên, hệ thống sẽ **tự động** tạo dữ liệu mẫu bao gồm:
- **Mã PIN Admin** mặc định: `123456`
- **Cài đặt âm thanh** mặc định (bật nhạc nền, bật hiệu ứng)
- **60 câu hỏi mẫu** (20 câu × 3 cấp độ đầu)

Quá trình này được thực hiện tự động bởi hàm `seedInitialData()` trong `database_service.dart`.

### Cấu trúc Database trên Firestore

```
Firestore
├── app_settings/               # Cài đặt ứng dụng
│   ├── admin                   #   { pin: "123456" }
│   └── audio                   #   { bgmEnabled: true, sfxEnabled: true, bgmVolume: 0.5, sfxVolume: 1.0 }
│
├── custom_questions/           # Ngân hàng câu hỏi
│   └── {auto_id}               #   { questionText, correctAnswer, options[], level, isActive, createdAt }
│
└── game_sessions/              # Lịch sử phiên chơi
    └── {auto_id}               #   { userId, level, score, createdAt }
```

---

## 🤖 Tích Hợp Trợ Lý AI (Groq)

Trợ lý AI sử dụng model **Llama 3.3 70B** thông qua API của **Groq** (tương thích chuẩn OpenAI). AI có khả năng **Function Calling** — tức là khi bạn yêu cầu tạo câu hỏi, AI sẽ tự động gọi hàm `add_question()` để nạp câu hỏi thẳng vào Firebase.

### Cách lấy API Key (Miễn phí)

1. Truy cập [Groq Console](https://console.groq.com/)
2. Đăng ký tài khoản (miễn phí)
3. Vào mục **API Keys** → Nhấn **"Create API Key"**
4. Copy key (bắt đầu bằng `gsk_...`)

### Cách sử dụng trong ứng dụng

1. Mở app → Nhấn nút **Admin** (góc dưới trái) → Nhập PIN `123456`
2. Chuyển sang tab **🤖 Trợ lý AI**
3. Dán API Key vào ô nhập liệu → Nhấn **"Bắt đầu"**
4. Gõ yêu cầu bằng tiếng Việt tự nhiên:
   - *"Tạo 5 câu hỏi cộng trừ trong phạm vi 10 cho Cấp 1"*
   - *"Tạo 3 câu hỏi nhân chia cho Cấp 3"*
   - *"Tạo 1 câu hỏi hỗn hợp khó cho Cấp 4"*

### Kiến trúc AI trong code

| File | Vai trò |
|------|---------|
| `ai_service.dart` | Gọi API Groq, gửi/nhận tin nhắn, xử lý Function Calling |
| `ai_rules.dart` | Chứa System Prompt — giới hạn AI chỉ trả lời về toán học |
| `ai_chat_tab.dart` | Giao diện chat (nhập key, hiển thị hội thoại, nút gửi) |
| `admin_provider.dart` | Điều phối trạng thái AI: loading, lịch sử chat, xử lý lỗi |

### Luồng hoạt động của AI (Function Calling)

```
Người dùng gõ: "Tạo 1 câu hỏi cấp 2"
        │
        ▼
   AIService gửi tin nhắn + Tool Schema tới Groq API
        │
        ▼
   Groq AI phân tích → trả về tool_call: add_question({
     questionText: "45 + 37 = ?",
     correctAnswer: "82",
     options: ["72", "78", "82", "87"],
     level: "2"
   })
        │
        ▼
   AIService parse kết quả → tạo CustomQuestion → gọi AdminProvider.addQuestion()
        │
        ▼
   AdminProvider ghi vào Firebase Firestore → phản hồi kết quả cho AI
        │
        ▼
   AI sinh câu trả lời tự nhiên: "Đã thêm câu hỏi '45 + 37 = ?' vào Cấp 2!"
```

### Giới hạn phạm vi AI

AI được cấu hình nghiêm ngặt trong file `ai_rules.dart`:
- ✅ **Được phép:** Tạo câu hỏi toán, quản lý database game
- ❌ **Bị từ chối:** Mọi câu hỏi không liên quan (lịch sử, địa lý, viết code khác...)

---

## 📖 Hướng Dẫn Sử Dụng

### Người chơi (Trẻ em)
1. Mở app → Chọn 1 trong 4 cấp độ
2. Trả lời câu hỏi bằng cách nhấn 1 trong 4 đáp án
3. Trả lời nhanh để được điểm thưởng thời gian
4. Xem kết quả sau khi hoàn thành 10 câu

### Admin (Giáo viên)
1. Nhấn nút **Admin** (góc dưới trái màn hình chính)
2. Nhập mã PIN: `123456`
3. **Tab "Câu hỏi":** Xem, thêm, sửa, xóa câu hỏi theo cấp độ
4. **Tab "Cài đặt":** Đổi PIN, bật/tắt âm thanh
5. **Tab "Trợ lý AI":** Dùng AI tự động sinh câu hỏi

---

## 🧪 Kiểm Thử (Testing)

Chạy toàn bộ bộ test:
```bash
flutter test
```

| File test | Nội dung kiểm thử |
|-----------|-------------------|
| `widget_test.dart` | Kiểm tra giao diện chính hiển thị đúng |
| `game_provider_test.dart` | Kiểm tra logic tính điểm, chuyển câu hỏi |
| `math_generator_test.dart` | Kiểm tra thuật toán sinh câu hỏi 4 cấp độ |
| `admin_login_test.dart` | Kiểm tra đăng nhập Admin bằng PIN |
| `result_screen_test.dart` | Kiểm tra màn hình kết quả |
| `app_integration_mock_test.dart` | Kiểm tra tích hợp toàn bộ luồng ứng dụng |

---

## 👥 Thành Viên Nhóm

| STT | Họ và Tên | MSSV | Vai trò |
|-----|-----------|------|---------|
| 1 | Trần Hữu Hoàng Châu | 23IT027 | Trưởng nhóm |
| 2 | Khổng Thị Lệ Ging | 23IT.B027 | Thành viên |
| 3 | Nguyễn Thị Hồng | 23IT.B039 | Thành viên |

---

## 📄 License

Dự án này được phát triển phục vụ mục đích học tập trong môn **Lập Trình Đa Nền Tảng**.