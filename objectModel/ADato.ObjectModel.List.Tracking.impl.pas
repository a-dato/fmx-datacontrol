{$IFNDEF WEBASSEMBLY}
{$I Adato.inc}
{$ENDIF}

unit ADato.ObjectModel.List.Tracking.impl;

interface

uses
  {$IFDEF DELPHI}
  System.SysUtils,
  {$ENDIF}
  System_,
  System.Collections,
  System.Collections.Generic,
  System.ComponentModel,
  ADato.ObjectModel.impl,
  ADato.ObjectModel.intf,
  ADato.ObjectModel.List.impl,
  ADato.ObjectModel.List.intf,
  ADato.ObjectModel.List.Tracking.intf,
  ADato.InsertPosition,
  ADato.ObjectModel.TrackInterfaces;

type
  IChangedItem = record
  public
    Item: CObject;
    ChangeType: TObjectListChangeType;
  end;

  TObjectListModelWithChangeTracking<T> = {$IFDEF DOTNET}public{$ENDIF} class(
    TObjectListModel<T>,
    IObjectListModelChangeTracking,
    IAddingNew,
    IEditState,
    IEditableModel,
    INotifyListItemChanged,
    IOnItemChangedSupport
    {$IFDEF APP_PLATFORM}
    , IUpdatableObject
    , IAddRange
    {$ENDIF}
    )

  protected
    _CreatorFunc  : TFunc<T>;
    _DoMultiContextSupport: Boolean;

    _ChangedItems : Dictionary<CObject, TObjectListChangeType>;   // List
    _orignalContext: IList;
    _EditContext  : IObjectModelContext;
    _OnItemChanged: IList<IListItemChanged>;
    _UpdateCount  : Integer;
    _StoreChangedItems: Boolean;

    procedure Initialize; override;
    function  CreateObjectModelContext : IObjectModelContext; override;
    procedure UpdateEditContext(const Context: IObjectModelContext; Cancel: Boolean = False);
    procedure OnObjectPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);

    // IUpdatableObject
    procedure BeginUpdate;
    procedure EndUpdate;

    {$IFDEF APP_PLATFORM}
    // IAddRange
    function AddRange(const Data: CObject) : Integer;
    {$ENDIF}

    // INotifyListItemChanged
    procedure NotifyAddingNew(const Context: IObjectModelContext; var Index: Integer; Position: InsertPosition);
    procedure NotifyRemoved(const Item: CObject; const Index: Integer);
    procedure NotifyBeginEdit(const Context: IObjectModelContext); virtual;
    procedure NotifyCancelEdit(const Context: IObjectModelContext; const OriginalObject: CObject);
    procedure NotifyEndEdit(const Context: IObjectModelContext; const OriginalObject: CObject; Index: Integer; Position: InsertPosition); virtual;

    procedure set_StoreChangedItems(const Value: Boolean);
    procedure UpdateChangedItem(const Obj: CObject; ChangeType: TObjectListChangeType);

    // IEditState
    function  get_IsChanged: Boolean;
    function  get_IsEdit: Boolean;
    function  get_IsNew: Boolean;
    function  get_IsEditOrNew: Boolean;

    // IEditableModel
    function  AddNew(Index: Integer; Position: InsertPosition) : Boolean;
    procedure BeginEdit(Index: Integer);
    procedure CancelEdit; virtual;
    procedure EndEdit; virtual;
    procedure Remove; overload;
    procedure Remove(const Item: CObject); overload;

    function CanAdd : Boolean;
    function CanEdit : Boolean;
    function CanRemove : Boolean;

    // IObjectListModelChangeTracking
    function  get_HasChangedItems: Boolean;
    function  get_ChangedItems: Dictionary<CObject, TObjectListChangeType>;
    procedure set_MultiObjectContextSupport(const Value: Boolean);
    procedure ResetContextFromChangedItems;

    // IOnItemChangedSupport
    function  get_OnItemChanged: IList<IListItemChanged>;

    procedure set_Context(const Value: IList); override;
    procedure set_ObjectContext(const Value: CObject); override;

    // IAddNewSupport
    function CreateInstance: CObject;
  public
    constructor Create(const CreatorFunc: TFunc<T> = nil); overload;

    destructor Destroy; override;

    property MultiObjectContextSupport: Boolean write set_MultiObjectContextSupport;
  end;

implementation

uses
  {$IFDEF DELPHI}
  System.Classes,
  System.TypInfo,
  {$ENDIF}
  ADato.TraceEvents.intf,
  ADato.MultiObjectModelContextSupport.impl,
  ADato.EditableObjectModelContext.impl;

{ TObjectListModel<T> }

function TObjectListModelWithChangeTracking<T>.AddNew(Index: Integer; Position: InsertPosition) : Boolean;
begin
  Result := False;

  BeginUpdate;
  try
    var item := CreateInstance;
    if item <> nil then
    begin
      var e: IEditableListObject;
      if Interfaces.Supports<IEditableListObject>(get_ObjectModelContext, e) then
      begin
        Result := True;
        e.AddNew(item, Index, Position);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.BeginEdit(Index: Integer);
begin
  var e: IEditableListObject;
  if Interfaces.Supports<IEditableListObject>(get_ObjectModelContext, e) then
    e.BeginEdit(Index);
end;

{$IFDEF APP_PLATFORM}
// IAddRange
function TObjectListModelWithChangeTracking<T>.AddRange(const Data: CObject) : Integer;
begin
  var upd: IUpdatableObject;
  Interfaces.Supports<IUpdatableObject>(_Context, upd);

  try
    if upd <> nil then
      upd.BeginUpdate;

    Result := 0;
    var e: IEnumerable;
    if Data.TryAsType<IEnumerable>(e) then
    begin
      var item: CObject;
      for item in e do
      begin
        _Context.Add(item);
        inc(Result);
      end;
    end;
  finally
    if upd <> nil then
      upd.EndUpdate;
  end;
end;
{$ENDIF}

procedure TObjectListModelWithChangeTracking<T>.BeginUpdate;
begin
  inc(_UpdateCount);
end;

function TObjectListModelWithChangeTracking<T>.CanAdd: Boolean;
begin
  Result := ((_Context <> nil) {or (_dataModel <> nil)}) and Assigned(_CreatorFunc);
end;

procedure TObjectListModelWithChangeTracking<T>.CancelEdit;
begin
  UpdateEditContext(nil, True);
end;

function TObjectListModelWithChangeTracking<T>.CanEdit: Boolean;
begin
  Result := True;
end;

function TObjectListModelWithChangeTracking<T>.CanRemove: Boolean;
begin
  Result := (_Context <> nil) and (_Context.Count > 0);
end;

constructor TObjectListModelWithChangeTracking<T>.Create(const CreatorFunc: TFunc<T>);
begin
  inherited Create;

  _CreatorFunc := CreatorFunc;
end;

procedure TObjectListModelWithChangeTracking<T>.Initialize;
begin
  inherited;

  _StoreChangedItems := True;
  _ChangedItems := CDictionary<CObject, TObjectListChangeType>.Create;
end;

destructor TObjectListModelWithChangeTracking<T>.Destroy;
begin
  {$IFNDEF WEBASSEMBLY}
  if _ObjectModelContext <> nil then
    _ObjectModelContext.OnPropertyChanged.Remove(OnObjectPropertyChanged);
  {$ELSE}
  if _ObjectModelContext <> nil then
    _ObjectModelContext.OnPropertyChanged -= OnObjectPropertyChanged;
  {$ENDIF}

  inherited Destroy;
end;

function TObjectListModelWithChangeTracking<T>.CreateObjectModelContext : IObjectModelContext;
begin
  if ListHoldsObjectType then
  begin
    if _DoMultiContextSupport then
      Result := TMultiEditableObjectModelContext.Create(get_ObjectModel, Self) else
      Result := TEditableObjectModelContext.Create(get_ObjectModel, Self);
  end else
    Result := inherited;

  {$IFNDEF WEBASSEMBLY}
  Result.OnPropertyChanged.Add(OnObjectPropertyChanged);
  {$ELSE}
  Result.OnPropertyChanged += OnObjectPropertyChanged;
  {$ENDIF}
end;

function TObjectListModelWithChangeTracking<T>.get_HasChangedItems: Boolean;
begin
  Result := _ChangedItems.Count > 0;
end;

function TObjectListModelWithChangeTracking<T>.get_ChangedItems: Dictionary<CObject, TObjectListChangeType>;
begin
  Result := _ChangedItems;
end;

function TObjectListModelWithChangeTracking<T>.get_IsChanged: Boolean;
begin
  var e: IEditState;
  Result := Interfaces.Supports<IEditState>(_EditContext, e) and e.IsChanged;
end;

function TObjectListModelWithChangeTracking<T>.get_IsEdit: Boolean;
begin
  var e: IEditState;
  Result := Interfaces.Supports<IEditState>(_EditContext, e) and e.IsEdit;
end;

function TObjectListModelWithChangeTracking<T>.get_IsEditOrNew: Boolean;
begin
  var e: IEditState;
  Result := Interfaces.Supports<IEditState>(_EditContext, e) and e.IsEditOrNew;
end;

function TObjectListModelWithChangeTracking<T>.get_IsNew: Boolean;
begin
  var e: IEditState;
  Result := Interfaces.Supports<IEditState>(_EditContext, e) and e.IsNew;
end;

function TObjectListModelWithChangeTracking<T>.get_OnItemChanged: IList<IListItemChanged>;
begin
  if _OnItemChanged = nil then
    _OnItemChanged := CList<IListItemChanged>.Create;

  Result := _OnItemChanged;
end;

procedure TObjectListModelWithChangeTracking<T>.UpdateEditContext(const Context: IObjectModelContext; Cancel: Boolean);
var
  ctxt: IObjectModelContext;
begin
  ctxt := Context;
  if _EditContext <> nil then
  begin
    BeginUpdate;
    try
      var e: IEditableListObject;
      if Interfaces.Supports<IEditableListObject>(_EditContext, e) then
      begin
        if Cancel then
          e.CancelEdit else
          e.EndEdit;
      end;
    finally
      EndUpdate;
    end;
  end;

  _EditContext := Context;
end;

procedure TObjectListModelWithChangeTracking<T>.NotifyBeginEdit(const Context: IObjectModelContext);
begin
  UpdateEditContext(Context);

  var i := _Context.IndexOf(Context.Context);
  if i = -1 then
    raise Exception.Create('NotifyBeginEdit, item could not be located');

  _Context[i] := Context.Context;

  if _OnItemChanged <> nil then
  begin
    var n: IListItemChanged;
    for n in _OnItemChanged do
      n.BeginEdit(Context.Context);
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.NotifyCancelEdit(const Context: IObjectModelContext; const OriginalObject: CObject);
begin
  _EditContext := nil;

  var i := _Context.IndexOf(Context.Context);
  if i = -1 then
    raise Exception.Create('NotifyCancelEdit, item could not be located');

  _Context[i] := OriginalObject;

  if _OnItemChanged <> nil then
  begin
    var n :IListItemChanged;
    for n in _OnItemChanged do
      n.CancelEdit(Context.Context);
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.NotifyEndEdit(const Context: IObjectModelContext; const OriginalObject: CObject; Index: Integer; Position: InsertPosition);
var
  item: CObject;
  savableItem: CObject;
begin
  var e: IEditState;
  if not Interfaces.Supports<IEditState>(Context, e) or not e.IsEditOrNew then
    Exit;

  _EditContext := nil;

  item := Context.Context;

  if e.IsEdit then
  begin
    if (_Context <> nil) then
    begin
      if Index <> -1 then
        _Context[Index] := item

      else begin
        var i := _Context.IndexOf(OriginalObject);
        if i = -1 then
          raise Exception.Create('NotifyEndEdit, item could not be located');
        _Context[i] := item;
      end;
    end;

    // Do not override initial change (object might have been added)
    UpdateChangedItem(OriginalObject, TObjectListChangeType.Changed);

    if _OnItemChanged <> nil then
    begin
     var n: IListItemChanged;
     for n in _OnItemChanged do
        n.EndEdit(item);
    end;
  end
  else if e.IsNew then
  begin
    savableItem := item;
    UpdateChangedItem(savableItem, TObjectListChangeType.Added);

    if _OnItemChanged <> nil then
    begin
     var n: IListItemChanged;
     for n in _OnItemChanged do
       n.Added(item, Index);
    end;
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.UpdateChangedItem(const Obj: CObject; ChangeType: TObjectListChangeType);
begin
  if not _storeChangedItems then
    Exit;

  // Do not override initial change (object might have been added)
  if not _ChangedItems.ContainsKey(Obj) then
    _ChangedItems.Add(Obj, ChangeType)
  else if ChangeType = TObjectListChangeType.Removed then
  begin
    var ct: TObjectListChangeType;
    if _ChangedItems.TryGetValue(Obj, ct) and (ct = TObjectListChangeType.Added) then
      _ChangedItems.Remove(Obj) else
      _ChangedItems[Obj] := TObjectListChangeType.Removed;
  end
  else if (_ChangedItems[Obj] = TObjectListChangeType.Removed) and (ChangeType = TObjectListChangeType.Added) then
    _ChangedItems.Remove(Obj);
end;

function TObjectListModelWithChangeTracking<T>.CreateInstance: CObject;
begin
  {$IFDEF DELPHI}
  if Assigned(_CreatorFunc) then
    Result := CObject.From<T>(_CreatorFunc);
  {$ELSE}
  if Assigned(_CreatorFunc) then
    Result := _CreatorFunc.Invoke;
  {$ENDIF}
end;

procedure TObjectListModelWithChangeTracking<T>.EndEdit;
begin
  UpdateEditContext(nil);
end;

procedure TObjectListModelWithChangeTracking<T>.EndUpdate;
begin
  dec(_UpdateCount);
end;

procedure TObjectListModelWithChangeTracking<T>.NotifyAddingNew(const Context: IObjectModelContext; var Index: Integer; Position: InsertPosition);
begin
  _Context.Insert(&Index, Context.Context);

  UpdateEditContext(Context);

  if _OnItemChanged <> nil then
  begin
    var n: IListItemChanged;
    for n in _OnItemChanged do
      n.AddingNew(Context.Context, {var}Index, Position);
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.NotifyRemoved(const Item: CObject; const Index: Integer);
begin
  UpdateChangedItem(Item, TObjectListChangeType.Removed);

  if _OnItemChanged <> nil then
  begin
    var &notify: IListItemChanged;
    for &notify in _OnItemChanged do
      &notify.Removed(Item, Index);
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.OnObjectPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
begin
  if HasMultiSelection then
  begin
    var item: CObject;
    for item in _multiSelect.Context do
      if not CObject.Equals(item, Context) then
      begin
        var cln: ICloneable;
        var obj: CObject;
        if item.TryAsType<ICloneable>(cln) then
          obj := cln.Clone else
          obj := item;

        UpdateChangedItem(obj, TObjectListChangeType.Changed);
        {$IFNDEF WEBASSEMBLY}
        AProperty.SetValue(item, AProperty.GetValue(Context, []), [], True);
        {$ELSE}
        AProperty.SetValue(item, AProperty.GetValue(Context, []), []);
        {$ENDIF}
      end;    
  end;

end;

procedure TObjectListModelWithChangeTracking<T>.Remove(const Item: CObject);
begin
  if Item = nil then Exit;

  // if IsNew item then insert it into the _changedItems this way
  // it will be removed properly in NotifyRemoved
  UpdateEditContext(nil, not get_IsNew);

  var ix: Integer;
  var newSelected: CObject;

  ix := _Context.IndexOf(Item);
  if ix <> -1 then
  begin
    if ix > 0 then
      newSelected := _Context[ix - 1]
    else if _Context.Count > 1 then
      newSelected := _Context[1];

    _Context.RemoveAt(ix);
  end;

  NotifyRemoved(Item, ix);

  inherited set_ObjectContext(newSelected);
end;

procedure TObjectListModelWithChangeTracking<T>.ResetContextFromChangedItems;
begin
  if get_IsEditOrNew then
    CancelEdit;

  var pair: KeyValuePair<CObject, TObjectListChangeType>;
  for pair in get_ChangedItems do
  begin
    var obj := pair.Key;
    var ix := get_Context.IndexOf(obj);

    case pair.Value of
      TObjectListChangeType.Added: begin
        if ix <> -1 then
          get_Context.RemoveAt(ix);
      end;
      TObjectListChangeType.Changed: begin
        if ix <> -1 then
          get_Context[ix] := obj;
      end;
      TObjectListChangeType.Removed: begin
        get_Context.Add(obj);
      end;
    end;
  end;

  get_ChangedItems.Clear;
end;

procedure TObjectListModelWithChangeTracking<T>.Remove;
begin
  Remove(get_ObjectContext);
end;

procedure TObjectListModelWithChangeTracking<T>.set_Context(const Value: IList);
begin
  inherited;
  _ChangedItems.Clear;
end;

procedure TObjectListModelWithChangeTracking<T>.set_MultiObjectContextSupport(const Value: Boolean);
begin
  _DoMultiContextSupport := Value;
end;

procedure TObjectListModelWithChangeTracking<T>.set_ObjectContext(const Value: CObject);
begin
  if not CObject.ReferenceEquals(get_ObjectContext, Value) then
  begin
    UpdateEditContext(nil);
    inherited;
  end;
end;

procedure TObjectListModelWithChangeTracking<T>.set_StoreChangedItems(const Value: Boolean);
begin
  _storeChangedItems := Value;
  if not Value then
    _ChangedItems.Clear;
end;

end.


