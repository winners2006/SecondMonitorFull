import 'package:flutter/material.dart';

class AppTheme {
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(150, 50),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF4B8F90),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: const BorderSide(color: Color(0xFF8F9092)),
    ),
  ).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return const Color(0xFFD8D9DB);
      }
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFFF5F5F5);
      }
      return Colors.white;
    }),
    elevation: WidgetStateProperty.resolveWith<double>((states) {
      if (states.contains(WidgetState.hovered)) {
        return 4;
      }
      if (states.contains(WidgetState.pressed)) {
        return 8;
      }
      return 2;
    }),
    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.grey.withOpacity(0.1);
      }
      return null;
    }),
    shadowColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFFCECFD1);
      }
      return Colors.black.withOpacity(0.2);
    }),
  );
}

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFFD8D9DB),
            Colors.white,
            Color(0xFFFDFDFD),
          ],
          stops: [0.0, 0.8, 1.0],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        style: AppTheme.elevatedButtonStyle,
        onPressed: onPressed,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B8F90),
            shadows: [
              Shadow(
                color: Colors.white,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
} 