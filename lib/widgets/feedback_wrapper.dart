import 'package:flutter/material.dart';
import 'feedback_chat_dialog.dart';

class FeedbackWrapper extends StatelessWidget {
  final Widget? child; // Nullable for builder
  
  const FeedbackWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        
        // Floating Light Bulb (Top Right or Bottom Right?)
        // User said "add a light bulb button on all screens"
        // Let's put it in a non-obtrusive spot, maybe top right under AppBar area or floating bottom left?
        // FAB is usually bottom right. Let's do a custom position.
        Positioned(
          right: 16,
          bottom: 100, // Above FABs usually
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const FeedbackChatDialog(),
                );
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
