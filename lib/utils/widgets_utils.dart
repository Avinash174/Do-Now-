import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Platform-independent back button that uses the appropriate icon
/// for the current platform (iOS uses arrow_back_ios_new, others use arrow_back)
class PlatformBackButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onPressed;

  const PlatformBackButton({
    super.key,
    this.color = Colors.black,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
        color: color,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
