import 'package:flutter_test/flutter_test.dart';
import 'package:daily_flow/main.dart';

void main() {
  testWidgets('DailyFlow app launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyFlowApp());
    expect(find.text('DailyFlow'), findsOneWidget);
  });
}
