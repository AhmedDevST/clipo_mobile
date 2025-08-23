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
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1B23),
                  Color(0xFF262832),
                ],
              ),
            ),
          ),
          // Animated background circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7043).withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with shimmer effect
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // App name with modern typography
                const Text(
                  'CLIPO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Color(0xFF4FC3F7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Save · Organize · Access',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Status message with animated container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: _isCheckingIntent
                    ? const Text(
                        'Initializing...',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : _sharedUrl != null
                      ? const Text(
                          'Processing shared link...',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}