# MVVM Utils

⚠️ This package is under development.

A collection of convenience methods and utilities to build flutter apps that follows MVVM architecture.

TODO:

- StreamValue object to store stream value in view model's state + utils widgets
- Disposer API to add same auto-dispose features to stateful widgets
- Repository utils

## ViewModel and ViewModelMixin

The MVVM Utils package provides two core components for implementing the MVVM pattern in Flutter: the `ViewModelMixin` and the `ViewModel` class.

### ViewModelMixin

The `ViewModelMixin` provides a set of utilities for managing resources and disposing of them properly when the ViewModel is no longer needed. This helps prevent memory leaks and ensures clean cleanup of resources.

#### Key Features

- **Automatic Resource Cleanup**: Register disposable resources that will be automatically cleaned up when the ViewModel is disposed.
- **Listener Management**: Easily manage Flutter widget listeners with automatic cleanup.
- **Stream Subscription Handling**: Manage StreamSubscriptions with automatic cancellation.
- **Command Creation**: Create and automatically dispose of Command objects.

#### Usage Examples

1. **Adding Custom Cleanup Logic**

```dart
class MyViewModel with ViewModelMixin {
  Timer? _refreshTimer;

  void startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) => refresh());
    addDisposer(() => _refreshTimer?.cancel());
  }
}
```

2. **Managing Listeners**

```dart
class MyViewModel with ViewModelMixin {
  final TextEditingController _controller = TextEditingController();

  void setupListeners() {
    autoDisposeListener(_controller, () {
      // Handle text changes
      print(_controller.text);
    });
  }
}
```

3. **Managing Stream Subscriptions**

```dart
class MyViewModel with ViewModelMixin {
  void listenToStream(Stream<Data> dataStream) {
    final subscription = dataStream.listen((data) {
      // Handle data
    });
    autoDisposeStreamSubscription(subscription);
  }
}
```

4. **Creating Commands**

```dart
class MyViewModel with ViewModelMixin {
  late final Command0<void> refreshCommand;

  void init() {
    refreshCommand = command(
      () async => await refreshData(),
      onSuccess: (_) => print('Refresh successful'),
      onFailure: (error) => print('Refresh failed: $error'),
    );
  }
}
```

### ViewModel Class

The `ViewModel` class is a base implementation that combines `ChangeNotifier` with `ViewModelMixin`, providing a foundation for creating ViewModels in your MVVM architecture.

## Result Type

The Result type provides a robust way to handle operation outcomes, representing either success with a value or failure with an error. This pattern helps write more reliable and maintainable code by making error handling explicit and type-safe.

### Core Features

The `Result<T>` class is a sealed class that can be either `Success<T>` or `Failure<T>`, where T is the type of the success value. It provides several methods for safely handling both success and failure cases:

1. **Pattern Matching**: Use `when()` and `whenOrNull()` for exhaustive handling of both success and failure cases.
2. **Selective Handling**: Use `whenSuccess()` and `whenFailure()` to handle specific cases.
3. **Type Conversion**: Use `asSuccess` and `asFailure` for direct type casting when the state is known.
4. **Value Access**: Use the `value` and `error` getters to access the underlying data.

This package also export `FutureResult<T>`, witch is simply a typedef for `Future<Result<T>>`.

When writing function that return results, it's strongly recommended to wrap your entire method in a try-catch close to avoid any unexpected exception to leak to the caller.

### Usage Examples

**Basic Usage**:

```dart
FutureResult<User> fetchUser(String id) async {
  try {
    final user = await api.getUser(id);
    return Success(user);
  } catch (e) {
    return Failure(e);
  }
}

// Using the Result
final result = await fetchUser('123');
final username = result.when(
  success: (user) => user.name,
  failure: (error) => 'Unknown user',
);
```

**Pattern Matching**:

```dart

void handleResult(Result<User> result) {
  switch (result) (
    case Success(value: final user):
        print('User loaded: ${user.name}');
    case Failure(:final error):
        print('Failed to load user: $error');
  );
}

void handleResult(Result<User> result) {
  result.when(
    success: (user) => print('User loaded: ${user.name}'),
    failure: (error) => print('Failed to load user: $error'),
  );
}
```

**Selective Handling**:

```dart
void showErrorIfFailed(Result<void> result) {
  result.whenFailure((error) {
    showErrorDialog(error.toString());
  });
}
```

### Error Propagation

The Result Failure type includes a `propagate()` method for converting failures between different result types:

```dart
Future<Result<Profile>> fetchProfile(String userId) async {
  final userResult = await fetchUser(userId);
  if (userResult is Failure) {
    return userResult.propagate<Profile>();
  }

  final user = userResult.value!;
  // Continue processing...
}
```

## Commands

Commands are listenable objects that encapsulate a fallible action and expose its result to listeners. They are a core part of the MVVM pattern, typically created inside view models and consumed in views. Commands help manage asynchronous operations and their lifecycle in a clean and predictable way.

### Command Types

The package provides two types of commands:

- `Command0<R>`: A command that takes no parameters and returns a result of type `R`
- `Command1<P, R>`: A command that takes a parameter of type `P` and returns a result of type `R`

### Command States

Commands maintain an internal state that represents the current status of the operation. The possible states are:

- `initial`: The command hasn't been executed yet
- `running`: The command is currently executing
- `success`: The command completed successfully with a result
- `failure`: The command failed with an error

### Creating Commands

Commands are typically created within ViewModels using the `ViewModelMixin`:

```dart
class MyViewModel with ViewModelMixin {
  MyViewModel() {
    // Command with no parameters
    fetchData = command(
      _fetchData,
      onSuccess: (result) => print('Fetch succeeded'),
      onFailure: (error) => print('Fetch failed'),
    );

    // Command with a parameter
    updateItem = command1(
      _updateItem,
      restrictionController: DependsOnCommands([fetchData]),
    );
  }

  late final Command0<List<Item>> fetchData;
  late final Command1<Item, void> updateItem;

  Future<Result<List<Item>>> _fetchData() async {
    final items = await repository.fetchItems();
    return Success(items);
  }

  Future<Result<void>> _updateItem(Item item) async {
    await repository.updateItem(item);
    return const Success(null);
  }
}
```

### Command Execution

Commands can be executed using the `execute()` method:

```dart
// For Command0
final result = await fetchData.execute();

// For Command1
final result = await updateItem.execute(newItem);
```

The execute method returns a `Result<R>?` which can be:

- `null` if the command is disabled or already running
- `Success<R>` if the operation succeeded
- `Failure` if the operation failed

### Command Restrictions

Commands can be restricted based on certain conditions using `CommandRestrictionController`:

```dart
// Create a command that depends on other commands
final saveCommand = command(
  _save,
  restrictionController: DependsOnCommands([validateCommand, fetchCommand]),
);

// Create a command with custom restrictions
final submitCommand = command(
  _submit,
  restrictionController: CommandRestrictionSelector(
    formState,
    (state) => state.isValid,
  ),
);
```

### UI Integration

#### CommandBuilder

`CommandBuilder` provides a declarative way to build UI based on command state:

```dart
CommandBuilder(
  command: viewModel.fetchData,
  initial: (context) => Text('Press to fetch'),
  running: (context) => CircularProgressIndicator(),
  success: (context, data) => DataView(data: data),
  failure: (context, error) => ErrorView(error: error),
)
```

For simpler cases, use `CommandBuilder.fallback`:

```dart
CommandBuilder.fallback(
  command: viewModel.fetchData,
  success: (context, data) => DataView(data: data),
  failure: (context, error) => ErrorView(error: error),
  orElse: (context) => CircularProgressIndicator(),
)
```

#### CommandListener

`CommandListener` allows you to react to command state changes:

```dart
CommandListener(
  command: viewModel.saveCommand,
  onRunning: () => showLoadingDialog(),
  onSuccess: (_) => showSuccessMessage(),
  onFailure: (error) => showErrorDialog(error),
  onEnabledChanged: (enabled) => updateUI(enabled),
  child: SaveButton(),
)
```

### Best Practices

1. **Command Return Values**: Commands should return minimal data that facilitates result handling. The actual data should be stored in the ViewModel's state:

```dart
class ViewModel extends ChangeNotifier {
  List<Item> _items = [];

  late final Command0<void> fetchItems = command(
    () async {
      final items = await repository.fetch();
      _items = items;  // Update ViewModel state
      notifyListeners();
      return const Success(null);  // Return void, not items
    },
  );
}
```

2. **Error Handling**: Commands automatically catch and wrap errors in a Failure result. You can handle specific errors in the command action:

```dart
late final Command0<void> saveData = command(() async {
  try {
    await repository.save();
    return const Success(null);
  } on NetworkException catch (e) {
    return Failure(UserFriendlyError('Network error: ${e.message}'));
  }
});
```

3. **Disposal**: Commands are automatically disposed when using `ViewModelMixin`. Make sure to call `disposeViewModel()` when the ViewModel is disposed:

```dart
class MyViewModel with ViewModelMixin {
  @override
  void dispose() {
    disposeViewModel();
    super.dispose();
  }
}
```

### Command State Inspection

Commands provide various state inspection properties:

```dart
if (command.isRunning) showLoadingIndicator();
if (command.isSucceeded) showSuccessMessage();
if (command.isFailed) showErrorMessage(command.errorOrNull);
if (command.isCompleted) hideLoadingIndicator();
```
