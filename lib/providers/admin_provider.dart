import 'package:flutter/material.dart';
import '../models/custom_question.dart';
import '../services/database_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isAdmin = false;
  bool _isLoading = false;
  List<CustomQuestion> _questions = [];
  String? _errorMessage;

  // Audio settings
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.5;
  double _sfxVolume = 1.0;

  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  List<CustomQuestion> get questions => _questions;
  String? get errorMessage => _errorMessage;
  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  final DatabaseService _db = DatabaseService();

  // =============================================
  // ADMIN AUTH
  // =============================================

  /// Đăng nhập admin bằng PIN
  Future<bool> login(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _db.verifyAdminPin(pin);

    _isLoading = false;
    if (success) {
      _isAdmin = true;
      await loadQuestions();
      await loadAudioSettings();
    } else {
      _errorMessage = 'Mã PIN không đúng!';
    }
    notifyListeners();
    return success;
  }

  /// Đăng xuất admin
  void logout() {
    _isAdmin = false;
    _questions = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Đổi mã PIN
  Future<bool> changePin(String newPin) async {
    final success = await _db.changeAdminPin(newPin);
    if (!success) {
      _errorMessage = 'Không thể đổi PIN!';
      notifyListeners();
    }
    return success;
  }

  // =============================================
  // CUSTOM QUESTIONS CRUD
  // =============================================

  /// Tải danh sách câu hỏi
  Future<void> loadQuestions({int? level}) async {
    _isLoading = true;
    notifyListeners();

    _questions = await _db.getCustomQuestions(level: level);

    _isLoading = false;
    notifyListeners();
  }

  /// Thêm câu hỏi mới
  Future<bool> addQuestion(CustomQuestion question) async {
    _isLoading = true;
    notifyListeners();

    final id = await _db.addCustomQuestion(question);
    final success = id != null;

    if (success) {
      await loadQuestions();
    } else {
      _errorMessage = 'Không thể thêm câu hỏi!';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Cập nhật câu hỏi
  Future<bool> updateQuestion(String id, CustomQuestion question) async {
    _isLoading = true;
    notifyListeners();

    final success = await _db.updateCustomQuestion(id, question);

    if (success) {
      await loadQuestions();
    } else {
      _errorMessage = 'Không thể cập nhật câu hỏi!';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Xóa câu hỏi
  Future<bool> deleteQuestion(String id) async {
    _isLoading = true;
    notifyListeners();

    final success = await _db.deleteCustomQuestion(id);

    if (success) {
      await loadQuestions();
    } else {
      _errorMessage = 'Không thể xóa câu hỏi!';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Toggle bật/tắt câu hỏi
  Future<void> toggleQuestion(CustomQuestion question) async {
    if (question.id == null) return;
    final updated = question.copyWith(isActive: !question.isActive);
    await updateQuestion(question.id!, updated);
  }

  // =============================================
  // AUDIO SETTINGS
  // =============================================

  /// Tải cài đặt âm thanh
  Future<void> loadAudioSettings() async {
    final settings = await _db.getAudioSettings();
    _bgmEnabled = settings['bgmEnabled'] ?? true;
    _sfxEnabled = settings['sfxEnabled'] ?? true;
    _bgmVolume = (settings['bgmVolume'] ?? 0.5).toDouble();
    _sfxVolume = (settings['sfxVolume'] ?? 1.0).toDouble();
    notifyListeners();
  }

  /// Cập nhật và lưu cài đặt âm thanh
  Future<void> updateAudioSettings({
    bool? bgmEnabled,
    bool? sfxEnabled,
    double? bgmVolume,
    double? sfxVolume,
  }) async {
    if (bgmEnabled != null) _bgmEnabled = bgmEnabled;
    if (sfxEnabled != null) _sfxEnabled = sfxEnabled;
    if (bgmVolume != null) _bgmVolume = bgmVolume;
    if (sfxVolume != null) _sfxVolume = sfxVolume;
    notifyListeners();

    await _db.updateAudioSettings({
      'bgmEnabled': _bgmEnabled,
      'sfxEnabled': _sfxEnabled,
      'bgmVolume': _bgmVolume,
      'sfxVolume': _sfxVolume,
    });
  }

  /// Xóa lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
