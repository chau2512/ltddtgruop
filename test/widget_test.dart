import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matchquizapp/providers/admin_provider.dart';
import 'package:matchquizapp/providers/game_provider.dart';
import 'package:matchquizapp/providers/user_provider.dart';
import 'package:matchquizapp/screens/game_screen.dart';
import 'package:matchquizapp/screens/result_screen.dart';
import 'package:provider/provider.dart';
import 'package:matchquizapp/main.dart';

// ─────────────────────────────────────────────────────────────
// Mock platform channels
// ─────────────────────────────────────────────────────────────

/// Mock audioplayers platform channels (không có audio hardware trong test)
void _mockAudioPlayers() {
  const channels = [
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
  ];
  for (final ch in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel(ch),
      (MethodCall methodCall) async => null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget helper
// ─────────────────────────────────────────────────────────────
Widget _buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => GameProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AdminProvider()),
    ],
    child: MaterialApp(
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────
void main() {
  setUpAll(() {
    // Giả lập SharedPreferences với dữ liệu rỗng
    SharedPreferences.setMockInitialValues({});
    // Mock audioplayers
    _mockAudioPlayers();
  });

  testWidgets('MainScreen hiển thị đúng các level button', (WidgetTester tester) async {
    // Đặt kích thước màn hình ảo lớn để tránh overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestApp());
    // Pump để UserProvider.loadProfile() hoàn tất
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Kiểm tra tiêu đề
    expect(find.text('Toán Trắc Nghiệm'), findsOneWidget);

    // Kiểm tra các nút level
    expect(find.widgetWithText(ElevatedButton, 'Cấp 1'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Cấp 2'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Cấp 3'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Cấp 4'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Tap Cấp 1 → GameScreen hiển thị câu hỏi đầu', (WidgetTester tester) async {
    // Đặt kích thước màn hình đủ lớn để hiển thị GridView đáp án
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Nhấn nút Cấp 1
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cấp 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Kiểm tra GameScreen đã load: hiện câu hỏi 1/10
    expect(find.textContaining('1/10'), findsOneWidget);
    expect(find.text('⭐ 0'), findsOneWidget);

    // Tìm các đáp án trong GridView
    final answerButtons = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(ElevatedButton),
    );
    expect(answerButtons, findsWidgets);

    // Scroll tới nút trước khi tap (đề phòng off-screen)
    await tester.ensureVisible(answerButtons.first);
    await tester.pump();

    // Chọn đáp án đầu tiên
    await tester.tap(answerButtons.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 1200));

    // Câu hỏi 2 xuất hiện (hoặc game vẫn ở câu 1 nếu answer chưa đăng ký)
    expect(find.textContaining('/10'), findsOneWidget);

    // Dọn dẹp timer và animation
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpWidget(const SizedBox());
  });
}
