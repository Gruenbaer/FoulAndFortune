import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foulandfortune/widgets/ball_button.dart';

void main() {
  testWidgets('BallButton fills its rack constraints', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: BallButton(
                ballNumber: 1,
                isActive: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.width, 120);
    expect(image.height, 120);
  });
}
