unit FMX.ScrollControl.WithRows.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls,
  System.SysUtils,
  System.Classes,
  FMX.Objects,
  System.ComponentModel,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.SysUtils,
  Wasm.FMX.Objects,
  Wasm.System.ComponentModel,
  {$ENDIF}
  System_,
  FMX.ScrollControl.WithRows.Intf,
  System.Collections,
  System.Collections.Generic,
  FMX.ScrollControl.Intf,
  FMX.ScrollControl.Impl, ADato.Data.DataModel.intf,
  ADato.ObjectModel.List.intf, ADato.ObjectModel.intf,
  FMX.ScrollControl.View.Intf, FMX.ScrollControl.Events, System.UITypes,
  System.Types;

type

  TCalculateViewFrom = (None, Top, Bottom);

  TScrollControlWithRows = class(TScrollControl, IRowsControl)
  // data
  protected
    _dataList: IList;
    _dataModelView: IDataModelView;
    // KV 04_05 Datacontrol should keep a lock on the model.
    // It will be released otherwise
    {[unsafe]} _model: IObjectListModel;

    function  get_DataList: IList;
    procedure set_DataList(const Value: IList);
    function  get_DataModelView: IDataModelView;
    procedure set_DataModelView(const Value: IDataModelView);
    function  get_Model: IObjectListModel;
    procedure set_Model(const Value: IObjectListModel); virtual;
    function  get_View: IDataViewList;

    procedure ModelListContextChanging(const Sender: IObjectListModel; const Context: IList);
    procedure ModelListContextChanged(const Sender: IObjectListModel; const Context: IList);
    procedure ModelContextPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
    procedure ModelContextChanged(const Sender: IObjectModelContext; const Context: CObject);

    procedure DataModelViewRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);
    procedure DataModelViewRowPropertiesChanged(Sender: TObject; Args: RowPropertiesChangedEventArgs); virtual;

    procedure GenerateView; virtual;

  // published property variables

  private _rowHeightSynchronizer: TScrollControlWithRows;
  protected _activeRowHeightSynchronizer: TScrollControlWithRows;

  protected
    _selectionType: TSelectionType;
    _rowHeightFixed: Single;
    _rowHeightDefault: Single;
    _rowHeightMax: Single;
    _options: TDCTreeOptions;
    _allowNoneSelected: Boolean;

    // events
    {$IFNDEF WEBASSEMBLY}
    _rowLoaded: RowLoadedEvent;
    _rowAligned: RowLoadedEvent;
    {$ENDIF}

    procedure DoRowLoaded(const ARow: IDCRow); virtual;
    procedure DoRowAligned(const ARow: IDCRow); virtual;

    function  get_SelectionType: TSelectionType;
    procedure set_SelectionType(const Value: TSelectionType);
    procedure set_Options(const Value: TDCTreeOptions);
    {$IFNDEF WEBASSEMBLY}
    function  get_AllowNoneSelected: Boolean;
    {$ENDIF}
    procedure set_AllowNoneSelected(const Value: Boolean);
    function  get_NotSelectableItems: IList;
    procedure set_NotSelectableItems(const Value: IList);
    procedure set_RowHeightMax(const Value: Single);

    function  get_rowHeightDefault: Single; virtual;
    function  get_RowHeightSynchronizer: TScrollControlWithRows;
    procedure set_RowHeightSynchronizer(const Value: TScrollControlWithRows);

    procedure DoViewPortPositionChanged; override;

    procedure StartMasterSynchronizer;
    procedure StopMasterSynchronizer;

  // public property variables
  private
    function  get_Current: Integer;
    procedure set_Current(const Value: Integer);
    function  get_DataItem: CObject;
    procedure set_DataItem(const Value: CObject);

  // row calculations
  private
    _scrollbarMaxChangeSinceViewLoading: Single;
    _scrollbarRefToTopHeightChangeSinceViewLoading: Single;

    procedure UpdateVirtualYPositions(const TopVirtualYPosition: Single; const ToViewIndex: Integer = -1);

    procedure DoViewLoadingStart(const StartY, StopY: Single);
    procedure DoViewLoadingFinished;
    procedure CreateAndSynchronizeSynchronizerRow(const Row: IDCRow);
    procedure UpdateRowHeightSynchronizerScrollbar;
    procedure set_RowHeightDefault(const Value: Single);
    procedure set_RowHeightFixed(const Value: Single);

  protected
    _view: IDataViewList;
    _waitForRepaintInfo: IWaitForRepaintInfo;
    _selectionInfo: IRowSelectionInfo;
    _internalSelectCount: Integer;
    _isMasterSynchronizer: Boolean;

    _hoverRect: TRectangle;
//    _viewChangedIndex: Integer;
//    _waitingForViewChange: Boolean;
    _resetViewRec: TResetViewRec;
    _canDragDrop: Boolean;
    _dragObject: CObject;

    _tryFindNewSelectionInDataModel: Boolean;

    function  HasInternalSelectCount: Boolean;

    procedure DoEnter; override;
    procedure DoExit; override;

    procedure RealignContentStart; override;
    procedure BeforeRealignContent; override;
    procedure RealignContent; override;
    procedure AfterRealignContent; override;
    procedure RealignFinished; override;
    procedure DoRealignContent; override;

    procedure RealignFromSelectionChange(const StartY, StopY: Single; CalculateViewFrom: TCalculateViewFrom);
    procedure InnerRealignContent(const StartY, StopY: Single; CalculateViewFrom: TCalculateViewFrom);
    procedure AfterRowHeightsChanged(const TopVirtualYPosition: Single; const CalculateViewFrom: TCalculateViewFrom = TCalculateViewFrom.Top);

    procedure SetBasicVertScrollBarValues; override;
    procedure BeforePainting; override;

    function  DoCreateNewRow: IDCRow; virtual;
    procedure InnerInitRow(const Row: IDCRow); virtual;
    procedure InitRow(const Row: IDCRow; const IsAboveRefRow: Boolean = False);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

    procedure OnSelectionInfoChanged; virtual;
    function  CreateSelectioninfoInstance: IRowSelectionInfo; virtual;
    procedure SetSingleSelectionIfNotExists; virtual;
    procedure InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False); virtual;
    function  TrySelectItem(const RequestedSelectionInfo: IRowSelectionInfo; Shift: TShiftState): Boolean; virtual;
    procedure ScrollSelectedIntoView(const RequestedSelectionInfo: IRowSelectionInfo);
    function  CreateDummyRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow; virtual;

    procedure AlignRowsFromReferenceToTop(const BottomReferenceRow: IDCRow; var SpaceForRows: Single);
    procedure AlignRowsFromReferenceToBottom(const TopReferenceRow: IDCRow; var SpaceForRows: Single);

    procedure UpdateYPositionRows;
    procedure UpdateScrollBarValues(const CalculateViewFrom: TCalculateViewFrom);
    procedure UpdateHoverRect(MousePos: TPointF); virtual;

    function  GetPropValue(const PropertyName: CString; const DataItem: CObject; const DataModel: IDataModel = nil): CObject;

    procedure UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single); override;
    function  DefaultMoveDistance(ScrollDown: Boolean): Single; override;
    function  CalculateAverageRowHeight: Single;
    procedure DoContentResized(WidthChanged, HeightChanged: Boolean); override;

    procedure CheckVertScrollbarVisibility;
    procedure CalculateScrollBarMax; override;
    procedure InternalDoSelectRow(const Row: IDCRow; Shift: TShiftState);

    procedure OnViewChanged;

    function  ListHoldsOrdinalType: Boolean;
    procedure HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions); virtual;

    function  GetInitializedWaitForRefreshInfo: IWaitForRepaintInfo; virtual;
    procedure VisualizeRowSelection(const Row: IDCRow); virtual;

    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure UpdateScrollAndSelectionByKey(var Key: Word; Shift: TShiftState); virtual;

    procedure ResetAndRealign(FromIndex: Integer = -1);
    procedure DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean);
    function  RowIsExpanded(const ViewListIndex: Integer): Boolean;

    procedure ResetView(const FromViewListIndex: Integer = -1; ClearOneRowOnly: Boolean = False); virtual;

    function  GetSelectableViewIndex(const FromViewListIndex: Integer; const Increase: Boolean; const FirstRound: Boolean = True): Integer;

    function  GetRowViewListIndexByKey(const Key: Word; Shift: TShiftState): Integer;
    function  GetActiveRow: IDCRow;

  public
    procedure OnItemAddedByUser(const Item: CObject; Index: Integer);
    procedure OnItemRemovedByUser(const Item: CObject; Index: Integer);

  protected
    _itemType: &Type;
    function  GetItemType: &Type;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // drag & drop
    procedure BeginDrag;

    procedure ExecuteKeyFromExternal(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    function  GetRowByLocalY(const Y: Single): IDCRow;

    function  ConvertToDataItem(const Item: CObject): CObject;
    function  ConvertedDataItem: CObject;

    procedure TriggerFilterOrSortChanged(FilterChanged, SortChanged: Boolean);

    procedure AddSortDescription(const Sort: IListSortDescription; const ClearOtherSort: Boolean);
    procedure AddFilterDescription(const Filter: IListFilterDescription; const ClearOtherFlters: Boolean);

    procedure DoDataItemChangedInternal(const DataItem: CObject); virtual;
    procedure DoDataItemChanged(const DataItem: CObject; const DataIndex: Integer);

    function  VisibleRows: List<IDCRow>;

    function  ViewIsDataModelView: Boolean;
    function  GetDataModelView: IDataModelView;
    function  GetDataModel: IDataModel;

    // start public selection
    procedure SelectAll; virtual;
    procedure ClearSelections; virtual;
    procedure ClearCurrentSelection; {virtual;}

    function  CanRealignContent: Boolean; override;

    procedure SelectItem(const DataItem: CObject; ClearOtherSelections: Boolean = False);
    procedure DeselectItem(const DataItem: CObject);
    procedure ToggleDataItemSelection; overload;
    procedure ToggleDataItemSelection(const Item: CObject); overload;

    function  IsSelected(const DataItem: CObject): Boolean;
    function  SelectedRowIfInView: IDCRow;
    function  SelectionCount: Integer;
    function  SelectedItems: List<CObject>;
    function  DraggedItems: List<CObject>;

    procedure AssignSelection(const SelectedItems: IList);
    // end public selection

    // start public expand/collapse
    procedure ExpandCurrentRow;
    procedure CollapseCurrentRow;
    function  CurrentRowIsExpanded: Boolean;
    // end public expand/collapse

    function SortActive: Boolean;
    function FiltersActive: Boolean;

    procedure RefreshControl(const DataChanged: Boolean = False); override;

    property DataList: IList read get_DataList write set_DataList;
    property Model: IObjectListModel read get_Model write set_Model;
    property DataModelView: IDataModelView read get_DataModelView write set_DataModelView;

    property Current: Integer read get_Current write set_Current;
    property DataItem: CObject read get_DataItem write set_DataItem;

    property View: IDataViewList read get_View;
    property NotSelectableItems: IList read get_NotSelectableItems write set_NotSelectableItems;
    property ItemType: &Type read _itemType write _itemType;

  published
    property SelectionType: TSelectionType read get_SelectionType write set_SelectionType default RowSelection;
    property Options: TDCTreeOptions read _options write set_Options;
    property AllowNoneSelected: Boolean read _allowNoneSelected write set_AllowNoneSelected default False;
    property CanDragDrop: Boolean read _canDragDrop write _canDragDrop default False;

    property RowHeightFixed: Single read _rowHeightFixed write set_RowHeightFixed;
    property RowHeightDefault: Single read get_rowHeightDefault write set_RowHeightDefault;
    property RowHeightMax: Single read _rowHeightMax write set_RowHeightMax;

    {$IFNDEF WEBASSEMBLY}
    property RowLoaded: RowLoadedEvent read _rowLoaded write _rowLoaded;
    property RowAligned: RowLoadedEvent read _rowAligned write _rowAligned;
    {$ENDIF}

    property RowHeightSynchronizer: TScrollControlWithRows read get_RowHeightSynchronizer write set_RowHeightSynchronizer;
  end;

  TDCRow = class(TBaseInterfacedObject, IDCRow)
  protected
    _dataItem: CObject;
    _convertedDataItem: CObject;
    _dataIndex: Integer;
    _viewPortIndex: Integer;
    _viewListIndex: Integer;
    _virtualYPosition: Single;

    _control: TControl;
    _enabled: Boolean;

    _ownerIsScrolling: Boolean;

    _customTag: CObject;

    function  get_DataIndex: Integer;
    procedure set_DataIndex(const Value: Integer);
    function  get_DataItem: CObject;
    procedure set_DataItem(const Value: CObject);
    function  get_ConvertedDataItem: CObject;
    function  get_ViewPortIndex: Integer;
    procedure set_ViewPortIndex(const Value: Integer);
    function  get_ViewListIndex: Integer;
    procedure set_ViewListIndex(const Value: Integer);
    function  get_VirtualYPosition: Single;
    procedure set_VirtualYPosition(const Value: Single);
    function  get_Control: TControl;
    procedure set_Control(const Value: TControl); virtual;
    function  get_IsHeaderRow: Boolean; virtual;
    function  get_Enabled: Boolean;
    procedure set_Enabled(const Value: Boolean);
    function  get_OwnerIsScrolling: Boolean;
    procedure set_OwnerIsScrolling(const Value: Boolean); virtual;
    function  get_CustomTag: CObject;
    procedure set_CustomTag(const Value: CObject);

    procedure UpdateControlVisibility;


  protected
    _selectionRect: TRectangle;

    procedure UpdateSelectionRect(OwnerIsFocused: Boolean);

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean); virtual;

    procedure ClearRowForReassignment; virtual;
    function  IsClearedForReassignment: Boolean;
    function  IsScrollingIntoView: Boolean;

    function  Height: Single;
    function  HasChildren: Boolean;
    function  HasVisibleChildren: Boolean;
    function  ParentCount: Integer;
    function  IsOddRow: Boolean;
  end;

  TRowSelectionInfo = class(TInterfacedObject, IRowSelectionInfo)
  protected
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF}_rowsControl: IRowsControl;

    _lastSelectedDataIndex: Integer;
    _lastSelectedViewListIndex: Integer;
    _lastSelectedDataItem: CObject;
    _forceScrollToSelection: Boolean;

    _selectionChanged: Boolean;
    _updateCount: Integer;

    _EventTrigger: TSelectionEventTrigger;
    _notSelectableDataIndexes: TDataIndexArray;

    function  get_DataIndex: Integer;
    function  get_DataItem: CObject;
    function  get_ViewListIndex: Integer;
    function  get_IsMultiSelection: Boolean;
    function  get_ForceScrollToSelection: Boolean;
    procedure set_ForceScrollToSelection(const Value: Boolean);
    function  get_EventTrigger: TSelectionEventTrigger;
    procedure set_EventTrigger(const Value: TSelectionEventTrigger);
    function  get_NotSelectableDataIndexes: TDataIndexArray;
    procedure set_NotSelectableDataIndexes(const Value: TDataIndexArray);

  protected
    _multiSelection: Dictionary<Integer {DataIndex}, IRowSelectionInfo>;

    function  CreateInstance: IRowSelectionInfo; virtual;
    function  Clone: IRowSelectionInfo; virtual;

    procedure DoSelectionInfoChanged;
    procedure UpdateLastSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);

  public
    constructor Create(const RowsControl: IRowsControl); reintroduce;

    function  SelectionType: TSelectionType;

    procedure UpdateSingleSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
    procedure AddToSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
    procedure Deselect(const DataIndex: Integer);
    procedure SelectedRowClicked(const DataIndex: Integer);

    procedure BeginUpdate;
    procedure EndUpdate(IgnoreChangeEvent: Boolean = False);

    procedure Clear; virtual;
    procedure ClearAllSelections;
    procedure ClearMultiSelections; virtual;

    function  CanSelect(const DataIndex: Integer): Boolean;
    function  HasSelection: Boolean;
    function  IsSelected(const DataIndex: Integer): Boolean;
    function  GetSelectionInfo(const DataIndex: Integer): IRowSelectionInfo;
    function  SelectedRowCount: Integer;
    function  SelectedDataIndexes: List<Integer>;

  end;

  TWaitForRepaintInfo = class(TInterfacedObject, IWaitForRepaintInfo)
  protected
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _owner: IRefreshControl;

  private
    _rowStateFlags: TTreeRowStateFlags;

    _current: Integer;
    _dataItem: CObject;
    _sortDescriptions: List<IListSortDescription>;
    _filterDescriptions: List<IListFilterDescription>;


    function  get_RowStateFlags: TTreeRowStateFlags;
    procedure set_RowStateFlags(const Value: TTreeRowStateFlags);
    function  get_Current: Integer;
    procedure set_Current(const Value: Integer);
    function  get_DataItem: CObject;
    procedure set_DataItem(const Value: CObject);
    function  get_SortDescriptions: List<IListSortDescription>;
    procedure set_SortDescriptions(const Value: List<IListSortDescription>);
    function  get_FilterDescriptions: List<IListFilterDescription>;
    procedure set_FilterDescriptions(const Value: List<IListFilterDescription>);

  public
    constructor Create(const Owner: IRefreshControl); reintroduce;

    procedure ClearIrrelevantInfo;

    property RowStateFlags: TTreeRowStateFlags read get_RowStateFlags;
    property Current: Integer read get_Current write set_Current;
    property DataItem: CObject read get_DataItem write set_DataItem;
    property SortDescriptions: List<IListSortDescription> read get_SortDescriptions write set_SortDescriptions;
    property FilterDescriptions: List<IListFilterDescription> read get_FilterDescriptions write set_FilterDescriptions;
  end;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Types,
  FMX.StdCtrls,
  System.Generics.Collections,
  {$ELSE}
  Wasm.FMX.Types,
  Wasm.FMX.StdCtrls,
  Wasm.System.UITypes,
  {$ENDIF}
  FMX.ScrollControl.ControlClasses
  , System.Math, FMX.Platform, System.Rtti, FMX.Forms, FMX.Graphics,
  FMX.ScrollControl.View.Impl, FMX.ControlCalculations, FMX.ActnList;


{ TScrollControlWithRows }

procedure TScrollControlWithRows.DoContentResized(WidthChanged, HeightChanged: Boolean);
begin
  if WidthChanged and (_view <> nil) then
  begin
    var row: IDCRow;
    for row in _view.ActiveViewRows do
      row.Control.Width := _content.Width;
  end;

  inherited;
end;

function TScrollControlWithRows.DefaultMoveDistance(ScrollDown: Boolean): Single;
begin
  if _rowHeightFixed > 0 then
    Result := _rowHeightFixed
  else if get_rowHeightDefault > 0 then
    Result := _rowHeightDefault
  else
    Result := 30;

  while (Result < 45) do
    Result := Result * 2;
end;

destructor TScrollControlWithRows.Destroy;
begin
//  AtomicIncrement(_viewChangedIndex);

  _view := nil;

  // remove events
  if _model <> nil then
    set_Model(nil);

  inherited;
end;

function TScrollControlWithRows.DoCreateNewRow: IDCRow;
begin
  Result := TDCRow.Create;
end;

procedure TScrollControlWithRows.DoDataItemChanged(const DataItem: CObject; const DataIndex: Integer);
begin
  OnSelectionInfoChanged;
//  var dataIndexActive := _view.FastPerformanceDataIndexIsActive(DataIndex);
//
//  var viewListindex := _view.GetViewListIndex(DataItem);
//  if (viewListIndex = -1) and not dataIndexActive then
//    Exit;
//
//  // clear all from this point,
//  // because as well row height as cell widths can be changed
//
//  DoDataItemChangedInternal(DataItem);
//  ResetView(viewListindex, viewListindex <> -1 {only if still exists});
end;

procedure TScrollControlWithRows.DoDataItemChangedInternal(const DataItem: CObject);
begin
  // DO NOT ask the view for the correct index
  // a item can be fitlered out, and therefor for example the DataModelView gives back another index
  // this is problematic when we want to keep the filtered out item in the view for niceness purpose
//  var ix := _view.GetViewListIndex(DataItem);

  var di := ConvertToDataItem(DataItem);

  var currentRow: IDCRow := nil;
  var row: IDCRow;
  for row in _view.ActiveViewRows do
    if CObject.Equals(ConvertToDataItem(row.DataItem), di) then
      currentRow := row;

  if currentRow = nil then
    Exit; // nothing to do

  var originalHeight := _view.CachedRowHeight(currentRow.ViewListIndex);

  // reset row height
  _view.ClearViewRecInfo(currentRow.ViewListIndex, True);
  if _activeRowHeightSynchronizer <> nil then
    _activeRowHeightSynchronizer.View.ClearViewRecInfo(currentRow.ViewListIndex, True);

  InnerInitRow(currentRow);
  DoRowLoaded(currentRow);

  _view.RowLoaded(currentRow, False);

  if _activeRowHeightSynchronizer <> nil then
    _isMasterSynchronizer := True;
  try
    CreateAndSynchronizeSynchronizerRow(currentRow);

    if not SameValue(originalHeight, currentRow.Height) then
    begin
      AfterRowHeightsChanged(_view.ActiveViewRows[0].VirtualYPosition);

      AfterRealignContent;
      RealignFinished;
    end;
  finally
    if _activeRowHeightSynchronizer <> nil then
      _isMasterSynchronizer := False;
  end;

  DoRowAligned(currentRow);
end;

function TScrollControlWithRows.HasInternalSelectCount: Boolean;
begin
  Result := (_internalSelectCount > 0) or ((_rowHeightSynchronizer <> nil) and (_rowHeightSynchronizer._internalSelectCount > 0));
end;

procedure TScrollControlWithRows.DoEnter;
begin
  inherited;

  if _view = nil then
    Exit;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    VisualizeRowSelection(row);
end;

procedure TScrollControlWithRows.DoExit;
begin
  inherited;

  if _view = nil then
    Exit;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    VisualizeRowSelection(row);
end;

procedure TScrollControlWithRows.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;

  _dragObject := nil;
end;

procedure TScrollControlWithRows.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  if not _canDragDrop then
    inherited;

  UpdateHoverRect(PointF(X, Y - _content.Position.Y));

  if _canDragDrop and MouseIsDown then
  begin
    var moved := (X > _mousePositionOnMouseDown.X + 5) or (X < _mousePositionOnMouseDown.X - 5) or (Y < _mousePositionOnMouseDown.Y + 5) or (Y < _mousePositionOnMouseDown.Y - 5);
    if not moved then
      Exit;

    var row := GetRowByLocalY(Y - _content.Position.Y);
    if (row <> nil) and not _selectionInfo.IsSelected(row.DataIndex) then
      _dragObject := ConvertToDataItem(row.DataItem)
    else
      row := GetActiveRow;

    if row = nil then
      Exit;

//    Self.Root.BeginInternalDrag(Self, bm);

    // copied from FMX.Forms => .Root.BeginInternalDrag(Self, bm);
    var D: TDragObject;
    var DDService: IFMXDragDropService;

    Self.Root.SetCaptured(nil);
    D.Source := row.Control;
    D.Files := nil;
    D.Data := TValue.From<IList>(DraggedItems as IList);
    {$IFNDEF WEBASSEMBLY}
    if TPlatformServices.Current.SupportsPlatformService(IFMXDragDropService, DDService) then
      DDService.BeginDragDrop(Self.Root as TCommonCustomForm, D, FMX.Graphics.TBitmap(row.Control.MakeScreenshot));
    {$ELSE}
    if TPlatformServices.Current.SupportsPlatformService<IFMXDragDropService>(DDService) then
      DDService.BeginDragDrop(Self.Root as TCommonCustomForm, D, Wasm.FMX.Graphics.TBitmap(row.Control.MakeScreenshot));
    {$ENDIF}
  end;
end;

procedure TScrollControlWithRows.DoMouseLeave;
begin
  inherited;

  UpdateHoverRect(PointF(-1, -1));
end;

procedure TScrollControlWithRows.DoRealignContent;
begin
  var hadSync := _activeRowHeightSynchronizer <> nil;

  if not hadSync then
    StartMasterSynchronizer;
  try
    inherited;
  finally
    if not hadSync then
      StopMasterSynchronizer;
  end;
end;

procedure TScrollControlWithRows.UpdateRowHeightSynchronizerScrollbar;
begin
  if not _isMasterSynchronizer then
    Exit;

  inc(_activeRowHeightSynchronizer._scrollUpdateCount);
  try
    _activeRowHeightSynchronizer.VertScrollBar.Max := _vertScrollBar.Max;
    _activeRowHeightSynchronizer.VertScrollBar.ViewportSize := _vertScrollBar.ViewportSize;
    _activeRowHeightSynchronizer.VertScrollBar.Value := _vertScrollBar.Value;

    _activeRowHeightSynchronizer.CheckVertScrollbarVisibility;
  finally
    dec(_activeRowHeightSynchronizer._scrollUpdateCount);
  end;
end;

procedure TScrollControlWithRows.DoRowLoaded(const ARow: IDCRow);
begin
  {$IFNDEF WEBASSEMBLY}
  if Assigned(_rowLoaded) then
  begin
    var rowEventArgs: DCRowEventArgs;
    AutoObject.Guard(DCRowEventArgs.Create(ARow), rowEventArgs);

    _rowLoaded(Self, rowEventArgs);
  end;
  {$ELSE}
  //raise NotImplementedException.Create('procedure TScrollControlWithRows.DoRowLoaded(const ARow: IDCRow)');
  {$ENDIF}
end;

procedure TScrollControlWithRows.DoRowAligned(const ARow: IDCRow);
begin
  {$IFNDEF WEBASSEMBLY}
  if Assigned(_rowAligned) then
  begin
    var rowEventArgs: DCRowEventArgs;
    AutoObject.Guard(DCRowEventArgs.Create(ARow), rowEventArgs);

    _rowAligned(Self, rowEventArgs);
  end;
  {$ELSE}
  //raise NotImplementedException.Create('procedure TScrollControlWithRows.DoRowAligned(const ARow: IDCRow)');
  {$ENDIF}
end;

procedure TScrollControlWithRows.TriggerFilterOrSortChanged(FilterChanged, SortChanged: Boolean);
begin
  var refreshInfo := GetInitializedWaitForRefreshInfo;

  if FilterChanged then
    refreshInfo.FilterDescriptions := _view.GetFilterDescriptions; // triggers refreshcontrol

  if SortChanged then
    refreshInfo.SortDescriptions := _view.GetSortDescriptions; // triggers refreshcontrol
end;

function TScrollControlWithRows.TrySelectItem(const RequestedSelectionInfo: IRowSelectionInfo; Shift: TShiftState): Boolean;
begin
  Result := True;

  var dataIndex := _view.GetDataIndex(RequestedSelectionInfo.ViewListIndex);
  var changed := (_selectionInfo.DataIndex <> dataIndex);
  if not changed then
  begin
    ScrollSelectedIntoView(RequestedSelectionInfo);
    Exit;
  end;

  // Okay, we now know for sure that we have a changed cell..
  // old row can be scrolled out of view. So always work with dummy rows
  var dummyNewRow := CreateDummyRowForChanging(RequestedSelectionInfo);

  _selectionInfo.BeginUpdate;
  try
    InternalDoSelectRow(dummyNewRow, Shift);
  finally
    _selectionInfo.EndUpdate;
  end;
end;

function TScrollControlWithRows.GetInitializedWaitForRefreshInfo: IWaitForRepaintInfo;
begin
  // _waitForRepaintInfo is nilled after RealignContent
  if _waitForRepaintInfo = nil then
    _waitForRepaintInfo := TWaitForRepaintInfo.Create(Self);

  Result := _waitForRepaintInfo;
end;

function TScrollControlWithRows.GetRowViewListIndexByKey(const Key: Word; Shift: TShiftState): Integer;
begin
  if (ssCtrl in Shift) and (Key in [vkUp, vkHome]) then
    Exit(GetSelectableViewIndex(0, True))
  else if (ssCtrl in Shift) and (Key in [vkDown, vkEnd]) then
    Exit(GetSelectableViewIndex(_view.ViewCount - 1, False))
  else if (Key = vkUp) then
    Exit(GetSelectableViewIndex(_selectionInfo.ViewListIndex-1, False))
  else if (Key = vkDown) then
    Exit(GetSelectableViewIndex(_selectionInfo.ViewListIndex+1, True));

  // no change
  Result := _selectionInfo.ViewListIndex;
end;

function TScrollControlWithRows.GetSelectableViewIndex(const FromViewListIndex: Integer; const Increase: Boolean; const FirstRound: Boolean = True): Integer;
begin
  Result := FromViewListIndex;
  if (Result < 0) or (Result > _view.ViewCount - 1) then
    Exit(-1);

  var di := _view.GetDataIndex(Result);
  while not _selectionInfo.CanSelect(di) do
  begin
    if Increase then
    begin
      inc(Result);
      if Result > _view.ViewCount - 1 then
      begin
        if FirstRound then
          Exit(GetSelectableViewIndex(FromViewListIndex, not Increase, False));

        Exit(-1);
      end;
    end
    else
    begin
      dec(Result);
      if Result = -1 then
      begin
        if FirstRound then
          Exit(GetSelectableViewIndex(FromViewListIndex, not Increase, True));

        Exit(-1);
      end;
    end;

    di := _view.GetDataIndex(Result);
  end;
end;

function TScrollControlWithRows.GetRowByLocalY(const Y: Single): IDCRow;
begin
  if (_view = nil) or (Y < 0) then
    Exit(nil);

  var virtualMouseposition := Y + _vertScrollBar.Value;
  var row: IDCRow;
  for row in _view.ActiveViewRows do
    if (row.VirtualYPosition <= virtualMouseposition) and (row.VirtualYPosition + row.Height > virtualMouseposition) then
      Exit(row);

  Result := nil;
end;

function TScrollControlWithRows.GetDataModel: IDataModel;
var
  dm: IDataModel;
begin
  if interfaces.Supports<IDataModel>(_dataList, dm) then
    Result := dm
  else if _dataModelView <> nil then
    Result := _dataModelView.DataModel
  else
    Result := nil;
end;

function TScrollControlWithRows.GetDataModelView: IDataModelView;
var
  dm: IDataModel;
begin
  if _dataModelView <> nil then
    Result := _dataModelView
  else if interfaces.Supports<IDataModel>(_dataList, dm) then
    Result := dm.DefaultView;
end;

procedure TScrollControlWithRows.GenerateView;
begin
  inc(_scrollUpdateCount);
  try
    _vertScrollBar.Value := 0;
    _horzScrollBar.Value := 0;

    UpdateRowHeightSynchronizerScrollbar;
  finally
    dec(_scrollUpdateCount);
  end;

  if _dataModelView <> nil then
    {$IFNDEF WEBASSEMBLY}
    _view := TDataViewList.Create(_dataModelView, DoCreateNewRow, OnViewChanged)
    {$ELSE}
    _view := TDataViewList.Create(_dataModelView, @DoCreateNewRow, @OnViewChanged)
    {$ENDIF}
  else begin
    var aType := GetItemType;
    if aType.IsUnknown and (_dataList.Count > 0) then
      aType := _dataList[0].GetType;

    {$IFNDEF WEBASSEMBLY}
    _view := TDataViewList.Create(_dataList, DoCreateNewRow, OnViewChanged, aType);
    {$ELSE}
    _view := TDataViewList.Create(_dataList, @DoCreateNewRow, @OnViewChanged, aType);
    {$ENDIF}
  end;

  if ViewIsDataModelView and (GetDataModelView.CurrencyManager.Current <> -1) and (_view.ActiveViewRows.Count > 0) then
    InternalSetCurrent(GetDataModelView.CurrencyManager.Current, TSelectionEventTrigger.External, []);

  RefreshControl;
end;

function TScrollControlWithRows.GetActiveRow: IDCRow;
begin
  if _view = nil then
    Exit;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    if (row.DataIndex = _selectionInfo.DataIndex) then
      Exit(row);

  Result := nil;
end;

function TScrollControlWithRows.get_SelectionType: TSelectionType;
begin
  Result := _selectionType;
end;

function TScrollControlWithRows.get_View: IDataViewList;
begin
  Result := _view;
end;

procedure TScrollControlWithRows.HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions);
begin
  if TDCTreeOption.HideVScrollBar in _options then
    _vertScrollBar.Visible := False;

  if TDCTreeOption.HideHScrollBar in _options then
    _horzScrollBar.Visible := False;

  if ((TDCTreeOption.AlternatingRowBackground in OldFlags) <> (TDCTreeOption.AlternatingRowBackground in NewFlags)) then
  begin
    if _view <> nil then
    begin
      var row: IDCRow;
      for row in _view.ActiveViewRows do
        InitRow(row);
    end;
  end;
end;

function TScrollControlWithRows.SelectionCount: Integer;
begin
  Result := _selectionInfo.SelectedRowCount;
end;

procedure TScrollControlWithRows.SelectItem(const DataItem: CObject; ClearOtherSelections: Boolean = False);
begin
  if _view = nil then Exit;

  var ix := _view.GetViewListIndex(DataItem);
  var dataIndex := _view.GetDataIndex(ix);
  if (dataIndex = -1) or _selectionInfo.IsSelected(dataIndex) then
    Exit;

  // for example when items are reset (set to nil) and after that this Select Item is called.
  if (_waitForRepaintInfo <> nil) and (TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags) then
    _waitForRepaintInfo.RowStateFlags := _waitForRepaintInfo.RowStateFlags - [TTreeRowState.RowChanged];

  if ClearOtherSelections then
    ClearSelections;

  _selectionInfo.AddToSelection(dataIndex, ix, DataItem);
end;

procedure TScrollControlWithRows.DeselectItem(const DataItem: CObject);
begin
  if _view = nil then Exit;

  var ix := _view.GetViewListIndex(DataItem);
  var dataIndex := _view.GetDataIndex(ix);
  if dataIndex = -1 then Exit;

  if _selectionInfo.IsSelected(dataIndex) then
    _selectionInfo.Deselect(dataIndex);
end;

procedure TScrollControlWithRows.ToggleDataItemSelection;
begin
  ToggleDataItemSelection(get_DataItem);
end;

procedure TScrollControlWithRows.ToggleDataItemSelection(const Item: CObject);
begin
  if _view = nil then Exit;

  var ix := _view.GetViewListIndex(Item);
  var dataIndex := _view.GetDataIndex(ix);
  if dataIndex = -1 then Exit;

  if not _selectionInfo.IsSelected(dataIndex) then
    _selectionInfo.AddToSelection(dataIndex, ix, Item) else
    _selectionInfo.Deselect(dataIndex);
end;

{$IFNDEF WEBASSEMBLY}
function TScrollControlWithRows.get_AllowNoneSelected: Boolean;
begin
  Result := _allowNoneSelected;
end;
{$ENDIF}

function TScrollControlWithRows.get_Current: Integer;
begin
  // check if a dataitem just has been set, but no realigncontent has been done yet
  if (_waitForRepaintInfo <> nil) and (TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags) then
    ForceImmeditiateRealignContent;

  Result := _selectionInfo.ViewListIndex;
end;

function TScrollControlWithRows.get_DataItem: CObject;
begin
  // check if a dataitem just has been set, but no realigncontent has been done yet
  if (_waitForRepaintInfo <> nil) and (TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags) then
    ForceImmeditiateRealignContent;

  Result := _selectionInfo.DataItem;
end;

procedure TScrollControlWithRows.UpdateVirtualYPositions(const TopVirtualYPosition: Single; const ToViewIndex: Integer = -1);
begin
  _view.ViewLoadingRemoveNonUsedRows(ToViewIndex, True);

  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.View.ViewLoadingRemoveNonUsedRows(ToViewIndex, True);

  var virtualYPosition := TopVirtualYPosition + _scrollbarRefToTopHeightChangeSinceViewLoading;
  var row: IDCRow;
  for row in _view.ActiveViewRows do
  begin
    row.VirtualYPosition := virtualYPosition;

    if _isMasterSynchronizer then
      _activeRowHeightSynchronizer.View.ActiveViewRows[row.ViewPortIndex].VirtualYPosition := virtualYPosition;

    if (row.ViewPortIndex = ToViewIndex) then
      Exit;

    virtualYPosition := virtualYPosition + _view.GetRowHeight(row.ViewListIndex);
  end;
end;

procedure TScrollControlWithRows.CalculateScrollBarMax;
begin
  if _view <> nil then
  begin
    inc(_scrollUpdateCount);
    try
      var newHeight := CMath.Max(_totalDataHeight, _content.Height);
      if (_realignState > TRealignState.Realigning) or (newHeight > _vertScrollBar.Max) then
        _vertScrollBar.Max := newHeight;
    finally
      dec(_scrollUpdateCount);
    end;

    UpdateRowHeightSynchronizerScrollbar;
  end;

  CheckVertScrollbarVisibility;
end;

function TScrollControlWithRows.CanRealignContent: Boolean;
begin
  Result := inherited;

  if Result and (_activeRowHeightSynchronizer <> nil) and not _activeRowHeightSynchronizer._isMasterSynchronizer then
  begin
    // avoid circular loop
    var setMaster := not _isMasterSynchronizer;
    if setMaster then
      _isMasterSynchronizer := True;
    try
      Result := _activeRowHeightSynchronizer.CanRealignContent;
    finally
      if setMaster then
        _isMasterSynchronizer := False;
    end;
  end;
end;

procedure TScrollControlWithRows.CheckVertScrollbarVisibility;
begin
  var makeVisible := (_view <> nil) and (not (TDCTreeOption.HideVScrollBar in _options)) and (_vertScrollBar.ViewPortSize + IfThen(_horzScrollBar.Visible, _horzScrollBar.Height, 0) < _vertScrollBar.Max);
  if _vertScrollBar.Visible = makeVisible then
    Exit;

  inc(_updateCount);
  try
    _vertScrollBar.Visible := makeVisible;
  finally
    dec(_updateCount);
  end;
end;

procedure TScrollControlWithRows.ClearCurrentSelection;
begin
  if _selectionInfo <> nil then
    _selectionInfo.UpdateSingleSelection(-1, -1, nil);
end;

procedure TScrollControlWithRows.ClearSelections;
begin
  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.External;
  _selectionInfo.BeginUpdate;
  try
    var cln := _selectionInfo.Clone;
    _selectionInfo.ClearAllSelections;

    if not _allowNoneSelected then
      SetSingleSelectionIfNotExists;
  finally
    _selectionInfo.EndUpdate;
  end;
end;

function TScrollControlWithRows.CreateSelectioninfoInstance: IRowSelectionInfo;
begin
  Result := TRowSelectionInfo.Create(Self);
end;

function TScrollControlWithRows.CurrentRowIsExpanded: Boolean;
begin
  Result := RowIsExpanded(get_Current);
end;

procedure TScrollControlWithRows.CollapseCurrentRow;
begin
  DoCollapseOrExpandRow(get_Current, False);
end;

procedure TScrollControlWithRows.ExecuteKeyFromExternal(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  KeyDown(Key, KeyChar, Shift);
end;

procedure TScrollControlWithRows.ExpandCurrentRow;
begin
  DoCollapseOrExpandRow(get_Current, True);
end;

function TScrollControlWithRows.SortActive: Boolean;
begin
  Result := (_view <> nil) and (_view.GetSortDescriptions <> nil) and (_view.GetSortDescriptions.Count > 0)
end;

procedure TScrollControlWithRows.StartMasterSynchronizer;
begin
  if (_rowHeightSynchronizer <> nil) and not _rowHeightSynchronizer._isMasterSynchronizer then
  begin
    if not ControlEffectiveVisible(_rowHeightSynchronizer) then
    begin
      _activeRowHeightSynchronizer := nil;
      _rowHeightSynchronizer._activeRowHeightSynchronizer := nil;
      Exit;
    end;

    _activeRowHeightSynchronizer := _rowHeightSynchronizer;
    _rowHeightSynchronizer._activeRowHeightSynchronizer := Self;

    _isMasterSynchronizer := True;

    // let the master take care of the sorting/filtering/current
    _activeRowHeightSynchronizer._waitForRepaintInfo := nil;
    _activeRowHeightSynchronizer._realignContentRequested := False;
    _activeRowHeightSynchronizer._scrollingType := _scrollingType;
    inc(_activeRowHeightSynchronizer._threadIndex);
  end;
end;

procedure TScrollControlWithRows.StopMasterSynchronizer;
begin
  if _isMasterSynchronizer then
  begin
    _activeRowHeightSynchronizer._realignContentTime := _realignContentTime;
    _isMasterSynchronizer := False;
    _activeRowHeightSynchronizer._scrollingType := _scrollingType;
  end;

  if _rowHeightSynchronizer <> nil then
    _rowHeightSynchronizer._activeRowHeightSynchronizer := nil;
  _activeRowHeightSynchronizer := nil;
end;

function TScrollControlWithRows.FiltersActive: Boolean;
begin
  Result := (_view <> nil) and (_view.GetFilterDescriptions <> nil) and (_view.GetFilterDescriptions.Count > 0)
end;

constructor TScrollControlWithRows.Create(AOwner: TComponent);
begin
  inherited;

  _selectionType := TSelectionType.RowSelection;

  _selectionInfo := CreateSelectionInfoInstance;
  _rowHeightDefault := 30;

  _options := [TreeOption_ShowHeaders, TreeOption_ShowHeaderGrid];

  _itemType := &Type.Unknown;

  _hoverRect := TRectangle.Create(_content);
  _hoverRect.Stored := False;
  _hoverRect.Align := TAlignLayout.None;
  _hoverRect.HitTest := False;
  _hoverRect.Visible := False;
  _hoverRect.Stroke.Kind := TBrushKind.None;
  _hoverRect.Fill.Color := DEFAULT_ROW_HOVER_COLOR;
  _content.AddObject(_hoverRect);
end;

function TScrollControlWithRows.CreateDummyRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow;
begin
  Result := DoCreateNewRow;
  Result.DataItem := FromSelectionInfo.DataItem;
  Result.DataIndex := FromSelectionInfo.DataIndex;
  Result.ViewListIndex := FromSelectionInfo.ViewListIndex;
end;

function TScrollControlWithRows.get_DataList: IList;
begin
  Result := _dataList;
end;

function TScrollControlWithRows.get_DataModelView: IDataModelView;
begin
  Result := _dataModelView;
end;

function TScrollControlWithRows.get_Model: IObjectListModel;
begin
  Result := _model;
end;

function TScrollControlWithRows.get_NotSelectableItems: IList;
begin
  if Length(_selectionInfo.NotSelectableDataIndexes) = 0 then
    Exit(nil);

  var l: List<CObject> := CList<CObject>.Create(Length(_selectionInfo.NotSelectableDataIndexes));
  var dataIndex: Integer;
  for dataIndex in _selectionInfo.NotSelectableDataIndexes do
    l.Add(_view.OriginalData[dataIndex]);

  Result := l as IList;
end;

function TScrollControlWithRows.get_rowHeightDefault: Single;
begin
  if _rowHeightFixed > 0 then
    Result := _rowHeightFixed
  else begin
    if _rowHeightDefault = -1 {dynamic height} then
    begin
      var txt := DataControlClassFactory.CreateText(Self);
      try
        (txt as ICaption).Text := 'Ag';
        _rowHeightDefault := TextControlHeight(txt, (txt as ITextSettings).TextSettings, 'Ag') + (2*ROW_CONTENT_MARGIN);

        if (_rowHeightMax > 0) and (_rowHeightMax < _rowHeightDefault) then
          _rowHeightDefault := _rowHeightMax;
      finally
        txt.Free;
      end;
    end;

    Result := _rowHeightDefault;
  end;
end;

function TScrollControlWithRows.get_RowHeightSynchronizer: TScrollControlWithRows;
begin
  Result := _rowHeightSynchronizer;
end;

procedure TScrollControlWithRows.set_DataList(const Value: IList);
begin
//  if CObject.ReferenceEquals(_dataList, Value) then
//    Exit;

  if GetDataModelView <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    GetDataModelView.CurrencyManager.CurrentRowChanged.Remove(DataModelViewRowChanged);
    GetDataModelView.RowPropertiesChanged.Remove(DataModelViewRowPropertiesChanged);
    {$ELSE}
    GetDataModelView.CurrencyManager.CurrentRowChanged -= DataModelViewRowChanged;
    GetDataModelView.RowPropertiesChanged -= DataModelViewRowPropertiesChanged;
    {$ENDIF}
  end;

  _view := nil;

  _dataList := Value;
  if _dataList <> nil then
  begin
    _selectionInfo.Clear;

    inc(_scrollUpdateCount);
    try
      _vertScrollBar.Value := 0;
      _horzScrollbar.Value := 0;

      UpdateRowHeightSynchronizerScrollbar;
    finally
      dec(_scrollUpdateCount);
    end;

    GenerateView;

    if GetDataModelView <> nil then
    begin
      {$IFNDEF WEBASSEMBLY}
      GetDataModelView.CurrencyManager.CurrentRowChanged.Add(DataModelViewRowChanged);
      GetDataModelView.RowPropertiesChanged.Add(DataModelViewRowPropertiesChanged);
      {$ELSE}
      GetDataModelView.CurrencyManager.CurrentRowChanged += DataModelViewRowChanged;
      GetDataModelView.RowPropertiesChanged += DataModelViewRowPropertiesChanged;
      {$ENDIF}
    end;
  end else
    _dataModelView := nil;
end;

procedure TScrollControlWithRows.set_DataModelView(const Value: IDataModelView);
begin
  _dataModelView := Value;

  if _dataModelView = nil then
  begin
    set_DataList(nil);
    Exit;
  end;

  var data: IList;
  if not interfaces.Supports<IList>(_dataModelView.DataModel, data) then
    data := _dataModelView.DataModel.Rows as IList;

  set_DataList(data);
end;

procedure TScrollControlWithRows.set_Model(const Value: IObjectListModel);
begin
  if _model = Value then
    Exit;

  if _model <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    _model.OnContextChanging.Remove(ModelListContextChanging);
    _model.OnContextChanged.Remove(ModelListContextChanged);
    {$ELSE}
    _model.OnContextChanging -= ModelListContextChanging;
    _model.OnContextChanged -= ModelListContextChanged;
    {$ENDIF}

    if _model.ListHoldsObjectType or (_model.ObjectModelContext <> nil) then
    begin
      {$IFNDEF WEBASSEMBLY}
      _model.ObjectModelContext.OnPropertyChanged.Remove(ModelContextPropertyChanged);
      _model.ObjectModelContext.OnContextChanged.Remove(ModelContextChanged);
      {$ELSE}
      _model.ObjectModelContext.OnPropertyChanged -= ModelContextPropertyChanged;
      _model.ObjectModelContext.OnContextChanged -= ModelContextChanged;
      {$ENDIF}
    end;
  end;

  _model := Value;

  if _model <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    _model.OnContextChanging.Add(ModelListContextChanging);
    _model.OnContextChanged.Add(ModelListContextChanged);
    {$ELSE}
    _model.OnContextChanging += ModelListContextChanging;
    _model.OnContextChanged += ModelListContextChanged;
    {$ENDIF}

    if _model.ListHoldsObjectType or (_model.ObjectModelContext <> nil) then
    begin
      {$IFNDEF WEBASSEMBLY}
      _model.ObjectModelContext.OnPropertyChanged.Add(ModelContextPropertyChanged);
      _model.ObjectModelContext.OnContextChanged.Add(ModelContextChanged);
      {$ELSE}
      _model.ObjectModelContext.OnPropertyChanged += ModelContextPropertyChanged;
      _model.ObjectModelContext.OnContextChanged += ModelContextChanged;
      {$ENDIF}
    end;

    if _model.Context <> nil then
      ModelListContextChanged(_model, _model.Context);
  end else
    set_DataList(nil);
end;

procedure TScrollControlWithRows.set_NotSelectableItems(const Value: IList);
begin
  if (Value = nil) or (Value.Count = 0) then
  begin
    _selectionInfo.NotSelectableDataIndexes := [];
    Exit;
  end;

  var arr: TDataIndexArray;
  SetLength(arr, 0);

  //var item: CObject;
  for var item in Value do
  begin
    var ix := _view.GetDataIndex(item);
    if ix <> -1 then
    begin
      SetLength(arr, Length(arr) + 1);
      arr[High(arr)] := ix;
    end;
  end;

  _selectionInfo.NotSelectableDataIndexes := arr;
end;

procedure TScrollControlWithRows.set_Options(const Value: TDCTreeOptions);
begin
  if _options = Value then
    Exit;

  var oldFlags := _options;
  _options := Value;
  HandleTreeOptionsChange(oldFlags, _options);
end;

procedure TScrollControlWithRows.set_RowHeightDefault(const Value: Single);
begin
  _rowHeightDefault := Value;
  if (_rowHeightDefault > 0) and (_rowHeightMax > 0) then
  begin
    if _rowHeightMax < _rowHeightDefault then
      _rowHeightMax := _rowHeightDefault;
  end;
end;

procedure TScrollControlWithRows.set_RowHeightFixed(const Value: Single);
begin
  _rowHeightFixed := Value;
  if (_rowHeightFixed > 0) and (_rowHeightMax > 0) then
  begin
    if _rowHeightMax < _rowHeightFixed then
      _rowHeightMax := _rowHeightFixed;
  end;
end;

procedure TScrollControlWithRows.set_RowHeightMax(const Value: Single);
begin
  _rowHeightMax := Value;
  if (_rowHeightMax > 0) then
  begin
    if _rowHeightMax < _rowHeightFixed then
      _rowHeightFixed := _rowHeightMax;
    if _rowHeightMax < _rowHeightDefault then
      _rowHeightDefault := _rowHeightMax;
  end;
end;

procedure TScrollControlWithRows.set_RowHeightSynchronizer(const Value: TScrollControlWithRows);
begin
  _rowHeightSynchronizer := Value;
end;

procedure TScrollControlWithRows.DataModelViewRowPropertiesChanged(Sender: TObject; Args: RowPropertiesChangedEventArgs);
begin
  if HasInternalSelectCount then
    Exit;

  if (Args.Row = nil) or (Args.OldProperties.Flags = Args.NewProperties.Flags) then
    Exit;

  // The same datamodel can be used on multiple datamodelviews..
  // therefor carefully check if the dmv and the row exist..
  var dmv := GetDataModelView;
  if dmv = nil then Exit;

  var drv := dmv.FindRow(Args.Row);
  if drv = nil then Exit;

  var doExpand := RowFlag.Expanded in Args.NewProperties.Flags;
  if drv.DataView.IsExpanded[drv.Row] <> DoExpand then
    DoCollapseOrExpandRow(drv.ViewIndex, doExpand) else
    ResetView(drv.ViewIndex);
end;

procedure TScrollControlWithRows.DataModelViewRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);
begin
  if _internalSelectCount > 0 then
    Exit;

  if ((_activeRowHeightSynchronizer <> nil) and (_activeRowHeightSynchronizer._internalSelectCount > 0)) then
  begin
    var syncSelInfo := _activeRowHeightSynchronizer._selectionInfo;
    _selectionInfo.BeginUpdate;
    try
      _selectionInfo.UpdateLastSelection(syncSelInfo.DataIndex, syncSelInfo.ViewListIndex, syncSelInfo.DataItem);
    finally
      _selectionInfo.EndUpdate(True);
    end;

    var row: IDCRow;
    for row in _view.ActiveViewRows do
      VisualizeRowSelection(row);
  end else
    set_Current(Args.NewIndex);
end;

procedure TScrollControlWithRows.ModelContextChanged(const Sender: IObjectModelContext; const Context: CObject);
begin
  if HasInternalSelectCount then
    Exit;

  var dItem := get_DataItem;

  var drv: IDataRowView;
  if dItem.TryAsType<IDataRowView>(drv) then
    dItem := drv.Row.Data;

  if not CObject.Equals(dItem, Context) then
    set_DataItem(Context);
end;

procedure TScrollControlWithRows.ModelContextPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
begin
  if not Self.IsUpdating and (_updateCount = 0) then
    DoDataItemChangedInternal(Context);
end;

procedure TScrollControlWithRows.ModelListContextChanged(const Sender: IObjectListModel; const Context: IList);
begin
  set_DataList(_model.Context);

  {$IFNDEF WEBASSEMBLY}
  if not _model.ListHoldsObjectType and (Context <> nil) then
    _model.ObjectModelContext.OnContextChanged.Add(ModelContextChanged);
  {$ELSE}
  if not _model.ListHoldsObjectType and (Context <> nil) then
    _model.ObjectModelContext.OnContextChanged += @ModelContextChanged;
  {$ENDIF}
end;

procedure TScrollControlWithRows.ModelListContextChanging(const Sender: IObjectListModel; const Context: IList);
begin
  {$IFNDEF WEBASSEMBLY}
  if not _model.ListHoldsObjectType and (Sender.Context <> nil) then
    _model.ObjectModelContext.OnContextChanged.Remove(ModelContextChanged);
  {$ELSE}
  if not _model.ListHoldsObjectType and (Sender.Context <> nil) then
    _model.ObjectModelContext.OnContextChanged -= @ModelContextChanged;
  {$ENDIF}
end;

procedure TScrollControlWithRows.BeforePainting;
begin
  // if DoRealignContent should be called, but the paint event is earlier at it's "_activeRowHeightSynchronizer" control..
  // make sure the calculations are done first
  if not _realignContentRequested and (_activeRowHeightSynchronizer <> nil) and _activeRowHeightSynchronizer._realignContentRequested then
    _activeRowHeightSynchronizer.BeforePainting;

  inherited;
end;

procedure TScrollControlWithRows.BeforeRealignContent;

  procedure UpdateSelectionInfo(const ScrolControlWithRows: TScrollControlWithRows; ViewListIndex: Integer);
  begin
    ScrolControlWithRows._selectionInfo.BeginUpdate;
    try
      ScrolControlWithRows._selectionInfo.UpdateLastSelection(ScrolControlWithRows._view.GetDataIndex(ViewListIndex), ViewListIndex, ScrolControlWithRows._view.GetViewList[ViewListIndex]);
    finally
      ScrolControlWithRows._selectionInfo.EndUpdate(True {ignore events});
    end;
  end;

var
  sortChanged: Boolean;
  filterChanged: Boolean;

begin
  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.BeforeRealignContent;

  if _view = nil then
    Exit;

  if _isMasterSynchronizer then
  begin
    var bestDefault := CMath.Max(_rowHeightDefault, _activeRowHeightSynchronizer._rowHeightDefault);
    var bestFixed := CMath.Max(_rowHeightFixed, _activeRowHeightSynchronizer._rowHeightFixed);

    _rowHeightDefault := bestDefault;
    _activeRowHeightSynchronizer._rowHeightDefault := bestDefault;
    _rowHeightFixed := bestFixed;
    _activeRowHeightSynchronizer._rowHeightFixed := bestFixed;
  end;

  sortChanged := (_waitForRepaintInfo <> nil) and (TTreeRowState.SortChanged in _waitForRepaintInfo.RowStateFlags);
  filterChanged := (_waitForRepaintInfo <> nil) and (TTreeRowState.FilterChanged in _waitForRepaintInfo.RowStateFlags);

  inherited;

  var repInfo := _waitForRepaintInfo;
  var customDataItem: CObject := get_DataItem;

  if repInfo <> nil then
  begin
    if sortChanged then
      _view.ApplySort(repInfo.SortDescriptions);

    if filterChanged then
      _view.ApplyFilter(repInfo.FilterDescriptions);

    // reset view
    if (sortChanged or filterChanged) then
    begin
      ResetView;

      // CalculateScrollBarMax is already done in inherited, but at that point the view is not correct yet
      if filterChanged then
        CalculateScrollBarMax;
    end;

    var viewIndex: Integer := -1;
    if TTreeRowState.RowChanged in repInfo.RowStateFlags then
    begin
      if repInfo.DataItem <> nil then
        viewIndex := _view.GetViewListIndex(repInfo.DataItem) else
        viewIndex := repInfo.Current;
    end;

    // if filter changed, we try to scroll back to the last selected dataitem
    if (viewIndex = -1) and filterChanged and (customDataItem <> nil) then
      viewIndex := _view.GetViewListIndex(customDataItem);

    if (viewIndex <> -1) and (_view.ViewCount > 0) then
    begin
      UpdateSelectionInfo(self, viewIndex);
      if _isMasterSynchronizer then
        UpdateSelectionInfo(_activeRowHeightSynchronizer, viewIndex);
    end;
  end;

  // if not in edit mode, the view will be reset
  // otherwise nothing is done till the endedit is called
  if _resetViewRec.DoResetView then
    ResetView(_resetViewRec.FromIndex, _resetViewRec.OneRowOnly);
end;

procedure TScrollControlWithRows.BeginDrag;
begin
  BeginAutoDrag;
end;

procedure TScrollControlWithRows.AlignRowsFromReferenceToBottom(const TopReferenceRow: IDCRow; var SpaceForRows: Single);
begin
  var thisRow := TopReferenceRow;
  var rowIndex := TopReferenceRow.ViewPortIndex;
  var createdRowsCount := _view.ActiveViewRows.Count;

  while thisRow <> nil do
  begin
    InitRow(thisRow, False);
    spaceForRows := spaceForRows - thisRow.Height;

    if (spaceForRows <= 0) or (thisRow.ViewListIndex = _view.ViewCount - 1) then
      Exit;

    inc(rowIndex);
    if rowIndex > createdRowsCount - 1 then
      thisRow := _view.InsertNewRowBeneeth else
      thisRow := _view.ActiveViewRows[rowIndex];
  end;
end;

procedure TScrollControlWithRows.AlignRowsFromReferenceToTop(const BottomReferenceRow: IDCRow; var SpaceForRows: Single);
begin
  var thisRow := BottomReferenceRow;
  var rowIndex := BottomReferenceRow.ViewPortIndex;

  while thisRow <> nil do
  begin
    InitRow(thisRow, True);
    spaceForRows := spaceForRows - thisRow.Height;

    if (spaceForRows <= 0) or (thisRow.ViewListIndex = 0) then
      Exit;

    dec(rowIndex);
    if rowIndex < 0 then
      thisRow := _view.InsertNewRowAbove else
      thisRow := _view.ActiveViewRows[rowIndex];
  end;
end;

procedure TScrollControlWithRows.CreateAndSynchronizeSynchronizerRow(const Row: IDCRow);
begin
  if _activeRowHeightSynchronizer = nil then
    Exit; // nothing to do


  var otherRow := _activeRowHeightSynchronizer.View.GetActiveRowIfExists(Row.ViewListIndex);
  if _isMasterSynchronizer then
  begin
    if otherRow = nil then
      otherRow := _activeRowHeightSynchronizer.View.InsertNewRowFromIndex(Row.ViewListIndex, Row.ViewPortIndex);

    _activeRowHeightSynchronizer.View.ReindexActiveRow(otherRow);

    _activeRowHeightSynchronizer.InitRow(otherRow, False);
  end;

  if otherRow.Height > Row.Height then
    Row.Control.Height := otherRow.Height;
end;

procedure TScrollControlWithRows.InnerInitRow(const Row: IDCRow);
begin
  // nothing to do
end;

procedure TScrollControlWithRows.InitRow(const Row: IDCRow; const IsAboveRefRow: Boolean = False);
begin
  var rowInfo := _view.RowLoadedInfo(Row.ViewListIndex);
  var rowNeedsReload := Row.IsScrollingIntoView or not rowInfo.InnerCellsAreApplied or (rowInfo.ControlNeedsResizeSoft and (_scrollingType = TScrollingType.None));

  if rowInfo.ControlNeedsResizeForced then
  begin
    rowInfo := _view.NotifyRowControlsNeedReload(Row, False {reset force realign this row});
    rowNeedsReload := True;
  end;

  Row.OwnerIsScrolling := _scrollingType <> TScrollingType.None;

  var oldRowHeight: Single := -1;
  if rowNeedsReload then
  begin
    oldRowHeight := _view.GetRowHeight(Row.ViewListIndex);
    if Row.Control = nil then
    begin
      var rect := DataControlClassFactory.CreateRowRect(_content);
      rect.ClipChildren := True;
      rect.HitTest := False;
      rect.Align := TAlignLayout.None;

      Row.Control := rect;

      _content.AddObject(Row.Control);

      var rr := Row.Control as TRectangle;
      if (TreeOption_ShowHorzGrid in _options) then
        rr.Sides := [TSide.Bottom] else
        rr.Sides := [];
    end;

    DataControlClassFactory.HandleRowBackground(TRectangle(Row.Control), (TreeOption_AlternatingRowBackground in _options) and not Row.IsOddRow);
    Row.Control.Position.X := 0;

    if not rowInfo.ControlNeedsResizeSoft then
      Row.Control.Height := oldRowHeight else
      Row.Control.Height := get_rowHeightDefault;

    if rowNeedsReload then
    begin
      InnerInitRow(Row);
      DoRowLoaded(Row);
    end;
  end;

  Row.Control.Width := _content.Width;
  CreateAndSynchronizeSynchronizerRow(Row);

  if rowNeedsReload then
  begin
    var rowHeightChanged := not SameValue(oldRowHeight, Row.Control.Height);
    if rowHeightChanged and (_scrollingType = TScrollingType.WithScrollBar) then
    begin
      // We do not!!!! accept a row height change while user is scrolling with scrollbar
      // because this will give flickering. AFter scroll release the row is reloaded automatically
      rowHeightChanged := False;
      row.Control.Height := oldRowHeight;
    end;

    VisualizeRowSelection(Row);

    if rowHeightChanged then
    begin
      var change := (Row.Height - oldRowHeight);
      _scrollbarMaxChangeSinceViewLoading := _scrollbarMaxChangeSinceViewLoading + change;
      if IsAboveRefRow then
        _scrollbarRefToTopHeightChangeSinceViewLoading := _scrollbarRefToTopHeightChangeSinceViewLoading + change;
    end;
  end else
    VisualizeRowSelection(Row);

  rowInfo := _view.RowLoadedInfo(Row.ViewListIndex) {reload the rowInfo, for it can be changed};

  var softRowHeightNeedsResizeAfterScrolling := rowInfo.ControlNeedsResizeSoft and (_scrollingType = TScrollingType.WithScrollBar); //(_scrollingType = TScrollingType.WithScrollBar);
  _view.RowLoaded(Row, softRowHeightNeedsResizeAfterScrolling);

  if rowInfo.ControlNeedsResizeForced then
    RestartWaitForRealignTimer(250, True {only realign when scrolling stopped});
end;

procedure TScrollControlWithRows.UpdateHoverRect(MousePos: TPointF);
begin
  if (TreeOption_HideHoverEffect in _options) then
  begin
    _hoverRect.Visible := False;
    Exit;
  end;

  var row := GetRowByLocalY(MousePos.Y);
  _hoverRect.Visible := (row <> nil) and (_selectionType <> TSelectionType.HideSelection) and _selectionInfo.CanSelect(row.DataIndex);
  if not _hoverRect.Visible then
    Exit;

  _hoverRect.Position.Y := row.Control.Position.Y;
  _hoverRect.Position.X := row.Control.Position.X;
  _hoverRect.Height := row.Height;
  _hoverRect.Width := row.Control.Width;
  _hoverRect.BringToFront;
end;

procedure TScrollControlWithRows.UpdateScrollAndSelectionByKey(var Key: Word; Shift: TShiftState);
begin
  if Key in [vkPrior, vkNext] then
  begin
    // in case the up/down button stays pressed, and the tree is not quick enough to repaint before it recalculates again
    if RealignedButNotPainted then
    begin
      Key := 0;
      Exit;
    end;

    var viewListindex: Integer;

    if Key = vkPrior then
    begin
      if Current = 0 then
        Exit;

      var rowZero := _view.ActiveViewRows[0];
      if rowZero.ViewListIndex = 0 then
        Current := 0
      else begin
        var stopY := CMath.Max(rowZero.VirtualYPosition + rowZero.Height - 2, _vertScrollBar.ViewportSize);
        var startY := stopY - _vertScrollBar.ViewportSize;

        RealignFromSelectionChange(startY, stopY, TCalculateViewFrom.Bottom);

        viewListIndex := _view.ActiveViewRows[0].ViewListIndex;
        InternalSetCurrent(viewListIndex, TSelectionEventTrigger.Key, Shift);
      end;

      Key := 0;
      Exit;
    end

    else if Key = vkNext then
    begin
      if Current = _view.ViewCount - 1 then
        Exit;

      var rowBottom := _view.ActiveViewRows[_view.ActiveViewRows.Count - 1];

      var startY := CMath.Min(rowBottom.VirtualYPosition + 2{+ rowBottom.Height}, _vertScrollBar.Max - _vertScrollBar.ViewportSize);
      var stopY := startY + _vertScrollBar.ViewportSize;

      RealignFromSelectionChange(startY, stopY, TCalculateViewFrom.Top);

      viewListIndex := _view.ActiveViewRows[_view.ActiveViewRows.Count - 1].ViewListIndex;
      InternalSetCurrent(viewListIndex, TSelectionEventTrigger.Key, Shift);

      Key := 0;
      Exit;
    end;
  end;


  var rowViewListIndex := GetRowViewListIndexByKey(Key, Shift);
  if _selectionInfo.ViewListIndex <> rowViewListIndex then
  begin
    // in case the up/down button stays pressed, and the tree is not quick enough to repaint before it recalculates again
    if not RealignedButNotPainted then
      InternalSetCurrent(rowViewListIndex, TSelectionEventTrigger.Key, Shift);

    Key := 0;
  end;
end;

procedure TScrollControlWithRows.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if _view = nil then
  begin
    inherited;
    Exit;
  end;

  if (_view.ActiveViewRows.Count = 0) then
  begin
    inherited;
    Exit;
  end;

  if (Key = vkA) and (ssCtrl in Shift) then
  begin
    SelectAll;
    Key := 0;
  end

  else
    UpdateScrollAndSelectionByKey({var} Key, Shift);

  if Key <> 0 then
    inherited;
end;

function TScrollControlWithRows.ListHoldsOrdinalType: Boolean;
begin
  {$IFNDEF WEBASSEMBLY}
  Result := not (&Type.GetTypeCode(GetItemType) in [TypeCode.&Object, TypeCode.&Interface, TypeCode.&Array]);
  {$ELSE}
  var tc := &Type.GetTypeCode(GetItemType);
  Result := not ((tc = TypeCode.Object) or GetItemType.IsInterface or GetItemType.IsArray);
  {$ENDIF}
end;

procedure TScrollControlWithRows.DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean);
begin
  if HasInternalSelectCount then
    Exit;

  var drv: IDataRowView;
  if not _view.GetViewList[ViewListIndex].TryAsType<IDataRowView>(drv) then
    Exit;

  var virtualYPos: Single;
  if DoExpand then
  begin
    var diDummy: CObject;
    _view.GetFastPerformanceRowInfo(ViewListIndex, {out} diDummy, {out} virtualYPos);
  end;

  inc(_internalSelectCount);
  try
    drv.DataView.IsExpanded[drv.Row] := DoExpand;
  finally
    dec(_internalSelectCount);
  end;

  ResetAndRealign(ViewListIndex);

  if DoExpand then
  begin
    // check if children fit in current view, otherwise scroll parent up...
    var spaceAvailableForChildren := _vertScrollBar.ViewportSize - (virtualYPos - _vertScrollBar.Value);
    var spaceNeeded := CalculateAverageRowHeight * (drv.DataView.DataModel.ChildCount(drv.Row) + 1 {for parent});

    if spaceNeeded > spaceAvailableForChildren then
    begin
      var scrollBy := CMath.Min(spaceNeeded - spaceAvailableForChildren, virtualYPos - _vertScrollBar.Value);
      ScrollManualTryAnimated(-Trunc(scrollBy), False);
    end;
  end;
end;

procedure TScrollControlWithRows.OnItemAddedByUser(const Item: CObject; Index: Integer);
begin
  if (_view <> nil) and (_view.GetDataIndex(Item) = -1) then
    _view.GetViewList.Insert(Index, Item);

  if (_view <> nil) then
  begin
    _resetViewRec := TResetViewRec.CreateFrom(Index, False, True {recalculate the view}, _resetViewRec);
    ResetView(Index);

    if _view.HasCustomDataList then
      _view.RecreateCustomDataList(_dataList);

    _view.RecalcSortedRows;
  end;
end;

procedure TScrollControlWithRows.OnItemRemovedByUser(const Item: CObject; Index: Integer);
begin
  if (_view <> nil) then
  begin
    var vlIndex := _view.GetViewListIndex(Item);
    if vlIndex <> -1 then
      _view.GetViewList.RemoveAt(vlIndex);
  end;

  if (_view <> nil) then
  begin
    _resetViewRec := TResetViewRec.CreateFrom(Index, False, True {recalculate the view}, _resetViewRec);
    ResetView(Index);

    if _view.HasCustomDataList then
      _view.RecreateCustomDataList(_dataList);
  end;
end;

procedure TScrollControlWithRows.OnSelectionInfoChanged;
begin
  if (_realignState in [TRealignState.Waiting, TRealignState.BeforeRealign]) then
    Exit;

  ScrollSelectedIntoView(_selectionInfo);

  AtomicIncrement(_internalSelectCount);
  try
    if (_model <> nil) then
    begin
      if SelectionCount > 1 then
        _model.MultiSelect.Context := SelectedItems else
        _model.MultiSelect.Context := nil;

      var convertedDataItem := ConvertToDataItem(Self.DataItem);
      if _model.ObjectContext = convertedDataItem then
        _model.ObjectContext := nil; // trigger a ContextChanged event for multiselect change event

      _model.ObjectContext := convertedDataItem;
    end
    else if (GetDataModelView <> nil) and (Self.DataItem <> nil) and (Self.DataItem.IsOfType<IDataRowView>) then
      GetDataModelView.CurrencyManager.Current := Self.DataItem.AsType<IDataRowView>.ViewIndex;
  finally
    AtomicDecrement(_internalSelectCount);
  end;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    VisualizeRowSelection(row);
end;

function TScrollControlWithRows.ConvertedDataItem: CObject;
begin
  Result := ConvertToDataItem(get_DataItem);
end;

function TScrollControlWithRows.ConvertToDataItem(const Item: CObject): CObject;
begin
  var drv: IDataRowView;
  if ViewIsDataModelView and Item.TryAsType<IDataRowView>(drv) then
    Exit(drv.Row.Data);

  Result := Item;
end;

function TScrollControlWithRows.ViewIsDataModelView: Boolean;
begin
  Result := (_dataModelView <> nil) or interfaces.Supports<IDataModel>(_dataList);
end;

procedure TScrollControlWithRows.VisualizeRowSelection(const Row: IDCRow);
begin
  if (_selectionType <> TSelectionType.HideSelection) then
    Row.UpdateSelectionVisibility(_selectionInfo, Self.IsFocused);
end;

procedure TScrollControlWithRows.OnViewChanged;
begin
  if (_activeRowHeightSynchronizer <> nil) and not _isMasterSynchronizer then
  begin
    if not _activeRowHeightSynchronizer._isMasterSynchronizer then
      RefreshControl(True);

    Exit;
  end;

  if not CanRealignContent then
    Exit;

  ResetAndRealign;

  if _selectionInfo.DataItem <> nil then
    Self.set_DataItem(_selectionInfo.DataItem);
end;

function TScrollControlWithRows.CalculateAverageRowHeight: Single;
begin
  if _rowHeightFixed > 0 then
    Exit(_rowHeightFixed);

  var totalHeight: Single := 0;
  var count: Integer := 0;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
  begin
    totalHeight := totalHeight + row.Height;
    inc(count);
  end;

  Result := totalHeight / count;
end;

procedure TScrollControlWithRows.UpdateScrollBarValues(const CalculateViewFrom: TCalculateViewFrom);
begin
  if SameValue(_scrollbarMaxChangeSinceViewLoading, 0) then
    Exit;

  inc(_scrollUpdateCount);
  try
    _totalDataHeight := _totalDataHeight + _scrollbarMaxChangeSinceViewLoading;
    CalculateScrollBarMax;

    if CalculateViewFrom = TCalculateViewFrom.None then
    begin
      var scrollBarIsAtBottom := not SameValue(_vertScrollBar.Value, 0) and (_vertScrollBar.Value + _vertScrollBar.ViewportSize >= _vertScrollBar.Max - 1);
      var scrollBarWillGetHigher := _scrollbarMaxChangeSinceViewLoading > 0;

      if not scrollBarIsAtBottom then
        _vertScrollBar.Value := _vertScrollBar.Value + _scrollbarRefToTopHeightChangeSinceViewLoading
      else if scrollBarWillGetHigher then
        _vertScrollBar.Value := _vertScrollBar.Value + _scrollbarMaxChangeSinceViewLoading
      else ; // do nothing, for setting _vertScrollBar.Max lower already updated _vertScrollbar.Value
    end;
  finally
    dec(_scrollUpdateCount);
  end;
end;

procedure TScrollControlWithRows.AssignSelection(const SelectedItems: IList);
begin
  if (SelectedItems = nil) or (SelectedItems.Count = 0) then
    Exit;

  _selectionInfo.BeginUpdate;
  try
    _selectionInfo.ClearAllSelections;

    if (not (TreeOption_MultiSelect in _options)) or (SelectedItems.Count = 1) then
    begin
      var viewListIndex := _view.GetViewListIndex(SelectedItems[0]);
      var dataIndex := _view.GetDataIndex(viewListIndex);

      if dataIndex <> -1 then
        _selectionInfo.UpdateSingleSelection(dataIndex, viewListIndex, SelectedItems[0]);
    end else
    begin
      //var item: CObject;
      for var item in SelectedItems do
      begin
        var viewListIndex := _view.GetViewListIndex(item);
        var dataIndex := _view.GetDataIndex(viewListIndex);

        if dataIndex <> -1 then
          _selectionInfo.AddToSelection(dataIndex, viewListIndex, item);
      end;
    end;
  finally
    _selectionInfo.EndUpdate;
  end;

  SetSingleSelectionIfNotExists;
end;

procedure TScrollControlWithRows.UpdateYPositionRows;
begin
  if (_realignState in [TRealignState.Waiting, TRealignState.BeforeRealign]) then
    Exit;

  // update YPositions
  var row: IDCRow;
  for row in _view.ActiveViewRows do
  begin
    if not SameValue(row.Control.Position.Y, row.VirtualYPosition - _vertScrollBar.Value) then
      row.Control.Position.Y := row.VirtualYPosition - _vertScrollBar.Value;
  end;

  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.UpdateYPositionRows;
end;

procedure TScrollControlWithRows.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var clickedRow := GetRowByLocalY(Y);
  if clickedRow = nil then Exit;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Click;

  InternalDoSelectRow(clickedRow, Shift);
end;

procedure TScrollControlWithRows.InternalDoSelectRow(const Row: IDCRow; Shift: TShiftState);
begin
  if CObject.Equals(get_DataItem, Row.DataItem) and ((ssCtrl in Shift) = (_selectionInfo.SelectedRowCount > 1)) and (_selectionInfo.ViewListIndex = Row.ViewListIndex {insert before and than go down}) then
  begin
    if _allowNoneSelected or (_selectionInfo.SelectedRowCount > 1) then
      _selectionInfo.Deselect(Row.DataIndex);

    Exit;
  end;

  if (TDCTreeOption.MultiSelect in _options) and (ssShift in Shift) then
  begin
    var lastSelectedIndex := _selectionInfo.ViewListIndex;

    var viewListIndex := lastSelectedIndex;
    while viewListIndex <> Row.ViewListIndex do
    begin
      _selectionInfo.AddToSelection(_view.GetDataIndex(viewListIndex), viewListIndex, _view.GetViewList[viewListIndex]);

      if lastSelectedIndex < Row.ViewListIndex then
        inc(ViewListIndex) else
        dec(ViewListIndex);
    end;

    _selectionInfo.AddToSelection(Row.DataIndex, Row.ViewListIndex, Row.DataItem);
  end
  else if (TDCTreeOption.MultiSelect in _options) and (ssCtrl in Shift) and (_selectionInfo.LastSelectionEventTrigger = TSelectionEventTrigger.Click) then
  begin
    if not _selectionInfo.IsSelected(Row.DataIndex) then
      _selectionInfo.AddToSelection(Row.DataIndex, Row.ViewListIndex, Row.DataItem) else
      _selectionInfo.Deselect(Row.DataIndex);
  end
  else
    _selectionInfo.UpdateSingleSelection(Row.DataIndex, Row.ViewListIndex, Row.DataItem);
end;

procedure TScrollControlWithRows.InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False);
begin
  _selectionInfo.LastSelectionEventTrigger := EventTrigger;

  var requestedSelection := _selectionInfo.Clone;
  requestedSelection.UpdateLastSelection(_view.GetDataIndex(Index), Index, _view.GetViewList[Index]);
  TrySelectItem(requestedSelection, Shift);
end;

function TScrollControlWithRows.IsSelected(const DataItem: CObject): Boolean;
begin
  Result := False;
  if _view = nil then Exit;

  var ix := _view.GetViewListIndex(DataItem);
  Result := _selectionInfo.IsSelected(_view.GetDataIndex(ix));
end;

procedure TScrollControlWithRows.DoViewLoadingStart(const StartY, StopY: Single);
begin
  _scrollbarMaxChangeSinceViewLoading := 0;
  _scrollbarRefToTopHeightChangeSinceViewLoading := 0;

  _view.ViewLoadingStart(StartY, StopY, get_rowHeightDefault);
  if _isMasterSynchronizer then
  begin
    _activeRowHeightSynchronizer._realignState := TRealignState.Realigning;
    _activeRowHeightSynchronizer.View.ViewLoadingStart(_view);
  end;
end;

procedure TScrollControlWithRows.DoViewPortPositionChanged;
begin
  if _hoverRect <> nil then
    _hoverRect.Visible := False;

  inherited;
end;

function TScrollControlWithRows.DraggedItems: List<CObject>;
begin
  if _dragObject <> nil then
  begin
    Result := CList<CObject>.Create;
    Result.Add(_dragObject);
  end else
    Result := SelectedItems;
end;

procedure TScrollControlWithRows.DoViewLoadingFinished;
begin
  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.View.ViewLoadingFinished;

  _view.ViewLoadingFinished;
end;

procedure TScrollControlWithRows.RealignFromSelectionChange(const StartY, StopY: Single; CalculateViewFrom: TCalculateViewFrom);
begin
  Assert(StartY >= 0);

  _scrollingType := TScrollingType.Other;
  InnerRealignContent(StartY, StopY, CalculateViewFrom);
  _scrollingType := TScrollingType.None;

  if _realignState = TRealignState.RealignDone then
  begin
    AfterRealignContent;
    RealignFinished;
  end;
end;

procedure TScrollControlWithRows.AfterRowHeightsChanged(const TopVirtualYPosition: Single; const CalculateViewFrom: TCalculateViewFrom = TCalculateViewFrom.Top);
begin
  // only needed once
  UpdateVirtualYPositions(TopVirtualYPosition);

  UpdateScrollBarValues(CalculateViewFrom);
  UpdateYPositionRows;
end;

procedure TScrollControlWithRows.InnerRealignContent(const StartY, StopY: Single; CalculateViewFrom: TCalculateViewFrom);
begin
//  AtomicIncrement(_viewChangedIndex);

  var setSynchronizerInternally := (_activeRowHeightSynchronizer <> nil) and not _activeRowHeightSynchronizer._isMasterSynchronizer and not _isMasterSynchronizer;
  if setSynchronizerInternally then
    StartMasterSynchronizer;

  Log('InnerRealignContent: start=' + StartY.ToString+'....stop=' + StopY.ToString);
  Log('InnerRealignContent: max=' + _vertScrollBar.Max.ToString);

  _content.BeginUpdate;
  try
    DoViewLoadingStart(StartY, StopY);
    try
      var topVirtualYPosition: Single := -1;

      if _view.ViewCount > 0 then
      begin
        var alignBottomTop := (StartY > 0) and
          ((StopY > _vertScrollBar.Max - _view.GetRowHeight(_view.ViewCount - 1)) or (CalculateViewFrom = TCalculateViewFrom.Bottom));

        var ix := -1;
        if (_waitForRepaintInfo <> nil) and (TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags) then
          ix := get_Current;

        var referenceRow := _view.ProvideReferenceRowForViewRange(StartY, StopY, alignBottomTop, ix);
        Log('InnerRealignContent: reference=' + referenceRow.DataItem.ToString);
        Log('InnerRealignContent: reference yPox=' + referenceRow.VirtualYPosition.ToString);

        var spaceLeftToBottom: Single := StopY - referenceRow.VirtualYPosition;
        AlignRowsFromReferenceToBottom(referenceRow, {var} spaceLeftToBottom);

        var spaceLeftToTop: Single := CMath.Max(spaceLeftToBottom, 0) + ((referenceRow.VirtualYPosition + referenceRow.Height)-StartY);
        AlignRowsFromReferenceToTop(referenceRow, {var} spaceLeftToTop);

        topVirtualYPosition := referenceRow.VirtualYPosition;
        if referenceRow.ViewPortIndex > 0 then
          for var ix2 := referenceRow.ViewPortIndex - 1 downto 0 do
              topVirtualYPosition := topVirtualYPosition - _view.GetRowHeight(_view.ActiveViewRows[ix2].ViewListIndex); // _view.ActiveViewRows[ix2].Height;
      end;

      AfterRowHeightsChanged(topVirtualYPosition, CalculateViewFrom);
    finally
      DoViewLoadingFinished;
    end;

    SetSingleSelectionIfNotExists;
  finally
    _content.EndUpdate;

    if setSynchronizerInternally then
      StopMasterSynchronizer;
  end;
end;

procedure TScrollControlWithRows.RealignContent;
begin
  if _view = nil then
    Exit;

//  if _waitingForViewChange then
//    ResetView;

  try
    inherited;
    InnerRealignContent(_vertScrollBar.Value, _vertScrollBar.Value + _vertScrollBar.ViewportSize, TCalculateViewFrom.None);
  finally
    _waitForRepaintInfo := nil;
  end;
end;

procedure TScrollControlWithRows.RealignContentStart;
begin
  inherited;

  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.RealignContentStart;

  if _view <> nil then
    _totalDataHeight := _view.TotalDataHeight(get_rowHeightDefault);
end;

procedure TScrollControlWithRows.RealignFinished;
begin
  if (_hoverRect <> nil) and _hoverRect.Visible and (_scrollingType <> TScrollingType.None) then
    _hoverRect.Visible := False;

  if _view <> nil then
  begin
    var row: IDCRow;
    for row in _view.ActiveViewRows do
      DoRowAligned(row);
  end;

  inherited;

  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.RealignFinished;
end;

procedure TScrollControlWithRows.RefreshControl(const DataChanged: Boolean = False);
begin
  if DataChanged then
  begin
    _resetViewRec := TResetViewRec.CreateFrom(-1, False, True, _resetViewRec);
    ResetView;
  end;

  inherited;
end;

procedure TScrollControlWithRows.ResetView(const FromViewListIndex: Integer = -1; ClearOneRowOnly: Boolean = False);
begin
  if _view = nil then
  begin
    _resetViewRec := TResetViewRec.CreateNull;
     Exit;
  end;

  _view.ResetView(FromViewListIndex, ClearOneRowOnly);
  if (_activeRowHeightSynchronizer <> nil) and not _activeRowHeightSynchronizer._isMasterSynchronizer and (_activeRowHeightSynchronizer.View <> nil) then
      _activeRowHeightSynchronizer.View.ResetView(FromViewListIndex, ClearOneRowOnly);

  if _resetViewRec.RecalcSortedRows then
  begin
    inc(_updateCount);
    try
      _view.RecalcSortedRows;
    finally
      dec(_updateCount);
    end;
  end;

  if (_realignState = TRealignState.RealignDone) or (_resetViewRec.RecalcSortedRows) then
    RefreshControl;

  _resetViewRec := TResetViewRec.CreateNull;
//  _waitingForViewChange := False;
end;

procedure TScrollControlWithRows.ResetAndRealign(FromIndex: Integer = -1);
begin
  var hadSync := _activeRowHeightSynchronizer <> nil;

  // only clear row info from this row and below, because all rows above stay the same!

  if not hadSync then
    StartMasterSynchronizer;
  try
    ResetView(FromIndex);
  finally
    if not hadSync then
      StopMasterSynchronizer;
  end;

  // make sure scrollbars are up-to-date
  DoRealignContent;
end;

function TScrollControlWithRows.RowIsExpanded(const ViewListIndex: Integer): Boolean;
begin
  Result := False;
  if not ViewIsDataModelView then
    Exit;

  var drv: IDataRowView;
  if not _view.GetViewList[ViewListIndex].TryAsType<IDataRowView>(drv) then
    Exit;

  Result := drv.DataView.IsExpanded[drv.Row];
end;

function TScrollControlWithRows.VisibleRows: List<IDCRow>;
begin
  Result := _view.ActiveViewRows;
end;

procedure TScrollControlWithRows.ScrollSelectedIntoView(const RequestedSelectionInfo: IRowSelectionInfo);
begin
  if _view.GetViewListIndex(RequestedSelectionInfo.DataIndex) = -1 then
    Exit;

  // scroll last selection change into view if not (fully) visible yet
  if RequestedSelectionInfo.DataItem <> nil then
  begin
    var dataItem: CObject;
    var virtualYPos: Single;

    // in case of sorting/filtering the selction is the same, but the row position is changed
    if _selectionInfo.ViewListIndex <> RequestedSelectionInfo.ViewListIndex then
    begin
      _selectionInfo.BeginUpdate;
      try
        _selectionInfo.UpdateLastSelection(RequestedSelectionInfo.DataIndex, RequestedSelectionInfo.ViewListIndex, RequestedSelectionInfo.DataItem);
      finally
        _selectionInfo.EndUpdate(True {ignore change event})
      end;
    end;

    // make sure selected row is in view
    if not _view.FastPerformanceDataIndexIsActive(_selectionInfo.DataIndex) then
    begin
      _view.GetSlowPerformanceRowInfo(_selectionInfo.ViewListIndex, {out} dataItem, {out} virtualYPos);
      var h := _view.GetRowHeight(_selectionInfo.ViewListIndex);

      if virtualYPos <= _vertScrollBar.Value then
      begin
        var startY := CMath.Max(virtualYPos + h - 1, 0);
        var stopY := CMath.Min(virtualYPos + _vertScrollBar.ViewportSize, _vertScrollBar.Max);
        RealignFromSelectionChange(startY, stopY, TCalculateViewFrom.Top)
      end
      else //if virtualYPos > _vertScrollBar.Value then
      begin
        var startY := CMath.Max(virtualYPos + 2 - _vertScrollBar.ViewportSize, 0);
        var stopY := CMath.Min(CMath.Max(virtualYPos + 2, startY + _vertScrollBar.ViewportSize), _vertScrollBar.Max);
        RealignFromSelectionChange(startY, stopY, TCalculateViewFrom.Bottom);
      end;
    end;

    var selRow := _view.GetActiveRowIfExists(_selectionInfo.ViewListIndex);

    {$IFDEF DEBUG}
    if selRow = nil then
      Exit;
      {$ENDIF}
    var yChange := 0.0;

    // if row (partly) above or fully below current view, then make it the top top row
    if (_vertScrollBar.Value > selRow.VirtualYPosition) then
      yChange := _vertScrollBar.Value - selRow.VirtualYPosition

    // else scroll row partially into view.. It will be fully visible later. At this point we do not know the exact height
    else
    begin
      if (_vertScrollBar.Value + _vertScrollBar.ViewportSize < (selRow.VirtualYPosition + selRow.Height)) and (_vertScrollBar.ViewportSize > selRow.Height) then
      begin
        // KV: 24/01/2025
        // Code dissabled, when scrolling down from the last line inside current view
        // the control should move to the next visible line.
        // The old code would make the tree 'jump' to the last line inside the current view
        yChange := _vertScrollBar.Value - ((selRow.VirtualYPosition + selRow.Height) - _vertScrollBar.ViewportSize);

        // Old code:
        //        var selectedIsViewBottom := virtualYPos > (_vertScrollBar.Max - _vertScrollBar.ViewportSize);
        //        if selectedIsViewBottom then
        //          yChange := _vertScrollBar.Value - _vertScrollBar.Max else
        //          yChange := _vertScrollBar.Value - (rowStopY - _vertScrollBar.ViewportSize);
      end;
    end;

    if not SameValue(yChange, 0) then
      ScrollManualTryAnimated(Round(yChange), False);
//    begin
//      var checkY := IfThen(yChange > 0, yChange, -yChange);
//
//      if checkY <= DefaultMoveDistance(yChange < 0 {scroll down}) then
//
//        ScrollManualInstant(Round(yChange));
//    end;

    UpdateYPositionRows;
  end;
end;

procedure TScrollControlWithRows.SelectAll;
begin
  Assert(TDCTreeOption.MultiSelect in _options);

  var currentSelection := _selectionInfo.Clone;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.External;
  _selectionInfo.BeginUpdate;
  try
    var cln := _selectionInfo.Clone;
    _selectionInfo.ClearAllSelections;

    if _view <> nil then
    begin
      var row: IDCRow;
      for row in _view.ActiveViewRows do
        _selectionInfo.AddToSelection(row.DataIndex, row.ViewListIndex, row.DataItem);
    end;

    // keep current selected item
    if cln.DataIndex <> -1 then
      _selectionInfo.AddToSelection(cln.DataIndex, cln.ViewListIndex, cln.DataItem);
  finally
    _selectionInfo.EndUpdate;
  end;
end;

function TScrollControlWithRows.SelectedItems: List<CObject>;
begin
  if _view = nil then
    Exit(nil);

  Result := CList<CObject>.Create;

  var dataIndexes := _selectionInfo.SelectedDataIndexes;
  dataIndexes.Sort;

  var ix: Integer;
  for ix in dataIndexes do
  begin
    var item := _view.OriginalData[ix];

    var dr: IDataRow;
    if ViewIsDataModelView and item.TryAsType<IDataRow>(dr) then
      Result.Add(dr.Data) else
      Result.Add(item);
  end;
end;

function TScrollControlWithRows.SelectedRowIfInView: IDCRow;
begin
  // can be that the selectedrow is out of view..
  // this function will return in that case, even if that row is still selected
  Result := _view.GetActiveRowIfExists(_selectionInfo.ViewListIndex);
end;

procedure TScrollControlWithRows.SetBasicVertScrollBarValues;
begin
  inherited;
  UpdateRowHeightSynchronizerScrollbar;
end;

procedure TScrollControlWithRows.SetSingleSelectionIfNotExists;
begin
  if _allowNoneSelected or (_view.ViewCount = 0) then
    Exit;

//  {$IFDEF DEBUG}
//  Exit;
//  {$ENDIF}

  var viewListIndex := 0;
  if _selectionInfo.HasSelection then
  begin
    viewListIndex := _view.GetViewListIndex(_selectionInfo.DataItem);
    if (viewListIndex <> -1) and (viewListIndex = _selectionInfo.ViewListIndex) then
    begin
      if (_waitForRepaintInfo = nil) or (_view.GetActiveRowIfExists(viewListIndex) <> nil {in current viewport}) then
        Exit; // nothing to do

//      // if filtered, scroll to new pos...
//      if not (TTreeRowState.FilterChanged in _waitForRepaintInfo.RowStateFlags) and not (TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags) then
//        Exit; // current selection is still valid
    end;

    if viewListIndex = -1 then
      viewListIndex := CMath.Min(_selectionInfo.ViewListIndex - 1, _view.ViewCount - 1);
  end
  else if ViewIsDataModelView then
    viewListIndex := CMath.Max(0, GetDataModelView.CurrencyManager.Current);

  viewListIndex := GetSelectableViewIndex(viewListIndex, True);
  if viewListIndex = -1 then
  begin
    viewListIndex := GetSelectableViewIndex(0, True);
    if viewListIndex = -1 then
      Exit;
  end;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Internal;

  var requestedSelection := _selectionInfo.Clone;
  requestedSelection.UpdateLastSelection(_view.GetDataIndex(viewListIndex), viewListIndex, _view.GetViewList[viewListIndex]);
  TrySelectItem(requestedSelection, []);
end;

procedure TScrollControlWithRows.set_SelectionType(const Value: TSelectionType);
begin
  _selectionType := Value;
end;

procedure TScrollControlWithRows.set_AllowNoneSelected(const Value: Boolean);
begin
  _allowNoneSelected := Value;
end;

procedure TScrollControlWithRows.set_Current(const Value: Integer);
begin
  if (_selectionInfo = nil) or (get_Current <> Value) then
    GetInitializedWaitForRefreshInfo.Current := Value;
end;

procedure TScrollControlWithRows.set_DataItem(const Value: CObject);
begin
  var dItem := get_DataItem;
  if ViewIsDataModelView and (dItem <> nil) then
    dItem := dItem.AsType<IDataRowView>.Row.Data;

  if not CObject.Equals(dItem, Value) then
    GetInitializedWaitForRefreshInfo.DataItem := Value;
end;

function TScrollControlWithRows.GetItemType: &Type;
begin
  if get_Model <> nil then
    Result := get_Model.ObjectModel.GetType
  else if not _itemType.IsUnknown then
    Result := _itemType
  else if (_view <> nil) and (_view.OriginalData.Count > 0) then
    Result := ConvertToDataItem(_view.OriginalData[0]).GetType
  else
    Result := &Type.Unknown
end;

function TScrollControlWithRows.GetPropValue(const PropertyName: CString; const DataItem: CObject; const DataModel: IDataModel = nil): CObject;
begin
  var drv: IDataRowView;
  var dr: IDataRow;

  var dm := DataModel;
  if DataItem.TryAsType<IDataRowView>(drv) then
  begin
    if dm = nil then
      dm := drv.DataView.DataModel;

    Result := dm.GetPropertyValue(PropertyName, drv.Row)
  end
  else if DataItem.TryAsType<IDataRow>(dr) then
  begin
    if dm = nil then
      dm := dr.Table;

    Result := dm.GetPropertyValue(PropertyName, dr)
  end
  else begin
    var prop := DataItem.GetType.PropertyByName(PropertyName);
    Result := prop.GetValue(DataItem, []);
  end;
end;

// start sorting and filtering

procedure TScrollControlWithRows.AddFilterDescription(const Filter: IListFilterDescription; const ClearOtherFlters: Boolean);
begin
  var filters: List<IListFilterDescription>;
  if ClearOtherFlters or (_view = nil) or (_view.GetFilterDescriptions = nil) then
    filters := CList<IListFilterDescription>.Create else
    filters := _view.GetFilterDescriptions;

  if Filter <> nil then
    filters.Add(Filter);

  GetInitializedWaitForRefreshInfo.FilterDescriptions := filters;

  // scroll to current dataitem after scrolling
  if GetInitializedWaitForRefreshInfo.DataItem = nil then
    GetInitializedWaitForRefreshInfo.DataItem := get_DataItem;
end;

procedure TScrollControlWithRows.AddSortDescription(const Sort: IListSortDescription; const ClearOtherSort: Boolean);
begin
  var sorts: List<IListSortDescription>;
  if ClearOtherSort or (_view = nil) or (_view.GetSortDescriptions = nil) then
    sorts := CList<IListSortDescription>.Create else
    sorts := _view.GetSortDescriptions;

  if Sort <> nil then
    sorts.Insert(0, Sort);  // make it the most important sort

  GetInitializedWaitForRefreshInfo.SortDescriptions := sorts;

  // scroll to current dataitem after scrolling
  if GetInitializedWaitForRefreshInfo.DataItem = nil then
    GetInitializedWaitForRefreshInfo.DataItem := get_DataItem;
end;

procedure TScrollControlWithRows.AfterRealignContent;
begin
  inherited;

  if _hoverRect <> nil then
    _hoverRect.Visible := False;

  if _isMasterSynchronizer then
    _activeRowHeightSynchronizer.AfterRealignContent;

//  if _view <> nil then
//    for var rowIx := 0 to _view.ActiveViewRows.Count - 1 do
//    begin
//      var row := _view.ActiveViewRows[rowIx];
//      if (_scrollingType = TScrollingType.None) or (rowIx < 10) then
//      begin
//        row.Control.Visible := True;
//        row.Control.Opacity := 1;
//      end
//      else if (rowIx >= 15) then
//        row.Control.Visible := False
//      else
//      begin
//        row.Control.Visible := True;
//        row.Control.Opacity := (15 - rowIx) * 0.15;
//      end;
//    end;
end;

// endof sorting and filtering

{ TDCRow }

procedure TDCRow.UpdateControlVisibility;
begin
  if (_control <> nil) then
    _control.Visible := get_IsHeaderRow or (_virtualYPosition <> -1);
end;

procedure TDCRow.UpdateSelectionRect(OwnerIsFocused: Boolean);
begin
  if _selectionRect = nil then
  begin
    var rect := TRectangle.Create(_control);
    rect.Align := TAlignLayout.Contents;
    rect.Sides := [];
    rect.Opacity := 0.3;
    rect.HitTest := False;

    _selectionRect := rect;
    _control.AddObject(_selectionRect);
    _selectionRect.BringToFront;
  end;

  if OwnerIsFocused then
    _selectionRect.Fill.Color := DEFAULT_ROW_SELECTION_ACTIVE_COLOR else
    _selectionRect.Fill.Color := DEFAULT_ROW_SELECTION_INACTIVE_COLOR;
end;

procedure TDCRow.UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean);
begin
  var isSelected := SelectionInfo.IsSelected(get_DataIndex);
  if not isSelected then
  begin
    FreeAndNil(_selectionRect);
    Exit;
  end;

  UpdateSelectionRect(OwnerIsFocused);
end;

procedure TDCRow.ClearRowForReassignment;
begin
  _dataItem := nil;
  _viewPortIndex := -1;
  _virtualYPosition := -1;
  _enabled := True;
  UpdateControlVisibility;
end;

constructor TDCRow.Create;
begin
  inherited Create;
  _virtualYPosition := -1;
  _enabled := True;
end;

destructor TDCRow.Destroy;
begin
  _selectionRect.Free;
  _control.Free;
  inherited;
end;

function TDCRow.get_Control: TControl;
begin
  Result := _control;
end;

function TDCRow.get_ConvertedDataItem: CObject;
begin
  Result := _convertedDataItem;
end;

function TDCRow.get_CustomTag: CObject;
begin
  Result := _customTag;
end;

function TDCRow.get_ViewListIndex: Integer;
begin
  Result := _viewListIndex;
end;

function TDCRow.get_DataIndex: Integer;
begin
  Result := _dataIndex;
end;

function TDCRow.get_DataItem: CObject;
begin
  Result := _dataItem;
end;

function TDCRow.get_Enabled: Boolean;
begin
  Result := _enabled;
end;

function TDCRow.get_IsHeaderRow: Boolean;
begin
  Result := False
end;

function TDCRow.get_OwnerIsScrolling: Boolean;
begin
  Result := _ownerIsScrolling
end;

function TDCRow.get_VirtualYPosition: Single;
begin
  Result := _virtualYPosition;
end;

function TDCRow.get_ViewPortIndex: Integer;
begin
  Result := _viewPortIndex;
end;

function TDCRow.HasChildren: Boolean;
begin
  var drv: IDataRowView;
  if _dataItem.TryAsType<IDataRowView>(drv) then
    Result := drv.DataView.DataModel.HasChildren(drv.Row) else
    Result := False;
end;

function TDCRow.HasVisibleChildren: Boolean;
begin
  var drv: IDataRowView;
  if _dataItem.TryAsType<IDataRowView>(drv) then
  begin
    var childs := drv.DataView.DataModel.Children(drv.Row, TChildren.IncludeParentRows);
    if childs <> nil then
    begin
      var dr: IDataRow;
      for dr in childs do
        if (dr.Level = drv.Row.Level + 1) then
        begin
          // FindVisibleRow apparently goes up untill it finds a visible row
          var firstVisibRow := drv.DataView.FindVisibleRow(dr);
          if (firstVisibRow.Row.Level = drv.Row.Level + 1) then
            Exit(True);
        end;      
    end;
  end;

  Result := False;
end;

function TDCRow.ParentCount: Integer;
begin
  var drv: IDataRowView;
  if _dataItem.TryAsType<IDataRowView>(drv) then
    Result := drv.Row.Level else
    Result := 0;
end;

function TDCRow.Height: Single;
begin
  Result := _control.Height;
end;

function TDCRow.IsClearedForReassignment: Boolean;
begin
  Result := (_dataItem = nil) and (_control <> nil);
end;

function TDCRow.IsOddRow: Boolean;
begin
  Result := Odd(_viewListIndex);
end;

function TDCRow.IsScrollingIntoView: Boolean;
begin
  Result := _virtualYPosition = -1;
end;

procedure TDCRow.set_Control(const Value: TControl);
begin
  var wasSelected := _selectionRect <> nil;
  var wasFocused := wasSelected and (_selectionRect.Fill.Color = TAlphaColors.Slateblue);

  if (_control <> nil) and (_control <> Value) then
  begin
    FreeAndNil(_selectionRect);
    _control.Free;
  end;

  _control := Value;

  if wasSelected then
    UpdateSelectionRect(wasFocused);

  UpdateControlVisibility;
end;

procedure TDCRow.set_CustomTag(const Value: CObject);
begin
  _customTag := Value;
end;

procedure TDCRow.set_ViewListIndex(const Value: Integer);
begin
  _ViewListIndex := Value;
end;

procedure TDCRow.set_DataIndex(const Value: Integer);
begin
  _dataIndex := Value;
end;

procedure TDCRow.set_DataItem(const Value: CObject);
begin
  _dataItem := Value;

  var drv: IDataRowView;
  var dr: IDataRow;

  if _dataItem.TryAsType<IDataRowView>(drv) then
    _convertedDataItem := drv.Row.Data
  else if _dataItem.TryAsType<IDataRow>(dr) then
    _convertedDataItem := dr.Data
  else
    _convertedDataItem := _dataItem;
end;

procedure TDCRow.set_Enabled(const Value: Boolean);
begin
  _enabled := Value;
end;

procedure TDCRow.set_OwnerIsScrolling(const Value: Boolean);
begin
  _ownerIsScrolling := Value;
end;

procedure TDCRow.set_VirtualYPosition(const Value: Single);
begin
  _virtualYPosition := Value;
  UpdateControlVisibility;
end;

procedure TDCRow.set_ViewPortIndex(const Value: Integer);
begin
  _viewPortIndex := Value;
end;

{ TRowSelectionInfo }

constructor TRowSelectionInfo.Create(const RowsControl: IRowsControl);
begin
  inherited Create;

  _rowsControl := RowsControl;
  _multiSelection := CDictionary<Integer {ViewListIndex}, IRowSelectionInfo>.Create;
  ClearAllSelections;
end;

procedure TRowSelectionInfo.BeginUpdate;
begin
  _selectionChanged := False;
  inc(_updateCount);
end;

procedure TRowSelectionInfo.EndUpdate(IgnoreChangeEvent: Boolean = False);
begin
  dec(_updateCount);

  if (_updateCount = 0) and _selectionChanged and not IgnoreChangeEvent then
    DoSelectionInfoChanged;
end;

function TRowSelectionInfo.CanSelect(const DataIndex: Integer): Boolean;
begin
  Result := not TArray.Contains<Integer>(_notSelectableDataIndexes, DataIndex);
end;

procedure TRowSelectionInfo.Clear;
begin
  ClearAllSelections;
  SetLength(_notSelectableDataIndexes, 0);
end;

procedure TRowSelectionInfo.ClearAllSelections;
begin
  ClearMultiSelections;

  if _lastSelectedDataIndex <> -1 then
  begin
    _lastSelectedDataIndex := -1;
    _lastSelectedViewListIndex := -1;
    _lastSelectedDataItem := nil;
    _selectionChanged := True;
  end;
end;

procedure TRowSelectionInfo.ClearMultiSelections;
begin
  if _multiSelection.Count > 0 then
  begin
    _multiSelection.Clear;
    _selectionChanged := True;
  end;
end;

function TRowSelectionInfo.GetSelectionInfo(const DataIndex: Integer): IRowSelectionInfo;
begin
  if (_lastSelectedDataIndex = DataIndex) then
    Result := Self
  else if not _multiSelection.TryGetValue(DataIndex, Result) then
    Result := nil;
end;

function TRowSelectionInfo.get_ViewListIndex: Integer;
begin
  Result := _lastSelectedViewListIndex;
end;

function TRowSelectionInfo.get_EventTrigger: TSelectionEventTrigger;
begin
  Result := _EventTrigger;
end;

function TRowSelectionInfo.get_DataIndex: Integer;
begin
  Result := _lastSelectedDataIndex;
end;

function TRowSelectionInfo.get_DataItem: CObject;
begin
  Result := _lastSelectedDataItem;
end;

function TRowSelectionInfo.get_ForceScrollToSelection: Boolean;
begin
  Result := _forceScrollToSelection;
end;

function TRowSelectionInfo.get_IsMultiSelection: Boolean;
begin
  Result := _multiSelection.Count > 0;
end;

function TRowSelectionInfo.get_NotSelectableDataIndexes: TDataIndexArray;
begin
  Result := _notSelectableDataIndexes;
end;

function TRowSelectionInfo.HasSelection: Boolean;
begin
  Result := (_lastSelectedDataItem <> nil) or get_IsMultiSelection;
end;

function TRowSelectionInfo.IsSelected(const DataIndex: Integer): Boolean;
begin
  Result := (_lastSelectedDataIndex = DataIndex) or (_multiSelection.ContainsKey(DataIndex));
end;

function TRowSelectionInfo.SelectedRowCount: Integer;
begin
  Result := _multiSelection.Count;
end;

function TRowSelectionInfo.SelectionType: TSelectionType;
begin
  if (_rowsControl <> nil {not a clone}) then
    Result := _rowsControl.SelectionType else
    Result := TSelectionType.HideSelection;
end;

procedure TRowSelectionInfo.set_EventTrigger(const Value: TSelectionEventTrigger);
begin
  _EventTrigger := Value;
end;

procedure TRowSelectionInfo.set_ForceScrollToSelection(const Value: Boolean);
begin
  _forceScrollToSelection := Value;
end;

procedure TRowSelectionInfo.set_NotSelectableDataIndexes(const Value: TDataIndexArray);
begin
  _notSelectableDataIndexes := Value;
end;

function TRowSelectionInfo.Clone: IRowSelectionInfo;
begin
  Result := CreateInstance;
  (Result as IRowSelectionInfo).UpdateSingleSelection(_lastSelectedDataIndex, _lastSelectedViewListIndex, _lastSelectedDataItem);

  Result.LastSelectionEventTrigger := _EventTrigger;
  Result.NotSelectableDataIndexes := _notSelectableDataIndexes;
end;

function TRowSelectionInfo.CreateInstance: IRowSelectionInfo;
begin
  Result := TRowSelectionInfo.Create(nil {clones don't get the treecontrol, for they dopn't need to make changes});
end;

procedure TRowSelectionInfo.Deselect(const DataIndex: Integer);
begin
  if (_multiSelection.Count <= 1) or not _multiSelection.ContainsKey(DataIndex) then
  begin
    if (_rowsControl <> nil {not a clone}) and _rowsControl.AllowNoneSelected then
    begin
      if _multiSelection.ContainsKey(DataIndex) then
        _multiSelection.Remove(DataIndex);
      UpdateLastSelection(-1, -1, nil);
    end;

    Exit;
  end;

  // UpdateLastSelection triggers DoSelectionInfoChanged
  // therefor work with Update locks
  BeginUpdate;
  try
    if _lastSelectedDataIndex = DataIndex then
    begin
      var item: IRowSelectionInfo;
      for item in _multiSelection.Values do
        if item.DataIndex <> DataIndex then
        begin
          UpdateLastSelection(item.DataIndex, item.ViewListIndex, item.DataItem);
          Break
        end;
    end;

    _multiSelection.Remove(DataIndex);
    DoSelectionInfoChanged;
  finally
    EndUpdate;
  end;
end;

procedure TRowSelectionInfo.DoSelectionInfoChanged;
begin
  // check if we are dealing with clone
  if _rowsControl = nil then
    Exit;

  if _updateCount > 0 then
  begin
    _selectionChanged := True;
    Exit;
  end;

  _rowsControl.OnSelectionInfoChanged;
end;

procedure TRowSelectionInfo.UpdateSingleSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
begin
  if not CanSelect(DataIndex) then
    Exit;

  ClearMultiSelections;
  UpdateLastSelection(DataIndex, ViewListIndex, DataItem);
end;

procedure TRowSelectionInfo.AddToSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
begin
  if not CanSelect(DataIndex) then
    Exit;

  BeginUpdate;
  try
    // add single selection if needed
    var prevInfo: IRowSelectionInfo := nil;
    if (_lastSelectedViewListIndex <> -1) {and not _multiSelection.ContainsKey(_lastSelectedDataIndex)} then
      prevInfo := Clone;

    UpdateLastSelection(DataIndex, ViewListIndex, DataItem);

    if prevInfo <> nil then
      _multiSelection[prevInfo.DataIndex] := prevInfo;

    var info: IRowSelectionInfo := CreateInstance as IRowSelectionInfo;
    info.UpdateSingleSelection(DataIndex, ViewListIndex, DataItem);
    _multiSelection[info.DataIndex] := info;
  finally
    EndUpdate;
  end;
end;

function TRowSelectionInfo.SelectedDataIndexes: List<Integer>;
begin
  Result := CList<Integer>.Create;

  if _multiSelection.Count > 0 then
  begin
    var item: IRowSelectionInfo;
    for item in _multiSelection.Values do
      Result.Add(item.DataIndex)
  end
  else if _lastSelectedDataIndex <> -1 then
    Result.Add(_lastSelectedDataIndex);
end;

procedure TRowSelectionInfo.SelectedRowClicked(const DataIndex: Integer);
begin
  if not CanSelect(DataIndex) or (_lastSelectedDataIndex = DataIndex) then
    Exit;

  var selectionInfo: IRowSelectionInfo;
  if not _multiSelection.TryGetValue(DataIndex, selectionInfo) then
    Exit;

  UpdateLastSelection(selectionInfo.DataIndex, selectionInfo.ViewListIndex, selectionInfo.DataItem);
end;

procedure TRowSelectionInfo.UpdateLastSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
begin
  _lastSelectedDataIndex := DataIndex;
  _lastSelectedViewListIndex := ViewListIndex;
  _lastSelectedDataItem := DataItem;

  DoSelectionInfoChanged;
end;

{ TWaitForRepaintInfo }

procedure TWaitForRepaintInfo.ClearIrrelevantInfo;
begin
  _rowStateFlags := _rowStateFlags - [SortChanged, FilterChanged];

  // ONLY KEEP CURRENT
  // we use current to reselect a item at that position after for example a refresh of the treecontrol

  _dataItem := nil;
  _sortDescriptions := nil;
  _filterDescriptions := nil;
end;

constructor TWaitForRepaintInfo.Create(const Owner: IRefreshControl);
begin
  inherited Create;
  _current := -1;
  _Owner := Owner;
end;

function TWaitForRepaintInfo.get_Current: Integer;
begin
  Result := _current;
end;

function TWaitForRepaintInfo.get_DataItem: CObject;
begin
  Result := _dataItem;
end;

function TWaitForRepaintInfo.get_FilterDescriptions: List<IListFilterDescription>;
begin
  Result := _filterDescriptions;
end;

function TWaitForRepaintInfo.get_RowStateFlags: TTreeRowStateFlags;
begin
  Result := _rowStateFlags;
end;

function TWaitForRepaintInfo.get_SortDescriptions: List<IListSortDescription>;
begin
  Result := _sortDescriptions;
end;

procedure TWaitForRepaintInfo.set_Current(const Value: Integer);
begin
  _current := Value;
  _rowStateFlags := _rowStateFlags + [TTreeRowState.RowChanged];
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

procedure TWaitForRepaintInfo.set_DataItem(const Value: CObject);
begin
  _dataItem := Value;
  _rowStateFlags := _rowStateFlags + [TTreeRowState.RowChanged];
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

procedure TWaitForRepaintInfo.set_FilterDescriptions(const Value: List<IListFilterDescription>);
begin
  _filterDescriptions := Value;
  _rowStateFlags := _rowStateFlags + [TTreeRowState.FilterChanged];
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

procedure TWaitForRepaintInfo.set_RowStateFlags(const Value: TTreeRowStateFlags);
begin
  _rowStateFlags := Value;
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

procedure TWaitForRepaintInfo.set_SortDescriptions(const Value: List<IListSortDescription>);
begin
  _sortDescriptions := Value;
  _rowStateFlags := _rowStateFlags + [TTreeRowState.SortChanged];
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

end.
