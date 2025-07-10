{$IFNDEF WEBASSEMBLY}
{$I ADato.inc}
{$ENDIF}

unit ADato.ObjectModel.DataModel.impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  {$ELSE}
  Wasm.System.SysUtils,
  ADato.TypeCustomization,
  {$ENDIF}
  System_,
  ADato.ObjectModel.intf,
  ADato.ObjectModel.List.intf,
  System.Collections,
  System.Collections.Generic,
  ADato.Data.DataModel.intf,
  ADato.ObjectModel.TrackInterfaces,
  ADato.ObjectModel.impl, ADato.InsertPosition,
  ADato.ObjectModel.List.Tracking.intf,
  ADato.MultiObjectModelContextSupport.impl,
  ADato.EditableObjectModelContext.impl;

type
  TDataRowInfo = record
  public
    Location: CObject;
    Position: InsertPosition;
    Level: Integer;
  end;

  TDataModelObjectListModel = class(TBaseInterfacedObject,
    IObjectListModel,
    IAddingNew,
    IEditState,
    IEditableModel,
    INotifyListItemChanged,
    IObjectListModelChangeTracking,
    IOnItemChangedSupport)
  protected
    _dataModel: IDataModel;

    _creatorFunc  : TFunc<CObject>;
    _storeChangedItems: Boolean;
    _changedItems : Dictionary<CObject, TObjectListChangeType>;   // List
    _originalDataRows : Dictionary<CObject, TDataRowInfo>;   // List

    _OnContextCanChange: ListContextCanChangeEventHandler;
    _OnContextChanging: ListContextChangingEventHandler;
    _OnContextChanged: ListContextChangedEventHandler;
    _ObjectModel: IObjectModel;
    _ObjectModelContext: IObjectModelContext;
    _HandleModelObjectContextExternally: Boolean; // => for example while animating wait for animation to complete

    _DoMultiContextSupport: Boolean;
    _previousIndex: Integer;
    _updateCount: Integer;
    _multiSelect: IObjectModelMultiSelect;

    // IOnItemChangedSupport
    _OnItemChanged: IList<IListItemChanged>;

    // DATAMODLE
    procedure OnRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);

    procedure OnObjectContextChanged(const ObjectModelContext: IObjectModelContext; const Context: CObject);
    procedure OnObjectPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);

    // TObjectModel
    function  CreateObjectModel : IObjectModel; virtual;
    function  CreateObjectModelContext : IObjectModelContext; virtual;
    procedure ResetModelProperties;

    function  ListHoldsObjectType: Boolean; virtual;
    function  HasMultiSelection: Boolean;
    function  ContextCanChange: Boolean;

    // IObjectListModel
    function  get_Context: IList; virtual;
    procedure set_Context(const Value: IList); virtual;
    function  get_ObjectType: &Type;
    function  get_ObjectContext: CObject; virtual;
    procedure set_ObjectContext(const Value: CObject); virtual;
    function  get_ObjectModel: IObjectModel;
    procedure set_ObjectModel(const Value: IObjectModel);
    function  get_ObjectModelContext: IObjectModelContext;
    procedure set_MultiObjectContextSupport(const Value: Boolean);
    function  get_MultiSelect: IObjectModelMultiSelect;

    {$IFNDEF WEBASSEMBLY}
    function  get_OnContextCanChange: ListContextCanChangeEventHandler;
    function  get_OnContextChanging: ListContextChangingEventHandler;
    function  get_OnContextChanged: ListContextChangedEventHandler;
    {$ELSE}
    event OnContextCanChange: ListContextCanChangeEventHandler delegate _OnContextCanChange;
    event OnContextChanging: ListContextChangingEventHandler delegate _OnContextChanging;
    event OnContextChanged: ListContextChangedEventHandler delegate _OnContextChanged;
    {$ENDIF}

    // helper functions for interfaces
    function  ModelEditFlags: RowEditFlags;
    function  DataRowViewAtIndex(const Index: Integer; CurrentIfNil: Boolean): IDataRowView;
    function  DataRowAtIndex(const Index: Integer; CurrentIfNil: Boolean): IDataRow;
    procedure UpdateChangedItem(const Obj: CObject; ChangeType: TObjectListChangeType);

    // IEditState
    function  get_IsChanged: Boolean;
    function  get_IsEdit: Boolean;
    function  get_IsNew: Boolean;
    function  get_IsEditOrNew: Boolean;

    // IEditableModel
    function  AddNew(Index: Integer; Position: InsertPosition) : Boolean;
    procedure BeginEdit(Index: Integer);
    procedure CancelEdit;
    procedure EndEdit; virtual;
    procedure Remove; overload;
    procedure Remove(const Item: CObject); overload;

    function CanAdd : Boolean;
    function CanEdit : Boolean;
    function CanRemove : Boolean;

    // IAddNewSupport
    function CreateInstance: CObject;

    // INotifyListItemChanged
    procedure NotifyAddingNew(const Context: IObjectModelContext; var Index: Integer; Position: InsertPosition);
    procedure NotifyCancelEdit(const Context: IObjectModelContext; const OriginalObject: CObject);
    procedure NotifyBeginEdit(const Context: IObjectModelContext);
    procedure NotifyEndEdit(const Context: IObjectModelContext; const OriginalObject: CObject; Index: Integer; Position: InsertPosition);
    procedure NotifyRemoved(const Item: CObject; const Index: Integer);

    // IObjectListModelChangeTracking
    function  get_HasChangedItems: Boolean;
    function  get_ChangedItems: Dictionary<CObject, TObjectListChangeType>;
    procedure set_StoreChangedItems(const Value: Boolean);

    procedure ResetContextFromChangedItems;

    function  RetrieveUpdatedItems: Dictionary<CObject, TObjectListChangeType>;
    procedure CacheOriginalData(const Obj: CObject);

    // IOnItemChangedSupport
    function get_OnItemChanged: IList<IListItemChanged>;
  public
    constructor Create(HandleModelObjectContextExternally: Boolean; const CreatorFunc: TFunc<CObject> = nil); reintroduce;
    destructor Destroy; override;

    function  SelectedAsList: IList;
  end;

  TDataModelObjectModel = class(TBaseInterfacedObject, IObjectModel)
  protected
    _dataModelType: &Type;
    _properties: PropertyInfoArray;
    _dataModel: IDataModel;

    {$IFDEF DOTNET}
    function  GetTypeEx: &Type;
    {$ENDIF}

    function  GetType: &Type; {$IFNDEF WEBASSEMBLY}override;{$ENDIF}
    function  CreateObjectModelContext : IObjectModelContext;
  public
    constructor Create(const DataModel: IDataModel); virtual;

    procedure ResetModelProperties; virtual;
  end;

  TDataModelPropertyForObjectModel = class(CPropertyInfo)
  protected
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _datamodelColumn: IDataModelColumn;
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _datamodel: IDataModel;

    function  get_Name: CString; override;
    function  get_CanRead: Boolean; override;
    function  get_CanWrite: Boolean; override;

    function  GetValue(const obj: CObject; const index: array of CObject): CObject; override;
    procedure SetValue(const obj: CObject; const value: CObject; const index: array of CObject; ExecuteTriggers: Boolean = false); override;
  public
    constructor Create(const DataModel: IDataModel; const DataModelColumn: IDataModelColumn); reintroduce;

    function  GetType: &Type; override;
  end;

  TDataModelEditableObjectModelContext = class(TEditableObjectModelContext)
  protected
    procedure DoContextChanged; override;
  end;

  TDataModelMultiEditableObjectModelContext = class(TMultiEditableObjectModelContext)
  protected
    procedure DoContextChanged; override;

    function  ConvertToData(const DataItem: CObject): CObject; override;
  end;

implementation

{ TObjectListModel }

function TDataModelObjectListModel.DataRowAtIndex(const Index: Integer; CurrentIfNil: Boolean): IDataRow;
begin
  var drv := DataRowViewAtIndex(Index, CurrentIfNil);
  if drv <> nil then
    Result := drv.Row else
    Result := nil;
end;

function TDataModelObjectListModel.DataRowViewAtIndex(const Index: Integer; CurrentIfNil: Boolean): IDataRowView;
begin
  if _dataModel = nil then
    Exit(nil);

  var ix := -1;
  if (Index <> -1) and (Index < _dataModel.DefaultView.Rows.Count) then
    ix := Index
  else if _previousIndex <> -1 then
    ix := _previousIndex
  else if CurrentIfNil then
  begin
    var obj := get_ObjectContext;
    if obj <> nil then
    begin
      var dr := _dataModel.FindByKey(get_ObjectContext);
      if dr <> nil then
        Exit(_dataModel.DefaultView.FindRow(dr));
    end;

    ix := _dataModel.DefaultCurrencyManager.Current; // can be -1
  end;

  if (ix <> -1) then
    Result := _dataModel.DefaultView.Rows[ix] else
    Result := nil;
end;

destructor TDataModelObjectListModel.Destroy;
begin
  set_Context(nil);

  inherited;
end;

function TDataModelObjectListModel.AddNew(Index: Integer; Position: InsertPosition): Boolean;
begin
  Assert(Assigned(_CreatorFunc));
  (get_ObjectModelContext as IEditableListObject).AddNew(CreateInstance, Index, Position);
  Result := True;
end;

procedure TDataModelObjectListModel.BeginEdit(Index: Integer);
begin
  (get_ObjectModelContext as IEditableListObject).BeginEdit(Index);
end;

procedure TDataModelObjectListModel.CancelEdit;
begin
  (get_ObjectModelContext as IEditableListObject).CancelEdit;
end;

function TDataModelObjectListModel.CanAdd: Boolean;
begin
  Result := Assigned(_CreatorFunc);
end;

function TDataModelObjectListModel.CanEdit: Boolean;
begin
  Result := not get_IsEditOrNew;
end;

function TDataModelObjectListModel.CanRemove: Boolean;
begin
  Result := DataRowAtIndex(-1, True) <> nil;
end;

function TDataModelObjectListModel.ContextCanChange: Boolean;
begin
  if (_ObjectModelContext <> nil) and not _ObjectModelContext.ContextCanChange then
    Exit(False);

  Result := (_OnContextCanChange = nil) or _OnContextCanChange.Invoke(Self, _dataModel as IList);
end;

procedure TDataModelObjectListModel.EndEdit;
begin
  (get_ObjectModelContext as IEditableListObject).EndEdit;
end;

procedure TDataModelObjectListModel.Remove;
begin
  var drv := DataRowViewAtIndex(-1, True);
  if drv <> nil then
    Remove(drv.Row.Data);
end;

procedure TDataModelObjectListModel.Remove(const Item: CObject);
begin
  var row := _dataModel.FindByKey(Item);
  if row <> nil then
  begin
    CacheOriginalData(Item);

    // if IsNew item then insert it into the _changedItems this way
    // it will be removed properly in NotifyRemoved
    if get_IsNew then
      UpdateChangedItem(row.Data, TObjectListChangeType.Added);

    _dataModel.Remove(row);
    NotifyRemoved(row.Data, row.get_Index);
  end;
end;

constructor TDataModelObjectListModel.Create(HandleModelObjectContextExternally: Boolean; const CreatorFunc: TFunc<CObject> = nil);
begin
  inherited Create;

  _HandleModelObjectContextExternally := HandleModelObjectContextExternally;
  _creatorFunc := CreatorFunc;
  _storeChangedItems := True;
  _changedItems := CDictionary<CObject, TObjectListChangeType>.Create;
  _originalDataRows := CDictionary<CObject, TDataRowInfo>.Create;
  _previousIndex := -1;

  {$IFNDEF WEBASSEMBLY}
  _OnContextCanChange := ListContextCanChangeEventDelegate.Create;
  _OnContextChanging := ListContextChangingEventDelegate.Create;
  _OnContextChanged := ListContextChangedEventDelegate.Create;
  {$ENDIF}
end;

function TDataModelObjectListModel.CreateInstance: CObject;
begin
  {$IFNDEF WEBASSEMBLY}
  if Assigned(_CreatorFunc) then
    Result := _CreatorFunc();
  {$ELSE}
  if Assigned(_CreatorFunc) then
    Result := _CreatorFunc.Invoke;
  {$ENDIF}
end;

function TDataModelObjectListModel.CreateObjectModel: IObjectModel;
begin
  Result := TDataModelObjectModel.Create(_dataModel);
end;

function TDataModelObjectListModel.CreateObjectModelContext: IObjectModelContext;
begin
  if _DoMultiContextSupport then
    Result := TDataModelMultiEditableObjectModelContext.Create(get_ObjectModel, Self) else
    Result := TDataModelEditableObjectModelContext.Create(get_ObjectModel, Self);
end;

function TDataModelObjectListModel.get_Context: IList;
begin
  Result := _datamodel as IList;
end;

function TDataModelObjectListModel.ModelEditFlags: RowEditFlags;
begin
  var row := DataRowAtIndex(-1, True);
  if row <> nil then
    Result := _dataModel.EditFlags(row) else
    Result := [];
end;

procedure TDataModelObjectListModel.NotifyAddingNew(const Context: IObjectModelContext; var Index: Integer; Position: InsertPosition);
begin
  CacheOriginalData(Context.Context);

  var insertLocation := DataRowAtIndex(Index, False) {can be nil};

  _dataModel.BeginUpdate;
  try
    var dr := _dataModel.AddNew(insertLocation, Position);
    dr.Data := Context.Context;
    _dataModel.Keys.Add(dr.Data, dr);
    _dataModel.DefaultView.Refresh;
  finally
    _dataModel.EndUpdate;
  end;

  var n: IListItemChanged;
  for n in get_OnItemChanged do
    n.AddingNew(Context.Context, {var}Index, Position);
end;

procedure TDataModelObjectListModel.NotifyBeginEdit(const Context: IObjectModelContext);
begin
  CacheOriginalData(Context.Context);

  var row := _dataModel.FindByKey(Context.Context);
  _dataModel.BeginEdit(row);

  if row <> nil then
    row.Data := Context.Context;

  var n: IListItemChanged;
  for n in get_OnItemChanged do
    n.BeginEdit(Context.Context);
end;

procedure TDataModelObjectListModel.NotifyCancelEdit(const Context: IObjectModelContext; const OriginalObject: CObject);
begin
  // if IsNew item then insert it into the _changedItems this way
  // it will be removed properly in NotifyRemoved
  var wasNew := get_IsNew;

  var row := _dataModel.FindByKey(Context.Context);
  _dataModel.CancelEdit(row);

  var dr := _dataModel.FindByKey(Context.Context);
  if dr <> nil then
    dr.Data := OriginalObject;

  var n: IListItemChanged;
  for n in get_OnItemChanged do
    n.CancelEdit(Context.Context);

  if wasNew and (dr = nil) then // it has been removed by _dataModel
    set_ObjectContext(nil);
end;

procedure TDataModelObjectListModel.NotifyEndEdit(const Context: IObjectModelContext; const OriginalObject: CObject; Index: Integer; Position: InsertPosition);
begin
  var e: IEditState;
  if not Interfaces.Supports<IEditState>(Context, e) or not e.IsEditOrNew then
    Exit;

  if e.IsEdit then
  begin
    _dataModel.EndEdit(_dataModel.FindByKey(Context.Context));

    // Do not override initial change (object might have been added)
    UpdateChangedItem(OriginalObject, TObjectListChangeType.Changed);

    var n: IListItemChanged;
    for n in get_OnItemChanged do
      n.EndEdit(Context.Context);
  end
  else if e.IsNew then
  begin
    _dataModel.EndEdit(_dataModel.FindByKey(Context.Context));

    UpdateChangedItem(Context.Context, TObjectListChangeType.Added);

    var n: IListItemChanged;
    for n in get_OnItemChanged do
      n.Added(Context.Context, Index);
  end;
end;

procedure TDataModelObjectListModel.NotifyRemoved(const Item: CObject; const Index: Integer);
begin
  UpdateChangedItem(Item, TObjectListChangeType.Removed);

  var n: IListItemChanged;
  for n in get_OnItemChanged do
    n.Removed(Item, Index);
end;

function TDataModelObjectListModel.get_IsChanged: Boolean;
begin
  Result := _changedItems.Count > 0;
end;

function TDataModelObjectListModel.get_IsEdit: Boolean;
begin
  Result := RowEditState.IsEdit in ModelEditFlags;
end;

function TDataModelObjectListModel.get_IsEditOrNew: Boolean;
begin
  Result := get_IsEdit or get_IsNew;
end;

function TDataModelObjectListModel.get_IsNew: Boolean;
begin
  Result := RowEditState.IsNew in ModelEditFlags;
end;

function TDataModelObjectListModel.get_MultiSelect: IObjectModelMultiSelect;
begin
  if _multiSelect = nil then
    _multiSelect := TObjectModelMultiSelect.Create(Self);

  Result := _multiSelect;
end;

function TDataModelObjectListModel.get_ObjectType: &Type;
begin
  Result := &Type.Unknown;
end;

function TDataModelObjectListModel.get_ObjectContext: CObject;
begin
  var omc := get_ObjectModelContext;
  if omc <> nil then
    Result := omc.Context else
    Result := nil;
end;

function TDataModelObjectListModel.get_ObjectModel: IObjectModel;
begin
  if (_ObjectModel = nil) then
    _ObjectModel := CreateObjectModel;

  Result := _ObjectModel;
end;

function TDataModelObjectListModel.get_ObjectModelContext: IObjectModelContext;
begin
  if (_ObjectModelContext = nil) and (get_Context <> nil) then
  begin
    _ObjectModelContext := CreateObjectModelContext;
    {$IFNDEF WEBASSEMBLY}
    _ObjectModelContext.OnContextChanged.Add(OnObjectContextChanged);
    _ObjectModelContext.OnPropertyChanged.Add(OnObjectPropertyChanged);
    {$ELSE}
    _ObjectModelContext.OnContextChanged += @OnObjectContextChanged;
    _ObjectModelContext.OnPropertyChanged += @OnObjectPropertyChanged;
    {$ENDIF}
  end;

  Result := _ObjectModelContext;
end;

{$IFNDEF WEBASSEMBLY}
function TDataModelObjectListModel.get_OnContextCanChange: ListContextCanChangeEventHandler;
begin
  Result := _OnContextCanChange;
end;

function TDataModelObjectListModel.get_OnContextChanged: ListContextChangedEventHandler;
begin
  Result := _OnContextChanged;
end;

function TDataModelObjectListModel.get_OnContextChanging: ListContextChangingEventHandler;
begin
  Result := _OnContextChanging;
end;
{$ENDIF}

function TDataModelObjectListModel.ListHoldsObjectType: Boolean;
begin
  Result := False;
end;

procedure TDataModelObjectListModel.OnObjectContextChanged(const ObjectModelContext: IObjectModelContext; const Context: CObject);
begin
  if (_updateCount > 0) then Exit;

  inc(_updateCount);
  try
    var ix := -1;
    if Context <> nil then
    begin
      var dr := _dataModel.FindByKey(Context);
      if dr <> nil then
      begin
        var drv := _dataModel.DefaultView.FindRow(dr);
        if drv <> nil then
          ix := drv.ViewIndex;
      end;
    end;

    _dataModel.DefaultCurrencyManager.Current := ix;
  finally
    dec(_updateCount);
  end;
end;

procedure TDataModelObjectListModel.OnObjectPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
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

        CacheOriginalData(item);
        UpdateChangedItem(obj, TObjectListChangeType.Changed);
        {$IFNDEF WEBASSEMBLY}
        AProperty.SetValue(item, AProperty.GetValue(Context, []), [], True);
        {$ELSE}
        AProperty.SetValue(item, AProperty.GetValue(Context, []), []);
        {$ENDIF}
      end;      
  end;
end;

procedure TDataModelObjectListModel.OnRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);
begin
  if (_updateCount > 0) or (Args.NewIndex = -1) then Exit;

  if _HandleModelObjectContextExternally then Exit;

  inc(_updateCount);
  _previousIndex := Args.OldIndex;
  try
    var &new := _dataModel.DefaultView.Rows[Args.NewIndex];
    set_ObjectContext(&new.Row.Data);
  finally
    _previousIndex := -1;
    dec(_updateCount);
  end;
end;

procedure TDataModelObjectListModel.ResetContextFromChangedItems;

  procedure ResetByLevel(const Level, MaxLevel: Integer);
  begin
    // first reset parents
    // then children..
    // to make sure that the original locations exist for children

    if Level > MaxLevel then
      Exit;

    var foundItems: List<CObject> := CList<CObject>.Create;
    while True do
    begin
      var foundCount := foundItems.Count;

      var pair: KeyValuePair<CObject, TObjectListChangeType>;
      for pair in get_ChangedItems do
      begin
        var obj := pair.Key;
        if foundItems.Contains(obj) then
          Continue;

        var dr := _dataModel.FindByKey(obj);
        var rowInfo := _originalDataRows[obj];

        if rowInfo.Level <> Level then
          Continue;

        case pair.Value of
          TObjectListChangeType.Added: begin
            if dr <> nil then
              _dataModel.Remove(dr);

            foundItems.Add(obj);
          end;
          TObjectListChangeType.Changed: begin
            if dr <> nil then
              _dataModel.Remove(dr);

            // re-index
            if rowInfo.Position <> InsertPosition.None {_dataModel.FindByKey(rowInfo.Location) <> nil} then
            begin
              _dataModel.Add(obj, rowInfo.Location {can be nil}, rowInfo.Position);
              foundItems.Add(obj);
            end;
          end;
          TObjectListChangeType.Removed:
            if rowInfo.Position <> InsertPosition.None {_dataModel.FindByKey(rowInfo.Location) <> nil} then
            begin
              _dataModel.Add(obj, rowInfo.Location {can be nil}, rowInfo.Position);
              foundItems.Add(obj);
            end;
        end;
      end;

      // no insertlocations found anymore
      if foundCount = foundItems.Count then
      begin
        Assert(foundCount = get_ChangedItems.Count);
        Break;
      end;
    end;

    ResetByLevel(Level + 1, MaxLevel);
  end;

begin
  if get_IsEditOrNew then
    CancelEdit;

  var maxLevel := 0;
  var rowInfo: TDataRowInfo;
  for rowInfo in _originalDataRows.Values do
    maxLevel := CMath.Max(maxLevel, rowInfo.Level);

  ResetByLevel(0, maxLevel);

  get_ChangedItems.Clear;
end;

procedure TDataModelObjectListModel.ResetModelProperties;
begin
  if _ObjectModel <> nil then
    _ObjectModel.ResetModelProperties;
end;

procedure TDataModelObjectListModel.set_StoreChangedItems(const Value: Boolean);
begin
  _storeChangedItems := Value;
end;

function TDataModelObjectListModel.get_ChangedItems: Dictionary<CObject, TObjectListChangeType>;
begin
  Result := _changedItems;
end;

function TDataModelObjectListModel.get_HasChangedItems: Boolean;
begin
  Result := _changedItems.Count > 0;
end;

function TDataModelObjectListModel.RetrieveUpdatedItems: Dictionary<CObject, TObjectListChangeType>;
var
  pair: KeyValuePair<CObject, TObjectListChangeType>;
begin
  Result := CDictionary<CObject, TObjectListChangeType>.Create;
  if not get_HasChangedItems then
    Exit;

  for pair in get_ChangedItems do
  begin
    // ChangedItems contains the orignal objects
    // DataModel contains the current state of the object.
    if pair.Value <> TObjectListChangeType.Removed then
    begin
      var item := _dataModel.FindByKey(pair.Key).Data;
      Result.Add(item, pair.Value);
    end else
      Result.Add(pair.Key, pair.Value);
  end;
end;

function TDataModelObjectListModel.SelectedAsList: IList;
begin
  if HasMultiSelection then
    Exit(_multiSelect.Context as IList);

  var selectedItem := get_ObjectContext;
  if selectedItem <> nil then
  begin
    Result := CList<CObject>.Create(1);
    Result.Add(selectedItem);
  end else
    Result := nil;
end;

procedure TDataModelObjectListModel.set_Context(const Value: IList);
begin
  {$IFDEF WINDOWS}
  Assert(GetCurrentThreadID = MainThreadID);
  {$ENDIF}

  if not ContextCanChange then
    Exit;

  if _OnContextChanging <> nil then
    _OnContextChanging.Invoke(Self, get_Context);

  if _dataModel <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    _dataModel.DefaultCurrencyManager.CurrentRowChanged.Remove(OnRowChanged);
    _ObjectModelContext.OnContextChanged.Remove(OnObjectContextChanged);
    _ObjectModelContext.OnPropertyChanged.Remove(OnObjectPropertyChanged);
    {$ELSE}
    _dataModel.DefaultCurrencyManager.CurrentRowChanged -= OnRowChanged;
    _ObjectModelContext.OnContextChanged -= OnObjectContextChanged;
    _ObjectModelContext.OnPropertyChanged -= OnObjectPropertyChanged;
    {$ENDIF}

    _ObjectModelContext := nil;
    _ObjectModel := nil;

    set_ObjectContext(nil);
  end;

  _dataModel := Value as IDataModel;

  if _dataModel <> nil then
  begin
    {$IFDEF DELPHI}
    _dataModel.DefaultCurrencyManager.CurrentRowChanged.Add(OnRowChanged);      
    {$ELSE}
    _dataModel.DefaultCurrencyManager.CurrentRowChanged += @OnRowChanged;
    {$ENDIF}
  end;


  if _OnContextChanged <> nil then
 		_OnContextChanged.Invoke(Self, get_Context);
end;

procedure TDataModelObjectListModel.set_MultiObjectContextSupport(const Value: Boolean);
begin
  _DoMultiContextSupport := Value;
end;

procedure TDataModelObjectListModel.set_ObjectContext(const Value: CObject);
begin
  // nothing to do.. _datamodel may not have been intialized yet
  if (Value = nil) and (_ObjectModelContext = nil) then
    Exit;

  get_ObjectModelContext.Context := Value;
end;

procedure TDataModelObjectListModel.set_ObjectModel(const Value: IObjectModel);
begin
  _ObjectModel := Value;
end;

procedure TDataModelObjectListModel.CacheOriginalData(const Obj: CObject);
begin
  if Obj = nil then
    Exit;

  // if cleared externally
  if _changedItems.Count = 0 then
    _originalDataRows.Clear;

  if not _storeChangedItems then
    Exit;

  if not _originalDataRows.ContainsKey(Obj) then
  begin
    var dr := _dataModel.FindByKey(Obj);
    var rowInfo: TDataRowInfo;
    rowInfo.Position := InsertPosition.None;

    if dr <> nil then
    begin
      rowInfo.Level := dr.Level;

      var parent := _dataModel.Parent(dr);
      if parent <> nil then
      begin
        rowInfo.Location := parent.Data;
        rowInfo.Position := InsertPosition.Child;
      end else
      begin
        var prev := _dataModel.Prev(dr);
        if prev <> nil then
        begin
          rowInfo.Position := InsertPosition.After;
          rowInfo.Location := prev.Data;
        end else
        begin
          rowInfo.Position := InsertPosition.Before;

          var next := _dataModel.Next(dr);
          if next <> nil then
            rowInfo.Location := next.Data else
            rowInfo.Location := nil;
        end;
      end;
    end else
      rowInfo.Level := 0;

    _originalDataRows.Add(Obj, rowInfo {can be nil});
  end;
end;

procedure TDataModelObjectListModel.UpdateChangedItem(const Obj: CObject; ChangeType: TObjectListChangeType);
begin
  if not _storeChangedItems then
    Exit;

  // Do not override initial change (object might have been added)
  if not _changedItems.ContainsKey(Obj) then
    _changedItems.Add(Obj, ChangeType)
  else if ChangeType = TObjectListChangeType.Removed then
  begin
    var ct: TObjectListChangeType;
    if _changedItems.TryGetValue(Obj, ct) and (ct = TObjectListChangeType.Added) then
      _changedItems.Remove(Obj) else
      _changedItems[Obj] := TObjectListChangeType.Removed;
  end;
end;

function TDataModelObjectListModel.get_OnItemChanged: IList<IListItemChanged>;
begin
  if _OnItemChanged = nil then
    _OnItemChanged := CList<IListItemChanged>.Create;

  Result := _OnItemChanged;
end;

function TDataModelObjectListModel.HasMultiSelection: Boolean;
begin
  Result := (_multiSelect <> nil) and (_multiSelect.Count > 0);
end;

{ TDataModelObjectModel }

constructor TDataModelObjectModel.Create(const DataModel: IDataModel);
begin
  Assert(DataModel <> nil);
  _dataModel := DataModel;
  ResetModelProperties;
end;

function TDataModelObjectModel.CreateObjectModelContext: IObjectModelContext;
begin
  raise NotImplementedException.Create;
end;

function TDataModelObjectModel.GetType: &Type;
begin
  {$IFNDEF WEBASSEMBLY}
  if _dataModelType.IsUnknown then
  begin
    Assert(_dataModel <> nil);

    _properties := [];

    _dataModelType := Global.GetTypeOf<IDataModel>;
    _dataModelType.GetPropertiesExternal :=
      function : PropertyInfoArray begin
        if Length(_properties) = 0 then
        begin
          SetLength(_properties, _dataModel.Columns.Count);
          var i := 0;
          var clmn: IDataModelColumn;
          for clmn in _dataModel.Columns do
          begin
            var prop: _PropertyInfo := TDataModelPropertyForObjectModel.Create(_dataModel, clmn);
            _properties[i] := TObjectModelPropertyWrapper.Create(prop);
            inc(i);
          end;
        end;

        Result := _properties;
      end;
  end;
  {$ELSE}
  if _dataModelType.IsUnknown then
  begin
    Assert(_dataModel <> nil);

    _properties := [];

    _dataModelType := TypeExtensions.Create(Global.GetTypeOf<IDataModel>);
    TypeExtensions(_dataModelType).GetPropertiesExternal :=
      function : PropertyInfoArray begin
        if Length(_properties) = 0 then
        begin
          SetLength(_properties, _dataModel.Columns.Count);
          var i := 0;

          for clmn in _dataModel.Columns do
          begin
            var prop: _PropertyInfo := TDataModelPropertyForObjectModel.Create(_dataModel, clmn);
            _properties[i] := TObjectModelPropertyWrapper.Create(prop);
            inc(i);
          end;
        end;

        Result := _properties;
      end;
  end;
  {$ENDIF}

  Result := _dataModelType;
end;

procedure TDataModelObjectModel.ResetModelProperties;
begin
  _dataModelType := &Type.Unknown;
end;

{ TDataModelPropertyForObjectModel }

constructor TDataModelPropertyForObjectModel.Create(const DataModel: IDataModel; const DataModelColumn: IDataModelColumn);
begin
  inherited Create;

  _dataModel := DataModel;
  _datamodelColumn := DataModelColumn;
end;

function TDataModelPropertyForObjectModel.get_CanRead: Boolean;
begin
  Result := True; // check CanRead will be done in function GetValue
end;

function TDataModelPropertyForObjectModel.get_CanWrite: Boolean;
begin
  Result := True; // check CanWrite will be done in function SetValue
end;

function TDataModelPropertyForObjectModel.get_Name: CString;
begin
  Result := _dataModelColumn.Name;
end;

function TDataModelPropertyForObjectModel.GetType: &Type;
begin
  Result := _dataModelColumn.DataType;
end;

function TDataModelPropertyForObjectModel.GetValue(const obj: CObject; const index: array of CObject): CObject;
begin
  var dr := _dataModel.FindByKey(obj);
  if dr <> nil then
    Result := _dataModel.GetFieldValue(_datamodelColumn, dr) else
    Result := nil;
end;

procedure TDataModelPropertyForObjectModel.SetValue(const obj, value: CObject; const index: array of CObject; ExecuteTriggers: Boolean);
begin
  var dr := _dataModel.FindByKey(obj);
  _dataModel.SetFieldValue(_datamodelColumn, dr, value);
end;

{ TDataModelEditableObjectModelContext }

procedure TDataModelEditableObjectModelContext.DoContextChanged;
begin
  if _context <> nil then
  begin
    var dm := _owner.Context as IDataModel;
    var dr := dm.FindByKey(get_Context);
    if dr <> nil then // if not new
      dm.DefaultView.MakeRowVisible(dr);
  end;

  inherited;
end;

{ TDataModelMultiEditableObjectModelContext }

function TDataModelMultiEditableObjectModelContext.ConvertToData(const DataItem: CObject): CObject;
begin
  var drv: IDataRowView;
  if DataItem.TryAsType<IDataRowView>(drv) then
    Result := drv.Row.Data else
    Result := DataItem;
end;

procedure TDataModelMultiEditableObjectModelContext.DoContextChanged;
begin
  if _context <> nil then
  begin
    var dm := _owner.Context as IDataModel;
    var dr := dm.FindByKey(get_Context);
    if dr <> nil then // if not new
      dm.DefaultView.MakeRowVisible(dr);
  end;

  inherited;
end;

{$IFDEF DOTNET}
function TDataModelObjectModel.GetTypeEx: &Type;
begin
  Result := self.GetType;
end;
{$ENDIF}

end.
