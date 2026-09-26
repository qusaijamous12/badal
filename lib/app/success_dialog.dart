import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme.dart';

Future<void> showBadalSuccessDialog({
  required String title,
  required String message,
  String buttonLabel = 'متابعة',
}) => Get.dialog<void>(
  BadalSuccessDialog(title: title, message: message, buttonLabel: buttonLabel),
  barrierDismissible: false,
);

class BadalSuccessDialog extends StatelessWidget {
  const BadalSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: BadalColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 46,
              color: BadalColors.pine,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    ),
  );
}
