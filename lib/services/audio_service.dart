import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _sfxPlayerInstance;
  AudioPlayer? _bgmPlayerInstance;

  AudioPlayer get _sfxPlayer {
    _sfxPlayerInstance ??= AudioPlayer();
    return _sfxPlayerInstance!;
  }

  AudioPlayer get _bgmPlayer {
    _bgmPlayerInstance ??= AudioPlayer();
    return _bgmPlayerInstance!;
  }

  final Random _random = Random();

  bool _isMuted = false;

  // Cài đặt từ Admin
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 0.5;
  double _sfxVolume = 1.0;

  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> init() async {
    if (isTestMode) return;
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    // Tải cài đặt âm thanh từ Firestore
    await loadSettings();
  }

  /// Tải cài đặt âm thanh từ Firestore
  Future<void> loadSettings() async {
    if (isTestMode) return;
    try {
      final settings = await DatabaseService().getAudioSettings();
      _bgmEnabled = settings['bgmEnabled'] ?? true;
      _sfxEnabled = settings['sfxEnabled'] ?? true;
      _bgmVolume = (settings['bgmVolume'] ?? 0.5).toDouble();
      _sfxVolume = (settings['sfxVolume'] ?? 1.0).toDouble();

      await _bgmPlayer.setVolume(_bgmVolume);
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      debugPrint('Lỗi tải audio settings: $e');
    }
  }

  /// Cập nhật cài đặt âm thanh (gọi từ AdminProvider)
  void applySettings({
    required bool bgmEnabled,
    required bool sfxEnabled,
    required double bgmVolume,
    required double sfxVolume,
  }) {
    _bgmEnabled = bgmEnabled;
    _sfxEnabled = sfxEnabled;
    _bgmVolume = bgmVolume;
    _sfxVolume = sfxVolume;

    if (isTestMode) return;

    _bgmPlayer.setVolume(_bgmVolume);
    _sfxPlayer.setVolume(_sfxVolume);

    // Nếu tắt BGM khi đang phát → dừng
    if (!_bgmEnabled) {
      _bgmPlayer.pause();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (isTestMode) return;
    
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  static bool isTestMode = false;

  Future<void> playBGM() async {
    if (isTestMode || _isMuted || !_bgmEnabled) return;
    try {
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát BGM: $e");
    }
  }

  Future<void> stopBGM() async {
    if (isTestMode) return;
    await _bgmPlayer.stop();
  }

  Future<void> playCorrect() async {
    if (isTestMode || _isMuted || !_sfxEnabled) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      int idx = _random.nextInt(3) + 1; // Random 1, 2, or 3
      await _sfxPlayer.play(AssetSource('audio/correct$idx.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát tiếng đúng: $e");
    }
  }

  Future<void> playWrong() async {
    if (isTestMode || _isMuted || !_sfxEnabled) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      int idx = _random.nextInt(4) + 1; // Random 1, 2, 3 or 4
      await _sfxPlayer.play(AssetSource('audio/wrong$idx.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát tiếng sai: $e");
    }
  }

  Future<void> playApplause() async {
    if (isTestMode || _isMuted || !_sfxEnabled) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource('audio/applause.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát tiếng vỗ tay: $e");
    }
  }
}
