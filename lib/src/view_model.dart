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
      try {
        cb();
      } catch (e) {
        continue;
      }
    }
    super.dispose();
  }

  void listenTo(Listenable listenable, VoidCallback callback) {
    listenable.addListener(callback);
    _cleanup.add(() => listenable.removeListener(callback));
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
    CommandSuccessCallback<T>? onSuccess,
    CommandFailureCallback? onFailure,
  }) {
    final c = Command0(
      action,
      restrictionController: restrictionController,
      onFailure: onFailure,
      onSuccess: onSuccess,
    );
    _cleanup.add(c.dispose);
    return c;
  }

  Command1<P, R> command1<P, R>(
    CommandAction1<P, R> action, {
    CommandRestrictionController? restrictionController,
    CommandSuccessCallback<R>? onSuccess,
    CommandFailureCallback? onFailure,
  }) {
    final c = Command1(
      action,
      restrictionController: restrictionController,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
    _cleanup.add(c.dispose);
    return c;
  }
}
