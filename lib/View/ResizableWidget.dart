import 'package:flutter/material.dart';

class CustomResizableWidget extends StatelessWidget {
  final Widget child;
  final Function(double, double) onResize;

  const CustomResizableWidget({
    super.key,
    required this.child,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onPanUpdate: (details) {
              onResize(details.delta.dx, details.delta.dy);
            },
            child: Container(
              width: 20,
              height: 20,
              color: Colors.blue.withOpacity(0.5),
              child: const Icon(Icons.drag_handle, size: 16),
            ),
          ),
        ),
      ],
    );
  }
} 