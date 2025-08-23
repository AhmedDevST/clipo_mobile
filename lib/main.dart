import 'package:clipo_app/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupIntentListener();
  }

  void _setupIntentListener() {
    // Listen for shared content while app is running
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _handleSharedFiles(value);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      final sharedPath = files.first.path;
      print("\n==============================");
      print("✅ Runtime Shared Path Received:");
      print(sharedPath);
      print("==============================\n");

      /* WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AddLinkScreen(url: sharedPath),
          ),
        );
      });*/

      ReceiveSharingIntent.instance.reset();
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestionnaire de Liens',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // No sharedUrl parameter - splash will check itself
    );
  }
}