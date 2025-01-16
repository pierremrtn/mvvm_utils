typedef FutureResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success;
  bool get isFailure => this is Failure;

  U fold<U>({
    required U Function(T success) success,
    required U Function(Object error) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Failure(:final error) => failure(error),
      };

  // /// Unsafe operation
  // Success<T> get asSuccess => this as Success<T>;

  // /// Unsafe operation
  // Failure<T> get asFailure => this as Failure<T>;
}

extension ResultValue<R> on Result<R> {
  Object? get error => switch (this) {
        Failure(:final error) => error,
        _ => null,
      };
  R? get value => switch (this) {
        Success(:final value) => value,
        _ => null,
      };
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final Object error;

  Failure<U> propagate<U>() => Failure(error);
}
