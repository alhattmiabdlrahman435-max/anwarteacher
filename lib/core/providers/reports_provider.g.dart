// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Reports)
final reportsProvider = ReportsProvider._();

final class ReportsProvider extends $NotifierProvider<Reports, List<Report>> {
  ReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsHash();

  @$internal
  @override
  Reports create() => Reports();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Report> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Report>>(value),
    );
  }
}

String _$reportsHash() => r'7a7f4c9809b0be5205e0958c45b428e1c3b78840';

abstract class _$Reports extends $Notifier<List<Report>> {
  List<Report> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Report>, List<Report>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Report>, List<Report>>,
              List<Report>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
