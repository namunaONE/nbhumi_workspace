import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Storage service — wraps Supabase Storage.
///
/// Handles image uploads, signed URLs, and KYC document storage.
class StorageService {
  StorageService(this._client);

  final SupabaseStorageClient _client;

  /// Upload a file to a bucket.
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.from(bucket).upload(path, file);
    return _client.from(bucket).getPublicUrl(path);
  }

  /// Get a signed URL for a private file.
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600,
  }) async {
    final url = await _client
        .from(bucket)
        .createSignedUrl(path, expiresIn);
    return url;
  }

  /// Delete a file from a bucket.
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.from(bucket).remove([path]);
  }
}
