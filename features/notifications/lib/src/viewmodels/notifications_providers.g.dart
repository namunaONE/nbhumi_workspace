// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the inbox live over Realtime.
///
/// Subscribes with the caller's `user_id=eq.<uid>` filter when a session
/// exists and does nothing signed out: a guest has no inbox, so there is
/// nothing to keep live. Every event invalidates the inbox page and the
/// badge count; watching this provider is what keeps the subscription (and
/// therefore the freshness) alive, so screens that render inbox data watch
/// it alongside the data providers.
///
/// The channel is released on dispose: without that every navigation to the
/// inbox would stack another socket listener.

@ProviderFor(notificationsRealtime)
final notificationsRealtimeProvider = NotificationsRealtimeProvider._();

/// Keeps the inbox live over Realtime.
///
/// Subscribes with the caller's `user_id=eq.<uid>` filter when a session
/// exists and does nothing signed out: a guest has no inbox, so there is
/// nothing to keep live. Every event invalidates the inbox page and the
/// badge count; watching this provider is what keeps the subscription (and
/// therefore the freshness) alive, so screens that render inbox data watch
/// it alongside the data providers.
///
/// The channel is released on dispose: without that every navigation to the
/// inbox would stack another socket listener.

final class NotificationsRealtimeProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Keeps the inbox live over Realtime.
  ///
  /// Subscribes with the caller's `user_id=eq.<uid>` filter when a session
  /// exists and does nothing signed out: a guest has no inbox, so there is
  /// nothing to keep live. Every event invalidates the inbox page and the
  /// badge count; watching this provider is what keeps the subscription (and
  /// therefore the freshness) alive, so screens that render inbox data watch
  /// it alongside the data providers.
  ///
  /// The channel is released on dispose: without that every navigation to the
  /// inbox would stack another socket listener.
  NotificationsRealtimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRealtimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRealtimeHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return notificationsRealtime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationsRealtimeHash() =>
    r'365358a6553d983291beaeabbae4839f34b6eca0';
