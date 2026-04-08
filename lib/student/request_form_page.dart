import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class RequestFormPage extends StatefulWidget {
  const RequestFormPage({super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final saptakId = TextEditingController();
  final purpose = TextEditingController();
  final people = TextEditingController();
  final equipments = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool loading = false;

  String _formatDate(DateTime d) => DateFormat("yyyy-MM-dd").format(d);

  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat("HH:mm").format(dt);
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now,
    );
    if (res != null) setState(() => selectedDate = res);
  }

  Future<void> pickStartTime() async {
    final res = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (res != null) setState(() => startTime = res);
  }

  Future<void> pickEndTime() async {
    final res = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (res != null) setState(() => endTime = res);
  }

  Future<void> submit() async {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time slot.")),
      );
      return;
    }
    if (saptakId.text.trim().isEmpty ||
        purpose.text.trim().isEmpty ||
        people.text.trim().isEmpty ||
        equipments.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = SupabaseService.supabase.auth.currentUser!;
      final profile = await SupabaseService.getProfile(user.id);

      if (profile == null) throw Exception("Profile missing.");

      final email = (profile['email'] as String?) ?? user.email ?? '';
      final name = (profile['name'] as String?) ?? 'Student';

      if (email.isEmpty) throw Exception('Profile email is missing.');

      // 🔥 KEY LOGIC: verify saptak id before creating request
      final ok = await SupabaseService.verifySaptakId(
        saptakId.text.trim(),
        email,
      );

      if (!ok) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotSaptakPage()),
        );
        return;
      }

      final reqId = await SupabaseService.submitRequest(
        studentId: user.id,
        studentName: name,
        studentEmail: email,
        saptakId: saptakId.text.trim(),
        date: _formatDate(selectedDate!),
        startTime: _formatTime(startTime!),
        endTime: _formatTime(endTime!),
        purpose: purpose.text.trim(),
        peopleVisiting: people.text.trim(),
        equipments: equipments.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request submitted! ID: $reqId")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    saptakId.dispose();
    purpose.dispose();
    people.dispose();
    equipments.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Request"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text("Container Access Request",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              "Only verified Saptak members can request access.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),

            _MinimalField(controller: saptakId, label: "Saptak ID (Required)"),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _PickChip(
                    title: selectedDate == null
                        ? "Select Date"
                        : _formatDate(selectedDate!),
                    icon: Icons.calendar_month_rounded,
                    onTap: pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickChip(
                    title: startTime == null ? "Start Time" : _formatTime(startTime!),
                    icon: Icons.access_time_rounded,
                    onTap: pickStartTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PickChip(
              title: endTime == null ? "End Time" : _formatTime(endTime!),
              icon: Icons.timer_outlined,
              onTap: pickEndTime,
            ),

            const SizedBox(height: 14),
            _MinimalField(controller: purpose, label: "Purpose"),
            const SizedBox(height: 12),
            _MinimalField(controller: people, label: "People visiting (names / count)"),
            const SizedBox(height: 12),
            _MinimalField(controller: equipments, label: "Required equipments"),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "After 2 admin approvals, your QR pass will be generated automatically.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MinimalField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _PickChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _PickChip({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          color: cs.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}

class NotSaptakPage extends StatelessWidget {
  const NotSaptakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block_rounded, size: 52, color: cs.error),
                  const SizedBox(height: 14),
                  Text("Request Rejected",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(
                    "You are not registered as a Saptak member.\nOnly verified Saptak members can request container access.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
