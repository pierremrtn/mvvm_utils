sealed class CommandState<T> {
  factory CommandState.initial() = _Initial.new;
  factory CommandState.running() = _Running.new;
  factory CommandState.success(T result) = _Succeeded.new;
  factory CommandState.failure(Object error) = _Failed.new;
}

class _Initial<T> implements CommandState<T> {}

class _Running<T> implements CommandState<T> {}

class _Succeeded<T> implements CommandState<T> {
  final T result;

  const _Succeeded(this.result);
}

class _Failed<T> implements CommandState<T> {
  final Object error;

  const _Failed(this.error);
}

extension CommandMethods<T> on CommandState<T> {
  U when<U>({
    required U Function() initial,
    required U Function() running,
    required U Function(T result) success,
    required U Function(Object error) failure,
  }) =>
      switch (this) {
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
      switch (this) {
        _Initial() => initial?.call(),
        _Running() => running?.call(),
        _Succeeded(:final result) => success?.call(result),
        _Failed(:final error) => failure?.call(error),
      };

  bool get isInitial => this is _Initial;
  bool get isRunning => this is _Running;
  bool get isFailed => this is _Failed;
  bool get isSucceeded => this is _Succeeded;
  bool get isCompleted => isFailed || isSucceeded;

  Object? get errorOrNull => switch (this) {
        _Failed(:final error) => error,
        _ => null,
      };

  T? get resultOrNull => switch (this) {
        _Succeeded(:final result) => result,
        _ => null,
      };
}
