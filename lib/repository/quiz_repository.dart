import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lưu Quiz mới vào Firestore
  Future<void> saveQuiz(QuizModel quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.quizId).set(quiz.toJson());
    } catch (e) {
      throw Exception('Lỗi khi lưu Quiz vào cơ sở dữ liệu: $e');
    }
  }

  // Lấy danh sách Quiz (dùng cho sau này)
  Future<List<QuizModel>> getQuizzes() async {
    try {
      final snapshot = await _firestore.collection('quizzes').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => QuizModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách Quiz: $e');
    }
  }
}