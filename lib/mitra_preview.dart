import 'package:flutter/material.dart';

import 'features/auth/data/auth_models.dart';
import 'features/home/presentation/role_navigation_page.dart';
import 'shared/theme/greenloop_theme.dart';
import 'shared/widgets/mobile_viewport_frame.dart';

/// Local UI preview entry point; it does not require the Django backend.
void main() {
  runApp(const MitraPreviewApp());
}

class MitraPreviewApp extends StatelessWidget {
  const MitraPreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GreenLoop Mitra Preview',
    debugShowCheckedModeBanner: false,
    theme: GreenLoopTheme.light,
    home: const RoleNavigationPage(role: UserRole.mitra),
    builder: (context, child) => MobileViewportFrame(
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
