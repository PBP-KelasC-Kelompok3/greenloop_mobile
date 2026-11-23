import 'package:flutter/material.dart';

import '../theme/greenloop_theme.dart';

/// Keeps a mobile-first Flutter app at handset width when previewed on desktop.
/// On a phone or emulator, the app uses the device's full available width.
class MobileViewportFrame extends StatelessWidget {
  const MobileViewportFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth <= 450) return child;

      const phoneWidth = 390.0;
      final height = constraints.maxHeight;
      final media = MediaQuery.of(context);
      return ColoredBox(
        color: GreenLoopColors.deepForest,
        child: Center(
          child: SizedBox(
            width: phoneWidth,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: MediaQuery(
                data: media.copyWith(size: Size(phoneWidth, height)),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}
