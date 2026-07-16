// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectivityNotifier)
final connectivityProvider = ConnectivityNotifierProvider._();

final class ConnectivityNotifierProvider
    extends $NotifierProvider<ConnectivityNotifier, ConnectivityStatus> {
  ConnectivityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityNotifierHash();

  @$internal
  @override
  ConnectivityNotifier create() => ConnectivityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityStatus>(value),
    );
  }
}

String _$connectivityNotifierHash() =>
    r'1d64db71bdb50f2ab893ccb6242abbe9ea3d3021';

abstract class _$ConnectivityNotifier extends $Notifier<ConnectivityStatus> {
  ConnectivityStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectivityStatus, ConnectivityStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectivityStatus, ConnectivityStatus>,
              ConnectivityStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
