unit FMX.ScrollControl.WithEditableCells.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls, 
  System.Classes, 
  FMX.Types,
  System.UITypes,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.Classes,
  Wasm.FMX.Types,
  Wasm.System.UITypes,
  {$ENDIF}
  System_,
  ADato.ComponentModel,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.WithEditableCells.Intf,
  ADato.ObjectModel.TrackInterfaces,
  ADato.ObjectModel.List.intf,
  System.ComponentModel,
  ADato.InsertPosition,
  FMX.ScrollControl.WithCells.Intf,
  System.Collections,
  System.Collections.Generic,
  FMX.ScrollControl.WithRows.Intf,
  FMX.ScrollControl.Events, ADato.Data.DataModel.intf,
  FMX.ScrollControl.ControlClasses.Intf;

type
  TScrollControlWithEditableCells = class(TScrollControlWithCells, IDataControlEditorHandler)
  protected
    _modelListItemChanged: IListItemChanged;
    procedure set_Model(const Value: IObjectListModel); override;

  public
    _editingInfo: ITreeEditingInfo;
    _cellEditor: IDCCellEditor;

    _checkedItems: Dictionary<IDCTreeColumn, List<Integer>>;

    procedure GenerateView; override;

    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single); override;

    procedure ResetView(const FromViewListIndex: Integer = -1; ClearOneRowOnly: Boolean = False); override;
    procedure InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False); override;

    function  CanRealignContent: Boolean; override;
    function  CanEditCell(const Cell: IDCTreeCell): Boolean;

    procedure ShowEditor(const Cell: IDCTreeCell; const StartEditArgs: DCStartEditEventArgs; const UserValue: CString);
    procedure HideEditor;

    function  TryAddRow(const Position: InsertPosition): Boolean;
    function  TryDeleteSelectedRows: Boolean;
    function  CheckCanChangeRow: Boolean;

  // editor behaviour
  protected
//    _tempCachedEditingColumnCustomWidth: Single;
//    procedure UpdateMinColumnWidthOnShowEditor(const Cell: IDCTreeCell; const MinColumnWidth: Single);
    procedure ResetColumnWidthOnHideEditor(const Column: IDCTreeColumn);

  // checkbox behaviour
  protected
//    _checkBoxUpdateCount: Integer;
    procedure LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const IsSubProp: Boolean); override;
    function  ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject; override;

    procedure OnNonPropertyCheckBoxChange(Sender: TObject);

    procedure UpdateColumnCheck(const DataIndex: Integer; const Column: IDCTreeColumn; IsChecked: Boolean); overload;
    procedure DoCellCheckChangedByUser(const Cell: IDCTreeCell); overload;
    procedure OnHeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure OnViewChanged(Sender: TObject; e: EventArgs); override;

    procedure HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions); override;
    procedure DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean); override;

  public
    function  ItemCheckedInColumn(const Item: CObject; const Column: IDCTreeColumn): Boolean;
    function  CheckedItemsInColumn(const Column: IDCTreeColumn): List<CObject>;

    procedure ClearCheckboxCache(const Column: IDCTreeColumn = nil);

    procedure UpdateColumnCheck(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean); overload;
    procedure DoCellCheckChangedByUser(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean); overload;

  private
    procedure SetCellData(const Cell: IDCTreeCell; const Data: CObject);

  // events
  protected
    _copyToClipboard: TNotifyEvent;
    _pasteFromClipboard: TNotifyEvent;

    _editRowStart: RowEditEvent;
    _editRowEnd: RowEditEvent;
    _editCellStart: StartEditEvent;
    _editCellEnd: EndEditEvent;
    _cellParsing: CellParsingEvent;
    _cellCheckChanged: CellCheckChangeEvent;

    _rowAdding: RowAddedEvent;
    _rowDeleting: RowDeletingEvent;
    _rowDeleted: TNotifyEvent;

    // IDataControlEditorHandler
    procedure OnEditorKeyDown(const CellEditor: IDCCellEditor; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure OnEditorExit;

    function  LoadDefaultPickListForCell(const Cell: IDCTreeCell; const CellValue: CObject) : IList;
    function  StartEditCell(const Cell: IDCTreeCell; CallShowEditor: Boolean; const UserValue: CString) : Boolean;
    function  EndEditCell(out ChangeUpdatedSort: Boolean): Boolean;
    procedure SafeForcedEndEdit;

    function  DoEditRowStart(const ARow: IDCTreeRow; var DataItem: CObject; IsNew: Boolean) : Boolean;
    function  DoEditRowEnd(const ARow: IDCTreeRow; out ChangeUpdatedSort: Boolean): Boolean;
    function  DoCellParsing(const Cell: IDCTreeCell; IsCheckOnEndEdit: Boolean; var AValue: CObject): Boolean;

    function  DoAddingNew(out NewObject: CObject) : Boolean;
    function  DoUserDeletingRow(const Item: CObject) : Boolean;
    procedure DoUserDeletedRow;

    procedure AfterCancelEdit(const PrevCell: IDCTreeCell; WasNew: Boolean);

    function  DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean; override;
    procedure FollowCheckThroughChildren(const Cell: IDCTreeCell);
    procedure TryCheckParentIfAllSelected(const ParentDrv: IDataRowView; const ColumnCheckedItems: List<Integer>);

  public
    procedure EndEditFromExternal;
    procedure CancelEditFromExternal;

    procedure CancelEdit(CellOnly: Boolean = False); // canceling is difficult to only do the cell
    function  EditActiveCell(SetFocus: Boolean; const UserValue: CString): Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  BeginEdit: Boolean;
    function  EndEdit: Boolean;
    function  IsEdit: Boolean;
    function  IsNew: Boolean;
    function  IsEditOrNew: Boolean;

    function  CopyToClipBoard: Boolean; virtual;
    function  PasteFromClipBoard: Boolean; virtual;
    function  TrySelectCheckBoxes: Boolean; virtual;

    property EditingInfo: ITreeEditingInfo read _editingInfo;
    property CellEditor: IDCCellEditor read _cellEditor;

  public
    // designer properties & events
    property EditRowStart: RowEditEvent read _editRowStart write _editRowStart;
    property EditRowEnd: RowEditEvent read _editRowEnd write _editRowEnd;
    property EditCellStart: StartEditEvent read _editCellStart write _editCellStart;
    property EditCellEnd: EndEditEvent read _editCellEnd write _editCellEnd;
    property CellParsing: CellParsingEvent read _cellParsing write _cellParsing;
    property CellCheckChanged: CellCheckChangeEvent read _cellCheckChanged write _cellCheckChanged;

    property OnCopyToClipBoard: TNotifyEvent read _copyToClipBoard write _copyToClipBoard;
    property OnPasteFromClipBoard: TNotifyEvent read _pasteFromClipBoard write _pasteFromClipBoard;

    property RowAdding: RowAddedEvent read _rowAdding write _rowAdding;
    property RowDeleting: RowDeletingEvent read _rowDeleting write _rowDeleting;
    property RowDeleted: TNotifyEvent read _rowDeleted write _rowDeleted;
  end;

  TTreeEditingInfo = class(TInterfacedObject, ITreeEditingInfo)
  private
    _dataIndex: Integer;
    _flatColumnIndex: Integer;

    _editItem: CObject;
    _isNew: Boolean;
    _endEditCellCount: Integer;

    procedure BeginEndEditCell;
    procedure EndEndEditCell;
    function  InsideEndEditCell: Boolean;

    function  get_EditItem: CObject;
    procedure set_EditItem(const Value: CObject);
    function  get_EditItemDataIndex: Integer;

  public
    constructor Create;

    function  RowIsEditing: Boolean;
    function  CellIsEditing: Boolean;

    function  IsNew: Boolean;

    procedure StartRowEdit(DataIndex: Integer; const EditItem: CObject; IsNew: Boolean);
    procedure StartCellEdit(DataIndex, FlatColumnIndex: Integer);

    procedure CellEditingFinished;
    procedure RowEditingFinished;
  end;

  TDCCellEditor = class(TInterfacedObject, IDCCellEditor)
  protected
    _editorHandler: IDataControlEditorHandler;

    _cell: IDCTreeCell;
    _editor: IDCEditControl;

    _originalValue: CObject;
    _originalValueSet: Boolean;

    function  get_Cell: IDCTreeCell;
    function  get_ContainsFocus: Boolean;
    function  get_Modified: Boolean;
    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_Value: CObject; virtual;
    procedure set_Value(const Value: CObject); virtual;
    function  get_OriginalValue: CObject;
    function  get_PickList: IList; virtual;
    procedure set_PickList(const Value: IList); virtual;
    function  get_Editor: TControl;
    function  get_IsMultiLine: Boolean; virtual;
    function  get_UserCanClear: Boolean;
    procedure set_UserCanClear(const Value: Boolean);

    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean); virtual;
    procedure EndEdit; virtual;

    function  FormatItem(const Item: CObject) : CString;

    procedure SetCustomValue(const EditValue: CObject);

    procedure OnEditorExit(Sender: TObject); virtual;
    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); //virtual;

    function TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean; virtual;

  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); reintroduce; virtual;
    destructor Destroy; override;
  end;

  TDCCustomCellEditor = class(TDCCellEditor)
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell; const Editor: IDCEditControl); reintroduce;
  end;

  TDCCheckBoxCellEditor = class(TDCCellEditor)
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;
    function  TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean; override;
  end;

  TDCTextCellEditor = class(TDCCellEditor)
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;
    function  TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean; override;
  end;

  TDCTextCellMultilineEditor = class(TDCCellEditor)
  protected
    function  get_IsMultiLine: Boolean; override;
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;
    function  TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean; override;
  end;

  TDCCellDateTimeEditor = class(TDCCellEditor)
  protected
//    procedure OnDateTimeEditorOpen(Sender: TObject);
//    procedure OnDateTimeEditorChange(Sender: TObject);

    procedure Dropdown;
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;
  end;

  TDCCellDropDownEditor = class(TDCCellEditor)
  protected
    function  TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean; override;
    procedure Dropdown;

  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;
  end;

  TDCCellMultiSelectDropDownEditor = class(TDCCellEditor)
  private
    _saveData: Boolean;
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;
    function  get_PickList: IList; override;
    procedure set_PickList(const Value: IList); override;

    procedure OnEditorExit(Sender: TObject); override;

    procedure Dropdown;
    procedure DropDownClosed;

  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); override;
    procedure BeginEdit(const EditValue: CObject; SelectAll: Boolean = True); override;

    property SaveData: Boolean read _saveData write _saveData;
  end;

  TObjectListModelItemChangedDelegate = class(TBaseInterfacedObject, IListItemChanged, IUpdatableObject)
  protected
    _Owner: TScrollControlWithEditableCells;
    _UpdateCount: Integer;

    procedure AddingNew(const Value: CObject; var Index: Integer; Position: InsertPosition);
    procedure Added(const Value: CObject; const Index: Integer);
    procedure Removed(const Value: CObject; const Index: Integer);
    procedure BeginEdit(const Item: CObject);
    procedure CancelEdit(const Item: CObject);
    procedure EndEdit(const Item: CObject);

    procedure SetItemInCurrentView(const DataItem: CObject);

  public
    constructor Create(const AOwner: TScrollControlWithEditableCells);

    procedure BeginUpdate;
    procedure EndUpdate;
  end;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Edit, 
  FMX.DateTimeCtrls, 
  FMX.ComboEdit,
  System.Math, 
  FMX.Memo,
  FMX.StdCtrls, 
  FMX.Graphics, 
  FMX.ActnList,
  System.Types,
  System.Character,
  FMX.Platform,
  System.SysUtils,
  System.TypInfo,
  ADato.FMX.ComboMultiBox,
  {$ELSE}
  Wasm.FMX.Edit,
  Wasm.FMX.DateTimeCtrls,
  Wasm.FMX.ComboEdit,
  Wasm.System.Math,
  Wasm.FMX.Memo,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Graphics,
  Wasm.FMX.ActnList,
  Wasm.System.UITypes,
  Wasm.System.Types,
  Wasm.FMX.Platform,
  Wasm.System.SysUtils,
  {$ENDIF}
  FMX.ControlCalculations,
  ADato.Collections.Specialized,
  System.Reflection, FMX.Text, FMX.ScrollControl.ControlClasses;

{ TScrollControlWithEditableCells }

constructor TScrollControlWithEditableCells.Create(AOwner: TComponent);
begin
  inherited;
  _editingInfo := TTreeEditingInfo.Create;
//  _tempCachedEditingColumnCustomWidth := -1;
end;

function TScrollControlWithEditableCells.CheckedItemsInColumn(const Column: IDCTreeColumn): List<CObject>;
begin
  var checkedItems: List<Integer>;
  if not _checkedItems.TryGetValue(Column, checkedItems) or (checkedItems = nil) then
    Exit(nil);

  var orgData := _view.OriginalData;

  Result := CList<CObject>.Create(checkedItems.Count);
  var dataIndex: Integer;
  for dataIndex in checkedItems do
    Result.Add(orgData[dataIndex]);
end;

procedure TScrollControlWithEditableCells.ClearCheckboxCache(const Column: IDCTreeColumn = nil);
begin
  if _checkedItems = nil then
    Exit;

  if Column = nil then
    _checkedItems.Clear
  else if _checkedItems.ContainsKey(Column) then
    _checkedItems.Remove(Column);
end;

function TScrollControlWithEditableCells.CanRealignContent: Boolean;
begin
  Result := inherited and not _editingInfo.CellIsEditing;
end;

function TScrollControlWithEditableCells.CheckCanChangeRow: Boolean;
begin
  // old row can be scrolled out of view. So always work with dummy rows

  var dummyOldRow := ProvideRowForChanging(_selectionInfo) as IDCTreeRow;
  if dummyOldRow = nil then Exit(True);

  var oldCell := dummyOldRow.Cells[_selectionInfo.Tag];
  Result := DoCellCanChange(oldCell, nil);
end;

procedure TScrollControlWithEditableCells.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

  function KeysImplyToAddRow: Boolean;
  begin
    Result := False;
    if not (TDCTreeOption.AllowAddNewRows in _options) then
      Exit(False);

    if (Key = vkInsert) then
      Exit(True);

    if (Key = vkDown) and not (ssCtrl in Shift) and not (ssShift in Shift) and (_view <> nil) and (Self.Current = _view.ViewCount - 1) and (TDCTreeOption.AllowAddNewRowsWithDownKey in _options) then
      Exit(True);
  end;

begin
  if ssCtrl in Shift then
  begin
    if (Key = vkC) and CopyToClipboard then
      Key := 0;

    if (Key = vkV) and PasteFromClipboard then
      Key := 0;

    if (Key = vkSpace) and TrySelectCheckBoxes then
      Key := 0;

    if Key = 0 then
      Exit;
  end;

  // check cell edit
  if (Key in [vkF2, vkReturn]) and CanEditCell(GetActiveCell) then
  begin
    if not _editingInfo.CellIsEditing then
      StartEditCell(GetActiveCell, True, nil {keep cell data value})
    else if Key = vkReturn then
    begin
      var changeUpdatedSort: Boolean;
      EndEditCell({out} changeUpdatedSort);
    end;

    Key := 0;
  end

  // check enter
  else if (Key = vkReturn) then
  begin
    if Assigned(OnDblClick) then
      OnDblClick(Self)
    else
      DoCellSelected(GetActiveCell, TSelectionEventTrigger.Key);

    Key := 0;
  end

  // check cancel edit
  else if (Key = vkEscape) then
  begin
    if IsEditOrNew then
    begin
      CancelEdit;
      Key := 0;
    end;
  end

  // check insert new row
  else if KeysImplyToAddRow then
  begin
    if CheckCanChangeRow and ((not CanRealignScrollCheck) or TryAddRow(InsertPosition.After)) then
      Key := 0;
  end

  // check delete edit
  else if (Key = vkDelete) and (ssCtrl in Shift) and (TDCTreeOption.AllowDeleteRows in _options) then
  begin
    if CheckCanChangeRow and ((not CanRealignScrollCheck) or TryDeleteSelectedRows) then
      Key := 0;
  end

  // check delete cell content
  else if ((Key = vkDelete) or (Key = vkBack)) and CanEditCell(GetActiveCell) then
  begin
    StartEditCell(GetActiveCell, True, '' {clear cell});
    Key := 0;
  end

  else
  begin
    var cell := GetActiveCell;

    // checkbox select with space key
    if (Key = 0) and KeyChar.IsWhiteSpace and (cell <> nil) and (cell.Column.IsSelectionColumn or (not CanEditCell(cell) and (SelectionCheckBoxColumn <> nil))) then
    begin
      if _selectionInfo.IsSelected(cell.Row.DataIndex) then
        _selectionInfo.RemoveFromSelection(cell.Row.DataIndex) else
        _selectionInfo.AddToSelection(cell.Row.DataIndex, cell.Row.ViewListIndex, cell.Row.DataItem);

      KeyChar := #0;
      Exit;
    end;

    // else inherited
    if ssAlt in Shift then
      Exit;

    if Key <> 0 then
    begin
      var isRowChange := (Key in [vkUp, vkDown, vkPrior, vkEnd, vkTab]);
      if not isRowChange and (ssCtrl in Shift) and (Key in [vkHome, vkEnd]) then
        isRowChange := True;

      if isRowChange and IsEditOrNew then
      begin
        var pt := _paintTime;
        if not CheckCanChangeRow then
          Exit;

        _paintTime := pt;
      end;

      inherited;

      if Key = 0 then
        Exit;
    end;

    {$IFNDEF WEBASSEMBLY}
    if (Key = 0) and KeyChar.IsDefined then
    begin
      if CanEditCell(GetActiveCell) then
      begin
        StartEditCell(GetActiveCell, True, KeyChar);
        KeyChar := #0;
      end
      else
        TryScrollToCellByKey(Key, KeyChar);
    end;
    {$ELSE}
    if WideChar.IsLetterOrDigit(KeyChar) then
    begin
      if CanEditCell(GetActiveCell) then
      begin
        StartEditCell(GetActiveCell, KeyChar);
        KeyChar := #0;
      end
      else
        TryScrollToCellByKey(Key, KeyChar);
    end;
    {$ENDIF}
  end;
end;

procedure TScrollControlWithEditableCells.LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const IsSubProp: Boolean);
begin
  inc(_updateCount);
  try
    inherited;

    var isCheckBox :=
      (not IsSubProp and (Cell.Column.InfoControlClass = TInfoControlClass.CheckBox)) or
      (IsSubProp and (Cell.Column.SubInfoControlClass = TInfoControlClass.CheckBox));

    if isCheckBox and not Cell.Column.IsSelectionColumn then
    begin
      var ctrl := Cell.InfoControl;
      var chkCtrl := (ctrl as IISChecked);

      if _localCheckSetInDefaultData {Cell.Column.HasPropertyAttached} then
        UpdateColumnCheck(cell.Row.DataIndex, Cell.Column, chkCtrl.IsChecked);

      ctrl.Tag := Cell.Row.ViewListIndex;

      {$IFNDEF WEBASSEMBLY}
      var cb: ICheckBoxControl;
      var rb: IRadioButtonControl;
      if Interfaces.Supports<ICheckBoxControl>(ctrl, cb) then
        cb.OnChange := OnNonPropertyCheckBoxChange
      else if Interfaces.Supports<IRadioButtonControl>(ctrl, rb) then
        rb.OnChange := OnNonPropertyCheckBoxChange;
      {$ELSE}
      if ctrl is TCheckBox then
        (ctrl as TCheckBox).OnChange := @OnNonPropertyCheckBoxChange else
        (ctrl as TRadioButton).OnChange := @OnNonPropertyCheckBoxChange;
      {$ENDIF}

      chkCtrl.IsChecked := _checkedItems.ContainsKey(Cell.Column) and _checkedItems[Cell.Column].Contains(cell.Row.DataIndex);
    end;

  finally
    dec(_updateCount);
  end;
end;

procedure TScrollControlWithEditableCells.DoCellCheckChangedByUser(const Cell: IDCTreeCell);
begin
  if Cell = nil then
    Exit;

  var item := cell.Row.DataItem;
  var checkBox := Cell.InfoControl as IIsChecked;

  if CString.IsNullOrEmpty(Cell.Column.PropertyName) then
    UpdateColumnCheck(cell.Row.DataIndex, Cell.Column, checkBox.IsChecked);

//  if not CString.IsNullOrEmpty(Cell.Column.PropertyName) then
//  begin
//    SetCellData(cell, checkBox.IsChecked);
//
//    if (_model <> nil) and CObject.Equals(item, Cell.Row.DataItem) then
//      _model.ObjectModelContext.UpdatePropertyBindingValues;
//
////    DoDataItemChangedInternal(item);
//  end;

  var checkChangeArgs: DCCheckChangedEventArgs;
  if Assigned(_cellCheckChanged) then
  begin
    AutoObject.Guard(DCCheckChangedEventArgs.Create(Cell), checkChangeArgs);
    _cellCheckChanged(Self, checkChangeArgs);

    if checkChangeArgs.DoFollowCheckThroughChildren then
      FollowCheckThroughChildren(Cell);
  end;
end;

procedure TScrollControlWithEditableCells.OnNonPropertyCheckBoxChange(Sender: TObject);
begin
  if Self.IsUpdating or (_updateCount > 0) then
    Exit;

  var cell := GetCellByControl(Sender as TControl);
  if cell = nil then Exit; // view not visible yet..

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Internal;

  var requestedSelection := _selectionInfo.Clone;
  requestedSelection.SetFocusedItem(cell.Row.DataIndex, cell.Row.ViewListIndex, cell.Row.DataItem);
  requestedSelection.Tag := FlatColumnByColumn(cell.Column).Index;

  if TrySelectItem(requestedSelection, []) then
  begin
    if not CString.IsNullOrEmpty(cell.Column.PropertyName) and not StartEditCell(cell, True, ' ') then
      Exit;

    DoCellCheckChangedByUser(cell);

//    if _cellEditor <> nil then
//      _cellEditor.BeginEdit(checkBox.IsChecked);


//    if not CString.IsNullOrEmpty(cell.Column.PropertyName) and not _editingInfo.RowIsEditing then
//    begin
//      var dataItem := Cell.Row.DataItem;
//      if not DoEditRowStart(Cell.Row as IDCTreeRow, {var} dataItem, False) then
//      begin
//        if IHadFocus then
//          Self.SetFocus;
//        Exit;
//      end;
//    end;

    // DoCellCheckChangedByUser(cell);

//    if IHadFocus then
//      Self.SetFocus;
  end;
end;

procedure TScrollControlWithEditableCells.OnViewChanged(Sender: TObject; e: EventArgs);
begin
  if {not IsNew and} _editingInfo.RowIsEditing then
  begin
    if not HasUpdateCount then
    begin
      var stillExistsInDataList := not IsNew or (_view.GetDataIndex(_editingInfo.EditItem) <> -1);

      if stillExistsInDataList then
        EndEditFromExternal else
        CancelEditFromExternal;
    end;

    Exit;
  end;

  inherited;
end;

procedure TScrollControlWithEditableCells.OnEditorExit;
begin
  // JvA: turned back on for the following situation:
  // Edit a cell in a project, than hit Save..
  // This is (for know) the only point were the tree knows we are going out of edit mode

//  {$IFDEF DEBUG}
//  // KV: Dissabled to fix F2 | Down arrow | F2
//  {$ELSE}
  // windows wants to clear the focus control after this point
  // therefor we need a little time untill we can EndEdit and free the editor


  // otherwise already EndEdited
  if _cellEditor <> nil then
    TThread.ForceQueue(nil, procedure
    begin
      SafeForcedEndEdit;
    end);

//  {$ENDIF}
end;

procedure TScrollControlWithEditableCells.OnEditorKeyDown(const CellEditor: IDCCellEditor; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkEscape) then
  begin
    CancelEdit;
    Self.SetFocus;

    Key := 0;
  end
  else if Key = vkReturn then
  begin
    if CellEditor.IsMultiLine and ((ssCtrl in Shift) or (ssShift in Shift)) then
      Exit; // let memo handle

    SafeForcedEndEdit;
    Self.SetFocus;

    Key := 0;
  end
  else if (Key in [vkUp, vkDown]) then
  begin
    if CellEditor.IsMultiLine and (Shift = []) then
    begin
      var mm := CellEditor.Editor as TMemo;

      if (Key = vkUp) and not mm.CaretPosition.IsZero then
        Exit; // let memo handle

      if key = vkDown then
      begin
        if (mm.CaretPosition.Line < mm.Lines.Count - 1) then
          Exit; // let memo handle

        if (mm.CaretPosition.Pos < Length(mm.Lines[mm.Lines.Count - 1])) then
          Exit; // let memo handle
      end;

    end;

    var changeUpdatedSort: Boolean;
    if not EndEditCell({out} changeUpdatedSort) or changeUpdatedSort then
      Exit;

    var crr := Self.Current;
    if not DoEditRowEnd(GetActiveRow as IDCTreeRow, {out} changeUpdatedSort) or changeUpdatedSort then
      Exit;

    if Key = vkUp then
      Self.Current := CMath.Max(crr-1, 0) else
      Self.Current := CMath.Min(crr+1, _view.ViewCount-1);

    Self.SetFocus;
    Key := 0;
  end;
end;

procedure TScrollControlWithEditableCells.OnHeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if (Button = TMouseButton.mbLeft) and not _fullHeaderClick then
    Exit;

  if _editingInfo.RowIsEditing then
    EndEditFromExternal;

  inherited;
end;

procedure TScrollControlWithEditableCells.set_Model(const Value: IObjectListModel);
begin
  if _model = Value then
    Exit;

  if (_model <> nil) then
  begin
    var ct: IOnItemChangedSupport;
    if (_modelListItemChanged <> nil) and Interfaces.Supports<IOnItemChangedSupport>(_model, ct) then
      ct.OnItemChanged.Remove(_modelListItemChanged);
  end;

  inherited;

  if _model <> nil then
  begin
    var ct: IOnItemChangedSupport;
    if Interfaces.Supports<IOnItemChangedSupport>(_model, ct) then
    begin
      if _modelListItemChanged = nil then
        _modelListItemChanged := TObjectListModelItemChangedDelegate.Create(Self);

      ct.OnItemChanged.Add(_modelListItemChanged);
    end;
  end;
end;

procedure TScrollControlWithEditableCells.UpdateColumnCheck(const DataIndex: Integer; const Column: IDCTreeColumn; IsChecked: Boolean);
begin
  Assert(Column.InfoControlClass = TInfoControlClass.CheckBox);

  if not _checkedItems.ContainsKey(Column) then
    _checkedItems.Add(Column, CList<Integer>.Create);

  var columnCheckedItems := _checkedItems[Column];
  if IsChecked and not columnCheckedItems.Contains(DataIndex) then
    columnCheckedItems.Add(DataIndex)
  else if not IsChecked and columnCheckedItems.Contains(DataIndex) then
    columnCheckedItems.Remove(DataIndex);
end;

procedure TScrollControlWithEditableCells.UpdateColumnCheck(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean);
begin
  if _view = nil then
    GenerateView;

  var ix := _view.OriginalData.IndexOf(DataItem);
  if ix <> -1 then
    UpdateColumnCheck(ix, Column, IsChecked);
end;

procedure TScrollControlWithEditableCells.ResetColumnWidthOnHideEditor(const Column: IDCTreeColumn);
begin
  FastColumnAlignAfterColumnChange;
end;

procedure TScrollControlWithEditableCells.ResetView(const FromViewListIndex: Integer; ClearOneRowOnly: Boolean);
begin
  // in case of IsNew a row needs to be added, and therefor the _view needs te be reset!
  if not IsEdit then
  begin
    inherited;
    Exit;
  end;

  _resetViewRec := TResetViewRec.CreateFrom(FromViewListIndex, ClearOneRowOnly, True, _resetViewRec);
end;

procedure TScrollControlWithEditableCells.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var clickedRow := GetRowByLocalY(Y);
  if clickedRow = nil then
  begin
    // end edit if needed
    if _editingInfo.CellIsEditing then
      CheckCanChangeRow;

    Exit;
  end;

  var crrntCell := GetActiveCell;
  if IsEditOrNew and not CObject.Equals(_editingInfo.EditItem, clickedRow.DataItem) then
  begin
    var clickedRowDataIndex := clickedRow.DataIndex;
    var editItem := _editingInfo.EditItem; // can be set to nil in next line
    if not CheckCanChangeRow then
      Exit;

    var filteredOut := _view.ItemIsFilteredOut(editItem);
    var sortCouldBeChanged := ((_view.GetSortDescriptions <> nil) and (_view.GetSortDescriptions.Count > 0));

    if filteredOut or sortCouldBeChanged then
    begin
      // changing the data can cause a row to become filtered out of the view
      // in that case we have to redirect the click to the updated click position
      if filteredOut then
        ResetView(crrntCell.Row.ViewListIndex) else
        ResetView;

      // ResetView requests a Realign content..
      // we execute that calculations directly
      DoRealignContent;

      var findClickedRowBackViewIndex := _view.GetViewListIndex(clickedRowDataIndex);
      if findClickedRowBackViewIndex = -1 then Exit;

      var findClickedRowBack := _view.GetActiveRowIfExists(findClickedRowBackViewIndex);
      if findClickedRowBack = nil then Exit;

      // click again with correct Y values in case a row has filtered out
      UserClicked(Button, Shift, X, findClickedRowBack.VirtualYPosition + 1 - _vertScrollBar.Value);
      VisualizeRowSelection(findClickedRowBack);

      Exit;
    end;
  end;

  inherited;

  if Shift * [ssShift, ssCtrl] = [] then
  begin
    // check if row change came through if it was needed
    var newCell := GetActiveCell;
    var clmn := GetFlatColumnByMouseX(X);
    if (newCell <> nil) and (newCell.Row = clickedRow) and (newCell.LayoutColumn = clmn) and not newCell.Column.ReadOnly then
    begin
      if not newCell.Column.IsSelectionColumn and (newCell.Column.InfoControlClass = TInfoControlClass.CheckBox) then
        (newCell.InfoControl as IIsChecked).IsChecked := not (newCell.InfoControl as IIsChecked).IsChecked
      else if ((ssDouble in Shift) or (crrntCell = newCell)) and not _editingInfo.CellIsEditing then
        StartEditCell(newCell, True, nil {keep cell data value});
    end;
  end;
end;

function TScrollControlWithEditableCells.LoadDefaultPickListForCell(const Cell: IDCTreeCell; const CellValue: CObject) : IList;
begin
  Result := nil;

  var tp := &Type.Unknown;
  if not CString.IsNullOrEmpty(Cell.Column.PropertyName) then
  begin
    if ViewIsDataModelView then
      tp := GetDataModelView.DataModel.FindColumnByName(Cell.Column.PropertyName).DataType else
      tp := GetItemType.PropertyByName(Cell.Column.PropertyName).GetType;
  end;

  if tp.IsUnknown and (CellValue <> nil) then
    tp := CellValue.GetType;

  if tp.IsEnum then
  begin
    var arr := CEnum.GetValues(tp);
    if arr <> nil then
    begin
      Result := CList<CObject>.Create(Length(arr));
      for var o in arr do
        Result.Add(o);
    end;
  end;
end;

function TScrollControlWithEditableCells.StartEditCell(const Cell: IDCTreeCell; CallShowEditor: Boolean; const UserValue: CString) : Boolean;
begin
  // row can be in edit mode already, but cell should not be in edit mode yet
  if (Cell = nil) or not CanEditCell(Cell) then
    Exit(False);

  if _editingInfo.CellIsEditing then
    Exit(True);

  var rowEditStartedHere := not _editingInfo.RowIsEditing;
  if not _editingInfo.RowIsEditing then
  begin
    _selectionInfo.ClearMultiSelections;

    var dataItem := Self.DataItem;
    var isNew := False;
    if not DoEditRowStart(Cell.Row as IDCTreeRow, {var} dataItem, isNew) then
      Exit(False);
  end;

  var cellValue := Cell.Column.ProvideCellData(cell, cell.Column.PropertyName);

  var startEditArgs: DCStartEditEventArgs;
  AutoObject.Guard(DCStartEditEventArgs.Create(Cell, cellValue), startEditArgs);

  startEditArgs.PickList := LoadDefaultPickListForCell(Cell, cellValue);
  startEditArgs.AllowEditing := True;
  if Assigned(_editCellStart) then
    _editCellStart(Self, startEditArgs);

  if startEditArgs.AllowEditing then
  begin
    _editingInfo.StartCellEdit(Cell.Row.DataIndex, FlatColumnByColumn(Cell.Column).Index);
    if CallShowEditor then
      ShowEditor(Cell, startEditArgs, UserValue);
    Exit(True);
  end
  else if rowEditStartedHere then
    CancelEdit;

  Exit(False);
end;

function TScrollControlWithEditableCells.TryAddRow(const Position: InsertPosition): Boolean;
begin
  Assert(not _editingInfo.RowIsEditing);


  var em: IEditableModel;
  if (_model <> nil) and interfaces.Supports<IEditableModel>(_model, em) and em.CanAdd then
  begin
    var addL: IAddToList;
    var addDm: IAddToDataModel;
    if interfaces.Supports<IAddToList>(_model, addL) then
      addL.AddNew(Self.Current, False)
    else if interfaces.Supports<IAddToDataModel>(_model, addDm) then
      addDm.AddNew(GetActiveRow.DataItem, InsertPosition.After);

    Exit(True);
  end;

  var newItem: CObject := nil;
  if not DoAddingNew({out} newItem) then
    Exit(False);

  // clear all sorts!!
  if ClearTreeSorts then
  begin
    UpdateHeaderRowControls;
    ForceImmeditiateRealignContent;
  end;

  if newItem = nil then
  begin
    var addIntf: IAddingNewSupport;
    if Interfaces.Supports<IAddingNewSupport>(_dataList, addIntf) then
      addIntf.AddingNew(nil, NewItem);

    if not ViewIsDataModelView and (NewItem = nil) then
    begin
      if ListHoldsOrdinalType then
        NewItem := ''

      else if (_view.OriginalData.Count > 0) then
      begin
        var referenceItem := ConvertToDataItem(_view.OriginalData[0]);
        {$IFNDEF WEBASSEMBLY}
        var obj: CObject := &Assembly.CreateInstanceFromObject(referenceItem);
        {$ELSE}
        var obj: CObject := Activator.CreateInstance(referenceItem.GetType);
        {$ENDIF}
        if obj = nil then
          raise NullReferenceException.Create(CString.Format('Failed to create instance of object {0}, implement event OnAddingNew', referenceItem.GetType));
        if not obj.TryCast(TypeOf(referenceItem), {out} NewItem, True) then
          raise NullReferenceException.Create(CString.Format('Failed to convert {0} to {1}, implement event OnAddingNew', obj.GetType, referenceItem.GetType));
      end;
    end;
  end;

  var newDataItem: CObject := nil;
  var newViewListIndex := Self.Current;

  if ViewIsDataModelView then
  begin
    var location: IDataRow := nil;
    if (newViewListIndex < GetDataModelView.Rows.Count) and (GetDataModelView.Rows.Count > 0) then
      location := GetDataModelView.Rows[newViewListIndex].Row;

    // make sure ViewChanged is not called at this point by using inc(_updateCount);
    var dataRow: IDataRow;
    inc(_updateCount);
    try
      dataRow := GetDataModelView.DataModel.AddNew(location, Position);

      if dataRow <> nil then
      begin
        // dataModel can have it's own "OnAddNewRow" where the Data can be created
        if NewItem <> nil then
        begin
          dataRow.Data := NewItem;
          GetDataModelView.DataModel.AddKey(dataRow);
        end;

        _view.RecalcSortedRows;

        var drv := GetDataModelView.FindRow(dataRow);
        if drv <> nil then
        begin
          _editingInfo.StartRowEdit(drv.Row.get_Index, drv, True);

          newDataItem := drv;
          GetDataModelView.Refresh;
          ResetView;
        end;
      end;
    finally
      dec(_updateCount);
    end;
  end
  else
  begin
    if NewItem = nil then
      Exit(False);

    if (newViewListIndex = -1) or (Position = InsertPosition.After) then
      inc(newViewListIndex);

    _view.GetViewList.Insert(newViewListIndex, NewItem);
    ResetView;

    newDataItem := newItem;
    var newDataIndex := _view.OriginalData.IndexOf(NewItem);
    _editingInfo.StartRowEdit(newDataIndex, NewItem, True);
  end;

  Result := _editingInfo.IsNew;
  if Result then
  begin
    _selectionInfo.SetFocusedItem(_editingInfo.EditItemDataIndex, _view.GetViewListIndex(_editingInfo.EditItemDataIndex), newDataItem);

    // let the view know that we started with editing
    _view.StartEdit(_editingInfo.EditItem);

    RealignFromSelectionChange;

    GetActiveRow.UseBuffering := False;
  end;
end;

procedure TScrollControlWithEditableCells.TryCheckParentIfAllSelected(const ParentDrv: IDataRowView; const ColumnCheckedItems: List<Integer>);
begin
  if (ParentDrv = nil) or ColumnCheckedItems.Contains(ParentDrv.Row.get_Index) then
    Exit; // nothing to do

  var parentChildren := GetDataModelView.DataModel.Children(ParentDrv.Row, TChildren.IncludeParentRows);

  var dr: IDataRow;
  for dr in parentChildren do
    if (ParentDrv.Row <> dr) and not ColumnCheckedItems.Contains(dr.get_Index) then
      Exit;

  ColumnCheckedItems.Add(ParentDrv.Row.get_Index);

  var parent := GetDataModelView.Parent(ParentDrv);
  TryCheckParentIfAllSelected(parent, ColumnCheckedItems);
end;

function TScrollControlWithEditableCells.TryDeleteSelectedRows: Boolean;
begin
  var em: IEditableModel;
  if (_model <> nil) and interfaces.Supports<IEditableModel>(_model, em) and em.CanRemove then
  begin
    em.Remove;
    Exit(True);
  end;

  var dataIndexes: List<Integer> := CList<Integer>.Create;
  for var ix in _selectionInfo.SelectedDataIndexes do
    dataIndexes.Add(ix);

  dataIndexes.Sort(function(const x, y: Integer): Integer begin Result := -CInteger(x).CompareTo(y); end);

  Result := False;
  var currentIndex := Self.Current;
  var ix: Integer;
  for ix in dataIndexes do
  begin
    var obj := _view.OriginalData[ix];

    if DoUserDeletingRow(obj) then
    begin
      if ViewIsDataModelView then
      begin
        var location := GetDataModelView.Rows[ix].Row;
        GetDataModelView.DataModel.Remove(location);
      end else
        _view.OriginalData.RemoveAt(ix);

      DoUserDeletedRow;

      Result := True;
    end;
  end;

  if Result then
  begin
    _view.RecalcSortedRows;

    if _view.ViewCount > 0 then
    begin
      var ixDel := CMath.Max(0, CMath.Min(_view.ViewCount -1, currentIndex));

      _selectionInfo.SetFocusedItem( _view.GetDataIndex(ixDel), ixDel, _view.GetViewList[ixDel]);
      RealignFromSelectionChange;
    end
    else
      Self.Current := -1;
  end;
end;

function TScrollControlWithEditableCells.TrySelectCheckBoxes: Boolean;
begin
  var cell := GetActiveCell;
  if (cell = nil) or cell.Column.IsSelectionColumn or (cell.Column.InfoControlClass <> TInfoControlClass.CheckBox) then
  begin
    var valid := False;
    var flatClmn: IDCTreeLayoutColumn;
    for flatClmn in Self.Layout.FlatColumns do
      if not flatClmn.Column.IsSelectionColumn and (flatClmn.Column.InfoControlClass = TInfoControlClass.CheckBox) then
      begin
        cell := (cell.Row as IDCTReeRow).Cells[flatClmn.Index];
        valid := True;
        Break;
      end;

    if not valid then
      Exit(False);
  end;

  var checks: List<IIsChecked> := CList<IIsChecked>.Create;
  var itemIx: Integer;
  for itemIx in _selectionInfo.SelectedDataIndexes do
  begin
    // not all rows are visible
    var viewIx := _view.GetViewListIndex(itemIx);
    var row := _view.GetActiveRowIfExists(viewIx);

    if row = nil then
      Continue;

    var rowCell := (row as IDCTreeRow).Cells[cell.Index];
    if (rowCell.InfoControl <> nil) and rowCell.InfoControl.Visible then
      checks.Add(rowCell.InfoControl as IIsChecked);
  end;

  if checks.Count = 0 then
    Exit(False);

  var checkCount := 0;
  var check: IIsChecked;
  for check in checks do
    if check.IsChecked then
      inc(checkCount);

  BeginUpdate;
  try
    var check2: IIsChecked;
    for check2 in checks do
    begin
      if check2.IsChecked <> (checkCount < checks.Count) then
      begin
        var checkCell := GetCellByControl(check2 as TControl);
        DoCellCheckChangedByUser(checkCell);
      end;
    end;
  finally
    EndUpdate;
  end;

  Result := True;
end;

procedure TScrollControlWithEditableCells.CancelEdit(CellOnly: Boolean = False);
begin
  if _editingInfo.CellIsEditing then
  begin
    _editingInfo.CellEditingFinished;
    HideEditor;
  end;

  if CellOnly then
  begin
    DoDataItemChangedInternal(_editingInfo.EditItem);
    Exit;
  end;

  var isModelRemove := False;
  var wasNew := IsNew;
  var crrCell := GetActiveCell;

  var notify: IEditableModel;
  if (_Model <> nil) and Interfaces.Supports<IEditableModel>(_Model, notify) then
  begin
    var u: IUpdatableObject;
    if Interfaces.Supports<IUpdatableObject>(_modelListItemChanged, u) then
    try
      u.BeginUpdate;
      notify.CancelEdit;
    finally
      u.EndUpdate
    end else
      notify.CancelEdit;

    isModelRemove := True;
  end;

  _view.EndEdit;
  _editingInfo.RowEditingFinished;

  if not isModelRemove then
  begin
    if ViewIsDataModelView then
    begin
      GetDataModelView.DataModel.CancelEdit(GetActiveRow.DataItem.AsType<IDataRowView>.Row);
      AfterCancelEdit(crrCell, wasNew);
      Exit;
    end
    else if wasNew then // remove item from list
      TryDeleteSelectedRows;
  end;

  AfterCancelEdit(crrCell, wasNew);
end;

function TScrollControlWithEditableCells.EditActiveCell(SetFocus: Boolean; const UserValue: CString): Boolean;
begin
  var cell := GetActiveCell;
  if (cell <> nil) and CanEditCell(cell) then
    StartEditCell(cell, True, UserValue);

  Result := _cellEditor <> nil;
  if Result and SetFocus then
    _cellEditor.Editor.SetFocus;
end;

function TScrollControlWithEditableCells.CopyToClipBoard : Boolean;
begin
  if Assigned(_copyToClipboard) then
  begin
    _copyToClipboard(Self);
    Result := True;
  end else
    Result := False;
end;

function TScrollControlWithEditableCells.PasteFromClipBoard : Boolean;
begin
  if Assigned(_pasteFromClipboard) then
  begin
    _pasteFromClipboard(Self);
    Result := True;
  end else
  begin
    var clipboard: IFMXClipboardService;
    {$IFNDEF WEBASSEMBLY}
    if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipBoard) then
      Result := EditActiveCell(True, ClipBoard.GetClipboard.AsString) else
      Result := False;
    {$ELSE}
    if TPlatformServices.Current.SupportsPlatformService<IFMXClipboardService>(ClipBoard) then
      Result := EditActiveCell(True, ClipBoard.GetClipboard.ToString) else
      Result := False;
    {$ENDIF}
  end;
end;

function TScrollControlWithEditableCells.ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject;
begin
  if (Cell.Column.InfoControlClass = TInfoControlClass.CheckBox) and not Cell.Column.IsSelectionColumn and not Cell.Column.HasPropertyAttached then
    Exit(_checkedItems.ContainsKey(Cell.Column) and _checkedItems[Cell.Column].Contains(Cell.Row.DataIndex));

  Result := inherited;

  if (Result = nil) and IsNew and (_cellEditor <> nil) and (_cellEditor.Cell = Cell) then
    Result := _cellEditor.Value;
end;

function TScrollControlWithEditableCells.EndEditCell(out ChangeUpdatedSort: Boolean): Boolean;
begin
  {out} ChangeUpdatedSort := False;

  // stop cell editing
  if (_editingInfo <> nil) and _editingInfo.CellIsEditing and not _editingInfo.InsideEndEditCell then
  begin
    _editingInfo.BeginEndEditCell;
    try
      var EditRowEnd := False;

      var val := _cellEditor.Value;
      var cell := _cellEditor.Cell;
      if not DoCellParsing(cell, True, {var} val) or CObject.Equals(val, _cellEditor.OriginalValue) then
      begin
        CancelEdit(True);
        Exit(False);
      end;

      if Assigned(_editCellEnd) then
      begin
        var endEditArgs: DCEndEditEventArgs;
        AutoObject.Guard(DCEndEditEventArgs.Create(cell, val, _cellEditor.Editor, _editingInfo.EditItem), endEditArgs);
        endEditArgs.EndRowEdit := False;

        _editCellEnd(Self, endEditArgs);

        if endEditArgs.Accept then
          val := endEditArgs.Value else
          Exit(False);

        EditRowEnd := endEditArgs.EndRowEdit;
      end;

      SetCellData(cell, val);

      var isDataItemChange := CString.Equals(cell.Column.PropertyName, COLUMN_SHOW_DEFAULT_OBJECT_TEXT);

      if not isDataItemChange then
      begin
        // KV: 24/01/2025
        // Update the actual contents of the cell after the data in the cell has changed
        LoadDefaultDataIntoControl(cell, False);
      end;

      _editingInfo.CellEditingFinished;

      var row := cell.Row as IDCTreeRow;

      // reset width of all cells, because multiple columns can depend on this item
      row.ContentCellSizes.Clear;
//      if row.ContentCellSizes.ContainsKey(cell.Index) then
//        row.ContentCellSizes.Remove(cell.Index);

      // Hide Editor after clear row.ContentCellSizes
      HideEditor;

      DoDataItemChangedInternal(row.DataItem);

      if EditRowEnd then
        Exit(DoEditRowEnd(row, {out} ChangeUpdatedSort));
    finally
      _editingInfo.EndEndEditCell;
    end;
  end;

  Result := True;
end;

procedure TScrollControlWithEditableCells.CancelEditFromExternal;
begin
  if (_internalSelectCount > 0) or not IsEditOrNew then
    Exit;

  var wasNew := IsNew;

  var crrCell := GetActiveCell;

  if _editingInfo.CellIsEditing or ((crrCell = nil) and (_cellEditor <> nil)) then
  begin
    _editingInfo.CellEditingFinished;
    HideEditor;
  end;

  _view.EndEdit;
  _editingInfo.RowEditingFinished;

  AfterCancelEdit(crrCell, wasNew);
end;

function TScrollControlWithEditableCells.CanEditCell(const Cell: IDCTreeCell): Boolean;
begin
  Result := (Cell <> nil) and not Cell.Column.ReadOnly and not (TDCTreeOption.ReadOnly in _options);
end;

procedure TScrollControlWithEditableCells.EndEditFromExternal;
begin
  if (_internalSelectCount > 0) or not IsEditOrNew then
    Exit;

  var crrCell := GetActiveCell;
  if crrCell = nil then
  begin
    _editingInfo.CellEditingFinished;
    _editingInfo.RowEditingFinished;
    Exit;
  end;

  if _editingInfo.CellIsEditing then
    SafeForcedEndEdit;

  // EndCellEdit can already execute EndRowEdit!!
  // therefor ask if RowIsEditing again
  if _editingInfo.RowIsEditing then
  begin
    var changeUpdatedSort: Boolean;
    DoEditRowEnd(crrCell.Row as IDCTreeRow, changeUpdatedSort);
  end;
end;

procedure TScrollControlWithEditableCells.FollowCheckThroughChildren(const Cell: IDCTreeCell);
begin
  if not Cell.Row.DataItem.IsOfType<IDataRowView> then
    Exit;

  var columnCheckedItems := _checkedItems[Cell.Column];
  var isChecked := (Cell.InfoControl as IISChecked).IsChecked;

  var drv := Cell.Row.DataItem.AsType<IDataRowView>;
  var parent := GetDataModelView.Parent(drv);

  if not isChecked then
  begin
    while parent <> nil do
    begin
      if columnCheckedItems.Contains(parent.Row.get_Index) then
        columnCheckedItems.Remove(parent.Row.get_Index);

      parent := GetDataModelView.Parent(parent);
    end;
  end;

  var children := GetDataModelView.DataModel.Children(drv.Row, TChildren.IncludeParentRows);
  var dr: IDataRow;
  for dr in children do
  begin
    if isChecked and not columnCheckedItems.Contains(dr.get_Index) then
      columnCheckedItems.Add(dr.get_Index)
    else if not isChecked and columnCheckedItems.Contains(dr.get_Index) then
      columnCheckedItems.Remove(dr.get_Index);
  end;

  if isChecked then
    TryCheckParentIfAllSelected(parent, columnCheckedItems);

  RefreshControl(True);
end;

procedure TScrollControlWithEditableCells.GenerateView;
begin
  inherited;

  _checkedItems := CDictionary<IDCTreeColumn, List<Integer>>.Create;
end;

procedure TScrollControlWithEditableCells.ShowEditor(const Cell: IDCTreeCell; const StartEditArgs: DCStartEditEventArgs; const UserValue: CString);
var
  dataType: &Type;
begin
  Assert(_cellEditor = nil);

//  UpdateMinColumnWidthOnShowEditor(Cell, startEditArgs.MinEditorWidth);

  // checkboxes are special case, for they are already visualized in DataControl.Static
  // all other controls can be shown as plain text while not editing

  if StartEditArgs.Editor <> nil then
    _cellEditor := TDCCustomCellEditor.Create(Self, Cell, StartEditArgs.Editor)
  else if StartEditArgs.PickList <> nil then
  begin
    Assert(Cell.Column.InfoControlClass in [TInfoControlClass.Text, TInfoControlClass.Custom]);

    if StartEditArgs.MultiSelect then
      _cellEditor := TDCCellMultiSelectDropDownEditor.Create(self, Cell) else
      _cellEditor := TDCCellDropDownEditor.Create(self, Cell);

    _cellEditor.DefaultValue := StartEditArgs.DefaultValue;
    _cellEditor.PickList := StartEditArgs.PickList;
    _cellEditor.UserCanClear := StartEditArgs.UserCanClear;
  end
  else if Cell.Column.InfoControlClass = TInfoControlClass.CheckBox then
    _cellEditor := TDCCheckBoxCellEditor.Create(Self, Cell)
  else
  begin
    if not CString.IsNullOrEmpty(Cell.Column.PropertyName) and not CString.Equals(Cell.Column.PropertyName, COLUMN_SHOW_DEFAULT_OBJECT_TEXT) then
    begin
      if ViewIsDataModelView then
        dataType := GetDataModelView.DataModel.FindColumnByName(Cell.Column.PropertyName).DataType else
        dataType := GetItemType.PropertyByName(Cell.Column.PropertyName).GetType;
    end else
      {$IFNDEF WEBASSEMBLY}
      dataType := Global.StringType;
      {$ELSE}
      dataType := &Global.GetTypeOf<String>;
      {$ENDIF}

    if dataType.IsDateTime then
      _cellEditor := TDCCellDateTimeEditor.Create(self, Cell)

    else begin
      var settings: ITextSettings;
      if StartEditArgs.MultilineEdit then
        _cellEditor := TDCTextCellMultilineEditor.Create(self, Cell) else
        _cellEditor := TDCTextCellEditor.Create(self, Cell);
    end;

    _cellEditor.UserCanClear := StartEditArgs.UserCanClear;
  end;

  if (UserValue = nil) or not _CellEditor.TryBeginEditWithUserKey(StartEditArgs.Value, UserValue) then
    _cellEditor.BeginEdit(StartEditArgs.Value);
end;

procedure TScrollControlWithEditableCells.HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions);
begin
  if (TDCTreeOption.AllowAddNewRows in OldFlags) and not (TDCTreeOption.AllowAddNewRows in NewFlags) then
    _options := _options - [TDCTreeOption.AllowAddNewRowsWithDownKey]
  else if not (TDCTreeOption.AllowAddNewRowsWithDownKey in OldFlags) and (TDCTreeOption.AllowAddNewRowsWithDownKey in NewFlags) then
    _options := _options + [TDCTreeOption.AllowAddNewRows];

  inherited;
end;

procedure TScrollControlWithEditableCells.HideEditor;
begin
  var cell := _cellEditor.Cell;

  _cellEditor.EndEdit;
  _cellEditor := nil;

  Self.SetFocus;

  var row := cell.Row as IDCTreeRow;
  if (cell.Column.WidthType = TDCColumnWidthType.AlignToContent) and row.ContentCellSizes.ContainsKey(cell.Index) then
  begin
    row.ContentCellSizes.Remove(cell.Index);
    cell.LayoutColumn.Width := 0;  // make sure it get's recalced
  end;

  ResetColumnWidthOnHideEditor(cell.Column);

  var activeCell := GetActiveCell;
  if activeCell = nil then Exit; // cell scrolled out of view

  activeCell.LayoutColumn.UpdateCellControlsPositions(activeCell);
end;

procedure TScrollControlWithEditableCells.AfterCancelEdit(const PrevCell: IDCTreeCell; WasNew: Boolean);
begin
  if WasNew then
  begin
    var cell := GetActiveCell;
    DoCellChanging(PrevCell, cell {can be nil});
    DoCellChanged(PrevCell, cell {can be nil});
    RefreshControl;
  end
  else if GetActiveRow <> nil then
    DoDataItemChangedInternal(GetActiveRow.DataItem);
end;

procedure TScrollControlWithEditableCells.InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean);
begin
  Assert(CanRealignContent);

  if IsNew then
  begin
    var ix := _view.GetViewListIndex(_editingInfo.EditItemDataIndex);

    _selectionInfo.BeginUpdate;
    try
      _selectionInfo.SetFocusedItem(_editingInfo.EditItemDataIndex, ix, _editingInfo.EditItem);
      _selectionInfo.ClearMultiSelections;
    finally
      _selectionInfo.EndUpdate(True);
    end;

    var row: IDCRow;
    for row in _view.ActiveViewRows do
      VisualizeRowSelection(row);

    Exit;
  end;

  inherited;
end;

function TScrollControlWithEditableCells.BeginEdit: Boolean;
begin
  Result := False;
  var cell := GetActiveCell;
  // row can be in edit mode already, but cell should not be in edit mode yet
  if (cell = nil) or not CanEditCell(cell) or _editingInfo.RowIsEditing then
    Exit;
  _selectionInfo.ClearMultiSelections;
  var dataItem := Self.DataItem;
  var isNew := False;
  Result := DoEditRowStart(Cell.Row as IDCTreeRow, {var} dataItem, isNew);
end;

function TScrollControlWithEditableCells.EndEdit: Boolean;
begin
  if (_editingInfo <> nil) and _editingInfo.RowIsEditing then
  begin
    var changeUpdatedSort: Boolean;
    if not EndEditCell({out} changeUpdatedSort) or changeUpdatedSort then
      Exit(False);

    if not DoEditRowEnd(GetActiveCell.Row as IDCTreeRow, {out} changeUpdatedSort) then
      Exit(False);
  end;

  Exit(True);
end;

function TScrollControlWithEditableCells.IsEdit: Boolean;
begin
  Result := _editingInfo.RowIsEditing and not _editingInfo.IsNew;
end;

function TScrollControlWithEditableCells.IsEditOrNew: Boolean;
begin
  Result := _editingInfo.RowIsEditing or _editingInfo.IsNew;
end;

function TScrollControlWithEditableCells.IsNew: Boolean;
begin
  Result := _editingInfo.IsNew;
end;

function TScrollControlWithEditableCells.ItemCheckedInColumn(const Item: CObject; const Column: IDCTreeColumn): Boolean;
begin
  if _view = nil then
    Exit(False);

  var ix := _view.OriginalData.IndexOf(Item);
  if ix = -1 then
    Exit(False);

  var columnCheckedItems: List<Integer>;
  Result := (_checkedItems <> nil) and _checkedItems.TryGetValue(Column, columnCheckedItems) and columnCheckedItems.Contains(ix);
end;

function TScrollControlWithEditableCells.DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean;
begin
  if _editingInfo.RowIsEditing then
  begin
    var changeUpdatedSort: Boolean;
    if not EndEditCell({out} changeUpdatedSort) or changeUpdatedSort then
      Exit(False);

    // stop row editing
    var goToNewRow := (NewCell = nil) or (OldCell.Row.DataIndex <> NewCell.Row.DataIndex);
    if goToNewRow then
    begin
      if not DoEditRowEnd(OldCell.Row as IDCTreeRow, {out} changeUpdatedSort) or changeUpdatedSort then
        Exit(False);
    end;
  end;

  Result := inherited;
end;

procedure TScrollControlWithEditableCells.DoCellCheckChangedByUser(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean);
begin
  var ix := _view.GetViewListIndex(DataItem);
  if ix = -1 then Exit;

  var row := _view.GetActiveRowIfExists(ix) as IDCTreeRow;
  if (row = nil) then Exit;

  var checkCell: IDCTreeCell := nil;
  var cell: IDCTreeCell;
  for cell in row.Cells.Values do
    if cell.Column = Column then
    begin
      checkCell := cell;
      Break;
    end;

  if (checkCell = nil) or (checkCell.InfoControl = nil) or not checkCell.InfoControl.Visible or ((checkCell.InfoControl as IIsChecked).IsChecked = IsChecked) then
    Exit;

  inc(_updateCount);
  try
    (checkCell.InfoControl as IIsChecked).IsChecked := IsChecked;
  finally
    dec(_updateCount);
  end;

  DoCellCheckChangedByUser(checkCell);
end;

function TScrollControlWithEditableCells.DoEditRowStart(const ARow: IDCTreeRow; var DataItem: CObject; IsNew: Boolean): Boolean;
var
  rowEditArgs: DCRowEditEventArgs;

begin
  if not ARow.Enabled then
    Exit(False);

  Result := True;
  if Assigned(_editRowStart) then
  begin
    AutoObject.Guard(DCRowEditEventArgs.Create(ARow, DataItem, not IsNew),  rowEditArgs);
    _editRowStart(Self, rowEditArgs);
    if rowEditArgs.Accept then
    begin
      DataItem := rowEditArgs.DataItem;
      Result := True;
    end else
      Result := False;
  end;

  if Result then
  begin
    var notify: IEditableModel;
    if Interfaces.Supports<IEditableModel>(_Model, notify) then
    begin
      var u: IUpdatableObject;
      if Interfaces.Supports<IUpdatableObject>(_modelListItemChanged, u) then
      try
        u.BeginUpdate;
        notify.BeginEdit(ARow.ViewListIndex);

        // can be cloned
        if DataItem.IsOfType<IDataRowView> then
          DataItem.AsType<IDataRowView>.Row.Data := _model.ObjectContext else
          DataItem := _model.ObjectContext;
      finally
        u.EndUpdate
      end else
        notify.BeginEdit(ARow.ViewListIndex);
    end
    else if ViewIsDataModelView then
    begin
      GetDataModelView.DataModel.BeginEdit(ARow.DataItem.AsType<IDataRowView>.Row);
    end;

    ARow.UseBuffering := False;
    _editingInfo.StartRowEdit(ARow.DataIndex, DataItem, IsNew);

    _view.StartEdit(_editingInfo.EditItem);
  end;
end;

procedure TScrollControlWithEditableCells.DoUserDeletedRow;
begin
  if Assigned(_rowDeleted) then
    _rowDeleted(Self);
end;

function TScrollControlWithEditableCells.DoUserDeletingRow(const Item: CObject): Boolean;
begin
  if Assigned(_rowDeleting) then
  begin
    var rowEditArgs: DCDeletingEventArgs;
    AutoObject.Guard(DCDeletingEventArgs.Create(Item), rowEditArgs);
    _rowDeleting(Self, rowEditArgs);
    Result := not rowEditArgs.Cancel;
  end else
    Result := True;
end;

function TScrollControlWithEditableCells.DoEditRowEnd(const ARow: IDCTreeRow; out ChangeUpdatedSort: Boolean): Boolean;
var
  rowEditArgs: DCRowEditEventArgs;

begin
  if not _editingInfo.RowIsEditing then
    Exit(True); // already done in DoEditCellEnd

  Result := True;
  if Assigned(_editRowEnd) then
  begin
    AutoObject.Guard(DCRowEditEventArgs.Create(ARow, _editingInfo.EditItem, not _editingInfo.IsNew), rowEditArgs);
    inc(_updateCount); // in case datamodel changes in EndEditRowEnd
    try
      _editRowEnd(Self, rowEditArgs);
    finally
      dec(_updateCount);
    end;
    Result := rowEditArgs.Accept;
  end;

  if Result then
  begin
    var notify: IEditableModel;
    if (_Model <> nil) and Interfaces.Supports<IEditableModel>(_Model, notify) then
    begin
      var u: IUpdatableObject;
      if Interfaces.Supports<IUpdatableObject>(_modelListItemChanged, u) then
      try
        u.BeginUpdate;
        notify.EndEdit;
      finally
        u.EndUpdate
      end else
        notify.EndEdit;

      // check if model was able to execute the EndEdit
      var es: IEditState;
      if Interfaces.Supports<IEditState>(_Model, es) and es.IsEditOrNew then
        Exit(False);
    end
    else if ViewIsDataModelView then
    begin
      inc(_updateCount);
      try
        GetDataModelView.DataModel.EndEdit(ARow.DataItem.AsType<IDataRowView>.Row);
      finally
        dec(_updateCount);
      end;
    end;

//    var ix := _view.GetViewList.IndexOf(_editingInfo.EditItem);
//    if ix <> -1 then
//      _view.GetViewList[ix] := _editingInfo.EditItem;

    var editItem := _editingInfo.EditItem;
    var dataIndex := _editingInfo.EditItemDataIndex;

    if not ViewIsDataModelView then
      _view.OriginalData[dataIndex] := editItem;

    _view.EndEdit;
    _editingInfo.RowEditingFinished;

    DoDataItemChanged(ARow.ViewListIndex, editItem, {out} ChangeUpdatedSort);

    ARow.UseBuffering := True;
  end;
end;

function TScrollControlWithEditableCells.DoCellParsing(const Cell: IDCTreeCell; IsCheckOnEndEdit: Boolean; var AValue: CObject) : Boolean;
var
  e: DCCellParsingEventArgs;

begin
  Result := True;
  if Assigned(_cellParsing) then
  begin
    AutoObject.Guard(DCCellParsingEventArgs.Create(Cell, AValue, IsCheckOnEndEdit), e);
    _cellParsing(Self, e);

    if e.DataIsValid then
      AValue := e.Value else
      Result := False;
  end;
end;

procedure TScrollControlWithEditableCells.DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean);
begin
  if IsEditOrNew then
  begin
    EndEditFromExternal;
    if IsEditOrNew then
      Exit;
  end;

  inherited;
end;

destructor TScrollControlWithEditableCells.Destroy;
begin
  _cellEditor := nil;

  inherited;
end;

function TScrollControlWithEditableCells.DoAddingNew(out NewObject: CObject) : Boolean;
begin
  NewObject := nil;

  if Assigned(_rowAdding) then
  begin
    var args: DCAddingNewEventArgs;
    AutoObject.Guard(DCAddingNewEventArgs.Create, args);

    _rowAdding(Self, args);
    NewObject := args.NewObject;
    Result := (NewObject <> nil) or args.AcceptIfNil;
  end else
    Result := True; // Continue with add new
end;

procedure TScrollControlWithEditableCells.SafeForcedEndEdit;
begin
  try
    var changeUpdatedSort: Boolean;
    if not EndEditCell({out} changeUpdatedSort) then
      CancelEdit(True);
  except
    on e: Exception do
    begin
      CancelEdit(True);
      raise;
    end;
  end;
end;

procedure TScrollControlWithEditableCells.SetCellData(const Cell: IDCTreeCell; const Data: CObject);
var
  s: string;
  msg: string;
  propInfo: _PropertyInfo;

begin
  try
    Inc(_updateCount);
    try
      if CString.Equals(Cell.Column.PropertyName, COLUMN_SHOW_DEFAULT_OBJECT_TEXT) then
      begin
        _editingInfo.EditItem := Data;
        Cell.Row.DataItem := Data;
      end
      else if not CString.IsNullOrEmpty(Cell.Column.PropertyName) then
      begin
        if ViewIsDataModelView then
          GetDataModelView.DataModel.SetPropertyValue(Cell.Column.PropertyName, Cell.Row.DataItem.GetValue<IDataRowView>.Row, Data)
        else begin
          // var prop := _editingInfo.EditItem.GetType.PropertyByName(Cell.Column.PropertyName);
          var prop := GetItemType.PropertyByName(Cell.Column.PropertyName);
          if prop <> nil then
            prop.SetValue(_editingInfo.EditItem, Data, []);
        end;
      end;
    finally
      Dec(_updateCount);
    end;

  except
    // Catch exception and translate into a 'nice' exception
    on E: Exception do
    begin
      msg := E.Message;
      try
        if Data <> nil then
          s := Data.ToString else
          s := '<empty>';

        {$IFNDEF WEBASSEMBLY}
        if (propInfo.PropInfo <> nil) and (propInfo.PropInfo.PropType <> nil) then
          msg := CString.Format('Invalid value: ''{0}'' (field expects a {1})', s, propInfo.PropInfo.PropType^.NameFld.ToString) else
          msg := CString.Format('Invalid value: ''{0}''', s);
        {$ELSE}
        if Assigned(propInfo) and (propInfo.PropertyType <> nil) then
          msg := CString.Format('Invalid value: ''{0}'' (field expects a {1})', s, propInfo.PropertyType) else
          msg := CString.Format('Invalid value: ''{0}''', s);
        {$ENDIF}
      except
        raise EConvertError.Create(msg);
      end;
      raise EConvertError.Create(msg);
    end;
  end;
end;

{ TTreeEditingInfo }

constructor TTreeEditingInfo.Create;
begin
  _dataIndex := -1;
  _flatColumnIndex := -1;
end;

procedure TTreeEditingInfo.BeginEndEditCell;
begin
  inc(_endEditCellCount);
end;

procedure TTreeEditingInfo.EndEndEditCell;
begin
  dec(_endEditCellCount);
end;

function TTreeEditingInfo.InsideEndEditCell: Boolean;
begin
  Result := _endEditCellCount > 0;
end;

function TTreeEditingInfo.get_EditItem: CObject;
begin
  Result := _editItem;
end;

function TTreeEditingInfo.get_EditItemDataIndex: Integer;
begin
  Result := _dataIndex;
end;

procedure TTreeEditingInfo.CellEditingFinished;
begin
//  Assert(_endEditCellCount > 0);
  _flatColumnIndex := -1;
end;

procedure TTreeEditingInfo.StartRowEdit(DataIndex: Integer; const EditItem: CObject; IsNew: Boolean);
begin
  Assert(_flatColumnIndex = -1);

  _dataIndex := DataIndex;
  _editItem := EditItem;
  _isNew := IsNew;
end;

procedure TTreeEditingInfo.StartCellEdit(DataIndex, FlatColumnIndex: Integer);
begin
  Assert(_dataIndex = DataIndex);
  _flatColumnIndex := FlatColumnIndex;
end;

function TTreeEditingInfo.IsNew: Boolean;
begin
  Result := _isNew;
end;

function TTreeEditingInfo.RowIsEditing: Boolean;
begin
  Result := _dataIndex <> -1;
end;

procedure TTreeEditingInfo.set_EditItem(const Value: CObject);
begin
  _editItem := Value;
end;

function TTreeEditingInfo.CellIsEditing: Boolean;
begin
  Result := RowIsEditing and (_flatColumnIndex <> -1);
end;

procedure TTreeEditingInfo.RowEditingFinished;
begin
  _dataIndex := -1;
  _editItem := nil;
  _isNew := False;
end;

{ TDCCellEditor }

function TDCCellEditor.TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;
begin
  Result := False;
end;

constructor TDCCellEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited Create;

  _editorHandler := EditorHandler;
  _cell := Cell;
end;

destructor TDCCellEditor.Destroy;
begin
  inherited;
  _editor.Dispose;
end;

procedure TDCCellEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean);
begin
  // ctrl is invisible when no data is set..
  if not _cell.InfoControl.Visible then
    _cell.LayoutColumn.UpdateCellControlsPositions(_cell, True {FORCE});

  if _cell.Column.InfoControlClass <> TInfoControlClass.CheckBox then
    _editor.Position.X := _cell.InfoControl.Position.X - ROW_CONTENT_MARGIN else
    _editor.Position.X := _cell.InfoControl.Position.X;

  _editor.Position.Y := _cell.InfoControl.Position.Y - ROW_CONTENT_MARGIN;
  _editor.Width := _cell.InfoControl.Width + (2*ROW_CONTENT_MARGIN);
  _editor.Height := _cell.InfoControl.Height + (2*ROW_CONTENT_MARGIN);

  _cell.InfoControl.Visible := False;

  _editor.FormatItem := FormatItem;

  {$IFNDEF WEBASSEMBLY}
  _editor.OnKeyDown := OnEditorKeyDown;
  _editor.OnExit := OnEditorExit;
  {$ELSE}
  _editor.OnKeyDown := @OnEditorKeyDown;
  _editor.OnExit := @OnEditorExit;
  {$ENDIF}

  if not _originalValueSet then
    _OriginalValue := EditValue;

  _cell.Control.AddObject(_editor.Control);
  _editor.SetFocus;
end;

function TDCCellEditor.FormatItem(const Item: CObject) : CString;
begin
  var cellData := Item;

  if _editorHandler.DoCellFormatting(_cell, False, {var} cellData) then
    Result := cellData.ToString(True) else
    Result := _cell.Column.GetFormattedValue(_cell, cellData);
end;

procedure TDCCellEditor.EndEdit;
begin
  _cell.InfoControl.Visible := True;
end;

function TDCCellEditor.get_Cell: IDCTreeCell;
begin
  Result := _Cell;
end;

function TDCCellEditor.get_ContainsFocus: Boolean;
begin
  Result := False;
end;

function TDCCellEditor.get_Editor: TControl;
begin
  Result := _editor.Control;
end;

function TDCCellEditor.get_IsMultiLine: Boolean;
begin
  Result := False;
end;

function TDCCellEditor.get_Modified: Boolean;
begin
  Result := not CObject.Equals(_OriginalValue, get_Value);
end;

function TDCCellEditor.get_OriginalValue: CObject;
begin
  Result := _OriginalValue;
end;

function TDCCellEditor.get_PickList: IList;
begin
  var ce: IComboEditControl;
  if Interfaces.Supports<IComboEditControl>(_editor, ce) then
    Result := ce.PickList;
end;

function TDCCellEditor.get_UserCanClear: Boolean;
begin
  Result := _editor.ShowClearButton;
end;

function TDCCellEditor.get_DefaultValue: CObject;
begin
  Result := _editor.DefaultValue;
end;

procedure TDCCellEditor.set_DefaultValue(const Value: CObject);
begin
  _editor.DefaultValue := Value;
end;

function TDCCellEditor.get_Value: CObject;
begin
  Result := _editor.Value;
end;

procedure TDCCellEditor.OnEditorExit(Sender: TObject);
begin
  _editorHandler.OnEditorExit;
end;

procedure TDCCellEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  _editor.DoKeyDown(Sender, Key, KeyChar, Shift);
  if Key <> 0 then
    _editorHandler.OnEditorKeyDown(Self, Key, KeyChar, Shift);
end;

procedure TDCCellEditor.SetCustomValue(const EditValue: CObject);
begin
  // if no user input key, then format like always => "2 days" stays "2 days"
  if CObject.Equals(EditValue, _originalValue) then
  begin
    set_Value(EditValue);
    Exit;
  end;

  // user input key.. Only convert this key or BackSpace/Delete to string
  var onFormat: TFormatItem := _editor.FormatItem;
  _editor.FormatItem := nil;
  try
    set_Value(EditValue);
  finally
    _editor.FormatItem := onFormat;
  end;
end;

procedure TDCCellEditor.set_PickList(const Value: IList);
begin
  var ce: IComboEditControl;
  if Interfaces.Supports<IComboEditControl>(_editor, ce) then
    ce.PickList := Value;
end;

procedure TDCCellEditor.set_UserCanClear(const Value: Boolean);
begin
  _editor.ShowClearButton := Value;
end;

procedure TDCCellEditor.set_Value(const Value: CObject);
begin
  _editor.Value := Value;
end;

{ TDCTextCellEditor }
procedure TDCTextCellEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean = True);
begin
  inherited;

  SetCustomValue(EditValue);

  var ta: ITextActions;
  if Interfaces.Supports<ITextActions>(_editor, ta) then
  begin
    if SelectAll then
      ta.SelectAll else
      ta.GoToTextEnd;
  end;
end;

constructor TDCTextCellEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;
  _editor := DataControlClassFactory.CreateEdit(nil);

  var cell_Settings: ITextSettings;
  var edit_Settings: ITextSettings;

  if Interfaces.Supports<ITextSettings>(_cell.InfoControl, cell_settings) and Interfaces.Supports<ITextSettings>(_editor, edit_settings) then
  begin
    if cell_settings.TextSettings.WordWrap then
    begin
      edit_Settings.TextSettings.WordWrap := True;

      // check if only 1 line is needed, or multiple
      var startWithOneLine := _cell.Control.Width > TextControlWidth(_cell.InfoControl.Control, cell_settings.TextSettings, (_cell.InfoControl as ICaption).Text);

      if startWithOneLine then
        edit_Settings.TextSettings.VertAlign := TTextAlign.Center else
        edit_Settings.TextSettings.VertAlign := TTextAlign.Trailing;
    end;
  end;
end;

function TDCTextCellEditor.TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;
begin
  Result := UserKey <> nil;

  if Result then
  begin
    _originalValue := OriginalValue;
    _originalValueSet := True;

    BeginEdit(UserKey, False);
  end;
end;

{ TDCCellDateTimeEditor }
constructor TDCCellDateTimeEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;
  _editor := DataControlClassFactory.CreateDateEdit(nil);
end;

procedure TDCCellDateTimeEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean = True);
begin
  inherited;
  DropDown;

  SetCustomValue(EditValue);
end;

procedure TDCCellDateTimeEditor.Dropdown;
begin
  var de: IDateEditControl;
  if Interfaces.Supports<IDateEditControl>(_editor, de) then
    de.OpenPicker;
end;

{ TDCCellDropDownEditor }
constructor TDCCellDropDownEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;
  _editor := DataControlClassFactory.CreateComboEdit(nil);
end;

procedure TDCCellDropDownEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean = True);
begin
  inherited;
  DropDown;

  SetCustomValue(EditValue);
end;

function TDCCellDropDownEditor.TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;
begin
  Result := not CString.IsNullOrEmpty(UserKey);
  if Result then
  begin
    BeginEdit(OriginalValue, False);

    var ce: IComboEditControl;
    if Interfaces.Supports<IComboEditControl>(_editor, ce) then
      ce.Text := UserKey;
  end;
end;

procedure TDCCellDropDownEditor.DropDown;
begin
  var ce: IComboEditControl;
  if Interfaces.Supports<IComboEditControl>(_editor, ce) then
    ce.DropDown;
end;

{ TObjectListModelItemChangedDelegate }

procedure TObjectListModelItemChangedDelegate.Added(const Value: CObject; const Index: Integer);
begin
end;

procedure TObjectListModelItemChangedDelegate.AddingNew(const Value: CObject; var Index: Integer; Position: InsertPosition);
begin
  _Owner.OnItemAddedByUser(Value, Index);
end;

procedure TObjectListModelItemChangedDelegate.Removed(const Value: CObject; const Index: Integer);
begin
  _Owner.OnItemRemovedByUser(Value, Index)
end;

procedure TObjectListModelItemChangedDelegate.SetItemInCurrentView(const DataItem: CObject);
begin
  if (_UpdateCount <> 0) or (_Owner.View = nil) then
    Exit;

  if _Owner.View.HasCustomDataList then
    _Owner.View.RecreateCustomDataList(_Owner.Model.Context);

  var current: IDCRow := nil;
  var row: IDCRow;
  for row in _Owner.View.ActiveViewRows do
    if CObject.Equals(_Owner.ConvertToDataItem(row.DataItem), DataItem) then
    begin
      // Changed item is a clone..
      var drv: IDataRowView;
      if interfaces.Supports<IDataRowView>(row.DataItem, drv) then
        drv.Row.Data := DataItem else
        row.DataItem := DataItem;

      Exit;
    end;
end;

procedure TObjectListModelItemChangedDelegate.BeginEdit(const Item: CObject);
begin
  SetItemInCurrentView(Item);
end;

procedure TObjectListModelItemChangedDelegate.BeginUpdate;
begin
  inc(_UpdateCount);
end;

procedure TObjectListModelItemChangedDelegate.CancelEdit(const Item: CObject);
begin
  var cancelHandled: Boolean := False;
  if (_UpdateCount = 0) and _owner.IsEditOrNew then
  begin
    _Owner.CancelEditFromExternal;
    cancelHandled := True;
  end;

  SetItemInCurrentView(Item);

  if not cancelHandled then
    _Owner.DoDataItemChangedInternal(Item);
end;

constructor TObjectListModelItemChangedDelegate.Create(const AOwner: TScrollControlWithEditableCells);
begin
  _Owner := AOwner;
end;

procedure TObjectListModelItemChangedDelegate.EndEdit(const Item: CObject);
begin
  SetItemInCurrentView(Item);
  if (_UpdateCount = 0) then
    _Owner.EndEditFromExternal;
end;

procedure TObjectListModelItemChangedDelegate.EndUpdate;
begin
  dec(_UpdateCount);
end;

{ TDCCheckBoxCellEditor }
constructor TDCCheckBoxCellEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;
  _editor := DataControlClassFactory.CreateCheckBox(nil);
end;

procedure TDCCheckBoxCellEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean);
begin
  inherited;
  SetCustomValue(EditValue);
end;

function TDCCheckBoxCellEditor.TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;
begin
  Result := UserKey = ' ';

  var b: Boolean;
  if Result and OriginalValue.TryGetValue<Boolean>(b) then
  begin
    _originalValue := OriginalValue;
    _originalValueSet := True;

    BeginEdit(not b, False);
  end;
end;
{ TDCCustomCellEditor }

constructor TDCCustomCellEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell; const Editor: IDCEditControl);
begin
  inherited Create(EditorHandler, Cell);
  _editor := Editor;
end;

{ TDCCellMultiSelectDropDownEditor }

procedure TDCCellMultiSelectDropDownEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean);
begin
  {$IFNDEF WEBASSEMBLY}
  inherited;

  TComboMultiBox(_editor.Control).SelectedItems := EditValue.AsType<IList>;

  Dropdown;
  {$ENDIF}
end;

constructor TDCCellMultiSelectDropDownEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;

  _editor := TComboMultiBox.Create(nil);
  TComboMultiBox(_editor.Control).DropDownClosed := DropDownClosed;
end;

procedure TDCCellMultiSelectDropDownEditor.Dropdown;
begin
  {$IFNDEF WEBASSEMBLY}
  TComboMultiBox(_editor.Control).DropDown;
  {$ENDIF}
end;

procedure TDCCellMultiSelectDropDownEditor.DropDownClosed;
begin
  inherited OnEditorExit(nil);
end;

function TDCCellMultiSelectDropDownEditor.get_PickList: IList;
begin
  Result := TComboMultiBox(_editor.Control).Items;
end;

function TDCCellMultiSelectDropDownEditor.get_Value: CObject;
begin
  {$IFNDEF WEBASSEMBLY}
  Result := TComboMultiBox(_editor.Control).SelectedItems;
  {$ENDIF}
end;

procedure TDCCellMultiSelectDropDownEditor.OnEditorExit(Sender: TObject);
begin
  // do nothing!
//  inherited;
end;

procedure TDCCellMultiSelectDropDownEditor.set_PickList(const Value: IList);
begin
  TComboMultiBox(_editor.Control).Items := Value;
end;

procedure TDCCellMultiSelectDropDownEditor.set_Value(const Value: CObject);
begin
  {$IFNDEF WEBASSEMBLY}
  TComboMultiBox(_editor.Control).SelectedItems := Value.AsType<IList>;
  {$ENDIF}
end;

{ TDCTextCellMultilineEditor }

procedure TDCTextCellMultilineEditor.BeginEdit(const EditValue: CObject; SelectAll: Boolean);
begin
  inherited;
  SetCustomValue(EditValue);

  var ta: ITextActions;
  if Interfaces.Supports<ITextActions>(_editor, ta) then
  begin
    if SelectAll then
      ta.SelectAll else
      ta.GoToTextEnd;
  end;
end;

constructor TDCTextCellMultilineEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell);
begin
  inherited;
  _editor := DataControlClassFactory.CreateMemo(nil);

  var cell_Settings: ITextSettings;
  var edit_Settings: ITextSettings;

  if Interfaces.Supports<ITextSettings>(_cell.InfoControl, cell_settings) and Interfaces.Supports<ITextSettings>(_editor, edit_settings) then
  begin
    if cell_settings.TextSettings.WordWrap then
    begin
      edit_Settings.TextSettings.WordWrap := True;

      // check if only 1 line is needed, or multiple
      var startWithOneLine := _cell.Control.Width > TextControlWidth(_cell.InfoControl.Control, cell_settings.TextSettings, (_cell.InfoControl as ICaption).Text);

      if startWithOneLine then
        edit_Settings.TextSettings.VertAlign := TTextAlign.Center else
        edit_Settings.TextSettings.VertAlign := TTextAlign.Trailing;
    end;
  end;
end;

function TDCTextCellMultilineEditor.get_IsMultiLine: Boolean;
begin
  Result := True;
end;

function TDCTextCellMultilineEditor.TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;
begin
  Result := UserKey <> nil;

  if Result then
  begin
    _originalValue := OriginalValue;
    _originalValueSet := True;

    BeginEdit(UserKey, False);
  end;
end;

end.
