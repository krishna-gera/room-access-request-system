import 'package:flutter/material.dart';

class GuardResultPage extends StatelessWidget {
  final Map<String, dynamic>? request;
  const GuardResultPage({super.key, required this.request});

  bool isValid(Map<String, dynamic> r) {
    return r['status'] == 'approved_2';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Result"), centerTitle: true),
        body: SafeArea(
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
                  Icon(Icons.close_rounded, size: 60, color: cs.error),
                  const SizedBox(height: 12),
                  Text("Not Found", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text("This QR is invalid or not in the system."),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final r = request!;
    final valid = isValid(r);

    return Scaffold(
      appBar: AppBar(title: const Text("Result"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outlineVariant),
                  color: valid ? cs.primaryContainer : cs.errorContainer,
                ),
                child: Column(
                  children: [
                    Icon(
                      valid ? Icons.verified_rounded : Icons.block_rounded,
                      size: 56,
                      color: valid ? cs.onPrimaryContainer : cs.onErrorContainer,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      valid ? "VALID PASS" : "NOT VALID",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: valid ? cs.onPrimaryContainer : cs.onErrorContainer,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _Tile(label: "Student", value: r['student_name']),
              _Tile(label: "Email", value: r['student_email']),
              _Tile(label: "Room", value: r['room_name'] ?? "Container Room"),
              _Tile(label: "Date", value: r['date']),
              _Tile(label: "Time", value: "${r['start_time']} - ${r['end_time']}"),
              _Tile(label: "Purpose", value: r['purpose']),
              _Tile(label: "Approved", value: r['status']),
            ],
          ),
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
      width: double.infinity,
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
