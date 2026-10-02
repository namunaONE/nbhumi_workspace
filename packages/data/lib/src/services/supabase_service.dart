import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client provider.
///
/// Initialize in main.dart before runApp.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase auth provider.
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return Supabase.instance.client.auth;
});

/// Supabase storage provider.
final supabaseStorageProvider = Provider<SupabaseStorageClient>((ref) {
  return Supabase.instance.client.storage;
});

/// Supabase realtime provider.
final supabaseRealtimeProvider = Provider<RealtimeClient>((ref) {
  return Supabase.instance.client.realtime;
});
