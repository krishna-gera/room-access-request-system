import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPassPage extends StatelessWidget {
  final Map<String, dynamic> request;
  const QRPassPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final payload = request['qr_payload'] ?? "RID:${request['id']}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Pass"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                "Show this QR to the guard",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black, // 🔥 dark background required
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: QrImageView(
                  data: payload,
                  size: 260,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                ),
              ),

              const SizedBox(height: 18),

              _InfoTile(label: "Room", value: request['room_name'] ?? "Container Room"),
              _InfoTile(label: "Date", value: request['date']),
              _InfoTile(label: "Time", value: "${request['start_time']} - ${request['end_time']}"),
              _InfoTile(label: "Purpose", value: request['purpose']),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

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
