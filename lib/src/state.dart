import 'package:redux/redux.dart';
import 'package:redux_dev_tools/src/actions.dart';

/// The DevToolsState is a wrapper around your application's normal State. It
/// holds all of the actions and resulting states
class DevToolsState<S> {
  /// List of computed states after committed.
  final List<S> computedStates;

  /// List of all actions that have been dispatched since the initial state of
  /// the app or the last save point if a Save action has been dispatched.
  final List<dynamic> stagedActions;

  /// Determines which of the [computedStates] is the current state. This allows
  /// you to skip back and forth in time.
  final int currentPosition;

  /// Create the DevToolsState in the simplest possible way
  DevToolsState(
    this.computedStates,
    this.stagedActions,
    this.currentPosition,
  );

  /// Create a new instance of the DevToolsState using a normal application
  /// Action and Reducer.
  factory DevToolsState.fromApp(
    DevToolsState<S> state,
    DevToolsAction devToolsAction,
    List<S> computedStates,
    List<dynamic> stagedActions,
    Reducer<S> appReducer,
  ) {
    final newStates = <S>[...computedStates];
    final newActions = <dynamic>[...stagedActions];

    newStates.add(
      appReducer(
        state.currentAppState,
        devToolsAction.appAction,
      ),
    );

    newActions.add(devToolsAction.appAction);

    return DevToolsState<S>(newStates, newActions, newStates.length - 1);
  }

  /// The last saved state, or the initial state if a Save action has not been
  /// dispatched. If you dispatch a Reset action, the store will be reset to the
  /// last saved state.
  S get savedState => computedStates[0];

  /// This is the current state of the application itself. The [DevToolsState]
  /// is simply a wrapper around your application's normal state.
  S get currentAppState => computedStates[currentPosition];

  /// The latest action that has been dispatched through the `Store`.
  dynamic get latestAction => stagedActions[currentPosition];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevToolsState &&
          runtimeType == other.runtimeType &&
          computedStates == other.computedStates &&
          stagedActions == other.stagedActions &&
          currentPosition == other.currentPosition;

  @override
  int get hashCode =>
      computedStates.hashCode ^
      stagedActions.hashCode ^
      currentPosition.hashCode;

  @override
  String toString() {
    return 'DevToolsState{\n'
        '  computedStates: $computedStates,\n'
        '  stagedActions: $stagedActions,\n'
        '  currentPosition: $currentPosition,\n'
        '  currentAppState: $currentAppState,\n'
        '  savedState: $savedState\n'
        '}';
  }
}
