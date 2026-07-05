// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TeacherScheduleState)
final teacherScheduleStateProvider = TeacherScheduleStateProvider._();

final class TeacherScheduleStateProvider
    extends
        $AsyncNotifierProvider<
          TeacherScheduleState,
          Map<String, List<TeacherPeriod>>
        > {
  TeacherScheduleStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherScheduleStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherScheduleStateHash();

  @$internal
  @override
  TeacherScheduleState create() => TeacherScheduleState();
}

String _$teacherScheduleStateHash() =>
    r'ebc027d0e63d1a4f6305d70b1876ed38e3bd7929';

abstract class _$TeacherScheduleState
    extends $AsyncNotifier<Map<String, List<TeacherPeriod>>> {
  FutureOr<Map<String, List<TeacherPeriod>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<TeacherPeriod>>>,
              Map<String, List<TeacherPeriod>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<TeacherPeriod>>>,
                Map<String, List<TeacherPeriod>>
              >,
              AsyncValue<Map<String, List<TeacherPeriod>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
