import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notenest_ai/features/home/presentation/screens/home_screen.dart';
import 'package:notenest_ai/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets(
      'SplashScreen renders splash_screen_v2.png and navigates to HomeScreen after 1.5s',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify Image asset widget is rendered with BoxFit.cover
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.fit, BoxFit.cover);
    expect(
      (imageWidget.image as AssetImage).assetName,
      'assets/images/splash_screen_v2.png',
    );

    // Advance timer by 1.5 seconds (1500 ms) and pump transitions
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify navigation to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
