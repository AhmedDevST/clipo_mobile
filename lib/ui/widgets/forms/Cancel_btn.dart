import 'package:flutter/material.dart';

class CancelbtnWidget extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;
  CancelbtnWidget(
      {super.key,
      required this.isLoading,
      required this.isEnabled,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? null : onPressed,
      child: const Text(
        'Cancel',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
