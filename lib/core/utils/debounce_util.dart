import 'dart:async';
import 'package:flutter/material.dart';

class DebounceUtil {
  static Timer? _timer;

  static void run(VoidCallback action, {int milliseconds = 500}) {
    if (_timer?.isActive ?? false) return;
    _timer = Timer(Duration(milliseconds: milliseconds), () {});
    action();
  }
}
