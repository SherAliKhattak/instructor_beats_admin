import 'package:flutter_test/flutter_test.dart';
import 'package:instructor_beats_admin/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InstructorBeatsAdminApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
