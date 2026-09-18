import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MedAlertApp());
}

class MedAlertApp extends StatelessWidget {
  const MedAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.redPrimary,
          primary: AppConstants.redPrimary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppConstants.redPrimary,
            foregroundColor: Colors.white,
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppConstants.redBright,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Shared gradient AppBar used by every page.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GradientAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: actions,
      flexibleSpace: Container(decoration: AppConstants.gradientBox(radius: 0)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Routes the user to Login or Home depending on session state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const LoginPage() : const HomePage();
  }
}

/// Global holder for the signed-in user's role (set after login).
class SessionContext {
  static Profile? currentProfile;
}