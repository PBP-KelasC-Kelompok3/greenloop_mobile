import 'package:flutter/material.dart';

import 'features/auth/data/auth_models.dart';
import 'features/home/presentation/role_navigation_page.dart';
import 'shared/theme/greenloop_theme.dart';

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
    color: GreenLoopColors.deepForest,
    home: const RoleNavigationPage(role: UserRole.mitra),
    builder: (context, child) => LayoutBuilder(
      builder: (context, constraints) {
        final appNavigator = child ?? const SizedBox.shrink();
        if (constraints.maxWidth <= 450) return appNavigator;
        return Center(
          child: Container(
            width: 390,
            height: constraints.maxHeight - 32,
            decoration: BoxDecoration(
              color: GreenLoopColors.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: appNavigator,
          ),
        );
      },
    ),
  );
}
