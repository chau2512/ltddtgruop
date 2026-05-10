import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/admin_provider.dart';

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, child) {
        if (!admin.aiService.hasApiKey) {
          return _buildApiKeySetup(admin);
        }
        return _buildChatInterface(admin);
      },
    );
  }

  Widget _buildApiKeySetup(AdminProvider admin) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 64, color: Color(0xFF4EA8DE)),
            const SizedBox(height: 16),
            Text(
              'Trợ lý AI Thông Minh',
              style: GoogleFonts.fredoka(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập API Key chuẩn OpenAI (như Groq, OpenAI) để bắt đầu. API key không được lưu cố định để bảo mật.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiKeyController,
              style: GoogleFonts.nunito(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập API Key...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.key, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_apiKeyController.text.isNotEmpty) {
                    admin.setAiApiKey(_apiKeyController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Bắt đầu',
                  style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface(AdminProvider admin) {
    final messages = admin.aiService.messages.where((m) => m['role'] != 'system' && m['role'] != 'tool').toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF16213E),
          child: Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: Color(0xFF4EA8DE), size: 24),
              const SizedBox(width: 10),
              Text(
                'AI Assistant',
                style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => admin.clearAiChat(),
                icon: const Icon(Icons.cleaning_services_rounded, size: 16, color: Colors.white54),
                label: Text('Xóa chat', style: GoogleFonts.nunito(color: Colors.white54)),
              ),
            ],
          ),
        ),

        // Chat list
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'Hãy nói gì đó để bắt đầu...',
                    style: GoogleFonts.nunito(color: Colors.white30, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg['role'] == 'user';
                    
                    // Xử lý nếu message là tool call
                    if (msg['tool_calls'] != null) {
                       return const SizedBox.shrink(); // Ẩn message trung gian của tool_calls
                    }

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFFE94560) : const Color(0xFF16213E),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        child: MarkdownBody(
                          data: msg['content']?.toString() ?? '',
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.nunito(color: Colors.white, fontSize: 15),
                            strong: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
                            code: const TextStyle(backgroundColor: Colors.black26, color: Colors.greenAccent),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Loading indicator
        if (admin.aiIsLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(color: Color(0xFF4EA8DE), strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('AI đang suy nghĩ...', style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF16213E),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.nunito(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn (VD: tạo 3 câu hỏi cấp 2)',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(admin),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: const Color(0xFFE94560),
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: admin.aiIsLoading ? null : () => _sendMessage(admin),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(AdminProvider admin) {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text.trim();
    _messageController.clear();
    
    admin.sendAiMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom(); // Cuộn ngay khi vừa gửi
  }
}
