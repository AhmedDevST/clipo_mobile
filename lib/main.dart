import 'package:clipo_app/ui/screens/links/add_link_screen.dart';
import 'package:clipo_app/screens/add_link_screen.dart';
import 'package:clipo_app/screens/home_screen.dart';
import 'package:clipo_app/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:clipo_app/screens/CategoryPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String? _initialSharedUrl;

  @override
  void initState() {
    super.initState();
    _checkInitialIntent();
    _setupIntentListener();
  }

  void _checkInitialIntent() async {
    // Check if app was opened with shared content
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      _initialSharedUrl = initialMedia.first.path;
      print("\n==============================");
      print("✅ Initial Shared Path Received:");
      print(_initialSharedUrl);
      print("==============================\n");
    }
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
      home: SplashScreen(sharedUrl: _initialSharedUrl),
    );
  }
}