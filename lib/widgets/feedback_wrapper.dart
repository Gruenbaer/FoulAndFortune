import 'package:flutter/material.dart';
import 'feedback_chat_dialog.dart';

class FeedbackWrapper extends StatefulWidget {
  final Widget? child;
  final GlobalKey<NavigatorState> navigatorKey;
  
  const FeedbackWrapper({super.key, required this.child, required this.navigatorKey});

  @override
  State<FeedbackWrapper> createState() => _FeedbackWrapperState();
}

class _FeedbackWrapperState extends State<FeedbackWrapper> {
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        
        // Floating Light Bulb (Hidden when chat is open)
        if (!_isChatOpen)
          Positioned(
            right: 16,
            bottom: 100, // Above FABs usually
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (widget.navigatorKey.currentState != null) {
                    setState(() => _isChatOpen = true);
                    await showDialog(
                      context: widget.navigatorKey.currentContext!,
                      builder: (context) => const FeedbackChatDialog(),
                    );
                    if (mounted) {
                      setState(() => _isChatOpen = false);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700, // Light Bulb color
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
