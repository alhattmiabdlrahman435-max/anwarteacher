// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyAttendance)
final dailyAttendanceProvider = DailyAttendanceFamily._();

final class DailyAttendanceProvider
    extends $NotifierProvider<DailyAttendance, List<AttendanceRecord>> {
  DailyAttendanceProvider._({
    required DailyAttendanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dailyAttendanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyAttendanceHash();

  @override
  String toString() {
    return r'dailyAttendanceProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is DailyAttendanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyAttendanceHash() => r'b2d3fcb9b40cd847c49ec28344ab7b4b8fc835ad';

final class DailyAttendanceFamily extends $Family
    with
        $ClassFamilyOverride<
          DailyAttendance,
          List<AttendanceRecord>,
          List<AttendanceRecord>,
          List<AttendanceRecord>,
          String
        > {
  DailyAttendanceFamily._()
    : super(
        retry: null,
        name: r'dailyAttendanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DailyAttendanceProvider call(String date) =>
      DailyAttendanceProvider._(argument: date, from: this);

  @override
  String toString() => r'dailyAttendanceProvider';
}

abstract class _$DailyAttendance extends $Notifier<List<AttendanceRecord>> {
  late final _$args = ref.$arg as String;
  String get date => _$args;

  List<AttendanceRecord> build(String date);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(studentAttendanceHistory)
final studentAttendanceHistoryProvider = StudentAttendanceHistoryFamily._();

final class StudentAttendanceHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, AttendanceStatus>>,
          Map<String, AttendanceStatus>,
          FutureOr<Map<String, AttendanceStatus>>
        >
    with
        $FutureModifier<Map<String, AttendanceStatus>>,
        $FutureProvider<Map<String, AttendanceStatus>> {
  StudentAttendanceHistoryProvider._({
    required StudentAttendanceHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentAttendanceHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentAttendanceHistoryHash();

  @override
  String toString() {
    return r'studentAttendanceHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, AttendanceStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, AttendanceStatus>> create(Ref ref) {
    final argument = this.argument as String;
    return studentAttendanceHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAttendanceHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentAttendanceHistoryHash() =>
    r'6e936bbce206e1f9ffbf2cfe3cb215ec913b89ee';

final class StudentAttendanceHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, AttendanceStatus>>,
          String
        > {
  StudentAttendanceHistoryFamily._()
    : super(
        retry: null,
        name: r'studentAttendanceHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentAttendanceHistoryProvider call(String studentId) =>
      StudentAttendanceHistoryProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentAttendanceHistoryProvider';
}
