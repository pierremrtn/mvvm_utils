import 'package:flutter/widgets.dart';
import 'package:mvvm_utils/mvvm_utils.dart';
import 'package:mvvm_utils/src/command/command.dart';

abstract class CommandBuilder<T> extends StatelessWidget {
  const factory CommandBuilder({
    Key key,
    required Command<T> command,
    required Widget Function(BuildContext context) initial,
    required Widget Function(BuildContext context, T value) success,
    required Widget Function(BuildContext context, Object error) failure,
    required Widget Function(BuildContext context) running,
  }) = _CommandBuilderState<T>;

  const factory CommandBuilder.fallback({
    required Command<T> command,
    Widget Function(BuildContext context)? initial,
    Widget Function(BuildContext context)? running,
    Widget Function(BuildContext context, T value)? success,
    Widget Function(BuildContext context, Object error)? failure,
    required Widget Function(BuildContext context) orElse,
  }) = _CommandBuilderStateWithFallback<T>;
}

class _CommandBuilderState<T> extends StatelessWidget
    implements CommandBuilder<T> {
  const _CommandBuilderState({
    super.key,
    required this.command,
    required this.initial,
    required this.running,
    required this.success,
    required this.failure,
  });

  final Command<T> command;
  final Widget Function(BuildContext context) initial;
  final Widget Function(BuildContext context) running;
  final Widget Function(BuildContext context, T value) success;
  final Widget Function(BuildContext context, Object error) failure;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => command.state.when(
        initial: () => initial(context),
        success: (value) => success(context, value),
        failure: (error) => failure(context, error),
        running: () => running(context),
      ),
    );
  }
}

class _CommandBuilderStateWithFallback<T> extends StatelessWidget
    implements CommandBuilder<T> {
  const _CommandBuilderStateWithFallback({
    super.key,
    required this.command,
    this.initial,
    this.running,
    this.success,
    this.failure,
    required this.orElse,
  });

  final Command<T> command;
  final Widget Function(BuildContext context)? initial;
  final Widget Function(BuildContext context)? running;
  final Widget Function(BuildContext context, T value)? success;
  final Widget Function(BuildContext context, Object error)? failure;
  final Widget Function(BuildContext context) orElse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => command.state.when(
        initial: () => initial?.call(context) ?? orElse(context),
        success: (value) => success?.call(context, value) ?? orElse(context),
        failure: (error) => failure?.call(context, error) ?? orElse(context),
        running: () => running?.call(context) ?? orElse(context),
      ),
    );
  }
}
