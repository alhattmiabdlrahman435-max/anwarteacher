// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

final class NotificationsProvider
    extends $NotifierProvider<Notifications, List<AppNotificationModel>> {
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppNotificationModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppNotificationModel>>(value),
    );
  }
}

String _$notificationsHash() => r'd1114b8ab3760b7715d1bbf412be6f7103b61eef';

abstract class _$Notifications extends $Notifier<List<AppNotificationModel>> {
  List<AppNotificationModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<List<AppNotificationModel>, List<AppNotificationModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<AppNotificationModel>,
                List<AppNotificationModel>
              >,
              List<AppNotificationModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
