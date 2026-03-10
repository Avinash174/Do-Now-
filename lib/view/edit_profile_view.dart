import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
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
  final _nameFocus = FocusNode();
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
      } else {
        _nameController.text = user?.displayName ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Image Source',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Error', 'Name cannot be empty');
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      // Update name
      await ref
          .read(databaseServiceProvider)
          .updateUserName(user.uid, _nameController.text.trim());

      // If image was selected, upload it
      if (_selectedImage != null) {
        final profileService = ref.read(databaseServiceProvider);
        await profileService.uploadProfilePhoto(user.uid, _selectedImage!);
        SnackbarUtils.showSuccess(
          context,
          'Success',
          'Profile and photo updated successfully',
        );
      } else {
        SnackbarUtils.showSuccess(
          context,
          'Success',
          'Profile updated successfully',
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Error',
          'Failed to update profile: $e',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: PlatformBackButton(
          color:
              Theme.of(context).textTheme.bodyLarge?.color ??
              AppColors.textDark,
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: 24,
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    userAsync.when(
                      data: (profile) {
                        final photoUrl = profile?['photoUrl'];
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: size.width * 0.15,
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null),
                            child: _selectedImage == null && photoUrl == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: size.width * 0.15,
                                    color: AppColors.primaryBlue,
                                  )
                                : null,
                          ),
                        );
                      },
                      loading: () => ShimmerLoading(
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        borderRadius: 100,
                      ),
                      error: (err, _) => const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.danger,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 16 : 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),

              // Name Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FULL NAME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLight,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _nameFocus.hasFocus
                          ? theme.cardColor
                          : theme.cardColor.withValues(
                              alpha: isDark ? 0.3 : 0.5,
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _nameFocus.hasFocus
                            ? AppColors.primaryBlue
                            : theme.dividerColor.withValues(
                                alpha: isDark ? 0.3 : 0.1,
                              ),
                        width: _nameFocus.hasFocus ? 1.5 : 1.0,
                      ),
                      boxShadow: _nameFocus.hasFocus
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: AppColors.textLight.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.1),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    elevation: 8,
                    shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const ShimmerLoading(
                          width: double.infinity,
                          height: 60,
                          borderRadius: 20,
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
