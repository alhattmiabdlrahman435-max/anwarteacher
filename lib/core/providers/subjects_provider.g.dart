// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subjects)
final subjectsProvider = SubjectsProvider._();

final class SubjectsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  SubjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subjectsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return subjects(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$subjectsHash() => r'a4dddb85e4b13f1b9b9503156f274056de3475af';

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
        isAutoDispose: true,
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

String _$selectedSubjectHash() => r'745d145d5707b72a36f1cb0cb0b4f4713d0e1df2';

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
