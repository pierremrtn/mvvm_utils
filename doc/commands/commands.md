# Commands

Command are listenable objects that encapsulate a fallible action, or *command* and expose the result to listener.
Commands are typically created inside view models and consumed in views.

Command can be executed using `execute()` method.

There are two types of commands: Command0 and Command1. The only difference between them is that Command1 takes a parameter for it's action.

```dart
command0.execute()
command1.execute(param)
```

Command hold a Result<T> with T matching the return types of the action, allowing clients to react based on the command status.

The value returned by the command **should not** be used as a ViewModel's state. While it's can work for simple cases, this doesn't scale well and create complicated and difficult to read code.

Instead, command's action **must emit a new ViewModel state**, only returning data that facilitate the result handling for the caller. Most commands do not need a return value.

The purpose of a command is to represent the status of a computation in the ViewModel, not to hold resulting data.

## Usage

```dart
class ViewModel {
    ViewModel() {
        doSomething = Command0(() { /**...**/ })
    }

    late final Command0<void> doSomething;
}
```

```dart
class ViewModel extends ValueNotifier<State> {
    ViewModel(this.repository) {
        doSomething = Command0(_fetchData);
    }

    final Repository repository;
    late final Command0<void> fetchData;

    Future<void> _fetchData() async {
        final data = await repository.fetch(); // perform action that can throw
        if (someCond == false) throw "Incorrect data"; // additional check
        value = data; // update view model state
    }
}

class View extends StatelessWidget {
    View({
        super.key, 
        required this.viewModel,
    });

    final ViewModel viewModel;

    Widget build(BuildContext context) {
        return CommandListener(
            command: viewModel.fetchData,
            onRunning: () => print("running"),
            child: CommandBuilder.fallback(
                command: viewModel.fetchData
                success: (context, result) => Text("Success: $result"),
                error: (context, error) => Text("Error: $error"),
                orElse: (context) => CircularProgressIndicator(),
            ), 
        );
    }
}
```