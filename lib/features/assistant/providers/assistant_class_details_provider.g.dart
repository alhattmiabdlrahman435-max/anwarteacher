// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_class_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssistantClassDetails)
final assistantClassDetailsProvider = AssistantClassDetailsFamily._();

final class AssistantClassDetailsProvider
    extends $NotifierProvider<AssistantClassDetails, List<StudentEntity>> {
  AssistantClassDetailsProvider._({
    required AssistantClassDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assistantClassDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assistantClassDetailsHash();

  @override
  String toString() {
    return r'assistantClassDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AssistantClassDetails create() => AssistantClassDetails();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<StudentEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<StudentEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssistantClassDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assistantClassDetailsHash() =>
    r'10cd278f055abf3131563ab5a4d46ec6f7630c71';

final class AssistantClassDetailsFamily extends $Family
    with
        $ClassFamilyOverride<
          AssistantClassDetails,
          List<StudentEntity>,
          List<StudentEntity>,
          List<StudentEntity>,
          String
        > {
  AssistantClassDetailsFamily._()
    : super(
        retry: null,
        name: r'assistantClassDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssistantClassDetailsProvider call(String classId) =>
      AssistantClassDetailsProvider._(argument: classId, from: this);

  @override
  String toString() => r'assistantClassDetailsProvider';
}

abstract class _$AssistantClassDetails extends $Notifier<List<StudentEntity>> {
  late final _$args = ref.$arg as String;
  String get classId => _$args;

  List<StudentEntity> build(String classId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<StudentEntity>, List<StudentEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<StudentEntity>, List<StudentEntity>>,
              List<StudentEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
