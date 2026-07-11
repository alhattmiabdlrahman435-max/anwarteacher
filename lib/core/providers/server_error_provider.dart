import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_error_provider.g.dart';

@Riverpod(keepAlive: true)
class ServerErrorNotifier extends _$ServerErrorNotifier {
  @override
  bool build() {
    return false;
  }

  void setHasError(bool hasError) {
    if (state != hasError) {
      state = hasError;
    }
  }
}
