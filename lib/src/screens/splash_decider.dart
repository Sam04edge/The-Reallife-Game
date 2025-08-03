// lib/src/screens/splash_decider.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({Key? key}) : super(key: key);

  @override
  SplashDeciderState createState() => SplashDeciderState();
}

class SplashDeciderState extends State<SplashDecider> {
  bool? _seenIntro;

  @override
  void initState() {
    super.initState();
    _verifyAsset(); // ← hier aufrufen
    _loadFlag();
  }

  Future<void> _verifyAsset() async {
    const assetPath = 'assets/images/items/Ring_rpg.png';

    // 1) Prüfe, ob der Pfad im AssetManifest auftaucht
    final manifest = await rootBundle.loadString('AssetManifest.json');
    if (manifest.contains(assetPath)) {
      debugPrint('✅ AssetManifest enthält $assetPath');
    } else {
      debugPrint('❌ AssetManifest enthält NICHT $assetPath');
    }

    // 2) Versuche das Asset zu laden
    try {
      await rootBundle.load(assetPath);
      debugPrint('✅ Asset erfolgreich geladen');
    } catch (e) {
      debugPrint('❌ Beim Laden des Assets ist ein Fehler aufgetreten: $e');
    }
  }

  Future<void> _loadFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenIntro') ?? false;
    setState(() => _seenIntro = seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_seenIntro == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return !_seenIntro! ? const OnboardingScreen() : const HomeScreen();
  }
}
