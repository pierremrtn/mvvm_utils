import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<R> = FutureOr<Result<R>> Function();
typedef CommandAction1<P, R> = FutureOr<Result<R>> Function(P);

abstract class CommandRestrictionController extends Listenable {
  const CommandRestrictionController();
  bool get enabled;
}

class DependsOnCommands
    with ChangeNotifier
    implements CommandRestrictionController {
  DependsOnCommands(List<Command> commands)
      : _commands = commands,
        _allCommands = Listenable.merge(commands) {
    _allCommands.addListener(notifyListeners);
  }

  final Listenable _allCommands;
  final List<Command> _commands;

  @override
  bool get enabled => _commands.none((c) => c.succeeded == false);
}

class AlwaysEnabledCommand implements CommandRestrictionController {
  const AlwaysEnabledCommand();

  @override
  final bool enabled = true;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class Command<R> with ChangeNotifier {
  Command({CommandRestrictionController? restrictionController})
      : _restrictionController = restrictionController {
    _restrictionController?.addListener(notifyListeners);
  }

  final CommandRestrictionController? _restrictionController;

  Result<R>? _result;
  bool _running = false;

  bool get enabled => _restrictionController?.enabled ?? true;
  bool get running => _running;
  bool get failed => _result is Failure;
  bool get succeeded => _result is Success;
  bool get completed => _result != null;
  Object? get error => _result?.error;
  R? get value => _result?.value;
  Result<R>? get result => _result;

  FutureOr<void> _execute(FutureOr<Result<R>> Function() action) async {
    if (_running || _restrictionController?.enabled == false) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } catch (e) {
      _result = Failure(e);
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _restrictionController?.removeListener(notifyListeners);
    super.dispose();
  }
}

/// A [Command] that accepts no arguments.
final class Command0<T> extends Command<T> {
  /// Creates a [Command0] with the provided [CommandAction0].
  Command0(
    this._action, {
    super.restrictionController,
  });

  final CommandAction0<T> _action;

  /// Executes the action.
  Future<void> execute() async {
    await _execute(() => _action());
  }
}

class Command1<P, R> extends Command<R> {
  Command1(
    this._action, {
    super.restrictionController,
  });

  final CommandAction1<P, R> _action;

  FutureOr<void> execute(P param) async {
    await _execute(() => _action(param));
  }
}
