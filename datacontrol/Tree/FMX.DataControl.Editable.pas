unit FMX.DataControl.Editable;

interface

uses
  System_,
  System.Classes,
  System.UITypes,
  System.SysUtils,

  FMX.DataControl.Static,
  FMX.DataControl.Static.Intf,
  FMX.DataControl.Editable.Intf,
  FMX.DataControl.Events,
  FMX.Objects,
  FMX.Edit,

  ADato.ObjectModel.List.intf,
  ADato.ObjectModel.TrackInterfaces, System.Collections, ADato.InsertPosition,
  System.Collections.Generic, ADato.Data.DataModel.intf,
  FMX.DataControl.ScrollableRowControl.Intf;

type
  TEditableDataControl = class(TStaticDataControl, IDataControlEditorHandler)
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

implementation

uses
  FMX.DataControl.Editable.Impl, System.Character,
  System.ComponentModel,
  FMX.DataControl.ControlClasses, FMX.StdCtrls, System.TypInfo, FMX.Controls,
  System.Math, ADato.Collections.Specialized,
  System.Reflection, FMX.ActnList, FMX.Platform,
  FMX.DataControl.ScrollableRowControl, FMX.Graphics;

{ TEditableDataControl }

constructor TEditableDataControl.Create(AOwner: TComponent);
begin
  inherited;
  _editingInfo := TTreeEditingInfo.Create;
  _tempCachedEditingColumnCustomWidth := -1;
end;

function TEditableDataControl.CheckedItemsInColumn(const Column: IDCTreeColumn): List<CObject>;
begin
  var checkedItems: List<Integer>;
  if not _checkedItems.TryGetValue(Column, checkedItems) or (checkedItems = nil) then
    Exit(nil);

  var orgData := _view.OriginalData;

  Result := CList<CObject>.Create(checkedItems.Count);
  for var dataIndex in checkedItems do
    Result.Add(orgData[dataIndex]);
end;

procedure TEditableDataControl.ClearCheckboxCache(const Column: IDCTreeColumn = nil);
begin
  if _checkedItems = nil then
    Exit;

  if Column = nil then
    _checkedItems.Clear
  else if _checkedItems.ContainsKey(Column) then
    _checkedItems.Remove(Column);
end;

function TEditableDataControl.CanRealignContent: Boolean;
begin
  Result := inherited and not _editingInfo.CellIsEditing;
end;

function TEditableDataControl.CheckCanChangeRow: Boolean;
begin
  // old row can be scrolled out of view. So always work with dummy rows

  var dummyOldRow := CreateDummyRowForChanging(_selectionInfo) as IDCTreeRow;
  if dummyOldRow = nil then Exit(True);

  var oldCell := dummyOldRow.Cells[(_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn];
  Result := DoCellCanChange(oldCell, nil);
end;

procedure TEditableDataControl.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

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
  end;
end;

procedure TEditableDataControl.LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const FlatColumn: IDCTreeLayoutColumn; const IsSubProp: Boolean);
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

      if ctrl is TCheckBox then
        (ctrl as TCheckBox).OnChange := OnPropertyCheckBoxChange else
        (ctrl as TRadioButton).OnChange := OnPropertyCheckBoxChange;

      chkCtrl.IsChecked := _checkedItems.ContainsKey(Cell.Column) and _checkedItems[Cell.Column].Contains(cell.Row.DataIndex);
    end;

  finally
    dec(_updateCount);
  end;
end;

procedure TEditableDataControl.DoCellCheckChangedByUser(const Cell: IDCTreeCell);
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

procedure TEditableDataControl.OnPropertyCheckBoxChange(Sender: TObject);
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

procedure TEditableDataControl.OnEditorExit;
begin
  // windows wants to clear the focus control after this point
  // therefor we need a little time untill we can EndEdit and free the editor
  TThread.ForceQueue(nil, procedure
  begin
    SafeForcedEndEdit;
  end);
end;

procedure TEditableDataControl.OnEditorKeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
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
  else if (Key in [vkUp, vkDown, vkTab]) and EndEditCell then
  begin
    Self.KeyDown(Key, KeyChar, Shift);
    Self.SetFocus;
  end;
end;

procedure TEditableDataControl.set_Model(const Value: IObjectListModel);
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

procedure TEditableDataControl.UpdateColumnCheck(const DataIndex: Integer; const Column: IDCTreeColumn; IsChecked: Boolean);
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

procedure TEditableDataControl.UpdateColumnCheck(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean);
begin
  var ix := _view.OriginalData.IndexOf(DataItem);
  if ix <> -1 then
    UpdateColumnCheck(ix, Column, IsChecked);
end;

procedure TEditableDataControl.UpdateMinColumnWidthOnShowEditor(const Cell: IDCTreeCell; const MinColumnWidth: Single);
begin
  if (Cell.COlumn.InfoControlClass <> TInfoControlClass.CheckBox) and (Cell.LayoutColumn.Width < MinColumnWidth) then
  begin
    _tempCachedEditingColumnCustomWidth := Cell.Column.CustomWidth;
    Cell.Column.CustomWidth := MinColumnWidth;

    FastColumnAlignAfterColumnChange;
  end else
    _tempCachedEditingColumnCustomWidth := -1;
end;

procedure TEditableDataControl.ResetColumnWidthOnHideEditor(const Column: IDCTreeColumn);
begin
  if not SameValue(_tempCachedEditingColumnCustomWidth, Column.CustomWidth) then
  begin
    Column.CustomWidth := _tempCachedEditingColumnCustomWidth;
    _tempCachedEditingColumnCustomWidth := -1;

    FastColumnAlignAfterColumnChange;
  end;
end;

procedure TEditableDataControl.ResetView(const FromViewListIndex: Integer; ClearOneRowOnly: Boolean);
begin
  if not IsEditOrNew then
  begin
    inherited;
    Exit;
  end;

  _resetViewRec := TResetViewRec.CreateFrom(FromViewListIndex, ClearOneRowOnly, True, _resetViewRec);
end;

procedure TEditableDataControl.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var clickedRow := GetRowByMouseY(Y);
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

procedure TEditableDataControl.StartEditCell(const Cell: IDCTreeCell; const UserValue: string = '');
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

function TEditableDataControl.TryAddRow(const Position: InsertPosition): Boolean;
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
        var obj: CObject := Assembly.CreateInstanceFromObject(referenceItem);
        if obj = nil then
          raise NullReferenceException.Create(CString.Format('Failed to create instance of object {0}, implement event OnAddingNew', referenceItem.GetType));
        if not obj.TryCast(TypeOf(referenceItem), {out} NewItem, True) then
          raise NullReferenceException.Create(CString.Format('Failed to convert {0} to {1}, implement event OnAddingNew', obj.GetType, referenceItem.GetType));
      end;
    end;
  end;

  var newDataItem: CObject := nil;
  var newDataIndex := 0;
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
      newDataIndex := dataRow.get_Index;

      var drv := GetDataModelView.FindRow(dataRow);
      if drv <> nil then
      begin
        _editingInfo.StartRowEdit(drv.Row.get_Index, drv, True);

        newDataItem := drv;
        newViewListIndex := drv.ViewIndex;

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
    newDataIndex := _view.OriginalData.IndexOf(NewItem);
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

procedure TEditableDataControl.TryCheckParentIfAllSelected(const ParentDrv: IDataRowView; const ColumnCheckedItems: List<Integer>);
begin
  if (ParentDrv = nil) or ColumnCheckedItems.Contains(ParentDrv.Row.get_Index) then
    Exit; // nothing to do

  var parentChildren := GetDataModelView.DataModel.Children(ParentDrv.Row, TChildren.IncludeParentRows);

  for var dr in parentChildren do
    if (ParentDrv.Row <> dr) and not ColumnCheckedItems.Contains(dr.get_Index) then
      Exit;

  ColumnCheckedItems.Add(ParentDrv.Row.get_Index);

  var parent := GetDataModelView.Parent(ParentDrv);
  TryCheckParentIfAllSelected(parent, ColumnCheckedItems);
end;

function TEditableDataControl.TryDeleteSelectedRows: Boolean;
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
  for var ix in dataIndexes do
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

function TEditableDataControl.TrySelectCheckBoxes: Boolean;
begin
  var cell := GetActiveCell;
  if (cell = nil) or cell.Column.IsSelectionColumn or (cell.Column.InfoControlClass <> TInfoControlClass.CheckBox) then
  begin
    var valid := False;
    for var flatClmn in Self.Layout.FlatColumns do
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
  for var itemIx in _selectionInfo.SelectedDataIndexes do
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
  for var check in checks do
    if check.IsChecked then
      inc(checkCount);

  BeginUpdate;
  try
    for var check in checks do
    begin
      if check.IsChecked <> (checkCount < checks.Count) then
      begin
        var checkCell := GetCellByControl(check as TControl);
        DoCellCheckChangedByUser(checkCell);
      end;
    end;
  finally
    EndUpdate;
  end;

  Result := True;
end;

procedure TEditableDataControl.CancelEdit(CellOnly: Boolean = False);
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

function TEditableDataControl.EditActiveCell(SetFocus: Boolean; const UserValue: string = ''): Boolean;
begin
  StartEditCell(GetActiveCell, UserValue);

  Result := _cellEditor <> nil;
  if Result and SetFocus then
    _cellEditor.Editor.SetFocus;
end;

function TEditableDataControl.CopyToClipBoard : Boolean;
begin
  if Assigned(_copyToClipboard) then
  begin
    _copyToClipboard(Self);
    Result := True;
  end else
    Result := False;
end;

function TEditableDataControl.PasteFromClipBoard : Boolean;
begin
  if Assigned(_pasteFromClipboard) then
  begin
    _pasteFromClipboard(Self);
    Result := True;
  end else
  begin
    var clipboard: IFMXClipboardService;
    if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipBoard) then
      Result := EditActiveCell(True, ClipBoard.GetClipboard.AsString) else
      Result := False;
  end;
end;

function TEditableDataControl.ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject;
begin
  Result := inherited;

  if (Result = nil) and IsNew and (_cellEditor <> nil) and (_cellEditor.Cell = Cell) then
    Result := _cellEditor.Value;
end;

function TEditableDataControl.EndEditCell: Boolean;
begin
  // stop cell editing
  if _editingInfo.CellIsEditing then
  begin
    var EditRowEnd := False;

    var val := _cellEditor.Value;
    if not DoCellParsing(_cellEditor.Cell, True, {var} val) then
    begin
      CancelEdit(True);
      Exit(False);
    end else
      _cellEditor.Value := val;

    if Assigned(_editCellEnd) then
    begin
      var endEditArgs: DCEndEditEventArgs;
      AutoObject.Guard(DCEndEditEventArgs.Create(_cellEditor.Cell, val, _cellEditor.Editor, _editingInfo.EditItem), endEditArgs);
      endEditArgs.EndRowEdit := False;

      _editCellEnd(Self, endEditArgs);

      if endEditArgs.Accept then
        val := endEditArgs.Value else
        Exit(False);

      EditRowEnd := endEditArgs.EndRowEdit;
    end;

    SetCellData(_cellEditor.Cell, val);

    // KV: 24/01/2025
    // Update the actual contents of the cell after the data in the cell has changed
    LoadDefaultDataIntoControl(_cellEditor.Cell, _cellEditor.Cell.LayoutColumn, False);

    _editingInfo.CellEditingFinished;

    var row := _cellEditor.Cell.Row as IDCTreeRow;
    HideEditor;

    DoDataItemChangedInternal(row.DataItem);

    if EditRowEnd then
      Exit(DoEditRowEnd(row));
  end;

  Result := True;
end;

procedure TEditableDataControl.CancelEditFromExternal;
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

function TEditableDataControl.CanEditCell(const Cell: IDCTreeCell): Boolean;
begin
  Result := not Cell.Column.ReadOnly and not (TDCTreeOption.ReadOnly in _options);
end;

procedure TEditableDataControl.EndEditFromExternal;
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

procedure TEditableDataControl.FollowCheckThroughChildren(const Cell: IDCTreeCell);
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
  for var dr in children do
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

procedure TEditableDataControl.GenerateView;
begin
  inherited;

  _checkedItems := CDictionary<IDCTreeColumn, List<Integer>>.Create;
end;

procedure TEditableDataControl.ShowEditor(const Cell: IDCTreeCell; const StartEditArgs: DCStartEditEventArgs; const UserValue: string = '');
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
    _cellEditor := TDCCellDropDownEditor.Create(self, Cell);
    (_cellEditor as IPickListSupport).PickList := StartEditArgs.PickList;
  end
  else if Cell.Column.InfoControlClass = TInfoControlClass.CheckBox then
    _cellEditor := TDCCheckBoxCellEditor.Create(Self, Cell)
  else
  begin
    if not CString.IsNullOrEmpty(Cell.Column.PropertyName) then
    begin
      if ViewIsDataModelView then
        dataType := GetDataModelView.DataModel.FindColumnByName(Cell.Column.PropertyName).DataType else
        dataType := GetItemType.PropertyByName(Cell.Column.PropertyName).GetType;
    end else
      dataType := Global.StringType;

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

procedure TEditableDataControl.HideEditor;
begin
  var clmn := _cellEditor.Cell.Column;

  _cellEditor := nil;

  ResetColumnWidthOnHideEditor(clmn);

  var activeCell := GetActiveCell;
  if activeCell = nil then Exit; // cell scrolled out of view

  activeCell.InfoControl.Visible := True;
end;

procedure TEditableDataControl.InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean);
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

    for var row in _view.ActiveViewRows do
      VisualizeRowSelection(row);

    Exit;
  end;

  inherited;
end;

function TEditableDataControl.IsEdit: Boolean;
begin
  Result := _editingInfo.RowIsEditing and not _editingInfo.IsNew;
end;

function TEditableDataControl.IsEditOrNew: Boolean;
begin
  Result := _editingInfo.RowIsEditing or _editingInfo.IsNew;
end;

function TEditableDataControl.IsNew: Boolean;
begin
  Result := _editingInfo.IsNew;
end;

function TEditableDataControl.ItemCheckedInColumn(const Item: CObject; const Column: IDCTreeColumn): Boolean;
begin
  var ix := _view.OriginalData.IndexOf(Item);
  if ix = -1 then
    Exit(False);

  var columnCheckedItems: List<Integer>;
  Result := (_checkedItems <> nil) and _checkedItems.TryGetValue(Column, columnCheckedItems) and columnCheckedItems.Contains(ix);
end;

function TEditableDataControl.DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean;
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

procedure TEditableDataControl.DoCellCheckChangedByUser(const DataItem: CObject; const Column: IDCTreeColumn; IsChecked: Boolean);
begin
  var ix := _view.GetViewListIndex(DataItem);
  if ix = -1 then Exit;

  var row := _view.GetActiveRowIfExists(ix) as IDCTreeRow;
  if (row = nil) then Exit;

  var checkCell: IDCTreeCell := nil;
  for var cell in row.Cells.Values do
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

function TEditableDataControl.DoEditRowStart(const ARow: IDCTreeRow; var DataItem: CObject; IsNew: Boolean): Boolean;
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

procedure TEditableDataControl.DoUserDeletedRow;
begin
  if Assigned(_rowDeleted) then
    _rowDeleted(Self);
end;

function TEditableDataControl.DoUserDeletingRow(const Item: CObject): Boolean;
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

function TEditableDataControl.DoEditRowEnd(const ARow: IDCTreeRow): Boolean;
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

    var ix := _view.GetViewList.IndexOf(_editingInfo.EditItem);
    if ix <> -1 then
      _view.GetViewList[ix] := _editingInfo.EditItem;

    var editItem := _editingInfo.EditItem;
    var dataIndex := _editingInfo.EditItemDataIndex;

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

function TEditableDataControl.DoCellParsing(const Cell: IDCTreeCell; IsCheckOnEndEdit: Boolean; var AValue: CObject) : Boolean;
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

function TEditableDataControl.DoAddingNew(out NewObject: CObject) : Boolean;
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

procedure TEditableDataControl.SafeForcedEndEdit;
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

procedure TEditableDataControl.SetCellData(const Cell: IDCTreeCell; const Data: CObject);
var
  s: string;
  msg: string;
  propInfo: _PropertyInfo;

begin
  try
    Inc(_updateCount);
    try
      if CString.Equals(Cell.Column.PropertyName, COLUMN_SHOW_DEFAULT_OBJECT_TEXT) then
        _editingInfo.EditItem := Data
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

        if (propInfo.PropInfo <> nil) and (propInfo.PropInfo.PropType <> nil) then
          msg := CString.Format('Invalid value: ''{0}'' (field expects a {1})', s, propInfo.PropInfo.PropType^.NameFld.ToString) else
          msg := CString.Format('Invalid value: ''{0}''', s);
      except
        raise EConvertError.Create(msg);
      end;
      raise EConvertError.Create(msg);
    end;
  end;
end;

procedure TEditableDataControl.SetSingleSelectionIfNotExists;
begin
//  if IsNew then
//    Exit;

  if _selectionInfo.HasSelection and IsEdit then
    Exit;

  Assert(not IsEdit);

  inherited;
end;

end.
