import 'package:flutter/material.dart';

import 'feature/auth/prsentation/screen/auth_gate.dart';
import 'feature/auth/prsentation/screen/forgot_password_screen.dart';
import 'feature/auth/prsentation/screen/new_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri?.path == '/forgot-password') {
          return MaterialPageRoute<void>(
            builder: (_) => const ForgotPasswordScreen(),
          );
        }
        if (uri?.path == '/reset-password') {
          final params = uri!.queryParametersAll;
          final email = params['email'];
          final token = params['token'];
          return MaterialPageRoute<void>(
            builder: (_) => NewPasswordScreen(
              email: email?.length == 1 ? email!.single : null,
              token: token?.length == 1 ? token!.single : null,
            ),
          );
        }
        return null;
      },
    );
  }
}
