import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const/app_colors.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/snackbar_utils.dart';
import '../utils/widgets_utils.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(
        context,
        'Missing Data',
        'Please complete all required identity parameters.',
      );
      return;
    }

    if (password != confirm) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(
        context,
        'Crossover Error',
        'Verification signature must match the original password.',
      );
      return;
    }

    if (password.length < 6) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(
        context,
        'Security Breach',
        'Encryption code must be at least 6 characters long.',
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(authServiceProvider)
          .signUpWithEmailPassword(name, email, password);
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Access Granted',
          'Your new identity has been registered in the system.',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Registration Failed', e.toString());
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: PlatformBackButton(color: textColor),
          ),
          title: Text(
            'New Identity',
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: isSmallScreen ? 18 : 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Join the Pulse',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 32 : 38,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                      'Register your unique credentials to access the full potential of productivity and task automation.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: mutedTextColor,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                SizedBox(height: size.height * 0.04),

                _buildInputField(
                  label: 'FULL IDENTIFIER',
                  hint: 'Enter your preferred name',
                  controller: _nameController,
                  focusNode: _nameFocus,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  textColor: textColor,
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                _buildInputField(
                  label: 'RECOVERY IDENTIFIER',
                  hint: 'Enter your verified email',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.alternate_email_rounded,
                  isDark: isDark,
                  textColor: textColor,
                ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                _buildInputField(
                  label: 'SECURE ENCRYPTION',
                  hint: 'Create a resilient password',
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onSuffixIconTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  isDark: isDark,
                  textColor: textColor,
                ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                _buildInputField(
                  label: 'RE-VERIFICATION',
                  hint: 'Confirm your encryption code',
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  icon: Icons.verified_user_outlined,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onSuffixIconTap: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  isDark: isDark,
                  textColor: textColor,
                ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.1, end: 0),

                SizedBox(height: size.height * 0.05),

                SizedBox(
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
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Initialize Identity',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 30),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Existing Identity? ',
                        style: GoogleFonts.plusJakartaSans(
                          color: mutedTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
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
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onSuffixIconTap?.call();
                      },
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: focusNode.hasFocus
                            ? AppColors.primaryBlue
                            : AppColors.textLight.withValues(alpha: 0.5),
                        size: 20,
                      ),
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
}
