import 'package:flutter/material.dart';

import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: .16)
                : BadalColors.forest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'بدل',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: light ? Colors.white : BadalColors.forest,
          ),
        ),
      ],
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: BadalColors.mint,
                      foregroundColor: BadalColors.forest,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const BrandMark(),
                  const SizedBox(height: 38),
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 30),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: BadalColors.ink,
      ),
    ),
  );
}

class AuthNotice extends StatelessWidget {
  const AuthNotice(this.message, {super.key, this.success = false});
  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: success ? BadalColors.mint : const Color(0xFFFFEDEC),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(
          success ? Icons.check_circle_outline : Icons.info_outline,
          size: 19,
          color: success ? BadalColors.pine : const Color(0xFFB44C42),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: success ? BadalColors.pine : const Color(0xFF9F3C34),
            ),
          ),
        ),
      ],
    ),
  );
}
