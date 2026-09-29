import 'package:flutter/material.dart';

/// Shared screen shell: AI background photo, readability gradient on top,
/// then the screen content. The top inset is intentionally left to the screen
/// header (which carries its own 44px status-bar padding).
class AppScaffold extends StatelessWidget {
  final ImageProvider background;
  final List<Color> overlay;
  final Widget child;
  final Widget? behindContent;

  const AppScaffold({
    super.key,
    required this.background,
    required this.overlay,
    required this.child,
    this.behindContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: background, fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: overlay,
            ),
          ),
          child: Stack(
            children: <Widget>[
              if (behindContent != null) Positioned.fill(child: behindContent!),
              SafeArea(top: false, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
