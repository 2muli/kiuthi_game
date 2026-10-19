import 'package:flutter/material.dart';

class KiuthiTheme {
  static const ink = Color(0xFF3E2723);
  static const clay = Color(0xFF8D4A32);
  static const sand = Color(0xFFF3E6D0);
  static const sandDeep = Color(0xFFE4CBA3);
  static const wood = Color(0xFFC9956A);
  static const woodEdge = Color(0xFF6D4C41);
  static const card = Color(0xFFFFF8EE);
  static const redPiece = Color(0xFFC62828);
  static const redEdge = Color(0xFF7F1010);
  static const bluePiece = Color(0xFF1565C0);
  static const blueEdge = Color(0xFF0D3C75);
  static const gold = Color(0xFFE6A817);
  static const moveGreen = Color(0xFF1B5E20);
  static const capture = Color(0xFFE65100);
  static const muted = Color(0xFF6D4C41);
  static const field = Color(0xFFF4E2C4);

  static ThemeData theme() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: clay,
          brightness: Brightness.light,
        ).copyWith(
          primary: clay,
          onPrimary: Colors.white,
          surface: sand,
          onSurface: ink,
        );
    const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: sand,
      textTheme: Typography.material2021().black.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: sand,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE8C4A4),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return label.copyWith(color: selected ? clay : muted);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: ink,
          height: 1.4,
          fontSize: 15,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? Colors.white : muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? clay : sandDeep;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: clay,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: woodEdge),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: sandDeep),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _StillPageTransitionsBuilder(),
          TargetPlatform.iOS: _StillPageTransitionsBuilder(),
          TargetPlatform.linux: _StillPageTransitionsBuilder(),
          TargetPlatform.macOS: _StillPageTransitionsBuilder(),
          TargetPlatform.windows: _StillPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _StillPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Opens a route in place. The board does not slide or zoom in.
class _StillPageTransitionsBuilder extends PageTransitionsBuilder {
  const _StillPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class KiuthiPanel extends StatelessWidget {
  const KiuthiPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KiuthiTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: KiuthiTheme.sandDeep),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class KiuthiSectionLabel extends StatelessWidget {
  const KiuthiSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class KiuthiPage extends StatelessWidget {
  const KiuthiPage({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.safeBottom = true,
  });

  final Widget child;
  final double maxWidth;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBF3E6), KiuthiTheme.sand, Color(0xFFE9D3B0)],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: safeBottom,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
