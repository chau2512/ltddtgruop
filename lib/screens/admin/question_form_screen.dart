import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/admin_provider.dart';
import '../../models/custom_question.dart';

class QuestionFormScreen extends StatefulWidget {
  final CustomQuestion? question; // null = thêm mới, có giá trị = chỉnh sửa

  const QuestionFormScreen({super.key, this.question});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _correctAnswerController;
  late TextEditingController _wrongAnswer1Controller;
  late TextEditingController _wrongAnswer2Controller;
  late TextEditingController _wrongAnswer3Controller;
  int _selectedLevel = 1;
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    _questionController = TextEditingController(text: q?.questionText ?? '');
    _correctAnswerController =
        TextEditingController(text: q?.correctAnswer.toString() ?? '');

    if (q != null) {
      _selectedLevel = q.level;
      _isActive = q.isActive;
      // Tách 3 đáp án sai
      final wrongAnswers = q.options.where((o) => o != q.correctAnswer).toList();
      _wrongAnswer1Controller =
          TextEditingController(text: wrongAnswers.isNotEmpty ? wrongAnswers[0].toString() : '');
      _wrongAnswer2Controller =
          TextEditingController(text: wrongAnswers.length > 1 ? wrongAnswers[1].toString() : '');
      _wrongAnswer3Controller =
          TextEditingController(text: wrongAnswers.length > 2 ? wrongAnswers[2].toString() : '');
    } else {
      _wrongAnswer1Controller = TextEditingController();
      _wrongAnswer2Controller = TextEditingController();
      _wrongAnswer3Controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    _wrongAnswer1Controller.dispose();
    _wrongAnswer2Controller.dispose();
    _wrongAnswer3Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final correctAnswer = int.parse(_correctAnswerController.text.trim());
    final options = [
      correctAnswer,
      int.parse(_wrongAnswer1Controller.text.trim()),
      int.parse(_wrongAnswer2Controller.text.trim()),
      int.parse(_wrongAnswer3Controller.text.trim()),
    ];

    final question = CustomQuestion(
      questionText: _questionController.text.trim(),
      correctAnswer: correctAnswer,
      options: options,
      level: _selectedLevel,
      isActive: _isActive,
    );

    final admin = Provider.of<AdminProvider>(context, listen: false);
    bool success;

    if (_isEditing) {
      success = await admin.updateQuestion(widget.question!.id!, question);
    } else {
      success = await admin.addQuestion(question);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Đã cập nhật câu hỏi!' : 'Đã thêm câu hỏi mới!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Có lỗi xảy ra. Vui lòng thử lại!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Sửa câu hỏi' : 'Thêm câu hỏi mới',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level selector
              _buildSectionTitle('📊 Chọn cấp độ'),
              const SizedBox(height: 10),
              _buildLevelSelector(),
              const SizedBox(height: 25),

              // Question text
              _buildSectionTitle('❓ Câu hỏi'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _questionController,
                hint: 'Ví dụ: 5 + 3 = ? hoặc Con mèo có mấy chân?',
                icon: Icons.help_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập câu hỏi';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Correct answer
              _buildSectionTitle('✅ Đáp án đúng'),
              const SizedBox(height: 10),
              _buildNumberField(
                controller: _correctAnswerController,
                hint: 'Nhập đáp án đúng (số)',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
              const SizedBox(height: 25),

              // Wrong answers
              _buildSectionTitle('❌ Đáp án sai (3 đáp án)'),
              const SizedBox(height: 10),
              _buildNumberField(
                controller: _wrongAnswer1Controller,
                hint: 'Đáp án sai 1',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFE94560),
              ),
              const SizedBox(height: 10),
              _buildNumberField(
                controller: _wrongAnswer2Controller,
                hint: 'Đáp án sai 2',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFE94560),
              ),
              const SizedBox(height: 10),
              _buildNumberField(
                controller: _wrongAnswer3Controller,
                hint: 'Đáp án sai 3',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFE94560),
              ),
              const SizedBox(height: 25),

              // Active toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: _isActive ? Colors.green : Colors.white30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trạng thái câu hỏi',
                            style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isActive ? 'Đang bật — sẽ xuất hiện trong game' : 'Đang tắt — sẽ không xuất hiện',
                            style: GoogleFonts.nunito(color: Colors.white38, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.white30,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 24, color: Colors.white),
                  label: Text(
                    _isSaving
                        ? 'Đang lưu...'
                        : (_isEditing ? 'Cập nhật câu hỏi' : 'Lưu câu hỏi'),
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    disabledBackgroundColor: const Color(0xFFE94560).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: const Color(0xFFE94560).withOpacity(0.4),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.fredoka(
        fontSize: 17,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Row(
      children: [1, 2, 3, 4].map((level) {
        final isSelected = _selectedLevel == level;
        final colors = {
          1: Colors.lightGreen,
          2: Colors.orange,
          3: Colors.deepOrange,
          4: Colors.purpleAccent,
        };
        final labels = {
          1: 'Cấp 1\n(+,- đến 10)',
          2: 'Cấp 2\n(+,- đến 100)',
          3: 'Cấp 3\n(Nhân/Chia)',
          4: 'Cấp 4\n(Hỗn hợp)',
        };
        final color = colors[level]!;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedLevel = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    level == 1
                        ? Icons.star_border_rounded
                        : level == 2
                            ? Icons.star_half_rounded
                            : level == 3
                                ? Icons.star_rounded
                                : Icons.workspace_premium_rounded,
                    color: isSelected ? color : Colors.white30,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[level]!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: isSelected ? color : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.nunito(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE94560), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
      ],
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số';
        if (int.tryParse(val.trim()) == null) return 'Phải là số nguyên';
        return null;
      },
      style: GoogleFonts.nunito(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(color: Colors.white24),
        prefixIcon: Icon(icon, color: color.withOpacity(0.6)),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
