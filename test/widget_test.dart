import 'package:flutter_test/flutter_test.dart';
import 'package:craftmitra/main.dart';

void main() {
  testWidgets('CraftMitra smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CraftMitraApp());
    expect(find.byType(CraftMitraApp), findsOneWidget);
  });
}
