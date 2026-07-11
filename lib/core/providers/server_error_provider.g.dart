// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServerErrorNotifier)
final serverErrorProvider = ServerErrorNotifierProvider._();

final class ServerErrorNotifierProvider
    extends $NotifierProvider<ServerErrorNotifier, bool> {
  ServerErrorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverErrorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverErrorNotifierHash();

  @$internal
  @override
  ServerErrorNotifier create() => ServerErrorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$serverErrorNotifierHash() =>
    r'1ac1c968166cfd758a0050cc51ea1e2e3cc80186';

abstract class _$ServerErrorNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
