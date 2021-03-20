import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:test/test.dart';
import 'package:redux/redux.dart';

class TestState {
  final String message;

  TestState([this.message = 'initial state']);

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

  TestAction([this.message = 'unknown']);

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
        return TestState('updated ${action.message}');
      }

      return TestState(action.message);
    }

    return state;
  }
}

void main() {
  group('DevTools Reducers', () {
    late TestReducer testReducer;

    setUp(() {
      testReducer = TestReducer();
    });

    test('perform action should update the dev tools store', () {
      final store = DevToolsStore<TestState>(
        testReducer,
        initialState: TestState(),
      );
      final message = 'test';

      store.dispatch(TestAction(message));

      expect(store.devToolsState.savedState, TestState());
      expect(store.devToolsState.computedStates.length, 2);
      expect(store.devToolsState.stagedActions.length, 2);
      expect(
        store.devToolsState.currentAppState,
        TestState(message),
      );
      expect(store.devToolsState.latestAction, TestAction(message));
    });

    test(
        'when back in time, the perform action should overwrite all future actions',
        () {
      final store = DevToolsStore<TestState>(
        testReducer,
        initialState: TestState(),
      );
      final first = 'first';
      final second = 'second';
      final third = 'third';

      store.dispatch(TestAction(first));
      store.dispatch(TestAction(second));
      store.dispatch(TestAction(third));

      expect(store.devToolsState.savedState, TestState());
      expect(store.devToolsState.computedStates.length, 4);
      expect(store.devToolsState.stagedActions.length, 4);
      expect(store.devToolsState.computedStates[1], TestState(first));
      expect(store.devToolsState.stagedActions[1], TestAction(first));
      expect(store.devToolsState.computedStates[2], TestState(second));
      expect(store.devToolsState.stagedActions[2], TestAction(second));
      expect(store.devToolsState.computedStates[3], TestState(third));
      expect(store.devToolsState.stagedActions[3], TestAction(third));
      expect(store.devToolsState.currentAppState, TestState(third));
      expect(store.devToolsState.latestAction, TestAction(third));

      store.dispatch(DevToolsAction.jumpToState(2));
      store.dispatch(TestAction(first));

      expect(store.devToolsState.savedState, TestState());
      expect(store.devToolsState.computedStates.length, 4);
      expect(store.devToolsState.stagedActions.length, 4);
      expect(store.devToolsState.computedStates[1], TestState(first));
      expect(store.devToolsState.stagedActions[1], TestAction(first));
      expect(store.devToolsState.computedStates[2], TestState(second));
      expect(store.devToolsState.stagedActions[2], TestAction(second));
      expect(store.devToolsState.computedStates[3], TestState(first));
      expect(store.devToolsState.stagedActions[3], TestAction(first));
      expect(store.devToolsState.currentAppState, TestState(first));
      expect(store.devToolsState.latestAction, TestAction(first));
    });

    test(
        'reset action should roll the current state of the app back to the previously saved state',
        () {
      final store = DevToolsStore<TestState>(
        testReducer,
        initialState: TestState(),
      );

      store
          .dispatch(TestAction('action that will be lost when store is reset'));
      store.dispatch(DevToolsAction.reset());

      expect(store.devToolsState.savedState, TestState());
      expect(store.devToolsState.computedStates.length, 1);
      expect(store.devToolsState.stagedActions.length, 1);
      expect(store.devToolsState.currentAppState, TestState());
      expect(store.devToolsState.latestAction, DevToolsAction.reset());
    });

    test('save action should commit the current state of the app', () {
      final store = DevToolsStore<TestState>(
        testReducer,
        initialState: TestState(),
      );
      final message = 'action to save';

      store.dispatch(TestAction(message));
      store.dispatch(DevToolsAction.save());

      expect(store.devToolsState.savedState, TestState(message));
      expect(store.devToolsState.computedStates.length, 1);
      expect(store.devToolsState.stagedActions.length, 1);
      expect(store.devToolsState.currentAppState, TestState(message));
      expect(
        store.devToolsState.latestAction,
        DevToolsAction.save(),
      );
    });

    test(
        'jump to state action should set the current state of the app to a given time in the past',
        () {
      final store =
          DevToolsStore<TestState>(testReducer, initialState: TestState());
      final jumpToMessage = 'action to jump to';
      final finalMessage = 'final action';

      store.dispatch(TestAction(jumpToMessage));
      store.dispatch(TestAction(finalMessage));
      store.dispatch(DevToolsAction.jumpToState(1));

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(store.devToolsState.currentAppState, TestState(jumpToMessage));
      expect(store.devToolsState.latestAction, TestAction(jumpToMessage));
    });

    test(
        'recompute action should run all actions through the app reducer again',
        () {
      final store = DevToolsStore<TestState>(
        testReducer,
        initialState: TestState(),
      );
      final first = 'first';
      final second = 'second';

      store.dispatch(TestAction(first));
      store.dispatch(TestAction(second));

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(store.devToolsState.currentAppState, TestState(second));
      expect(store.devToolsState.latestAction, TestAction(second));

      testReducer.updated = true;
      store.dispatch(DevToolsAction.recompute());

      expect(store.devToolsState.computedStates.length, 3);
      expect(store.devToolsState.stagedActions.length, 3);
      expect(
        store.devToolsState.computedStates[1],
        TestState('updated $first'),
      );
      expect(
        store.devToolsState.currentAppState,
        TestState('updated $second'),
      );
      expect(store.devToolsState.latestAction, TestAction(second));
    });
  });
}
