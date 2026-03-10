import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/widgets_utils.dart';
import '../utils/snackbar_utils.dart';

import '../const/app_colors.dart';
import '../services/auth_service.dart';

class ForgetPasswordView extends ConsumerStatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  ConsumerState<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends ConsumerState<ForgetPasswordView> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(
        context,
        'Missing Email',
        'Please provide your registered email address.',
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Transmission Sent',
          'Password reset instructions have been dispatched to your inbox.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'System Error', e.toString());
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
            'Security Recovery',
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
                const SizedBox(height: 40),
                Text(
                  'Lost Access?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmallScreen ? 32 : 38,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                Text(
                      'Initiate a secure password reset. We\'ll transmit a verified recovery link to your registered identification.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: mutedTextColor,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                SizedBox(height: size.height * 0.06),

                _buildInputField(
                  label: 'RECOVERY IDENTIFIER',
                  hint: 'Enter your registered email',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  icon: Icons.alternate_email_rounded,
                  isDark: isDark,
                  textColor: textColor,
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),

                SizedBox(height: size.height * 0.06),

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
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Dispatch Recovery Link',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

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
