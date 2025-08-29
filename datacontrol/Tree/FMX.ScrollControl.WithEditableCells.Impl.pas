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
  Wasm.System.ComponentModel,
  {$ENDIF}
  System_,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.WithEditableCells.Intf, ADato.ObjectModel.TrackInterfaces,
  System.ComponentModel, ADato.InsertPosition, FMX.ScrollControl.WithCells.Intf,
  System.Collections, ADato.ObjectModel.List.intf, System.Collections.Generic,
  FMX.ScrollControl.WithRows.Intf,
  FMX.ScrollControl.Events, ADato.Data.DataModel.intf;

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
    procedure SetSingleSelectionIfNotExists; override;
    procedure InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False); override;

    function  CanRealignContent: Boolean; override;
    function  CanEditCell(const Cell: IDCTreeCell): Boolean;

    procedure ShowEditor(const Cell: IDCTreeCell; const StartEditArgs: DCStartEditEventArgs; const UserValue: string = '');
    procedure HideEditor;

    function  TryAddRow(const Position: InsertPosition): Boolean;
    function  TryDeleteSelectedRows: Boolean;
    function  CheckCanChangeRow: Boolean;

  // editor behaviour
  protected
    _tempCachedEditingColumnCustomWidth: Single;
    procedure UpdateMinColumnWidthOnShowEditor(const Cell: IDCTreeCell; const MinColumnWidth: Single);
    procedure ResetColumnWidthOnHideEditor(const Column: IDCTreeColumn);

  // checkbox behaviour
  protected
//    _checkBoxUpdateCount: Integer;
    procedure LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const FlatColumn: IDCTreeLayoutColumn; const IsSubProp: Boolean); override;
    function  ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject; override;

    procedure OnPropertyCheckBoxChange(Sender: TObject);

    procedure UpdateColumnCheck(const DataIndex: Integer; const Column: IDCTreeColumn; IsChecked: Boolean); overload;
    procedure DoCellCheckChangedByUser(const Cell: IDCTreeCell); overload;

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
    procedure OnEditorKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure OnEditorExit;

    procedure StartEditCell(const Cell: IDCTreeCell; const UserValue: string = '');
    function  EndEditCell: Boolean;
    procedure SafeForcedEndEdit;

    function  DoEditRowStart(const ARow: IDCTreeRow; var DataItem: CObject; IsNew: Boolean) : Boolean;
    function  DoEditRowEnd(const ARow: IDCTreeRow): Boolean;
    function  DoCellParsing(const Cell: IDCTreeCell; IsCheckOnEndEdit: Boolean; var AValue: CObject): Boolean;

    function  DoAddingNew(out NewObject: CObject) : Boolean;
    function  DoUserDeletingRow(const Item: CObject) : Boolean;
    procedure DoUserDeletedRow;

    function  DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean; override;
    procedure FollowCheckThroughChildren(const Cell: IDCTreeCell);
    procedure TryCheckParentIfAllSelected(const ParentDrv: IDataRowView; const ColumnCheckedItems: List<Integer>);

  public
    procedure EndEditFromExternal;
    procedure CancelEditFromExternal;

    procedure CancelEdit(CellOnly: Boolean = False); // canceling is difficult to only do the cell
    function  EditActiveCell(SetFocus: Boolean; const UserValue: string = ''): Boolean;

  public
    constructor Create(AOwner: TComponent); override;

    function  IsEdit: Boolean;
    function  IsNew: Boolean;
    function  IsEditOrNew: Boolean;

    function  CopyToClipBoard: Boolean; virtual;
    function  PasteFromClipBoard: Boolean; virtual;
    function  TrySelectCheckBoxes: Boolean; virtual;

    property EditingInfo: ITreeEditingInfo read _editingInfo;
    property CellEditor: IDCCellEditor read _cellEditor;

  published
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
    _editor: TControl;
    _originalValue: CObject;

    function  get_Cell: IDCTreeCell;
    function  get_ContainsFocus: Boolean;
    function  get_Modified: Boolean;
    function  get_Value: CObject; virtual; abstract;
    procedure set_Value(const Value: CObject); virtual; abstract;
    function  get_OriginalValue: CObject;
    function  get_Editor: TControl;

    function  ParseValue(var AValue: CObject): Boolean;

    procedure OnEditorExit(Sender: TObject);
    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;

  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell); reintroduce;
    destructor Destroy; override;

    procedure BeginEdit(const EditValue: CObject); virtual;
    procedure EndEdit; virtual;

    function TryBeginEditWithUserKey(UserKey: string): Boolean; virtual;
  end;

  TDCCustomCellEditor = class(TDCCellEditor)
  protected
    _val: CObject;

    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;
  public
    constructor Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell; const Editor: TControl); reintroduce;
  end;

  TDCCheckBoxCellEditor = class(TDCCellEditor)
  protected
    _Value: CObject;
//    _standAloneCheckbox: Boolean;

    _originalOnChange: TNotifyEvent;

    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    procedure OnCheckBoxCellEditorChangeTracking(Sender: TObject);
    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
  public
    destructor Destroy; override;

    procedure BeginEdit(const EditValue: CObject); override;
  end;

  TDCTextCellEditor = class(TDCCellEditor)
  private
    _Value: CObject;

  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    procedure OnTextCellEditorChangeTracking(Sender: TObject);

    procedure InternalBeginEdit(const EditValue: CObject);
    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;

  public
    procedure BeginEdit(const EditValue: CObject); override;
    function  TryBeginEditWithUserKey(UserKey: string): Boolean; override;
  end;

  TDCTextCellMultilineEditor = class(TDCCellEditor)
  protected
    _Value: CObject;

    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    procedure OnTextCellEditorChangeTracking(Sender: TObject);

    procedure InternalBeginEdit(const EditValue: CObject);
    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
  public
    procedure BeginEdit(const EditValue: CObject); override;
    function  TryBeginEditWithUserKey(UserKey: string): Boolean; override;
  end;

  TDCCellDateTimeEditor = class(TDCCellEditor)
  private
    _ValueChanged: Boolean;
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    procedure OnDateTimeEditorOpen(Sender: TObject);
    procedure OnDateTimeEditorChange(Sender: TObject);

    procedure Dropdown;
  public
    procedure BeginEdit(const EditValue: CObject); override;
    property ValueChanged: Boolean read _ValueChanged write _ValueChanged;
  end;

  TDCCellDropDownEditor = class(TDCCellEditor, IPickListSupport)
  private
    _PickList: IList;
    _Value: CObject;
    _saveData: Boolean;
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);

    procedure OnDropDownEditorClose(Sender: TObject);
    procedure OnDropDownEditorOpen(Sender: TObject);
    procedure OnDropdownEditorChange(Sender: TObject);

    procedure Dropdown;

    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
  public
    procedure BeginEdit(const EditValue: CObject); override;

//    function  TryBeginEditWithUserKey(UserKey: string): Boolean; override;

    property PickList: IList read get_PickList write set_PickList;
    property SaveData: Boolean read _saveData write _saveData;
  end;

  TDCCellMultiSelectDropDownEditor = class(TDCCellEditor, IPickListSupport)
  private
    _PickList: IList;
    _saveData: Boolean;
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);

    procedure Dropdown;

//    procedure OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
  public
    procedure BeginEdit(const EditValue: CObject); override;

//    function  TryBeginEditWithUserKey(UserKey: string): Boolean; override;

    property PickList: IList read get_PickList write set_PickList;
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
  FMX.ScrollControl.ControlClasses,
  FMX.ControlCalculations,
  ADato.Collections.Specialized,
  System.Reflection,
  System.TypInfo, ADato.FMX.ComboMultiBox;

{ TScrollControlWithEditableCells }

constructor TScrollControlWithEditableCells.Create(AOwner: TComponent);
begin
  inherited;
  _editingInfo := TTreeEditingInfo.Create;
  _tempCachedEditingColumnCustomWidth := -1;
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

  var dummyOldRow := CreateDummyRowForChanging(_selectionInfo) as IDCTreeRow;
  if dummyOldRow = nil then Exit(True);

  var oldCell := dummyOldRow.Cells[(_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn];
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

    if (Key = vkDown) and not (ssCtrl in Shift) and not (ssShift in Shift) and (_view <> nil) and (Self.Current = _view.ViewCount - 1) then
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
      StartEditCell(GetActiveCell)
    else if Key = vkReturn then
      EndEditCell;

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
    if CheckCanChangeRow and TryAddRow(InsertPosition.After) then
      Key := 0;
  end

  // check delete edit
  else if (Key = vkDelete) and (ssCtrl in Shift) and (TDCTreeOption.AllowDeleteRows in _options) then
  begin
    if CheckCanChangeRow and TryDeleteSelectedRows then
      Key := 0;
  end

  // else inherited
  else
  begin
    if ssAlt in Shift then
      Exit;

    if Key <> 0 then
    begin
      if (Key in [vkUp, vkDown, vkPrior, vkEnd, vkTab]) and IsEditOrNew then
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
    if KeyChar.IsLetterOrDigit then
    begin
      if CanEditCell(GetActiveCell) then
      begin
        StartEditCell(GetActiveCell, KeyChar);
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

procedure TScrollControlWithEditableCells.LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const FlatColumn: IDCTreeLayoutColumn; const IsSubProp: Boolean);
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

      if Cell.Column.HasPropertyAttached then
        UpdateColumnCheck(cell.Row.DataIndex, Cell.Column, chkCtrl.IsChecked);

      ctrl.Tag := Cell.Row.ViewListIndex;

      {$IFNDEF WEBASSEMBLY}
      if ctrl is TCheckBox then
        (ctrl as TCheckBox).OnChange := OnPropertyCheckBoxChange else
        (ctrl as TRadioButton).OnChange := OnPropertyCheckBoxChange;
      {$ELSE}
      if ctrl is TCheckBox then
        (ctrl as TCheckBox).OnChange := @OnPropertyCheckBoxChange else
        (ctrl as TRadioButton).OnChange := @OnPropertyCheckBoxChange;
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

  UpdateColumnCheck(cell.Row.DataIndex, Cell.Column, checkBox.IsChecked);

  if not CString.IsNullOrEmpty(Cell.Column.PropertyName) then
  begin
    SetCellData(cell, checkBox.IsChecked);

    if (_model <> nil) and CObject.Equals(item, Cell.Row.DataItem) then
      _model.ObjectModelContext.UpdatePropertyBindingValues;

//    DoDataItemChangedInternal(item);
  end;

  var checkChangeArgs: DCCheckChangedEventArgs;
  if Assigned(_cellCheckChanged) then
  begin
    AutoObject.Guard(DCCheckChangedEventArgs.Create(Cell), checkChangeArgs);
    _cellCheckChanged(Self, checkChangeArgs);

    if checkChangeArgs.DoFollowCheckThroughChildren then
      FollowCheckThroughChildren(Cell);
  end;
end;

procedure TScrollControlWithEditableCells.OnPropertyCheckBoxChange(Sender: TObject);
begin
  if Self.IsUpdating or (_updateCount > 0) then
    Exit;

  var cell := GetCellByControl(Sender as TControl);

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Internal;

  var requestedSelection := _selectionInfo.Clone as ITreeSelectionInfo;
  requestedSelection.UpdateLastSelection(cell.Row.DataIndex, cell.Row.ViewListIndex, cell.Row.DataItem);
  requestedSelection.SelectedLayoutColumn := FlatColumnByColumn(cell.Column).Index;

  if TrySelectItem(requestedSelection, []) then
  begin
    var IHadFocus := Self.IsFocused;

    cell := GetActiveCell;
    if not CString.IsNullOrEmpty(cell.Column.PropertyName) and not _editingInfo.RowIsEditing then
    begin
      var dataItem := Cell.Row.DataItem;
      if not DoEditRowStart(Cell.Row as IDCTreeRow, {var} dataItem, False) then
      begin
        if IHadFocus then
          Self.SetFocus;
        Exit;
      end;
    end;

    DoCellCheckChangedByUser(cell);

    if IHadFocus then
      Self.SetFocus;
  end;
end;

procedure TScrollControlWithEditableCells.OnEditorExit;
begin
  // windows wants to clear the focus control after this point
  // therefor we need a little time untill we can EndEdit and free the editor
  TThread.ForceQueue(nil, procedure
  begin
    SafeForcedEndEdit;
  end);
end;

procedure TScrollControlWithEditableCells.OnEditorKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkEscape) then
  begin
    CancelEdit;
    Self.SetFocus;

    Key := 0;
  end
  else if Key = vkReturn then
  begin
    SafeForcedEndEdit;
    Self.SetFocus;

    Key := 0;
  end
  else if (Key in [vkUp, vkDown]) and EndEditCell then
  begin
    var crr := Self.Current;
    if not DoEditRowEnd(GetActiveRow as IDCTreeRow) then
      Exit;

    if Key = vkUp then
      Self.Current := CMath.Max(crr-1, 0) else
      Self.Current := CMath.Min(crr+1, _view.ViewCount-1);

    Self.SetFocus;
    Key := 0;
  end;
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
  var ix := _view.OriginalData.IndexOf(DataItem);
  if ix <> -1 then
    UpdateColumnCheck(ix, Column, IsChecked);
end;

procedure TScrollControlWithEditableCells.UpdateMinColumnWidthOnShowEditor(const Cell: IDCTreeCell; const MinColumnWidth: Single);
begin
  if (Cell.COlumn.InfoControlClass <> TInfoControlClass.CheckBox) and (Cell.LayoutColumn.Width < MinColumnWidth) then
  begin
    _tempCachedEditingColumnCustomWidth := Cell.Column.CustomWidth;
    Cell.Column.CustomWidth := MinColumnWidth;

    FastColumnAlignAfterColumnChange;
  end else
    _tempCachedEditingColumnCustomWidth := -1;
end;

procedure TScrollControlWithEditableCells.ResetColumnWidthOnHideEditor(const Column: IDCTreeColumn);
begin
  if not SameValue(_tempCachedEditingColumnCustomWidth, Column.CustomWidth) then
  begin
    Column.CustomWidth := _tempCachedEditingColumnCustomWidth;
    _tempCachedEditingColumnCustomWidth := -1;

    FastColumnAlignAfterColumnChange;
  end;
end;

procedure TScrollControlWithEditableCells.ResetView(const FromViewListIndex: Integer; ClearOneRowOnly: Boolean);
begin
  if not IsEditOrNew then
  begin
    inherited;
    Exit;
  end;

  _resetViewRec := TResetViewRec.CreateFrom(FromViewListIndex, ClearOneRowOnly, True, _resetViewRec);
end;

procedure TScrollControlWithEditableCells.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var clickedRow := GetRowByLocalY(Y);
  if clickedRow = nil then Exit;

  var crrntCell := GetActiveCell;
  if IsEditOrNew and not CObject.Equals(_editingInfo.EditItem, clickedRow.DataItem) then
  begin
    var clickedRowDataIndex := clickedRow.DataIndex;
    if not CheckCanChangeRow then
      Exit;

    var filteredOut := _view.ItemIsFilteredOut(_editingInfo.EditItem);
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

  // check if row change came through if it was needed
  var newCell := GetActiveCell;
  if (newCell <> nil) and (newCell.Row = clickedRow) and not newCell.Column.ReadOnly then
  begin
    if not newCell.Column.IsSelectionColumn and (newCell.Column.InfoControlClass = TInfoControlClass.CheckBox) then
    begin
      if (ssShift in Shift) or (ssCtrl in Shift) then
        Exit; // do nothing

      (newCell.InfoControl as IIsChecked).IsChecked := not (newCell.InfoControl as IIsChecked).IsChecked;
    end
    else if (ssDouble in Shift) and not _editingInfo.CellIsEditing then
      StartEditCell(newCell);
  end;
end;

procedure TScrollControlWithEditableCells.StartEditCell(const Cell: IDCTreeCell; const UserValue: string = '');
begin
  // row can be in edit mode already, but cell should not be in edit mode yet
  if (Cell = nil) or Cell.Column.ReadOnly or (TDCTreeOption.ReadOnly in _options) then
    Exit;

  Assert(not _editingInfo.CellIsEditing);

  if not _editingInfo.RowIsEditing then
  begin
    _selectionInfo.ClearMultiSelections;

    var dataItem := Self.DataItem;
    var isNew := False;
    if not DoEditRowStart(Cell.Row as IDCTreeRow, {var} dataItem, isNew) then
      Exit;
  end;

  var formatApplied: Boolean;
  var cellValue := Cell.Column.ProvideCellData(cell, cell.Column.PropertyName);
  DoCellFormatting(cell, True, {var} cellValue, {out} formatApplied);

  var startEditArgs: DCStartEditEventArgs;
  AutoObject.Guard(DCStartEditEventArgs.Create(Cell, cellValue), startEditArgs);

  startEditArgs.AllowEditing := True;
  if Assigned(_editCellStart) then
    _editCellStart(Self, startEditArgs);

  if startEditArgs.AllowEditing then
  begin
    _editingInfo.StartCellEdit(Cell.Row.DataIndex, FlatColumnByColumn(Cell.Column).Index);

    ShowEditor(Cell, startEditArgs, UserValue);
  end;
end;

function TScrollControlWithEditableCells.TryAddRow(const Position: InsertPosition): Boolean;
begin
  Assert(not _editingInfo.RowIsEditing);

  var em: IEditableModel;
  if (_model <> nil) and interfaces.Supports<IEditableModel>(_model, em) and em.CanAdd then
  begin
    em.AddNew(Self.Current, InsertPosition.After);
    Exit(True);
  end;

  var newItem: CObject := nil;
  if not DoAddingNew({out} newItem) then
    Exit(False);

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

    // make sure ViewChanged is not called at this point
    var dataRow: IDataRow;
    inc(_updateCount);
    try
//      if NewItem <> nil then
//        dataRow := GetDataModelView.DataModel.Add(NewItem, location, Position) else
        dataRow := GetDataModelView.DataModel.AddNew(location, Position);
    finally
      dec(_updateCount);
    end;

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
//        newViewListIndex := drv.ViewIndex;

        GetDataModelView.Refresh;
        ResetView;
      end;
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
    // let the view know that we started with editing
    _view.StartEdit(_editingInfo.EditItem);

//    CalculateScrollBarMax;

    Self.DataItem := newDataItem;
//    _forceCurrentIntoView := True;
//    var requestedSelection := _selectionInfo.Clone as ITreeSelectionInfo;
//    requestedSelection.UpdateLastSelection(newDataIndex, newViewListIndex, newDataItem);
//    ScrollSelectedIntoView(requestedSelection);
//
//    for var row in _view.ActiveViewRows do
//      VisualizeRowSelection(row);
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

  var dataIndexes: List<Integer> := CList<Integer>.Create(_selectionInfo.SelectedDataIndexes);
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
      Self.Current := CMath.Max(0, CMath.Min(_view.ViewCount -1, currentIndex)) else
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
      Exit;
    end
    else if wasNew then // remove item from list
      TryDeleteSelectedRows;
  end;

  DoDataItemChangedInternal(GetActiveRow.DataItem); //, GetActiveRow.DataIndex);
end;

function TScrollControlWithEditableCells.EditActiveCell(SetFocus: Boolean; const UserValue: string = ''): Boolean;
begin
  StartEditCell(GetActiveCell, UserValue);

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
  Result := inherited;

  if (Result = nil) and IsNew and (_cellEditor <> nil) and (_cellEditor.Cell = Cell) then
    Result := _cellEditor.Value;
end;

function TScrollControlWithEditableCells.EndEditCell: Boolean;
begin
  // stop cell editing
  if _editingInfo.CellIsEditing then
  begin
    var EditRowEnd := False;

    var val := _cellEditor.Value;
    var cell := _cellEditor.Cell;

    if not DoCellParsing(cell, True, {var} val) then
    begin
      CancelEdit(True);
      Exit(False);
    end else
      _cellEditor.Value := val;

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
      LoadDefaultDataIntoControl(cell, cell.LayoutColumn, False);
    end;

    _editingInfo.CellEditingFinished;

    var row := cell.Row as IDCTreeRow;
    HideEditor;

    // reset width of the cell
    if row.ContentCellSizes.ContainsKey(cell.Index) then
      row.ContentCellSizes.Remove(cell.Index);

    DoDataItemChangedInternal(row.DataItem);

    if EditRowEnd then
      Exit(DoEditRowEnd(row));
  end;

  Result := True;
end;

procedure TScrollControlWithEditableCells.CancelEditFromExternal;
begin
  if (_internalSelectCount > 0) or not IsEditOrNew then
    Exit;

  var crrCell := GetActiveCell;

  if (crrCell = nil) or _editingInfo.CellIsEditing then
  begin
    _editingInfo.CellEditingFinished;
    HideEditor;
  end;

  _view.EndEdit;
  _editingInfo.RowEditingFinished;

  DoDataItemChangedInternal(GetActiveRow.DataItem); //, GetActiveRow.DataIndex);
end;

function TScrollControlWithEditableCells.CanEditCell(const Cell: IDCTreeCell): Boolean;
begin
  Result := not Cell.Column.ReadOnly and not (TDCTreeOption.ReadOnly in _options);
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

  if _editingInfo.RowIsEditing then
    DoEditRowEnd(crrCell.Row as IDCTreeRow);
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

procedure TScrollControlWithEditableCells.ShowEditor(const Cell: IDCTreeCell; const StartEditArgs: DCStartEditEventArgs; const UserValue: string = '');
var
  dataType: &Type;
begin
  Assert(_cellEditor = nil);

  UpdateMinColumnWidthOnShowEditor(Cell, startEditArgs.MinEditorWidth);

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

    (_cellEditor as IPickListSupport).PickList := StartEditArgs.PickList;
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
  end;

  if not _CellEditor.TryBeginEditWithUserKey(UserValue) then
    _cellEditor.BeginEdit(StartEditArgs.Value);
end;

procedure TScrollControlWithEditableCells.HideEditor;
begin
  var clmn := _cellEditor.Cell.Column;

  _cellEditor := nil;

  ResetColumnWidthOnHideEditor(clmn);

  var activeCell := GetActiveCell;
  if activeCell = nil then Exit; // cell scrolled out of view

  activeCell.InfoControl.Visible := True;
end;

procedure TScrollControlWithEditableCells.InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean);
begin
  Assert(CanRealignContent);

  if IsNew then
  begin
    var ix := _view.GetViewListIndex(_editingInfo.EditItemDataIndex);

    _selectionInfo.BeginUpdate;
    try
      _selectionInfo.UpdateSingleSelection(_editingInfo.EditItemDataIndex, ix, _editingInfo.EditItem);
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
    if not EndEditCell then
      Exit(False);

    // stop row editing
    var goToNewRow := (NewCell = nil) or (OldCell.Row.DataIndex <> NewCell.Row.DataIndex);
    if goToNewRow and not DoEditRowEnd(OldCell.Row as IDCTreeRow) then
      Exit(False);
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

  if (checkCell = nil) or (checkCell.InfoControl = nil) or not checkCell.InfoControl.Visible or ((checkCell.InfoControl as TCheckBox).IsChecked = IsChecked) then
    Exit;

  inc(_updateCount);
  try
    (checkCell.InfoControl as TCheckBox).IsChecked := IsChecked;
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

function TScrollControlWithEditableCells.DoEditRowEnd(const ARow: IDCTreeRow): Boolean;
var
  rowEditArgs: DCRowEditEventArgs;

begin
  if not _editingInfo.RowIsEditing then
    Exit(True); // already done in DoEditCellEnd

  Result := True;
  if Assigned(_editRowEnd) then
  begin
    AutoObject.Guard(DCRowEditEventArgs.Create(ARow, _editingInfo.EditItem, not _editingInfo.IsNew), rowEditArgs);
    _editRowEnd(Self, rowEditArgs);
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

    // it can be that the EditRowStart is activated by user event that triggers this EditRowEnd
    // for excample by clicking a checkbox on a next row or inserting a new row by "INSERT"
    // therefor we have to wait a little
    TThread.ForceQueue(nil, procedure
    begin
      if not IsEditOrNew then
        DoDataItemChanged(editItem, dataIndex);
    end);
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
    if not EndEditCell then
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
          var prop := _editingInfo.EditItem.GetType.PropertyByName(Cell.Column.PropertyName);
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

procedure TScrollControlWithEditableCells.SetSingleSelectionIfNotExists;
begin
//  if IsNew then
//    Exit;

  if _selectionInfo.HasSelection and IsEdit then
    Exit;

  Assert(not IsEdit);

  inherited;
end;

{ TTreeEditingInfo }

constructor TTreeEditingInfo.Create;
begin
  _dataIndex := -1;
  _flatColumnIndex := -1;
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

function TDCCellEditor.TryBeginEditWithUserKey(UserKey: string): Boolean;
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
  if _editor <> nil then
  begin
    _editor.OnKeyDown := nil;
    _editor.OnExit := nil;

    // TODO: _editor is already being destroyed at this point
    _editor.Free;
  end;

  inherited;
end;

procedure TDCCellEditor.BeginEdit(const EditValue: CObject);
begin
  _editor.Position.X := _cell.InfoControl.Position.X - ROW_CONTENT_MARGIN;
  _editor.Position.Y := _cell.InfoControl.Position.Y - ROW_CONTENT_MARGIN;
  _editor.Width := _cell.InfoControl.Width + (2*ROW_CONTENT_MARGIN);
  _editor.Height := _cell.InfoControl.Height + (2*ROW_CONTENT_MARGIN);

  _cell.InfoControl.Visible := False;

  // otherwise
  if not (Self is TDCCellDropDownEditor) then
  begin
    {$IFNDEF WEBASSEMBLY}
    _editor.OnKeyDown := OnEditorKeyDown;
    _editor.OnExit := OnEditorExit;
    {$ELSE}
    _editor.OnKeyDown := @OnEditorKeyDown;
    _editor.OnExit := @OnEditorExit;
    {$ENDIF}
  end;

  _cell.Control.AddObject(_editor);

  _OriginalValue := EditValue;

  set_Value(EditValue);
  _editor.SetFocus;
end;

procedure TDCCellEditor.EndEdit;
begin
// TODO
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
  Result := _editor;
end;

function TDCCellEditor.get_Modified: Boolean;
begin
  if Self is TDCCellDateTimeEditor then
    Result := TDCCellDateTimeEditor(Self).ValueChanged
  else if Self is TDCCellDropDownEditor then
    Result := TDCCellDropDownEditor(Self).SaveData
	else
    Result := not CObject.Equals(_OriginalValue, get_Value);
end;

function TDCCellEditor.get_OriginalValue: CObject;
begin
  Result := _OriginalValue;
end;

procedure TDCCellEditor.OnEditorExit(Sender: TObject);
begin
  _editorHandler.OnEditorExit;
end;

procedure TDCCellEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  _editorHandler.OnEditorKeyDown(Key, KeyChar, Shift);
end;

function TDCCellEditor.ParseValue(var AValue: CObject): Boolean;
begin
  Result := _editorHandler.DoCellParsing(_cell, False, AValue);
end;

//procedure TDCCellEditor.set_Value(const Value: CObject);
//begin
//  var valueParsed := Value;
//  ParseValue(valueParsed);
//end;

{ TDCTextCellEditor }

procedure TDCTextCellEditor.BeginEdit(const EditValue: CObject);
begin
  InternalBeginEdit(EditValue);

  var settings: ITextSettings;
  var ed := TEdit(_editor);

  ed.TextSettings.WordWrap := Interfaces.Supports<ITextSettings>(_cell.InfoControl, settings) and settings.TextSettings.WordWrap;
  if ed.TextSettings.WordWrap then
  begin
    // check if only 1 line is needed, or multiple
    var startWithOneLine := _cell.Control.Width > TextControlWidth(_cell.InfoControl, settings.TextSettings, (_cell.InfoControl as ICaption).Text);

    if startWithOneLine then
      ed.TextSettings.VertAlign := TTextAlign.Center else
      ed.TextSettings.VertAlign := TTextAlign.Trailing;
  end;

  ed.SelectAll;
end;

function TDCTextCellEditor.get_Value: CObject;
begin
  if _Value <> nil then
    Result := _Value else
    Result := TEdit(_editor).Text;
end;

procedure TDCTextCellEditor.InternalBeginEdit(const EditValue: CObject);
begin
  // TODO: We say here that Owner is nil, but since we add _editor to control it means
  // when parent control is freed _editor's lifetime is dependant on that control.
  // So trying to free with _editor.Free fails in destroy.
  _editor := DataControlClassFactory.CreateEdit(nil);
  _cell.Control.AddObject(_editor);

  {$IFNDEF WEBASSEMBLY}
  TEdit(_editor).OnChangeTracking := OnTextCellEditorChangeTracking;
  {$ELSE}
  TEdit(_editor).OnChangeTracking := @OnTextCellEditorChangeTracking;
  {$ENDIF}

  inherited BeginEdit(EditValue);
end;

procedure TDCTextCellEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
//  if (Key in [vkUp, vkDown]) then
//  begin
//    // do nothing at all..
//  end else
    inherited;
end;

procedure TDCTextCellEditor.OnTextCellEditorChangeTracking(Sender: TObject);
var
  text: CObject;
begin
  text := TEdit(_editor).Text;

  if ParseValue(text) then
    _Value := text;
end;

procedure TDCTextCellEditor.set_Value(const Value: CObject);
begin
  var val: CObject := Value;
  if not ParseValue(val) then
    val := _originalValue;

  TEdit(_editor).Text := CStringToString(val.ToString(True));
end;

function TDCTextCellEditor.TryBeginEditWithUserKey(UserKey: string): Boolean;
begin
  Result := UserKey <> '';
  if Result then
  begin
    InternalBeginEdit(UserKey);
    TEdit(_editor).GoToTextEnd;
  end;
end;

{ TDCCellDateTimeEditor }

procedure TDCCellDateTimeEditor.BeginEdit(const EditValue: CObject);
begin
  _editor := DataControlClassFactory.CreateDateEdit(nil);
  _cell.Control.AddObject(_editor);

  _editor.TabStop := false;

  {$IFNDEF WEBASSEMBLY}
  TDateEdit(_editor).OnOpenPicker := OnDateTimeEditorOpen;
  TDateEdit(_editor).OnChange := OnDateTimeEditorChange;
  {$ELSE}
  TDateEdit(_editor).OnOpenPicker := @OnDateTimeEditorOpen;
  TDateEdit(_editor).OnChange := @OnDateTimeEditorChange;
  {$ENDIF}

  inherited;
  Dropdown;
end;

procedure TDCCellDateTimeEditor.Dropdown;
begin
  TDateEdit(_editor).OpenPicker;
end;

function TDCCellDateTimeEditor.get_Value: CObject;
begin
  Result := CDateTime(TDateEdit(_editor).Date);
end;

procedure TDCCellDateTimeEditor.OnDateTimeEditorChange(Sender: TObject);
begin
  _ValueChanged := True;
end;

procedure TDCCellDateTimeEditor.OnDateTimeEditorOpen(Sender: TObject);
begin
  _editor.SetFocus;
end;

procedure TDCCellDateTimeEditor.set_Value(const Value: CObject);
var
  date: CDateTime;

begin
  if Value = nil then Exit;

  var val: CObject := Value;
  if not ParseValue(val) then
    val := _originalValue;

  date := CDateTime(val);

  if date.Ticks = 0 then // Zero date
    date := CDateTime.Now;

  TDateEdit(_editor).Date:= date;
end;

{ TDCCellDropDownEditor }

procedure TDCCellDropDownEditor.BeginEdit(const EditValue: CObject);
begin
  _editor := DataControlClassFactory.CreateComboEdit(nil);
  _cell.Control.AddObject(_editor);

  var ce := TComboEdit(_editor);
  ce.DropDownCount := 5;
  ce.ItemHeight := 20; // For some reason if the ItemHeight is at its default value of 0. The dropdown shows a scrollbar unnecessarily.
  {$IFNDEF WEBASSEMBLY}
  ce.OnClosePopup := OnDropDownEditorClose;
  ce.OnPopup := OnDropDownEditorOpen;
  ce.OnChange := OnDropdownEditorChange;
  {$ELSE}
  ce.OnClosePopup := @OnDropDownEditorClose;
  ce.OnPopup := @OnDropDownEditorOpen;
  ce.OnChange := @OnDropdownEditorChange;
  {$ENDIF}

  inherited;

  var val := CStringToString(_originalValue.ToString(True));
  ce.ItemIndex := ce.Items.IndexOf(val);

  Dropdown;
end;

function TDCCellDropDownEditor.get_PickList: IList;
begin
  Result := _PickList;
end;

function TDCCellDropDownEditor.get_Value: CObject;
begin
  var ce := TComboEdit(_editor);
  var index := ce.ItemIndex;
  if index <> -1 then
    _Value := _PickList[index];

  if _Value <> nil then
    Result := _Value;
end;

procedure TDCCellDropDownEditor.OnDropdownEditorChange(Sender: TObject);
begin
  _saveData := TComboEdit(_editor).ItemIndex <> -1;
end;

procedure TDCCellDropDownEditor.OnDropDownEditorClose(Sender: TObject);
var
  Data: CObject;
begin
  if _saveData then
  begin
    var ce := TComboEdit(_editor);

    if ce.ItemIndex <> -1 then
      Data := ce.Items[ce.ItemIndex] else
      Data := nil;

    if ParseValue(Data) then
      _Value := Data;
  end;
end;

procedure TDCCellDropDownEditor.OnDropDownEditorOpen(Sender: TObject);
begin
  _editor.SetFocus;
end;

procedure TDCCellDropDownEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key in [vkUp, vkDown, vkPrior, vkNext, vkHome, vkEnd] then
  begin
    var cb := _editor as TComboEdit;
    case Key of
      vkUp:     cb.ItemIndex := CMath.Max(0, cb.ItemIndex - 1);
      vkDown:   cb.ItemIndex := CMath.Min(cb.Items.Count - 1, cb.ItemIndex + 1);
      vkPrior:  cb.ItemIndex := CMath.Max(0, cb.ItemIndex - 10);
      vkNext:   cb.ItemIndex := CMath.Min(cb.Items.Count - 1, cb.ItemIndex + 10);
      vkHome:   cb.ItemIndex := 0;
      vkEnd:    cb.ItemIndex := cb.Items.Count - 1;
    end;
  end else
    inherited;
end;

procedure TDCCellDropDownEditor.DropDown;
var
  newItemWidth: Single;
begin
  var ce := TComboEdit(_editor);

  newItemWidth := 0;

  var item: string;
  for item in ce.Items do
  begin
    var itemWidth := ce.Canvas.TextWidth(Item);
    if itemWidth > newItemWidth then
      newItemWidth := itemWidth;
  end;

  var comboEditScrollbarPadding := IfThen((ce.Items.Count > ce.DropDownCount), 20, 0);
  var extraPadding := 10; // Padding to compensate for space between item text and border of dropdown area on the left and right.
  ce.ItemWidth := CMath.Max(ce.Width, newItemWidth + comboEditScrollbarPadding + extraPadding);

  if not ce.DroppedDown then
    ce.DropDown;
end;

procedure TDCCellDropDownEditor.set_PickList(const Value: IList);
begin
  _PickList := Value;

  Assert(_editor = nil); // do we need code below?

  // already editing??
  if _editor <> nil then
  begin
    var ce := TComboEdit(_editor);
    ce.Clear;
    var v: CObject;
    for v in Value do
      ce.Items.Add(v.ToString);
  end;
end;

procedure TDCCellDropDownEditor.set_Value(const Value: CObject);
begin
  var val: CObject := Value;
  if not ParseValue(val) then
    val := _originalValue;

  var ce := TComboEdit(_editor);

  ce.Clear;
  var o: CObject;
  for o in _PickList do
    ce.Items.Add(o.ToString);

  var val2 := CStringToString(val.ToString(True));
  var ix := ce.Items.IndexOf(val2);

  if ix <> -1 then
    ce.ItemIndex := ix else
    ce.Text := val2;
end;

//function TDCCellDropDownEditor.TryBeginEditWithUserKey( UserKey: string): Boolean;
//begin
//  var ce := TComboEdit(_editor);
//  ce.DropDown;
//
//  var ix := ce.Items.IndexOf(UserKey);
//  Result := ix <> -1;
//  if Result then
//    ce.ItemIndex := ix;
//end;

{ TDCTextCellMultilineEditor }

procedure TDCTextCellMultilineEditor.BeginEdit(const EditValue: CObject);
begin
  InternalBeginEdit(EditValue);
  TMemo(_editor).SelectAll;
end;

function TDCTextCellMultilineEditor.get_Value: CObject;
begin
  Result := TMemo(_editor).Text;

  if _Value <> nil then
    Result := _Value;
end;

procedure TDCTextCellMultilineEditor.InternalBeginEdit(const EditValue: CObject);
begin
  _editor := DataControlClassFactory.CreateMemo(nil);
  _cell.Control.AddObject(_editor);

  TMemo(_editor).ShowScrollBars := false;
  {$IFNDEF WEBASSEMBLY}
  TMemo(_editor).OnChangeTracking := OnTextCellEditorChangeTracking;
  {$ELSE}
  TMemo(_editor).OnChangeTracking := @OnTextCellEditorChangeTracking;
  {$ENDIF}
  inherited BeginEdit(EditValue);
end;

procedure TDCTextCellMultilineEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
//  if (Key in [vkUp, vkDown]) then
//  begin
//    // do nothing at all..
//  end else
    inherited;
end;

procedure TDCTextCellMultilineEditor.OnTextCellEditorChangeTracking(Sender: TObject);
var
  text: CObject;
begin
  text := TMemo(_editor).Text;

  if ParseValue(text) then
    _Value := text;
end;

procedure TDCTextCellMultilineEditor.set_Value(const Value: CObject);
begin
  var val: CObject := Value;
  if not ParseValue(val) then
    val := _originalValue;

  TMemo(_editor).Text := CStringToString(val.ToString(True));
end;

function TDCTextCellMultilineEditor.TryBeginEditWithUserKey(UserKey: string): Boolean;
begin
  Result := UserKey <> '';
  if Result then
  begin
    InternalBeginEdit(UserKey);
    TMemo(_editor).GoToTextEnd;
  end;
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
  if (_UpdateCount <> 0) then
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
  if (_UpdateCount = 0) then
    _Owner.CancelEditFromExternal;

  SetItemInCurrentView(Item);
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

procedure TDCCheckBoxCellEditor.BeginEdit(const EditValue: CObject);
begin
//  if not _standAloneCheckbox then
//    _editor := ScrollableRowControl_DefaultCheckboxClass.Create(nil) else
    _editor := _cell.InfoControl as TStyledControl;

  _originalOnChange := TCheckBox(_editor).OnChange;

  {$IFNDEF WEBASSEMBLY}
  TCheckBox(_editor).OnChange := OnCheckBoxCellEditorChangeTracking;
  {$ELSE}
  TCheckBox(_editor).OnChange := @OnCheckBoxCellEditorChangeTracking;
  {$ENDIF}
  //inherited;
//
//  set_Value((_cell.InfoControl as TCheckBox).IsChecked);
end;

destructor TDCCheckBoxCellEditor.Destroy;
begin
//  if _standAloneCheckbox then

  TCheckBox(_editor).OnChange := _originalOnChange;
  _editor := nil; // keep it alive in the inherited Destroy

  inherited;
end;

function TDCCheckBoxCellEditor.get_Value: CObject;
begin
  if _Value <> nil then
    Result := _Value else
    Result := TCheckBox(_editor).IsChecked;
end;

procedure TDCCheckBoxCellEditor.OnCheckBoxCellEditorChangeTracking(Sender: TObject);
begin
  var isChecked: CObject := TCheckBox(_editor).IsChecked;
  if ParseValue({var} isChecked) then
    _Value := isChecked;

  if Assigned(_originalOnChange) then
    _originalOnChange(_editor);
end;

procedure TDCCheckBoxCellEditor.OnEditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkSpace then
    (_editor as IISChecked).IsChecked := not (_editor as IISChecked).IsChecked
  else
    inherited;
end;

procedure TDCCheckBoxCellEditor.set_Value(const Value: CObject);
begin
  (_editor as TCheckBox).IsChecked := (Value <> nil) and Value.AsType<Boolean>;
end;

{ TDCCustomCellEditor }

constructor TDCCustomCellEditor.Create(const EditorHandler: IDataControlEditorHandler; const Cell: IDCTreeCell; const Editor: TControl);
begin
  inherited Create(EditorHandler, Cell);
  _editor := Editor;
end;

function TDCCustomCellEditor.get_Value: CObject;
begin
  Result := _val;
end;

procedure TDCCustomCellEditor.set_Value(const Value: CObject);
begin
  _val := Value;
end;

{ TDCCellMultiSelectDropDownEditor }

procedure TDCCellMultiSelectDropDownEditor.BeginEdit(const EditValue: CObject);
begin
  _editor := TComboMultiBox.Create(nil);
  TComboMultiBox(_editor).Items := _PickList;
  TComboMultiBox(_editor).SelectedItems := EditValue.AsType<IList>;
  _cell.Control.AddObject(_editor);

  inherited;

  Dropdown;
end;

procedure TDCCellMultiSelectDropDownEditor.Dropdown;
begin
  TComboMultiBox(_editor).DropDown;
end;

function TDCCellMultiSelectDropDownEditor.get_PickList: IList;
begin
  Result := _PickList;
end;

function TDCCellMultiSelectDropDownEditor.get_Value: CObject;
begin
  Result := TComboMultiBox(_editor).SelectedItems;
end;

procedure TDCCellMultiSelectDropDownEditor.set_PickList(const Value: IList);
begin
  _PickList := Value;
end;

procedure TDCCellMultiSelectDropDownEditor.set_Value(const Value: CObject);
begin
  TComboMultiBox(_editor).SelectedItems := Value.AsType<IList>;
end;

end.
