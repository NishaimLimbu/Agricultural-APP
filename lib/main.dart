import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/welcome_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MSFloraERP(),
  );
}


class MSFloraERP extends StatelessWidget {
  const MSFloraERP({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title:
          'MS FLORA ERP',

      theme:
          AppTheme.lightTheme,

      home:
          const WelcomeScreen(),
    );
  }
}