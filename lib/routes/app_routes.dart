import 'package:flutter/material.dart';

import '../view/login_view.dart';
import '../view/signup_view.dart';
import '../view/home_view.dart';
import '../view/new_task_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String newTask = '/new_task';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginView(),
    signup: (context) => const SignupView(),
    home: (context) => const HomeView(),
    newTask: (context) => const NewTaskView(),
  };
}
