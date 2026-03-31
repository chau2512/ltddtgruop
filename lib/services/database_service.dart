import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> saveGameSession({
    required String userId,
    required int level,
    required int score,
  }) async {
    try {
      await _db.collection('game_sessions').add({
        'userId': userId,
        'level': level,
        'score': score,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('MOCK/REAL: Bắn dữ liệu ván chơi (Level $level, Điểm $score) lên Firebase thành công!');
    } catch (e) {
      debugPrint('Lỗi khi lưu game session: $e');
    }
  }
}
