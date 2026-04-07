import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../services/supabase_service.dart';
import 'guard_scanner.dart';

class GuardHome extends StatelessWidget {
  const GuardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard'),
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
              Text(
                'Verify Access Pass',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan student QR passes and validate the approved time slot.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuardScanner()),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Open QR Scanner'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
