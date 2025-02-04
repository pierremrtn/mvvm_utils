part of "command.dart";

/// A shared interface to allows using same utils implementation for both CommandState and Command
abstract interface class CommandStateAccessor<T> {
  CommandState<T> get _state;
}

sealed class CommandState<T> implements CommandStateAccessor<T> {
  const CommandState._();

  @override
  CommandState<T> get _state => this;

  factory CommandState.initial() = _Initial.new;
  factory CommandState.running() = _Running.new;
  factory CommandState.success(T result) = _Succeeded.new;
  factory CommandState.failure(Object error) = _Failed.new;
}

class _Initial<T> extends CommandState<T> {
  const _Initial() : super._();
}

class _Running<T> extends CommandState<T> {
  const _Running() : super._();
}

class _Succeeded<T> extends CommandState<T> {
  const _Succeeded(this.result) : super._();

  final T result;
}

class _Failed<T> extends CommandState<T> {
  const _Failed(this.error) : super._();

  final Object error;
}

extension CommandUtils<T> on CommandStateAccessor<T> {
  U when<U>({
    required U Function() initial,
    required U Function() running,
    required U Function(T result) success,
    required U Function(Object error) failure,
  }) =>
      switch (_state) {
        _Initial() => initial(),
        _Running() => running(),
        _Succeeded(:final result) => success(result),
        _Failed(:final error) => failure(error),
      };

  U? whenOrNull<U>({
    U Function()? initial,
    U Function()? running,
    U Function(T result)? success,
    U Function(Object error)? failure,
  }) =>
      switch (_state) {
        _Initial() => initial?.call(),
        _Running() => running?.call(),
        _Succeeded(:final result) => success?.call(result),
        _Failed(:final error) => failure?.call(error),
      };

  bool get isInitial => _state is _Initial;
  bool get isRunning => _state is _Running;
  bool get isFailed => _state is _Failed;
  bool get isSucceeded => _state is _Succeeded;
  bool get isCompleted => isFailed || isSucceeded;

  Object? get errorOrNull => switch (_state) {
        _Failed(:final error) => error,
        _ => null,
      };

  T? get resultOrNull => switch (_state) {
        _Succeeded(:final result) => result,
        _ => null,
      };
}
