import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../const/app_colors.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_utils.dart';
import '../utils/shimmer_utils.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailPassword(email, password);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }
      _showSnackBar(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    AppUtils.showSnackBar(context, msg, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.05),
                _buildLogo(size),
                const SizedBox(height: 32),
                _buildWelcomeText(isSmallScreen),
                SizedBox(height: size.height * 0.06),

                _buildInputField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isSmallScreen: isSmallScreen,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                _buildInputField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  isSmallScreen: isSmallScreen,
                  onSuffixIconTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

                _buildForgotPassword(isSmallScreen),

                SizedBox(height: size.height * 0.05),

                _buildLoginButton(size, isSmallScreen),

                const SizedBox(height: 32),

                _buildDivider(isSmallScreen),

                const SizedBox(height: 32),

                _buildSocialLogins(isSmallScreen),

                SizedBox(height: size.height * 0.06),

                _buildSignUpLink(isSmallScreen),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: size.width * 0.14,
              height: size.width * 0.14,
            ),
          ),
        )
        .animate()
        .scale(duration: 500.ms, curve: Curves.easeOutBack)
        .rotate(begin: -0.1, end: 0);
  }

  Widget _buildWelcomeText(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign In',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 28 : 34,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Please enter your details.',
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconTap,
    TextInputType? keyboardType,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      onPressed: onSuffixIconTap,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.05),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
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
        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgetPassword),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0),
        ),
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildLoginButton(Size size, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 56 : 60,
      child: _isLoading
          ? ShimmerLoading(
              width: double.infinity,
              height: isSmallScreen ? 56 : 60,
              borderRadius: 18,
            )
          : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                elevation: 8,
                shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDivider(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 12 : 13,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildSocialLogins(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            'Google',
            'assets/images/google_logo.png',
            () {},
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            'Apple',
            '',
            () {},
            useIcon: true,
            icon: Icons.apple_rounded,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSocialButton(
    String label,
    String imagePath,
    VoidCallback onTap, {
    bool useIcon = false,
    IconData? icon,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: isSmallScreen ? 50 : 56,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useIcon)
              Icon(icon, size: isSmallScreen ? 20 : 24)
            else
              Image.asset(imagePath, width: 20, height: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmallScreen ? 13 : 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
          child: Text(
            'Sign Up',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmallScreen ? 13 : 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms);
  }
}
