import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matchquizapp/main.dart' as app;
import 'package:matchquizapp/models/custom_question.dart';
import 'package:matchquizapp/services/database_service.dart';
import 'package:matchquizapp/services/audio_service.dart';
import 'package:matchquizapp/screens/result_screen.dart';
import 'package:matchquizapp/screens/game_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Manual Mock
class MockDatabaseService implements DatabaseService {
  @override
  Future<List<CustomQuestion>> getActiveQuestions(int level) async {
    // Trả về 2 câu hỏi giả lập cho Level 1
    return [
      CustomQuestion(
        id: 'mock1',
        questionText: '1+1 = ?',
        correctAnswer: 2,
        options: [1, 2, 3, 4],
        level: 1,
        isActive: true,
      ),
      CustomQuestion(
        id: 'mock2',
        questionText: '2+2 = ?',
        correctAnswer: 4,
        options: [2, 3, 4, 5],
        level: 1,
        isActive: true,
      ),
    ];
  }

  @override
  Future<void> saveGameSession({required String userId, required int level, required int score}) async {
    return;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  AudioService.isTestMode = true;

  // Bỏ qua lỗi MissingPluginException của audioplayers trong môi trường test
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is MissingPluginException && 
        details.exception.toString().contains('audioplayers')) {
      return;
    }
    originalOnError?.call(details);
  };

  group('Luồng Chơi Game (End-to-End)', () {
    testWidgets('Người dùng chọn Level 1 và trả lời hết câu hỏi', (tester) async {
      // Cho phép tải font (nhưng ta sẽ mock path_provider để nó không crash)
      GoogleFonts.config.allowRuntimeFetching = true;
      
      // Mock path_provider MethodChannel
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return '.'; // Trả về thư mục hiện tại giả lập
        },
      );

      // Mock MethodChannel và EventChannel cho audioplayers
      const MethodChannel('xyz.luan/audioplayers').setMockMethodCallHandler((call) async => null);
      const MethodChannel('xyz.luan/audioplayers.global').setMockMethodCallHandler((call) async => null);
      
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers/events'),
        (methodCall) async => null,
      );

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Đặt kích thước màn hình ảo
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockDb = MockDatabaseService();
      
      // Khởi chạy app với mock DB và Theme mặc định để tránh lỗi Google Fonts
      await tester.pumpWidget(
        app.MainApp(
          databaseService: mockDb,
          themeData: ThemeData(
            textTheme: const TextTheme(), // Use default system fonts
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1)); // Wait for initialization

      // 1. Kiểm tra màn hình chính
      expect(find.text('Toán Trắc Nghiệm'), findsOneWidget);
      expect(find.text('Cấp 1'), findsOneWidget);

      // 2. Click chọn Cấp 1
      await tester.tap(find.text('Cấp 1'));
      await tester.pump(const Duration(seconds: 1));

      // 3. Đang ở GameScreen, trả lời câu 1
      // Vì có shuffle, ta tìm câu hỏi bất kỳ trong mock
      await tester.pump(const Duration(seconds: 1)); 
      final q1Finder = find.byWidgetPredicate((widget) => widget is Text && (widget.data?.contains('1+1') == true || widget.data?.contains('2+2') == true));
      expect(q1Finder, findsOneWidget);
      
      // Tap đại một đáp án (vì ta chỉ cần qua màn)
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump(const Duration(seconds: 2)); // Wait for 1.5s delay + animation

      // 4. Trả lời câu 2
      expect(q1Finder, findsOneWidget); // Vẫn là tìm Text chứa câu hỏi
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump(const Duration(seconds: 2));

      // 5. Trả lời cho đến khi hết game (tối đa 20 câu để cực kỳ an toàn)
      for (int i = 0; i < 20; i++) {
        final buttons = find.descendant(
          of: find.byType(GameScreen), 
          matching: find.byType(ElevatedButton)
        );
        
        if (buttons.evaluate().isEmpty) break;
        
        await tester.tap(buttons.first);
        await tester.pump(const Duration(seconds: 1)); // Nhanh hơn
        
        if (find.byType(ResultScreen).evaluate().isNotEmpty) break;
      }

      // 6. Đợi màn hình kết quả xuất hiện (Retry loop)
      bool foundResult = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ResultScreen).evaluate().isNotEmpty) {
          foundResult = true;
          break;
        }
      }
      
      expect(foundResult, isTrue, reason: 'Không tìm thấy ResultScreen sau khi trả lời hết câu hỏi');
      expect(find.byType(ResultScreen), findsOneWidget);
      
      // 7. Quay lại màn hình chính
      await tester.tap(find.text('VỀ MÀN HÌNH CHÍNH'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Toán Trắc Nghiệm'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
