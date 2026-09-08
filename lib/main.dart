import 'package:cinema_admin/widgets/admin_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CinemaAdminApp());
}

class CinemaAdminApp extends StatelessWidget {
  const CinemaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Admin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070909),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF3F0D6),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const AdminShell();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
