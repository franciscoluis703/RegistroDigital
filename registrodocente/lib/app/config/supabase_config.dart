import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Credenciales de Supabase desde .env
  // Proyecto: RegistroDocente

  // Valores por defecto (usados si .env no está disponible)
  static const String _defaultUrl = 'https://fqghquowfozmmbohzebb.supabase.co';
  static const String _defaultAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ2hxdW93Zm96bW1ib2h6ZWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MjM4ODcsImV4cCI6MjA3NTE5OTg4N30.ULyIyq7UGDc0qSdz9lH1gQa3nby5ATg2st8QyeoJ7ww';

  // Obtener desde .env o usar valores por defecto
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? _defaultUrl;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? _defaultAnonKey;
}
