import 'package:flutter/material.dart';

class GuardResultPage extends StatelessWidget {
  final Map<String, dynamic>? request;

  const GuardResultPage({super.key, required this.request});

  /// Safely parse date + time into DateTime
  DateTime _parseDateTime(String date, String time) {
    try {
      // date expected: yyyy-MM-dd
      final d = DateTime.parse(date);

      final parts = time.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(
        d.year,
        d.month,
        d.day,
        hour,
        minute,
      );
    } catch (e) {
      debugPrint("Date parse error: $e");
      return DateTime.now();
    }
  }

  bool isExpired(Map<String, dynamic> r) {
    if (r['status'] != 'approved_2') return false;

    final endDT = _parseDateTime(r['date'], r['end_time']);
    final now = DateTime.now();

    return now.isAfter(endDT);
  }

  bool isValid(Map<String, dynamic> r) {
    if (r['status'] != 'approved_2') return false;

    final startDT = _parseDateTime(r['date'], r['start_time']);
    final endDT = _parseDateTime(r['date'], r['end_time']);
    final now = DateTime.now();

    return now.isAfter(startDT) && now.isBefore(endDT);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (request == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Verification Result"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            "QR not found or invalid",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final r = request!;
    final expired = isExpired(r);
    final valid = isValid(r);

    Color bgColor;
    IconData icon;
    String title;

    // 🔥 IMPORTANT: order matters
    if (valid) {
      bgColor = const Color(0xFFE6F4EA); // soft green
      icon = Icons.verified_rounded;
      title = "VALID PASS";
    } else if (expired) {
      bgColor = const Color(0xFFFFF4E5); // soft amber
      icon = Icons.schedule_rounded;
      title = "EXPIRED";
    } else {
      bgColor = const Color(0xFFFDECEC); // soft red
      icon = Icons.block_rounded;
      title = "NOT VALID";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Result"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 60),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _Tile(label: "Student", value: r['student_name'] ?? ""),
              _Tile(label: "Email", value: r['student_email'] ?? ""),
              _Tile(label: "Room", value: r['room_name'] ?? "Container"),
              _Tile(label: "Date", value: r['date'] ?? ""),
              _Tile(
                label: "Time",
                value:
                    "${r['start_time'] ?? ""} - ${r['end_time'] ?? ""}",
              ),
              _Tile(label: "Purpose", value: r['purpose'] ?? ""),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
