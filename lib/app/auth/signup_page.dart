import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = Get.find<AuthController>();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final error = await _auth.createAccount(
      _name.text,
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'لنبدأ التغيير 🌿',
      subtitle: 'أنشئ حسابك وامنح أغراضك فرصة جديدة.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('الاسم الكامل'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                hintText: 'كيف نناديك؟',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? 'أدخل اسمًا من حرفين على الأقل'
                  : null,
            ),
            const SizedBox(height: 18),
            const FieldLabel('البريد الإلكتروني'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 18),
            const FieldLabel('كلمة المرور'),
            Obx(
              () => TextFormField(
                controller: _password,
                obscureText: !_auth.passwordVisible.value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  hintText: '8 أحرف على الأقل',
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
                validator: (value) => value == null || value.length < 8
                    ? 'استخدم 8 أحرف على الأقل'
                    : null,
              ),
            ),
            const SizedBox(height: 18),
            const FieldLabel('تأكيد كلمة المرور'),
            Obx(
              () => TextFormField(
                controller: _confirm,
                obscureText: !_auth.passwordVisible.value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(
                  hintText: 'أعد كتابة كلمة المرور',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (value) => value != _password.text
                    ? 'كلمتا المرور غير متطابقتين'
                    : null,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 18),
              AuthNotice(_error!),
            ],
            const SizedBox(height: 28),
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
                    : const Text('إنشاء حساب'),
              ),
            ),
            const SizedBox(height: 15),
            const Center(
              child: Text(
                'بانضمامك إلى بدل، أنت تختار أسلوبًا أكثر استدامة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: BadalColors.muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'لديك حساب؟',
                  style: TextStyle(color: BadalColors.muted),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: const Text('سجّل الدخول'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
