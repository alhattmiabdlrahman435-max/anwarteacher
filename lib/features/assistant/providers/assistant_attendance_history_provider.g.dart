// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_attendance_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssistantAttendanceHistory)
final assistantAttendanceHistoryProvider =
    AssistantAttendanceHistoryProvider._();

final class AssistantAttendanceHistoryProvider
    extends
        $NotifierProvider<
          AssistantAttendanceHistory,
          List<AttendanceHistoryEntity>
        > {
  AssistantAttendanceHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantAttendanceHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantAttendanceHistoryHash();

  @$internal
  @override
  AssistantAttendanceHistory create() => AssistantAttendanceHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AttendanceHistoryEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AttendanceHistoryEntity>>(
        value,
      ),
    );
  }
}

String _$assistantAttendanceHistoryHash() =>
    r'df23fff14905f13b99107bfbfe1a23d60dbdcb7f';

abstract class _$AssistantAttendanceHistory
    extends $Notifier<List<AttendanceHistoryEntity>> {
  List<AttendanceHistoryEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              List<AttendanceHistoryEntity>,
              List<AttendanceHistoryEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<AttendanceHistoryEntity>,
                List<AttendanceHistoryEntity>
              >,
              List<AttendanceHistoryEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
