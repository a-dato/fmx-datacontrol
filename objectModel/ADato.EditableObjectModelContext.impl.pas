unit ADato.EditableObjectModelContext.impl;

interface

uses
  System_,
  System.Collections,
  System.Collections.Generic,

  ADato.ObjectModel.impl,
  ADato.ObjectModel.intf,
  ADato.ObjectModel.List.impl,
  ADato.ObjectModel.List.intf,
  ADato.Models.VirtualListItemDelegate,
  ADato.ObjectModel.TrackInterfaces,
  ADato.InsertPosition;

type
  TEditableObjectModelContext = class(TObjectModelContext, IEditableListObject, IEditState)
  {$IFDEF DELPHI}protected{$ELSE}public{$ENDIF}
    _IsChanged: Boolean;
    _IsNew: Boolean;
    _Index: Integer;
    _Position: InsertPosition;
    _SavedContext: CObject;
    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF}_Owner: IObjectListModel;

    function  get_IsChanged: Boolean;
    function  get_IsEdit: Boolean;
    function  get_IsNew: Boolean;
    function  get_IsEditOrNew: Boolean;

    procedure AddNew(const item: CObject; Index: Integer; Position: InsertPosition);
    procedure BeginEdit(Index: Integer);
    procedure CancelEdit;
    procedure EndEdit;
    procedure StartChange;

    procedure DoContextChanging; override;
    procedure UpdatePropertyBindingValues; override;
    procedure UpdatePropertyBindingValues(const APropertyName: CString); override;
    procedure UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean); override;
    procedure UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean); override;

  public
    constructor Create(const AModel: IObjectModel; const AOwner: IObjectListModel); reintroduce; overload;
//    constructor Create(const Other: IObjectModelContext; const AOwner: IObjectListModelChangeTracking); overload;
  end;

implementation

uses
  {$IFDEF DELPHI}
  System.SysUtils,
  {$ENDIF}
  System.ComponentModel;

{ TEditableObjectModelContext }

constructor TEditableObjectModelContext.Create(const AModel: IObjectModel; const AOwner: IObjectListModel);
begin
  inherited Create(AModel);
  _Owner := AOwner;
end;

procedure TEditableObjectModelContext.AddNew(const Item: CObject; Index: Integer; Position: InsertPosition);
begin
  // Added by JvA 25-11-2021
  if get_IsEditOrNew then
    EndEdit;

  _IsChanged := False;
  _IsNew := True;
  _Index := Index;

  inherited set_Context(item);

  var notify: INotifyListItemChanged;
  if interfaces.Supports<INotifyListItemChanged>(_Owner, notify) then
    notify.NotifyAddingNew(Self, {var} _Index, Position);

  var cln: ICloneable;
  if _Context.TryGetValue<ICloneable>(cln) then
    _SavedContext := cln.Clone else
    _SavedContext := Item;
end;

procedure TEditableObjectModelContext.BeginEdit(Index: Integer);
var
  eo: IEditableObject;
  cln: ICloneable;
begin
  _IsChanged := False;
  _IsNew := False;
  _Index := Index;

  _SavedContext := _Context;

  if _Context.TryGetValue<ICloneable>(cln) then
  begin
    BeginUpdate;
    try
      set_Context(cln.Clone);
    finally
      EndUpdate;
    end;
  end;

  if _Context.TryGetValue<IEditableObject>(eo) then
    eo.BeginEdit;

  var notify: INotifyListItemChanged;
  if interfaces.Supports<INotifyListItemChanged>(_Owner, notify) then
    notify.NotifyBeginEdit(Self);
end;

procedure TEditableObjectModelContext.CancelEdit;
var
  eo: IEditableObject;
begin
  if get_IsEditOrNew then
  begin
    if _Context.TryGetValue<IEditableObject>(eo) then
      eo.CancelEdit;

    var notify: INotifyListItemChanged;
    if (_UpdateCount = 0) and interfaces.Supports<INotifyListItemChanged>(_Owner, notify) then
      notify.NotifyCancelEdit(Self, _SavedContext);

    // in case of clone, set old item back
    BeginUpdate;
    try
      inherited set_Context(_SavedContext);
    finally
      EndUpdate;
    end;

    _SavedContext := nil;
    _IsChanged := False;
  end;
end;

procedure TEditableObjectModelContext.EndEdit;
var
  eo: IEditableObject;
begin
  if get_IsEditOrNew then
  begin
    if _Context.TryGetValue<IEditableObject>(eo) then
      eo.EndEdit;

    var notify: INotifyListItemChanged;
    if (_UpdateCount = 0) and interfaces.Supports<INotifyListItemChanged>(_Owner, notify) then
      notify.NotifyEndEdit(Self, _SavedContext, _Index, _Position);

    _SavedContext := nil;
    _IsChanged := False;
  end;
end;

function TEditableObjectModelContext.get_IsChanged: Boolean;
begin
  Result := _IsChanged;
end;

function TEditableObjectModelContext.get_IsEdit: Boolean;
begin
  Result := (_savedContext <> nil) and not _IsNew;
end;

function TEditableObjectModelContext.get_IsNew: Boolean;
begin
  Result := (_savedContext <> nil) and _IsNew;
end;

function TEditableObjectModelContext.get_IsEditOrNew: Boolean;
begin
  Result := get_IsEdit or get_IsNew;
end;

procedure TEditableObjectModelContext.DoContextChanging;
begin
  inherited;
  if (_UpdateCount = 0) then
    EndEdit;
end;

procedure TEditableObjectModelContext.UpdatePropertyBindingValues;
begin
  // do not execute by creating a clone in BeginEdit
  if (_updateCount = 0) or _IsChanged then
    inherited;
end;

procedure TEditableObjectModelContext.UpdatePropertyBindingValues(const APropertyName: CString);
begin
  // do not execute by creating a clone in BeginEdit
  if (_updateCount = 0) or _IsChanged then
    inherited;
end;

procedure TEditableObjectModelContext.UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean);
begin
  if (_updateCount = 0) then
    StartChange;
  inherited;
end;

procedure TEditableObjectModelContext.UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean);
begin
  if (_updateCount = 0) then
    StartChange;
  inherited;
end;

procedure TEditableObjectModelContext.StartChange;
begin
  if not get_IsEditOrNew then
    BeginEdit(-1);

  _IsChanged := True;
end;

end.


