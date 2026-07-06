// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Classes)
final classesProvider = ClassesProvider._();

final class ClassesProvider extends $NotifierProvider<Classes, List<String>> {
  ClassesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'classesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$classesHash();

  @$internal
  @override
  Classes create() => Classes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$classesHash() => r'ffdb43fefac18a62920da6b15007688af970e19d';

abstract class _$Classes extends $Notifier<List<String>> {
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

@ProviderFor(SelectedClass)
final selectedClassProvider = SelectedClassProvider._();

final class SelectedClassProvider
    extends $NotifierProvider<SelectedClass, String> {
  SelectedClassProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedClassProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedClassHash();

  @$internal
  @override
  SelectedClass create() => SelectedClass();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedClassHash() => r'7ab5bd9ba1d1f8c62deb8db07d9cf468a30eaf1c';

abstract class _$SelectedClass extends $Notifier<String> {
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
