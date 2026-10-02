import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panel/main.dart';

void main() {
  testWidgets('AdminPanel renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AdminPanel(),
      ),
    );

    expect(find.text('nBhumi Admin'), findsOneWidget);
    expect(find.text('nBhumi Admin Panel'), findsOneWidget);
  });
}
