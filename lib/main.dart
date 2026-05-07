import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_register_page.dart';
import 'screens/home_page.dart';
import 'admin_page.dart'; // ← Import AdminPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gimigizuhiypqimztblx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpbWlnaXp1aGl5cHFpbXp0Ymx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MzQ5MDAsImV4cCI6MjA5MzUxMDkwMH0.IUNiVGn6FNDTIN6oVcMFYdL8nmXrNI4VeCivV0Cb1QQ',
  );

  runApp(const FruitShopApp());
}

class FruitShopApp extends StatelessWidget {
  const FruitShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trái Cây Gia Đình',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AuthGate(),
      routes: {
        '/admin': (context) => const AdminPage(), // ← Route Admin
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        return snapshot.data?.session != null
            ? const HomePage()
            : const LoginRegisterPage();
      },
    );
  }
}

// Khai báo global một lần
final supabase = Supabase.instance.client;
