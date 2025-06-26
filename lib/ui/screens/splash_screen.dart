import 'package:flutter/material.dart';
import 'package:clipo_app/ui/screens/home_screen.dart';
import 'package:clipo_app/ui/screens/links/add_link_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _sharedUrl;
  bool _isCheckingIntent = true;

  @override
  void initState() {
    super.initState();
    _checkInitialIntentAndNavigate();
  }

  Future<void> _checkInitialIntentAndNavigate() async {
    String? initialSharedUrl;
    
    try {
      // Check for shared media files
      final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
      if (initialMedia.isNotEmpty) {
        initialSharedUrl = initialMedia.first.path;
        print("\n==============================");
        print("✅ Initial Shared Path Received:");
        print(initialSharedUrl);
        print("==============================\n");
      }
    } catch (e) {
      print("Error checking initial intent: $e");
    }
    
    // Update state to show the correct message
    if (mounted) {
      setState(() {
        _sharedUrl = initialSharedUrl;
        _isCheckingIntent = false;
      });
    }
    
    // Wait for splash screen duration (you can adjust this)
    await Future.delayed(const Duration(seconds: 3));
    
    // Navigate based on whether we have a shared URL
    if (mounted) {
      if (initialSharedUrl != null) {
        // Navigate to AddLinkScreen with the shared URL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddLinkScreen(url: initialSharedUrl!),
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
              'Clipo',
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
            const SizedBox(height: 30),
            // Dynamic message based on sharing status
            if (_isCheckingIntent)
              const Text(
                'Initializing...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              )
            else if (_sharedUrl != null)
              const Text(
                'Processing shared link...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              const Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}