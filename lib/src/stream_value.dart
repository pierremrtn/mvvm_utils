import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

class StreamValue<T> extends ValueNotifier<Result<T>?> {
  StreamValue(
    this._stream, {
    bool listenImmediately = true,
  }) : super(null) {
    if (listenImmediately) {
      startListening();
    }
  }

  void startListening() {
    _sub = _stream.listen(
      _onData,
      onError: _onError,
      // onDone: _onDone,
    );
  }

  final Stream<T> _stream;
  StreamSubscription<T>? _sub;

  bool get hasReceivedData => value != null;

  void _onData(T data) {
    value = Success(data);
  }

  void _onError(Object error) {
    value = Failure(error);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
