import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:absensi_king_royal/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('renders home screen content', (WidgetTester tester) async {
    await tester.pumpWidget(const AbsensiKingRoyalApp());

    expect(find.text('Absensi King Royal'), findsOneWidget);
    expect(find.text('Hotel King Royal'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);
    expect(find.text('Check Out'), findsOneWidget);
    expect(find.text('Belum Check In'), findsOneWidget);
  });

  testWidgets('check in updates status and enables check out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AbsensiKingRoyalApp());

    await tester.tap(find.text('Check In'));
    await tester.pump();

    expect(find.text('Sudah Check In'), findsOneWidget);
    expect(find.textContaining('Check In'), findsWidgets);
  });
}
