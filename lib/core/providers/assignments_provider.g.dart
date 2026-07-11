// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssignmentsData)
final assignmentsDataProvider = AssignmentsDataProvider._();

final class AssignmentsDataProvider
    extends $NotifierProvider<AssignmentsData, List<Assignment>> {
  AssignmentsDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentsDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentsDataHash();

  @$internal
  @override
  AssignmentsData create() => AssignmentsData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Assignment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Assignment>>(value),
    );
  }
}

String _$assignmentsDataHash() => r'f96611b325eeb77ca98c54a834f394520657d074';

abstract class _$AssignmentsData extends $Notifier<List<Assignment>> {
  List<Assignment> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Assignment>, List<Assignment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Assignment>, List<Assignment>>,
              List<Assignment>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
