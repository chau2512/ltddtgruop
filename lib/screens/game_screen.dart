import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? _selectedOptionIndex;
  bool _isCorrect = false;
  bool _isProcessing = false;

  void _handleAnswer(GameProvider game, int option, int index) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _selectedOptionIndex = index;
      _isCorrect = option == game.currentQuestion!.correctAnswer;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    game.checkAnswer(option);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _selectedOptionIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isGameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const ResultScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              )
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final question = game.currentQuestion;
        if (question == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          backgroundColor: Colors.orange[50],
          appBar: _buildAppBar(context, game),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMascot(game.questionCount),
                  const SizedBox(height: 10),
                  _buildQuestionCard(question.questionText, game.questionCount),
                  const SizedBox(height: 30),
                  _buildAnswersGrid(game),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, GameProvider game) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.deepOrange, size: 30),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: game.questionCount / game.maxQuestions,
                backgroundColor: Colors.orange.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            '${game.questionCount}/${game.maxQuestions}',
            style: GoogleFonts.fredoka(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (_isProcessing && _isCorrect)
                  Positioned(
                    top: -30,
                    child: const Text('+10', style: TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold))
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .moveY(begin: 0, end: -40, duration: 800.ms, curve: Curves.easeOut)
                      .fadeOut(delay: 600.ms, duration: 200.ms),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
                    ]
                  ),
                  child: Text(
                    '⭐ ${game.score}',
                    style: GoogleFonts.fredoka(color: Colors.deepOrange, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ).animate(key: ValueKey(game.score)).scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 300.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMascot(int questionCount) {
    if (_isProcessing) {
      if (_isCorrect) {
        return const Icon(Icons.sentiment_very_satisfied_rounded, size: 70, color: Colors.green)
            .animate().scale(curve: Curves.elasticOut, duration: 600.ms);
      } else {
        return const Icon(Icons.sentiment_very_dissatisfied_rounded, size: 70, color: Colors.red)
            .animate().shakeX(amount: 5, duration: 400.ms);
      }
    }
    
    return const Icon(Icons.help_outline_rounded, size: 70, color: Colors.indigo)
        .animate(key: ValueKey(questionCount)).scale(curve: Curves.elasticOut, duration: 600.ms);
  }

  Widget _buildQuestionCard(String text, int questionCount) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.fredoka(fontSize: 60, color: Colors.indigo, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ).animate(key: ValueKey(questionCount))
       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 500.ms)
       .fadeIn(duration: 400.ms),
    );
  }

  Widget _buildAnswersGrid(GameProvider game) {
    final question = game.currentQuestion!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = _selectedOptionIndex == index;
        
        Color btnColor = Colors.orange;
        if (_isProcessing && isSelected) {
          btnColor = _isCorrect ? Colors.green : Colors.red;
        }

        final delay = 300 + (index * 100);
        
        Widget button = ElevatedButton(
          onPressed: () => _handleAnswer(game, option, index),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: isSelected ? 12 : 8,
            shadowColor: btnColor.withOpacity(0.5),
          ),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.toString(),
                  style: GoogleFonts.fredoka(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                if (_isProcessing && isSelected) ...[
                  const SizedBox(width: 10),
                  Icon(_isCorrect ? Icons.check_circle : Icons.cancel, size: 40, color: Colors.white),
                ]
              ],
            ),
          ),
        );

        if (_isProcessing && isSelected && !_isCorrect) {
          button = button.animate().shakeX(amount: 5, duration: 400.ms);
        }
        if (_isProcessing && isSelected && _isCorrect) {
          button = button.animate().scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 200.ms);
        }

        if (!_isProcessing) {
          button = button.animate(key: ValueKey('${game.questionCount}_$index'))
            .fadeIn(delay: delay.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack, delay: delay.ms);
        }

        return button;
      }),
    );
  }
}
