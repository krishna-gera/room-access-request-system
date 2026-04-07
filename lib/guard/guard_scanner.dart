import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/supabase_service.dart';
import 'guard_result_page.dart';

class GuardScanner extends StatefulWidget {
  const GuardScanner({super.key});

  @override
  State<GuardScanner> createState() => _GuardScannerState();
}

class _GuardScannerState extends State<GuardScanner> {
  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;

  String extractRequestId(String raw) {
    if (raw.contains("RID:")) {
      final start = raw.indexOf("RID:") + 4;
      final end = raw.contains("|") ? raw.indexOf("|", start) : raw.length;
      return raw.substring(start, end).trim();
    }
    return raw.trim();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> handleScan(String raw) async {
    if (scanned) return;

    scanned = true;
    controller.stop(); // stop camera before navigating

    final requestId = extractRequestId(raw);
    final request = await SupabaseService.getRequestById(requestId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GuardResultPage(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final raw = barcode.rawValue;
              if (raw != null) {
                handleScan(raw);
              }
            },
          ),

          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Center scanner window
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.redAccent,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Align QR code inside the frame",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "The pass will be verified automatically",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
