import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../data/stores/auth_store.dart';
import '../../data/api/auth_api.dart';

/// LoginPage — port of web app's LoginPage.tsx (simplified for Phase 1).
///
/// Drops: social login buttons (Google/GitHub) — they don't work on web either.
/// Keeps: email + password, remember me, forgot-password link, sign-up link.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email and password are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authApi = await ref.read(authApiProvider.future);
      final result = await authApi.login(email: email, password: password);

      if (!mounted) return;

      if (result.requires2FA) {
        // TODO: Navigate to 2FA verification page
        context.go('/login?msg=2fa-required');
        return;
      }

      if (result.isSuccess) {
        // Trigger device binding right after login
        await ref.read(authProvider.notifier).onLoginSuccess(
          token: result.token!,
          user: result.user!,
        );
        // Router redirect will send to /app/home
        if (mounted) context.go('/app/home');
      } else {
        setState(() => _error = result.error ?? 'Invalid email or password');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [DakkhoColors.bgDark, DakkhoColors.bgDarker]
                : [DakkhoColors.bgLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Logo + Title ───
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: DakkhoColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: DakkhoColors.primary.withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 40),
                  )
                      .animate()
                      .fadeIn(duration: DakkhoAnimations.slow)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: DakkhoAnimations.slow,
                        curve: DakkhoAnimations.elastic,
                      ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontFamilyFallback: ['NotoSansBengali', 'Roboto'],
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: DakkhoColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: DakkhoAnimations.normal, duration: DakkhoAnimations.normal)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to continue learning',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontFamilyFallback: ['NotoSansBengali', 'Roboto'],
                      fontSize: 14,
                      color: DakkhoColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: DakkhoAnimations.slow, duration: DakkhoAnimations.normal)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // ─── Login Form ───
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: DakkhoColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(LucideIcons.mail, size: 18),
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: DakkhoAnimations.normal).slideX(begin: -0.1, end: 0),

                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          style: const TextStyle(color: DakkhoColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(LucideIcons.lock, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: DakkhoAnimations.normal).slideX(begin: -0.1, end: 0),

                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            child: const Text('Forgot password?'),
                          ),
                        ),

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: DakkhoColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: DakkhoColors.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertCircle, color: DakkhoColors.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: DakkhoColors.danger,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().shake(delay: 0.ms).fadeIn(),
                        ],

                        const SizedBox(height: 24),

                        // Sign In button
                        GradientButton(
                          label: 'Sign In',
                          icon: LucideIcons.logIn,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ).animate().fadeIn(delay: 600.ms, duration: DakkhoAnimations.normal).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: DakkhoAnimations.slow)
                      .slideY(begin: 0.3, end: 0, curve: DakkhoAnimations.easeOut),

                  const SizedBox(height: 24),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: DakkhoColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: DakkhoAnimations.normal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
