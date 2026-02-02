unit FMX.ScrollControl.WithRows.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls,
  System.SysUtils,
  System.Classes,
  FMX.Objects,
  System.UITypes,
  System.Types,
  FMX.Graphics,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.SysUtils,
  Wasm.System.Classes,
  Wasm.FMX.Objects,
  Wasm.System.UITypes,
  Wasm.System.Types,
  {$ENDIF}
  System_,
  FMX.ScrollControl.WithRows.Intf,
  System.Collections,
  System.Collections.Generic,
  ADato.ComponentModel,
  FMX.ScrollControl.Intf,
  FMX.ScrollControl.Impl, ADato.Data.DataModel.intf,
  ADato.ObjectModel.List.intf, ADato.ObjectModel.intf,
  FMX.ScrollControl.View.Intf, FMX.ScrollControl.Events,
  System.Diagnostics, FMX.ScrollControl.ControlClasses.Intf, FMX.Types;

type
  TScrollControlWithRows = class(TScrollControl, IRowsControl)
  // data
  strict private
    _previousHardAssignedDataModelView: IDataModelView;

    function  TryStartMasterSynchronizer(CheckSyncVisibility: Boolean = False): Boolean;
    function  TryStartIgnoreMasterSynchronizer(CheckSyncVisibility: Boolean = False): Boolean;

    procedure StopMasterSynchronizer(const DoTry: Boolean = True);
    procedure StopIgnoreMasterSynchronizer(const DoTry: Boolean = True);

  protected
    _dataList: IList;
    _dataModelView: IDataModelView;
    // KV 04_05 Datacontrol should keep a lock on the model.
    // It will be released otherwise
    {[unsafe]} _model: IObjectListModel;

    _rowHeightSynchronizer: TScrollControlWithRows;

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

    procedure GenerateView; virtual;

    function  MeOrSynchronizerIsUpdating: Boolean;

  protected
    _selectionType: TSelectionType;
    _rowHeightFixed: Single;
    _rowHeightDefault: Single;
    _rowHeightMax: Single;
    _options: TDCTreeOptions;

    // events
    {$IFNDEF WEBASSEMBLY}
    _rowLoaded: RowLoadedEvent;
    _rowAligned: RowLoadedEvent;
    {$ENDIF}

    procedure DoRowLoaded(const ARow: IDCRow); virtual;
    procedure DoRowAligned(const ARow: IDCRow); virtual;
    function  DrawRowBackground: Boolean; virtual;

    function  get_SelectionType: TSelectionType;
    procedure set_SelectionType(const Value: TSelectionType);
    procedure set_Options(const Value: TDCTreeOptions);
    function  get_NotSelectableItems: IList;
    procedure set_NotSelectableItems(const Value: IList);

    function  get_rowHeightDefault: Single; virtual;
    procedure set_RowHeightDefault(const Value: Single);
    function  get_rowHeightFixed: Single;
    procedure set_RowHeightFixed(const Value: Single);
    function  get_RowHeightMax: Single;
    procedure set_RowHeightMax(const Value: Single);
    function  get_RowHeightSynchronizer: TScrollControlWithRows;
    procedure set_RowHeightSynchronizer(const Value: TScrollControlWithRows);

    function  CalculateRowControlWidth(const ForceRealContentWidth: Boolean): Single; virtual;

    procedure UpdateAndIgnoreVertScrollbar(const NewValue: Single);
    procedure DoViewPortPositionChanged; override;

    function  IsMasterSynchronizer: Boolean;
    function  IgnoreSynchronizer: Boolean;
    function  SyncIsMasterSynchronizer: Boolean;
    function  MasterSynchronizer: TScrollControlWithRows;

  // public property variables
  private
    _topRow: Integer;
    _isPrinting: Boolean;

    function  get_Current: Integer;
    procedure set_Current(const Value: Integer);
    function  get_TopRow: Integer;
    procedure set_TopRow(const Value: Integer);
    function  get_IsPrinting: Boolean;
    procedure set_IsPrinting(const Value: Boolean);
    function  get_DataItem: CObject;
    procedure set_DataItem(const Value: CObject);

//    function  RequestedOrActualCurrent: Integer;
    function  RequestedOrActualDataItem: CObject;

  // row calculations
  private
//    _scrollbarRefToTopHeightChangeSinceViewLoading: Single;

    procedure UpdateVirtualYPositions(const ReferenceRow: IDCRow; const HeightChangeAboveRef: Single);

    procedure DoViewLoadingStart(const startY, StopY: Single; const ReferenceRow: IDCRow);
    procedure DoViewLoadingFinished;
    procedure DoViewRmoveNonUsedRows;

    procedure CreateAndSynchronizeSynchronizerRow(const Row: IDCRow);
    procedure UpdateRowHeightSynchronizerScrollbar;
    procedure ValidateSelectionInfo;

    procedure AnimateRow(const Row: IDCRow; StartY, StopY: Single; AnimateOpacity: Boolean; Hide: Boolean; ExtraDelay: Single = 0);
    procedure ExecuteAfterAnimateRow(const Row: IDCRow; Event: TNotifyEvent; ExtraDelay: Single = 0);
    function IsPartOfSelectedParentChildGroup(const Row: IDCRow): Boolean;

  // expand / collapse
  protected
    _isExpandingOrCollapsing: Boolean;
    _scrollAfterExpandCollapse: Integer;
    _visualizeParentChilds: TVisualizeParentChilds;

    procedure VisualizeRowExpand(ViewListIndex: Integer);
    procedure VisualizeRowCollapse(ViewListIndex: Integer);
    procedure OnExpandTimer(Sender: TObject);
    procedure OnCollapseTimer(Sender: TObject);

    procedure set_VisualizeParentChilds(const Value: TVisualizeParentChilds);

    property VisualizeParentChilds: TVisualizeParentChilds read _visualizeParentChilds write set_VisualizeParentChilds;


  protected
    _view: IDataViewList;
    _waitForRepaintInfo: IWaitForRepaintInfo;
    _selectionInfo: IRowSelectionInfo;
    _internalSelectCount: Integer;
    _masterIgnoreIndex: Integer;
    _masterSynchronizerIndex: Integer;

    _hoverRect: TRectangle;
    _resetViewRec: TResetViewRec;
    _canDragDrop: Boolean;
    _dragObject: CObject;

    _tryFindNewSelectionInDataModel: Boolean;
    _referenceRowViewListIndex: Integer;

    _multiSelectSorter: ITreeSortDescription;

    // Used when printing this control and we're on the last page
    // and the viewportsize needs to be adjusted in order to set _vertScrollBar.Value.
    _manualContentHeight: Single;

    function  HasUpdateCount: Boolean;
    function  HasInternalSelectCount: Boolean;

    procedure DoEnter; override;
    procedure DoExit; override;

    procedure RealignContentStart; override;
    procedure BeforeRealignContent; override;
    procedure RealignContent; override;
    procedure AfterRealignContent; override;
    procedure RealignFinished; override;

    procedure DoRealignContent; override;

    function  IsScrolling: Boolean; override;
    function  IsFastScrolling(ScrollbarOnly: Boolean = False): Boolean; override;

  public
    procedure ExecuteAfterRealignOnly(DoBeginUpdate: Boolean);

  protected
    procedure RealignFromSelectionChange;

    procedure SetBasicVertScrollBarValues; override;
    procedure BeforePainting; override;

    function  RealignedButNotPainted: Boolean; override;
    function  RealignContentTime: Integer; override;
    function  GetScrollingType: TScrollingType;
    procedure AfterScrolling; override;

    function  DoCreateNewRow: IDCRow; virtual;
    function  CreateRowBackground: IBackgroundControl; virtual;
    procedure InnerInitRow(const Row: IDCRow; RowHeightNeedsRecalc: Boolean = False); virtual;
    procedure PerformanceRoutineLoadedRow(const Row: IDCRow); virtual;
    procedure InitRow(const Row: IDCRow);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

    function  HasViewRows: Boolean;
    
    procedure OnSelectionInfoChanged; virtual;
    function  CreateSelectioninfoInstance: IRowSelectionInfo; virtual;
    procedure InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False); virtual;
    function  TrySelectItem(const RequestedSelectionInfo: IRowSelectionInfo; Shift: TShiftState): Boolean; virtual;
    procedure ScrollSelectedIntoView(const RequestedSelectionInfo: IRowSelectionInfo);
    function  ProvideRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow; virtual;

    function  PrepareReferenceRowBeforeRealignContent(out StartY: Single; out AlignBottomToTop: Boolean): IDCRow;
    procedure AlignRowsAboveReference(const BottomReferenceRow: IDCRow; var SpaceForRows: Single; out HeightChangeAboveRef: Single);
    procedure AlignRowsFromReferenceToBottom(const TopReferenceRow: IDCRow; var SpaceForRows: Single);

    procedure UpdateYPositionRows;
    procedure UpdateScrollBarValues(const NewValue: Single);
    procedure UpdateHoverRect(MousePos: TPointF); virtual;

    function  GetPropValue(const PropertyName: CString; const DataItem: CObject; const DataModel: IDataModel = nil): CObject;

    procedure UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single); override;
    function  DefaultMoveDistance(ScrollDown: Boolean; RowCount: Integer): Single; override;
    function  CalculateAverageRowHeight: Single;
    procedure DoContentResized(WidthChanged, HeightChanged: Boolean); override;

    procedure CheckVertScrollbarVisibility;
    procedure CalculateScrollBarMax; override;
    procedure InternalDoSelectRow(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; Shift: TShiftState);

    function  ListHoldsOrdinalType: Boolean;
    procedure HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions); virtual;

    function  GetInitializedWaitForRefreshInfo: IWaitForRepaintInfo; virtual;
    procedure VisualizeRowSelection(const Row: IDCRow); virtual;
    procedure HandleRowChildRelation(const Row: IDCRow; IsOpenParent, IsOpenChild: Boolean); virtual;

    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure UpdateScrollAndSelectionByKey(var Key: Word; Shift: TShiftState); virtual;

    procedure DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean); virtual;
    function  RowIsExpanded(const ViewListIndex: Integer): Boolean;

    procedure PrepareView;
    procedure ResetView(const FromViewListIndex: Integer = -1; ClearOneRowOnly: Boolean = False); virtual;

    function  GetSelectableViewIndex(const FromViewListIndex: Integer; const Increase: Boolean; const FirstRound: Boolean = True): Integer;

    function  GetRowViewListIndexByKey(const Key: Word; Shift: TShiftState): Integer;
    function  GetActiveRow: IDCRow;

  protected
    _resetRowDataItem: Boolean;

    procedure OnViewChanged(Sender: TObject; e: EventArgs); virtual;
    procedure DataModelViewRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);
    procedure DataModelViewRowPropertiesChanged(Sender: TObject; Args: RowPropertiesChangedEventArgs); virtual;

  public
    procedure OnItemAddedByUser(const Item: CObject; Index: Integer);
    procedure OnItemRemovedByUser(const Item: CObject; Index: Integer);

  protected
    _itemType: &Type;
    function  GetItemType: &Type;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  FitRowsDownwards(StartIndex: Integer): Integer;

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
    procedure DoDataItemChanged(const CurrentViewListIndex: Integer; const DataItem: CObject; out ChangeUpdatedSort: Boolean); virtual;

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

    function  IsSelected(const DataIndex: Integer): Boolean;
    function  SlowItemIsSelected(const DataItem: CObject): Boolean;
    function  SelectedRowIfInView: IDCRow;
    function  SelectionCount: Integer;
    function  SelectedItems: List<CObject>; overload;
    function  SelectedItems<T>: List<T>; overload;
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
    property TopRow: Integer read get_TopRow write set_TopRow;
    property IsPrinting: Boolean read get_IsPrinting write set_IsPrinting;
    property DataItem: CObject read get_DataItem write set_DataItem;

    property View: IDataViewList read get_View;
    property NotSelectableItems: IList read get_NotSelectableItems write set_NotSelectableItems;
    property ItemType: &Type read _itemType write _itemType;

  public
    // designer properties & events
    property SelectionType: TSelectionType read get_SelectionType write set_SelectionType default RowSelection;
    property Options: TDCTreeOptions read _options write set_Options;
    property CanDragDrop: Boolean read _canDragDrop write _canDragDrop default False;

    property RowHeightFixed: Single read get_rowHeightFixed write set_RowHeightFixed;
    property RowHeightDefault: Single read get_rowHeightDefault write set_RowHeightDefault;
    property RowHeightMax: Single read get_RowHeightMax write set_RowHeightMax;

    {$IFNDEF WEBASSEMBLY}
    property RowLoaded: RowLoadedEvent read _rowLoaded write _rowLoaded;
    property RowAligned: RowLoadedEvent read _rowAligned write _rowAligned;
    {$ENDIF}

    property RowHeightSynchronizer: TScrollControlWithRows read get_RowHeightSynchronizer write set_RowHeightSynchronizer;
  end;

  TDCRow = class(TBaseInterfacedObject, IDCRow)
  protected
    {$IFNDEF DOTNET}[unsafe]{$ENDIF} _rowsControl: IRowsControl;
    _dataItem: CObject;
    _convertedDataItem: CObject;
    _dataIndex: Integer;
    _viewPortIndex: Integer;
    _viewListIndex: Integer;
    _virtualYPosition: Single;

    _control: TControl;
    _enabled: Boolean;

    _customTag: CObject;

    function  get_RowsControl: IRowsControl;
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
    function  get_CustomTag: CObject;
    procedure set_CustomTag(const Value: CObject);
    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean);

    procedure UpdateControlVisibility;
  protected
    _selectionRect: TRectangle;

    procedure UpdateSelectionRect(OwnerIsFocused: Boolean);

  public
    constructor Create(const RowsControl: IRowsControl); reintroduce;

    destructor Destroy; override;

    function  ControlAsRowLayout: IRowLayout;
    procedure UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean); virtual;

    procedure ClearRowForReassignment; virtual;
    function  IsClearedForReassignment: Boolean;
    function  IsScrollingIntoView: Boolean;

    function  Height: Single;
    function  HasChildren: Boolean;
    function  HasVisibleChildren: Boolean;
    function  ParentCount: Integer;
    function  IsChildOf(const DataItem: CObject): Boolean;
    function  IsParentOf(const DataItem: CObject): Boolean;
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

    procedure UpdateSingleSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; KeepCurrentSelection: Boolean);
    procedure AddToSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; ExpandCurrentSelection: Boolean);
    procedure Deselect(const DataIndex: Integer);
    function  Select(const DataIndex, ViewListIndex: Integer; const DataItem: CObject) : Boolean;
    procedure SelectedRowClicked(const DataIndex: Integer);

    procedure BeginUpdate;
    procedure EndUpdate(IgnoreChangeEvent: Boolean = False);

    procedure Clear; virtual;
    procedure ClearAllSelections;
    procedure ClearMultiSelections; virtual;

    function  CanSelect(const DataIndex: Integer): Boolean;
    function  HasSelection: Boolean;
    function  IsChecked(const DataIndex: Integer): Boolean;
    function  IsSelected(const DataIndex: Integer): Boolean;
    function  GetSelectionInfo(const DataIndex: Integer): IRowSelectionInfo;
    function  SelectedRowCount: Integer;
    function  SelectedDataItems: List<CObject>;
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

    procedure ClearSelectionInfo;

    property RowStateFlags: TTreeRowStateFlags read get_RowStateFlags;
    property Current: Integer read get_Current write set_Current;
    property DataItem: CObject read get_DataItem write set_DataItem;
    property SortDescriptions: List<IListSortDescription> read get_SortDescriptions write set_SortDescriptions;
    property FilterDescriptions: List<IListFilterDescription> read get_FilterDescriptions write set_FilterDescriptions;
  end;

const
  ANI_DURATION = 0.3;
  ANI_DELAY = 0.2;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.StdCtrls,
  System.Generics.Collections,
  System.Math, 
  FMX.Platform, 
  System.Rtti, 
  FMX.Forms,
  FMX.ActnList,
  {$ELSE}
  Wasm.FMX.Types,
  Wasm.FMX.StdCtrls,
  Wasm.System.UITypes,
  Wasm.System.Math,
  Wasm.FMX.Platform,
  Wasm.FMX.Forms,
  Wasm.FMX.Graphics,
  Wasm.FMX.ActnList,
  {$ENDIF}
  FMX.ScrollControl.ControlClasses,
  FMX.ScrollControl.View.Impl, FMX.ControlCalculations,
  ADato.TraceEvents.intf, FMX.ScrollControl.SortAndFilter,
  System.ComponentModel, FMX.Layouts, FMX.Ani;


{ TScrollControlWithRows }

procedure TScrollControlWithRows.DoContentResized(WidthChanged, HeightChanged: Boolean);
begin
//  if WidthChanged and (_view <> nil) then
//  begin
//    var row: IDCRow;
//    for row in _view.ActiveViewRows do
//      row.Control.Width := _content.Width;
//  end;

  inherited;
end;

function TScrollControlWithRows.DefaultMoveDistance(ScrollDown: Boolean; RowCount: Integer): Single;
begin
  if (_view <> nil) and (_view.ActiveViewRows.Count > 2) then
  begin
    var topRow := _view.ActiveViewRows[0];

    var count := _view.ActiveViewRows.Count;

    if ScrollDown then
    begin
      Result := (topRow.VirtualYPosition + topRow.height) - _vertScrollBar.Value;

      var ix: Integer;
      if RowCount > 1 then
        for ix := 2 to CMath.Min(count, RowCount) do
          Result := Result + _view.ActiveViewRows[ix - 1].Height;
    end else begin
      Result := _vertScrollBar.Value - topRow.VirtualYPosition;

      var ix: Integer;
      if topRow.ViewListIndex > 0 then
        for ix := topRow.ViewListIndex - 1 downto CMath.Max(0, topRow.ViewListIndex - RowCount) do
          Result := Result + _view.GetRowHeight(ix);
    end;

    Exit;
  end
  else if _rowHeightFixed > 0 then
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

//  _newLoadedTreeRows := nil;

  // remove events
  if _model <> nil then
    set_Model(nil)
  else if _dataModelView <> nil then
    set_DataModelView(nil)
  else
    set_DataList(nil);

  if _rowHeightSynchronizer <> nil then
  begin
    _rowHeightSynchronizer._rowHeightSynchronizer := nil;
    _rowHeightSynchronizer := nil;
  end;

  inherited;
end;

function TScrollControlWithRows.DoCreateNewRow: IDCRow;
begin
  Result := TDCRow.Create(Self);
end;

procedure TScrollControlWithRows.DoDataItemChanged(const CurrentViewListIndex: Integer; const DataItem: CObject; out ChangeUpdatedSort: Boolean);
begin
  // datamodelView already Recalcs sorted rows in the DataModel.EndEdit
  if not ViewIsDataModelView then
  begin
    inc(_updateCount); // make sure to ignore OnViewChanged
    try
      _view.RecalcSortedRows;
    finally
      dec(_updateCount);
    end;
  end;

  var newViewListIndex := _view.GetViewListIndex(DataItem);

  ChangeUpdatedSort := CurrentViewListIndex <> newViewListIndex;
  if not ChangeUpdatedSort then
  begin
    OnSelectionInfoChanged;
    Exit;
  end;

  // sorting changed due to user change
  // reset view from lowest viewlistIndex
  ResetView(CMath.Min(CurrentViewListIndex, newViewListIndex), False);
  GetInitializedWaitForRefreshInfo.DataItem := DataItem;
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
    begin
      currentRow := row;
      Break;
    end;

  if currentRow = nil then
    Exit; // nothing to do

  var originalHeight := _view.CachedRowHeight(currentRow.ViewListIndex);

  // reset row height
  _view.ClearViewRecInfo(currentRow.ViewListIndex, True);
  if IsMasterSynchronizer then
    _rowHeightSynchronizer.View.ClearViewRecInfo(currentRow.ViewListIndex, True);

  InnerInitRow(currentRow);
  DoRowLoaded(currentRow);

  _view.RowLoaded(currentRow, False);

  
  var goMaster := TryStartMasterSynchronizer(True);
  try
    CreateAndSynchronizeSynchronizerRow(currentRow);

    if not SameValue(originalHeight, currentRow.Height) then
      RealignFromSelectionChange;
  finally
    StopMasterSynchronizer(goMaster);
  end;

  DoRowAligned(currentRow);
end;

function TScrollControlWithRows.HasInternalSelectCount: Boolean;
begin
  Result := (_internalSelectCount > 0) or ((_rowHeightSynchronizer <> nil) and (_rowHeightSynchronizer._internalSelectCount > 0));
end;

function TScrollControlWithRows.HasUpdateCount: Boolean;
begin
  Result := (_updateCount > 0) or ((_rowHeightSynchronizer <> nil) and (_rowHeightSynchronizer._updateCount > 0));
end;

function TScrollControlWithRows.HasViewRows: Boolean;
begin
  Result := (_view <> nil) and (_view.ViewCount > 0);
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
  var goMaster := TryStartMasterSynchronizer(True);
  try
    inherited;
  finally
    StopMasterSynchronizer(goMaster);
  end;
end;

procedure TScrollControlWithRows.UpdateRowHeightSynchronizerScrollbar;
begin
  var ctrl, master: TScrollControlWithRows; 
  
  if SyncIsMasterSynchronizer then begin
    ctrl := Self;
    master := _rowHeightSynchronizer;
  end else if _rowHeightSynchronizer <> nil then begin  
    ctrl := _rowHeightSynchronizer;
    master := Self;              
  end else
    Exit;

  inc(ctrl._scrollUpdateCount);
  try
    ctrl.VertScrollBar.ValueRange.BeginUpdate;
    try
      ctrl.VertScrollBar.Max := master._vertScrollBar.Max;
      ctrl.VertScrollBar.ViewportSize := master._vertScrollBar.ViewportSize;
      ctrl.VertScrollBar.Value := master._vertScrollBar.Value;
    finally
      ctrl.VertScrollBar.ValueRange.EndUpdate;
    end;

    ctrl.CheckVertScrollbarVisibility;
  finally
    dec(ctrl._scrollUpdateCount);
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

    if rowEventArgs.RealignAfterScrolling then
      _view.NotifyRowControlsNeedReload(ARow, True {force reload after scrolling is done});
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

  _selectionInfo.BeginUpdate;
  try
    InternalDoSelectRow(RequestedSelectionInfo.DataIndex, RequestedSelectionInfo.ViewListIndex, RequestedSelectionInfo.DataItem, Shift);
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

function TScrollControlWithRows.MasterSynchronizer: TScrollControlWithRows;
begin
  if IsMasterSynchronizer then
    Result := Self
  else if SyncIsMasterSynchronizer then
    Result := _rowHeightSynchronizer
  else
    Result := nil;
end;

function TScrollControlWithRows.MeOrSynchronizerIsUpdating: Boolean;
begin
  Result := IsUpdating or ((_rowHeightSynchronizer <> nil) and _rowHeightSynchronizer.IsUpdating);
end;

procedure TScrollControlWithRows.GenerateView;
begin
  if (_view <> nil) or ((_dataList = nil) and (_dataModelView = nil)) then
    Exit;

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

    // Handled in GetItemType
    //    if aType.IsUnknown and (_dataList.Count > 0) then
    //      aType := _dataList[0].GetType;

    {$IFNDEF WEBASSEMBLY}
    _view := TDataViewList.Create(_dataList, DoCreateNewRow, OnViewChanged, aType);
    {$ELSE}
    _view := TDataViewList.Create(_dataList, @DoCreateNewRow, @OnViewChanged, aType);
    {$ENDIF}
  end;

  {$IFDEF KV_OBSOLETE}
  if ViewIsDataModelView and (GetDataModelView.CurrencyManager.Current <> -1) and (_view.ActiveViewRows.Count > 0) then
    InternalSetCurrent(GetDataModelView.CurrencyManager.Current, TSelectionEventTrigger.External, []);
  {$ENDIF}

  if GetDataModelView <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    GetDataModelView.CurrencyManager.CurrentRowChanged.Add(DataModelViewRowChanged);
    GetDataModelView.RowPropertiesChanged.Add(DataModelViewRowPropertiesChanged);
    {$ELSE}
    GetDataModelView.CurrencyManager.CurrentRowChanged += DataModelViewRowChanged;
    GetDataModelView.RowPropertiesChanged += DataModelViewRowPropertiesChanged;
    {$ENDIF}

    Self.Current := GetDataModelView.CurrencyManager.Current;
  end
  else if _model <> nil then
    // Set current position, if any
    GetInitializedWaitForRefreshInfo.DataItem := _model.ObjectContext;
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

function TScrollControlWithRows.get_TopRow: Integer;
begin
  Result := _topRow;
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

  if (TDCTreeOption.MultiSelect in OldFlags) and not (TDCTreeOption.MultiSelect in NewFlags) then
    _options := _options - [TDCTreeOption.KeepCurrentSelection]
  else if not (TDCTreeOption.KeepCurrentSelection in OldFlags) and (TDCTreeOption.KeepCurrentSelection in NewFlags) and not (TDCTreeOption.MultiSelect in NewFlags) then
    set_Options(_options + [TDCTreeOption.MultiSelect]);

//  begin
//    if (TDCTreeOption.MultiSelect in NewFlags) then
//      _multiSelectSorter := TTreeMultiSelectSortDescription.Create(Self)
//    else begin
//      _multiSelectSorter := nil;
//      if (_selectionInfo <> nil) then
//        _selectionInfo.ClearMultiSelections;
//    end;
//  end;

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
  if (Result = 0) and (_selectionInfo.DataItem <> nil) then
    Result := 1;
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

  _selectionInfo.Select(dataIndex, ix, _view.GetViewList[ix] {should be datarowview});
  // _selectionInfo.AddToSelection(dataIndex, ix, _view.GetViewList[ix] {should be datarowview}, False);
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
    _selectionInfo.AddToSelection(dataIndex, ix, Item, False) else
    _selectionInfo.Deselect(dataIndex);
end;

function TScrollControlWithRows.get_Current: Integer;
begin
  Result := _selectionInfo.ViewListIndex;
end;

function TScrollControlWithRows.get_DataItem: CObject;
begin
  ValidateSelectionInfo;
  Result := _selectionInfo.DataItem;
end;

procedure TScrollControlWithRows.DoViewRmoveNonUsedRows;
begin
  _view.ViewLoadingRemoveNonUsedRows(-1, True);
  if IsMasterSynchronizer then
    _rowHeightSynchronizer.View.ViewLoadingRemoveNonUsedRows(-1, True);
end;

procedure TScrollControlWithRows.UpdateVirtualYPositions(const ReferenceRow: IDCRow; const HeightChangeAboveRef: Single);
begin
  ReferenceRow.VirtualYPosition := ReferenceRow.VirtualYPosition + HeightChangeAboveRef;

  var topVirtualYPosition := ReferenceRow.VirtualYPosition;
  if ReferenceRow.ViewPortIndex > 0 then
  begin
    var ix2: Integer;
    for ix2 := ReferenceRow.ViewPortIndex - 1 downto 0 do
      begin
        var viewListIndex := _view.ActiveViewRows[ix2].ViewListIndex;
        var info := _view.RowLoadedInfo(viewListIndex);
        if info.RowIsInActiveView then
          topVirtualYPosition := topVirtualYPosition - info.GetCalculatedHeight;
      end;
  end;

  var virtualYPosition := topVirtualYPosition;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
  begin
    row.VirtualYPosition := virtualYPosition;

    if IsMasterSynchronizer then
      _rowHeightSynchronizer.View.ActiveViewRows[row.ViewPortIndex].VirtualYPosition := virtualYPosition;

    virtualYPosition := virtualYPosition + _view.GetRowHeight(row.ViewListIndex);
  end;
end;

procedure TScrollControlWithRows.CalculateScrollBarMax;
begin
  if _view <> nil then
  begin
    inc(_scrollUpdateCount);                      
    try
      var newMax := CMath.Max(_view.TotalDataHeight, _content.Height);
      if not SameValue(_vertScrollBar.Max, newMax, 0.5) then
        _vertScrollBar.Max := newMax;
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

  if Result then
  begin
    // avoid circular loop
    var doIgnoreMaster := TryStartIgnoreMasterSynchronizer; //(True);
    if not doIgnoreMaster then Exit;

    try
      Result := _rowHeightSynchronizer.CanRealignContent;
    finally
      StopIgnoreMasterSynchronizer;
    end;
  end;
end;

procedure TScrollControlWithRows.CheckVertScrollbarVisibility;
begin
  var makeVisible :=
    (_view <> nil) and
    not (TDCTreeOption.HideVScrollBar in _options) and
    (_vertScrollBar.ViewPortSize + IfThen(_horzScrollBar.Visible, _horzScrollBar.Height, 0) < (_vertScrollBar.Max - 1));

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
    _selectionInfo.UpdateSingleSelection(-1, -1, nil, TDCTreeOption.KeepCurrentSelection in _Options);
end;

procedure TScrollControlWithRows.ClearSelections;
begin
  if not _selectionInfo.HasSelection then
    Exit;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.External;
  _selectionInfo.BeginUpdate;
  try
    var cln := _selectionInfo.Clone;
    _selectionInfo.ClearMultiSelections;

    _selectionInfo.UpdateLastSelection(-1, -1, nil);
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

procedure TScrollControlWithRows.ExecuteAfterRealignOnly(DoBeginUpdate: Boolean);
begin
  if DoBeginUpdate then
    RealignContentStart;

  AfterRealignContent;
  RealignFinished;  // => EndUpdate
end;

procedure TScrollControlWithRows.ExecuteKeyFromExternal(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  KeyDown(Key, KeyChar, Shift);
end;

procedure TScrollControlWithRows.ExpandCurrentRow;
begin
  DoCollapseOrExpandRow(get_Current, True);
end;

function TScrollControlWithRows.SlowItemIsSelected(const DataItem: CObject): Boolean;
begin
  var ix := _view.GetDataIndex(DataItem);
  Result := IsSelected(ix);
end;

function TScrollControlWithRows.SortActive: Boolean;
begin
  Result := (_view <> nil) and (_view.GetSortDescriptions <> nil) and (_view.GetSortDescriptions.Count > 0)
end;

function TScrollControlWithRows.TryStartIgnoreMasterSynchronizer(CheckSyncVisibility: Boolean): Boolean;
begin
  if (_rowHeightSynchronizer = nil) or _rowHeightSynchronizer.IsMasterSynchronizer or _rowHeightSynchronizer.IgnoreSynchronizer then
    Exit(False);

  if CheckSyncVisibility and (not ControlEffectiveVisible(_rowHeightSynchronizer) or not ControlEffectiveVisible(Self)) then
    Exit(False);

  inc(_masterIgnoreIndex);
  Result := True;
end;

function TScrollControlWithRows.TryStartMasterSynchronizer(CheckSyncVisibility: Boolean = False): Boolean;
begin
  Result := TryStartIgnoreMasterSynchronizer(CheckSyncVisibility);
  if not Result then Exit;

  inc(_masterSynchronizerIndex);
  if _masterSynchronizerIndex = 1 then
  begin
    // let the master take care of the sorting/filtering/current
    if _waitForRepaintInfo = nil then
      _waitForRepaintInfo := _rowHeightSynchronizer._waitForRepaintInfo;

    _rowHeightSynchronizer._waitForRepaintInfo := nil;
  end;
end;

procedure TScrollControlWithRows.StopIgnoreMasterSynchronizer(const DoTry: Boolean);
begin
  // keep code in "finally" sections simple
  if not DoTry then
    Exit;

  Dec(_masterIgnoreIndex);
end;

procedure TScrollControlWithRows.StopMasterSynchronizer(const DoTry: Boolean = True);
begin
  StopIgnoreMasterSynchronizer(DoTry);
  if not DoTry then Exit;

  dec(_masterSynchronizerIndex);
end;

function TScrollControlWithRows.SyncIsMasterSynchronizer: Boolean;
begin
  Result := (_rowHeightSynchronizer <> nil) and _rowHeightSynchronizer.IsMasterSynchronizer;
end;

function TScrollControlWithRows.FiltersActive: Boolean;
begin
  Result := (_view <> nil) and (_view.GetFilterDescriptions <> nil) and (_view.GetFilterDescriptions.Count > 0)
end;

function TScrollControlWithRows.FitRowsDownwards(StartIndex: Integer): Integer;
var
  availableHeight: Integer;
  virtualY: Single;
  dataItem: CObject;
begin
  Result := 0;

  if (StartIndex < 0) or (_View = nil) then
    Exit;

  availableHeight := Round(_Content.BoundsRect.Height);

  if StartIndex >= (_View.GetViewList.Count) then Exit;

  _View.GetSlowPerformanceRowInfo(StartIndex, dataItem, virtualY);
  Inc(_scrollUpdateCount);
  try
    _vertScrollBar.ValueRange.BeginUpdate;
    try
      _vertScrollBar.Value := virtualY;
      _vertScrollBar.ViewportSize := availableHeight;
    finally
      _vertScrollBar.ValueRange.EndUpdate;
    end;
  finally
    Dec(_scrollUpdateCount);
  end;

  DoRealignContent;
  Result := _View.ActiveViewRows.Count;
end;

constructor TScrollControlWithRows.Create(AOwner: TComponent);
begin
  inherited;

  _selectionType := TSelectionType.RowSelection;

  _selectionInfo := CreateSelectionInfoInstance;
  _rowHeightDefault := 30;
  _manualContentHeight := -1;
  _referenceRowViewListIndex := -1;

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

function TScrollControlWithRows.ProvideRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow;
begin
  if FromSelectionInfo.DataIndex = -1 then
    Exit;

  if _view <> nil then
  begin
    Result := _view.GetActiveRowIfExists(FromSelectionInfo.ViewListIndex);
    if Result <> nil then Exit;
  end;

  Result := DoCreateNewRow;
  Result.DataItem := FromSelectionInfo.DataItem;
  Result.DataIndex := FromSelectionInfo.DataIndex;
  Result.ViewListIndex := FromSelectionInfo.ViewListIndex;
end;

function TScrollControlWithRows.CreateRowBackground: IBackgroundControl;
begin
  Result := DataControlClassFactory.CreateRowRect(_content);
end;

function TScrollControlWithRows.get_DataList: IList;
begin
  Result := _dataList;
end;

function TScrollControlWithRows.get_DataModelView: IDataModelView;
begin
  Result := _dataModelView;
end;

function TScrollControlWithRows.get_IsPrinting: Boolean;
begin
  Result := _isPrinting;
end;

function TScrollControlWithRows.IsScrolling: Boolean;
begin
  Result := GetScrollingType <> TScrollingType.None;
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
    Exit(_rowHeightFixed)
  else begin
    if _rowHeightDefault = -1 {dynamic height} then
    begin
      var txt := DataControlClassFactory.CreateText(Self);
      try
        (txt as ICaption).Text := 'Ag';
        // KV: XXX
        // _rowHeightDefault := TextControlHeight(txt, (txt as ITextSettings).TextSettings, 'Ag') + (2*ROW_CONTENT_MARGIN);

        if (_rowHeightMax > 0) and (_rowHeightMax < _rowHeightDefault) then
          _rowHeightDefault := _rowHeightMax;
      finally
        // KV: XXX
        // txt.Free;
      end;
    end;

    Result := _rowHeightDefault;
  end;
end;

function TScrollControlWithRows.get_rowHeightFixed: Single;
begin
  Result := _rowHeightFixed;
end;

function TScrollControlWithRows.get_RowHeightMax: Single;
begin
  Result := _rowHeightMax;
end;

function TScrollControlWithRows.get_RowHeightSynchronizer: TScrollControlWithRows;
begin
  Result := _rowHeightSynchronizer;
end;

procedure TScrollControlWithRows.set_DataList(const Value: IList);
begin
//  if CObject.ReferenceEquals(_dataList, Value) then
//    Exit;

  if _previousHardAssignedDataModelView <> nil then
  begin
    {$IFNDEF WEBASSEMBLY}
    _previousHardAssignedDataModelView.CurrencyManager.CurrentRowChanged.Remove(DataModelViewRowChanged);
    _previousHardAssignedDataModelView.RowPropertiesChanged.Remove(DataModelViewRowPropertiesChanged);
    {$ELSE}
    _previousHardAssignedDataModelView.CurrencyManager.CurrentRowChanged -= DataModelViewRowChanged;
    _previousHardAssignedDataModelView.RowPropertiesChanged -= DataModelViewRowPropertiesChanged;
    {$ENDIF}
  end;

  _view := nil;

  _dataList := Value;
  if _dataList <> nil then
  begin
    _selectionInfo.Clear;
    RefreshControl(True);
  end else
    _dataModelView := nil;

  _previousHardAssignedDataModelView := GetDataModelView;
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

procedure TScrollControlWithRows.set_IsPrinting(const Value: Boolean);
begin
  _isPrinting := Value;
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

  if _view = nil then
    GenerateView;

  var arr: TDataIndexArray;
  SetLength(arr, 0);

  var item: CObject;
  for item in Value do
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

//  var wasDone := (_ignoreNextRowPropertiesChanged <> nil) and (_ignoreNextRowPropertiesChanged = Args);
//
//  if (_rowHeightSynchronizer <> nil) then
//  begin
//    _ignoreNextRowPropertiesChanged := Args;
//    _rowHeightSynchronizer._ignoreNextRowPropertiesChanged := Args;
//  end;
//
//  if wasDone then
//    Exit;

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
    DoCollapseOrExpandRow(drv.ViewIndex, doExpand);
//  else
//    ResetView(drv.ViewIndex);
end;
                                
procedure TScrollControlWithRows.DataModelViewRowChanged(const Sender: IBaseInterface; Args: RowChangedEventArgs);
begin
  if not HasInternalSelectCount then
  begin
    set_Current(Args.NewIndex);
    Exit;
  end;

  if ((_rowHeightSynchronizer <> nil) and (_rowHeightSynchronizer._internalSelectCount > 0)) then
  begin
    var syncSelInfo := _rowHeightSynchronizer._selectionInfo;
    _selectionInfo.BeginUpdate;
    try
      _selectionInfo.UpdateLastSelection(syncSelInfo.DataIndex, syncSelInfo.ViewListIndex, syncSelInfo.DataItem);
    finally
      _selectionInfo.EndUpdate(True {do ignore events});
    end;

    UpdateRowHeightSynchronizerScrollbar;

    var row: IDCRow;
    for row in _view.ActiveViewRows do
      VisualizeRowSelection(row);
  end;
end;

procedure TScrollControlWithRows.ModelContextChanged(const Sender: IObjectModelContext; const Context: CObject);
begin
  if HasInternalSelectCount then
    Exit;

  var dItem := _selectionInfo.DataItem;

  var drv: IDataRowView;
  if dItem.TryAsType<IDataRowView>(drv) then
    dItem := drv.Row.Data;

  if CObject.Equals(dItem, Context) then
    Exit;

  if (Context = nil) then
  begin
    set_DataItem(nil);
    Exit;
  end;

//  if _previousHardAssignedDataModelView <> nil then
//  begin
//    var dr := GetDataModel.FindByKey(Context);
//    GetDataModelView.MakeRowVisible(dr);
//  end;

  set_DataItem(Context);
end;

procedure TScrollControlWithRows.ModelContextPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
begin
  if (_view <> nil) and not MeOrSynchronizerIsUpdating and not HasUpdateCount then
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
  // if DoRealignContent should be called, but the paint event is earlier at it's "_rowHeightSynchronizer" control..
  // make sure the calculations are done first
  if not _realignContentRequested and (_rowHeightSynchronizer <> nil) and _rowHeightSynchronizer._realignContentRequested and ControlEffectiveVisible(_rowHeightSynchronizer) then
    _rowHeightSynchronizer.BeforePainting;

  inherited;
end;

procedure TScrollControlWithRows.BeforeRealignContent;
//var
//  sortChanged: Boolean;
//  filterChanged: Boolean;

begin
  if IsMasterSynchronizer then
    _rowHeightSynchronizer.BeforeRealignContent;

  if _view = nil then
    Exit;

  PrepareView;

  inherited;

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
    InitRow(thisRow);
    spaceForRows := spaceForRows - thisRow.Height;

    if (spaceForRows < 1 {avoid 0.0046 figures..}) or (thisRow.ViewListIndex = _view.ViewCount - 1) then
      Exit;

    inc(rowIndex);
    if rowIndex > createdRowsCount - 1 then
      thisRow := _view.InsertNewRowBeneeth else
      thisRow := _view.ActiveViewRows[rowIndex];
  end;
end;

procedure TScrollControlWithRows.AlignRowsAboveReference(const BottomReferenceRow: IDCRow; var SpaceForRows: Single; out HeightChangeAboveRef: Single);
begin
  var orgTotalHeight := _view.TotalDataHeight;
  try
    var thisRow := BottomReferenceRow;
    var rowIndex := BottomReferenceRow.ViewPortIndex;

    while thisRow <> nil do
    begin
      if thisRow <> BottomReferenceRow then
      begin
        InitRow(thisRow);
        spaceForRows := spaceForRows - thisRow.Height;
      end;

      if (spaceForRows <= 0) or (thisRow.ViewListIndex = 0) then
        Exit;

      dec(rowIndex);
      if rowIndex < 0 then
        thisRow := _view.InsertNewRowAbove else
        thisRow := _view.ActiveViewRows[rowIndex];
    end;
  finally
    {out} HeightChangeAboveRef := _view.TotalDataHeight - orgTotalHeight;
  end;
end;

procedure TScrollControlWithRows.CreateAndSynchronizeSynchronizerRow(const Row: IDCRow);
begin
  if not SyncIsMasterSynchronizer and not IsMasterSynchronizer then
    Exit; // nothing to do

  var otherRow := _rowHeightSynchronizer.View.GetActiveRowIfExists(Row.ViewListIndex);
  if IsMasterSynchronizer then
  begin
    if otherRow = nil then
      otherRow := _rowHeightSynchronizer.View.InsertNewRowFromIndex(Row.ViewListIndex, Row.ViewPortIndex);

    _rowHeightSynchronizer.View.ReindexActiveRow(otherRow);

    _rowHeightSynchronizer.InitRow(otherRow);
  end;

  if otherRow.Height > Row.Height then
    Row.Control.Height := otherRow.Height;
end;

procedure TScrollControlWithRows.InnerInitRow(const Row: IDCRow; RowHeightNeedsRecalc: Boolean = False);
begin
//  _newLoadedTreeRows.Add(Row);
end;

function TScrollControlWithRows.IgnoreSynchronizer: Boolean;
begin
  Result := _masterIgnoreIndex > 0;
end;

procedure TScrollControlWithRows.InitRow(const Row: IDCRow);
begin
  var rowInfo := _view.RowLoadedInfo(Row.ViewListIndex);
  var isFastScrollbarScrolling := IsFastScrolling(True);
  var rowNeedsReload := IsPrinting or Row.IsScrollingIntoView or not rowInfo.InnerCellsAreApplied or (rowInfo.ControlNeedsResizeSoft and (GetScrollingType <> TScrollingType.WithScrollBar));

  var oldRowHeight: Single := -1;

  if rowInfo.ReloadAfterScroll and not isFastScrollbarScrolling {(_scrollingType = TScrollingType.None)} then
  begin
    oldRowHeight := _view.GetRowHeight(Row.ViewListIndex);

    // row height will be reset
    rowInfo := _view.NotifyRowControlsNeedReload(Row, False {reset force realign this row});
    rowNeedsReload := True;
  end
  else if rowNeedsReload then
    oldRowHeight := _view.GetRowHeight(Row.ViewListIndex);

  if rowNeedsReload then
  begin
    if Row.Control = nil then
    begin
      var ly := TRowLayout.Create(_content, CreateRowBackground);
//      ly.ClipChildren := True; // costs a lot of time , while we can also do this on lower level..
      ly.HitTest := False;
      ly.Align := TAlignLayout.None;

      Row.Control := ly;

      _content.AddObject(Row.Control);

      if (TreeOption_ShowHorzGrid in _options) then
        ly.Sides := [TSide.Bottom] else
        ly.Sides := [];
    end;

    if DrawRowBackground then
      DataControlClassFactory.HandleRowBackground(Row.ControlAsRowLayout.Background, (TreeOption_AlternatingRowBackground in _options), not Row.IsOddRow);

    Row.Control.Position.X := 0;

    if not rowInfo.ControlNeedsResizeSoft then
      Row.Control.Height := oldRowHeight else
      Row.Control.Height := get_rowHeightDefault;

    InnerInitRow(Row, rowInfo.ControlNeedsResizeSoft);
    DoRowLoaded(Row);
  end;

  PerformanceRoutineLoadedRow(Row);
  Row.Control.Width := CalculateRowControlWidth(False);
  Row.UseBuffering := True;

  CreateAndSynchronizeSynchronizerRow(Row);

  if rowNeedsReload then
  begin
    var rowHeightChanged := not SameValue(oldRowHeight, Row.Control.Height);
    if rowHeightChanged and (GetScrollingType = TScrollingType.WithScrollBar) then
    begin
      // We do not!!!! accept a row height change while user is scrolling with scrollbar
      // because this will give flickering. AFter scroll release the row is reloaded automatically
      // rowHeightChanged := False;
      row.Control.Height := oldRowHeight;
    end;
  end;

  rowInfo := _view.RowLoadedInfo(Row.ViewListIndex) {reload the rowInfo, for it can be changed};

  var softRowHeightNeedsResizeAfterScrolling := rowInfo.ControlNeedsResizeSoft and (GetScrollingType = TScrollingType.WithScrollBar);
  _view.RowLoaded(Row, softRowHeightNeedsResizeAfterScrolling);

  // if user tells in CellLoading / CellLoaded that a cell control should be loaded after scrolling is done (for performance)
  if rowInfo.ReloadAfterScroll then
    RestartWaitForRealignTimer(True, True {only realign when scrolling stopped});
end;

procedure TScrollControlWithRows.UpdateAndIgnoreVertScrollbar(const NewValue: Single);
begin
  // it can be due to max vertscrollbar value that the value is lower than NewValue
  inc(_scrollUpdateCount);
  try
    _vertScrollBar.Value := NewValue;
  finally
    dec(_scrollUpdateCount);
  end;

  UpdateRowHeightSynchronizerScrollbar;
end;

procedure TScrollControlWithRows.UpdateHoverRect(MousePos: TPointF);
begin
  if (TreeOption_HideHoverEffect in _options) or IsScrolling or MousePos.IsZero or _isExpandingOrCollapsing then
  begin
    _hoverRect.Visible := False;
    Exit;
  end;

  var row := GetRowByLocalY(MousePos.Y);
  _hoverRect.Visible := (row <> nil) and {(_selectionType <> TSelectionType.HideSelection) and} _selectionInfo.CanSelect(row.DataIndex);
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
  var waitingForPaint := RealignedButNotPainted;

  if Key in [vkPrior, vkNext] then
  begin
    // in case the up/down button stays pressed, and the tree is not quick enough to repaint before it recalculates again
    if waitingForPaint then
    begin
      Key := 0;
      Exit;
    end;

    if Key = vkPrior then
    begin
      if Current = 0 then
      begin
        Key := 0;
        Exit;
      end;

      var rowZero := _view.ActiveViewRows[0];

      if rowZero.ViewListIndex <= 1 then
      begin
        InternalSetCurrent(0, TSelectionEventTrigger.Key, Shift);
        Exit;
      end;
        
      _selectionInfo.BeginUpdate;
      try
        InternalSetCurrent(rowZero.ViewListIndex {+ 1}, TSelectionEventTrigger.Key, Shift);      
      finally
        _selectionInfo.EndUpdate(True);
      end;
      UpdateAndIgnoreVertScrollbar(rowZero.VirtualYPosition + rowZero.Height - _vertScrollBar.ViewportSize);
      RealignFromSelectionChange;

      rowZero := _view.ActiveViewRows[0];
      // check if row is only partly visible
      if (rowZero.VirtualYPosition < _vertScrollBar.Value) and (_view.ActiveViewRows.Count > 1) then
        rowZero := _view.ActiveViewRows[1];
        
      InternalSetCurrent(rowZero.ViewListIndex {+ 1}, TSelectionEventTrigger.Key, Shift);   
      UpdateAndIgnoreVertScrollbar(rowZero.VirtualYPosition);  
      RealignFromSelectionChange;

      Key := 0;
      Exit;
    end

    else if Key = vkNext then
    begin
      if Current = _view.ViewCount - 1 then
      begin
        Key := 0;
        Exit;
      end;

      var rowBottom := _view.ActiveViewRows[_view.ActiveViewRows.Count - 1];

      if _view.ViewCount = rowBottom.ViewListIndex + 1 then
      begin
        InternalSetCurrent(rowBottom.ViewListIndex, TSelectionEventTrigger.Key, Shift);
        Exit;
      end;
                 
      _selectionInfo.BeginUpdate;
      try
        InternalSetCurrent(rowBottom.ViewListIndex {+ 1}, TSelectionEventTrigger.Key, Shift);      
      finally
        _selectionInfo.EndUpdate(True);
      end;
      UpdateAndIgnoreVertScrollbar(rowBottom.VirtualYPosition);
      RealignFromSelectionChange;

      rowBottom := _view.ActiveViewRows[_view.ActiveViewRows.Count - 1];
      // check if bottomrow is only partly visible
      if (rowBottom.VirtualYPosition + rowBottom.Height > _vertScrollBar.Value + _vertScrollBar.ViewportSize) and (_view.ActiveViewRows.Count > 1) then
        rowBottom := _view.ActiveViewRows[_view.ActiveViewRows.Count - 2];
        
      InternalSetCurrent(rowBottom.ViewListIndex {+ 1}, TSelectionEventTrigger.Key, Shift);   
      UpdateAndIgnoreVertScrollbar(rowBottom.VirtualYPosition + rowBottom.Height - _vertScrollBar.ViewportSize);  
      RealignFromSelectionChange;
      
      Key := 0;
      Exit;
    end;
  end;


  var rowViewListIndex := GetRowViewListIndexByKey(Key, Shift);

  // no row visible / available anymore
  // refreshcontrol in case a row was showing, butis filtered out now
  if rowViewListIndex = -1 then
  begin
    RefreshControl(True);
    Exit;
  end;

  if _selectionInfo.ViewListIndex <> rowViewListIndex then
  begin
    // in case the up/down button stays pressed, and the tree is not quick enough to repaint before it recalculates again
    if not waitingForPaint and CanRealignScrollCheck then
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

procedure TScrollControlWithRows.AnimateRow(const Row: IDCRow; StartY, StopY: Single; AnimateOpacity: Boolean; Hide: Boolean; ExtraDelay: Single = 0);

  procedure DoAnimate(const Row: IDCRow);
  begin
    Row.UseBuffering := False;
    Row.Control.Position.Y := StartY;
    if AnimateOpacity then
      Row.Control.AnimateFloatDelay('Position.Y', StopY, ANI_DURATION, ANI_DELAY + ExtraDelay, TAnimationType.Out, TInterpolationType.Quadratic) else
      Row.Control.AnimateFloatDelay('Position.Y', StopY, ANI_DURATION, ANI_DELAY + ExtraDelay, TAnimationType.InOut, TInterpolationType.Quadratic);

    if AnimateOpacity then
    begin
      Row.Control.Opacity := IfThen(Hide, Row.Control.Opacity, 0);
      Row.Control.AnimateFloatDelay('Opacity', IfThen(Hide, 0, 1), ANI_DURATION, ANI_DELAY + ExtraDelay, TAnimationType.InOut, TInterpolationType.Quadratic);
    end
    else if Hide then
      Row.Control.Opacity := 0;
  end;

begin
  DoAnimate(Row);

  if (_rowHeightSynchronizer <> nil) and (_rowHeightSynchronizer.View <> nil) then
  begin
    var otherRow := _rowHeightSynchronizer.View.GetActiveRowIfExists(Row.ViewListIndex);
    if otherRow <> nil then
      DoAnimate(otherRow);
  end;
end;

procedure TScrollControlWithRows.ExecuteAfterAnimateRow(const Row: IDCRow; Event: TNotifyEvent; ExtraDelay: Single = 0);
begin
  Row.UseBuffering := False;
  Row.Control.Opacity := 0.5;

  var ani := TFloatAnimation.Create(nil);
  ani.Parent := Row.Control;
  ani.Duration := ANI_DURATION;
  ani.Delay := ANI_DELAY + ExtraDelay;
  ani.PropertyName := 'Opacity';
  ani.StartFromCurrent := True;
  ani.StopValue := 1;
  ani.OnFinish := Event;
  ani.Start;
end;

procedure TScrollControlWithRows.VisualizeRowExpand(ViewListIndex: Integer);
begin
  _isExpandingOrCollapsing := True;
  UpdateHoverRect(PointF(0,0));

  var parentRow := _view.GetActiveRowIfExists(ViewListIndex);
  if parentRow = nil then
  begin
    if ViewListIndex <> _selectionInfo.ViewListIndex then
    begin
      _selectionInfo.BeginUpdate;
      try
        _selectionInfo.UpdateLastSelection(parentRow.DataIndex, parentRow.ViewListIndex, parentRow.DataItem);
      finally
        _selectionInfo.EndUpdate(True);
      end;
    end;

    OnCollapseTimer(nil);
    Exit;
  end;

  var rowCountBelowParentRow := _view.ActiveViewRows.Count - 1 - parentRow.ViewPortIndex;

  var orgHeight := parentRow.Height;

  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer(True);
  try
    ResetView(ViewListIndex);
  finally
    StopIgnoreMasterSynchronizer(doIgnoreMaster);
  end;

  if ViewListIndex <> _selectionInfo.ViewListIndex then
  begin
    InternalSetCurrent(ViewListIndex, TSelectionEventTrigger.Key, []);
    RealignFromSelectionChange;
  end else
    DoRealignContent;

  StopWaitForRealignTimer;

  // because parentrow changed, get it again
  parentRow := _view.GetActiveRowIfExists(ViewListIndex);
  var drv := parentRow.DataItem.AsType<IDataRowView>;
  var oldParentPos := parentRow.Control.Position.Y;
  var row: IDCRow;

  // check if children fit in current view, otherwise scroll parent up...
  var spaceAvailableForParentAndChildren := _vertScrollBar.ViewportSize - (parentRow.VirtualYPosition - _vertScrollBar.Value);

  var parentAndChildrenHeight := parentRow.Height;
  var childCount := CMath.Min(drv.DataView.ChildCount(drv), _view.ActiveViewRows.Count - 1);

  var goMaster := TryStartMasterSynchronizer(True);
  try
    var childNo := 0;
    for var viewPortIndex := parentRow.ViewPortIndex + 1 to parentRow.ViewPortIndex + childCount + rowCountBelowParentRow do
    begin
      inc(childNo);
      if _view.ActiveViewRows.Count - 1 >= viewPortIndex then
        row := _view.ActiveViewRows[viewPortIndex]
      else
      begin
        row := _view.ProvideReferenceRowForViewIndex(parentRow.ViewListIndex + childNo);
        InitRow(row);
      end;

      // other rows are normal rows below
      if viewPortIndex <= parentRow.ViewPortIndex + childCount then
        parentAndChildrenHeight := parentAndChildrenHeight + row.Height;
    end;
  finally
    StopMasterSynchronizer(goMaster);
  end;

  var newParentPos := oldParentPos;
  if parentAndChildrenHeight > spaceAvailableForParentAndChildren then
    newParentPos := CMath.Max(0, newParentPos - (parentAndChildrenHeight - spaceAvailableForParentAndChildren));

  _scrollAfterExpandCollapse := Round(newParentPos - parentRow.Control.Position.Y);

  var diff := parentRow.Control.Position.Y - NewParentPos; // can be 0

  // for rows that are above the parentrow and have to scroll up to give the childs room
  if diff > 0 then
  begin
    var rowYPos := _view.ActiveViewRows[0].Control.Position.Y;
    for var rowAboveIx := 0 to parentRow.ViewPortIndex do
    begin
      var startPos := rowYPos;
      var stopPos := rowYPos - diff;

      row := _view.ActiveViewRows[rowAboveIx];
      AnimateRow(row, startPos, stopPos, False, False);

      rowYPos := rowYPos + row.Height;
    end;
  end;

  // for the new child rows
  var extraDelay := 0.15;
  var rowYPos := newParentPos + parentRow.Height;
  for var rowChildIx := parentRow.ViewPortIndex + 1 to parentRow.ViewPortIndex + childCount do
  begin
    var startPos := newParentPos + (rowYPos - newParentPos)*0.45;
    var stopPos := rowYPos;

    row := _view.ActiveViewRows[rowChildIx];
    AnimateRow(row, startPos, stopPos, True, False, extraDelay);
    extraDelay := extraDelay + 0.01;

    rowYPos := rowYPos + row.Height;
  end;

  var parentRowDiff := orgHeight - parentRow.Height;

  // for rows that were below the parentrow and that scroll out of view
  var rowsHeight := 0.0;
  for var rowBelowIx := parentRow.ViewPortIndex + childCount + 1 to _view.ActiveViewRows.Count - 1 do
  begin
    var startPos := oldParentPos + parentRow.Height + rowsHeight + parentRowDiff; // + 15 {just to look cool with a gappie};
    var stopPos := oldParentPos + parentAndChildrenHeight + rowsHeight;

    row := _view.ActiveViewRows[rowBelowIx];
    AnimateRow(row, startPos, stopPos, False, False, -0.15);

    rowsHeight := rowsHeight + row.Height;
  end;

  if not SameValue(parentRowDiff, 0) then
  begin
    var newHeight := parentRow.Height;
    parentRow.Control.Height := newHeight + parentRowDiff;
    parentRow.Control.AnimateFloatDelay('Height', newHeight, ANI_DURATION, ANI_DELAY, TAnimationType.InOut, TInterpolationType.Quadratic);
  end;

  ExecuteAfterAnimateRow(parentRow, OnExpandTimer, extraDelay);
end;

procedure TScrollControlWithRows.OnExpandTimer(Sender: TObject);
begin
  _isExpandingOrCollapsing := False;
  CalculateScrollBarMax;
  ScrollManualInstant(_scrollAfterExpandCollapse);
end;

procedure TScrollControlWithRows.VisualizeRowCollapse(ViewListIndex: Integer);
begin
  _isExpandingOrCollapsing := True;
  UpdateHoverRect(PointF(0,0));

  var parentRow := _view.GetActiveRowIfExists(ViewListIndex);
  if parentRow = nil then
  begin
    if ViewListIndex <> _selectionInfo.ViewListIndex then
      InternalSetCurrent(ViewListIndex, TSelectionEventTrigger.Key, []);

    OnCollapseTimer(nil);
    Exit;
  end;

  var drv := parentRow.DataItem.AsType<IDataRowView>;

  if ViewListIndex <> _selectionInfo.ViewListIndex then
  begin
    _selectionInfo.BeginUpdate;
    try
      _selectionInfo.UpdateLastSelection(parentRow.DataIndex, parentRow.ViewListIndex, parentRow.DataItem);
    finally
      _selectionInfo.EndUpdate(True);
    end;
  end;


//  var childCount := 0;
//  if _view.ActiveViewRows.Count > parentRow.ViewPortIndex + 1 then
//  begin
//    var parentLevel := parentRow.ParentCount;
//    var childIx := parentRow.ViewPortIndex + 1;
//    var childLevel := _view.ActiveViewRows[parentRow.ViewPortIndex + 1].ParentCount;
//    while (_view.ActiveViewRows.Count > childIx) and (_view.ActiveViewRows[childIx].ParentCount > parentLevel) do
//    begin
//      inc(childIx);
//      inc(childCount);
//    end;
//  end;
//
//  // hide children
//  for var rowChildIx := parentRow.ViewPortIndex + 1 to parentRow.ViewPortIndex + childCount do
//  begin
//    var row := _view.ActiveViewRows[rowChildIx];
//    var pos := row.Control.Position.Y;
//    AnimateRow(row, pos, pos, True, True);
//  end;

//  ExecuteAfterAnimateRow(parentRow, OnCollapseTimer);
  OnCollapseTimer(nil);
end;

procedure TScrollControlWithRows.OnCollapseTimer(Sender: TObject);
begin
  _isExpandingOrCollapsing := False;

  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer(True);
  try
    ResetView(_selectionInfo.ViewListIndex);
  finally
    StopIgnoreMasterSynchronizer(doIgnoreMaster);
  end;

  RefreshControl(False);
end;

procedure TScrollControlWithRows.DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean);
begin
  if HasInternalSelectCount then
    Exit;

  var drv: IDataRowView;
  if not _view.GetViewList[ViewListIndex].TryAsType<IDataRowView>(drv) then
    Exit;

  inc(_internalSelectCount);
  try
    drv.DataView.IsExpanded[drv.Row] := DoExpand;
  finally
    dec(_internalSelectCount);
  end;

  if DoExpand then
    VisualizeRowExpand(ViewListIndex) else
    VisualizeRowCollapse(ViewListIndex);
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


procedure TScrollControlWithRows.ValidateSelectionInfo;
begin
  if (_view = nil) or (_view.ViewCount = 0) then
    Exit;

  if ViewIsDataModelView then
  begin
    if not _resetRowDataItem {and (_selectionInfo.ViewListIndex <> -1)} then
      Exit;

    _resetRowDataItem := False;
  end else
  begin
    if (_selectionInfo.ViewListIndex <> -1) then
      Exit;

    if ((_model = nil) or (_model.ObjectContext = nil)) then
      Exit;
  end;

  _selectionInfo.BeginUpdate;
  try
    if ViewIsDataModelView then
    begin
      var dmv := _dataModelView;
      if dmv = nil then
        dmv := (_dataList as IDataModel).DefaultView;

      if dmv.CurrencyManager.Current <> -1 then
      begin
        var drv := dmv.Rows[dmv.CurrencyManager.Current];
        _selectionInfo.UpdateLastSelection(drv.Row.get_Index, drv.ViewIndex, drv);
      end;
    end else
    begin
      var di := _model.ObjectContext;
      var diIndex := _view.GetViewListIndex(di);
      var diViewIndex := _view.GetViewListIndex(diIndex);

      _selectionInfo.UpdateLastSelection(diIndex, diViewIndex, di);
    end;
  finally
    _selectionInfo.EndUpdate(True {Ignore events at this point});
  end;
end;

procedure TScrollControlWithRows.OnSelectionInfoChanged;
begin
  if SyncIsMasterSynchronizer then
    Exit;

  ValidateSelectionInfo;

  AtomicIncrement(_internalSelectCount);
  try
    if (_model <> nil) then
    begin
      if SelectionCount > 1 then
        _model.MultiSelect.Context := SelectedItems else
        _model.MultiSelect.Context := nil;

      var convertedDataItem := ConvertToDataItem(Self.DataItem);

      // trigger a ContextChanged event for multiselect change event
      if _model.HasMultiSelection and (_model.ObjectContext = convertedDataItem) then
      begin
        (_model.ObjectModelContext as IUpdatableObject).BeginUpdate;
        try
          _model.ObjectContext := nil;
        finally
          (_model.ObjectModelContext as IUpdatableObject).EndUpdate;
        end;
      end;

      _model.ObjectContext := convertedDataItem;
    end
    else if (GetDataModelView <> nil) and (Self.DataItem <> nil) and (Self.DataItem.IsOfType<IDataRowView>) then
      GetDataModelView.CurrencyManager.Current := Self.DataItem.AsType<IDataRowView>.ViewIndex;
  finally
    AtomicDecrement(_internalSelectCount);
  end;

  if (_realignState in [TRealignState.Waiting, TRealignState.BeforeRealign]) then
    Exit;

  if _realignState <> TRealignState.Realigning then
    ScrollSelectedIntoView(_selectionInfo);

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    VisualizeRowSelection(row);

  if IsMasterSynchronizer then
    _rowHeightSynchronizer.OnSelectionInfoChanged;
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

procedure TScrollControlWithRows.PerformanceRoutineLoadedRow(const Row: IDCRow);
begin
end;

function TScrollControlWithRows.ViewIsDataModelView: Boolean;
begin
  Result := (_dataModelView <> nil) or interfaces.Supports<IDataModel>(_dataList);
end;

function TScrollControlWithRows.IsPartOfSelectedParentChildGroup(const Row: IDCRow): Boolean;
begin
  if not ViewIsDataModelView then
    Exit(False);

  if not Row.HasVisibleChildren and (Row.ParentCount = 0) then
    Exit(False);

  var drv := Row.DataItem.AsType<IDataRowView>;
  var view := drv.DataView;

  var selDrv := view.Rows[view.CurrencyManager.Current];

  if drv = selDrv then
    Result := True
  else if drv.Row.Level < selDrv.Row.Level then
    Result := view.Parent(selDrv) = drv
  else if drv.Row.Level > selDrv.Row.Level then
    Result := view.Parent(drv) = selDrv
  else
    Result := (drv.Row.Level > 0) and (view.Parent(drv) = view.Parent(selDrv));
end;

procedure TScrollControlWithRows.HandleRowChildRelation(const Row: IDCRow; IsOpenParent, IsOpenChild: Boolean);
begin
  DataControlClassFactory.HandleRowChildRelation(Row.ControlAsRowLayout, isOpenParent, isOpenChild, Row.Control.Width);
end;

procedure TScrollControlWithRows.VisualizeRowSelection(const Row: IDCRow);
begin
  if (_selectionType <> TSelectionType.HideSelection) then
  begin
    Row.UpdateSelectionVisibility(_selectionInfo, Self.IsFocused);

    if DrawRowBackground and (_visualizeParentChilds <> TVisualizeParentChilds.No) then
    begin
      var isOpenParent := False;
      var isOpenChild := False;
      var isParentChilds: Boolean;

      if ViewIsDataModelView then
      begin
        var drv := Row.DataItem.AsType<IDataRowView>;

        isParentChilds := (drv <> nil) and ((drv.DataView.ChildCount(drv) > 0) or (drv.Row.Level > 0));
        if isParentChilds and ((_visualizeParentChilds = TVisualizeParentChilds.Yes) or IsPartOfSelectedParentChildGroup(Row)) then
        begin
          isOpenParent := Row.HasVisibleChildren;
          if not isOpenParent then
            isOpenChild := True;
        end;
      end;

      HandleRowChildRelation(Row, isOpenParent, isOpenChild);
    end;
  end;
end;

procedure TScrollControlWithRows.OnViewChanged(Sender: TObject; e: EventArgs);
begin
  if HasUpdateCount or not CanRealignContent then
    Exit;

  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer(True);
  try
    _resetRowDataItem := True;
    ResetView;

    // in case of a revert of a newly added item..
    if _selectionInfo.ViewListIndex > _view.ViewCount - 1 then
    begin
//      _mustShowSelectionInRealign := False;
      ClearSelections;
    end;
  finally
    StopIgnoreMasterSynchronizer(doIgnoreMaster);
  end;
end;

procedure TScrollControlWithRows.PrepareView;

  procedure UpdateSelectionInfo(const ScrolControlWithRows: TScrollControlWithRows; ViewListIndex: Integer);
  begin
    ScrolControlWithRows._selectionInfo.BeginUpdate;
    try
      ScrolControlWithRows._selectionInfo.UpdateLastSelection(ScrolControlWithRows._view.GetDataIndex(ViewListIndex), ViewListIndex, ScrolControlWithRows._view.GetViewList[ViewListIndex]);
    finally
      ScrolControlWithRows._selectionInfo.EndUpdate(True {ignore events});
    end;
  end;

begin
  if (_rowHeightSynchronizer <> nil) then
  begin
    if not SameValue(_rowHeightDefault, _rowHeightSynchronizer._rowHeightDefault) then
    begin
      var bestDefault := CMath.Max(_rowHeightDefault, _rowHeightSynchronizer._rowHeightDefault);
      _rowHeightDefault := bestDefault;
      _rowHeightSynchronizer._rowHeightDefault := bestDefault;
    end;

    if not SameValue(_rowHeightFixed, _rowHeightSynchronizer._rowHeightFixed) then
    begin
      var bestFixed := CMath.Max(_rowHeightFixed, _rowHeightSynchronizer._rowHeightFixed);
      _rowHeightFixed := bestFixed;
      _rowHeightSynchronizer._rowHeightFixed := bestFixed;
    end;
  end;

  // must be below bestDefault/bestFixed
  _view.Prepare(get_rowHeightDefault);

  if _waitForRepaintInfo = nil then
    Exit;

  var sortChanged := (TTreeRowState.SortChanged in _waitForRepaintInfo.RowStateFlags);
  var filterChanged := (TTreeRowState.FilterChanged in _waitForRepaintInfo.RowStateFlags);

  inc(_updateCount);
  try
    if sortChanged then
      _view.ApplySort(_waitForRepaintInfo.SortDescriptions);

    if filterChanged then
      _view.ApplyFilter(_waitForRepaintInfo.FilterDescriptions);

    // reset view
    if (sortChanged or filterChanged) then
    begin
      ResetView;

//      // CalculateScrollBarMax is already done in inherited, but at that point the view is not correct yet
//      if filterChanged then
//        CalculateScrollBarMax;
    end;
  finally
    dec(_updateCount);
  end;

  var viewIndex: Integer := -1;
  if TTreeRowState.RowChanged in _waitForRepaintInfo.RowStateFlags then
  begin
    if _waitForRepaintInfo.DataItem <> nil then
      viewIndex := _view.GetViewListIndex(_waitForRepaintInfo.DataItem) else
      viewIndex := _waitForRepaintInfo.Current;
  end;

  // if filter changed, we try to scroll back to the last selected dataitem
  var customDataItem: CObject := get_DataItem;
  if (viewIndex = -1) and filterChanged and (customDataItem <> nil) then
    viewIndex := _view.GetViewListIndex(customDataItem);

  if (viewIndex <> -1) and (_view.ViewCount > 0) and (viewIndex <= _view.ViewCount - 1) then
  begin
    UpdateSelectionInfo(self, viewIndex);

    if IsMasterSynchronizer then
      UpdateSelectionInfo(_rowHeightSynchronizer, viewIndex);

//    _referenceRowViewListIndex := viewIndex;
  end;
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

procedure TScrollControlWithRows.UpdateScrollBarValues(const NewValue: Single);
begin
  CalculateScrollBarMax;
       
  // after CalculateScrollBarMax!! 
  UpdateAndIgnoreVertScrollbar(NewValue);
end;

procedure TScrollControlWithRows.AssignSelection(const SelectedItems: IList);
begin
  if (SelectedItems = nil) or (SelectedItems.Count = 0) then
    Exit;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.External;
  _selectionInfo.BeginUpdate;
  try
    _selectionInfo.ClearAllSelections;

    var item: CObject;
    for item in SelectedItems do
    begin
      if _view = nil then
        GenerateView;

      var viewListIndex := _view.GetViewListIndex(item);
      var dataIndex := _view.GetDataIndex(viewListIndex);

      if dataIndex <> -1 then
        _selectionInfo.AddToSelection(dataIndex, viewListIndex, item, False);
    end;


//    if (not (TreeOption_MultiSelect in _options)) or (SelectedItems.Count = 1) then
//    begin
//      var viewListIndex := _view.GetViewListIndex(SelectedItems[0]);
//      var dataIndex := _view.GetDataIndex(viewListIndex);
//
//      if dataIndex <> -1 then
//        _selectionInfo.UpdateSingleSelection(dataIndex, viewListIndex, SelectedItems[0], TDCTreeOption.KeepCurrentSelection in _Options);
//    end else
//    begin
//      var item: CObject;
//      for item in SelectedItems do
//      begin
//        var viewListIndex := _view.GetViewListIndex(item);
//        var dataIndex := _view.GetDataIndex(viewListIndex);
//
//        if dataIndex <> -1 then
//          _selectionInfo.AddToSelection(dataIndex, viewListIndex, item);
//      end;
//    end;
  finally
    _selectionInfo.EndUpdate;
  end;
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

  if IsMasterSynchronizer then
    _rowHeightSynchronizer.UpdateYPositionRows;
end;

procedure TScrollControlWithRows.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var clickedRow := GetRowByLocalY(Y);
  if clickedRow = nil then Exit;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Click;

  InternalDoSelectRow(clickedRow.DataIndex, clickedRow.ViewListIndex, clickedRow.DataItem, Shift);
end;

procedure TScrollControlWithRows.InternalDoSelectRow(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; Shift: TShiftState);
begin
  if CObject.Equals(get_DataItem, DataIndex) and ((ssCtrl in Shift) = (_selectionInfo.SelectedRowCount > 1)) and (_selectionInfo.ViewListIndex = ViewListIndex {insert before and than go down}) then
  begin
    if (_selectionInfo.SelectedRowCount > 1) then
      _selectionInfo.Deselect(DataIndex);

    Exit;
  end;

  if (TDCTreeOption.MultiSelect in _options) and (ssShift in Shift) then
  begin
    var lastSelectedIndex := _selectionInfo.ViewListIndex;

    var vlIndex := lastSelectedIndex;
    while vlIndex <> ViewListIndex do
    begin
      _selectionInfo.AddToSelection(_view.GetDataIndex(vlIndex), vlIndex, _view.GetViewList[vlIndex], False);

      if lastSelectedIndex < ViewListIndex then
        inc(vlIndex) else
        dec(vlIndex);
    end;

    _selectionInfo.AddToSelection(DataIndex, ViewListIndex, DataItem, False);
  end
  else if (ssCtrl in Shift) and (_selectionInfo.LastSelectionEventTrigger = TSelectionEventTrigger.Click) then
  begin
    if not _selectionInfo.IsChecked(DataIndex) then
      _selectionInfo.AddToSelection(DataIndex, ViewListIndex, DataItem, True {ExpandCurrentSelection}) else
      _selectionInfo.Deselect(DataIndex);
  end else
    _selectionInfo.UpdateSingleSelection(DataIndex, ViewListIndex, DataItem, TDCTreeOption.KeepCurrentSelection in _Options);
end;

procedure TScrollControlWithRows.InternalSetCurrent(const Index: Integer; const EventTrigger: TSelectionEventTrigger; Shift: TShiftState; SortOrFilterChanged: Boolean = False);
begin
  _selectionInfo.LastSelectionEventTrigger := EventTrigger;

  var requestedSelection := _selectionInfo.Clone;
  requestedSelection.UpdateLastSelection(_view.GetDataIndex(Index), Index, _view.GetViewList[Index]);
  TrySelectItem(requestedSelection, Shift);
end;

function TScrollControlWithRows.IsFastScrolling(ScrollbarOnly: Boolean = False): Boolean;
begin
  Result := inherited;

  if not Result and (_rowHeightSynchronizer <> nil) and not IgnoreSynchronizer then
  begin
    var doIgnoreMaster := TryStartIgnoreMasterSynchronizer(False);
    try
      Result := _rowHeightSynchronizer.IsFastScrolling(ScrollbarOnly);
    finally
      StopignoreMasterSynchronizer(doIgnoreMaster);
    end;
  end;
end;

function TScrollControlWithRows.IsMasterSynchronizer: Boolean;
begin
  Result := (_masterSynchronizerIndex > 0);
end;

function TScrollControlWithRows.IsSelected(const DataIndex: Integer): Boolean;
begin
  Result := False;
  if _view = nil then Exit;

  Result := _selectionInfo.IsSelected(DataIndex);
end;

procedure TScrollControlWithRows.DoViewLoadingStart(const startY, StopY: Single; const ReferenceRow: IDCRow);
begin
//  _scrollbarMaxChangeSinceViewLoading := 0;
//  _scrollbarRefToTopHeightChangeSinceViewLoading := 0;

  _view.ViewLoadingStart(startY, StopY, ReferenceRow);
  if IsMasterSynchronizer then
  begin
    _rowHeightSynchronizer._realignState := TRealignState.Realigning;
    _rowHeightSynchronizer.View.ViewLoadingStart(_view);
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

function TScrollControlWithRows.DrawRowBackground: Boolean;
begin
  Result := True;
end;

procedure TScrollControlWithRows.DoViewLoadingFinished;
begin
  if IsMasterSynchronizer then
    _rowHeightSynchronizer.View.ViewLoadingFinished;

  _view.ViewLoadingFinished;
end;

procedure TScrollControlWithRows.RealignFromSelectionChange;
begin
  var goMaster := TryStartMasterSynchronizer(True);
  try
    StartScrolling;
    try
      var isInRealignProcess := _realignState <> TRealignState.RealignDone;

      if not isInRealignProcess then
        RealignContentStart;

      _referenceRowViewListIndex := _selectionInfo.ViewListIndex;
      RealignContent;

      if not isInRealignProcess then
        ExecuteAfterRealignOnly(False);
    finally
      StopScrolling;
    end;
  finally
    StopMasterSynchronizer(goMaster);
  end;
end;

procedure TScrollControlWithRows.AfterScrolling;
begin
  inherited;

  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer(False);
  try
    if doIgnoreMaster then
      _rowHeightSynchronizer.AfterScrolling;
  finally
    StopignoreMasterSynchronizer(doIgnoreMaster);
  end;

  if _view <> nil then
    for var row in _view.ActiveViewRows do
    begin
//      row.UseBuffering := True;
      PerformanceRoutineLoadedRow(row);
    end;

  UpdateHoverRect(_lastMousePos);
end;

function TScrollControlWithRows.PrepareReferenceRowBeforeRealignContent(out StartY: Single; out AlignBottomToTop: Boolean): IDCRow;
begin
  if (_view = nil) or (_view.ViewCount = 0) then
  begin
    StartY := 0;
    Exit(nil);
  end;

  StartY := _vertScrollBar.Value;

  if _referenceRowViewListIndex <> -1 then
  begin
    var existed := _view.GetActiveRowIfExists(_referenceRowViewListIndex) <> nil;

    Result := _view.ProvideReferenceRowForViewIndex(_referenceRowViewListIndex);
    var prevRefHeight := _view.GetRowHeight(Result.ViewListIndex);

    InitRow(Result);

    AlignBottomToTop := SameValue(Result.VirtualYPosition + prevRefHeight, _vertScrollBar.Value + _vertScrollBar.ViewportSize, 0.5);
    if not existed or (prevRefHeight <> Result.Height) then
    begin
      if AlignBottomToTop then
        startY := startY + (Result.Height - prevRefHeight) else
        startY := CMath.Min(_vertScrollBar.Max - _vertScrollBar.ViewportSize, Result.VirtualYPosition);
    end;
  end else
  begin
    AlignBottomToTop := ((_vertScrollBar.Value > 0) and (_vertScrollBar.Value + _vertScrollBar.ViewportSize = _vertScrollBar.Max));
    Result := _view.ProvideReferenceRowForViewRange(startY, startY + _vertScrollBar.ViewportSize, AlignBottomToTop);
  end;
end;

procedure TScrollControlWithRows.RealignContent;
begin
  if _view = nil then
    Exit;

  try
    inherited;

    var startY: Single;
    var alignBottomToTop: Boolean;
    var referenceRow := PrepareReferenceRowBeforeRealignContent({out} startY, {out} alignBottomToTop);
    var stopY := startY + _vertScrollBar.ViewportSize;

    var goMaster := TryStartMasterSynchronizer(True);
    try
      DoViewLoadingStart(startY, stopY, referenceRow);
      try
        if _view.ViewCount = 0 then
        begin
          DoViewRmoveNonUsedRows;
          UpdateAndIgnoreVertScrollbar(0);
          Exit;
        end;

        var spaceLeftToBottom: Single := StopY - referenceRow.VirtualYPosition;
        AlignRowsFromReferenceToBottom(referenceRow, {var} spaceLeftToBottom);

        var spaceToFill: Single := referenceRow.VirtualYPosition - startY + CMath.Max(spaceLeftToBottom, 0); 
        var heightChangeAboveRef: Single;
        AlignRowsAboveReference(referenceRow, {var} spaceToFill, {out} heightChangeAboveRef);

        DoViewRmoveNonUsedRows;
        UpdateVirtualYPositions(referenceRow, heightChangeAboveRef);
            
        CalculateScrollBarMax;  
        var newScrollVal := _vertScrollBar.Value + (startY - _vertScrollBar.Value {for reference row height change}) + heightChangeAboveRef;
        if alignBottomToTop and (referenceRow.VirtualYPosition + referenceRow.Height > newScrollVal + _vertScrollBar.ViewportSize) then
          newScrollVal := (referenceRow.VirtualYPosition + referenceRow.Height) - _vertScrollBar.ViewportSize;

        UpdateScrollBarValues(newScrollVal);

        UpdateYPositionRows;
      finally
        DoViewLoadingFinished;
      end;
    finally
      StopMasterSynchronizer(goMaster);
    end;

  finally
    // set model context / cell selected if the correct one was not set yet
    var rowIsChanged := (_waitForRepaintInfo <> nil) and (RowChanged in _waitForRepaintInfo.RowStateFlags);

    _waitForRepaintInfo := nil;
    _referenceRowViewListIndex := -1;

    if rowIsChanged then
      OnSelectionInfoChanged;
  end;
end;

procedure TScrollControlWithRows.RealignContentStart;
begin
  inherited;

  if IsMasterSynchronizer then
    _rowHeightSynchronizer.RealignContentStart;

  if _view = nil then
    GenerateView;
end;

function TScrollControlWithRows.RealignContentTime: Integer;
begin
  Result := inherited;

  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer;
  try
    if doIgnoreMaster then
      Result := CMath.Max(Result, _rowHeightSynchronizer.RealignContentTime);
  finally
    StopIgnoreMasterSynchronizer(doIgnoreMaster);
  end;
end;

function TScrollControlWithRows.RealignedButNotPainted: Boolean;
begin
  Result := inherited;
  if Result then Exit;
  
  var doIgnoreMaster := TryStartIgnoreMasterSynchronizer;
  try
    if doIgnoreMaster then
      Result := _rowHeightSynchronizer.RealignedButNotPainted;
  finally
    StopIgnoreMasterSynchronizer(doIgnoreMaster);
  end;
end;

procedure TScrollControlWithRows.RealignFinished;
begin
  if (_hoverRect <> nil) and _hoverRect.Visible and (GetScrollingType <> TScrollingType.None) then
    _hoverRect.Visible := False;

  if _view <> nil then
  begin
    var row: IDCRow;
    for row in _view.ActiveViewRows do
    begin
      DoRowAligned(row);
      VisualizeRowSelection(row);
    end;
  end;

  inherited;

  if IsMasterSynchronizer then
    _rowHeightSynchronizer.RealignFinished;
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

function TScrollControlWithRows.RequestedOrActualDataItem: CObject;
begin
  if (_waitForRepaintInfo <> nil) and (_waitForRepaintInfo.DataItem <> nil) then
    Result := _waitForRepaintInfo.DataItem else
    Result := _selectioninfo.DataItem;
end;

procedure TScrollControlWithRows.ResetView(const FromViewListIndex: Integer = -1; ClearOneRowOnly: Boolean = False);
begin
  if _view = nil then
  begin
    _resetViewRec := TResetViewRec.CreateNull;
     Exit;
  end;

  _view.ResetView(FromViewListIndex, ClearOneRowOnly);
  if (_rowHeightSynchronizer <> nil) {and not SyncIsMasterSynchronizer} and (_rowHeightSynchronizer.View <> nil) then
      _rowHeightSynchronizer.View.ResetView(FromViewListIndex, ClearOneRowOnly);

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

function TScrollControlWithRows.CalculateRowControlWidth(const ForceRealContentWidth: Boolean): Single;
begin
  // _content.WIdth => since we are in painting, scrollbar can be turned off/on..
  // This will not be taken into account in width when Control.IsUpdating
  Result := Self.Width - IfThen(_vertScrollBar.Visible, _vertScrollBar.Width, 0);
end;

function TScrollControlWithRows.VisibleRows: List<IDCRow>;
begin
  Result := _view.ActiveViewRows;
end;

function TScrollControlWithRows.GetScrollingType: TScrollingType;
begin
  Result := _scrollingType;
  if (Result = TScrollingType.None) and (_rowHeightSynchronizer <> nil) then
    Result := _rowHeightSynchronizer._scrollingType;
end;

procedure TScrollControlWithRows.ScrollSelectedIntoView(const RequestedSelectionInfo: IRowSelectionInfo);
begin
  if _view.GetViewListIndex(RequestedSelectionInfo.DataIndex) = -1 then
    Exit;

  if RequestedSelectionInfo.DataItem = nil then
    Exit;

  // scroll last selection change into view if not (fully) visible yet
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

  var selectionWasVisible := _view.DataIndexIsInView(_selectionInfo.DataIndex);
  var rowheight := _view.GetRowHeight(_selectionInfo.ViewListIndex);

  _view.GetSlowPerformanceRowInfo(_selectionInfo.ViewListIndex, {out} dataItem, {out} virtualYPos);

  if not selectionWasVisible and (virtualYPos <= _vertScrollBar.Value) then // row not visible and is above view
    UpdateAndIgnoreVertScrollbar(virtualYPos)
  else if not selectionWasVisible then // row not visible and is below view
    UpdateAndIgnoreVertScrollbar(virtualYPos + rowheight - _vertScrollBar.ViewportSize)
  else if (_vertScrollBar.Value > virtualYPos) then // row partly visible on top
    UpdateAndIgnoreVertScrollbar(virtualYPos)
  else if (_vertScrollBar.Value + _vertScrollBar.ViewportSize < virtualYPos + rowheight) and (rowheight < _vertScrollBar.ViewportSize) then // row partly visible at bottom
    UpdateAndIgnoreVertScrollbar(virtualYPos + rowheight - _vertScrollBar.ViewportSize)
  else // row full visible
    Exit;

  RealignFromSelectionChange;
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
      var list := _view.GetViewList;
      var viewIndex: Integer;
      for viewIndex := 0 to list.Count - 1 do
        _selectionInfo.AddToSelection(_view.GetDataIndex(viewIndex), viewIndex, list[viewIndex], False);
    end;

    // keep current selected item
    if cln.DataIndex <> -1 then
      _selectionInfo.AddToSelection(cln.DataIndex, cln.ViewListIndex, cln.DataItem, False);
  finally
    _selectionInfo.EndUpdate;
  end;
end;

function TScrollControlWithRows.SelectedItems: List<CObject>;
begin
  if _view = nil then
    Exit(nil);

  var dataIndexes := _selectionInfo.SelectedDataIndexes;
  if dataIndexes.Count = 0 then
    Exit(nil);

  dataIndexes.Sort;

  Result := CList<CObject>.Create(dataIndexes.Count);

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

function TScrollControlWithRows.SelectedItems<T>: List<T>;
begin
  if _view = nil then
    Exit(nil);

  var dataIndexes := _selectionInfo.SelectedDataIndexes;
  if dataIndexes.Count = 0 then
    Exit(nil);

  dataIndexes.Sort;

  Result := CList<T>.Create(dataIndexes.Count);

  var ix: Integer;
  for ix in dataIndexes do
  begin
    var item := _view.OriginalData[ix];

    var dr: IDataRow;
    var item_t: T;

    if item.TryAsType<T>(item_t) then
      Result.Add(item_t)
    else if ViewIsDataModelView and item.TryAsType<IDataRow>(dr) and dr.Data.TryAsType<T>(item_T) then
      Result.Add(item_t);
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
  if _manualContentHeight > 0 then
  begin
    _vertScrollBar.Min := 0;
    _vertScrollBar.ViewportSize := _manualContentHeight;
  end else
    inherited;

  UpdateRowHeightSynchronizerScrollbar;
end;

procedure TScrollControlWithRows.set_SelectionType(const Value: TSelectionType);
begin
  _selectionType := Value;
end;

procedure TScrollControlWithRows.set_TopRow(const Value: Integer);
var
  virtualY: Single;
  dataItem: CObject;
begin
  if (_View <> nil) and (_topRow <> Value) and (Value >= 0) then
  begin
    _topRow := Value;

    _View.GetSlowPerformanceRowInfo(Value, dataItem, virtualY);
    Inc(_scrollUpdateCount);
    try
      if (_vertScrollBar.Value + _vertScrollBar.ViewportSize) >= _vertScrollBar.Max then
      begin
        _vertScrollBar.ViewportSize := _vertScrollBar.Max - virtualY;
        _manualContentHeight := _vertScrollBar.ViewportSize;
      end else
        _manualContentHeight := -1;

      _vertScrollBar.Value := virtualY;
    finally
      Dec(_scrollUpdateCount);
    end;

    DoRealignContent;
  end;
end;

procedure TScrollControlWithRows.set_VisualizeParentChilds(const Value: TVisualizeParentChilds);
begin
  if _visualizeParentChilds = Value then
    Exit;

  _visualizeParentChilds := Value;

  if _view = nil then
    Exit;

  var row: IDCRow;
  for row in _view.ActiveViewRows do
    VisualizeRowSelection(row);
end;

procedure TScrollControlWithRows.set_Current(const Value: Integer);
begin
  if (_selectionInfo = nil) or (_selectionInfo.ViewListIndex <> Value) then
    GetInitializedWaitForRefreshInfo.Current := Value
  else if (_waitForRepaintInfo <> nil) and (_waitForRepaintInfo.Current <> Value) then
    _waitForRepaintInfo.Current := Value
end;

procedure TScrollControlWithRows.set_DataItem(const Value: CObject);
begin
  var dItem := _selectionInfo.DataItem;
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

    Result := DataModel.GetPropertyValue(PropertyName, DataItem.AsType<IDataRowView>.Row)
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
  var filters: List<IListFilterDescription> := CList<IListFilterDescription>.Create;

  if Filter <> nil then
    filters.Add(Filter);

  if (_view <> nil) and (_view.GetFilterDescriptions <> nil) then
  begin
    var filterDescription: IListFilterDescription;
    for filterDescription in _view.GetFilterDescriptions do
      if not ClearOtherFlters or not Interfaces.Supports<ITreeFilterDescription>(filterDescription) {external sort} then
        filters.Add(filterDescription);

    // clear here already, to free existing sorts
    if ClearOtherFlters then
      _view.GetFilterDescriptions.Clear;
  end;

  GetInitializedWaitForRefreshInfo.FilterDescriptions := filters;

  // scroll to current dataitem after scrolling
  if GetInitializedWaitForRefreshInfo.DataItem = nil then
    GetInitializedWaitForRefreshInfo.DataItem := get_DataItem;

  if (_multiSelectSorter <> nil) and not ViewIsDataModelView then
  begin
    var ix := -1;
    if (_view <> nil) and (_view.GetSortDescriptions <> nil) then
      ix := _view.GetSortDescriptions.IndexOf(_multiSelectSorter);

    if ix <> 0 then
    begin
      if ix > 0 then
        _view.GetSortDescriptions.RemoveAt(ix);

      AddSortDescription(_multiSelectSorter, False);
    end;
  end;
end;

procedure TScrollControlWithRows.AddSortDescription(const Sort: IListSortDescription; const ClearOtherSort: Boolean);
begin
  var sorts: List<IListSortDescription> := CList<IListSortDescription>.Create;
  if Sort <> nil then
    sorts.Add(Sort);

  if (_view <> nil) and (_view.GetSortDescriptions <> nil) then
  begin
    var sortDescription: IListSortDescription;
    for sortDescription in _view.GetSortDescriptions do
      if not ClearOtherSort or not Interfaces.Supports<ITreeSortDescription>(sortDescription) {external sort} then
        sorts.Add(sortDescription);

    // clear here already, to free existing sorts
    if ClearOtherSort then
      _view.GetSortDescriptions.Clear;
  end;

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

  if IsMasterSynchronizer then
    _rowHeightSynchronizer.AfterRealignContent;
end;

// endof sorting and filtering

{ TDCRow }

procedure TDCRow.UpdateControlVisibility;
begin
  if (_control <> nil) and not (csDestroying in _control.ComponentState) then
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
  end;

  if _selectionRect.Parent <> _control then
  begin
    _selectionRect.Parent := nil;
    _control.AddObject(_selectionRect);
  end;

  _selectionRect.BringToFront;

  if OwnerIsFocused then
    _selectionRect.Fill.Color := DEFAULT_ROW_SELECTION_ACTIVE_COLOR else
    _selectionRect.Fill.Color := DEFAULT_ROW_SELECTION_INACTIVE_COLOR;
end;

procedure TDCRow.UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean);
begin
  var isSelected := SelectionInfo.IsSelected(get_DataIndex);
  var selectionStaysTheSame := isSelected = (_selectionRect <> nil);

  if isSelected then
    UpdateSelectionRect(OwnerIsFocused)
  else if _selectionRect <> nil then
    FreeAndNil(_selectionRect);

  if get_UseBuffering and not selectionStaysTheSame then
    ControlAsRowLayout.ResetBuffer;
end;

procedure TDCRow.ClearRowForReassignment;
begin
  _dataItem := nil;
  _viewPortIndex := -1;
  _virtualYPosition := -1;
  _enabled := True;

  if _control <> nil then
  begin
    var rowLayout := ControlAsRowLayout;
    rowLayout.ResetBuffer;
    rowLayout.HandleParentChildVisualisation(False, False, 0);
  end;

  UpdateControlVisibility;
end;

function TDCRow.ControlAsRowLayout: IRowLayout;
begin
  Result := _control as IRowLayout;
end;

constructor TDCRow.Create(const RowsControl: IRowsControl);
begin
  inherited Create;
  _rowsControl := RowsControl;
  _virtualYPosition := -1;
  _enabled := True;
end;

destructor TDCRow.Destroy;
begin
  ClearRowForReassignment;

  if (_control <> nil) and not (csDestroying in _control.ComponentState) then
  begin
    FreeAndNil(_selectionRect);
    FreeAndNil(_control);
  end;

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

function TDCRow.get_RowsControl: IRowsControl;
begin
  Result := _rowsControl;
end;

function TDCRow.get_UseBuffering: Boolean;
begin
  var ctrl := ControlAsRowLayout;
  Result := (ctrl <> nil) and ctrl.UseBuffering;
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

function TDCRow.IsChildOf(const DataItem: CObject): Boolean;
begin
  var drv: IDataRowView;
  if not _dataItem.TryAsType<IDataRowView>(drv) then
    Exit(False);

  Result := CObject.Equals(drv.DataView.Parent(drv).Row.Data, DataItem);
end;

function TDCRow.IsClearedForReassignment: Boolean;
begin
  Result := (_dataItem = nil) and (_control <> nil);
end;

function TDCRow.IsOddRow: Boolean;
begin
  Result := Odd(_viewListIndex);
end;

function TDCRow.IsParentOf(const DataItem: CObject): Boolean;
begin
  var drv: IDataRowView;
  if not _dataItem.TryAsType<IDataRowView>(drv) then
    Exit(False);

  if not drv.DataView.HasChildren(drv) then
    Exit(False);

  var childs := drv.DataView.Children(drv, TChildren.IncludeParentRows);
  for var child in childs do
    if CObject.Equals(child, DataItem) then
      Exit(True);

  Result := False;
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

procedure TDCRow.set_UseBuffering(const Value: Boolean);
begin
  var ctrl := ControlAsRowLayout;
  if ctrl <> nil then
    ctrl.UseBuffering := Value;
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
  Result := _multiSelection.Count > 1;
end;

function TRowSelectionInfo.get_NotSelectableDataIndexes: TDataIndexArray;
begin
  Result := _notSelectableDataIndexes;
end;

function TRowSelectionInfo.HasSelection: Boolean;
begin
  Result := (_lastSelectedDataItem <> nil) or get_IsMultiSelection;
end;

function TRowSelectionInfo.IsChecked(const DataIndex: Integer): Boolean;
begin
  Result := _multiSelection.ContainsKey(DataIndex);
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
  (Result as IRowSelectionInfo).UpdateSingleSelection(_lastSelectedDataIndex, _lastSelectedViewListIndex, _lastSelectedDataItem, False);

  Result.LastSelectionEventTrigger := _EventTrigger;
  Result.NotSelectableDataIndexes := _notSelectableDataIndexes;
end;

function TRowSelectionInfo.CreateInstance: IRowSelectionInfo;
begin
  Result := TRowSelectionInfo.Create(nil {clones don't get the treecontrol, for they dopn't need to make changes});
end;

procedure TRowSelectionInfo.Deselect(const DataIndex: Integer);
begin
  // UpdateLastSelection triggers DoSelectionInfoChanged
  // therefore works with Update locks
  BeginUpdate;
  try
    var lastSelectedIsDeselect := _lastSelectedDataIndex = DataIndex;

    if lastSelectedIsDeselect then
    begin
      var item: IRowSelectionInfo;
      for item in _multiSelection.Values do
        if item.DataIndex <> DataIndex then
        begin
          UpdateLastSelection(item.DataIndex, item.ViewListIndex, item.DataItem);
          lastSelectedIsDeselect := False;
          Break
        end;
    end;

    if _multiSelection.Remove(DataIndex) then
      _selectionChanged := True;

    if lastSelectedIsDeselect then
      UpdateLastSelection(-1, -1, nil);
  finally
    EndUpdate; //(True {do not scroll lastselected into view, because it can be out of view, causing scroll action});
  end;
end;

function TRowSelectionInfo.Select(const DataIndex, ViewListIndex: Integer; const DataItem: CObject) : Boolean;
begin
  BeginUpdate;
  try
    if not _multiSelection.ContainsKey(DataIndex) then
    begin
      Result := True;
      var info: IRowSelectionInfo := CreateInstance as IRowSelectionInfo;
      info.UpdateSingleSelection(DataIndex, ViewListIndex, DataItem, False);
      _multiSelection[DataIndex] := info;
    end else
      Result := False;
  finally
    EndUpdate; //(True {do not scroll lastselected into view, because it can be out of view, causing scroll action});
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

procedure TRowSelectionInfo.UpdateSingleSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; KeepCurrentSelection: Boolean);
begin
  if not CanSelect(DataIndex) then
    Exit;

  if not KeepCurrentSelection then
    ClearMultiSelections;

  UpdateLastSelection(DataIndex, ViewListIndex, DataItem);
end;

procedure TRowSelectionInfo.AddToSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject; ExpandCurrentSelection: Boolean);
begin
  if not CanSelect(DataIndex) then
    Exit;

  BeginUpdate;
  try
    if not ExpandCurrentSelection then
      ClearMultiSelections;

    UpdateLastSelection(DataIndex, ViewListIndex, DataItem);

    var info: IRowSelectionInfo := CreateInstance as IRowSelectionInfo;
    info.UpdateSingleSelection(DataIndex, ViewListIndex, DataItem, False);
    _multiSelection[info.DataIndex] := info;
  finally
    EndUpdate;
  end;
end;

function TRowSelectionInfo.SelectedDataItems: List<CObject>;
begin
  Result := CList<CObject>.Create;

  if _multiSelection.Count > 0 then
  begin
    var item: IRowSelectionInfo;
    for item in _multiSelection.Values do
      Result.Add(item.DataItem)
  end
  else if _lastSelectedDataItem <> nil then
    Result.Add(_lastSelectedDataItem);
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
  if not CanSelect(DataIndex) then
  begin
    UpdateLastSelection(-1, -1, nil);
    Exit;
  end;

  _lastSelectedDataIndex := DataIndex;
  _lastSelectedViewListIndex := ViewListIndex;
  _lastSelectedDataItem := DataItem;

  DoSelectionInfoChanged;
end;

{ TWaitForRepaintInfo }
procedure TWaitForRepaintInfo.ClearSelectionInfo;
begin
  _dataItem := nil;
  _current := -1;
  _rowStateFlags := _rowStateFlags - [RowChanged];
end;

//procedure TWaitForRepaintInfo.ClearIrrelevantInfo;
//begin
//  _rowStateFlags := _rowStateFlags - [SortChanged, FilterChanged];
//
//  // ONLY KEEP CURRENT
//  // we use current to reselect a item at that position after for example a refresh of the treecontrol
//
//  _dataItem := nil;
//  _sortDescriptions := nil;
//  _filterDescriptions := nil;
//end;

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
  if Value <> -1 then
    _dataItem := nil;

  _current := Value;
  _rowStateFlags := _rowStateFlags + [TTreeRowState.RowChanged];
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

procedure TWaitForRepaintInfo.set_DataItem(const Value: CObject);
begin
  if Value <> nil then
    _current := -1;

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

function TScrollControlWithRows.ListHoldsOrdinalType: Boolean;
begin
  var tc := &Type.GetTypeCode(GetItemType);
  Result := not ((tc = TypeCode.Object) or GetItemType.IsInterfaceType or GetItemType.IsArray);
end;

end.
