import 'package:redux/redux.dart';
import 'package:redux_dev_tools/src/actions.dart';
import 'package:redux_dev_tools/src/state.dart';

/// An internal class for Wrapping a normal app Action as a [DevToolsAction] for
/// consumption by the `DevToolsReducer`.
///
/// This is not exported as there's no need to create or use this from an
/// outside package.
class DevToolsMiddleware<S> extends MiddlewareClass<DevToolsState<S>> {
  final Store<S> store;
  final Middleware<S> appMiddleware;

  DevToolsMiddleware(this.store, this.appMiddleware);

  @override
  void call(Store<DevToolsState<S>> _, dynamic action, NextDispatcher next) {
    // Actions are wrapped by the dispatcher as a DevToolsAction. However, the
    // middleware passed into the constructor act on original app actions.
    // Therefore, we must lift the app action out of the DevToolsAction
    // container.
    dynamic actionToDispatch = action;

    if (action is DevToolsAction && action.appAction != null) {
      actionToDispatch = action.appAction;
    }

    final dispatcher = (dynamic action) {
      // Since next can be called within any Middleware, we need to wrap the
      // actions as DevToolsActions, in the same way as we wrap the initial
      // dispatch call.
      if (action is DevToolsAction) {
        next(action);
      } else {
        next(new DevToolsAction.perform(action));
      }
    };

    appMiddleware(store, actionToDispatch, dispatcher);
  }
}
