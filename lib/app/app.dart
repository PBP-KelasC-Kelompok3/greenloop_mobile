import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_pages.dart';
import '../features/auth/services/auth_service.dart';
import '../shared/theme/greenloop_theme.dart';

class GreenLoopApp extends StatelessWidget {
  const GreenLoopApp({this.authService, super.key});

  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLoop',
      debugShowCheckedModeBanner: false,
      theme: GreenLoopTheme.light,
      home: WelcomePage(authService: authService),
    );
  }
}
