import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/postgrest_error_mapper.dart';
import '../providers/session_logging.dart';

/// Read access to reference data: districts, municipalities and wards.
///
/// Separate from ListingRepository because the shape of the call differs.
/// Reference data is small, cached for the life of the process and read by
/// guests, so mixing it into the listing repository would mean every caller
/// navigating past pagination and cursor logic it does not use.
class ReferenceRepository {
  /// Wraps a Supabase client.
  ReferenceRepository(this._client);

  final SupabaseClient _client;

  /// All Nepali districts, ordered by name.
  ///
  /// The `districts` table is reference data with 77 rows and an RLS policy
  /// that admits anon, so this needs no session and no pagination. Sorted in
  /// SQL rather than Dart so the ordering is identical wherever it is consumed.
  ///
  /// Throws an [AppException] subclass, never a raw [PostgrestException].
  Future<List<District>> getDistricts() async {
    try {
      final response = await _client
          .from('districts')
          .select('id, name, province, region')
          .order('name');
      return response
          .map(District.fromJson)
          .toList(growable: false);
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: 'getDistricts');
      AppLogger.error(
        'Reference data failure in getDistricts',
        context: logContext(
          action: 'getDistricts',
          detail: <String, Object?>{'code': mapped.code},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Municipalities in one district, ordered by name.
  ///
  /// The `municipalities` table holds all 753 local bodies with an RLS policy
  /// that admits anon, so this needs no session and no pagination, exactly like
  /// [getDistricts]. Filtered server-side rather than in Dart: unlike the 77
  /// districts, 753 rows is enough that fetching everything to filter locally
  /// would waste a mobile connection on every wizard open.
  ///
  /// Throws an [AppException] subclass, never a raw [PostgrestException].
  Future<List<Municipality>> getMunicipalities({String? district}) async {
    try {
      // Filters before transforms: once `.order` runs the builder becomes a
      // transform builder with no `.eq`, so filtering has to come first.
      final filtered = district != null && district.isNotEmpty
          ? _client.from('municipalities').select(
                'id, slug, district, name, name_ne, type, ward_count',
              ).eq('district', district)
          : _client.from('municipalities').select(
                'id, slug, district, name, name_ne, type, ward_count',
              );
      final response = await filtered.order('name');
      return response.map(Municipality.fromJson).toList(growable: false);
    } on PostgrestException catch (e) {
      final mapped = PostgrestErrorMapper.map(e, action: 'getMunicipalities');
      AppLogger.error(
        'Reference data failure in getMunicipalities',
        context: logContext(
          action: 'getMunicipalities',
          detail: <String, Object?>{'code': mapped.code, 'district': district},
        ),
        error: e,
      );
      throw mapped;
    }
  }

  /// Districts in one province.
  ///
  /// Used by the location step's province filter. Filtering in Dart because the
  /// list is already in memory and this keeps a single query path.
  List<District> byProvince(List<District> districts, String province) =>
      districts.where((d) => d.province == province).toList(growable: false);

  /// The province names present in [districts], alphabetically.
  List<String> provinces(List<District> districts) {
    final names = districts.map((d) => d.province).toSet().toList()..sort();
    return names;
  }
}
