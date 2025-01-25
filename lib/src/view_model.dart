import 'dart:async';

import 'package:flutter/foundation.dart';

import 'command/command.dart';

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

  /// Register [dispose] to be call when this [ViewModel] is disposed
  void addDisposer(VoidCallback dispose) {
    _cleanup.add(dispose);
  }

  /// Add [listener] to [listenable] and remove it when this [ViewModel] is disposed
  void autoDisposeListener(Listenable listenable, VoidCallback listener) {
    listenable.addListener(listener);
    addDisposer(() => listenable.removeListener(listener));
  }

  /// Add a disposer that cancel [subscription] when this [ViewModel] is disposed
  void autoDisposeStreamSubscription(StreamSubscription sub) {
    addDisposer(() => sub.cancel());
  }

  /// Create a command0 and register it for automatic disposal
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
    addDisposer(c.dispose);
    return c;
  }

  /// Create a command1 and register it for automatic disposal
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
    addDisposer(c.dispose);
    return c;
  }
}
