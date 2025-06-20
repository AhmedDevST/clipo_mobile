import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final Color? textColor;
  final double? fontSize;

  const LoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              color: textColor ?? primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
