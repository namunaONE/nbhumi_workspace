/// Data layer — repositories, services, and Supabase client for nBhumi.
///
/// The `View → ViewModel → Repository → Service → Supabase` chain (Rule 18).
/// Repositories are the only thing a ViewModel talks to; nothing above this
/// layer may import `supabase_flutter` directly.
library;

export 'src/errors/postgrest_error_mapper.dart';
export 'src/providers/app_provider_observer.dart';
export 'src/providers/repositories.dart';
export 'src/providers/session_logging.dart';
export 'src/providers/session_providers.dart';
export 'src/repositories/auth_repository.dart';
export 'src/repositories/listing_repository.dart';
export 'src/repositories/reference_repository.dart';
export 'src/repositories/user_repository.dart';
export 'src/services/auth_service.dart';
export 'src/services/storage_service.dart';
export 'src/services/supabase_service.dart';
