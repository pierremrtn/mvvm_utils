# MVVM Utils

⚠️ This package is under development.

A collection of convenience methods and utilities to facilitate [Flutter official Architecture recommandation](https://docs.flutter.dev/app-architecture/guide)

**Result**

basic usage:
```dart
Result<String> myFunction() {
    try {
        ...
        return Success("ok");
    } catch (e) {
        return Failure(e);
    }
}

final res = myFunction();
res.fold(
    success: (v) {},
    failure: (e) {}
);
```

Result is a sealed class, so you can uses pattern matching
```dart
final v = switch(result) {
    Success(:final value) => ...,
    Failure(:final error) => ...,
}
```

This package also export a `FutureResult<T>`, which is simply a typedef for `Future<Result<T>>`;


**Command**
// TODO

**ViewModel**
// TODO

**Inject**
// TODO

**CommandBuilder**
// TODO
