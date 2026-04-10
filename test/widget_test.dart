import 'package:flutter_test/flutter_test.dart';
import 'package:instructor_beats_admin/main.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const InstructorBeatsAdminApp(initialRoute: AppRoutes.login),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
