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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GuardHome()));
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
    final cs = Theme.of(context).colorScheme;

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
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.20),
                          cs.secondary.withOpacity(0.22),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: cs.primary.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.meeting_room_rounded, color: cs.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Room Access Request System",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Secure request, approval, and guard verification",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

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
