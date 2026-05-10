import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/custom_question.dart';
import '../providers/admin_provider.dart';
import 'ai_rules.dart';

class AIService {
  static const String _defaultGroqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static const String _model = 'llama-3.3-70b-versatile';

  String? _apiKey;
  final List<Map<String, dynamic>> _messages = [];

  void setApiKey(String key) {
    _apiKey = key;
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  
  List<Map<String, dynamic>> get messages => _messages;

  void clearChat() {
    _messages.clear();
  }

  /// Khởi tạo system prompt
  void _initSystemPromptIfNeeded() {
    if (_messages.isEmpty) {
      _messages.add({
        "role": "system",
        "content": AIRules.systemPrompt
      });
    }
  }

  /// Định nghĩa Tool (Function Calling)
  List<Map<String, dynamic>> _getTools() {
    return [
      {
        "type": "function",
        "function": {
          "name": "add_question",
          "description": "Thêm một câu hỏi toán học mới vào hệ thống",
          "parameters": {
            "type": "object",
            "properties": {
              "questionText": { "type": "string", "description": "Câu hỏi, ví dụ: '5 + 3 = ?' hoặc '12 x 3 = ?'" },
              "correctAnswer": { "type": "string", "description": "Đáp án đúng (chỉ ghi số, ví dụ '8')" },
              "options": { 
                "type": "array", 
                "items": { "type": "string" },
                "description": "Danh sách 4 đáp án (chỉ ghi số, ví dụ ['8', '10', '12', '14'])"
              },
              "level": { "type": "string", "description": "Cấp độ khó: '1', '2', '3' hoặc '4'" }
            },
            "required": ["questionText", "correctAnswer", "options", "level"]
          }
        }
      }
    ];
  }

  /// Gửi tin nhắn tới AI và xử lý phản hồi
  Future<void> sendMessage(String text, AdminProvider admin) async {
    if (!hasApiKey) throw Exception('Vui lòng nhập API Key trước');

    _initSystemPromptIfNeeded();

    // Thêm tin nhắn của user
    _messages.add({"role": "user", "content": text});

    bool toolCallResolved = false;

    do {
      toolCallResolved = false;

      final response = await http.post(
        Uri.parse(_defaultGroqUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", // Model mới nhất của Groq hỗ trợ Function Calling tốt
          "messages": _messages,
          "tools": _getTools(),
          "tool_choice": "auto",
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Lỗi API: ${response.body}');
        throw Exception('Lỗi kết nối tới AI: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final choice = data['choices'][0];
      final message = choice['message'];

      _messages.add(message);

      // Kiểm tra xem AI có gọi hàm (Tool Call) không
      if (message['tool_calls'] != null) {
        for (var toolCall in message['tool_calls']) {
          final function = toolCall['function'];
          final name = function['name'];
          final args = jsonDecode(function['arguments']);

          if (name == 'add_question') {
            try {
              final qText = args['questionText'];
              final cAnswer = int.parse(args['correctAnswer'].toString());
              final List<dynamic> optionsRaw = args['options'];
              final List<int> options = optionsRaw.map((e) => int.parse(e.toString())).toList();
              final level = int.parse(args['level'].toString());

              final newQuestion = CustomQuestion(
                questionText: qText,
                correctAnswer: cAnswer,
                options: options,
                level: level,
                isActive: true,
              );

              final success = await admin.addQuestion(newQuestion);

              // Phản hồi kết quả của hàm lại cho AI
              _messages.add({
                "role": "tool",
                "tool_call_id": toolCall['id'],
                "name": name,
                "content": success ? "Đã thêm câu hỏi thành công!" : "Lỗi khi thêm câu hỏi."
              });

              // Bật flag để gọi lại API cho AI sinh câu trả lời tự nhiên
              toolCallResolved = true;
            } catch (e) {
              _messages.add({
                "role": "tool",
                "tool_call_id": toolCall['id'],
                "name": name,
                "content": "Lỗi tham số: $e"
              });
              toolCallResolved = true;
            }
          }
        }
      }

    } while (toolCallResolved); // Lặp lại nếu có tool call để lấy response cuối
  }
}
