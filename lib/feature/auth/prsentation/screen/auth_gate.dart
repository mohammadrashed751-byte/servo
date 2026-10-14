import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/local_storage.dart';
import '../../../../core/shell/company_shell.dart';
import '../../../../core/shell/main_shell.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'login_screen.dart';
import 'screen_one.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Widget> _sessionCheck;

  @override
  void initState() {
    super.initState();
    _sessionCheck = _checkSession();
  }

  Future<Widget> _checkSession() async {
    final token = await LocalStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      return ScreenOne();
    }

    try {
      final account = await AuthRemoteDataSource().getCurrentAccount();

      final data = account['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid account data');
      }

      final role = data['role'];
      if (role != 'customer' && role != 'provider') {
        throw Exception('Unsupported account role');
      }

      await LocalStorage.saveRole(role as String);

      return role == 'provider'
          ? const CompanyShell()
          : const MainShell();
    } on DioException catch (error) {
      // السيرفر رفض التوكن: انتهت الجلسة أو أصبحت غير صالحة.
      if (error.response?.statusCode == 401) {
        await LocalStorage.clearAuthentication();
        return const LoginScreen();
      }

      // مشاكل الاتصال والسيرفر لا تمسح الجلسة.
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _sessionCheck = _checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'تعذّر التحقق من الجلسة. حاول مرة أخرى.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return snapshot.data!;
      },
    );
  }
}
