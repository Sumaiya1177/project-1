import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_project1/pages/welcome_page.dart';
import 'package:flutter_project1/pages/signup_page.dart';
import 'package:flutter_project1/pages/login_page.dart';
import 'package:flutter_project1/pages/admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://hxbbzegtaotkkfyqwisr.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4YmJ6ZWd0YW90a2tmeXF3aXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMzUwNTIsImV4cCI6MjA3MjkxMTA1Mn0.vO0bmzf78K7w9mMkoUNJoaLUFSLG8dUNKwkkXMUfSHI",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Admin Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPanelPage(),
      },
    );
  }
}