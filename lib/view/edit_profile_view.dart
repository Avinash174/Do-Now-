import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

import '../const/app_colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/snackbar_utils.dart';
import '../utils/widgets_utils.dart';
import '../utils/shimmer_utils.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));

    // Load current name from provider
    Future.microtask(() {
      final profile = ref.read(userProfileProvider).value;
      final user = ref.read(authStateProvider).value;
      if (profile != null) {
        _nameController.text = profile['name'] ?? user?.displayName ?? '';
        _emailController.text = profile['email'] ?? user?.email ?? '';
      } else {
        _nameController.text = user?.displayName ?? '';
        _emailController.text = user?.email ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.mediumImpact();
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error', 'Failed to pick image: $e');
      }
    }
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Update Profile Media',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSourceOption(
                  context,
                  Icons.camera_alt_rounded,
                  'Capture from Camera',
                  () => _pickImage(ImageSource.camera),
                  AppColors.primaryBlue,
                ),
                const SizedBox(height: 12),
                _buildSourceOption(
                  context,
                  Icons.photo_library_rounded,
                  'Choose from Gallery',
                  () => _pickImage(ImageSource.gallery),
                  AppColors.primaryAccent,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? Colors.white38
                  : AppColors.textLight.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      SnackbarUtils.showError(context, 'Error', 'Name cannot be empty');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final currentName = ref.read(userProfileProvider).value?['name'];
      final currentEmail = ref.read(userProfileProvider).value?['email'];
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();

      bool nameChanged = newName != currentName;
      bool emailChanged = newEmail != currentEmail;

      // Update name if changed
      if (nameChanged) {
        await ref
            .read(databaseServiceProvider)
            .updateUserName(user.uid, newName);
      }

      // Update email if changed
      if (emailChanged) {
        await ref.read(authServiceProvider).updateEmail(newEmail);
        await ref
            .read(databaseServiceProvider)
            .updateUserEmail(user.uid, newEmail);
      }

      // If image was selected, upload it
      if (_selectedImage != null) {
        final profileService = ref.read(databaseServiceProvider);
        await profileService.uploadProfilePhoto(user.uid, _selectedImage!);
      }

      if (mounted) {
        String message = 'Your profile information has been synchronized.';
        if (emailChanged) {
          message += '\nA verification link has been sent to your new email.';
        }
        SnackbarUtils.showSuccess(
          context,
          'Profile Updated',
          message,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      dev.log('EditProfileView: Error updating profile: $e', name: 'view', error: e);
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.split('Exception:').last.trim();
        }
        SnackbarUtils.showError(
          context,
          'Operation Failed',
          errorMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final userAsync = ref.watch(userProfileProvider);
    final isDark = theme.brightness == Brightness.dark;

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
            'Personal Information',
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
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      userAsync.when(
                        data: (profile) {
                          final photoUrl = profile?['photoUrl'];
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: isDark ? 0.2 : 0.1,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: 'profile_pic',
                              child: CircleAvatar(
                                radius: size.width * 0.18,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.05),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (photoUrl != null
                                          ? NetworkImage(photoUrl)
                                          : null),
                                child:
                                    _selectedImage == null && photoUrl == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: size.width * 0.18,
                                        color: AppColors.primaryBlue.withValues(
                                          alpha: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ).animate().scale(
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          );
                        },
                        loading: () => ShimmerLoading(
                          width: size.width * 0.4,
                          height: size.width * 0.4,
                          borderRadius: 100,
                        ),
                        error: (err, _) => Container(
                          width: size.width * 0.4,
                          height: size.width * 0.4,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child:
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showImageSourceDialog();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_enhance_rounded,
                                  color: Colors.white,
                                  size: isSmallScreen ? 18 : 22,
                                ),
                              ),
                            ).animate().scale(
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Inputs Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.04,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FULL IDENTIFICATION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hint: 'Your official name',
                        icon: Icons.badge_rounded,
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hint: 'Email address',
                        icon: Icons.email_rounded,
                        isDark: isDark,
                        textColor: textColor,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Synchronize Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                Text(
                  'This information is visible to other users\ndepending on your privacy settings.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: mutedTextColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    TextInputType? keyboardType,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: focusNode.hasFocus
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.primaryBlue
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05)),
          width: focusNode.hasFocus ? 2 : 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus
                ? AppColors.primaryBlue
                : AppColors.textLight.withValues(alpha: 0.5),
            size: 22,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textLight.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
