import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackChatDialog extends StatefulWidget {
  const FeedbackChatDialog({super.key});

  @override
  State<FeedbackChatDialog> createState() => _FeedbackChatDialogState();
}

class _FeedbackChatDialogState extends State<FeedbackChatDialog> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Chat State
  ChatStep _currentStep = ChatStep.intro;
  String? _feedbackType; // 'bug' or 'feature'
  String _description = "";
  
  @override
  void initState() {
    super.initState();
    // Initial Greeting
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage("Hello! I'm the Fortune Assistant. 🤖\n\nDo you want to report a **Bug** 🐞 or request a **Feature** ✨?");
    });
  }

  void _addBotMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
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

  void _handleInput(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _addUserMessage(text);
    
    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 600), () {
      _processBotLogic(text);
    });
  }
  
  void _processBotLogic(String input) {
    final lowerInput = input.toLowerCase();
    
    switch (_currentStep) {
      case ChatStep.intro:
        if (lowerInput.contains('bug') || lowerInput.contains('error') || lowerInput.contains('issue')) {
          _feedbackType = 'Bug Report';
          _currentStep = ChatStep.details;
          _addBotMessage("Oh no! A bug? 😱\n\nPlease describe what happened. What were you doing when it occurred?");
        } else if (lowerInput.contains('feature') || lowerInput.contains('idea') || lowerInput.contains('request')) {
          _feedbackType = 'Feature Request';
          _currentStep = ChatStep.details;
          _addBotMessage("Ooh, a new idea! 💡\n\nTell me more! How should it work?");
        } else {
           _addBotMessage("I didn't quite catch that. Please type **Bug** or **Feature**.");
        }
        break;
        
      case ChatStep.details:
        _description = input;
        _currentStep = ChatStep.conclusion;
        _addBotMessage("Got it. Let me summarize:\n\nType: $_feedbackType\nDetails: \"$_description\"\n\nIs there anything else you want to add? (Type 'no' to finish)");
        break;
        
      case ChatStep.conclusion:
        if (lowerInput == 'no' || lowerInput.contains('send') || lowerInput.contains('ok') || lowerInput.contains('done')) {
           _currentStep = ChatStep.sent;
           _addBotMessage("Thanks! I've prepared a report for the developer. 📝\n\nTap the button below to send it via Email so he can review it!");
        } else {
           // Append to description
           _description += "\nAdditional: $input";
           _addBotMessage("Okay, added that. Ready to send? (Type 'yes' or 'send')");
        }
        break;
        
      case ChatStep.sent:
        _addBotMessage("The report is ready. Please click the button below.");
        break;
    }
  }
  
  Future<void> _sendEmail() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = "${packageInfo.version}+${packageInfo.buildNumber}";
    
    final String subject = "Fortune 14/2 Feedback: $_feedbackType";
    final String body = 
      "Generic User Feedback Report\n"
      "---------------------------\n"
      "Type: $_feedbackType\n"
      "App Version: $version\n\n"
      "User Description:\n"
      "$_description\n\n"
      "---------------------------\n"
      "Sent from In-App Chat Assistant";
      
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'developer@example.com', // User didn't provide email, use placeholder or ask user to fill
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      Navigator.of(context).pop(); // Close chat on success
    } else {
      _addBotMessage("⚠️ Could not open email client. Please copy the text above manually.");
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
                color: Color(0xFF2196F3), // Tech Blue
                borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.yellowAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Feedback Assistant',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                itemCount: _messages.length,
                itemBuilder: (context, index) {
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
            
            // Action Button (if ready)
            if (_currentStep == ChatStep.sent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Composing Email...'),
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
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: _handleInput,
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

enum ChatStep { intro, details, conclusion, sent }
