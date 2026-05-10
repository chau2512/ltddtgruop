import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:matchquizapp/screens/admin/admin_login_screen.dart';
import 'package:matchquizapp/providers/admin_provider.dart';
import 'package:matchquizapp/services/database_service.dart';

import 'package:matchquizapp/models/custom_question.dart';

class MockDatabaseService implements DatabaseService {
  @override
  Future<bool> verifyAdminPin(String pin) async {
    return pin == '123456';
  }
  
  @override
  Future<List<CustomQuestion>> getCustomQuestions({int? level}) async => [];
  
  @override
  Future<Map<String, dynamic>> getAudioSettings() async => {
    'bgmEnabled': true,
    'sfxEnabled': true,
    'bgmVolume': 0.5,
    'sfxVolume': 1.0,
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestApp(AdminProvider adminProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
      ],
      child: const MaterialApp(
        home: AdminLoginScreen(),
      ),
    );
  }

  group('AdminLoginScreen Widget Tests', () {
    late AdminProvider adminProvider;
    late MockDatabaseService mockDb;

    setUp(() {
      mockDb = MockDatabaseService();
      adminProvider = AdminProvider(databaseService: mockDb);
    });

    testWidgets('Hiển thị tiêu đề và 6 ô nhập PIN', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(adminProvider));
      await tester.pump();

      expect(find.text('Quản trị viên'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Hiển thị lỗi khi nhập PIN sai (999999)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(adminProvider));
      await tester.pump();

      final fields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), '9');
        await tester.pump();
      }
      
      // Chờ login logic hoàn thành
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Mã PIN không đúng'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Vào dashboard khi nhập PIN đúng (123456)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(adminProvider));
      await tester.pump();

      final fields = find.byType(TextField);
      final pin = '123456';
      for (int i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), pin[i]);
        await tester.pump();
      }

      await tester.pump(const Duration(milliseconds: 500));
      
      // AdminProvider.isAdmin sẽ thành true
      expect(adminProvider.isAdmin, true);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
