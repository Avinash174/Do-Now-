import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../view/login_view.dart';
import '../view/signup_view.dart';
import '../view/home_view.dart';
import '../view/new_task_view.dart';
import '../view/splash_view.dart';
import '../view/introduction_view.dart';
import '../view/forget_password_view.dart';
import '../view/edit_profile_view.dart';
import '../view/notifications_view.dart';
import '../view/security_privacy_view.dart';
import '../view/help_center_view.dart';
import '../view/help_topic_details_view.dart';
import '../view/support_chat_view.dart';
import '../view/about_view.dart';
import '../view/change_password_view.dart';
import '../view/two_factor_auth_view.dart';
import '../view/profile_visibility_view.dart';
import '../view/privacy_policy_view.dart';
import '../model/task_model.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String introduction = '/introduction';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPassword = '/forget-password';
  static const String home = '/home';
  static const String newTask = '/new_task';
  static const String editProfile = '/edit_profile';
  static const String notifications = '/notifications';
  static const String security = '/security';
  static const String changePassword = '/change_password';
  static const String twoFactorAuth = '/two_factor_auth';
  static const String profileVisibility = '/profile_visibility';
  static const String privacyPolicy = '/privacy_policy';
  static const String helpCenter = '/help_center';
  static const String helpTopicDetails = '/help_topic_details';
  static const String supportChat = '/support_chat';
  static const String about = '/about';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashView(),
    introduction: (context) => const IntroductionView(),
    login: (context) => const LoginView(),
    signup: (context) => const SignupView(),
    forgetPassword: (context) => const ForgetPasswordView(),
    home: (context) => const HomeView(),
    newTask: (context) => const NewTaskView(),
    editProfile: (context) => const EditProfileView(),
    notifications: (context) => const NotificationsView(),
    security: (context) => const SecurityPrivacyView(),
    changePassword: (context) => const ChangePasswordView(),
    twoFactorAuth: (context) => const TwoFactorAuthView(),
    profileVisibility: (context) => const ProfileVisibilityView(),
    privacyPolicy: (context) => const PrivacyPolicyView(),
    helpCenter: (context) => const HelpCenterView(),
    supportChat: (context) => const SupportChatView(),
    about: (context) => const AboutView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle routes with arguments
    switch (settings.name) {
      case helpTopicDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              HelpTopicDetailsView(
                title: args?['title'] ?? 'Help Topic',
                topic: args?['topic'] ?? '',
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve));
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve));
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(position: slideAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      case newTask:
        final task = settings.arguments as TaskModel?;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              NewTaskView(task: task),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve));
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: curve));
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(position: slideAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
        );
      default:
        break;
    }

    // Handle regular routes
    final builder = routes[settings.name];
    if (builder != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeOutCubic;

          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          var slideAnimation = Tween<Offset>(
            begin: const Offset(0.05, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      );
    }

    // Fallback route
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }

  static Future<String> getInitialRoute() async {
    dev.log('AppRoutes: Calculating initial route...', name: 'navigation');
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

      if (!onboardingSeen) {
        dev.log(
          'AppRoutes: Onboarding not seen, going to introduction',
          name: 'navigation',
        );
        return introduction;
      }

      // Check if user is already logged in (Check both Firebase and local session)
      final user = FirebaseAuth.instance.currentUser;
      final localSessionId = prefs.getString('user_session_id');

      if (user != null || localSessionId != null) {
        dev.log(
          'AppRoutes: Session found (Firebase: ${user?.uid}, Local: $localSessionId), going to home',
          name: 'navigation',
        );
        return home;
      }

      dev.log(
        'AppRoutes: No active session, going to login',
        name: 'navigation',
      );
      return login;
    } catch (e) {
      dev.log(
        'AppRoutes: Error in getInitialRoute: $e',
        name: 'navigation',
        error: e,
      );
      return login;
    }
  }
}
