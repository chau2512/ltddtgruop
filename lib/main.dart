import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/game_provider.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MathQuizApp(),
    ),
  );
}

class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Quiz Cho Bé',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // Tông màu pastel nhẹ nhàng
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.orange.withOpacity(0.2),
            ).animate(onPlay: (controller) => controller.repeat()).moveY(end: 30, duration: 2.seconds, curve: Curves.easeInOut).then().moveY(end: -30, duration: 2.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -80,
            right: -20,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.deepOrange.withOpacity(0.15),
            ).animate(onPlay: (controller) => controller.repeat()).moveX(end: -40, duration: 3.seconds, curve: Curves.easeInOut).then().moveX(end: 40, duration: 3.seconds, curve: Curves.easeInOut),
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calculate_rounded, size: 100, color: Colors.orange)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.yellowAccent)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
                    .then().scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1.seconds, curve: Curves.easeInOut),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Toán Trắc Nghiệm',
                    style: GoogleFonts.fredoka(
                      fontSize: 45,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.orange.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    child: const Text(
                      'Dành cho học sinh Tiểu học',
                      style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 60),
                  
                  // Level Buttons
                  _buildLevelButton(
                    context: context,
                    level: 1,
                    title: 'Cấp 1',
                    subtitle: '(+, - đến 10)',
                    color: Colors.lightGreen,
                    icon: Icons.star_border_rounded,
                    delay: 500,
                  ),
                  const SizedBox(height: 20),
                  _buildLevelButton(
                    context: context,
                    level: 2,
                    title: 'Cấp 2',
                    subtitle: '(+, - đến 100)',
                    color: Colors.orange,
                    icon: Icons.star_half_rounded,
                    delay: 700,
                  ),
                  const SizedBox(height: 20),
                  _buildLevelButton(
                    context: context,
                    level: 3,
                    title: 'Cấp 3',
                    subtitle: '(Nhân / Chia)',
                    color: Colors.deepOrange,
                    icon: Icons.star_rounded,
                    delay: 900,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton({
    required BuildContext context,
    required int level,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required int delay,
  }) {
    return ElevatedButton(
      onPressed: () {
        _startGame(context, level);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        minimumSize: const Size(280, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 8,
        shadowColor: color.withOpacity(0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold, height: 1.0)),
              Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 500.ms).slideX(begin: 0.5, end: 0, curve: Curves.easeOutBack);
  }

  void _startGame(BuildContext context, int level) {
    Provider.of<GameProvider>(context, listen: false).startGame(level);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      )
    );
  }
}
