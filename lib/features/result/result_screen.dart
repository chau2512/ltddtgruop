import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/result_model.dart';
import '../../providers/quiz_provider.dart'; // Nơi chứa geminiServiceProvider
import '../../providers/history_provider.dart';
import '../home/home_screen.dart'; // Nơi chứa resultRepositoryProvider

class ResultScreen extends ConsumerStatefulWidget {
  final ResultModel result;
  final String topic;

  const ResultScreen({super.key, required this.result, required this.topic});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  String? _aiFeedback;
  bool _isLoadingAI = false;

  @override
  void initState() {
    super.initState();
    _aiFeedback = widget.result.aiAnalysis;
    if (_aiFeedback == null || _aiFeedback!.isEmpty) {
      _generateAIFeedback();
    }
  }

  Future<void> _generateAIFeedback() async {
    setState(() => _isLoadingAI = true);
    try {
      final gemini = ref.read(geminiServiceProvider);
      // Gọi AI phân tích (Hàm này đã viết ở Phần 1: gemini_service.dart)
      final feedback = await gemini.analyzeResult(
        widget.result.correctAnswers,
        widget.result.correctAnswers + widget.result.wrongAnswers,
        widget.topic,
        widget.result.wrongDetails,
      );

      // Lưu kết quả phân tích xuống Firestore
      await ref.read(resultRepositoryProvider).updateAIAnalysis(widget.result.resultId, feedback);

      if (mounted) setState(() => _aiFeedback = feedback);
    } catch (e) {
      if (mounted) setState(() => _aiFeedback = "Lỗi khi AI phân tích: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Học Tập'),
        automaticallyImplyLeading: false, // Không cho user back lại bài thi
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Vòng tròn điểm số
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: widget.result.percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: widget.result.percentage >= 50 ? Colors.green : Colors.red,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${widget.result.percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    Text('${widget.result.score} Điểm', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Thống kê đúng/sai
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Đúng', widget.result.correctAnswers, Colors.green),
                _buildStatCard('Sai', widget.result.wrongAnswers, Colors.red),
              ],
            ),
            const SizedBox(height: 32),

            // AI Feedback Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text('AI Phân Tích & Gợi Ý', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800)),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_isLoadingAI)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                  else
                    Text(
                      _aiFeedback ?? 'Không có dữ liệu phân tích.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              // child: const Text('Về Trang Chủ'),
              onPressed: () {
                try {
                  print('Đang chuẩn bị chuyển trang...');
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  print('Lệnh chuyển trang đã thực thi');
                } catch (e) {
                  print('LỖI KHI BẤM NÚT: $e');
                }
              },
              child: const Text('Về Trang Chủ'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}