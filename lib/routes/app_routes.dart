import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/login_view.dart';
import '../view/signup_view.dart';
import '../view/home_view.dart';
import '../view/new_task_view.dart';
import '../view/splash_view.dart';
import '../view/introduction_view.dart';
import '../view/forget_password_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String introduction = '/introduction';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPassword = '/forget-password';
  static const String home = '/home';
  static const String newTask = '/new_task';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashView(),
    introduction: (context) => const IntroductionView(),
    login: (context) => const LoginView(),
    signup: (context) => const SignupView(),
    forgetPassword: (context) => const ForgetPasswordView(),
    home: (context) => const HomeView(),
    newTask: (context) => const NewTaskView(),
  };

  static Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    if (!onboardingSeen) {
      return introduction;
    }
    return login;
  }
}
