import 'package:flutter/material.dart';
//import 'package:lottie/lottie.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? lottieUrl;
  final String confirmText;
  final String cancelText;
  final  Color? color ;
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    this.lottieUrl,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           /* if (lottieUrl != null)
              Lottie.network(
                lottieUrl!,
                height: 100,
                fit: BoxFit.contain,
              ),*/
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                      label: Text(
                        cancelText,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.done),
                      label: Text(confirmText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:color ?? Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
