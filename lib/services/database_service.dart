import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_question.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // =============================================
  // GAME SESSIONS
  // =============================================

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

  /// Lấy thống kê của người chơi từ Firestore
  /// Trả về Map chứa: totalGames, highScores (theo level)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('game_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      int totalGames = querySnapshot.docs.length;
      Map<int, int> highScores = {}; // level -> highScore

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final level = data['level'] as int;
        final score = data['score'] as int;

        if (!highScores.containsKey(level) || score > highScores[level]!) {
          highScores[level] = score;
        }
      }

      return {
        'totalGames': totalGames,
        'highScores': highScores,
      };
    } catch (e) {
      debugPrint('Lỗi khi lấy thống kê người chơi: $e');
      return {
        'totalGames': 0,
        'highScores': <int, int>{},
      };
    }
  }

  // =============================================
  // CUSTOM QUESTIONS (CRUD)
  // =============================================

  /// Thêm câu hỏi tùy chỉnh
  Future<String?> addCustomQuestion(CustomQuestion question) async {
    try {
      final docRef = await _db.collection('custom_questions').add(question.toFirestore());
      debugPrint('Đã thêm câu hỏi: ${question.questionText}');
      return docRef.id;
    } catch (e) {
      debugPrint('Lỗi thêm câu hỏi: $e');
      return null;
    }
  }

  /// Cập nhật câu hỏi
  Future<bool> updateCustomQuestion(String id, CustomQuestion question) async {
    try {
      await _db.collection('custom_questions').doc(id).update(question.toFirestore());
      debugPrint('Đã cập nhật câu hỏi: $id');
      return true;
    } catch (e) {
      debugPrint('Lỗi cập nhật câu hỏi: $e');
      return false;
    }
  }

  /// Xóa câu hỏi
  Future<bool> deleteCustomQuestion(String id) async {
    try {
      await _db.collection('custom_questions').doc(id).delete();
      debugPrint('Đã xóa câu hỏi: $id');
      return true;
    } catch (e) {
      debugPrint('Lỗi xóa câu hỏi: $e');
      return false;
    }
  }

  /// Lấy danh sách câu hỏi (lọc theo level nếu có)
  Future<List<CustomQuestion>> getCustomQuestions({int? level}) async {
    try {
      Query query = _db.collection('custom_questions');
      if (level != null) {
        query = query.where('level', isEqualTo: level);
      }
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CustomQuestion.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách câu hỏi: $e');
      return [];
    }
  }

  /// Lấy câu hỏi tùy chỉnh đang active cho level nhất định
  Future<List<CustomQuestion>> getActiveQuestions(int level) async {
    try {
      final snapshot = await _db
          .collection('custom_questions')
          .where('level', isEqualTo: level)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CustomQuestion.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Lỗi lấy câu hỏi active: $e');
      return [];
    }
  }

  // =============================================
  // ADMIN AUTHENTICATION
  // =============================================

  /// Kiểm tra mã PIN admin
  /// PIN được lưu trong Firestore: app_settings/admin → { pin: "123456" }
  /// Fallback: nếu Firestore lỗi thì dùng PIN mặc định local
  static const String _defaultPin = '123456';

  Future<bool> verifyAdminPin(String pin) async {
    try {
      final doc = await _db.collection('app_settings').doc('admin').get();
      if (!doc.exists) {
        // Nếu chưa có, tạo PIN mặc định
        await _db.collection('app_settings').doc('admin').set({
          'pin': _defaultPin,
        });
        return pin == _defaultPin;
      }
      final data = doc.data()!;
      return data['pin'] == pin;
    } catch (e) {
      debugPrint('Lỗi xác thực admin PIN (dùng fallback local): $e');
      // Fallback: dùng PIN mặc định nếu Firestore không truy cập được
      return pin == _defaultPin;
    }
  }

  /// Đổi mã PIN admin
  Future<bool> changeAdminPin(String newPin) async {
    try {
      await _db.collection('app_settings').doc('admin').update({'pin': newPin});
      return true;
    } catch (e) {
      debugPrint('Lỗi đổi PIN: $e');
      return false;
    }
  }

  // =============================================
  // AUDIO SETTINGS
  // =============================================

  /// Lấy cài đặt âm thanh
  Future<Map<String, dynamic>> getAudioSettings() async {
    try {
      final doc = await _db.collection('app_settings').doc('audio').get();
      if (!doc.exists) {
        // Tạo cài đặt mặc định
        final defaults = {
          'bgmEnabled': true,
          'sfxEnabled': true,
          'bgmVolume': 0.5,
          'sfxVolume': 1.0,
        };
        await _db.collection('app_settings').doc('audio').set(defaults);
        return defaults;
      }
      return doc.data()!;
    } catch (e) {
      debugPrint('Lỗi lấy audio settings: $e');
      return {
        'bgmEnabled': true,
        'sfxEnabled': true,
        'bgmVolume': 0.5,
        'sfxVolume': 1.0,
      };
    }
  }

  /// Cập nhật cài đặt âm thanh
  Future<bool> updateAudioSettings(Map<String, dynamic> settings) async {
    try {
      await _db.collection('app_settings').doc('audio').set(settings);
      return true;
    } catch (e) {
      debugPrint('Lỗi cập nhật audio settings: $e');
      return false;
    }
  }

  // =============================================
  // SEED DATA (Khởi tạo dữ liệu ban đầu)
  // =============================================

  /// Kiểm tra và tạo dữ liệu ban đầu cho database mới
  /// Chỉ tạo nếu chưa có dữ liệu (an toàn khi gọi nhiều lần)
  Future<void> seedInitialData() async {
    try {
      debugPrint('🌱 Đang kiểm tra và seed dữ liệu ban đầu...');

      // 1. Admin PIN settings
      final adminDoc = await _db.collection('app_settings').doc('admin').get();
      if (!adminDoc.exists) {
        await _db.collection('app_settings').doc('admin').set({
          'pin': '123456',
        });
        debugPrint('✅ Đã tạo Admin PIN mặc định (123456)');
      } else {
        debugPrint('ℹ️ Admin PIN đã tồn tại');
      }

      // 2. Audio settings
      final audioDoc = await _db.collection('app_settings').doc('audio').get();
      if (!audioDoc.exists) {
        await _db.collection('app_settings').doc('audio').set({
          'bgmEnabled': true,
          'sfxEnabled': true,
          'bgmVolume': 0.5,
          'sfxVolume': 1.0,
        });
        debugPrint('✅ Đã tạo Audio settings mặc định');
      } else {
        debugPrint('ℹ️ Audio settings đã tồn tại');
      }

      // 3. Sample custom questions (chỉ tạo nếu chưa có câu hỏi nào)
      final existingQuestions = await _db.collection('custom_questions').limit(1).get();
      if (existingQuestions.docs.isEmpty) {
        final sampleQuestions = [
          // ========================================
          // Level 1: Cộng trừ đến 10 (20 câu)
          // ========================================
          {'questionText': '1 + 2 = ?', 'correctAnswer': 3, 'options': [2, 3, 4, 5], 'level': 1},
          {'questionText': '3 + 4 = ?', 'correctAnswer': 7, 'options': [5, 6, 7, 8], 'level': 1},
          {'questionText': '2 + 5 = ?', 'correctAnswer': 7, 'options': [6, 7, 8, 9], 'level': 1},
          {'questionText': '5 + 3 = ?', 'correctAnswer': 8, 'options': [6, 7, 8, 9], 'level': 1},
          {'questionText': '4 + 6 = ?', 'correctAnswer': 10, 'options': [8, 9, 10, 11], 'level': 1},
          {'questionText': '1 + 8 = ?', 'correctAnswer': 9, 'options': [7, 8, 9, 10], 'level': 1},
          {'questionText': '3 + 5 = ?', 'correctAnswer': 8, 'options': [6, 7, 8, 9], 'level': 1},
          {'questionText': '2 + 7 = ?', 'correctAnswer': 9, 'options': [7, 8, 9, 10], 'level': 1},
          {'questionText': '6 + 4 = ?', 'correctAnswer': 10, 'options': [8, 9, 10, 11], 'level': 1},
          {'questionText': '5 + 5 = ?', 'correctAnswer': 10, 'options': [8, 9, 10, 11], 'level': 1},
          {'questionText': '9 - 3 = ?', 'correctAnswer': 6, 'options': [4, 5, 6, 7], 'level': 1},
          {'questionText': '8 - 5 = ?', 'correctAnswer': 3, 'options': [2, 3, 4, 5], 'level': 1},
          {'questionText': '10 - 4 = ?', 'correctAnswer': 6, 'options': [5, 6, 7, 8], 'level': 1},
          {'questionText': '7 - 2 = ?', 'correctAnswer': 5, 'options': [3, 4, 5, 6], 'level': 1},
          {'questionText': '6 - 1 = ?', 'correctAnswer': 5, 'options': [3, 4, 5, 6], 'level': 1},
          {'questionText': '10 - 7 = ?', 'correctAnswer': 3, 'options': [2, 3, 4, 5], 'level': 1},
          {'questionText': '9 - 6 = ?', 'correctAnswer': 3, 'options': [1, 2, 3, 4], 'level': 1},
          {'questionText': '8 - 2 = ?', 'correctAnswer': 6, 'options': [4, 5, 6, 7], 'level': 1},
          {'questionText': '7 - 4 = ?', 'correctAnswer': 3, 'options': [2, 3, 4, 5], 'level': 1},
          {'questionText': '10 - 5 = ?', 'correctAnswer': 5, 'options': [3, 4, 5, 6], 'level': 1},

          // ========================================
          // Level 2: Cộng trừ đến 100 (20 câu)
          // ========================================
          {'questionText': '12 + 15 = ?', 'correctAnswer': 27, 'options': [25, 27, 29, 30], 'level': 2},
          {'questionText': '25 + 37 = ?', 'correctAnswer': 62, 'options': [52, 62, 72, 57], 'level': 2},
          {'questionText': '48 + 29 = ?', 'correctAnswer': 77, 'options': [67, 77, 87, 79], 'level': 2},
          {'questionText': '33 + 44 = ?', 'correctAnswer': 77, 'options': [67, 72, 77, 82], 'level': 2},
          {'questionText': '56 + 38 = ?', 'correctAnswer': 94, 'options': [84, 88, 94, 96], 'level': 2},
          {'questionText': '17 + 65 = ?', 'correctAnswer': 82, 'options': [72, 78, 82, 85], 'level': 2},
          {'questionText': '41 + 39 = ?', 'correctAnswer': 80, 'options': [70, 75, 80, 85], 'level': 2},
          {'questionText': '28 + 53 = ?', 'correctAnswer': 81, 'options': [71, 76, 81, 83], 'level': 2},
          {'questionText': '64 + 19 = ?', 'correctAnswer': 83, 'options': [73, 79, 83, 85], 'level': 2},
          {'questionText': '35 + 47 = ?', 'correctAnswer': 82, 'options': [72, 78, 82, 87], 'level': 2},
          {'questionText': '80 - 35 = ?', 'correctAnswer': 45, 'options': [35, 40, 45, 55], 'level': 2},
          {'questionText': '73 - 28 = ?', 'correctAnswer': 45, 'options': [35, 40, 45, 55], 'level': 2},
          {'questionText': '95 - 47 = ?', 'correctAnswer': 48, 'options': [38, 43, 48, 52], 'level': 2},
          {'questionText': '62 - 19 = ?', 'correctAnswer': 43, 'options': [33, 38, 43, 47], 'level': 2},
          {'questionText': '51 - 24 = ?', 'correctAnswer': 27, 'options': [23, 25, 27, 31], 'level': 2},
          {'questionText': '88 - 39 = ?', 'correctAnswer': 49, 'options': [41, 45, 49, 53], 'level': 2},
          {'questionText': '76 - 48 = ?', 'correctAnswer': 28, 'options': [22, 26, 28, 32], 'level': 2},
          {'questionText': '100 - 56 = ?', 'correctAnswer': 44, 'options': [34, 40, 44, 54], 'level': 2},
          {'questionText': '67 - 29 = ?', 'correctAnswer': 38, 'options': [28, 34, 38, 42], 'level': 2},
          {'questionText': '84 - 57 = ?', 'correctAnswer': 27, 'options': [23, 25, 27, 31], 'level': 2},

          // ========================================
          // Level 3: Nhân chia (20 câu)
          // ========================================
          {'questionText': '2 × 6 = ?', 'correctAnswer': 12, 'options': [10, 12, 14, 16], 'level': 3},
          {'questionText': '3 × 7 = ?', 'correctAnswer': 21, 'options': [18, 21, 24, 27], 'level': 3},
          {'questionText': '4 × 8 = ?', 'correctAnswer': 32, 'options': [28, 30, 32, 36], 'level': 3},
          {'questionText': '5 × 9 = ?', 'correctAnswer': 45, 'options': [40, 42, 45, 50], 'level': 3},
          {'questionText': '6 × 7 = ?', 'correctAnswer': 42, 'options': [36, 42, 48, 49], 'level': 3},
          {'questionText': '7 × 8 = ?', 'correctAnswer': 56, 'options': [48, 54, 56, 63], 'level': 3},
          {'questionText': '8 × 9 = ?', 'correctAnswer': 72, 'options': [63, 64, 72, 81], 'level': 3},
          {'questionText': '9 × 6 = ?', 'correctAnswer': 54, 'options': [45, 48, 54, 56], 'level': 3},
          {'questionText': '7 × 5 = ?', 'correctAnswer': 35, 'options': [25, 30, 35, 40], 'level': 3},
          {'questionText': '8 × 6 = ?', 'correctAnswer': 48, 'options': [42, 46, 48, 54], 'level': 3},
          {'questionText': '12 ÷ 3 = ?', 'correctAnswer': 4, 'options': [3, 4, 5, 6], 'level': 3},
          {'questionText': '24 ÷ 6 = ?', 'correctAnswer': 4, 'options': [3, 4, 5, 6], 'level': 3},
          {'questionText': '35 ÷ 7 = ?', 'correctAnswer': 5, 'options': [4, 5, 6, 7], 'level': 3},
          {'questionText': '56 ÷ 8 = ?', 'correctAnswer': 7, 'options': [6, 7, 8, 9], 'level': 3},
          {'questionText': '45 ÷ 9 = ?', 'correctAnswer': 5, 'options': [4, 5, 6, 7], 'level': 3},
          {'questionText': '36 ÷ 4 = ?', 'correctAnswer': 9, 'options': [6, 7, 8, 9], 'level': 3},
          {'questionText': '72 ÷ 9 = ?', 'correctAnswer': 8, 'options': [6, 7, 8, 9], 'level': 3},
          {'questionText': '63 ÷ 7 = ?', 'correctAnswer': 9, 'options': [7, 8, 9, 10], 'level': 3},
          {'questionText': '48 ÷ 6 = ?', 'correctAnswer': 8, 'options': [6, 7, 8, 9], 'level': 3},
          {'questionText': '81 ÷ 9 = ?', 'correctAnswer': 9, 'options': [7, 8, 9, 10], 'level': 3},
        ];

        // Dùng batch write cho nhanh (tối đa 500 docs/batch)
        final batch = _db.batch();
        for (var q in sampleQuestions) {
          final docRef = _db.collection('custom_questions').doc();
          batch.set(docRef, {
            ...q,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        debugPrint('✅ Đã tạo ${sampleQuestions.length} câu hỏi mẫu (20 câu × 3 level)');
      } else {
        debugPrint('ℹ️ Custom questions đã tồn tại');
      }

      debugPrint('🎉 Seed dữ liệu hoàn tất!');
    } catch (e) {
      debugPrint('❌ Lỗi seed dữ liệu: $e');
      debugPrint('💡 Kiểm tra Firestore Security Rules đã cho phép read/write chưa');
    }
  }
}

