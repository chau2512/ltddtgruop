import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/result_model.dart';
import '../../data/repositories/result_repository.dart';
import '../../providers/auth_provider.dart';
import '../result/result_screen.dart'; // Sẽ tạo ở Phần 5

class QuizScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, String> _selectedAnswers = {};

  // Timer variables
  late Timer _timer;
  int _timeLeftInSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Cấp thời gian: mỗi câu 1 phút (60 giây)
    _timeLeftInSeconds = widget.quiz.questions.length * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftInSeconds > 0) {
        setState(() => _timeLeftInSeconds--);
      } else {
        _timer.cancel();
        _submitQuiz(); // Hết giờ tự động nộp bài
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswers[_currentIndex] = answer;
    });
  }

  Future<void> _submitQuiz() async {
    _timer.cancel();

    int correct = 0;
    List<Map<String, dynamic>> wrongDetails = [];

    // Chấm điểm
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final userAnswer = _selectedAnswers[i];

      if (userAnswer == question.correctAnswer) {
        correct++;
      } else {
        wrongDetails.add({
          'question': question.question,
          'userAnswer': userAnswer ?? 'Bỏ trống',
          'correctAnswer': question.correctAnswer,
          'explanation': question.explanation,
        });
      }
    }

    final total = widget.quiz.questions.length;
    final percentage = (correct / total) * 100;
    final user = ref.read(currentUserProvider).value;

    final result = ResultModel(
      resultId: const Uuid().v4(),
      userId: user?.uid ?? 'unknown',
      quizId: widget.quiz.quizId,
      score: correct * 10, // Giả sử mỗi câu 10 điểm
      correctAnswers: correct,
      wrongAnswers: total - correct,
      percentage: percentage,
      submittedAt: DateTime.now(),
      wrongDetails: wrongDetails,
    );

    // Lưu kết quả vào Firebase
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final repo = ResultRepository();
      await repo.saveResult(result);

      if (mounted) {
        Navigator.pop(context); // Đóng loading
        Navigator.pop(context); // Đóng QuizScreen
        // Chuyển sang trang kết quả (Sẽ code ở Phần 5)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result, topic: widget.quiz.topic)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nộp bài thành công! Bạn đúng $correct/$total câu.')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi nộp bài: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentIndex];
    final totalQuestions = widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Câu ${_currentIndex + 1}/$totalQuestions'),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _formatTime(_timeLeftInSeconds),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / totalQuestions,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Nội dung câu hỏi
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Danh sách đáp án
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = _selectedAnswers[_currentIndex] == option;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? Colors.deepPurple : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(option, style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Nút Điều hướng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentIndex--),
                    child: const Text('Quay lại'),
                  )
                else
                  const SizedBox.shrink(),

                if (_currentIndex < totalQuestions - 1)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex++),
                    child: const Text('Tiếp theo'),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _submitQuiz,
                    child: const Text('Nộp Bài', style: TextStyle(color: Colors.white)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}