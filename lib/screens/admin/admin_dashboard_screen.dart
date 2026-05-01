import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/admin_provider.dart';
import '../../models/custom_question.dart';
import '../../services/audio_service.dart';
import 'question_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _filterLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
              onPressed: () {
                admin.logout();
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Admin Panel',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                onPressed: () {
                  admin.logout();
                  Navigator.pop(context);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE94560),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.quiz_rounded), text: 'Câu hỏi'),
                Tab(icon: Icon(Icons.volume_up_rounded), text: 'Âm thanh'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildQuestionsTab(admin),
              _buildAudioTab(admin),
            ],
          ),
          floatingActionButton: _tabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateToForm(context),
                  backgroundColor: const Color(0xFFE94560),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'Thêm câu hỏi',
                    style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 1, end: 0)
              : null,
        );
      },
    );
  }

  // =============================================
  // TAB 1: QUẢN LÝ CÂU HỎI
  // =============================================

  Widget _buildQuestionsTab(AdminProvider admin) {
    return Column(
      children: [
        // Filter by level
        _buildLevelFilter(admin),

        // Questions list
        Expanded(
          child: admin.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE94560)),
                )
              : admin.questions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                      itemCount: admin.questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(admin, admin.questions[index], index);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLevelFilter(AdminProvider admin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF16213E),
      child: Row(
        children: [
          Text(
            'Lọc theo:',
            style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(width: 10),
          _buildFilterChip('Tất cả', null, admin),
          const SizedBox(width: 8),
          _buildFilterChip('Cấp 1', 1, admin),
          const SizedBox(width: 8),
          _buildFilterChip('Cấp 2', 2, admin),
          const SizedBox(width: 8),
          _buildFilterChip('Cấp 3', 3, admin),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? level, AdminProvider admin) {
    final isSelected = _filterLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() => _filterLevel = level);
        admin.loadQuestions(level: level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE94560) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE94560) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 15),
          Text(
            'Chưa có câu hỏi nào',
            style: GoogleFonts.fredoka(fontSize: 20, color: Colors.white30),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút "Thêm câu hỏi" để bắt đầu',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white24),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildQuestionCard(AdminProvider admin, CustomQuestion question, int index) {
    final levelColors = {
      1: Colors.lightGreen,
      2: Colors.orange,
      3: Colors.deepOrange,
    };
    final color = levelColors[question.level] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: question.isActive ? color.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Cấp ${question.level}',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: question.isActive
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.isActive ? 'Bật' : 'Tắt',
                    style: TextStyle(
                      fontSize: 12,
                      color: question.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Toggle active
                Switch(
                  value: question.isActive,
                  onChanged: (_) => admin.toggleQuestion(question),
                  activeColor: const Color(0xFFE94560),
                  inactiveThumbColor: Colors.white30,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question text
            Text(
              question.questionText,
              style: GoogleFonts.nunito(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Options
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: question.options.map((opt) {
                final isCorrect = opt == question.correctAnswer;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect ? Colors.green.withOpacity(0.4) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCorrect)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ),
                      Text(
                        opt.toString(),
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _navigateToForm(context, question: question),
                  icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF4EA8DE)),
                  label: Text(
                    'Sửa',
                    style: GoogleFonts.nunito(color: const Color(0xFF4EA8DE), fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(admin, question),
                  icon: const Icon(Icons.delete_rounded, size: 18, color: Color(0xFFE94560)),
                  label: Text(
                    'Xóa',
                    style: GoogleFonts.nunito(color: const Color(0xFFE94560), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 400.ms).slideX(
        begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  void _confirmDelete(AdminProvider admin, CustomQuestion question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xóa câu hỏi:\n"${question.questionText}"?',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.nunito(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (question.id != null) {
                admin.deleteQuestion(question.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Xóa', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, {CustomQuestion? question}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuestionFormScreen(question: question),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  // =============================================
  // TAB 2: CÀI ĐẶT ÂM THANH
  // =============================================

  Widget _buildAudioTab(AdminProvider admin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔊 Cài đặt âm thanh',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Thay đổi sẽ áp dụng cho tất cả người chơi',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white38),
          ),
          const SizedBox(height: 30),

          // BGM Settings
          _buildAudioSettingCard(
            title: 'Nhạc nền (BGM)',
            subtitle: 'Nhạc phát trong khi chơi game',
            icon: Icons.music_note_rounded,
            color: const Color(0xFF4EA8DE),
            isEnabled: admin.bgmEnabled,
            volume: admin.bgmVolume,
            onToggle: (val) {
              admin.updateAudioSettings(bgmEnabled: val);
              AudioService().applySettings(
                bgmEnabled: admin.bgmEnabled,
                sfxEnabled: admin.sfxEnabled,
                bgmVolume: admin.bgmVolume,
                sfxVolume: admin.sfxVolume,
              );
            },
            onVolumeChanged: (val) {
              admin.updateAudioSettings(bgmVolume: val);
              AudioService().applySettings(
                bgmEnabled: admin.bgmEnabled,
                sfxEnabled: admin.sfxEnabled,
                bgmVolume: admin.bgmVolume,
                sfxVolume: admin.sfxVolume,
              );
            },
            delay: 0,
          ),
          const SizedBox(height: 16),

          // SFX Settings
          _buildAudioSettingCard(
            title: 'Hiệu ứng âm thanh (SFX)',
            subtitle: 'Tiếng đúng, sai, vỗ tay',
            icon: Icons.spatial_audio_off_rounded,
            color: const Color(0xFFE94560),
            isEnabled: admin.sfxEnabled,
            volume: admin.sfxVolume,
            onToggle: (val) {
              admin.updateAudioSettings(sfxEnabled: val);
              AudioService().applySettings(
                bgmEnabled: admin.bgmEnabled,
                sfxEnabled: admin.sfxEnabled,
                bgmVolume: admin.bgmVolume,
                sfxVolume: admin.sfxVolume,
              );
            },
            onVolumeChanged: (val) {
              admin.updateAudioSettings(sfxVolume: val);
              AudioService().applySettings(
                bgmEnabled: admin.bgmEnabled,
                sfxEnabled: admin.sfxEnabled,
                bgmVolume: admin.bgmVolume,
                sfxVolume: admin.sfxVolume,
              );
            },
            delay: 100,
          ),

          const SizedBox(height: 30),

          // Audio files info
          _buildAudioFilesInfo(),
        ],
      ),
    );
  }

  Widget _buildAudioSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onVolumeChanged,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isEnabled ? color.withOpacity(0.3) : Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: color,
                inactiveThumbColor: Colors.white30,
              ),
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.volume_down_rounded, color: Colors.white30, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: color,
                      inactiveTrackColor: color.withOpacity(0.15),
                      thumbColor: color,
                      overlayColor: color.withOpacity(0.1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: onVolumeChanged,
                    ),
                  ),
                ),
                Icon(Icons.volume_up_rounded, color: Colors.white30, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${(volume * 100).round()}%',
                  style: GoogleFonts.fredoka(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideX(
        begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildAudioFilesInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📁 File âm thanh hiện có',
            style: GoogleFonts.fredoka(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildAudioFileRow('🎵 bgm.mp3', 'Nhạc nền'),
          _buildAudioFileRow('✅ correct1-3.mp3', 'Tiếng trả lời đúng (3 file)'),
          _buildAudioFileRow('❌ wrong1-4.mp3', 'Tiếng trả lời sai (4 file)'),
          _buildAudioFileRow('👏 applause.mp3', 'Tiếng vỗ tay khi đạt điểm cao'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white24, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Để thay đổi file âm thanh, thay thế trực tiếp trong thư mục assets/audio/ rồi build lại app.',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildAudioFileRow(String fileName, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(fileName, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(description, style: GoogleFonts.nunito(color: Colors.white30, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
