import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonya/main.dart';
import 'package:sonya/models/work_entry.dart';
import 'package:sonya/providers/app_provider.dart';

void main() {
  test('WorkEntry billing calculation works accurately', () {
    final total = WorkEntry.calculateTotal(
      quantityTons: 12.5,
      ratePerTon: 1200,
      additionalCharges: 500,
      discount: 200,
    );
    expect(total, 15300);

    final remaining = WorkEntry.calculateRemaining(
      totalAmount: total,
      receivedAmount: 5000,
    );
    expect(remaining, 10300);
  });

  testWidgets('MurghasBusinessApp renders Dashboard and bottom navigation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appProvider = AppProvider();
    await appProvider.load();

    await tester.pumpWidget(MurghasBusinessApp(appProvider: appProvider));
    await tester.pump();

    expect(find.text('मुख्यपृष्ठ'), findsOneWidget);
    expect(find.text('ग्राहक'), findsOneWidget);
    expect(find.text('काम'), findsOneWidget);
    expect(find.text('पेमेंट्स'), findsOneWidget);
    expect(find.text('अधिक'), findsOneWidget);
  });
}
