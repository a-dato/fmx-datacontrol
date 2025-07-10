{$IFNDEF WEBASSEMBLY}
{$I Adato.inc}
{$ENDIF}

unit FMX.ScrollControl.DataControl.Binders;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Classes,
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Classes,
  {$ENDIF}
  System_,
  System.Collections,
  ADato.ObjectModel.Binders,
  FMX.ScrollControl.DataControl.Impl,
  FMX.ScrollControl.Events;

type
  TTreePropertyType = (DataList, CheckedItems);

  TDataControlBinding = class(TControlBinding<TDataControl>)
  private
    _orgRowEndEdit: FMX.ScrollControl.Events.RowEditEvent;
    _orgCellSelectedEvent: CellSelectedEvent;

    _propType: TTreePropertyType;

    _onDatalistRequired: TProc;
    _currentItem: CObject;

    procedure OnEditRowEnd(const Sender: TObject; e: DCRowEditEventArgs);
    procedure OnCellSelectedEvent(const Sender: TObject; e: DCCellSelectedEventArgs);

    procedure InternalSetValue(const Value: CObject);

    function GetDataAsList: IList;
    function ConvertToDataItem(const Item: CObject): CObject;

  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TDataControl; TreeBindingPropType: TTreePropertyType = TTreePropertyType.CheckedItems); reintroduce; overload;
    constructor Create(AControl: TDataControl; const OnDatalistRequired: TProc); reintroduce; overload;
    destructor Destroy; override;
  end;

implementation

uses
  ADato.Data.DataModel.intf;


{ TDATACONTROL}

constructor TDataControlBinding.Create(AControl: TDataControl; const OnDatalistRequired: TProc);
begin
  Create(AControl, TTreePropertyType.CheckedItems);
  _onDatalistRequired := OnDatalistRequired;
end;

constructor TDataControlBinding.Create(AControl: TDataControl; TreeBindingPropType: TTreePropertyType = TTreePropertyType.CheckedItems);
begin
  inherited Create(AControl);

  _propType := TreeBindingPropType;

  {$IFDEF DELPHI}
  case _propType of
    DataList: begin
      _orgRowEndEdit := _Control.EditRowEnd;
      _Control.EditRowEnd := OnEditRowEnd;
    end;
    CheckedItems: begin
      _orgCellSelectedEvent :=   _Control.CellSelected;
      _Control.CellSelected := OnCellSelectedEvent;
    end;
  end;
  {$ENDIF}
end;

destructor TDataControlBinding.Destroy;
begin
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
  begin
    case _propType of
      DataList: _Control.EditRowEnd := _orgRowEndEdit;
      CheckedItems: _Control.CellSelected := _orgCellSelectedEvent;
    end;
  end;

  inherited;
end;

function TDataControlBinding.GetDataAsList: IList;
begin
  if Assigned(_onDatalistRequired) then
    _onDatalistRequired();

  if (_control.DataList <> nil) and (_control.View <> nil) then
    Result := _control.View.GetViewList else
    Result := nil;
end;

function TDataControlBinding.GetValue: CObject;
begin
  var data := GetDataAsList;
  case _propType of
    DataList: begin
      Result := data;
    end;

    CheckedItems:
    begin
      if data.Count = 0 then
        Exit(nil);

      if _Control.SelectionCount > 1 then
        Result := _Control.SelectedItems
      else // Radio buttons
      begin
//        var selected: CObject := ;

        _currentItem := ConvertToDataItem(_Control.DataItem);

//        if selected = nil then
//          Exit(nil);

//        if (_currentItem = nil) and (checked.Count = 0) then
//        begin
//          Exit(nil);
////          _currentItem := ConvertToDataItem(data[0]);
//        end;
//
//        if checked.Count = 0 then
//          _Control.SelectItem(_currentItem) else

        Exit(_currentItem);
      end;
    end;
  end;
end;

procedure TDataControlBinding.OnCellSelectedEvent(const Sender: TObject; e: DCCellSelectedEventArgs);
begin
  if not e.EventTrigger.IsUserEvent then
    Exit;

  if Assigned(_orgCellSelectedEvent) then
    _orgCellSelectedEvent(Sender, e);

  TThread.ForceQueue(nil, procedure
  begin
    NotifyModel(nil);
  end);
end;

//procedure TDataControlBinding.OnCellItemClicked(const Sender: TObject; e: CellItemClickedEventArgs);
//begin
//  if Assigned(_orgCellItemClicked) then
//    _orgCellItemClicked(Sender, e);
//
//  TThread.ForceQueue(nil, procedure
//  begin
//    NotifyModel(nil);
//  end);
//end;

procedure TDataControlBinding.OnEditRowEnd(const Sender: TObject; e: DCRowEditEventArgs);
begin
  if Assigned(_orgRowEndEdit) then
    _orgRowEndEdit(Sender, e);

  TThread.ForceQueue(nil, procedure
  begin
    NotifyModel(nil);
  end);
end;

procedure TDataControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  case _propType of
    DataList: _control.DataList := Value.AsType<IList>;
    CheckedItems: InternalSetValue(Value);
  end;
end;

function TDataControlBinding.ConvertToDataItem(const Item: CObject): CObject;
var
  drv: IDataRowView;
begin
  if Item.TryAsType<IDataRowView>(drv) then
  begin
    if drv.Row.Level <> 0 then
      Result := drv.Row.Data else
      Result := nil;
  end else
    Result := Item;
end;

procedure TDataControlBinding.InternalSetValue(const Value: CObject);
var
  l: IList;

begin
  var data := GetDataAsList;
  if data = nil then
  begin
//    if Value <> nil then
//      raise Exception.Create('Datalist not set');
    Exit;
  end;

  BeginUpdate;
  try
    if Value = nil then
    begin
      _control.ClearSelections;

      if _control.GetDataModelView <> nil then
        _control.GetDataModelView.CurrencyManager.Current := -1;

      Exit;
    end;

    if not Value.TryAsType<IList>(l) then
    begin
      l := CArrayList.Create;
      l.Add(Value);
    end else
      l := Value.AsType<IList>;

    _control.ClearSelections;
    //var item: CObject;
    for var item in data do
    begin
      var cvItem := ConvertToDataItem(item);
      if cvItem = nil then Continue;  // level 1 row

      if (l <> nil) and (l.IndexOf(cvItem) <> -1) then
      begin
        _control.SelectItem(cvItem);
        _currentItem := item;
      end;
    end;
  finally
    EndUpdate;
  end;
end;

end.


