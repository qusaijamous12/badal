import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/auth/auth_controller.dart';
import 'app/auth/auth_gate.dart';
import 'app/theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  runApp(const BadalApp());
}

class BadalApp extends StatelessWidget {
  const BadalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'بدل | Badal',
      debugShowCheckedModeBanner: false,
      theme: BadalTheme.light,
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AuthGate(),
    );
  }
}
