import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    final isHigh = game.score >= (game.maxQuestions * 10 * 0.8); // Điểm cao >= 80%
    
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isHigh ? Icons.emoji_events_rounded : Icons.star_rounded,
                size: 150,
                color: isHigh ? Colors.amber : Colors.orange,
              ).animate(onPlay: (controller) => controller.repeat())
               .shimmer(duration: 2.seconds, color: Colors.white)
               .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds)
               .then().scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1.seconds),
               
              const SizedBox(height: 20),
              
              Text(
                isHigh ? 'TUYỆT VỜI!' : 'CỐ GẮNG LÊN NÀO!',
                style: GoogleFonts.fredoka(fontSize: 40, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
              
              const SizedBox(height: 30),
              
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  children: [
                    Text(
                      'Điểm số của bạn',
                      style: GoogleFonts.fredoka(fontSize: 24, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${game.score} / ${game.maxQuestions * 10}',
                      style: GoogleFonts.fredoka(fontSize: 48, color: Colors.indigo, fontWeight: FontWeight.bold),
                    ).animate().scale(delay: 500.ms, duration: 600.ms, curve: Curves.elasticOut),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              
              const SizedBox(height: 50),
              
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Trở về MainScreen
                },
                icon: const Icon(Icons.home_rounded, size: 30, color: Colors.white),
                label: Text(
                  'VỀ MÀN HÌNH CHÍNH',
                  style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.orange.withOpacity(0.5),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }
}
