// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GradesData)
final gradesDataProvider = GradesDataProvider._();

final class GradesDataProvider
    extends $NotifierProvider<GradesData, ClassSubjectGrades> {
  GradesDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gradesDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gradesDataHash();

  @$internal
  @override
  GradesData create() => GradesData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClassSubjectGrades value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClassSubjectGrades>(value),
    );
  }
}

String _$gradesDataHash() => r'3a0ec7801f7686f7ea4b5cd763216d34f8821f45';

abstract class _$GradesData extends $Notifier<ClassSubjectGrades> {
  ClassSubjectGrades build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ClassSubjectGrades, ClassSubjectGrades>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClassSubjectGrades, ClassSubjectGrades>,
              ClassSubjectGrades,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
