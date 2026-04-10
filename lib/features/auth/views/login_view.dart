import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/core/widgets/auth_footer_divider.dart';
import 'package:instructor_beats_admin/core/widgets/primary_button.dart';
import 'package:instructor_beats_admin/features/auth/controllers/auth_controller.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';
import 'package:instructor_beats_admin/theme/app_theme.dart';

/// MVC: View — admin login (dark theme aligned with admin shell).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Builder(
        builder: (context) {
          final auth = Get.find<AuthController>();
          final scheme = Theme.of(context).colorScheme;
          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return Scaffold(
            appBar: AppBar(
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Get.back<void>(),
                    )
                  : const SizedBox.shrink(),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, c) {
                  const maxW = 440.0;
                  final w = c.maxWidth > maxW ? maxW : c.maxWidth;
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              label: 'Instructor Beats logo',
                              image: true,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 88,
                                    fit: BoxFit.fitHeight,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(
                                      Icons.admin_panel_settings_outlined,
                                      size: 72,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to manage Instructor Beats — playlists, songs, and users.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AppLabeledField(
                                        label: 'Email',
                                        controller: _email,
                                        hint: 'your@email.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        prefixIcon: Icons.mail_outline_rounded,
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                      const SizedBox(height: 18),
                                      AppLabeledField(
                                        label: 'Password',
                                        controller: _password,
                                        hint: 'Enter your password',
                                        obscureText: true,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        validator: (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => Get.toNamed<void>(
                                            AppRoutes.forgotPassword,
                                          ),
                                          child: const Text('Forgot password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(
                                        () => PrimaryButton(
                                          label: 'Log in',
                                          isLoading: auth.isBusy.value,
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                    ?.validate() !=
                                                true) {
                                              return;
                                            }
                                            await auth.login(
                                              email: _email.text,
                                              password: _password.text,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            const AuthFooterDivider(),
                            const SizedBox(height: 18),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                  children: [
                                    const TextSpan(
                                      text: "Don't have an account? ",
                                    ),
                                    TextSpan(
                                      text: 'Sign up',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.snackbar(
                                            'Sign-up isn’t here',
                                            'New members join through the main Instructor Beats app. This panel is for admins only.',
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24 + bottomInset),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
