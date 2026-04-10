// Phase 2: replace mock [AdminRepository] / [AuthController] with Firebase Auth,
// Firestore, Storage, and Stripe webhooks + HTTPS callable actions.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instructor_beats_admin/core/initial_session.dart';
import 'package:instructor_beats_admin/routes/app_pages.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';
import 'package:instructor_beats_admin/routes/initial_binding.dart';
import 'package:instructor_beats_admin/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await InitialSession.resolve();
  runApp(InstructorBeatsAdminApp(
    initialRoute: InitialSession.startAsAdminSession
        ? AppRoutes.admin
        : AppRoutes.login,
  ));
}

class InstructorBeatsAdminApp extends StatelessWidget {
  const InstructorBeatsAdminApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Instructor Beats · Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
