import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

enum ConnectivityStatus {
  online,
  offline,
}

@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityStatus build() {
    _subscription?.cancel();
    _subscription = null;
    
    _init();
    
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return ConnectivityStatus.online;
  }

  Future<void> _init() async {
    // Check initial state
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {
      state = ConnectivityStatus.offline;
    }

    // Listen for updates
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else {
      state = ConnectivityStatus.online;
    }
  }
}
