import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:test/test.dart';

class TestState {
  final String message;

  TestState([this.message = 'initial state']);
}

class TestAction {
  final String type;

  TestAction([this.type = 'unknown']);
}

class MyMiddleware extends MiddlewareClass<TestState> {
  @override
  dynamic call(Store<TestState> store, dynamic action, NextDispatcher next) {
    next(action);

    return action;
  }
}

enum Actions { HeyHey, CallApi, Fetching, FetchComplete, Around }

void main() {
  group('DevTools Store', () {
    test(
        'when an action is fired, the corresponding reducer should be called and update the state of the application',
        () {
      final reducer = (TestState state, dynamic action) {
        if (action is TestAction && action.type == 'to invoke') {
          return TestState('reduced');
        }

        return state;
      };

      final store = DevToolsStore(reducer, initialState: TestState());

      store.dispatch(TestAction('to invoke'));

      expect(store.state.message, 'reduced');
    });

    test('should return from dispatch', () {
      TestState reducer(TestState state, dynamic action) {
        if (action is TestAction && action.type == 'to invoke') {
          return TestState('reduced');
        }

        return state;
      }

      final store = DevToolsStore<TestState>(
        reducer,
        initialState: TestState(),
        middleware: [MyMiddleware()],
      );

      var returned = store.dispatch(TestAction()) as TestAction?;

      expect(returned, TypeMatcher<TestAction>());
    });

    test(
        'when two reducers are combined, and a series of actions are fired, the correct reducer should be called',
        () {
      final helloReducer1 = 'helloReducer1';
      final helloReducer2 = 'helloReducer2';

      final reducer1 = (TestState state, dynamic action) {
        if (action is TestAction && action.type == helloReducer1) {
          return TestState('oh hai');
        }

        return state;
      };

      final reducer2 = (TestState state, dynamic action) {
        if (action is TestAction && action.type == helloReducer2) {
          return TestState('mark');
        }

        return state;
      };

      final store = DevToolsStore<TestState>(
          combineReducers([reducer1, reducer2]),
          initialState: TestState());

      store.dispatch(TestAction(helloReducer1));
      expect(store.state.message, 'oh hai');
      store.dispatch(TestAction(helloReducer2));
      expect(store.state.message, 'mark');
    });

    test('subscribers should be notified when the state changes', () async {
      final store = DevToolsStore<TestState>(
          (state, dynamic action) => TestState(),
          initialState: TestState(),
          syncStream: true);
      var subscriber1Called = false;
      var subscriber2Called = false;

      store.onChange.listen((_) {
        subscriber1Called = true;
      });
      store.onChange.listen((_) {
        subscriber2Called = true;
      });

      store.dispatch(TestAction());

      expect(subscriber1Called, isTrue);
      expect(subscriber2Called, isTrue);
    });

    test('the store should not notify unsubscribed objects', () {
      final store = DevToolsStore<TestState>(
        (state, dynamic action) => TestState(),
        initialState: TestState(),
        syncStream: true,
      );
      var subscriber1Called = false;
      var subscriber2Called = false;

      final subscription = store.onChange.listen((_) {
        subscriber1Called = true;
      });

      store.onChange.listen((_) {
        subscriber2Called = true;
      });

      subscription.cancel();

      store.dispatch(TestAction());

      expect(subscriber1Called, isFalse);
      expect(subscriber2Called, isTrue);
    });

    test('store should pass the current state to subscribers', () {
      final reducer = (TestState state, dynamic action) {
        if (action is TestAction && action.type == 'to invoke') {
          return TestState('oh hai');
        }

        return state;
      };

      var actual = TestState();
      final store = DevToolsStore(
        reducer,
        initialState: TestState(),
        syncStream: true,
      );

      store.onChange.listen((it) => actual = it);
      store.dispatch(TestAction('to invoke'));

      expect(actual, store.state);
    });

    test('store does not emit an onChange if distinct', () {
      String stringReducer(String state, dynamic action) =>
          action is String ? action : 'notFound';

      final action = 'test';
      final states = <String>[];
      final store = DevToolsStore<String>(stringReducer,
          initialState: 'hello', syncStream: true, distinct: true);
      store.onChange.listen((state) => states.add(state));

      // Dispatch two actions. Only one should be emitted b/c distinct is true
      store.dispatch(action);
      store.dispatch(action);

      expect(states, <String>[action]);
    });

    test(
        'store should work with both dev tools actions and application actions',
        () {
      final reducer = (TestState state, dynamic action) {
        if (action is TestAction && action.type == 'to invoke') {
          return TestState('oh hai');
        }

        return state;
      };

      final store = DevToolsStore(
        reducer,
        initialState: TestState(),
      );

      store.dispatch(TestAction('to invoke'));
      expect(store.state.message, 'oh hai');

      store.dispatch(DevToolsAction.reset());
      expect(store.state.message, TestState().message);
    });
  });
}
