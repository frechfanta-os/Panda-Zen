import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panda_zen/app/app.dart';

void main() {
  testWidgets('PandaZenApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PandaZenApp(),
      ),
    );

    // Initial frame builds splash screen
    expect(find.text('Panda Zen'), findsOneWidget);
  });
}
