import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();
  String? _notice;
  bool _success = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _notice = null);
    final error = await _auth.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _notice = error;
        _success = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() {
        _notice = 'أدخل بريدك الإلكتروني أولًا لاستعادة كلمة المرور.';
        _success = false;
      });
      return;
    }
    final error = await _auth.resetPassword(_email.text);
    if (!mounted) return;
    setState(() {
      _notice =
          error ?? 'أرسلنا رابط استعادة كلمة المرور إلى بريدك الإلكتروني.';
      _success = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'أهلًا بعودتك 👋',
      subtitle: 'سجّل دخولك لتكمل رحلة التبادل.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('البريد الإلكتروني'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) =>
                  value == null ||
                      !RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(value.trim())
                  ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                  : null,
            ),
            const SizedBox(height: 22),
            const FieldLabel('كلمة المرور'),
            Obx(
              () => TextFormField(
                controller: _password,
                obscureText: !_auth.passwordVisible.value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _auth.passwordVisible.value
                        ? 'إخفاء كلمة المرور'
                        : 'إظهار كلمة المرور',
                    onPressed: () => _auth.passwordVisible.toggle(),
                    icon: Icon(
                      _auth.passwordVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'أدخل كلمة المرور' : null,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ),
            if (_notice != null) ...[
              const SizedBox(height: 6),
              AuthNotice(_notice!, success: _success),
            ],
            const SizedBox(height: 25),
            Obx(
              () => ElevatedButton(
                onPressed: _auth.isBusy.value ? null : _submit,
                child: _auth.isBusy.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تسجيل الدخول'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'جديد في بدل؟',
                  style: TextStyle(color: BadalColors.muted),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  ),
                  child: const Text('أنشئ حسابًا'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
