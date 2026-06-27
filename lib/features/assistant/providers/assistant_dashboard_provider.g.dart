// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assistantDashboardStats)
final assistantDashboardStatsProvider = AssistantDashboardStatsProvider._();

final class AssistantDashboardStatsProvider
    extends $FunctionalProvider<DashboardStats, DashboardStats, DashboardStats>
    with $Provider<DashboardStats> {
  AssistantDashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantDashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantDashboardStatsHash();

  @$internal
  @override
  $ProviderElement<DashboardStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardStats create(Ref ref) {
    return assistantDashboardStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardStats>(value),
    );
  }
}

String _$assistantDashboardStatsHash() =>
    r'beb3fa3e0e50e2534a7443f28f07cad2bd1d65d5';
