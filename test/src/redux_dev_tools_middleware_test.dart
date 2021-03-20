import 'dart:async';
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
}

enum Actions { HeyHey, CallApi, Fetching, FetchComplete, Around }

void main() {
  group('DevTools Middleware', () {
    test("unwrapped actions should be run through a store's middleware", () {
      var counter = 0;
      final Reducer<TestState> reducer = (state, dynamic action) {
        return new TestState("Reduced?");
      };
      final Middleware<TestState> middleware = (
        Store<TestState> store,
        dynamic action,
        NextDispatcher next,
      ) {
        counter += 1;
        next(action);
      };
      final store = new DevToolsStore<TestState>(
        reducer,
        initialState: new TestState(),
        middleware: [middleware],
        syncStream: true,
      );

      store.dispatch(Actions.HeyHey);

      expect(counter, 2);
      expect(store.state.message, "Reduced?");
    });

    test(
        "unwrapped actions should pass through the middleware chain in the correct order",
        () {
      var counter = 0;
      final order = <String>[];

      final Middleware<TestState> middleWare1 = (state, dynamic action, next) {
        counter += 1;
        order.add("first");
        next(action);
        order.add("third");
      };

      final Middleware<TestState> middleWare2 = (store, dynamic action, next) {
        counter += 1;
        order.add("second");
        next(action);
      };

      final Reducer<TestState> reducer = (state, dynamic action) {
        if (action == Actions.HeyHey) {
          return new TestState("howdy!");
        }

        return state;
      };

      final store = new DevToolsStore<TestState>(reducer,
          initialState: new TestState(),
          middleware: [
            middleWare1,
            middleWare2,
          ],
          syncStream: true);

      store.dispatch(Actions.HeyHey);

      expect(store.state, new TestState("howdy!"));
      expect(counter, 4);
      expect(order, ["first", "second", "third", "first", "second", "third"]);
    });

    test(
        "async middleware should be able to dispatch follow-up unwrapped actions that travel through the remaining middleware",
        () async {
      int counter = 0;
      Future<dynamic>? fetchComplete;
      final order = <String>[];

      final Middleware<TestState> fetchMiddleware =
          (store, dynamic action, next) {
        counter += 1;

        if (action == Actions.CallApi) {
          next(Actions.Fetching);
          fetchComplete =
              new Future<dynamic>(() => next(Actions.FetchComplete));
        }

        next(action);
      };

      final Middleware<TestState> loggerMiddleware =
          (store, dynamic action, next) {
        counter += 1;

        if (action == Actions.CallApi) {
          order.add("CALL_API");
        } else if (action == Actions.Fetching) {
          order.add("FETCHING");
        } else if (action == Actions.FetchComplete) {
          order.add("FETCH_COMPLETE");
        }

        next(action);
      };

      final Reducer<TestState> reducer = (state, dynamic action) {
        if (action == Actions.Fetching) {
          return new TestState("FETCHING");
        } else if (action == Actions.FetchComplete) {
          return new TestState("FETCH_COMPLETE");
        }

        return state;
      };

      final store = new DevToolsStore<TestState>(reducer,
          initialState: new TestState(),
          middleware: [fetchMiddleware, loggerMiddleware],
          syncStream: true);

      store.dispatch(Actions.CallApi);

      expect(counter, 5);
      expect(order, ["FETCHING", "CALL_API"]);
      expect(store.state, new TestState("FETCHING"));

      await fetchComplete;

      expect(counter, 6);
      expect(
        order,
        ["FETCHING", "CALL_API", "FETCH_COMPLETE"],
      );
      expect(store.state, new TestState("FETCH_COMPLETE"));
    });

    test(
        "sync actions should be able to send new unwrapped actions through the entire chain",
        () async {
      var counter = 0;
      final order = <String>[];

      final Middleware<TestState> middleWare1 = (store, dynamic action, next) {
        counter += 1;
        order.add("first");
        next(action);

        if (action == Actions.Around) {
          store.dispatch(Actions.HeyHey);
        }
      };

      final Middleware<TestState> middleWare2 = (store, dynamic action, next) {
        counter += 1;
        order.add("second");
        next(action);
      };

      final Reducer<TestState> reducer = (state, dynamic action) {
        return state;
      };
      final store = new DevToolsStore<TestState>(
        reducer,
        initialState: new TestState(),
        middleware: [middleWare1, middleWare2],
      );

      store.dispatch(Actions.Around);

      expect(counter, 6);
      expect(order, [
        // From DevToolsInit
        "first",
        "second",
        // From Around
        "first",
        "second",
        // From Hey Hey
        "first",
        "second",
      ]);
    });
  });
}
