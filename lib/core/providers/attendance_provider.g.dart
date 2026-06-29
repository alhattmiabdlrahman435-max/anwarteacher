// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyAttendance)
final dailyAttendanceProvider = DailyAttendanceProvider._();

final class DailyAttendanceProvider
    extends $NotifierProvider<DailyAttendance, List<AttendanceRecord>> {
  DailyAttendanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyAttendanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyAttendanceHash();

  @$internal
  @override
  DailyAttendance create() => DailyAttendance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AttendanceRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AttendanceRecord>>(value),
    );
  }
}

String _$dailyAttendanceHash() => r'db8ad11df3138860d50bab7e92debf49cfd5d252';

abstract class _$DailyAttendance extends $Notifier<List<AttendanceRecord>> {
  List<AttendanceRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<AttendanceRecord>, List<AttendanceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AttendanceRecord>, List<AttendanceRecord>>,
              List<AttendanceRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
