import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_pages.dart';
import '../shared/theme/greenloop_theme.dart';

class GreenLoopApp extends StatelessWidget {
  const GreenLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLoop',
      debugShowCheckedModeBanner: false,
      theme: GreenLoopTheme.light,
      home: const WelcomePage(),
    );
  }
}
