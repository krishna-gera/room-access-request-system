import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../student/student_home.dart';
import '../admin/admin_home.dart';
import '../guard/guard_home.dart';
import '../tech_admin/tech_admin_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await SupabaseService.supabase.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = SupabaseService.supabase.auth.currentUser!;
      final profile = await SupabaseService.getProfile(user.id);

      if (!mounted) return;

      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No profile found. Contact tech admin.")),
        );
        return;
      }

      final role = profile['role'];

      if (role == 'student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentHome()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHome()));
      } else if (role == 'guard') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GuardHome()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TechAdminHome()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Text("Saptak Container Access",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text("Login to request / approve / verify access",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 30),

                  TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
