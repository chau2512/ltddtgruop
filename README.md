# 🎮 MatchQuizApp - Trò Chơi Toán Học Thông Minh Cùng Trợ Lý AI

MatchQuizApp là một ứng dụng di động/web giáo dục dành cho trẻ em, giúp các bé rèn luyện kỹ năng giải toán (Cộng, Trừ, Nhân, Chia) thông qua các cấp độ từ cơ bản đến nâng cao. Đặc biệt, ứng dụng tích hợp **Trợ lý ảo AI (sử dụng model Llama 3.3)** giúp giáo viên/phụ huynh tự động tạo câu hỏi đa dạng và quản lý dễ dàng qua giao diện Admin.

Dự án được xây dựng trên nền tảng **Flutter** và sử dụng **Firebase Firestore** để lưu trữ dữ liệu thời gian thực (realtime).

---

## 📂 Cấu Trúc Dự Án (Project Structure)

Dự án được tổ chức theo chuẩn **Layer-First Architecture**, giúp code rõ ràng, dễ bảo trì và phân tách nhiệm vụ rõ ràng:

```text
lib/
│
├── models/             # 📦 Cấu trúc Dữ Liệu (Data Models)
│   ├── custom_question.dart  # Định dạng dữ liệu của 1 câu hỏi từ Admin (Có đáp án, mức độ khó)
│   └── question.dart         # Cấu trúc câu hỏi chung cho thuật toán game
│
├── providers/          # 🧠 Quản Lý Trạng Thái (State Management)
│   ├── admin_provider.dart   # Xử lý logic phần Admin (Đăng nhập, Chat AI, CRUD câu hỏi)
│   └── game_provider.dart    # Xử lý logic Game Loop (Tính điểm, Chuyển câu hỏi, Mạng chơi)
│
├── screens/            # 🖥️ Giao Diện Người Dùng (UI/Views)
│   ├── admin/                # Thư mục giao diện của người quản trị (Admin)
│   │   ├── admin_dashboard_screen.dart # Bảng điều khiển chính (Quản lý và AI)
│   │   ├── ai_chat_tab.dart            # Giao diện Chat với Trợ lý AI
│   │   └── question_form_screen.dart   # Giao diện Thêm/Sửa/Xóa câu hỏi
│   ├── game_screen.dart      # Màn hình chơi game chính (Hiện câu hỏi và nút bấm)
│   ├── main_screen.dart      # Màn hình bắt đầu (Menu chính)
│   ├── profile_screen.dart   # Màn hình hồ sơ người chơi (Cài đặt tên, Avatar)
│   └── result_screen.dart    # Màn hình kết quả sau khi chơi xong
│
├── services/           # ⚙️ Dịch Vụ Cốt Lõi (Core Services & APIs)
│   ├── ai_rules.dart         # Chứa "Luật" nghiêm ngặt giới hạn phạm vi trả lời của AI
│   ├── ai_service.dart       # Kết nối với API của Groq (Llama 3.3) để sinh câu hỏi
│   ├── audio_service.dart    # Xử lý âm thanh (Nhạc nền, hiệu ứng Đúng/Sai)
│   └── database_service.dart # Kết nối và truy xuất dữ liệu từ Firebase Firestore
│
└── utils/              # 🛠️ Tiện Ích Hỗ Trợ (Utilities)
    └── math_generator.dart   # Thuật toán tự động sinh câu hỏi ngẫu nhiên theo cấp độ
```

---

## 🚀 Hướng Dẫn Cài Đặt Và Chạy Dự Án

### 1. Yêu cầu hệ thống
- Tải và cài đặt **Flutter SDK** (Phiên bản mới nhất).
- Cài đặt trình soạn thảo: **VS Code** hoặc **Android Studio**.
- (Tùy chọn) Máy ảo Android / iOS, hoặc chạy trực tiếp trên Windows/Web.

### 2. Tải và cài đặt
1. **Clone dự án về máy:**
   ```bash
   git clone https://github.com/chau2512/ltddtgruop.git
   cd matchquizapp
   ```
2. **Cài đặt các gói thư viện (Dependencies):**
   ```bash
   flutter pub get
   ```

### 3. Chạy Dự Án (Rất Quan Trọng)

Ứng dụng có tích hợp AI (gọi API ra bên ngoài), do đó nếu bạn chạy dưới dạng Web thông thường, trình duyệt sẽ chặn kết nối vì lý do bảo mật **CORS**. Dưới đây là 2 cách chạy an toàn:

**✅ Cách 1: Chạy dưới dạng ứng dụng Desktop (Khuyên Dùng)**
Chạy bằng Windows App sẽ cực kỳ mượt mà, không bao giờ bị lỗi CORS và không lag.
```bash
flutter run -d windows
```

**✅ Cách 2: Chạy trên Web (Tắt bảo mật Chrome)**
Nếu bạn muốn test nhanh trên Web, bạn phải chạy lệnh sau để buộc Chrome tắt cơ chế chặn CORS:
```bash
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

---

## 🤖 Hướng dẫn dùng Trợ Lý AI
1. Mở ứng dụng, nhấn vào nút **Admin** (Hình bánh răng).
2. Nhập mã PIN mặc định: `1234`
3. Chuyển sang Tab **Trợ lý AI**.
4. Dán API Key của **Groq** vào ô nhập liệu.
5. Yêu cầu AI tạo câu hỏi. Ví dụ: *"Tạo cho tôi 1 câu hỏi toán học phép cộng trong phạm vi 10 cho Cấp 1"*. AI sẽ phân tích và tự động nạp câu hỏi vào Database.

*(Trợ lý AI đã được thiết lập kỷ luật nghiêm ngặt trong file `ai_rules.dart`, nó sẽ từ chối trả lời mọi câu hỏi không liên quan đến Toán học và Game).*