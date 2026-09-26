import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  StreamSubscription<User?>? _subscription;
  final user = Rxn<User>();
  final isReady = false.obs;
  final isBusy = false.obs;
  final passwordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = _auth.authStateChanges().listen((currentUser) {
      user.value = currentUser;
      isReady.value = true;
    });
  }

  Future<String?> signIn(String email, String password) async {
    return _run(() async {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<String?> createAccount(
    String name,
    String email,
    String password,
  ) async {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      try {
        await credential.user?.updateDisplayName(name.trim());
        await credential.user?.reload();
      } catch (_) {
        // The account exists even if the optional display name could not sync.
      }
      user.value = _auth.currentUser;
    });
  }

  Future<String?> resetPassword(String email) async {
    return _run(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  Future<String?> signOut() async => _run(_auth.signOut);

  Future<String?> _run(Future<void> Function() action) async {
    if (isBusy.value) return 'هناك عملية جارية. انتظر قليلًا.';
    isBusy.value = true;
    try {
      await action();
      return null;
    } on FirebaseAuthException catch (error) {
      return _messageFor(error.code);
    } catch (_) {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    } finally {
      isBusy.value = false;
    }
  }

  String _messageFor(String code) => switch (code) {
    'invalid-email' => 'البريد الإلكتروني غير صحيح.',
    'email-already-in-use' => 'هذا البريد الإلكتروني مستخدم بالفعل.',
    'weak-password' => 'كلمة المرور ضعيفة. اختر كلمة أقوى.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'too-many-requests' => 'محاولات كثيرة. انتظر قليلًا ثم أعد المحاولة.',
    'network-request-failed' => 'تعذر الاتصال بالإنترنت. تحقق من اتصالك.',
    'operation-not-allowed' =>
      'تسجيل الدخول بالبريد الإلكتروني غير مفعّل في Firebase.',
    _ => 'تعذر إكمال العملية. حاول مرة أخرى.',
  };

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
