import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class RequestDetailAdmin extends StatefulWidget {
  final Map<String, dynamic> request;
  const RequestDetailAdmin({super.key, required this.request});

  @override
  State<RequestDetailAdmin> createState() => _RequestDetailAdminState();
}

class _RequestDetailAdminState extends State<RequestDetailAdmin> {
  bool loading = false;
  Map<String, dynamic>? fresh;

  Future<void> reload() async {
    fresh = await SupabaseService.getRequestById(widget.request['id']);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> approve() async {
    setState(() => loading = true);

    try {
      final user = SupabaseService.supabase.auth.currentUser!;
      final profile = await SupabaseService.getProfile(user.id);
      final name = profile?['name'] ?? "Admin";

      await SupabaseService.adminApproveRequest(
        requestId: widget.request['id'],
        adminId: user.id,
        adminName: name,
      );

      await reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Approved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = fresh ?? widget.request;
    final status = r['status'] as String;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text("Student", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Tile(label: "Name", value: r['student_name']),
            _Tile(label: "Email", value: r['student_email']),
            _Tile(label: "Saptak ID", value: r['saptak_id']),

            const SizedBox(height: 14),
            Text("Slot", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Tile(label: "Date", value: r['date']),
            _Tile(label: "Time", value: "${r['start_time']} - ${r['end_time']}"),

            const SizedBox(height: 14),
            Text("Details", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Tile(label: "Purpose", value: r['purpose']),
            _Tile(label: "People", value: r['people_visiting']),
            _Tile(label: "Equipments", value: r['equipments']),

            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                "Status: $status",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),

            const SizedBox(height: 18),

            if (status == "pending" || status == "approved_1")
              ElevatedButton(
                onPressed: loading ? null : approve,
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(status == "pending"
                        ? "Approve (1st Approval)"
                        : "Approve (2nd Approval → Confirm)"),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  const _Tile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.titleSmall)),
        ],
      ),
    );
  }
}
