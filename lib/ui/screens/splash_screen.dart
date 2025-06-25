import 'package:flutter/material.dart';
import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:clipo_app/screens/add_link_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? sharedUrl;
  
  const SplashScreen({super.key, this.sharedUrl});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  _navigateAfterSplash() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      if (widget.sharedUrl != null) {
        // If we have a shared URL, navigate to AddLinkScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddLinkScreen(url: widget.sharedUrl!),
          ),
        );
      } else {
        // Normal launch, navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4FC3F7),
                    Color(0xFF29B6F6),
                    Color(0xFF0288D1),
                    Color(0xFFFF7043),
                  ],
                ),
              ),
              child: const Icon(
                Icons.link,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'GREAN APP',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'LinkSaver',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Save. Organize. Access.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            // Optional: Show a different message when sharing
            if (widget.sharedUrl != null) ...[
              const SizedBox(height: 30),
              const Text(
                'Processing shared link...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}