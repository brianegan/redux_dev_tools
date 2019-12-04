import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:test/test.dart';
import 'package:redux/redux.dart';

class TestState {
  final String message;

  TestState([this.message = "initial state"]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() {
    return 'TestState{message: $message}';
  }
}

class TestAction {
  final String message;

  TestAction([this.message = "unknown"]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestAction &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() {
    return 'TestAction{message: $message}';
  }
}

class TestReducer extends ReducerClass<TestState> {
  var updated = false;

  @override
  TestState call(TestState state, dynamic action) {
    if (action is TestAction) {
      if (updated) {
        return new TestState("updated ${action.message}");
      }

      return new TestState(action.message);
    }

    return state;
  }
}

void main() {
  group('DevTools Reducers', () {
    TestReducer testReducer;

    setUp(() {
      testReducer = new TestReducer();
    });

    test("perform action should update the dev tools store", () {
      final store = new DevToolsStore<TestState>(
        testReducer,
        initialState: new TestState(),
      );
      final message = "test";

      store.dispatch(new TestAction(message));

      expect(store.devToolsState.savedState, new TestState());
      expect(store.devToolsState.computedStates.length, 2);
      expect(store.devToolsState.stagedActions.length, 2);
      expect(
        store.devToolsState.currentAppState,
        new TestState(message),
      );
      expect(store.devToolsState.latestAction, new TestAction(message));
    });

    test(
        "when back in time, the perform action should overwrite all future actions",
        () {
      final store = new DevToolsStore<TestState>(
        testReducer,
        initialState: new TestState(),
      );
      final first = "first";
      final second = "second";
      final third = "third";

      store.dispatch(new TestAction(first));
      store.dispatch(new TestAction(second));
      store.dispatch(new TestAction(third));

      expect(store.devToolsState.savedState, new TestState());
      expect(store.devToolsState.computedStates.length, 4);
      expect(store.devToolsState.stagedActions.length, 4);
      expect(store.devToolsState.computedStates[1], new TestState(first));
      expect(store.devToolsState.stagedActions[1], new TestAction(first));
      expect(store.devToolsState.computedStates[2], new TestState(second));
      expect(store.devToolsState.stagedActions[2], new TestAction(second));
      expect(store.devToolsState.computedStates[3], new TestState(third));
      expect(store.devToolsState.stagedActions[3], new TestAction(third));
      expect(store.devToolsState.currentAppState, new TestState(third));
      expect(store.devToolsState.latestAction, new TestAction(third));

      store.dispatch(new DevToolsAction.jumpToState(2));
      store.dispatch(new TestAction(first));

      expect(store.devToolsState.savedState, new TestState());
      expect(store.devToolsState.computedStates.length, 4);
      expect(store.devToolsState.stagedActions.length, 4);
      expect(store.devToolsState.computedStates[1], new TestState(first));
      expect(store.devToolsState.stagedActions[1], new TestAction(first));
      expect(store.devToolsState.computedStates[2], new TestState(second));
      expect(store.devToolsState.stagedActions[2], new TestAction(second));
      expect(store.devToolsState.computedStates[3], new TestState(first));
      expect(store.devToolsState.stagedActions[3], new TestAction(first));
      expect(store.devToolsState.currentAppState, new TestState(first));
      expect(store.devToolsState.latestAction, new TestAction(first));
    });

    test(
        "reset action should roll the current state of the app back to the previously saved state",
        () {
      final store = new DevToolsStore<TestState>(
        testReducer,
        initialState: new TestState(),
      );

      store.dispatch(
          new TestAction("action that will be lost when store is reset"));
      store.dispatch(new DevToolsAction.reset());

      expect(store.devToolsState.savedState, new TestState());
      expect(store.devToolsState.computedStates.length, 1);
      expect(store.devToolsState.stagedActions.length, 1);
      expect(store.devToolsState.currentAppState, new TestState());
      expect(store.devToolsState.latestAction, new DevToolsAction.reset());
    });

    test("save action should commit the current state of the app", () {
      final store = new DevToolsStore<TestState>(
        testReducer,
        initialState: new TestState(),
      );
      final message = "action to save";

      store.dispatch(new TestAction(message));
      store.dispatch(new DevToolsAction.save());

      expect(store.devToolsState.savedState, new TestState(message));
      expect(store.devToolsState.computedStates.length, 1);
      expect(store.devToolsState.stagedActions.length, 1);
      expect(store.devToolsState.currentAppState, new TestState(message));
      expect(
        store.devToolsState.latestAction,
        new DevToolsAction.save(),
      );
    });

    test(
        "jump to state action should set the current state of the app to a given time in the past",
        () {
      final store = new DevToolsStore<TestState>(testReducer,
          initialState: new TestState());
      final jumpToMessage = "action to jump to";
      final finalMessage = "final action";

      store.dispatch(new TestAction(jumpToMessage));
      store.dispatch(new TestAction(finalMessage));
      store.dispatch(new DevToolsAction.jumpToState(1));

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(store.devToolsState.currentAppState, new TestState(jumpToMessage));
      expect(store.devToolsState.latestAction, new TestAction(jumpToMessage));
    });

    test(
        "recompute action should run all actions through the app reducer again",
        () {
      final store = new DevToolsStore<TestState>(
        testReducer,
        initialState: new TestState(),
      );
      final first = "first";
      final second = "second";

      store.dispatch(new TestAction(first));
      store.dispatch(new TestAction(second));

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(store.devToolsState.currentAppState, new TestState(second));
      expect(store.devToolsState.latestAction, new TestAction(second));

      testReducer.updated = true;
      store.dispatch(new DevToolsAction.recompute());

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(
        store.devToolsState.computedStates[1],
        new TestState("updated $first"),
      );
      expect(
        store.devToolsState.currentAppState,
        new TestState("updated $second"),
      );
      expect(store.devToolsState.latestAction, new TestAction(second));
    });
  });
}
