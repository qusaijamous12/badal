import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home_page.dart';
import 'auth_controller.dart';
import 'welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      if (!auth.isReady.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return auth.user.value == null ? const WelcomePage() : const HomePage();
    });
  }
}
