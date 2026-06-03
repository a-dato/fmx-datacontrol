unit FMX.ScrollControl.Events;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.Classes,
  System.Generics.Defaults,
  FMX.Controls,
  System.ComponentModel,
  System.Types,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.Types,
  {$ENDIF}
  System_,
  System.Collections,
  ADato.ComponentModel,
  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.WithRows.Intf, System.Collections.Generic,
  FMX.ScrollControl.ControlClasses.Intf, FMX.Types, System.SysUtils;

type
  TDataControlEventRegistration = class
  public
    class procedure DoRegister;
  end;

  BasicEventArgs = class(EventArgs)
  protected
    _cell: IDCTreeCell;
    _requestValueForSorting: Boolean;

  public
    constructor Create(const ACell: IDCTreeCell); reintroduce;

    property RequestValueForSorting: Boolean read _RequestValueForSorting write _RequestValueForSorting;
  end;

  DCSelectionEvent = class(EventArgs)
  public
    EventTrigger: TSelectionEventTrigger;

    constructor Create(Trigger: TSelectionEventTrigger); reintroduce;
  end;

  DCCellSelectedEventArgs = class(BasicEventArgs)
  public
    EventTrigger: TSelectionEventTrigger;

    constructor Create(const ACell: IDCTreeCell; Trigger: TSelectionEventTrigger); reintroduce;
    property Cell: IDCTreeCell read _cell;
  end;

  DCCellEventArgs = class(BasicEventArgs)
  private
    _customRowHeight: Single;

  public
    constructor Create(const ACell: IDCTreeCell); reintroduce;

    property Cell: IDCTreeCell read _cell;
    property OverrideRowHeight: Single read _customRowHeight write _customRowHeight;

    // if multiple OverrideRowHeight are done in a row, the heighest is taken into account
  end;

  DCCellLoadEventArgs = class(DCCellEventArgs)
  private
    _showVertGrid: Boolean;
    _calculateRowCellAfterScrolling: Boolean;
    _performanceModeWhileScrolling: Boolean;

  public
    constructor Create(const ACell: IDCTreeCell; ShowVertGrid, APerformanceModeWhileScrolling: Boolean); reintroduce;

    function AssignCellStyleLookUp(const StyleLookUp: CString): TStyledControl;
    function AssignCellCustomInfoControl(const Control: IDCControl): IDCControl;

    property CalculateCellAfterScrolling: Boolean read _calculateRowCellAfterScrolling write _calculateRowCellAfterScrolling;
    property PerformanceModeWhileScrolling: Boolean read _performanceModeWhileScrolling write _performanceModeWhileScrolling;
  end;

  DCCellLoadingEventArgs = class(DCCellLoadEventArgs)
  public
    LoadDefaultData: Boolean;
    { LoadDefaulData = True: Tree shows default data (DataItem: CObject of this row) in a Cell.
      Tree calls CellFormatting event where user is able to set a custom text.
      LoadDefaulData = False: CellFormatting will not be triggered. }

    constructor Create(const ACell: IDCTreeCell; ShowVertGrid, APerformanceModeWhileScrolling: Boolean); reintroduce;
  end;

  DCCellLoadedEventArgs = DCCellLoadEventArgs;

  DCCellChangeEventArgs = class(BasicEventArgs)
  private
    _oldCell: IDCTreeCell;

  public
    function OldCell: IDCTreeCell;
    function NewCell: IDCTreeCell;

    constructor Create(const &Old, &New: IDCTreeCell); reintroduce;
  end;

  DCCellCanChangeEventArgs = DCCellChangeEventArgs;
  DCCellChangingEventArgs = DCCellChangeEventArgs;
  DCCellChangedEventArgs = DCCellChangeEventArgs;

  DCCellFormattingEventArgs = class(DCCellEventArgs)
  private
    _formatRowCellAfterScrolling: Boolean;
    _isSubProp: Boolean;
  public
    Value: CObject;
    FormattingApplied: Boolean;

   {  Related to CellFormatting event.
      True: Use e.Value 'as is' and put the text value in a cell
      False: Convert e.Value to a string calling: var text: string := e.Value.ToString(_Format, nil);}

    constructor Create(const ACell: IDCTreeCell; const AValue: CObject; const AIsSubProp: Boolean); reintroduce;
    property FormatCellAfterScrolling: Boolean read _formatRowCellAfterScrolling write _formatRowCellAfterScrolling;
    property IsSubProperty: Boolean read _isSubProp;
  end;

//  TCellUserEventType = (Mouse, Key);
//
//  DCCellItemUserActionEventArgs = class(DCCellEventArgs)
//  public
//    CellChanged: Boolean;
//    AllowCellEdit: Boolean;
//    UserEventType: TCellUserEventType;
//
//    constructor Create(const ACell: IDCTreeCell; const ACellChanged: Boolean; const AUserEventType: TCellUserEventType);
//  end;

  DCColumnComparerEventArgs = {$IFDEF DOTNET}public{$ENDIF} class(EventArgs)
  protected
    _SortDescription: IListSortDescription;
    _comparer: IComparer<CObject>;
//    _ReturnSortComparer: Boolean;

  public
    constructor Create(const SortDescription: IListSortDescription{; const ReturnSortComparer: Boolean});

    property SortDescription: IListSortDescription read _SortDescription;
    property Comparer: IComparer<CObject> read _comparer write _comparer;
//    property ReturnSortComparer: Boolean read _ReturnSortComparer;
  end;


  DCRowEventArgs = class(EventArgs)
  protected
    _row: IDCRow;

    _calculateRowCellAfterScrolling: Boolean;

  public
    constructor Create(const ARow: IDCRow); reintroduce;
    property Row: IDCRow read _row;

    property RealignAfterScrolling: Boolean read _calculateRowCellAfterScrolling write _calculateRowCellAfterScrolling;
  end;

  DCHoverRowEventArgs = class(DCRowEventArgs)
  protected
    _oldRow: IDCRow;

  public
    constructor Create(const ARow, AOldRow: IDCRow); reintroduce;
    property OldRow: IDCRow read _oldRow;
  end;

  DCRowEditEventArgs = class(DCRowEventArgs)
  protected
    _IsEdit: Boolean;

    function  get_IsNew: Boolean;

  public
    // Data item being editied. May ne replaced with dummy item while editing
    DataItem: CObject;
    Accept: Boolean;
    CancelRowEdit: Boolean;

    constructor Create(const ARow: IDCTreeRow; const DataItem: CObject; IsEdit: Boolean); reintroduce;

    property IsNew: Boolean read get_IsNew;
    property IsEdit: Boolean read _IsEdit;
  end;

  DCAddingNewEventArgs = class(EventArgs)
  public
    NewObject: CObject;
    AcceptIfNil: Boolean;
  end;

  DCDeletingEventArgs = class(EventArgs)
  public
    DataItem: CObject;
    Cancel: Boolean;

    constructor Create(const ADataItem: CObject); reintroduce;
  end;

  DCStartEditEventArgs = class(BasicEventArgs)
  protected
    function get_DataItem: CObject;
  public
    // Tells TreeView if editing is allowed
    AllowEditing  : Boolean;
    // Inidicates initial edit state
    Modified      : Boolean;
    // Holds a list of items to choose from when a DropDowenEditor is used
    PickList      : IList;
    MultiSelect   : Boolean;
    // Holds the value to edit
    Value         : CObject;
    DefaultValue  : CObject;
    MultilineEdit : Boolean;  // True - show Multiline editor
    UserCanClear  : Boolean;
    Editor        : IDCEditControl; // Custom user editor
    DataType      : &Type;
    MinEditorWidth: Single;

    constructor Create(const ACell: IDCTreeCell; const AValue: CObject); reintroduce;

    property Cell: IDCTreeCell read _cell;
    property DataItem: CObject read get_DataItem;
  end;


  DCEndEditEventArgs = class(BasicEventArgs)
  protected
    _EditItem: CObject;

  public
    Editor: TControl;
    Value: CObject;
    Accept: Boolean;
    EndRowEdit: Boolean;

    constructor Create( const ACell: IDCTreeCell;
                        const AValue: CObject;
                        const AEditor: TControl;
                        const AEditItem: CObject);

    property Cell: IDCTreeCell read _cell;
    property EditItem: CObject read _EditItem;
  end;


  DCCellParsingEventArgs = class(BasicEventArgs)
  public
    DataIsValid: Boolean;
    Value: CObject;
    IsCheckOnEndEdit: Boolean;

    constructor Create(const ACell: IDCTreeCell; const AValue: CObject; AIsCheckOnEndEdit: Boolean);

    property Cell: IDCTreeCell read  _Cell;
  end;

  DCCheckChangedEventArgs = class(DCCellEventArgs)
  public
    DoFollowCheckThroughChildren: Boolean;

    function CheckControl: TControl;
  end;

  ColumnChangedByUserEventArgs = class(EventArgs)
  protected
    _accept: Boolean;
    _column: IDCTreeColumn;
    _newWidth: Single;
    _newPosition: Integer;

  public
    constructor Create(const Column: IDCTreeColumn; NewWidth: Single; NewPosition: Integer = -1);

    property Accept: Boolean read _accept write _accept;
    property Column: IDCTreeColumn read _column;
    property NewWidth: Single read _newWidth; // write _newWidth;
    property NewPosition: Integer read _newPosition; // write _newPosition;
  end;

  DCTreePositionArgs = class(EventArgs)
  public
    TotalColumnWidth: Single;
    RowControl: TControl;

    constructor Create(const ATotalColumnWidth: Single; ARowControl: TControl);
    function GetMaxY(const LastRow: IDCRow; const ControlMaxY: Single): Single;
    function AllViewRowsVisible: Boolean;
    function GetRowsHeight: Single;
  end;

  DCExceptionEventArgs = class(EventArgs)
  public
    Exception: Exception;
    Handled: Boolean;

    constructor Create(const AException: Exception);
  end;

  CellLoadingEvent = procedure(const Sender: TObject; e: DCCellLoadingEventArgs) of object;
  CellLoadedEvent  = procedure(const Sender: TObject; e: DCCellLoadedEventArgs) of object;
  CellFormattingEvent  = procedure (const Sender: TObject; e: DCCellFormattingEventArgs) of object;

  CellCanChangeEvent = function(const Sender: TObject; e: DCCellCanChangeEventArgs): Boolean of object;
  CellChangingEvent = procedure(const Sender: TObject; e: DCCellChangingEventArgs) of object;
  CellChangedEvent = procedure(const Sender: TObject; e: DCCellChangedEventArgs) of object;

  CellSelectedEvent = procedure(const Sender: TObject; e: DCCellSelectedEventArgs) of object;
  SelectionChangedEvent = procedure(const Sender: TObject; e: DCSelectionEvent) of object;

  GetColumnComparerEvent  = procedure(const Sender: TObject; e: DCColumnComparerEventArgs) of object;
  TOnCompareRows = function (Sender: TObject; const Left, Right: CObject): integer of object;
  TOnCompareColumnCells = function(Sender: TObject; const TreeColumn: IDCTreeColumn; const Left, Right: CObject): integer of object;

  RowLoadedEvent  = procedure (const Sender: TObject; e: DCRowEventArgs) of object;
  RowHoverEvent = procedure (const Sender: TObject; e: DCHoverRowEventArgs) of object;
  RowEditEvent = procedure(const Sender: TObject; e: DCRowEditEventArgs) of object;
  StartEditEvent  = procedure(const Sender: TObject; e: DCStartEditEventArgs) of object;
  EndEditEvent  = procedure(const Sender: TObject; e: DCEndEditEventArgs) of object;
  CellParsingEvent = procedure(const Sender: TObject; e: DCCellParsingEventArgs) of object;
  CellCheckChangeEvent = procedure(const Sender: TObject; e: DCCheckChangedEventArgs) of object;

  ColumnChangedByUserEvent = procedure (const Sender: TObject; e: ColumnChangedByUserEventArgs) of object;
  ColumnChangingByUserEvent = ColumnChangedByUserEvent;

  TDragEnterRowsEvent = procedure(Sender: TObject; const SelectedRows: List<TRowDataItemInfo>; const Data: TDragObject; const Point: TPointF) of object;
  TDragOverRowsEvent = procedure(Sender: TObject; const SelectedRows: List<TRowDataItemInfo>; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation) of object;
  TDragDropRowsEvent = procedure(Sender: TObject; const SelectedRows: List<TRowDataItemInfo>; const Data: TDragObject; const Point: TPointF) of object;

  RowAddedEvent = procedure(const Sender: TObject; e: DCAddingNewEventArgs) of object;
  RowDeletingEvent = procedure(const Sender: TObject; e: DCDeletingEventArgs) of object;

  TreePositionedEvent = procedure(const Sender: TObject; e: DCTreePositionArgs) of object;

  OnExceptionEvent = procedure(const Sender: TObject; e: DCExceptionEventArgs) of object;

implementation

uses
  FMX.ScrollControl.WithRows.Impl;

class procedure TDataControlEventRegistration.DoRegister;
begin
  // this procedure makes this file included as required uses
end;

{ DCCellEventArgs }

constructor BasicEventArgs.Create(const ACell: IDCTreeCell);
begin
  inherited Create;
  _cell := ACell;
  _requestValueForSorting := False;
end;

{ DCCellChangingEventArgs }

constructor DCCellChangeEventArgs.Create(const &Old, &New: IDCTreeCell);
begin
  inherited Create(&New);
  _oldCell := &Old;
end;

function DCCellChangeEventArgs.NewCell: IDCTreeCell;
begin
  Result := _cell;
end;

function DCCellChangeEventArgs.OldCell: IDCTreeCell;
begin
  Result := _oldCell;
end;

{ DCCellEventArgs }

constructor DCCellEventArgs.Create(const ACell: IDCTreeCell);
begin
  inherited;
  _customRowHeight := -1;
end;

{ DCCellFormattingEventArgs }

constructor DCCellFormattingEventArgs.Create(const ACell: IDCTreeCell; const AValue: CObject; const AIsSubProp: Boolean);
begin
  inherited Create(ACell);
  Value := AValue;
  _isSubProp := AIsSubProp;
  _formatRowCellAfterScrolling := False;
end;

{ DCCellLoadingEventArgs }

constructor DCCellLoadingEventArgs.Create(const ACell: IDCTreeCell; ShowVertGrid, APerformanceModeWhileScrolling: Boolean);
begin
  inherited;
  LoadDefaultData := True;
end;

{ DCExceptionEventArgs }

constructor DCExceptionEventArgs.Create(const AException: Exception);
begin
  inherited Create;

  Exception := AException;
  Handled := False;
end;

{ DCColumnComparerEventArgs }

constructor DCColumnComparerEventArgs.Create(const SortDescription: IListSortDescription{; const ReturnSortComparer: Boolean});
begin
  inherited Create;
  _SortDescription := SortDescription;
//  _ReturnSortComparer := ReturnSortComparer;
end;

{ DCRowEditEventArgs }

constructor DCRowEditEventArgs.Create(const ARow: IDCTreeRow; const DataItem: CObject; IsEdit: Boolean);
begin
  inherited Create(ARow);

  Accept := True;
  _IsEdit := IsEdit;
  Self.DataItem := DataItem;
end;

function DCRowEditEventArgs.get_IsNew: Boolean;
begin
  Result := not _IsEdit;
end;

{ DCStartEditEventArgs }

constructor DCStartEditEventArgs.Create(const ACell: IDCTreeCell; const AValue: CObject);
begin
  inherited Create(ACell);
  Value := AValue;
  MinEditorWidth := 125;
  DataType := &Type.Unknown;
end;

function DCStartEditEventArgs.get_DataItem: CObject;
begin
  Result := _cell.Row.DataItem;
end;

{ DCEndEditEventArgs }

constructor DCEndEditEventArgs.Create(const ACell: IDCTreeCell; const AValue: CObject; const AEditor: TControl; const AEditItem: CObject);
begin
  inherited Create(ACell);

  Value := AValue;
  Editor := AEditor;

  _EditItem := AEditItem;
  Accept := True;
end;

{ DCCellParsingEventArgs }

constructor DCCellParsingEventArgs.Create(const ACell: IDCTreeCell; const AValue: CObject; AIsCheckOnEndEdit: Boolean);
begin
  inherited Create(ACell);

  Value := AValue;
  DataIsValid := True;
  IsCheckOnEndEdit := AIsCheckOnEndEdit;
end;

{ DCRowEventArgs }

constructor DCRowEventArgs.Create(const ARow: IDCRow);
begin
  inherited Create;
  _row := ARow;

  _calculateRowCellAfterScrolling := False;
end;

{ DCHoverRowEventArgs }

constructor DCHoverRowEventArgs.Create(const ARow, AOldRow: IDCRow);
begin
  inherited Create(ARow);
  _oldRow := AOldRow;
end;

{ DCCellLoadEventArgs }

function DCCellLoadEventArgs.AssignCellCustomInfoControl(const Control: IDCControl): IDCControl;
begin
  if Control = nil then
  begin
    if _cell.InfoControl <> nil then
      _cell.InfoControl.Visible := False;

    Exit(nil);
  end;

  _cell.LayoutColumn.CreateCellBase(_showVertGrid, _cell);
  _cell.Control.AddObject(Control.Control);
  _cell.InfoControl := Control;
  _cell.InfoControl.Visible := True;

  var h := _cell.InfoControl.Height + 2*_cell.Column.TreeControl.CellTopBottomPadding;
  if _cell.Control.Height < h then
    _cell.Control.Height := h;

  Result := _cell.InfoControl;
end;

function DCCellLoadEventArgs.AssignCellStyleLookUp(const StyleLookUp: CString): TStyledControl;
begin
  _cell.LayoutColumn.CreateCellStyleControl(StyleLookUp, _showVertGrid, _cell);
  Result := _cell.InfoControl.Control as TStyledControl;
end;

constructor DCCellLoadEventArgs.Create(const ACell: IDCTreeCell; ShowVertGrid, APerformanceModeWhileScrolling: Boolean);
begin
  inherited Create(ACell);
  _showVertGrid := ShowVertGrid;

  _calculateRowCellAfterScrolling := False;
  _performanceModeWhileScrolling := APerformanceModeWhileScrolling;
end;

{ DCSelectionEvent }

constructor DCSelectionEvent.Create(Trigger: TSelectionEventTrigger);
begin
  inherited Create;
  EventTrigger := Trigger;
end;

{ DCCellSelectedEventArgs }

constructor DCCellSelectedEventArgs.Create(const ACell: IDCTreeCell; Trigger: TSelectionEventTrigger);
begin
  inherited Create(ACell);
  EventTrigger := Trigger;
end;

{ ColumnChangedByUserEventArgs }

constructor ColumnChangedByUserEventArgs.Create(const Column: IDCTreeColumn; NewWidth: Single; NewPosition: Integer = -1);
begin
  inherited Create;

  _accept := True;
  _column := Column;
  _newWidth := NewWidth;
  _newPosition := NewPosition;
end;

//{ DCCellItemUserActionEventArgs }
//
//constructor DCCellItemUserActionEventArgs.Create(const ACell: IDCTreeCell; const ACellChanged: Boolean; const AUserEventType: TCellUserEventType);
//begin
//  inherited Create(ACell);
//
//  CellChanged := ACellChanged;
//  UserEventType := AUserEventType;
//end;

{ DCDeleteCancelEventArgs }
constructor DCDeletingEventArgs.Create(const ADataItem: CObject);
begin
  inherited Create;
  DataItem := ADataItem;
end;

{ DCCheckChangedEventArgs }

function DCCheckChangedEventArgs.CheckControl: TControl;
begin
  Result := _cell.InfoControl.Control;
end;

{ DCTreePositionArgs }

function DCTreePositionArgs.AllViewRowsVisible: Boolean;
begin
  var dc := RowControl as TScrollControlWithRows;
  Result := dc.View.ViewCount = dc.View.ActiveViewRows.Count;
end;

constructor DCTreePositionArgs.Create(const ATotalColumnWidth: Single; ARowControl: TControl);
begin
  inherited Create;
  TotalColumnWidth := ATotalColumnWidth;
  RowControl := ARowControl;
end;

function DCTreePositionArgs.GetMaxY(const LastRow: IDCRow; const ControlMaxY: Single): Single;
begin
  Result := CMath.Min(LastRow.Control.Position.Y + LastRow.Height, ControlMaxY);
end;

function DCTreePositionArgs.GetRowsHeight: Single;
begin
  var dc := RowControl as TScrollControlWithRows;

  Result := 0.0;
  var row: IDCRow;
  for row in dc.View.ActiveViewRows do
    Result := Result + row.Height;
end;

end.








