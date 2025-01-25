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
    this.onEnabledChanged,
  });

  final Command<R> command;
  final void Function()? onChanged;
  final VoidCallback? onRunning;
  final CommandSuccessCallback<R>? onSuccess;
  final CommandFailureCallback? onFailure;
  final ValueChanged<bool>? onEnabledChanged;
  final Widget child;

  @override
  State<CommandListener<R>> createState() => _CommandListenerState<R>();
}

class _CommandListenerState<R> extends State<CommandListener<R>> {
  late bool commandEnabled;

  @override
  void initState() {
    super.initState();
    commandEnabled = widget.command.enabled;
    widget.command.addListener(_handleCommandStateChanges);
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    if (old.command != widget.command) {
      commandEnabled = widget.command.enabled;
      widget.command.addListener(_handleCommandStateChanges);
    }
  }

  @override
  void dispose() {
    widget.command.removeListener(_handleCommandStateChanges);
    super.dispose();
  }

  void _handleCommandStateChanges() {
    widget.onChanged?.call();
    if (commandEnabled != widget.command.enabled) {
      widget.onEnabledChanged?.call(widget.command.enabled);
      commandEnabled = widget.command.enabled;
    }
    widget.command.state.whenOrNull(
      running: widget.onRunning,
      success: widget.onSuccess,
      failure: widget.onFailure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
