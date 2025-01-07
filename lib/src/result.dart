typedef FutureResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result();

  T? get value;

  Object? get error;

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

class Success<T> extends Result<T> {
  const Success(this.value);

  @override
  final T value;

  @override
  get error => null;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  @override
  final Object error;

  @override
  get value => null;

  Failure<U> propagate<U>() => Failure(error);
}

extension ObjectToResult<T extends Object> on T {
  Success<T> get toSuccess => Success(this);
  Failure<T> get toFailure => Failure(this);
}
