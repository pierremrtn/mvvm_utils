import 'package:flutter/widgets.dart';
import 'package:mvvm_utils/mvvm_utils.dart';

class CommandListener<R> extends StatefulWidget {
  const CommandListener({
    super.key,
    required this.command,
    required this.child,
    this.onSuccess,
    this.onFailure,
    this.onChanged,
    this.onRunning,
  });

  final Command<R> command;
  final void Function()? onChanged;
  final CommandSuccessCallback? onSuccess;
  final CommandFailureCallback? onFailure;
  final VoidCallback? onRunning;
  final Widget child;

  @override
  State<CommandListener<R>> createState() => _CommandListenerState<R>();
}

class _CommandListenerState<R> extends State<CommandListener<R>> {
  @override
  void initState() {
    super.initState();
    widget.command.addListener(_handleCommandChanges);
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    if (old.command != widget.command) {
      old.command.removeListener(_handleCommandChanges);
      widget.command.addListener(_handleCommandChanges);
    }
  }

  @override
  void dispose() {
    widget.command.removeListener(_handleCommandChanges);
    super.dispose();
  }

  void _handleCommandChanges() {
    widget.onChanged?.call();
    switch (widget.command.result) {
      case null:
        widget.onRunning?.call();
      case Success(:final value):
        widget.onSuccess?.call(value);
      case Failure(:final Object error):
        widget.onFailure?.call(error);
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
