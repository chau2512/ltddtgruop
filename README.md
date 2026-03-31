# MathQuiz Gamification 🎮📐

Một ứng dụng trò chơi trắc nghiệm Toán học tươi sáng, vui nhộn và trực quan được xây dựng bằng **Flutter**. Ứng dụng cung cấp các mức độ khó khác nhau, lưu điểm số đồng bộ trên mây (Firebase Cloud Firestore) và tích hợp các hiệu ứng Gamification sinh động dành cho lứa tuổi học sinh!

## ✨ Tính Năng Nổi Bật
- **Hệ thống cấp độ**: 3 Level với độ khó toán học tăng dần (Cộng trừ cơ bản đến Nhân chia phức tạp).
- **Gamification UI**: Hoạt hình (Animations) tinh tế, nảy (bounce), hiệu ứng điểm số bay (+10).
- **Phản hồi Trực quan**: Nút trả lời Đỏ/Xanh cùng Mascot (mặt cười biểu cảm) và độ trễ 1 giây để người chơi nhận thức đúng/sai một cách thỏa mãn.
- **Firebase Integration**: Tích hợp Cloud Firestore để lưu lại toàn bộ lịch sử các phiên chơi của bạn lên mây.
- **Kiểm thử tự động (Testing)**: Bộ Unit test và Widget Test toàn diện đảm bảo không có lỗi luồng người chơi.

---

## 🚀 Hướng Dẫn Cài Đặt (Dành cho Lập trình viên mới)

Nếu bạn vừa tải (download) mã nguồn này về máy hoặc `clone` từ GitHub, hãy làm theo các bước dưới đây để chạy thử nghiệm.

### 1. Yêu Cầu Hệ Thống (Prerequisites)
Để code và chạy được dự án Flutter này, máy bạn bắt buộc cần cài sẵn:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Khuyến nghị bản mới nhất >= 3.x)
- [Dart SDK](https://dart.dev/get-dart)
- IDE Tùy chọn: VS Code, Android Studio hoặc IntelliJ IDEA.

### 2. Tải Mã Nguồn Về Máy (Clone)
Mở Terminal / Command Prompt và chạy lệnh (Nếu bạn dùng Git):
```bash
git clone https://github.com/chau2512/ltddt.git
cd ltddt
```
*(Nếu tải tệp ZIP, giải nén và mở thư mục giải nén trong IDE).*

### 3. Cài Đặt Thư Viện (Install Dependencies)
Dự án sử dụng các gói mở rộng như `flutter_animate`, `google_fonts`, `firebase_core`. Cài đặt chúng tự động bằng lệnh:
```bash
flutter pub get
```

### 4. Thiết Lập Firebase (Đối với Database riêng)
Dự án đã đính kèm sẵn file cấu hình cục bộ của app. Tuy nhiên nếu bạn fork (chẽ nhánh) dự án ra thành ứng dụng cá nhân và cần chạy **Database của riêng mình**, hãy làm theo hướng dẫn:
1. Xóa (hoặc thay thế) file `android/app/google-services.json` bằng file của bạn (lấy từ Firebase Console).
2. Xóa/thay thế file `lib/firebase_options.dart`.
3. Cài đặt [Firebase CLI](https://firebase.google.com/docs/cli) và chạy lệnh:
   ```bash
   flutterfire configure
   ```
4. Đảm bảo Firestore Database đã được bật "Test Mode" cho phép read/write trong bộ Quy tắc bảo mật (Security Rules).

### 5. Khởi Chạy Ứng Dụng (Run The App)
Bạn có thể chạy dự án trên máy giả lập Android (Emulator), iPhone Simulator, trình duyệt Web tĩnh hoặc nối dây cáp vào điện thoại thật:
```bash
flutter run
```

### 6. Chạy Kiểm Thử Tự Động (Run Tests)
Dự án bao gồm hàng loạt bài kiểm tra logic điểm số (Provider, MathGenerator) và giao diện. Bạn có thể kiểm tra xem mọi thứ ổn định hay không:
```bash
flutter test
```

---

*Mong dự án này sẽ mang lại trải nghiệm học & chơi thú vị dành cho bạn!*