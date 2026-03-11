import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/snackbar_utils.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(
        context,
        'Missing Fields',
        'Please fill in all authentication details.',
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailPassword(email, password);
      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      String errorMessage = 'Authentication failed';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      if (mounted) {
        SnackbarUtils.showError(context, 'Login Error', errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedTextColor = isDark ? Colors.white70 : AppColors.textLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.04),
                _buildLogo(size),
                const SizedBox(height: 32),
                _buildWelcomeText(isSmallScreen, textColor, mutedTextColor),
                SizedBox(height: size.height * 0.06),

                _buildInputField(
                  label: 'IDENTITY GATEWAY',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  textColor: textColor,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                _buildInputField(
                  label: 'SECURE KEY',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  icon: Icons.lock_open_rounded,
                  isPassword: true,
                  isDark: isDark,
                  textColor: textColor,
                  obscureText: _obscurePassword,
                  onSuffixIconTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

                _buildForgotPassword(isSmallScreen),

                SizedBox(height: size.height * 0.05),

                _buildLoginButton(size, isSmallScreen),

                SizedBox(height: size.height * 0.06),

                _buildSignUpLink(isSmallScreen, mutedTextColor),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(
                    alpha: isDark ? 0.2 : 0.12,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: size.width * 0.16,
              height: size.width * 0.16,
            ),
          ),
        )
        .animate()
        .scale(duration: 700.ms, curve: Curves.easeOutBack)
        .rotate(begin: -0.1, end: 0);
  }

  Widget _buildWelcomeText(
    bool isSmallScreen,
    Color textColor,
    Color mutedTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Digital Access',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 28 : 34,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome back. Provide your credentials to synchronize with your workspace.',
          style: GoogleFonts.plusJakartaSans(
            color: mutedTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconTap,
    TextInputType? keyboardType,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
              letterSpacing: 1.5,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: focusNode.hasFocus
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02))
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: focusNode.hasFocus
                  ? AppColors.primaryBlue
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05)),
              width: focusNode.hasFocus ? 2 : 1.5,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.textLight.withValues(alpha: 0.4),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus
                    ? AppColors.primaryBlue
                    : AppColors.textLight.withValues(alpha: 0.5),
                size: 22,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: focusNode.hasFocus
                            ? AppColors.primaryBlue
                            : AppColors.textLight.withValues(alpha: 0.5),
                        size: 22,
                      ),
                      onPressed: onSuffixIconTap,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(bool isSmallScreen) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, AppRoutes.forgetPassword);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Recovery Access?',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 13 : 14,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildLoginButton(Size size, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 3,
              ),
            )
          : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Authorize Entry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSignUpLink(bool isSmallScreen, Color mutedTextColor) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to the platform? ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: mutedTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.signup);
            },
            child: Text(
              'Register Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }
}
