import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_utils/mvvm_utils.dart';

part 'command_state.dart';

typedef CommandAction0<R> = FutureOr<Result<R>> Function();
typedef CommandAction1<P, R> = FutureOr<Result<R>> Function(P);
typedef CommandSuccessCallback<R> = void Function(R value);
typedef CommandFailureCallback = void Function(Object error);

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
  bool get enabled => _commands.none((c) => c.state.isSucceeded == false);
}

class CommandRestrictionSelector<T extends Listenable>
    implements CommandRestrictionController {
  CommandRestrictionSelector(this.listenable, this.selector);

  final T listenable;
  final bool Function(T) selector;

  @override
  bool get enabled => selector(listenable);

  @override
  void addListener(VoidCallback listener) => listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      listenable.removeListener(listener);
}

class Command<R> with ChangeNotifier implements CommandStateAccessor<R> {
  Command({
    CommandRestrictionController? restrictionController,
    this.onFailure,
    this.onSuccess,
  }) : _restrictionController = restrictionController {
    _restrictionController?.addListener(notifyListeners);
  }

  final CommandSuccessCallback<R>? onSuccess;
  final CommandFailureCallback? onFailure;
  final CommandRestrictionController? _restrictionController;

  CancelableOperation<Result<R>>? _currentAction;

  @override
  CommandState<R> _state = CommandState.initial();
  CommandState<R> get state => _state;

  bool get enabled => _restrictionController?.enabled ?? true;
  bool get disabled => !enabled;

  /// {@template commandExecute}
  /// Execute [action] and returns its result, or null in one of the following scenario:
  /// - The command is already executing
  /// - The current execution as been canceled
  /// - The command is disabled
  ///
  /// When [reset] is true, action is called even if any previous action is still
  /// being executed, and the previous execute call will return null
  ///
  /// Any error thrown by action will be catch and interpreted as a Failure state
  /// {@endtemplate}
  FutureOr<Result<R>?> _execute(
    CommandAction0<R> action, {
    bool reset = false,
    CommandSuccessCallback<R>? onSuccess,
    CommandFailureCallback? onFailure,
  }) async {
    if (_restrictionController?.enabled == false) {
      return null;
    }

    if (state.isRunning) {
      if (reset) {
        _currentAction?.cancel();
      } else {
        return null;
      }
    }

    _state = CommandState.running();
    notifyListeners();

    late final Result<R> executionResult;
    try {
      _currentAction = CancelableOperation.fromFuture(
        Future.value(action()),
      );

      final resultOrCancelation = await _currentAction?.valueOrCancellation();
      if (resultOrCancelation == null) {
        return null;
      } else {
        executionResult = resultOrCancelation;
      }

      _state = switch (executionResult) {
        Success(:final value) => CommandState.success(value),
        Failure(:final error) => CommandState.failure(error)
      };
    } catch (e) {
      executionResult = Failure(e);
      _state = CommandState.failure(e);
    } finally {
      state.whenOrNull(
        success: (value) {
          onSuccess?.call(value);
          this.onSuccess?.call(value);
        },
        failure: (error) {
          onFailure?.call(error);
          this.onFailure?.call(error);
        },
      );
      notifyListeners();
    }
    return executionResult;
  }

  void reset() {
    _currentAction?.cancel();
    _state = CommandState.initial();
    notifyListeners();
  }

  void cancel() {
    _currentAction?.cancel();
    _state = CommandState.initial();
    notifyListeners();
  }

  @override
  void dispose() {
    _currentAction?.cancel();
    _restrictionController?.removeListener(notifyListeners);
    super.dispose();
  }
}

/// A [Command] that accepts no arguments.
class Command0<R> extends Command<R> {
  /// Creates a [Command0] with the provided [CommandAction0].
  Command0(
    this._action, {
    super.restrictionController,
    super.onFailure,
    super.onSuccess,
  });

  final CommandAction0<R> _action;

  FutureOr<Result<R>?> Function()? asNullableCallback({
    bool nullWhenDisabled = true,
    bool nullWhenRunning = true,
    CommandSuccessCallback<R>? onSuccess,
    CommandFailureCallback? onFailure,
  }) =>
      (nullWhenDisabled && disabled) || (nullWhenRunning && state.isRunning)
          ? null
          : () => this.execute(onSuccess: onSuccess, onFailure: onFailure);

  /// {@macro commandExecute}
  FutureOr<Result<R>?> execute({
    bool reset = false,
    CommandSuccessCallback<R>? onSuccess,
    CommandFailureCallback? onFailure,
  }) async {
    return await _execute(
      () => _action(),
      reset: reset,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
}

class Command1<P, R> extends Command<R> {
  Command1(
    this._action, {
    super.restrictionController,
    super.onFailure,
    super.onSuccess,
  });

  final CommandAction1<P, R> _action;

  /// {@macro commandExecute}
  FutureOr<Result<R>?> execute(
    P param, {
    bool reset = false,
    CommandSuccessCallback<R>? onSuccess,
    CommandFailureCallback? onFailure,
  }) async {
    return await _execute(
      () => _action(param),
      reset: reset,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
}
