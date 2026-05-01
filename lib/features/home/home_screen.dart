import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../quiz/quiz_screen.dart'; // Sẽ tạo ở Phần 4

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _topicController = TextEditingController();
  String _difficulty = 'Medium';
  double _questionCount = 5;

  Future<void> _handleGenerateQuiz() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập chủ đề!')));
      return;
    }

    try {
      final quiz = await ref.read(generateQuizProvider.notifier).generateAndSaveQuiz(
        _topicController.text.trim(),
        _questionCount.toInt(),
        _difficulty,
      );

      if (quiz != null && mounted) {
        // Chuyển sang màn hình làm bài (Sẽ code ở Phần 4)
        Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo Quiz thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final generateState = ref.watch(generateQuizProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Quiz AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).logout();
            },
            tooltip: 'Đăng xuất',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chào ${user?.name ?? 'bạn'},',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            const Text('Hôm nay bạn muốn học chủ đề gì?', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            // Nhập chủ đề
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'VD: Lịch sử Việt Nam, Flutter Widget, v.v.',
                prefixIcon: Icon(Icons.psychology),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Chọn độ khó
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(labelText: 'Độ khó', prefixIcon: Icon(Icons.bar_chart)),
              items: ['Easy', 'Medium', 'Hard'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _difficulty = newValue!),
            ),
            const SizedBox(height: 24),

            // Chọn số lượng câu hỏi
            Text('Số lượng câu hỏi: ${_questionCount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _questionCount,
              min: 3,
              max: 20,
              divisions: 17,
              label: _questionCount.toInt().toString(),
              onChanged: (value) => setState(() => _questionCount = value),
            ),
            const SizedBox(height: 40),

            // Nút Tạo Quiz
            generateState.when(
              data: (_) => ElevatedButton.icon(
                onPressed: _handleGenerateQuiz,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Tạo & Bắt đầu làm bài', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              loading: () => const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI đang suy nghĩ và soạn đề... Vui lòng đợi nhé!')
                ],
              ),
              error: (err, stack) => Column(
                children: [
                  Text('Có lỗi xảy ra: $err', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleGenerateQuiz,
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}