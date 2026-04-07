import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'request_detail_admin.dart';
import '../auth/login_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool loading = true;
  List<Map<String, dynamic>> requests = [];

  Future<void> load() async {
    setState(() => loading = true);
    try {
      requests = await SupabaseService.fetchRequestsForAdmin();
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  String labelFor(String status) {
    switch (status) {
      case "pending":
        return "Pending";
      case "approved_1":
        return "Needs 2nd Approval";
      case "approved_2":
        return "Confirmed";
      case "rejected":
        return "Rejected";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
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
        child: RefreshIndicator(
          onRefresh: load,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = requests[i];
                    final status = r['status'] as String;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestDetailAdmin(request: r),
                          ),
                        );
                        load();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${r['student_name']} • ${r['student_email']}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${r['date']} • ${r['start_time']} - ${r['end_time']}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: status == "approved_2"
                                        ? cs.primaryContainer
                                        : cs.surfaceContainerHighest,
                                  ),
                                  child: Text(labelFor(status)),
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
