import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(userHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch Sử Học Tập')),
      body: historyAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('Bạn chưa làm bài quiz nào cả.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: item.percentage >= 50 ? Colors.green : Colors.red,
                    child: Text('${item.percentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text('Điểm: ${item.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Đúng: ${item.correctAnswers} | Sai: ${item.wrongAnswers}\n'
                        '${DateFormat('dd/MM/yyyy HH:mm').format(item.submittedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  isThreeLine: true,
                  onTap: () {
                    // Bạn có thể truyền item sang ResultScreen để xem lại chi tiết
                  },
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