import 'package:flutter_test/flutter_test.dart';

import 'package:caneandtender/main.dart';

void main() {
  testWidgets('App launches without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CaneAndTenderApp());

    // Just verify app builds
    expect(find.byType(CaneAndTenderApp), findsOneWidget);
  });
}
