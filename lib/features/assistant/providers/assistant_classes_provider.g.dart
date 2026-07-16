// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_classes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssistantClasses)
final assistantClassesProvider = AssistantClassesProvider._();

final class AssistantClassesProvider
    extends $NotifierProvider<AssistantClasses, List<ClassroomEntity>> {
  AssistantClassesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantClassesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantClassesHash();

  @$internal
  @override
  AssistantClasses create() => AssistantClasses();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ClassroomEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ClassroomEntity>>(value),
    );
  }
}

String _$assistantClassesHash() => r'91764c0eb88ee5470096cafae0169610d8de233c';

abstract class _$AssistantClasses extends $Notifier<List<ClassroomEntity>> {
  List<ClassroomEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ClassroomEntity>, List<ClassroomEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ClassroomEntity>, List<ClassroomEntity>>,
              List<ClassroomEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
