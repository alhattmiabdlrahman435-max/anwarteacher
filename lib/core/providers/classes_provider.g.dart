// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(classes)
final classesProvider = ClassesProvider._();

final class ClassesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  ClassesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'classesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$classesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return classes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$classesHash() => r'11846b75e0fc47773b70a3f3979a460a92de3065';

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
        isAutoDispose: true,
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

String _$selectedClassHash() => r'6cf2b643028129c4fb7591954a3fe974fd24ba85';

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
