{$IFNDEF WEBASSEMBLY}
{$I Adato.inc}
{$ENDIF}

unit ADato.MultiObjectModelContextSupport.impl;

interface

uses
  System_,
  System.Collections,
  System.Collections.Generic,
  ADato.ObjectModel.impl,
  ADato.ObjectModel.intf,
  ADato.ObjectModel.List.impl,
  ADato.ObjectModel.List.intf,
  ADato.EditableObjectModelContext.impl,
  ADato.MultiObjectModelContextSupport.intf,
  ADato.Models.VirtualListItemDelegate,
  ADato.ObjectModel.TrackInterfaces,
  ADato.InsertPosition;

type
  TMultiEditableObjectModelContext = class(TEditableObjectModelContext, IMultiObjectContextSupport, ADato.ObjectModel.TrackInterfaces.IEditState)
  protected
    _contexts: Dictionary<CObject, IObjectModelContext>;
    _onListItemChanged: IListItemChanged;

    function  get_StoredContexts: Dictionary<CObject, IObjectModelContext>;
    procedure OnContextChanging(const Sender: IObjectListModel; const Context: IList);
    procedure OnContextChanged(const Sender: IObjectListModel; const Context: IList);

    function  ConvertToData(const DataItem: CObject): CObject; virtual;

  public
    constructor Create(const AModel: IObjectModel; const AOwner: IObjectListModel); reintroduce; overload;
    destructor Destroy; override;

    function  ProvideObjectModelContext(const DataItem: CObject; const ItemIsInControl: Boolean = False): IObjectModelContext;
    function  FindObjectModelContext(const DataItem: CObject): IObjectModelContext;
    procedure RemoveObjectModelContext(const DataItem: CObject);

    property StoredContexts: Dictionary<CObject, IObjectModelContext> read get_StoredContexts;
  end;

  TStorageObjectModelContext = class(TObjectModelContext, IStorageObjectModelContext)
  protected
    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF} _listObjectModelContext: IObjectModelContext;
    _itemIsInControlOfOtherModelContexts: Boolean;

    function  get_itemIsInControlOfOtherModelContexts: Boolean;
    procedure set_itemIsInControlOfOtherModelContexts(const Value: Boolean);
    function  get_listObjectModelContext: IObjectModelContext;

    procedure UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean); override;
    procedure UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean); override;
  public
    constructor Create(const ListObjectModelContext: IObjectModelContext; const ItemIsInControl: Boolean); reintroduce;

    property ItemIsInControlOfOtherModelContexts: Boolean read get_itemIsInControlOfOtherModelContexts write set_itemIsInControlOfOtherModelContexts;
  end;

  TOnListItemChanged = class(TVirtualListItemChanged)
  protected
    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF} _objectListModel: IObjectListModel;
    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF} _multiObjectContextSupport: IMultiObjectContextSupport;

    procedure BeginEdit(const Item: CObject); override;
    procedure CancelEdit(const Item: CObject); override;

    procedure UpdateStoredContext;

  public
    constructor Create(const ObjectListModel: IObjectListModel; const MultiObjectContextSupport: IMultiObjectContextSupport);
  end;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.ComponentModel
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.ComponentModel
  {$ENDIF}
  ;

{ TMultiEditableObjectModelContext }

function TMultiEditableObjectModelContext.ConvertToData(const DataItem: CObject): CObject;
begin
  Result := DataItem;
end;

constructor TMultiEditableObjectModelContext.Create(const AModel: IObjectModel; const AOwner: IObjectListModel);
begin
  inherited;

  _contexts := CDictionary<CObject, IObjectModelContext>.Create;

  var support: IOnItemChangedSupport;
  if interfaces.Supports<IOnItemChangedSupport>(_Owner, support) then
  begin
    _onListItemChanged := TOnListItemChanged.Create(_Owner, Self);
    support.OnItemChanged.Add(_onListItemChanged);
  end;

  {$IFNDEF WEBASSEMBLY}
  _Owner.OnContextChanging.Add(OnContextChanging);
  _Owner.OnContextChanged.Add(OnContextChanged);
  {$ELSE}
  _Owner.OnContextChanging += @OnContextChanging;
  _Owner.OnContextChanged += @OnContextChanged;
  {$ENDIF}
end;

destructor TMultiEditableObjectModelContext.Destroy;
begin
  if (_Owner <> nil) then
  begin
    {$IFNDEF WEBASSEMBLY}
    _Owner.OnContextChanging.Remove(OnContextChanging);
    _Owner.OnContextChanged.Remove(OnContextChanged);
    {$ELSE}
    _Owner.OnContextChanging -= @OnContextChanging;
    _Owner.OnContextChanged -= @OnContextChanged;
    {$ENDIF}

    var support: IOnItemChangedSupport;
    if interfaces.Supports<IOnItemChangedSupport>(_Owner, support) then
      support.OnItemChanged.Remove(_onListItemChanged);
  end;

  _onListItemChanged := nil;

  inherited;
end;

function TMultiEditableObjectModelContext.get_StoredContexts: Dictionary<CObject, IObjectModelContext>;
begin
  Result := _Contexts;
end;

procedure TMultiEditableObjectModelContext.OnContextChanged(const Sender: IObjectListModel; const Context: IList);
begin
  if Context = nil then
    Exit;

  var item: CObject;
  for item in Context do
    ProvideObjectModelContext(item);
end;

procedure TMultiEditableObjectModelContext.OnContextChanging(const Sender: IObjectListModel; const Context: IList);
begin
  if Sender.Context = nil then
    Exit;

  var omc: IObjectModelContext;
  for omc in _Contexts.Values do
    omc.Unbind;

  _Contexts.Clear;
end;

function TMultiEditableObjectModelContext.ProvideObjectModelContext(const DataItem: CObject; const ItemIsInControl: Boolean = False): IObjectModelContext;
begin
  var item := ConvertToData(DataItem);
  Result := FindObjectModelContext(item);

  if Result = nil then
  begin
    // keep object reference in memory, so we can search back for it and keep track of changes
    var omc := _Owner.ObjectModelContext;
    Result := TStorageObjectModelContext.Create(omc, ItemIsInControl);
    Result.Context := item;

    _Contexts.Add(item, Result);
  end
  else if Result.HasBindings then
    raise Exception.Create('ObjectmodelContext not cleared. Use "FindObjectModelContext" to get the assigned OMC with active bindings');
end;

function TMultiEditableObjectModelContext.FindObjectModelContext(const DataItem: CObject): IObjectModelContext;
begin
  Assert(DataItem <> nil, 'DataItem may not be nil');

  var item := ConvertToData(DataItem);
  if not _Contexts.TryGetValue(item, Result) then
    Exit(nil);

  // update dataitem, for "Stored Context" can be nil (if new), or contain "Old Version" of Object
  Result.Context := item;
end;

procedure TMultiEditableObjectModelContext.RemoveObjectModelContext(const DataItem: CObject);
var
  mdlContext: IObjectModelContext;
begin
  var item := ConvertToData(DataItem);
  if not _Contexts.TryGetValue(item, mdlContext) then
    Exit;

  _Contexts.Remove(item);
end;

{ TStorageObjectModelContext }

constructor TStorageObjectModelContext.Create(const ListObjectModelContext: IObjectModelContext; const ItemIsInControl: Boolean);
begin
  inherited Create(ListObjectModelContext.Model);
  _listObjectModelContext := ListObjectModelContext;
  _itemIsInControlOfOtherModelContexts := ItemIsInControl;
end;

function TStorageObjectModelContext.get_itemIsInControlOfOtherModelContexts: Boolean;
begin
  Result := _itemIsInControlOfOtherModelContexts;
end;

function TStorageObjectModelContext.get_listObjectModelContext: IObjectModelContext;
begin
  Result := _listObjectModelContext;
end;

procedure TStorageObjectModelContext.set_itemIsInControlOfOtherModelContexts(const Value: Boolean);
begin
  _itemIsInControlOfOtherModelContexts := Value;
end;

procedure TStorageObjectModelContext.UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean);
begin
  Assert(_itemIsInControlOfOtherModelContexts or CObject.Equals(_listObjectModelContext.Context, Self.get_Context));

  var multi: IMultiObjectContextSupport;
  if _itemIsInControlOfOtherModelContexts and interfaces.Supports<IMultiObjectContextSupport>(_listObjectModelContext, multi) then
  begin
    var ctxt: IObjectModelContext;
    for ctxt in multi.StoredContexts.Values do
    begin
      _listObjectModelContext.Context := ctxt.Context;
      try
        _listObjectModelContext.UpdateValueFromBoundProperty(ABinding, Value, ExecuteTriggers);
      finally
        (_listObjectModelContext as IEditableListObject).EndEdit;
      end;
    end;
  end
  else if not _itemIsInControlOfOtherModelContexts and (_listObjectModelContext.Context <> nil) then
    _listObjectModelContext.UpdateValueFromBoundProperty(ABinding, Value, ExecuteTriggers);

  inherited;
end;

procedure TStorageObjectModelContext.UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean);
begin
  Assert(not _itemIsInControlOfOtherModelContexts or CObject.Equals(_listObjectModelContext.Context, Self.get_Context));

  var isInternalUpdate := _UpdateCount > 0;

  if isInternalUpdate then
    (_listObjectModelContext as IUpdatableObject).BeginUpdate;
  try

  var multi: IMultiObjectContextSupport;
    if _itemIsInControlOfOtherModelContexts and interfaces.Supports<IMultiObjectContextSupport>(_listObjectModelContext, multi) then
  begin
    var ctxt: IObjectModelContext;
    for ctxt in multi.StoredContexts.Values do
    begin
      _listObjectModelContext.Context := ctxt.Context;
      try
        _listObjectModelContext.UpdateValueFromBoundProperty(APropertyName, Value, ExecuteTriggers);
      finally
        (_listObjectModelContext as IEditableListObject).EndEdit;
      end;
    end;
  end
  else if not _itemIsInControlOfOtherModelContexts and (_listObjectModelContext.Context <> nil) then
    _listObjectModelContext.UpdateValueFromBoundProperty(APropertyName, Value, ExecuteTriggers);

  finally
    if isInternalUpdate then
      (_listObjectModelContext as IUpdatableObject).EndUpdate;
  end;

  inherited;
end;

{ TOnListItemChanged }

constructor TOnListItemChanged.Create(const ObjectListModel: IObjectListModel; const MultiObjectContextSupport: IMultiObjectContextSupport);
begin
  _objectListModel := ObjectListModel;
  _multiObjectContextSupport := MultiObjectContextSupport;
end;

procedure TOnListItemChanged.BeginEdit(const Item: CObject);
begin
  UpdateStoredContext;
end;

procedure TOnListItemChanged.CancelEdit(const Item: CObject);
begin
  UpdateStoredContext;
end;

procedure TOnListItemChanged.UpdateStoredContext;
var
  ctxt: IObjectModelContext;
begin
  if not _multiObjectContextSupport.StoredContexts.TryGetValue(_objectListModel.ObjectContext, ctxt) then
    Exit;

  (ctxt as IUpdatableObject).BeginUpdate;
  try
    ctxt.Context := _objectListModel.ObjectContext; // overwrite with clone / original object
  finally
    (ctxt as IUpdatableObject).EndUpdate;
  end;
end;

end.


