import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile(userId: '', name: 'Người chơi mới');
  bool _isLoaded = false;

  UserProfile get profile => _profile;
  bool get isLoaded => _isLoaded;

  /// Tải thông tin người chơi từ SharedPreferences
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('userId');
    if (userId == null) {
      // Tạo userId ngẫu nhiên cho lần đầu tiên
      userId = _generateUserId();
      await prefs.setString('userId', userId);
    }

    final name = prefs.getString('userName') ?? 'Người chơi mới';
    final avatarIndex = prefs.getInt('avatarIndex') ?? 0;

    _profile = UserProfile(
      userId: userId,
      name: name,
      avatarIndex: avatarIndex,
    );
    _isLoaded = true;
    notifyListeners();
  }

  /// Cập nhật tên và avatar
  Future<void> updateProfile({String? name, int? avatarIndex}) async {
    _profile = _profile.copyWith(
      name: name,
      avatarIndex: avatarIndex,
    );

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('userName', name);
    if (avatarIndex != null) await prefs.setInt('avatarIndex', avatarIndex);

    notifyListeners();
  }

  /// Tạo userId dạng "user_xxxxx"
  String _generateUserId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final code = List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    return 'user_$code';
  }
}
