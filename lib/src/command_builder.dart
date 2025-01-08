import 'package:flutter/widgets.dart';

import 'command.dart';
import 'result.dart';

abstract class CommandBuilder<T> extends StatelessWidget {
  const factory CommandBuilder.result({
    Key key,
    required Command<T> command,
    required Widget Function(BuildContext context, T value) success,
    required Widget Function(BuildContext context, Object error) failure,
    required Widget Function(BuildContext context) orElse,
  }) = _CommandBuilderResult<T>;

  const factory CommandBuilder.status({
    Key key,
    required Command<T> command,
    required Widget Function(BuildContext context) initial,
    required Widget Function(BuildContext context, T value) success,
    required Widget Function(BuildContext context, Object error) failure,
    required Widget Function(BuildContext context) running,
  }) = _CommandBuilderStatus<T>;
}

class _CommandBuilderResult<T> extends StatelessWidget
    implements CommandBuilder<T> {
  const _CommandBuilderResult({
    super.key,
    required this.command,
    required this.success,
    required this.failure,
    required this.orElse,
  });

  final Command<T> command;
  final Widget Function(BuildContext context, T value) success;
  final Widget Function(BuildContext context, Object error) failure;
  final Widget Function(BuildContext context) orElse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => switch (command.result) {
        Success(:final value) => success(context, value),
        Failure(:final error) => failure(context, error),
        null => orElse(context),
      },
    );
  }
}

class _CommandBuilderStatus<T> extends StatelessWidget
    implements CommandBuilder<T> {
  const _CommandBuilderStatus({
    super.key,
    required this.command,
    required this.initial,
    required this.success,
    required this.failure,
    required this.running,
  });

  final Command<T> command;
  final Widget Function(BuildContext context) initial;
  final Widget Function(BuildContext context, T value) success;
  final Widget Function(BuildContext context, Object error) failure;
  final Widget Function(BuildContext context) running;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => switch (command.status) {
        CommandStatus.initial => initial(context),
        CommandStatus.success => success(context, command.value as T),
        CommandStatus.failure => failure(context, command.error!),
        CommandStatus.running => running(context),
      },
    );
  }
}
