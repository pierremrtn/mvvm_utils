import 'package:flutter/widgets.dart';

import 'command.dart';
import 'result.dart';

class CommandBuilder<T> extends StatelessWidget {
  const CommandBuilder({
    super.key,
    required this.command,
    required this.success,
    required this.failure,
    required this.loading,
  });

  final Command<T> command;
  final Widget Function(BuildContext context, T value) success;
  final Widget Function(BuildContext context, Object error) failure;
  final Widget Function(BuildContext context) loading;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) => switch (command.result) {
        Success(:final value) => success(context, value),
        Failure(:final error) => failure(context, error),
        null => loading(context),
      },
    );
  }
}
