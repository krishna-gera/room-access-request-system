import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final byId = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
    if (byId != null) return byId;

    final email = supabase.auth.currentUser?.email;
    if (email == null || email.isEmpty) return null;

    final byEmail = await supabase.from('profiles').select().eq('email', email).maybeSingle();
    return byEmail;
  }

  static Future<bool> verifySaptakId(String saptakId, String email) async {
    final res = await supabase
        .from('saptak_members')
        .select()
        .eq('saptak_id', saptakId)
        .eq('email', email)
        .eq('is_active', true)
        .maybeSingle();

    return res != null;
  }

  static Future<String?> submitRequest({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String saptakId,
    required String date,
    required String startTime,
    required String endTime,
    required String purpose,
    required String peopleVisiting,
    required String equipments,
  }) async {
    final insert = await supabase.from('requests').insert({
      'student_id': studentId,
      'student_name': studentName,
      'student_email': studentEmail,
      'saptak_id': saptakId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'purpose': purpose,
      'people_visiting': peopleVisiting,
      'equipments': equipments,
      'status': 'pending',
    }).select().single();

    return insert['id'] as String?;
  }

  static Future<List<Map<String, dynamic>>> fetchRequestsForAdmin() async {
    final res = await supabase
        .from('requests')
        .select()
        .order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  static Future<void> adminApproveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
  }) async {
    final req = await supabase.from('requests').select().eq('id', requestId).single();

    final status = req['status'] as String;
    final approvedBy1 = req['approved_by_1'];
    final approvedBy2 = req['approved_by_2'];

    if (approvedBy1 == adminId || approvedBy2 == adminId) {
      throw Exception("You already approved this request.");
    }

    if (status == 'pending') {
      await supabase.from('requests').update({
        'status': 'approved_1',
        'approved_by_1': adminId,
        'approved_at_1': DateTime.now().toIso8601String(),
      }).eq('id', requestId);
    } else if (status == 'approved_1') {
      // Second approval => confirm
      final qrPayload = "RID:$requestId|APPROVED_BY:$adminId|TIME:${DateTime.now().toIso8601String()}";

      await supabase.from('requests').update({
        'status': 'approved_2',
        'approved_by_2': adminId,
        'approved_at_2': DateTime.now().toIso8601String(),
        'qr_payload': qrPayload,
      }).eq('id', requestId);
    } else {
      throw Exception("Request cannot be approved now.");
    }

    await supabase.from('approvals').insert({
      'request_id': requestId,
      'admin_id': adminId,
      'decision': 'approved',
    });
  }

  static Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    final res = await supabase.from('requests').select().eq('id', requestId).maybeSingle();
    return res;
  }
}
