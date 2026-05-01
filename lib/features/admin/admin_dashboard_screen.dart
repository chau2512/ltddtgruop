import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import 'user_management_screen.dart';
import 'quiz_management_screen.dart'; // Sẽ tạo ở Phần 7

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(systemStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).logout(),
            tooltip: 'Đăng xuất',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(systemStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tổng quan hệ thống', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Grid Thống kê
              statsAsync.when(
                data: (stats) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Users', stats['totalUsers'].toString(), Icons.people, Colors.blue),
                    _buildStatCard('Quizzes AI', stats['totalQuizzes'].toString(), Icons.psychology, Colors.orange),
                    _buildStatCard('Lượt làm bài', stats['totalResults'].toString(), Icons.assignment_turned_in, Colors.green),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Lỗi: $err', style: const TextStyle(color: Colors.red)),
              ),

              const SizedBox(height: 32),
              const Text('Chức năng Quản trị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Menu chức năng
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.manage_accounts)),
                title: const Text('Quản lý Người dùng'),
                subtitle: const Text('Xem, khóa/mở khóa, phân quyền'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.quiz)),
                title: const Text('Quản lý Quiz'),
                subtitle: const Text('Kiểm duyệt bộ đề AI'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizManagementScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}