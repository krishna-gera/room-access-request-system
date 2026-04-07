import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'qr_pass_page.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  bool loading = true;
  List<Map<String, dynamic>> myRequests = [];

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final user = SupabaseService.supabase.auth.currentUser!;
      final res = await SupabaseService.supabase
          .from('requests')
          .select()
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      myRequests = (res as List).cast<Map<String, dynamic>>();
    } catch (_) {}
    setState(() => loading = false);
  }

  String labelFor(String status) {
    switch (status) {
      case "pending":
        return "Pending";
      case "approved_1":
        return "Approved by 1 Admin";
      case "approved_2":
        return "Confirmed (QR Ready)";
      case "rejected":
        return "Rejected";
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: myRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = myRequests[i];
                    final status = r['status'] as String;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${r['date']} • ${r['start_time']} - ${r['end_time']}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Purpose: ${r['purpose']}",
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
                                child: Text(
                                  labelFor(status),
                                  style: TextStyle(
                                    color: status == "approved_2"
                                        ? cs.onPrimaryContainer
                                        : cs.onSurface,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (status == "approved_2")
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QRPassPage(request: r),
                                      ),
                                    );
                                  },
                                  child: const Text("View QR"),
                                )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
