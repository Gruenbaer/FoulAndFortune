import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../secrets.dart'; // Imports kGeminiApiKey

// -----------------------------------------------------------------------------
// CONFIGURATION
// kGeminiApiKey is now loaded from secrets.dart (gitignored)
// -----------------------------------------------------------------------------

class FeedbackChatDialog extends StatefulWidget {
  const FeedbackChatDialog({super.key});

  @override
  State<FeedbackChatDialog> createState() => _FeedbackChatDialogState();
}

class _FeedbackChatDialogState extends State<FeedbackChatDialog> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // AI State
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isTyping = false;
  bool _useFallback = true;
  String? _feedbackType; // Persists for email summary

  @override
  void initState() {
    super.initState();
    _initAI();
    
    // Initial Greeting
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_useFallback) {
         _addBotMessage("Hello! I'm the Fortune QA Bot (Basic Mode). 🤖\n\nPlease add an API Key to enable my Brain!\n\nFor now, just tell me: Is this a **Bug** 🐞 or a **Feature** ✨?");
      } else {
         _addBotMessage("Hello! I'm the Fortune QA Assistant. 🤖\n\nI can help you capture bugs or detail new features. What's on your mind?");
      }
    });
  }

  void _initAI() {
    if (kGeminiApiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: kGeminiApiKey,
        systemInstruction: Content.system(
          "You are the QA Assistant for the 'Fortune 14/2' pool scoring app. "
          "Your role is STRICTLY to help users report bugs or suggest features. "
          "1. Ask clarifying questions to understand the issue or idea completely. "
          "2. Do NOT engage in general conversation, storytelling, creative writing, or code generation. "
          "3. If asked for code or unrelated topics, refuse politely. "
          "4. Once you have enough info, summarize it and ask the user to 'Send Email'. "
          "5. Format your summary as: 'Type: [Bug/Feature]\nSummary: [Details]'. "
          "Be concise and professional."
        ),
      );
      _chatSession = _model!.startChat();
      _useFallback = false;
    } else {
      _useFallback = true;
    }
  }

  void _addBotMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
     if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleInput(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _addUserMessage(text);
    setState(() => _isTyping = true);

    if (_useFallback) {
      // Fallback Logic (Old Implementation)
      await Future.delayed(const Duration(milliseconds: 600));
      _processFallbackLogic(text);
    } else {
      // LLM Logic
      try {
        final response = await _chatSession!.sendMessage(Content.text(text));
        final responseText = response.text ?? "I'm having trouble thinking right now.";
        
        // Simple heuristic to detect if bot is ready to send
        if (responseText.toLowerCase().contains("summary:") || responseText.toLowerCase().contains("send email")) {
           // Extract type for subject line if possible
           if (responseText.toLowerCase().contains("bug")) _feedbackType = "Bug Report";
           else if (responseText.toLowerCase().contains("feature")) _feedbackType = "Feature Request";
        }
        
        _addBotMessage(responseText);
      } catch (e) {
        _addBotMessage("Error connecting to AI brain. Please try again. ($e)");
      }
    }
  }
  
  // --- Fallback (Old Logic) ---
  int _fallbackStep = 0;
  void _processFallbackLogic(String input) {
    final lower = input.toLowerCase();
    if (_fallbackStep == 0) {
      if (lower.contains('bug')) { _feedbackType = 'Bug'; _fallbackStep = 1; _addBotMessage("Oh no! Describe the bug."); }
      else if (lower.contains('feature')) { _feedbackType = 'Feature'; _fallbackStep = 1; _addBotMessage("Cool! Describe the feature."); }
      else { _addBotMessage("Please say 'Bug' or 'Feature'."); }
    } else {
      _fallbackStep = 2; // Ready
      _addBotMessage("Got it. Click the button below to send this report via email!");
    }
  }

  Future<void> _sendEmail() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = "${packageInfo.version}+${packageInfo.buildNumber}";
    
    // Compile history
    final history = _messages.map((m) => "${m.isUser ? 'User' : 'Assistant'}: ${m.text}").join("\n\n");
    
    final String subject = "Fortune 14/2 Feedback: ${_feedbackType ?? 'General'}";
    final String body = 
      "Generic User Feedback Report\n"
      "---------------------------\n"
      "App Version: $version\n\n"
      "Transcript:\n"
      "$history\n"
      "---------------------------\n";
      
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'developer@example.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      if (mounted) Navigator.of(context).pop();
    } else {
      _addBotMessage("⚠️ Could not open email client.");
    }
  }
  
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    // Detect if we are in a "Ready to Send" state roughly
    final showSendButton = (_messages.length > 2); 

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white), // Brain Icon
                  const SizedBox(width: 8),
                  Text(
                    'QA Assistant ${_useFallback ? "(Basic)" : "(AI)"}',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Chat Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(padding: EdgeInsets.all(8), child: Text("Thinking...", style: TextStyle(color: Colors.grey))),
                    );
                  }
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 260),
                      decoration: BoxDecoration(
                        color: msg.isUser ? const Color(0xFFBBDEFB) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: msg.isUser ? const Radius.circular(12) : Radius.zero,
                          bottomRight: msg.isUser ? Radius.zero : const Radius.circular(12),
                        ),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0,1))
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Action Button
            if (showSendButton)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Send Report via Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (t) => _handleInput(t),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2196F3)),
                    onPressed: () => _handleInput(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
