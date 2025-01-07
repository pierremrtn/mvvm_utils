import 'package:flutter/widgets.dart';

import 'view_model.dart';

/// A widget that instantiate a ViewModel T during initialization and dispose in
/// when widget is removed from the tree
///
/// This is useful to prevent the view model to be re-created if the widget rebuild.
/// This widget does not rebuild if view model notify listener
class Inject<T extends ViewModel> extends StatefulWidget {
  const Inject({
    super.key,
    required this.create,
    required this.builder,
  });

  final T Function(BuildContext context) create;
  final Widget Function(BuildContext, T) builder;

  @override
  State<Inject<T>> createState() => _InjectState<T>();
}

class _InjectState<T extends ViewModel> extends State<Inject<T>> {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _viewModel);
  }
}
