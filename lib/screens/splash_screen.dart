import 'package:chikitsa/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:chikitsa/screens/home_screen.dart';

class ChikitsaSplashScreen extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const ChikitsaSplashScreen({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<ChikitsaSplashScreen> createState() => _ChikitsaSplashScreenState();
}

class _ChikitsaSplashScreenState extends State<ChikitsaSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Quick brut style load
    Future.delayed(const Duration(seconds: 2), () {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Sliding curtain effect or simple fade? Brutalism likes direct cuts.
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.current;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top decoration
              Container(
                width: double.infinity,
                height: 4,
                color: Theme.of(context).colorScheme.onSurface,
              ),

              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain, // Fill width
                    child: Text(
                      lang.get('BRAND'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ),

              // Bottom text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.get('TAGLINE'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
