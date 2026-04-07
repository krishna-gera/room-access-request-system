import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../auth/login_page.dart';

class TechAdminHome extends StatelessWidget {
  const TechAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tech Admin"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await SupabaseService.supabase.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Full Access", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                "You can manage rooms, members, admins, guards, and logs (future).",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: const Text(
                  "MVP Note:\nFor now, Tech Admin is only a placeholder screen.\nLater we will add:\n• Manage Saptak IDs\n• Create Admin/Guard accounts\n• View logs",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
