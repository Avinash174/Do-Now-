import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/app_colors.dart';
import '../utils/widgets_utils.dart';

class LegalView extends StatelessWidget {
  final String title;
  final String content;

  const LegalView({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: PlatformBackButton(
          color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.bodyLarge?.color ?? AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: theme.textTheme.bodyMedium?.color ?? AppColors.textLight,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class LegalTexts {
  static const String termsOfService = """
Terms of Service

1. Introduction
Welcome to Do Now. By using our application, you agree to these terms. Please read them carefully.

2. Using our Services
You must follow any policies made available to you within the Services. Don't misuse our Services. For example, don't interfere with our Services or try to access them using a method other than the interface and the instructions that we provide.

3. Privacy Protection
Do Now's privacy policies explain how we treat your personal data and protect your privacy when you use our Services. By using our Services, you agree that Do Now can use such data in accordance with our privacy policies.

4. Your Content in our Services
Our Services allow you to upload, submit, store, send or receive content. You retain ownership of any intellectual property rights that you hold in that content. In short, what belongs to you stays yours.

5. Modifying and Terminating our Services
We are constantly changing and improving our Services. We may add or remove functionalities or features, and we may suspend or stop a Service altogether.

6. Our Warranties and Disclaimers
We provide our Services using a commercially reasonable level of skill and care and we hope that you will enjoy using them. But there are certain things that we don't promise about our Services.
""";

  static const String privacyPolicy = """
Privacy Policy

Last Updated: March 2026

1. Information We Collect
We collect information to provide better services to all our users.
- Information you give us: For example, your app account information, tasks, and preferences.
- Device information: We collect device-specific information (such as your hardware model, operating system version).

2. How We Use Information We Collect
We use the information we collect from all of our services to provide, maintain, protect and improve them, to develop new ones, and to protect Do Now and our users.

3. Transparency and Choice
People have different privacy concerns. Our goal is to be clear about what information we collect, so that you can make meaningful choices about how it is used.

4. Information You Share
Our Services may let you share information with others. Remember that when you share information publicly, it may be indexable by search engines.

5. Information Security
We work hard to protect Do Now and our users from unauthorized access to or unauthorized alteration, disclosure or destruction of information we hold.

6. When This Privacy Policy Applies
Our Privacy Policy applies to all of the services offered by Do Now Inc. and its affiliates.
""";
}
