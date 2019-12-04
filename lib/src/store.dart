import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_dev_tools/src/actions.dart';
import 'package:redux_dev_tools/src/middleware.dart';
import 'package:redux_dev_tools/src/reducer.dart';
import 'package:redux_dev_tools/src/state.dart';

/// The DevToolsStore is a drop-in replacement for a normal Redux [Store] that
/// should only be used during Development, allowing you to "Time Travel"
/// between different states of your app.
///
/// By default, it will act exactly like a normal [Store]. You can Time Travel
/// through the states of your app by dispatching your own [DevToolsAction]s,
/// or by including one of the following Dev Tools UI packages for Flutter or
/// web.
///
///   * [flutter_redux_dev_tools](https://pub.dartlang.org/packages/flutter_redux_dev_tools)
///
/// For developers, this class acts as your core building block for creating
/// your own implementation of a Dev Tools UI.
///
/// ### Example
///
/// First, we'll create a normal Store, to show the drop-in replacement between
/// Production builds and Dev builds.
///
///     int addOneReducer(int state, action) => state + 1;
///
///     // For production mode, this is how you should create your store.
///     final store = new Store(addReducer);
///
///     // In Dev Mode, if you want to hook up to Time-Traveling Dev Tools,
///     // create a `DevToolsStore` instead!
///     //
///     // It will act exactly like your normal Store, but give you super powers
///     // to travel back and forth in time throughout your app States!
///     final store = new DevToolsStore(addReducer);
class DevToolsStore<S> implements Store<S> {
  final bool _distinct;
  Store<DevToolsState<S>> _devToolsStore;

  DevToolsStore(
    Reducer<S> reducer, {
    S initialState,
    List<Middleware<S>> middleware: const [],
    bool syncStream: false,
    bool distinct: false,
  }) : _distinct = distinct {
    final devToolsState = new DevToolsState<S>([initialState], <dynamic>[], 0);

    final DevToolsReducer<S> devToolsReducer = new DevToolsReducer<S>(reducer);

    _devToolsStore = new Store<DevToolsState<S>>(devToolsReducer,
        initialState: devToolsState,
        middleware: new List<Middleware<DevToolsState<S>>>.generate(
          middleware.length,
          (index) => new DevToolsMiddleware<S>(this, middleware[index]),
        ),
        syncStream: syncStream);

    dispatch(new DevToolsAction.init());
  }

  DevToolsState<S> get devToolsState => _devToolsStore.state;
  @override
  Reducer<S> reducer;

  @override
  dynamic dispatch(dynamic action) {
    if (action is DevToolsAction) {
      _devToolsStore.dispatch(action);
    } else {
      _devToolsStore.dispatch(new DevToolsAction.perform(action));
    }
  }

  @override
  Stream<S> get onChange {
    final stream = _devToolsStore.onChange
        .map((devToolsState) => devToolsState.currentAppState);

    return _distinct ? stream.distinct() : stream;
  }

  @override
  S get state => _devToolsStore.state.currentAppState;

  @override
  Future teardown() async {
    await _devToolsStore.teardown();
    _devToolsStore = null;
  }
}
