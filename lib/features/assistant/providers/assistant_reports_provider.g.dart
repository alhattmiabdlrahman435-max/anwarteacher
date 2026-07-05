// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssistantReports)
final assistantReportsProvider = AssistantReportsProvider._();

final class AssistantReportsProvider
    extends $NotifierProvider<AssistantReports, AttendanceStatsEntity> {
  AssistantReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantReportsHash();

  @$internal
  @override
  AssistantReports create() => AssistantReports();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceStatsEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceStatsEntity>(value),
    );
  }
}

String _$assistantReportsHash() => r'becc2877ce3a2e95a6bde05d96497c1faf33784b';

abstract class _$AssistantReports extends $Notifier<AttendanceStatsEntity> {
  AttendanceStatsEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AttendanceStatsEntity, AttendanceStatsEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AttendanceStatsEntity, AttendanceStatsEntity>,
              AttendanceStatsEntity,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
