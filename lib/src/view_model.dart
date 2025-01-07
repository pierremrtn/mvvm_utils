import 'package:flutter/foundation.dart';

import 'command.dart';
import 'stream_value.dart';

base class ViewModel extends ChangeNotifier {
  ViewModel() {
    init();
  }

  final List<Function()> _cleanup = [];

  @mustCallSuper
  void init() {}

  @override
  @mustCallSuper
  void dispose() {
    for (final cb in _cleanup) {
      cb();
    }
    super.dispose();
  }

  StreamValue<T> streamValue<T>(
    Stream<T> stream, {
    bool listenImmediately = true,
  }) {
    final sv = StreamValue(stream, listenImmediately: listenImmediately);
    _cleanup.add(sv.dispose);
    return sv;
  }

  Command0<T> command<T>(
    CommandAction0<T> action, {
    CommandRestrictionController? restrictionController,
  }) {
    final c = Command0(action);
    _cleanup.add(c.dispose);
    return c;
  }

  Command1<P, R> command1<P, R>(
    CommandAction1<P, R> action, {
    CommandRestrictionController? restrictionController,
  }) {
    final c = Command1(action);
    _cleanup.add(c.dispose);
    return c;
  }
}
