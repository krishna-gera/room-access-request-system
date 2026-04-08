import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _resolve(String key) {
    const fromDefineUrl = String.fromEnvironment('SUPABASE_URL');
    const fromDefineKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    final fromDefine = switch (key) {
      'SUPABASE_URL' => fromDefineUrl,
      'SUPABASE_ANON_KEY' => fromDefineKey,
      _ => '',
    };

    if (fromDefine.isNotEmpty) return fromDefine;

    final fromDotEnv = dotenv.env[key];
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) return fromDotEnv;

    throw StateError('$key is missing. Set it in .env or pass via --dart-define.');
  }

  static String get supabaseUrl => _resolve('SUPABASE_URL');

  static String get supabaseAnonKey => _resolve('SUPABASE_ANON_KEY');
}
