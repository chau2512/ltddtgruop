import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  int _selectedAvatarIndex = 0;

  // Stats
  bool _isLoadingStats = true;
  int _totalGames = 0;
  Map<int, int> _highScores = {};

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.profile.name);
    _selectedAvatarIndex = user.profile.avatarIndex;
    _loadStats(user.profile.userId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadStats(String userId) async {
    final stats = await DatabaseService().getUserStats(userId);
    if (mounted) {
      setState(() {
        _totalGames = stats['totalGames'] as int;
        _highScores = Map<int, int>.from(stats['highScores'] as Map);
        _isLoadingStats = false;
      });
    }
  }

  void _saveProfile() {
    final user = Provider.of<UserProvider>(context, listen: false);
    user.updateProfile(
      name: _nameController.text.trim().isEmpty ? 'Người chơi mới' : _nameController.text.trim(),
      avatarIndex: _selectedAvatarIndex,
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        final profile = user.profile;
        return Scaffold(
          backgroundColor: Colors.orange[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.deepOrange, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Hồ Sơ Của Tôi',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ===== AVATAR & NAME SECTION =====
                _buildProfileHeader(profile),
                const SizedBox(height: 30),

                // ===== EDIT SECTION =====
                if (_isEditing) ...[
                  _buildEditSection(),
                  const SizedBox(height: 30),
                ],

                // ===== STATS SECTION =====
                _buildStatsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.avatarEmoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 15),

          // Name
          Text(
            profile.name,
            style: GoogleFonts.fredoka(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 5),

          // User ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${profile.userId}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Edit button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (_isEditing) {
                  _nameController.text = profile.name;
                  _selectedAvatarIndex = profile.avatarIndex;
                }
              });
            },
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              size: 20,
            ),
            label: Text(
              _isEditing ? 'Huỷ' : 'Chỉnh sửa hồ sơ',
              style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildEditSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            '✏️ Chỉnh sửa',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Name input
          Text(
            'Tên của bạn',
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            maxLength: 20,
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Nhập tên...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.orange[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
              ),
              counterText: '',
              prefixIcon: const Icon(Icons.person_rounded, color: Colors.deepOrange),
            ),
          ),

          const SizedBox(height: 25),

          // Avatar grid
          Text(
            'Chọn hình đại diện',
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: UserProfile.avatarEmojis.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAvatarIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatarIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? Colors.deepOrange : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.deepOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      UserProfile.avatarEmojis[index],
                      style: TextStyle(fontSize: isSelected ? 32 : 28),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_rounded, size: 24),
              label: Text(
                'Lưu thay đổi',
                style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                shadowColor: Colors.deepOrange.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Thành Tích',
            style: GoogleFonts.fredoka(fontSize: 22, color: Colors.deepOrange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (_isLoadingStats)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            )
          else ...[
            // Total games
            _buildStatCard(
              icon: Icons.sports_esports_rounded,
              title: 'Số ván đã chơi',
              value: '$_totalGames',
              color: Colors.blue,
              delay: 0,
            ),
            const SizedBox(height: 15),

            // High scores per level
            _buildStatCard(
              icon: Icons.star_border_rounded,
              title: 'Cấp 1 – Điểm cao nhất',
              value: _highScores[1]?.toString() ?? '—',
              color: Colors.lightGreen,
              delay: 100,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.star_half_rounded,
              title: 'Cấp 2 – Điểm cao nhất',
              value: _highScores[2]?.toString() ?? '—',
              color: Colors.orange,
              delay: 200,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.star_rounded,
              title: 'Cấp 3 – Điểm cao nhất',
              value: _highScores[3]?.toString() ?? '—',
              color: Colors.deepOrange,
              delay: 300,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
