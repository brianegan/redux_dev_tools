/// In order to modify the `DevToolsState`, you must dispatch a
/// `DevToolsAction`. Do not dispatch a `DevToolsAction` to modify your
/// normal application state.
///
/// The `DevToolsAction` will be sent to the `DevToolsReducer`, which will
/// update the `DevToolsState` in response.
///
/// The `DevToolsAction`s should only be dispatched when building a Dev Tools UI
/// or when you manually want to jump between app states contained within the
/// DevToolsState.
class DevToolsAction {
  final DevToolsActionTypes type;
  final dynamic appAction;
  final int position;

  DevToolsAction._(this.type, this.appAction, this.position);

  factory DevToolsAction.perform(dynamic appAction) =>
      new DevToolsAction._(DevToolsActionTypes.PerformAction, appAction, null);

  factory DevToolsAction.jumpToState(int index) =>
      new DevToolsAction._(DevToolsActionTypes.JumpToState, null, index);

  factory DevToolsAction.save() =>
      new DevToolsAction._(DevToolsActionTypes.Save, null, null);

  factory DevToolsAction.reset() =>
      new DevToolsAction._(DevToolsActionTypes.Reset, null, null);

  factory DevToolsAction.recompute() =>
      new DevToolsAction._(DevToolsActionTypes.Recompute, null, null);

  factory DevToolsAction.init() =>
      new DevToolsAction._(DevToolsActionTypes.Init, null, null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevToolsAction &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          appAction == other.appAction &&
          position == other.position;

  @override
  int get hashCode => type.hashCode ^ appAction.hashCode ^ position.hashCode;

  @override
  String toString() =>
      'DevToolsAction{type: $type, appAction: $appAction, position: $position}';
}

enum DevToolsActionTypes {
  PerformAction,
  JumpToState,
  Save,
  Reset,
  Recompute,
  ToggleAction,
  Init
}
