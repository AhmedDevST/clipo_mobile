import 'package:flutter/material.dart';
//import 'package:lottie/lottie.dart';

class StatusDialog extends StatelessWidget {
  final String title;
  final String description;
  final String lottieUrl; // Success or error animation
  final bool isSuccess;
  final List<String>? errors; // Optional list of errors

  const StatusDialog({
    super.key,
    required this.title,
    required this.description,
    required this.lottieUrl,
    required this.isSuccess,
    this.errors,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             /* Lottie.network(
                lottieUrl,
                height: 120,
                fit: BoxFit.contain,
              ),
              */
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              if (errors != null && errors!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: errors!
                      .map((error) => ListTile(
                            leading: const Icon(Icons.error_outline, color: Colors.red),
                            title: Text(error),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("OK"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
