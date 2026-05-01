import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import 'package:intl/intl.dart';

class QuizManagementScreen extends ConsumerWidget {
  const QuizManagementScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, String quizId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "$title" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              try {
                await ref.read(adminRepositoryProvider).deleteQuiz(quizId);
                ref.refresh(allQuizzesProvider); // Refresh lại danh sách
                ref.refresh(systemStatsProvider); // Refresh lại thống kê ở Dashboard
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa Quiz thành công!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(allQuizzesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Quiz')),
      body: quizzesAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) return const Center(child: Text('Hệ thống chưa có Quiz nào.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.psychology, color: Colors.white),
                  ),
                  title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Độ khó: ${quiz.difficulty} | Số câu: ${quiz.questions.length}\n'
                        'Tạo ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(quiz.createdAt)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, quiz.quizId, quiz.title),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải dữ liệu: $err')),
      ),
    );
  }
}