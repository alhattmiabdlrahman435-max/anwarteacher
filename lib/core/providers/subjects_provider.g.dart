// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Subjects)
final subjectsProvider = SubjectsProvider._();

final class SubjectsProvider extends $NotifierProvider<Subjects, List<String>> {
  SubjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subjectsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subjectsHash();

  @$internal
  @override
  Subjects create() => Subjects();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$subjectsHash() => r'bda397e6614413e77b432e2eb2e4785c64bde64a';

abstract class _$Subjects extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedSubject)
final selectedSubjectProvider = SelectedSubjectProvider._();

final class SelectedSubjectProvider
    extends $NotifierProvider<SelectedSubject, String> {
  SelectedSubjectProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSubjectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSubjectHash();

  @$internal
  @override
  SelectedSubject create() => SelectedSubject();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedSubjectHash() => r'e138a39a12c6fa4ae294c9cd39aae5385d82625a';

abstract class _$SelectedSubject extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
