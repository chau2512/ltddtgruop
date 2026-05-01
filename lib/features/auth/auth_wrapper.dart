import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../home/home_screen.dart'; // Màn hình User (Tạo ở bước trước)
import '../admin/admin_dashboard_screen.dart'; // Màn hình Admin (Sẽ tạo sau)

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Chưa đăng nhập -> Trả về màn hình Login
          return const LoginScreen();
        }

        // Đã đăng nhập trên Firebase, tiếp tục lấy Data từ Firestore để check Role
        final userData = ref.watch(currentUserProvider);

        return userData.when(
          data: (userModel) {
            if (userModel == null) return const Scaffold(body: Center(child: Text('Lỗi tải dữ liệu người dùng')));

            if (userModel.isBlocked) {
              return const Scaffold(body: Center(child: Text('Tài khoản của bạn đã bị khóa.')));
            }

            // Phân quyền điều hướng
            if (userModel.role == 'admin') {
              return const AdminDashboardScreen(); // Chuyển đến Admin
            } else {
              return const HomeScreen(); // Chuyển đến User App
            }
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi xác thực: $err'))),
    );
  }
}