unit FMX.ScrollControl.WithCells.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.JSON,
  FMX.Controls,
  FMX.StdCtrls,
  System.Classes,
  System.SysUtils,
  FMX.Layouts, 
  System.UITypes, 
  System.Types, 
  FMX.ImgList,
  FMX.Objects,
  FMX.Forms,
  System.Generics.Defaults,
  FMX.Types,
  FMX.ActnList,
  FMX.Text,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.FMX.StdCtrls,
  Wasm.System.Classes, 
  Wasm.System.SysUtils,
  Wasm.FMX.Layouts, 
  Wasm.System.UITypes, 
  Wasm.System.Types, 
  Wasm.FMX.ImgList, 
  Wasm.FMX.Objects,
  Wasm.FMX.Forms,
  Wasm.FMX.Types,
  Wasm.FMX.ActnList, 
  Wasm.FMX.Text,
  {$ENDIF}
  System_,
  System.ComponentModel,
  System.Collections.Generic,
  System.Collections,

  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.WithRows.Impl,

  ADato.ComponentModel,
  ADato.Collections.Specialized, 
  System.Collections.Specialized,
  FMX.ScrollControl.WithRows.Intf,
  FMX.ScrollControl.Events, ADato.Data.DataModel.intf,
  FMX.ScrollControl.ControlClasses.Intf;

type
  TRightLeftScroll = (None, FullLeft, Left, Right, FullRight);

  TScrollControlWithCells = class(TScrollControlWithRows, IRowAndCellCompare, IColumnsControl)
  private
    _headerRow: IDCHeaderRow;
    _treeLayout: IDCTreeLayout;

    _frozenRectLine: TRectangle;

    _defaultColumnsGenerated: Boolean;
    _isSortingOrFiltering: Integer;

    _headerColumnResizeControl: IHeaderColumnResizeControl;
    _frmHeaderPopupMenu: TForm;

    function  get_Layout: IDCTreeLayout;
    function  get_SelectedColumn: IDCTreeLayoutColumn;

    procedure ColumnsChanged(Sender: TObject; e: NotifyCollectionChangedEventArgs);
    procedure OnHeaderCellResizeClicked(const HeaderCell: IHeaderCell);

    procedure InitHeader;
    procedure InitLayout;

    function  HeaderAndTreeRows(OnlyNewRows: Boolean): List<IDCTreeRow>;

    function  GetHorzScroll(const Key: Word; Shift: TShiftState): TRightLeftScroll;
    procedure OnExpandCollapseHierarchy(Sender: TObject);
    procedure ProcessColumnVisibilityRules;

    procedure CreateDefaultColumns;
    procedure ShowHeaderPopupMenu(const LayoutColumn: IDCTreeLayoutColumn);
    procedure HeaderPopupMenu_Closed(Sender: TObject; var Action: TCloseAction);
    function  GetColumnValues(const LayoutColumn: IDCTreeLayoutColumn; Add_NO_VALUE: Boolean): Dictionary<CObject, CString>;

    procedure GetSortAndFilterImages(out ImageList: TCustomImageList; out FilterIndex, SortAscIndex, SortDescIndex: Integer);

  protected
    procedure DoHorzScrollBarChanged; override;
    procedure GenerateView; override;
    procedure RealignFinished; override;
    procedure DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean); override;

  // properties
  protected
    _columns: IDCTreeColumnList;
    _autoFitColumns: Boolean;
    _autoCenterTree: Boolean;
    _autoExtraColumnSizeMax: Single;
    _reloadForSpecificColumn: IDCTreeLayoutColumn;
    _headerHeight: Single;
    _headerTextTopMargin: Single;
    _headerTextBottomMargin: Single;
    _scrollingHideColumnsFromIndex: Integer;
    _cellTopBottomPadding: Single;
    _cellLeftRightPadding: Single;

    procedure set_AutoFitColumns(const Value: Boolean);
    function  get_headerHeight: Single;
    procedure set_HeaderHeight(const Value: Single);
    function  get_headerTextTopMargin: Single;
    procedure set_headerTextTopMargin(const Value: Single);
    function  get_headerTextBottomMargin: Single;
    procedure set_headerTextBottomMargin(const Value: Single);
    function  get_CellTopBottomPadding: Single;
    procedure set_CellTopBottomPadding(const Value: Single);
    function  get_CellLeftRightPadding: Single;
    procedure set_CellLeftRightPadding(const Value: Single);

    function  IsScrollingHideColumnsFromIndexStored: Boolean;

  // events
  protected
    _cellLoading: CellLoadingEvent;
    _cellLoaded: CellLoadedEvent;
    _cellFormatting: CellFormattingEvent;
    _cellCanChange: CellCanChangeEvent;
    _cellChanging: CellChangingEvent;
    _cellChanged: CellChangedEvent;
    _cellSelected: CellSelectedEvent;
//    _cellUserActionEvent: CellUserActionEvent;

    _sortingGetComparer: GetColumnComparerEvent;
    _onCompareRows: TOnCompareRows;
    _onCompareColumnCells: TOnCompareColumnCells;

    _onColumnsChanged: ColumnChangedByUserEvent;
    _onTreePositioned: TreePositionedEvent;

    _popupMenuClosed: TNotifyEvent;

    procedure DoCellLoaded(const Cell: IDCTreeCell; RequestForSort: Boolean; var PerformanceModeWhileScrolling: Boolean; var OverrideRowHeight: Single); virtual;
    function  DoCellLoading(const Cell: IDCTreeCell; RequestForSort: Boolean; var PerformanceModeWhileScrolling: Boolean; var OverrideRowHeight: Single): Boolean; virtual;
    function  DoCellFormatting(const Cell: IDCTreeCell; RequestForSort: Boolean; var Value: CObject) : Boolean; virtual;
    function  DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean; virtual;
    procedure DoCellChanging(const OldCell, NewCell: IDCTreeCell);
    procedure DoCellChanged(const OldCell, NewCell: IDCTreeCell);
    procedure DoCellSelected(const Cell: IDCTreeCell; EventTrigger: TSelectionEventTrigger);

    function  DoSortingGetComparer(const SortDescription: IListSortDescriptionWithComparer {; const ReturnSortComparer: Boolean}): IComparer<CObject>;
    function  DoOnCompareRows(const Left, Right: CObject): Integer;
    function  DoOnCompareColumnCells(const Column: IDCTreeColumn; const Left, Right: CObject): Integer;

    procedure DoColumnsChanged(const Column: IDCTreeColumn);
    procedure DoTreePositioned(const TotalColumnWidth: Single);

  private
    _selectionCheckBoxUpdateCount: Integer;
//    procedure OnSelectionCheckBoxChange(Sender: TObject);
    procedure UpdateSelectionCheckboxes(const Row: IDCRow);
    function  SelectionCheckBoxColumn: IDCTreeLayoutColumn;

    procedure SetColumnSelectionIfNoneExists;
    procedure set_AutoCenterTree(const Value: Boolean);
    function  get_AutoExtraColumnSizeMax: Single;
    procedure set_AutoExtraColumnSizeMax(const Value: Single);

  protected
    _totalColumnWidth: Single;
    _fullHeaderClick: Boolean;
    _autoMultiSelectColumn: IDCTreeCheckboxColumn;
    _autoMultiSelectColumnIndex: Integer;
    _localCheckSetInDefaultData: Boolean;

    procedure FastColumnAlignAfterColumnChange;

    procedure ClearTreeSorts;
    procedure ClearTreeFilters;
    procedure UpdateHeaderRowControls;

    function  DoCreateNewRow: IDCRow; override;
    function  DoCreateNewCell(const ARow: IDCRow; const LayoutColumn: IDCTreeLayoutColumn): IDCTreeCell; virtual;

    procedure BeforeRealignContent; override;
    procedure AfterRealignContent; override;
    procedure AfterScrolling; override;

    procedure PrepareColumns;
    procedure PrepareCellControls(const Cell: IDCTreeCell);
    procedure TryLoadDataIntoCellControls(const Cell: IDCTreeCell; LoadDefaultData, PerformanceModeWhileScrolling: Boolean);
    procedure InnerInitRow(const Row: IDCRow; RowHeightNeedsRecalc: Boolean = False); override;
    procedure PerformanceRoutineLoadedRow(const Row: IDCRow); override;
    procedure DoRowLoaded(const ARow: IDCRow); override;

    function  CreateSelectioninfoInstance: IRowSelectionInfo; override;
    procedure OnSelectionInfoChanged; override;
    procedure VisualizeRowSelection(const Row: IDCRow); override;
    procedure HandleRowChildRelation(const Row: IDCRow; IsOpenParent, IsOpenChild: Boolean); override;
    procedure CheckCorrectColumnSelection( const SelectionInfo: ITreeSelectionInfo; const Row: IDCTreeRow);

    function  AutoMultiSelectColumnShowing: Boolean;
    procedure CheckShowAutoMultiSelectColumn;
    procedure CheckHideAutoMultiSelectColumn(const OldRow: IDCRow; const Shift: TShiftState);

    function  GetInitializedWaitForRefreshInfo: IWaitForRepaintInfo; override;

    procedure InternalDoSelectColumn(const LayoutColumnIndex: Integer; Shift: TShiftState);
    function  TrySelectItem(const RequestedSelectionInfo: IRowSelectionInfo; Shift: TShiftState): Boolean; override;

    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single); override;
    procedure OnHeaderClick(Sender: TObject);
    procedure OnHeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single); virtual;
    procedure DataModelViewRowPropertiesChanged(Sender: TObject; Args: RowPropertiesChangedEventArgs); override;

    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure UpdateHorzScrollbar;

    function  GetCellControlData(const Cell: IDCTreeCell): CObject;

    procedure UpdateHoverRect(MousePos: TPointF); override;

    function  FlatColumnByColumn(const Column: IDCTreeColumn): IDCTreeLayoutColumn;
    function  FlatColumnIndexByLayoutIndex(const LayoutIndex: Integer): Integer;

    procedure TryScrollToCellByKey(var Key: Word; var KeyChar: WideChar);

    function  TextForSizeCalc(const Text: string): string;

    function  CalculateRowControlWidth(const ForceRealContentWidth: Boolean): Single; override;
    function  CalculateRowHeight(const Row: IDCTreeRow): Single;
    function  CalculateCellWidth(const LayoutColumn: IDCTreeLayoutColumn; const Cell: IDCTreeCell): Single;
    function  CalculateCellControlHeight(const Cell: IDCTreeCell; GoSub: Boolean): Single;

    procedure AssignWidthsToAlignColumns;

    procedure UpdatePositionAndWidthCells;
    procedure LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const IsSubProp: Boolean); virtual;
    function  ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject; virtual;

    procedure UpdateScrollAndSelectionByKey(var Key: Word; Shift: TShiftState); override;
    procedure SetBasicHorzScrollBarValues; override;

    function  GetSelectableFlatColumnByMouseX(const X: Single): IDCTreeLayoutColumn;
    function  GetFlatColumnByMouseX(const X: Single): IDCTreeLayoutColumn;
    function  GetFlatColumnByKey(const Key: Word; Shift: TShiftState; FromColumnIndex: Integer): IDCTreeLayoutColumn;

    procedure HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions); override;
    procedure HandleMultiSelectOptionChanged;

    function  ProvideRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow; override;

    function  GetCellByControl(const Control: TControl): IDCTreeCell;

    procedure ClearCalculatedColumnWidths;

    procedure DoContentResized(WidthChanged, HeightChanged: Boolean); override;

    // IColumnsControl
    procedure ColumnVisibilityChanged(const Column: IDCTreeColumn; IsUserChange: Boolean);
    procedure ColumnWidthChanged(const Column: IDCTreeColumn);
    function  Control: TControl;
    function  Content: TControl;
    function  FullColumnList: IList<IDCTreeColumn>;

  protected
    procedure PositionTree;
    function  TreeInnerXPosition: Single;

    {$IFDEF WEBASSEMBLY}
    function  GetItemType: &Type; 
    {$ENDIF}

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  OnGetCellDataForSorting(const Cell: IDCTreeCell): CObject;
    function  IsSortingOrFiltering: Boolean;
    function  IsSpecifiedColumnReload: Boolean;
    function  GetActiveCell: IDCTreeCell;

    procedure RefreshColumn(const Column: IDCTreeColumn);
    procedure ColumnsChangedFromExternal;

    procedure UpdateColumnSort(const Column: IDCTreeColumn; SortDirection: ListSortDirection; ClearOtherSort: Boolean);
    procedure UpdateColumnFilter(const Column: IDCTreeColumn; const FilterText: CString; const FilterValues: List<CObject>);

    procedure UpdateSelectedColumn(const Column: Integer);

    procedure SelectAll; override;
    function  RadioInsteadOfCheck: Boolean;

    property  Layout: IDCTreeLayout read get_Layout;
    property  HeaderRow: IDCHeaderRow read _headerRow;
    property  SelectedColumn: IDCTreeLayoutColumn read get_SelectedColumn;
    property  AutoMultiSelectColumnIndex: Integer write _autoMultiSelectColumnIndex;

  public
    // designer properties
    property Columns: IDCTreeColumnList read _columns write _columns;  // stored DoStoreColumns;
    property AutoFitColumns: Boolean read _autoFitColumns write set_AutoFitColumns default False;
    property AutoCenterTree: Boolean read _autoCenterTree write set_AutoCenterTree default False;
    property HeaderHeight: Single read get_headerHeight write set_HeaderHeight;
    property HeaderTextTopMargin: Single read get_headerTextTopMargin write set_headerTextTopMargin;
    property HeaderTextBottomMargin: Single read get_headerTextBottomMargin write set_headerTextBottomMargin;
    property AutoExtraColumnSizeMax: Single read get_AutoExtraColumnSizeMax write set_AutoExtraColumnSizeMax;
    property ScrollingHideColumnsFromIndex: integer read _scrollingHideColumnsFromIndex write _scrollingHideColumnsFromIndex {$IFNDEF WEBASSEMBLY}stored IsScrollingHideColumnsFromIndexStored{$ENDIF};
    property CellTopBottomPadding: Single read get_CellTopBottomPadding write set_CellTopBottomPadding;
    property CellLeftRightPadding: Single read get_CellLeftRightPadding write set_CellLeftRightPadding;
    property PopupMenuClosed: TNotifyEvent read _popupMenuClosed write _popupMenuClosed;

    // designer events
    property CellLoading: CellLoadingEvent read _cellLoading write _cellLoading;
    property CellLoaded: CellLoadedEvent read _cellLoaded write _cellLoaded;
    property CellFormatting: CellFormattingEvent read _cellFormatting write _cellFormatting;
    property CellCanChange: CellCanChangeEvent read _cellCanChange write _cellCanChange;
    property CellChanging: CellChangingEvent read _cellChanging write _cellChanging;
    property CellChanged: CellChangedEvent read _cellChanged write _cellChanged;
    property CellSelected: CellSelectedEvent read _cellSelected write _cellSelected;
    property SortingGetComparer: GetColumnComparerEvent read _sortingGetComparer write _sortingGetComparer;
    property OnCompareRows: TOnCompareRows read _onCompareRows write _onCompareRows;
    property OnCompareColumnCells: TOnCompareColumnCells read _onCompareColumnCells write _onCompareColumnCells;
    property OnColumnsChanged: ColumnChangedByUserEvent read _onColumnsChanged write _onColumnsChanged;
    property OnTreePositioned: TreePositionedEvent read _onTreePositioned write _onTreePositioned;
  end;

  TDCColumnSortAndFilter = class(TObservableObject, IDCColumnSortAndFilter)
  private
    _showSortMenu: Boolean;
    _showFilterMenu: Boolean;
    _sortType: TSortType;

    function  get_ShowFilterMenu: Boolean;
    procedure set_ShowFilterMenu(const Value: Boolean);
    function  get_ShowSortMenu: Boolean;
    procedure set_ShowSortMenu(const Value: Boolean);
    function  get_SortType: TSortType;
    procedure set_SortType(const Value: TSortType);

    function Clone: IDCColumnSortAndFilter; virtual;

  public
    procedure Assign(const Source: IBaseInterface); reintroduce; overload; virtual;

  published
    property Sort: TSortType read get_SortType write set_SortType;
    property ShowSortMenu: Boolean read get_ShowSortMenu write set_ShowSortMenu;
    property ShowFilterMenu: Boolean read get_ShowFilterMenu write set_ShowFilterMenu;
  end;

  TDCColumnWidthSettings = class(TObservableObject, IDCColumnWidthSettings)
  private
    _width: Single;
    _widthMin: Single;
    _widthMax: Single;
    _widthType: TDCColumnWidthType;

    function  get_Width: Single;
    procedure set_Width(const Value: Single);
    function  get_WidthMin: Single;
    procedure set_WidthMin(const Value: Single);
    function  get_WidthMax: Single;
    procedure set_WidthMax(const Value: Single);
    function  get_WidthType: TDCColumnWidthType;
    procedure set_WidthType(const Value: TDCColumnWidthType);

    function Clone: IDCColumnWidthSettings; virtual;

  public
    constructor Create; reintroduce;

    procedure Assign(const Source: IBaseInterface); reintroduce; overload; virtual;

  published
    property WidthType: TDCColumnWidthType read get_WidthType write set_WidthType;
    property Width: Single read get_Width write set_Width;
    property WidthMin: Single read get_WidthMin write set_WidthMin;
    property WidthMax: Single read get_WidthMax write set_WidthMax;

  end;

  TDCColumnSubControlSettings = class(TObservableObject, IDCColumnSubControlSettings)
  private
    _subPropertyName: CString;
    _subInfoControlClass: TInfoControlClass;

    function  get_SubPropertyName: CString;
    procedure set_SubPropertyName(const Value: CString);
    function  get_SubInfoControlClass: TInfoControlClass;
    procedure set_SubInfoControlClass(const Value: TInfoControlClass);


    function Clone: IDCColumnSubControlSettings; virtual;

  public
    procedure Assign(const Source: IBaseInterface); reintroduce; overload; virtual;

  published
    property SubPropertyName: CString read get_SubPropertyName write set_SubPropertyName;
    property SubInfoControlClass: TInfoControlClass read get_SubInfoControlClass write set_SubInfoControlClass default Custom;

  end;

  TDCColumnHierarchy = class(TObservableObject, IDCColumnHierarchy)
  private
    _showHierarchy: Boolean;
    _indent: Single;

    function  get_ShowHierarchy: Boolean;
    procedure set_ShowHierarchy(const Value: Boolean);
    function  get_Indent: Single;
    procedure set_Indent(const Value: Single);

    function Clone: IDCColumnHierarchy; virtual;

  public
    procedure Assign(const Source: IBaseInterface); reintroduce; overload; virtual;

  published
    property ShowHierarchy: Boolean read get_ShowHierarchy write set_ShowHierarchy;
    property Indent: Single read get_Indent write set_Indent;
  end;

  TDCColumnVisualisation = class(TObservableObject, IDCColumnVisualisation)
  private
    _visible: Boolean;
    _frozen: Boolean;
    _readOnly: Boolean;
    _selectable: Boolean;
    _allowResize: Boolean;
    _allowHide: Boolean;
    _hideWhenEmpty: Boolean;
    _hideGrid: Boolean;
    _ignoreHeightByRowCalculation: Boolean;
    _format: CString;

    _horzAlign: TDCTextAlign;
    _vertAlign: TDCTextAlign;

    function  get_Visible: Boolean;
    procedure set_Visible(const Value: Boolean);
    function  get_Frozen: Boolean;
    procedure set_Frozen(const Value: Boolean);
    function  get_ReadOnly: Boolean;
    procedure set_ReadOnly(const Value: Boolean);
    procedure set_Selectable(Value : Boolean);
    function  get_Selectable: Boolean;
    function  get_AllowResize: Boolean;
    procedure set_AllowResize(const Value: Boolean);
    function  get_AllowHide: Boolean;
    procedure set_AllowHide(const Value: Boolean);
    function  get_HideWhenEmpty: Boolean;
    procedure set_HideWhenEmpty(const Value: Boolean);
    function  get_HideGrid: Boolean;
    procedure set_HideGrid(const Value: Boolean);
    function  get_IgnoreHeightByRowCalculation: Boolean;
    procedure set_IgnoreHeightByRowCalculation(const Value: Boolean);
    function  get_Format: CString;
    procedure set_Format(const Value: CString);
    function  get_HorzAlign: TDCTextAlign;
    procedure set_HorzAlign(const Value: TDCTextAlign);
    function  get_VertAlign: TDCTextAlign;
    procedure set_VertAlign(const Value: TDCTextAlign);

    function Clone: IDCColumnVisualisation; virtual;

  public
    constructor Create; reintroduce;
    procedure Assign(const Source: IBaseInterface); reintroduce; overload; virtual;

  published
    property Visible: Boolean read get_Visible write set_Visible;
    property Frozen: Boolean read get_Frozen write set_Frozen;
    property ReadOnly: Boolean read get_ReadOnly write set_ReadOnly;
    property Selectable: Boolean read get_Selectable write set_Selectable;
    property AllowResize: Boolean read get_AllowResize write set_AllowResize;
    property AllowHide: Boolean read get_AllowHide write set_AllowHide;
    property HideWhenEmpty: Boolean read get_HideWhenEmpty write set_HideWhenEmpty;
    property HideGrid: Boolean read get_HideGrid write set_HideGrid;
    property IgnoreHeightByRowCalculation: Boolean read get_IgnoreHeightByRowCalculation write set_IgnoreHeightByRowCalculation;
    property Format: CString read get_Format write set_Format;
    property HorzAlign: TDCTextAlign read get_HorzAlign write set_HorzAlign;
    property VertAlign: TDCTextAlign read get_VertAlign write set_VertAlign;

  end;

  TDCTreeColumn = class(TObservableObject, IDCTreeColumn)
  private
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _treeControl: IColumnsControl;

    _caption: CString;
    _propertyName: CString;
    _tag: CObject;

    _infoControlClass: TInfoControlClass;
    _formatProvider : IFormatProvider;

    _cachedType: &Type;
    _cachedProp: _PropertyInfo;
    _subPropertyName: CString;
    _cachedSubProp: _PropertyInfo;

    _widthSettings: IDCColumnWidthSettings;
    _sortAndFilter: IDCColumnSortAndFilter;
    _subControlSettings: IDCColumnSubControlSettings;
    _visualisation: IDCColumnVisualisation;
    _hierarchy: IDCColumnHierarchy;

    _customHidden: Boolean;
    _customWidth: Single;
    _userDefinedWidth: Single;
    _isCustomColumn: Boolean;

    function  get_TreeControl: IColumnsControl;
    procedure set_TreeControl(const Value: IColumnsControl);
    function  get_CustomWidth: Single;
    procedure set_CustomWidth(const Value: Single);
    function  get_CustomHidden: Boolean;
    procedure set_CustomHidden(const Value: Boolean);
    function  get_IsCustomColumn: Boolean;
    procedure set_IsCustomColumn(const Value: Boolean);

//    function  get_Index: Integer;
//    procedure set_Index(Value: Integer);
    function  get_Caption: CString;
    procedure set_Caption(const Value: CString);
    function  get_PropertyName: CString;
    procedure set_PropertyName(const Value: CString);
    function  get_Tag: CObject;
    procedure set_Tag(const Value: CObject);

    function  get_Visible: Boolean;
    function  get_Frozen: Boolean;
    function  get_ReadOnly: Boolean;
    function  get_AllowResize: Boolean;
    function  get_AllowHide: Boolean;
    function  get_ShowSortMenu: Boolean;
    function  get_ShowFilterMenu: Boolean;
    function  get_SortType: TSortType;
    function  get_Selectable: Boolean; virtual;
    function  get_ShowHierarchy: Boolean;
    function  get_Indent: Single;
    function  get_InfoControlClass: TInfoControlClass;
    procedure set_InfoControlClass(const Value: TInfoControlClass);
    function  get_SubPropertyName: CString;
    function  get_SubInfoControlClass: TInfoControlClass;

    function  get_Width: Single;
    function  get_WidthMin: Single;
    function  get_WidthMax: Single;
    function  get_WidthType: TDCColumnWidthType;

    function  get_Format: CString;
    function  get_FormatProvider: IFormatProvider;
    procedure set_FormatProvider(const Value: IFormatProvider);
    function  get_UserDefinedWidth: Single;
    procedure set_UserDefinedWidth(const Value: Single);

    function  get_SortAndFilter: IDCColumnSortAndFilter;
    procedure set_SortAndFilter(const Value: IDCColumnSortAndFilter);
    function  get_WidthSettings: IDCColumnWidthSettings;
    procedure set_WidthSettings(const Value: IDCColumnWidthSettings);
    function  get_SubControlSettings: IDCColumnSubControlSettings;
    procedure set_SubControlSettings(const Value: IDCColumnSubControlSettings);
    function  get_Visualisation: IDCColumnVisualisation;
    procedure set_Visualisation(const Value: IDCColumnVisualisation);
    function  get_Hierarchy: IDCColumnHierarchy;
    procedure set_Hierarchy(const Value: IDCColumnHierarchy);

    function  CreateInstance: IDCTreeColumn; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    function  Clone: IDCTreeColumn;
    function  IsSelectionColumn: Boolean; virtual;
    function  HasPropertyAttached: Boolean;

    function  ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; IsSubProp: Boolean = False): CObject;
    function  GetFormattedValue(const Cell: IDCTreeCell; const CellValue: CObject): CString; virtual;

    // width settings
    property WidthType: TDCColumnWidthType read get_WidthType;
    property Width: Single read get_Width;
    property WidthMin: Single read get_WidthMin;
    property WidthMax: Single read get_WidthMax;

    // user actions
    property AllowResize: Boolean read get_AllowResize;
    property AllowHide: Boolean read get_AllowHide;
    property ShowSortMenu: Boolean read get_ShowSortMenu;
    property ShowFilterMenu: Boolean read get_ShowFilterMenu;
    property TSortType: TSortType read get_SortType;

    property SubPropertyName: CString read get_SubPropertyName;
    property SubInfoControlClass: TInfoControlClass read get_SubInfoControlClass;

    property Visible: Boolean read get_Visible;
    property Frozen: Boolean read get_Frozen;
    property ReadOnly: Boolean read get_ReadOnly;
    property Selectable: Boolean read get_Selectable;
    property ShowHierarchy: Boolean read get_ShowHierarchy;
    property Indent: Single read get_Indent;
    property Format: CString read get_Format;

  published
//    property Index: Integer read get_Index write set_Index;
    property Caption: CString read get_Caption write set_Caption;
    property Tag: CObject read get_Tag write set_Tag;
    property PropertyName: CString read get_PropertyName write set_PropertyName;
    property InfoControlClass: TInfoControlClass read get_InfoControlClass write set_InfoControlClass;

    property WidthSettings: IDCColumnWidthSettings read get_WidthSettings write set_WidthSettings;
    property Visualisation: IDCColumnVisualisation read get_Visualisation write set_Visualisation;
    property SortAndFilter: IDCColumnSortAndFilter read get_SortAndFilter write set_SortAndFilter;
    property SubControlSettings: IDCColumnSubControlSettings read get_SubControlSettings write set_SubControlSettings;
    property Hierarchy: IDCColumnHierarchy read get_Hierarchy write set_Hierarchy;
  end;

  TDCTreeCheckboxColumn = class(TDCTreeColumn, IDCTreeCheckboxColumn)
  protected
    function  get_Selectable: Boolean; override;
    function  CreateInstance: IDCTreeColumn; override;
  public
    constructor Create; override;

    function  IsSelectionColumn: Boolean; override;
    // function  GetFormattedValue(const Cell: IDCTreeCell; const CellValue: CObject): CObject; override;
  end;

  TDCTreeColumnList = class(CObservableCollectionEx<IDCTreeColumn>, IDCTreeColumnList)
  protected
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _treeControl: IColumnsControl;

    function  get_TreeControl: IColumnsControl;
//    procedure OnCollectionChanged(e: NotifyCollectionChangedEventArgs); override;
    function  FindIndexByCaption(const Caption: CString) : Integer;
    function  FindIndexByTag(const Tag: CObject) : Integer;
    function  FindColumnByCaption(const Caption: CString) : IDCTreeColumn;
    function  FindColumnByPropertyName(const Name: CString) : IDCTreeColumn;
    function  FindColumnByTag(const Value: CObject) : IDCTreeColumn;

    function  ColumnLayoutToJSON: TJSONObject;
    procedure RestoreColumnLayoutFromJSON(const Value: TJSONObject);

    procedure InsertItem(index: Integer; const value: IDCTreeColumn); overload; override;

  public
    constructor Create(const Owner: IColumnsControl); overload; virtual;
    constructor Create(const Owner: IColumnsControl; const col: IEnumerable<IDCTreeColumn>); overload; virtual;
    destructor Destroy; override;

    property TreeControl: IColumnsControl read get_TreeControl;
  end;

  TTreeLayoutColumn = class(TBaseInterfacedObject, IDCTreeLayoutColumn)
  protected
    _column: IDCTreeColumn;
    _treeControl: IColumnsControl;

    _index: Integer;
    _left: Single;
    _width: Single;

    _hideColumnInView: Boolean;
    _containsData: TColumnContainsData;
    _calculatedHorzAlign: TTextAlign;
    _calculatedVertAlign: TTextAlign;

    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF} _activeFilter: ITreeFilterDescription;
    {$IFNDEF WEBASSEMBLY}[weak]{$ENDIF} _activeSort: IListSortDescription;

    function  get_Column: IDCTreeColumn;
    function  get_Index: Integer;
    procedure set_Index(const Value: Integer);
    function  get_Left: Single;
    procedure set_Left(Value: Single);
    function  get_Width: Single;
    procedure set_Width(Value: Single);

    function  get_ActiveFilter: ITreeFilterDescription;
    procedure set_ActiveFilter(const Value: ITreeFilterDescription);
    function  get_ActiveSort: IListSortDescription;
    procedure set_ActiveSort(const Value: IListSortDescription);
    function  get_HideColumnInView: Boolean;
    procedure set_HideColumnInView(const Value: Boolean);
    function  get_ContainsData: TColumnContainsData;
    function  get_CalculatedHorzAlign: TTextAlign;
    function  get_CalculatedVertAlign: TTextAlign;

  public
    constructor Create(const AColumn: IDCTreeColumn; const ColumnControl: IColumnsControl);
    destructor Destroy; override;

    function  CreateInfoControl(const Cell: IDCTreeCell; const ControlClassType: TInfoControlClass): IDCControl;

    procedure CreateCellBase(const ShowVertGrid: Boolean; const Cell: IDCTreeCell);
    procedure CreateCellBaseControls(const ShowVertGrid: Boolean; const Cell: IDCTreeCell);
    procedure CreateCellStyleControl(const StyleLookUp: CString; const ShowVertGrid: Boolean; const Cell: IDCTreeCell);

    procedure UpdateCellControlsByRow(const Cell: IDCTreeCell);
    procedure UpdateCellControlsPositions(const Cell: IDCTreeCell; ForceIsValid: Boolean = False);
    procedure UpdateColumnContainsData(const ContainsData: TColumnContainsData; const CellDataExample: CObject);
  end;

  TExpandButton = class(TLayout)
  private
    _plusRect: TRectangle;
    _minRect: TRectangle;

    procedure set_ShowExpanded(const Value: Boolean);

  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

  public
    constructor Create(Owner: TComponent); override;

    property ShowExpanded: Boolean write set_ShowExpanded;
  end;

  TDCTreeLayout = class(TBaseInterfacedObject, IDCTreeLayout)
  protected
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _columnsControl: IColumnsControl;
    _recalcRequired: Boolean;

    _layoutColumns: List<IDCTreeLayoutColumn>;
    _flatColumns: List<IDCTreeLayoutColumn>;
    _overflow: Single;
    _isScrolling: Boolean;

    function  get_LayoutColumns: List<IDCTreeLayoutColumn>;
    function  get_FlatColumns: List<IDCTreeLayoutColumn>;

    function  ColumnCanAddWidth(const LayoutColumn: IDCTreeLayoutColumn): Boolean;

  public
    constructor Create(const ColumnControl: IColumnsControl); reintroduce;
    destructor Destroy; override;

    procedure UpdateColumnWidth(const FlatColumnIndex: Integer; const Width: Single);
    procedure RecalcColumnWidthsBasic;
    procedure RecalcColumnWidthsAutoFit;

    procedure ResetColumnDataAvailability(OnlyForInsertedRows: Boolean);
    procedure UpdateLayoutColumnList;

    procedure ForceRecalc;

    function  HasFrozenColumns: Boolean;
    function  ContentOverFlow: Integer;
    function  FrozenColumnWidth: Single;
    function  RecalcRequired: Boolean;

    procedure SetTreeIsScrolling(const IsScrolling: Boolean);
  end;

  TFastLayout = class(TLayout)
  protected
    procedure DoPaint; override;
  end;

  TDCTreeCell = class(TBaseInterfacedObject, IDCTreeCell)
  protected
    _backgroundControl: IBackgroundControl; // can be custom user control, not only TCellControl
    _infoControl: IDCControl;
    _subInfoControl: IDCControl;
    _expandButton: TLayout;
    _customInfoControlBounds: TRectF;
    _customSubInfoControlBounds: TRectF;
    _customTag: CObject;

    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _row     : IDCRow;

    _data: CObject;
    _subData: CObject;

    _performanceModeWhileScrolling: Boolean;
    _performanceLayout: TFastLayout;

    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _layoutColumn   : IDCTreeLayoutColumn;

    function  get_Column: IDCTreeColumn;
    function  get_LayoutColumn: IDCTreeLayoutColumn;
    function  get_Control: TControl;
//    procedure set_Control(const Value: TControl); virtual;
    function  get_BackgroundControl: IBackgroundControl;
    procedure set_BackgroundControl(const Value: IBackgroundControl);
    function  get_ExpandButton: TLayout;
    procedure set_ExpandButton(const Value: TLayout);
    function  get_HideCellInView: Boolean;
    procedure set_HideCellInView(const Value: Boolean);

    function  get_InfoControl: IDCControl;
    procedure set_InfoControl(const Value: IDCControl);
    function  get_CustomInfoControlBounds: TRectF;
    procedure set_CustomInfoControlBounds(const Value: TRectF);
    function  get_SubInfoControl: IDCControl;
    procedure set_SubInfoControl(const Value: IDCControl);
    function  get_CustomSubInfoControlBounds: TRectF;
    procedure set_CustomSubInfoControlBounds(const Value: TRectF);

    function  get_Data: CObject; virtual;
    procedure set_Data(const Value: CObject); virtual;
    function  get_SubData: CObject;
    procedure set_SubData(const Value: CObject);
    function  get_Row: IDCRow;
    function  get_Index: Integer;
    function  get_CustomTag: CObject;
    procedure set_CustomTag(const Value: CObject);
    function  get_PerformanceModeWhileScrolling: Boolean;
    procedure set_PerformanceModeWhileScrolling(const Value: Boolean);

  protected
    _selectionRect: TControl;

    procedure UpdateSelectionRect(OwnerIsFocused: Boolean);

    function  InPerformanceMode: Boolean;
    procedure TogglePerformanceMode(const Activate: Boolean);

  public
    constructor Create(const ARow: IDCRow; const LayoutColumn: IDCTreeLayoutColumn);
    destructor Destroy; override;

    procedure UpdateSelectionVisibility(const RowIsSelected: Boolean; const SelectionInfo: ITreeSelectionInfo; OwnerIsFocused: Boolean);

    function  IsHeaderCell: Boolean; virtual;

    procedure ClearCellForReassignment; virtual;
    procedure CheckPerformanceRoutine(GoPerformanceMode: Boolean);

    property Column: IDCTreeColumn read get_Column;
    property Row: IDCRow read get_Row;
    property Control: TControl read get_Control;
    property PerformanceModeWhileScrolling: Boolean read get_PerformanceModeWhileScrolling write set_PerformanceModeWhileScrolling;
  end;

  THeaderCell = class(TDCTreeCell, IHeaderCell)
  private
    procedure OnResizeControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

  protected
    _sortControl: TControl;
    _filterControl: TControl;
    _resizeControl: TControl;

    _onHeaderCellResizeClicked: TOnHeaderCellResizeClicked;

    function  get_SortControl: TControl;
    procedure set_SortControl(const Value: TControl);
    function  get_FilterControl: TControl;
    procedure set_FilterControl(const Value: TControl);
    function  get_ResizeControl: TControl;
    procedure set_ResizeControl(const Value: TControl);

    procedure set_OnHeaderCellResizeClicked(const Value: TOnHeaderCellResizeClicked);

  public
    function  IsHeaderCell: Boolean; override;
  end;

  TDCTreeRow = class(TDCRow, IDCTreeRow)
  private
    _cells: Dictionary<Integer, IDCTreeCell>;
    _contentCellSizes: Dictionary<Integer, Single>;

    _frozenColumnRowControl: TControl;
    _nonFrozenColumnRowControl: TControl;

  protected
//    _innerRowControl: TControl;
    _placeInnerRowAtBottom: Boolean;

    function  get_Cells: Dictionary<Integer, IDCTreeCell>;
    function  get_ContentCellSizes: Dictionary<Integer, Single>;
    function  get_FrozenColumnRowControl: TControl;
    procedure set_FrozenColumnRowControl(const Value: TControl);
    function  get_NonFrozenColumnRowControl: TControl;
    procedure set_NonFrozenColumnRowControl(const Value: TControl);

//    function  get_InnerRowControl: TControl;
//    procedure set_InnerRowControl(const Value: TControl);
//    function  get_PlaceInnerRowAtBottom: Boolean;
//    procedure set_PlaceInnerRowAtBottom(const Value: Boolean);

//    procedure UpdatePositionAndWidthInnerRowControl; virtual;

  public
    destructor Destroy; override;

    procedure ClearRowForReassignment; override;
    procedure UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean); override;
    procedure ResetCells;
    function  IsDummyRowForChanging: Boolean;

//    property InnerRowControl: TControl read get_InnerRowControl write set_InnerRowControl;
//    property PlaceInnerRowAtBottom: Boolean read get_PlaceInnerRowAtBottom write set_PlaceInnerRowAtBottom;
  end;

  TDCHeaderRow = class(TDCTreeRow, IDCHeaderRow)
  private
    _contentControl: TControl;

    function  get_ContentControl: TControl;

  protected
    function  get_IsHeaderRow: Boolean; override;

  public
    destructor Destroy; override;

    procedure CreateHeaderControls(const Owner: IColumnsControl);

    property ContentControl: TControl read get_ContentControl;
  end;

  TTreeSelectionInfo = class(TRowSelectionInfo, ITreeSelectionInfo)
  private
    _lastSelectedLayoutColumn: Integer;
    _SelectedLayoutColumns: List<Integer>;

    function  get_SelectedLayoutColumn: Integer;
    procedure set_SelectedLayoutColumn(const Value: Integer);
    function  get_SelectedLayoutColumns: List<Integer>;

  protected
    function  CreateInstance: IRowSelectionInfo; override;
    function  Clone: IRowSelectionInfo; override;

  public
    constructor Create(const RowsControl: IRowsControl); reintroduce;

    procedure Clear; override;
    procedure ClearMultiSelections; override;

    function ColumnIsSelected(const ClmnIndex: Integer): Boolean;
  end;

  TDataControlWaitForRepaintInfo = class(TWaitForRepaintInfo, IDCControlWaitForRepaintInfo)
  private
    _viewStateFlags: TTreeViewStateFlags;
    _cellSizeUpdates: Dictionary<Integer {FlatColumnIndex}, Single>;

    function  get_ViewStateFlags: TTreeViewStateFlags;
    procedure set_ViewStateFlags(const Value: TTreeViewStateFlags);

    function  get_CellSizeUpdates: Dictionary<Integer {FlatColumnIndex}, Single>;
    procedure set_CellSizeUpdates(const Value: Dictionary<Integer {FlatColumnIndex}, Single>);

  public
    procedure ColumnsChanged;

    property ViewStateFlags: TTreeViewStateFlags read get_ViewStateFlags;
    property CellSizeUpdates: Dictionary<Integer {FlatColumnIndex}, Single> read get_CellSizeUpdates write set_CellSizeUpdates;
  end;

  THeaderColumnResizeControl = class(TInterfacedObject, IHeaderColumnResizeControl)
  private
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF} _headerCell: IHeaderCell;
    _treeControl: IColumnsControl;

//      _onResized: TNotifyEvent;

    _columnResizeFullHeaderControl: TControl;
    _columnResizeControl: TControl;

//    procedure SplitterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DoSplitterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure DoSplitterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DoSplitterMouseLeave(Sender: TObject);

    procedure StopResizing;

  public
    constructor Create(const TreeControl: IColumnsControl); reintroduce;
    procedure StartResizing(const HeaderCell: IHeaderCell);
  end;

const
  AUTO_SELECT_COLUMN_TAG = 'autoselect';


implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.Math,
  FMX.Graphics,
  System.ClassHelpers,
  FMX.Ani,
  FMX.ScrollControl.WithCells.PopupMenu,
  System.Rtti, 
  System.TypInfo,
  {$ELSE}
  Wasm.FMX.ActnList,
  Wasm.FMX.Types,
  Wasm.System.Math,
  Wasm.FMX.Graphics,
  {$ENDIF}
  FMX.ControlCalculations,
  FMX.ScrollControl.Intf, 
  FMX.ScrollControl.SortAndFilter,
  FMX.ScrollControl.Impl
  {$IFDEF APP_PLATFORM}
  , app.intf
  , app.PropertyDescriptor.intf
  {$ENDIF}
  , FMX.ScrollControl.ControlClasses,
  System.Generics.Collections;


{ TScrollControlWithCells }

procedure TScrollControlWithCells.ProcessColumnVisibilityRules;
begin
  var currentClmns := _treeLayout.FlatColumns;
  var clmn: IDCTreeLayoutColumn;
  for clmn in currentClmns do
    if clmn.ContainsData = TColumnContainsData.Unknown then
    begin
      clmn.UpdateColumnContainsData(TColumnContainsData.No, nil);
      _treeLayout.ForceRecalc;
    end;

  if not _autoFitColumns and not _treeLayout.RecalcRequired {in case column is hidden by user} then
    Exit;

  if _autoFitColumns then
    _treeLayout.RecalcColumnWidthsAutoFit;

  InitHeader;

  if _treeLayout.FlatColumns.Count = 0 then
    Exit;

  var selInfo := (_selectionInfo as ITreeSelectionInfo);
  var lastFlatColumn := _treeLayout.FlatColumns[_treeLayout.FlatColumns.Count - 1];
  if selInfo.SelectedLayoutColumn > lastFlatColumn.Index then
    selInfo.SelectedLayoutColumn := lastFlatColumn.Index;

  if _view <> nil then
  begin
    var row: IDCRow;
    for row in _view.ActiveViewRows do
    begin
      var treeRow := row as IDCTreeRow;

      var cell: IDCTreeCell;
      var layoutColumn: IDCTreeLayoutColumn;
      for layoutColumn in _treeLayout.LayoutColumns do
        if treeRow.Cells.TryGetValue(layoutColumn.Index, cell) and cell.LayoutColumn.HideColumnInView then
          cell.HideCellInView := True;
    end;
  end;

  var clmn2: IDCTreeLayoutColumn;
  for clmn2 in _treeLayout.FlatColumns do
    if not currentClmns.Contains(clmn2) then
      RefreshColumn(clmn2.Column);
end;

function TScrollControlWithCells.ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; const IsSubProp: Boolean): CObject;
begin
  Result := Cell.Column.ProvideCellData(cell, propName, IsSubProp);
end;

procedure TScrollControlWithCells.RealignFinished;
begin
  if _headerRow <> nil then
    DoRowAligned(_headerRow);

  inherited;
end;

procedure TScrollControlWithCells.RefreshColumn(const Column: IDCTreeColumn);
begin
  if (_view = nil) or (_treeLayout = nil) or (Column = nil) then
    Exit;

  var clmn := FlatColumnByColumn(Column);
  if clmn = nil then
    Exit; // full realign still needs to happen..

  _reloadForSpecificColumn := clmn;
  try
    var row: IDCRow;
    for row in _view.ActiveViewRows do
    begin
      var treeRow := row as IDCTreeRow;
      InnerInitRow(row);

      if treeRow.ContentCellSizes.ContainsKey(clmn.Index) then
        treeRow.ContentCellSizes.Remove(clmn.Index);

      if clmn.Column.WidthType = TDCColumnWidthType.AlignToContent then
        clmn.Width := clmn.Column.WidthMin;
    end;
  finally
    _reloadForSpecificColumn := nil;
  end;

  RefreshControl;
end;

function TScrollControlWithCells.TreeInnerXPosition: Single;
begin
  if _autoCenterTree then
    Result := CMath.Max((Self.Width-_totalColumnWidth)/2, 0) else
    Result := 0;
end;

procedure TScrollControlWithCells.PositionTree;
begin
  if (_treeLayout <> nil) and (_treeLayout.FlatColumns.Count > 0) then
  begin
    var lastClmn := _treeLayout.FlatColumns[_treeLayout.FlatColumns.Count - 1];
    var newColumnsWidth := lastClmn.Left + lastClmn.Width;

    if not SameValue(_totalColumnWidth, newColumnsWidth) then
      _totalColumnWidth := newColumnsWidth;

    DoTreePositioned(_totalColumnWidth);
  end else
    _totalColumnWidth := 0.0;

  if _autoCenterTree then
  begin
    var startFromX := TreeInnerXPosition;
    var row: IDCTreeRow;
    for row in HeaderAndTreeRows(False) do
      row.Control.Position.X := startFromX;
  end;
end;

{$IFDEF WEBASSEMBLY}
function  TScrollControlWithCells.GetItemType: &Type; 
begin
  Result := inherited;
end;
{$ENDIF}

procedure TScrollControlWithCells.AfterScrolling;
begin
  inherited;

end;

procedure TScrollControlWithCells.AfterRealignContent;
begin
  inherited;

  if _columns.Count = 0 then
    Exit;

  AssignWidthsToAlignColumns;

  ProcessColumnVisibilityRules;

  UpdateHorzScrollbar;

  UpdatePositionAndWidthCells;

  PositionTree;

  SetBasicVertScrollBarValues;

  if DefaultLayout <> nil then
    EndDefaultTextLayout;
end;

procedure TScrollControlWithCells.AssignWidthsToAlignColumns;
begin
  if GetScrollingType = TScrollingType.WithScrollBar then
    Exit;

  var fullRowList: List<IDCTreeRow> := HeaderAndTreeRows(True);

  var flatClmn: IDCTreeLayoutColumn;
  for flatClmn in _treeLayout.FlatColumns do
    if flatClmn.Column.WidthType = TDCColumnWidthType.AlignToContent then
    begin
      var maxCellWidth := flatClmn.Width;
      var row: IDCTreeRow;
      for row in fullRowList do
      begin
        var treeRow := row as IDCTreeRow;
        try
          var w: Single;
          var cell: IDCTreeCell;
          if not treeRow.ContentCellSizes.TryGetValue(flatClmn.Index, w) and treeRow.Cells.TryGetValue(flatClmn.Index, cell) then
          begin
            w := CalculateCellWidth(flatClmn, cell) {+ (10 extra space on the right, to make the view look cleaner)};
            treeRow.ContentCellSizes.Add(flatClmn.Index, w);
          end;

          if w > maxCellWidth then
            maxCellWidth := w;
        except
          Continue;
        end;
      end;

      _treeLayout.UpdateColumnWidth(flatClmn.Index, maxCellWidth);
    end;
end;

procedure TScrollControlWithCells.UpdateHorzScrollbar;
begin
  var contentOverflow := _treeLayout.ContentOverFlow;
  if contentOverflow > 0 then
  begin
    SetBasicHorzScrollBarValues;

    if MasterSynchronizer <> nil then
    begin
      _horzScrollBar.Visible := True;
      _horzScrollBar.Opacity := IfThen(TDCTreeOption.HideHScrollBar in _options, 0, 1);
    end else begin
      _horzScrollBar.Visible := not (TDCTreeOption.HideHScrollBar in _options);
      _horzScrollBar.Opacity := 1;
    end;

    UpdateScrollbarMargins;

    _frozenRectLine.Visible := (_horzScrollBar.Value > _horzScrollBar.Min) and _treeLayout.HasFrozenColumns;
    _frozenRectLine.Position.X := _treeLayout.FrozenColumnWidth - 1;
    _frozenRectLine.BringToFront;
  end else
  begin
    if MasterSynchronizer <> nil then
    begin
      _horzScrollBar.Visible := True;
      _horzScrollBar.Opacity := 0;
    end else begin
      _horzScrollBar.Visible := False;
    end;

    _frozenRectLine.Visible := False;
  end;
end;

procedure TScrollControlWithCells.UpdateHoverRect(MousePos: TPointF);
begin
  inherited;

  if (_hoverRect.Visible) and (_selectionType = TSelectionType.CellSelection) then
  begin
    var clmn := GetSelectableFlatColumnByMouseX(MousePos.X);

    _hoverRect.Visible := (clmn <> nil) and (GetScrollingType = TScrollingType.None);
    if not _hoverRect.Visible then Exit;

    // y positions already set in "inherited"
    var hoverMargin := 1;
    _hoverRect.Position.X := clmn.Left + hoverMargin;

    var hoverWidth := clmn.Width;
    if not clmn.Column.Frozen and _horzScrollBar.Visible then
    begin
      var xPos := _hoverRect.Position.X - (_horzScrollBar.Value - _horzScrollBar.Min);
      if xPos < _horzScrollBar.Min then
      begin
        var diff := _horzScrollBar.Min - xPos;
        hoverWidth := hoverWidth - diff;
        _hoverRect.Position.X := xPos + diff;
      end else
        _hoverRect.Position.X := xPos;
    end;

    _hoverRect.Width := hoverWidth - (2*hoverMargin);
  end;
//   else
//    _hoverCellRect.Visible := False;
end;

procedure TScrollControlWithCells.UpdatePositionAndWidthCells;
begin
  // this will only be done if columns or their sizes changed
  _treeLayout.RecalcColumnWidthsBasic;

  var frozenColumnWidth := _treeLayout.FrozenColumnWidth;
  var hasFrozenColumns := frozenColumnWidth > 0;

  var rowWidth := CalculateRowControlWidth(False);

  var showHeaderGrid := TDCTreeOption.ShowHeaderGrid in _options;
  var showVertGrid := TDCTreeOption.ShowVertGrid in _options;
  var showHorzGrid := TDCTreeOption.ShowHorzGrid in _options;

  var row: IDCTreeRow;
  for row in HeaderAndTreeRows(False{not _fullRepositionCellsNeeded}) do
  begin
    var treeRow := row as IDCTreeRow;
    treeRow.Control.Width := rowWidth;
    treeRow.Control.Position.X := 0.0;
//    treeRow.UpdatePositionAndWidthInnerRowControl;

    if hasFrozenColumns then
    begin
      if (treeRow.FrozenColumnRowControl = nil) then
      begin
        var ly := TLayout.Create(Row.Control);
        ly.Align := TAlignLayout.None;
        ly.Position.X := 0;
        ly.Position.Y := 0;
        ly.HitTest := False;
        ly.Parent := Row.Control;
        treeRow.FrozenColumnRowControl := ly;
      end;

      treeRow.FrozenColumnRowControl.Height := Row.Control.Height;
      treeRow.FrozenColumnRowControl.Width := frozenColumnWidth;
    end
    else if treeRow.FrozenColumnRowControl <> nil then
      treeRow.FrozenColumnRowControl.Visible := False;

    if (treeRow.NonFrozenColumnRowControl = nil) then
    begin
      var ly2 := TLayout.Create(Row.Control);
      ly2.Align := TAlignLayout.None;
      ly2.Position.Y := 0;
      ly2.HitTest := False;
      ly2.ClipChildren := True;
      ly2.Parent := Row.Control;

      treeRow.NonFrozenColumnRowControl := ly2;
    end;

    if treeRow.FrozenColumnRowControl <> nil then
      treeRow.FrozenColumnRowControl.BringToFront;

    treeRow.NonFrozenColumnRowControl.Position.X := frozenColumnWidth;
    treeRow.NonFrozenColumnRowControl.Height := Row.Control.Height;
    treeRow.NonFrozenColumnRowControl.Width := rowWidth - frozenColumnWidth;

    var firstVisibleGridClmn := True;

    var flatClmn: IDCTreeLayoutColumn;
    for flatClmn in _treeLayout.FlatColumns do
    begin
      var cell: IDCTreeCell;
      if not treeRow.Cells.TryGetValue(flatClmn.Index, cell) then
        Continue;

      flatClmn.UpdateCellControlsPositions(cell);

      var sides: TSides := [];
      if not cell.Column.Visualisation.HideGrid then
      begin
        if cell.IsHeaderCell then
        begin
          if not showHeaderGrid then
            sides := [TSide.Bottom]
          else if firstVisibleGridClmn then
            sides := AllSides
          else
            sides := [TSide.Top, TSide.Bottom, TSide.Right];
        end
        else
        begin
          if showVertGrid then
          begin
            if firstVisibleGridClmn then
              sides := [TSide.Right, TSide.Left] else
              sides := [TSide.Right];
          end;

          if showHorzGrid then
            sides := sides + [TSide.Bottom];
        end;
      end;

      cell.BackgroundControl.Sides := sides;

      var leftPos := flatClmn.Left;
      var xPos: Single;
      if hasFrozenColumns and cell.Column.Frozen then
      begin
        cell.Control.Parent := treeRow.FrozenColumnRowControl;
        xPos := leftPos;
      end else
      begin
        cell.Control.Parent := treeRow.NonFrozenColumnRowControl;

        if _horzScrollBar.Visible and (_horzScrollBar.Opacity > 0) then
          xPos := leftPos - {frozenColumnWidth - }_horzScrollBar.Value else
          xPos := leftPos - frozenColumnWidth;
      end;

      cell.Control.Position.X := xPos;

      if cell.ExpandButton <> nil then
        cell.ExpandButton.Position.Y := ((cell.Row.Height - cell.ExpandButton.Height) / 2) + 0.5;

      if not cell.Column.Visualisation.HideGrid then
        firstVisibleGridClmn := False;
    end;
  end;

//  _fullRepositionCellsNeeded := False;
end;

procedure TScrollControlWithCells.GenerateView;
begin
  if _defaultColumnsGenerated then
  begin
    _columns.Clear;
    _treeLayout := nil;

    _defaultColumnsGenerated := False;
  end
  else if _treeLayout <> nil then
    _treeLayout.ResetColumnDataAvailability(False);

  inherited;
end;

function TScrollControlWithCells.GetActiveCell: IDCTreeCell;
begin
  var row := GetActiveRow as IDCTreeRow;
  if (row = nil) or (row.Cells.Count = 0) then
    Exit(nil);

  var treeSelection := _selectionInfo as ITreeSelectionInfo;

  CheckCorrectColumnSelection(treeSelection, row);
  Result := row.Cells[treeSelection.SelectedLayoutColumn];
end;

function TScrollControlWithCells.GetCellByControl(const Control: TControl): IDCTreeCell;
begin
  Result := nil;

  var controlPoint := Control.LocalToScreen(PointF(0,0));
  var pointInDataControl := Self.ScreenToLocal(controlPoint);

  var clickedRow := GetRowByLocalY(pointInDataControl.Y - _content.Position.Y);
  if clickedRow = nil then Exit;

  var flatColumn := GetFlatColumnByMouseX(pointInDataControl.X);
  if flatColumn = nil then Exit;

  Result := (clickedRow as IDCTreeRow).Cells[FlatColumn.Index];
end;

function TScrollControlWithCells.GetFlatColumnByKey(const Key: Word; Shift: TShiftState; FromColumnIndex: Integer): IDCTreeLayoutColumn;

  function CanSelectLayoutColumn(const LyColumn: IDCTreeLayoutColumn): Boolean;
  begin
    Result := (LyColumn.Column.CustomWidth <> 0) and LyColumn.Column.Selectable and _treeLayout.FlatColumns.Contains(LyColumn);
  end;

begin
  var horzScroll := GetHorzScroll(Key, Shift);
  if horzScroll = TRightLeftScroll.None then
  begin
    if FromColumnIndex = -1 then
      Exit(GetFlatColumnByKey(vkHome, Shift, 0));

    Result := _treeLayout.LayoutColumns[FromColumnIndex];
    Exit;
  end;

  var treeSelectionInfo := _selectionInfo as ITreeSelectionInfo;

  var flatColumn: IDCTreeLayoutColumn;
  if horzScroll = TRightLeftScroll.FullLeft then
    flatColumn := _treeLayout.FlatColumns[0]
  else if horzScroll = TRightLeftScroll.FullRight then
    flatColumn := _treeLayout.FlatColumns[_treeLayout.FlatColumns.Count - 1]
  else
  begin
    var crrntFlatColumnIndex := FlatColumnIndexByLayoutIndex(FromColumnIndex);
    if horzScroll = TRightLeftScroll.Left then
      flatColumn := _treeLayout.FlatColumns[CMath.Max(0, crrntFlatColumnIndex - 1)]
    else if horzScroll = TRightLeftScroll.Right then
      flatColumn := _treeLayout.FlatColumns[CMath.Min(_treeLayout.FlatColumns.Count - 1, crrntFlatColumnIndex + 1)];
  end;

  var flatIndex := _treeLayout.FlatColumns.IndexOf(flatColumn);
  while not CanSelectLayoutColumn(flatColumn) do
  begin
    if horzScroll in [TRightLeftScroll.FullLeft, TRightLeftScroll.Right] then
      inc(flatIndex) else
      dec(flatIndex);

    if (flatIndex < 0) or (flatIndex > _treeLayout.FlatColumns.Count - 1) then
      Exit(_treeLayout.LayoutColumns[FromColumnIndex]); // nothing to do

    flatColumn := _treeLayout.FlatColumns[flatIndex];
  end;

  Result := flatColumn;
end;

function TScrollControlWithCells.GetSelectableFlatColumnByMouseX(const X: Single): IDCTreeLayoutColumn;
begin
  Result := GetFlatColumnByMouseX(X);

  if (Result = nil) or not Result.Column.Selectable then
  begin
    if (Result <> nil) then
      Result := GetFlatColumnByKey(vkLeft, [], Result.Index);

    // if none found on the left of the mouse than try find first selectable column (on the right of mouse click)
    if (Result = nil) or not Result.Column.Selectable then
      Result := GetFlatColumnByKey(vkHome, [], 0);
  end;
end;

function TScrollControlWithCells.GetFlatColumnByMouseX(const X: Single): IDCTreeLayoutColumn;
begin
  var virtualMouseposition: Single;
  if _horzScrollBar.Visible and (X > _treeLayout.FrozenColumnWidth) then
    virtualMouseposition := X + (_horzScrollBar.Value - _horzScrollBar.Min {frozen width if set}) else
    virtualMouseposition := X;

  if _autoCenterTree then
  begin
    if _headerRow <> nil then
      virtualMouseposition := virtualMouseposition - _headerRow.Control.Position.X
    else if _view.ActiveViewRows.Count > 0 then
      virtualMouseposition := virtualMouseposition - _view.ActiveViewRows[0].Control.Position.X;
  end;

  var flatColumn: IDCTreeLayoutColumn;
  for flatColumn in _treeLayout.FlatColumns do
    if (flatColumn.Left <= virtualMouseposition) and (flatColumn.Left + flatColumn.Width > virtualMouseposition) then
      Exit(flatColumn);

  Result := nil;
end;

function TScrollControlWithCells.GetHorzScroll(const Key: Word; Shift: TShiftState): TRightLeftScroll;
begin
  Result := TRightLeftScroll.None;
  case Key of
    vkHome:   if not (ssCtrl in Shift) then Result := TRightLeftScroll.FullLeft;
    vkEnd:    if not (ssCtrl in Shift) then Result := TRightLeftScroll.FullRight;
    vkLeft:   Result := TRightLeftScroll.Left;
    vkRight:  Result := TRightLeftScroll.Right;
  end;
end;

procedure TScrollControlWithCells.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  var row := GetActiveRow;

  inherited;

  CheckHideAutoMultiSelectColumn(row, Shift);
end;

procedure TScrollControlWithCells.UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single);
begin
  var currentRow := GetActiveRow;

  var clickedRow := GetRowByLocalY(Y);
  if clickedRow = nil then Exit;

  _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Click;

  var flatColumn := GetSelectableFlatColumnByMouseX(X);
  if flatColumn = nil then
  begin
    var flatIx := (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn;
    if _treeLayout.LayoutColumns.Count > flatIx - 1 then
      flatColumn := _treeLayout.LayoutColumns[flatIx] else
      flatColumn := _treeLayout.FlatColumns[0];
  end
  else if flatColumn.Column.IsSelectionColumn then
  begin
    var treeRow := clickedRow as IDCTreeRow;
    var treeCell := treeRow.Cells[flatColumn.Index];
    var checkBox := treeCell.InfoControl as IIsChecked;

    if _selectionInfo.IsChecked(treeRow.DataIndex) then
      _selectionInfo.Deselect(treeRow.DataIndex) else
      _selectionInfo.AddToSelection(treeRow.DataIndex, treeRow.ViewListIndex, treeRow.DataItem, TreeOption_MultiSelect in _options);

    _selectionInfo.BeginUpdate;
    try
      (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn := flatColumn.Index;
    finally
      _selectionInfo.EndUpdate(True {ignore events});
    end;

    DoCellChanged(nil, treeCell);
    Exit;
  end;

  var requestedSelection := _selectionInfo.Clone as ITreeSelectionInfo;
  requestedSelection.UpdateLastSelection(clickedRow.DataIndex, clickedRow.ViewListIndex, clickedRow.DataItem);
  requestedSelection.SelectedLayoutColumn := flatColumn.Index;

  TrySelectItem(requestedSelection, Shift);

  CheckHideAutoMultiSelectColumn(currentRow, Shift);
end;

procedure TScrollControlWithCells.PerformanceRoutineLoadedRow(const Row: IDCRow);
begin
  inherited;

  var performanceModeNeeded := IsFastScrolling;

  var cell: IDCTreeCell;
  for cell in (Row as IDCTreeRow).Cells.Values do
  begin
    cell.CheckPerformanceRoutine(performanceModeNeeded);
    if cell.PerformanceModeWhileScrolling and performanceModeNeeded then
      RestartWaitForRealignTimer(True, True {only realign when scrolling stopped});
  end;
end;

procedure TScrollControlWithCells.VisualizeRowSelection(const Row: IDCRow);
begin
  CheckCorrectColumnSelection(_selectionInfo as ITreeSelectionInfo, nil);

  inherited;
  UpdateSelectionCheckboxes(Row);
end;

procedure TScrollControlWithCells.HandleRowChildRelation(const Row: IDCRow; IsOpenParent, IsOpenChild: Boolean);
begin
  if IsOpenParent then
    DataControlClassFactory.HandleRowChildRelation(Row.ControlAsRowLayout, IsOpenParent, IsOpenChild, Row.Control.Width) else
    DataControlClassFactory.HandleRowChildRelation(Row.ControlAsRowLayout, IsOpenParent, IsOpenChild, _treeLayout.FlatColumns[0].Width);
end;

procedure TScrollControlWithCells.OnHeaderCellResizeClicked( const HeaderCell: IHeaderCell);
begin
  _headerColumnResizeControl.StartResizing(HeaderCell);
end;

procedure TScrollControlWithCells.OnHeaderClick(Sender: TObject);
begin
  _fullHeaderClick := True;
end;

procedure TScrollControlWithCells.OnHeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if (Button = TMouseButton.mbLeft) and not _fullHeaderClick then
    Exit;

  _fullHeaderClick := False;

  if (_headerRow = nil) then
    Exit;

  var flatColumn := GetFlatColumnByMouseX(X);
  if (flatColumn = nil) then
    Exit;

  if Button = TMouseButton.mbRight then
  begin
    if flatColumn.Column.ShowSortMenu or flatColumn.Column.ShowFilterMenu or flatColumn.Column.AllowHide then
      ShowHeaderPopupMenu(flatColumn);

    Exit;
  end;

  if flatColumn.Column.SortType = TSortType.None then
    Exit;

  var sortDirection: ListSortDirection;
  if flatColumn.ActiveSort <> nil then
  begin
    if flatColumn.ActiveSort.SortDirection = ListSortDirection.Ascending then
      sortDirection := ListSortDirection.Descending else
      sortDirection := ListSortDirection.Ascending
  end else
    sortDirection := ListSortDirection.Ascending;

  UpdateColumnSort(flatColumn.Column, sortDirection, not (ssCtrl in Shift));
end;

procedure TScrollControlWithCells.UpdateColumnSort(const Column: IDCTreeColumn; SortDirection: ListSortDirection; ClearOtherSort: Boolean);
begin
  var flatColumn := Self.FlatColumnByColumn(Column);
  if flatColumn = nil then
  begin
    if _realignContentRequested and CanRealignContent then
    begin
      PrepareColumns;
      flatColumn := Self.FlatColumnByColumn(Column);
    end;

    if flatColumn = nil then
      Exit;
  end;

  // keep this var in the methods scope
  // for "ActiveSort" is a weak referenced variable
  var sortDesc: IListSortDescription;
  if FlatColumn.ActiveSort = nil then
  begin
    if FlatColumn.Column.SortType in [TSortType.ColumnCellComparer, TSortType.RowComparer] then
    begin
      {$IFNDEF WEBASSEMBLY}
      var cmpDescriptor: IListSortDescriptionWithComparer := TTreeSortDescriptionWithComparer.Create(FlatColumn, OnGetCellDataForSorting);
      {$ELSE}
      var cmpDescriptor: IListSortDescriptionWithComparer := TTreeSortDescriptionWithComparer.Create(FlatColumn, @OnGetCellDataForSorting);
      {$ENDIF}

      var comparer := DoSortingGetComparer(cmpDescriptor);
      if comparer = nil then
        comparer := TComparerForEvents.Create(Self, FlatColumn.Column);

      cmpDescriptor.Comparer := comparer;

      sortDesc := cmpDescriptor;
    end else
    begin
      {$IFNDEF WEBASSEMBLY}
      sortDesc := TTreeSortDescription.Create(FlatColumn, OnGetCellDataForSorting);
      {$ELSE}
      sortDesc := TTreeSortDescription.Create(FlatColumn, @OnGetCellDataForSorting);
      {$ENDIF}
    end;
      
    FlatColumn.ActiveSort := sortDesc;
  end;

  if FlatColumn.ActiveSort.SortDirection <> SortDirection then
    FlatColumn.ActiveSort.ToggleDirection;

  AddSortDescription(FlatColumn.ActiveSort, ClearOtherSort);
  UpdateHeaderRowControls;

  ExecuteAfterRealignOnly(False);
end;

procedure TScrollControlWithCells.UpdateColumnFilter(const Column: IDCTreeColumn; const FilterText: CString; const FilterValues: List<CObject>);
begin
  var flatColumn := Self.FlatColumnByColumn(Column);
  if flatColumn = nil then
    Exit;

  if CString.IsNullOrEmpty(FilterText) and ((FilterValues = nil) or (FilterValues.Count = 0)) then
  begin
    if flatColumn.ActiveFilter <> nil then
    begin
      var activeFilters: List<IListFilterDescription> := CList<IListFilterDescription>.Create;
      var filterDescription: IListFilterDescription;
      for filterDescription in _view.GetFilterDescriptions do
        if filterDescription <> flatColumn.ActiveFilter then
          activeFilters.Add(filterDescription);

      flatColumn.ActiveFilter := nil;
      GetInitializedWaitForRefreshInfo.FilterDescriptions := activeFilters;
    end;
  end
  else begin
    // keep this var in the methods scope
    // for "ActiveFilter" is a weak referenced variable
    var filter: ITreeFilterDescription;
    if flatColumn.ActiveFilter = nil then
    begin
      {$IFNDEF WEBASSEMBLY}
      filter := TTreeFilterDescriptionWithRow.Create(flatColumn, OnGetCellDataForSorting);
      {$ELSE}
      filter := TTreeFilterDescriptionWithRow.Create(flatColumn, @OnGetCellDataForSorting);
      {$ENDIF}
      FlatColumn.ActiveFilter := filter;
    end;

    FlatColumn.ActiveFilter.FilterText := FilterText;

    if (FilterValues <> nil) and (FilterValues.Count > 0) then
      FlatColumn.ActiveFilter.FilterValues := FilterValues else
      FlatColumn.ActiveFilter.FilterValues := nil;

    AddFilterDescription(FlatColumn.ActiveFilter, False);
  end;

  if _headerRow <> nil then
  begin
    var headerCell := _headerRow.Cells[FlatColumn.Index];
    FlatColumn.UpdateCellControlsByRow(HeaderCell);
  end;
end;

procedure TScrollControlWithCells.UpdateSelectedColumn(const Column: Integer);
begin
  _selectionInfo.BeginUpdate;
  try
//    _selectionInfo.ClearAllSelections;
    (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn := Column;
  finally
    _selectionInfo.EndUpdate;
  end;

  TrySelectItem(_selectionInfo, [ssShift]);
end;

function TScrollControlWithCells.GetColumnValues(const LayoutColumn: IDCTreeLayoutColumn; Add_NO_VALUE: Boolean): Dictionary<CObject, CString>;
var
  filterDescription: IListFilterDescription;

  function GetText(const obj: CObject) : CString;
  begin
    var o := obj;
    if DoCellFormatting(filterDescription as IDCTreeCell, False, {var} o) then
      Result := o.ToString(True) else
      Result := LayoutColumn.Column.GetFormattedValue(filterDescription as IDCTreeCell, o);

    if CString.IsNullOrEmpty(Result) then
      Result := NO_VALUE;
  end;

begin
  {$IFNDEF WEBASSEMBLY}
  filterDescription := TTreeFilterDescriptionWithRow.Create(LayoutColumn, OnGetCellDataForSorting);
  {$ELSE}
  filterDescription := TTreeFilterDescriptionWithRow.Create(LayoutColumn, @OnGetCellDataForSorting);
  {$ENDIF}

  var orgDataList := _view.OriginalData;

  // do it this way to make sure that DataModel returns IDataRow, and not the CObjectss
  var dm: IDataModel;
  if ViewIsDataModelView and interfaces.Supports<IDataModel>(orgDataList, dm) then
    orgDataList := dm.Rows as IList;

  Result := CDictionary<CObject, CString>.Create;

  var item: CObject;
  for item in orgDataList do
  begin
    var obj := filterDescription.GetFilterableValue(item);

    if (obj = nil) and Add_NO_VALUE then
    begin
      if not Result.ContainsKey(NO_VALUE_KEY)  then
        Result[NO_VALUE_KEY] := NO_VALUE;
      continue;
    end;

    if obj.IsOfType<IList> then
    begin
      var o: CObject;
      for o in obj.AsType<IList> do
        if not Result.ContainsKey(o)  then
          Result[o] := GetText(o)
    end
    else if not Result.ContainsKey(obj)  then
      Result[obj] := GetText(obj);
  end;
end;

procedure TScrollControlWithCells.ShowHeaderPopupMenu(const LayoutColumn: IDCTreeLayoutColumn);
var
  showFilter: Boolean;
  dataValues: Dictionary<CObject, CString>;
begin
  {$IFNDEF WEBASSEMBLY}
  (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn := LayoutColumn.Index;

  // Popup form will be created once, then reused for any column
  if _frmHeaderPopupMenu = nil then
    _frmHeaderPopupMenu := TfrmFMXPopupMenuDataControl.Create(Self);

  _frmHeaderPopupMenu.OnClose := HeaderPopupMenu_Closed;
  var popupMenu := _frmHeaderPopupMenu as TfrmFMXPopupMenuDataControl;
  popupMenu.LayoutColumn := LayoutColumn;

  var leftPos: Single;
  if LayoutColumn.Left + TreeInnerXPosition + _frmHeaderPopupMenu.Width > (Self.Width - 10) then
    leftPos := (Self.Width - 10) - _frmHeaderPopupMenu.Width else
    leftPos := LayoutColumn.Left + TreeInnerXPosition;

  var localPos := PointF(leftPos, _headerRow.Height);
  var screenPos := Self.LocalToScreen(localPos);

  showFilter := LayoutColumn.Column.ShowFilterMenu and (_view <> nil) and (_view.ViewCount > 0);

  popupMenu.ShowPopupMenu(ScreenPos, showFilter,
      {ShowItemSort} LayoutColumn.Column.ShowSortMenu,
      {ShowItemAddColumAfter} TDCTreeOption.AllowColumnUpdates in _Options,
      {ShowItemHideColumn} LayoutColumn.Column.AllowHide );

  if showFilter then
  begin
    // Dummy descriptor
    var descriptor: IListSortDescriptionWithComparer := TTreeSortDescriptionWithComparer.Create(LayoutColumn, OnGetCellDataForSorting);
    var comparer := DoSortingGetComparer(descriptor);
    var filter := LayoutColumn.ActiveFilter;

    if filter <> nil then
    begin
      dataValues := GetColumnValues(LayoutColumn, filter.ShowEmptyValues);
      popupMenu.LoadFilterItems(dataValues, comparer, filter.FilterValues, LayoutColumn.Column.SortType = TSortType.Displaytext);
    end
    else
    begin
      dataValues := GetColumnValues(LayoutColumn, True);
      popupMenu.LoadFilterItems(dataValues, comparer, nil, LayoutColumn.Column.SortType = TSortType.Displaytext);
    end;

    popupMenu.AllowClearColumnFilter := (filter <> nil);
  end;
  {$ELSE}
  raise NotImplementedException.Create('procedure TScrollControlWithCells.ShowHeaderPopupMenu(const LayoutColumn: IDCTreeLayoutColumn)');
  {$ENDIF}
end;

procedure TScrollControlWithCells.HeaderPopupMenu_Closed(Sender: TObject; var Action: TCloseAction);
begin
  {$IFNDEF WEBASSEMBLY}
  var popupForm := _frmHeaderPopupMenu as TfrmFMXPopupMenuDataControl;
  var flatColumn := _treeLayout.LayoutColumns[popupForm.LayoutColumn.Index];

  if Assigned(_popupMenuClosed) then
    _popupMenuClosed(popupForm);

  if popupForm.PopupResult = TfrmFMXPopupMenuDataControl.TPopupResult.ptCancel then
    Exit;

  if not DoCellCanChange(GetActiveCell, nil) then
    Exit;

  case popupForm.PopupResult of
    TfrmFMXPopupMenuDataControl.TPopupResult.ptCancel: Exit;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptSortAscending:
    begin
      UpdateColumnSort(flatColumn.Column, ListSortDirection.Ascending, True);
    end;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptSortDescending:
    begin
      UpdateColumnSort(flatColumn.Column, ListSortDirection.Descending, True);
    end;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptFilter:
    begin
      var filterValues := popupForm.SelectedItems;
      UpdateColumnFilter(flatColumn.Column, nil, filterValues);
    end;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptHideColumn:
    begin
      // check if is last flat
      var treeSelectionInfo := (_selectionInfo as ITreeSelectionInfo);
      if treeSelectionInfo.SelectedLayoutColumn = _treeLayout.FlatColumns.Count - 1 then
      begin
        // if last column, then do nothing
        if treeSelectionInfo.SelectedLayoutColumn = 0 then
          Exit;

        treeSelectionInfo.SelectedLayoutColumn := treeSelectionInfo.SelectedLayoutColumn - 1;
      end;

      flatColumn.Column.CustomHidden := True;
      if flatColumn.Column.IsCustomColumn then
        _columns.Remove(flatColumn.Column);

      FastColumnAlignAfterColumnChange;
    end;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptClearFilter:
    begin
      UpdateColumnFilter(flatColumn.Column, nil, nil);
    end;

    TfrmFMXPopupMenuDataControl.TPopupResult.ptClearSortAndFilter:
    begin
      ClearTreeSorts;
      ClearTreeFilters;
      UpdateHeaderRowControls;
    end;
  end;
  {$ELSE}
  raise NotImplementedException.Create('procedure TScrollControlWithCells.HeaderPopupMenu_Closed(Sender: TObject; var Action: TCloseAction)');
  {$ENDIF}
end;

procedure TScrollControlWithCells.ClearTreeSorts;
begin
  var sorts := _view.GetSortDescriptions;
  if (sorts <> nil) and (sorts.Count > 0) then
  begin
    var sortIx: Integer;
    for sortIx := sorts.Count - 1 downto 0 do
      if Interfaces.Supports<ITreeSortDescription>(sorts[sortIx])  then
        sorts.RemoveAt(sortIx);
  end;

  GetInitializedWaitForRefreshInfo.SortDescriptions := sorts;
end;

procedure TScrollControlWithCells.ClearTreeFilters;
begin
  var filters := _view.GetFilterDescriptions;
  if (filters <> nil) and (filters.Count > 0) then
  begin
    var filterIx: Integer;
    for filterIx := filters.Count - 1 downto 0 do
      if Interfaces.Supports<ITreeFilterDescription>(filters[filterIx])  then
        filters.RemoveAt(filterIx);
  end;

  GetInitializedWaitForRefreshInfo.FilterDescriptions := filters;
end;

procedure TScrollControlWithCells.UpdateHeaderRowControls;
begin
  if _headerRow = nil then
    Exit;

  // update all header cells, because other sorts can be turned of (their image should be hidden)
  var headerCell: IDCTreeCell;
  for headerCell in _headerRow.Cells.Values do
    headerCell.LayoutColumn.UpdateCellControlsByRow(headerCell);

  _headerRow.ContentCellSizes.Clear;
end;

procedure TScrollControlWithCells.FastColumnAlignAfterColumnChange;
begin
  _treeLayout.ForceRecalc;
  ExecuteAfterRealignOnly(True);
end;

//procedure TScrollControlWithCells.OnSelectionCheckBoxChange(Sender: TObject);
//begin
//  if _selectionCheckBoxUpdateCount > 0 then
//    Exit;
//
//  var checkBox := Sender as IIsChecked;
//  var cell := GetCellByControl(checkBox);
//
//  if (TreeOption_MultiSelect in _options) then
//    _selectionInfo.AddToSelection(cell.Row.DataIndex, cell.Row.ViewListIndex, cell.Row.DataItem) else
//    _selectionInfo.UpdateSingleSelection(cell.Row.DataIndex, cell.Row.ViewListIndex, cell.Row.DataItem);
//end;

procedure TScrollControlWithCells.UpdateSelectionCheckboxes(const Row: IDCRow);
begin
  // select / deselect based on _selectionInfo
  var selectionCheckBoxColumn := SelectionCheckBoxColumn;
  if selectionCheckBoxColumn = nil then
    Exit;

  inc(_selectionCheckBoxUpdateCount);
  try
    var checkBoxCell := (Row as IDCTreeRow).Cells[selectionCheckBoxColumn.Index];
    var checkBox := checkBoxCell.InfoControl as IIsChecked;

    if (TreeOption_MultiSelect in _options) then
      checkBox.IsChecked := _selectionInfo.IsChecked(Row.DataIndex) else
      checkBox.IsChecked := _selectionInfo.IsSelected(Row.DataIndex);
  finally
    dec(_selectionCheckBoxUpdateCount);
  end;
end;

function TScrollControlWithCells.AutoMultiSelectColumnShowing: Boolean;
begin
  Result := (_autoMultiSelectColumn <> nil) and _autoMultiSelectColumn.Visualisation.Visible;
end;

procedure TScrollControlWithCells.CheckHideAutoMultiSelectColumn(const OldRow: IDCRow; const Shift: TShiftState);
begin
  if not AutoMultiSelectColumnShowing then
    Exit;

  if not (ssCtrl in Shift) and not (ssShift in Shift) and (OldRow <> GetActiveRow) and not _selectionInfo.IsSelected(OldRow.DataIndex) then
  begin
    _autoMultiSelectColumn.Visualisation.Visible := False;
    (GetInitializedWaitForRefreshInfo as IDCControlWaitForRepaintInfo).ColumnsChanged;

    ColumnVisibilityChanged(_autoMultiSelectColumn, False);
  end;
end;

procedure TScrollControlWithCells.CheckShowAutoMultiSelectColumn;
begin
  if (_autoMultiSelectColumn = nil) or _autoMultiSelectColumn.Visualisation.Visible then
    Exit;

  if (_autoMultiSelectColumn.Visualisation.Visible or _selectionInfo.IsMultiSelection {only visible by 2 or more selected}) then
  begin
    _autoMultiSelectColumn.Visualisation.Visible := True;
    (GetInitializedWaitForRefreshInfo as IDCControlWaitForRepaintInfo).ColumnsChanged;

    ColumnVisibilityChanged(_autoMultiSelectColumn, False);
  end;
end;

procedure TScrollControlWithCells.OnSelectionInfoChanged;
begin
  inherited;

  if _horzScrollBar.Visible and (_selectionType = TSelectionType.CellSelection) and ((_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn <> -1) then
  begin
    var treeSelectionInfo := _selectionInfo as ITreeSelectionInfo;
    var currentFlatColumn := _treeLayout.LayoutColumns[treeSelectionInfo.SelectedLayoutColumn];
    if not currentFlatColumn.Column.Frozen {those are always visible} then
    begin
      if (currentFlatColumn.Width > _horzScrollBar.ViewportSize) or (currentFlatColumn.Left < _horzScrollBar.Value) then
        _horzScrollBar.Value := currentFlatColumn.Left
      else if currentFlatColumn.Left + currentFlatColumn.Width > _horzScrollBar.Value + _horzScrollBar.ViewportSize then
        _horzScrollBar.Value := _horzScrollBar.Value + ((currentFlatColumn.Left + currentFlatColumn.Width) - (_horzScrollBar.Value + _horzScrollBar.ViewportSize));
    end;
  end;

  CheckShowAutoMultiSelectColumn;

  if not _selectionInfo.HasSelection then
    Exit;

  var cell := GetActiveCell;
  if (cell = nil) and _realignContentRequested then
  begin
    ForceImmeditiateRealignContent;
    cell := GetActiveCell; // can still be nil..
  end;

  DoCellSelected(cell, _selectionInfo.LastSelectionEventTrigger);
end;

procedure TScrollControlWithCells.SelectAll;
begin
  var selInfo := _selectionInfo as ITreeSelectionInfo;
  selInfo.BeginUpdate;
  try
    inherited;

    if _selectionType = TSelectionType.CellSelection then
    begin
      var flatClmn: IDCTreeLayoutColumn;
      for flatClmn in _treeLayout.FlatColumns do
        if (flatClmn.Width > 0) and flatClmn.Column.Selectable and not selInfo.SelectedLayoutColumns.Contains(flatClmn.Index) then
          selInfo.SelectedLayoutColumns.Add(flatClmn.Index);
    end;

  finally
    selInfo.EndUpdate;
  end;
end;

function TScrollControlWithCells.SelectionCheckBoxColumn: IDCTreeLayoutColumn;
begin
  Result := nil;
  if _treeLayout = nil then
    Exit;

  var lyClmn: IDCTreeLayoutColumn;
  for lyClmn in _treeLayout.FlatColumns do
    if lyClmn.Column.IsSelectionColumn then
      Exit(lyClmn);
end;

procedure TScrollControlWithCells.SetBasicHorzScrollBarValues;
begin
  if _treeLayout = nil then
    inherited
  else begin
    var frozenColumnWidth := _treeLayout.FrozenColumnWidth;

    // when AlignToContent column is a frozen column, and this type of width can change, the HScrollBar Min value must be set back
    var setHorzBackToMinValue := SameValue(_horzScrollBar.Min, _horzScrollBar.Value);
    var rowCtrlWidth := CalculateRowControlWidth(False);

    _horzScrollBar.ValueRange.BeginUpdate;
    try
      _horzScrollBar.Min := frozenColumnWidth;
      _horzScrollBar.Max := rowCtrlWidth + _treeLayout.ContentOverFlow;
      _horzScrollBar.ViewportSize := rowCtrlWidth - frozenColumnWidth;
    finally
      _horzScrollBar.ValueRange.EndUpdate;
    end;

    if setHorzBackToMinValue then
      _horzScrollBar.Value := _horzScrollBar.Min;
  end;
end;

procedure TScrollControlWithCells.SetColumnSelectionIfNoneExists;
begin
  _selectionInfo.BeginUpdate;
  Try
    var treeSelectionInfo := _selectionInfo as ITreeSelectionInfo;
    treeSelectionInfo.SelectedLayoutColumn := -1;
  finally
    _selectionInfo.EndUpdate(True {ignore events});
  end;
end;

procedure TScrollControlWithCells.PrepareColumns;
begin
  var repaintInfo: IDCControlWaitForRepaintInfo;
  var columnsChanged := (Interfaces.Supports<IDCControlWaitForRepaintInfo>(_waitForRepaintInfo, repaintInfo) and (TTreeViewState.ColumnsChanged in repaintInfo.ViewStateFlags));

  if (_treeLayout = nil) or (_columns.Count = 0) or columnsChanged then
    InitLayout;

  _treeLayout.ResetColumnDataAvailability(True);

  if _treeLayout.RecalcRequired then
  begin
    _treeLayout.RecalcColumnWidthsBasic;
    InitHeader;
  end;
end;

procedure TScrollControlWithCells.BeforeRealignContent;
begin
  var repaintInfo: IDCControlWaitForRepaintInfo;
  if Interfaces.Supports<IDCControlWaitForRepaintInfo>(_waitForRepaintInfo, repaintInfo) then
  begin
    // sorting / set data item / set current etc..
    var columnsChanged := ((repaintInfo <> nil) and (TTreeViewState.ColumnsChanged in repaintInfo.ViewStateFlags));
    if columnsChanged and (_view <> nil) then
      _view.ResetView; // clear all controls
  end;

  PrepareColumns;

  inherited;

  BeginDefaultTextLayout;
end;

procedure TScrollControlWithCells.ColumnsChanged(Sender: TObject; e: NotifyCollectionChangedEventArgs);
begin
  if _treeLayout = nil then
    Exit;

  (GetInitializedWaitForRefreshInfo as IDCControlWaitForRepaintInfo).ColumnsChanged;

  var column: IDCTreeColumn := nil;
  if (e.NewItems <> nil) then
    column := e.NewItems[0].AsType<IDCTreeColumn>
  else if (e.OldItems <> nil) then
    column := e.OldItems[0].AsType<IDCTreeColumn>;

  ClearCalculatedColumnWidths;

  if column <> nil then
    DoColumnsChanged(column);
end;

procedure TScrollControlWithCells.ColumnsChangedFromExternal;
begin
  if (_treeLayout = nil) or (_treeLayout.FlatColumns = nil) or (_treeLayout.FlatColumns.Count = 0) then
    Exit;

  InitHeader;
  InitLayout;

  RefreshControl(True);
end;

procedure TScrollControlWithCells.ClearCalculatedColumnWidths;
begin
  if (_treeLayout = nil) or (_realignState <> TRealignState.Waiting) then
    Exit;

  var flatClmn: IDCTreeLayoutColumn;
  for flatClmn in _treeLayout.FlatColumns do
    if flatClmn.Column.WidthType = TDCColumnWidthType.AlignToContent then
    begin
      if flatClmn.Width > 10 then
        flatClmn.Width := CMath.Max(10, flatClmn.Column.WidthMin);
    end;

  RefreshControl;
end;

procedure TScrollControlWithCells.ColumnVisibilityChanged(const Column: IDCTreeColumn; IsUserChange: Boolean);
begin
  if _treeLayout = nil then
    Exit;

  if IsUserChange then
  begin
    (GetInitializedWaitForRefreshInfo as IDCControlWaitForRepaintInfo).ColumnsChanged;
    DoColumnsChanged(Column);
  end;

  ClearCalculatedColumnWidths;

  // selectedcolumn is not valid anymore, select another one
  var flatColumn := FlatColumnByColumn(Column);
  if (flatColumn <> nil) and (flatColumn.HideColumnInView or not flatColumn.Column.Visible) then
    if (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn = flatColumn.Index then
      SetColumnSelectionIfNoneExists;
end;

procedure TScrollControlWithCells.ColumnWidthChanged(const Column: IDCTreeColumn);
begin
  DoColumnsChanged(Column);

  _treeLayout.ForceRecalc;
  ResetView; // rowheighst need to be recalculated..
end;

function TScrollControlWithCells.Content: TControl;
begin
  Result := _content;
end;

function TScrollControlWithCells.Control: TControl;
begin
  Result := Self;
end;

function TScrollControlWithCells.FullColumnList: IList<IDCTreeColumn>;
begin
  if _autoMultiSelectColumn = nil then
    Exit(_columns);

  var list: List<IDCTreeColumn> := CList<IDCTreeColumn>.Create(_columns.Count + 1);
  list.AddRange(_columns);
  list.Insert(_autoMultiSelectColumnIndex, _autoMultiSelectColumn);

  Result :=  list;
end;

constructor TScrollControlWithCells.Create(AOwner: TComponent);
begin
  inherited;

  _frozenRectLine := TRectangle.Create(_content);
  _frozenRectLine.Align := TALignLayout.None;
  _frozenRectLine.Position.Y := 0;
  _frozenRectLine.Width := 2;
  _frozenRectLine.Stroke.Kind := TBrushKind.None;
  _frozenRectLine.Fill.Color := TAlphaColors.Mediumpurple;
  _frozenRectLine.Height := _content.Height;
  _frozenRectLine.Visible := False;
  _content.AddObject(_frozenRectLine);

  _headerHeight := 24;
  _headerTextTopMargin := 0;
  _headerTextBottomMargin := 0;
  _autoExtraColumnSizeMax := -1;

  _scrollingHideColumnsFromIndex := 5;
  _autoMultiSelectColumnIndex := 0;

  _cellTopBottomPadding := ROW_CONTENT_MARGIN;
  _cellLeftRightPadding := ROW_CONTENT_MARGIN;

//  _hoverCellRect := TRectangle.Create(_hoverRect);
//  _hoverCellRect.Stored := False;
//  _hoverCellRect.Align := TAlignLayout.Client;
//  _hoverCellRect.HitTest := False;
//  _hoverCellRect.Visible := False;
//  _hoverCellRect.Stroke.Dash := TStrokeDash.Dot;
//  _hoverCellRect.Stroke.Color := TAlphaColors.Grey;
//  _hoverCellRect.Fill.Kind := TBrushKind.None;
//  _hoverRect.AddObject(_hoverCellRect);

  _headerColumnResizeControl := THeaderColumnResizeControl.Create(Self);

  _columns := TDCTreeColumnList.Create(Self);
  {$IFNDEF WEBASSEMBLY}
  (_columns as INotifyCollectionChanged).CollectionChanged.Add(ColumnsChanged);
  {$ELSE}
  (_columns as INotifyCollectionChanged).CollectionChanged += @ColumnsChanged;
  {$ENDIF}
end;

function TScrollControlWithCells.CreateSelectioninfoInstance: IRowSelectionInfo;
begin
  Result := TTreeSelectionInfo.Create(Self);
end;

function TScrollControlWithCells.GetInitializedWaitForRefreshInfo: IWaitForRepaintInfo;
begin
  // _waitForRepaintInfo is nilled after RealignContent
  if _waitForRepaintInfo = nil then
    _waitForRepaintInfo := TDataControlWaitForRepaintInfo.Create(Self);

  Result := _waitForRepaintInfo;
end;

function TScrollControlWithCells.get_headerHeight: Single;
begin
  Result := _headerHeight;
end;

function TScrollControlWithCells.get_headerTextBottomMargin: Single;
begin
  Result := _headerTextBottomMargin;
end;

function TScrollControlWithCells.get_headerTextTopMargin: Single;
begin
  Result := _headerTextTopMargin;
end;

function TScrollControlWithCells.get_Layout: IDCTreeLayout;
begin
  Result := _treeLayout;
end;

function TScrollControlWithCells.get_AutoExtraColumnSizeMax: Single;
begin
  Result := _autoExtraColumnSizeMax;
end;

function TScrollControlWithCells.get_CellLeftRightPadding: Single;
begin
  Result := _cellLeftRightPadding;
end;

function TScrollControlWithCells.get_CellTopBottomPadding: Single;
begin
  Result := _cellTopBottomPadding;
end;

function TScrollControlWithCells.get_SelectedColumn: IDCTreeLayoutColumn;
begin
  Result := nil;
  if _treeLayout = nil then Exit;

  var selectedLayoutColumn := (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn;
  if (selectedLayoutColumn = -1) or (_treeLayout.LayoutColumns.Count = 0) then Exit;
  Result := _treeLayout.LayoutColumns[selectedLayoutColumn];
end;

procedure TScrollControlWithCells.HandleMultiSelectOptionChanged;
begin
  if not (TDCTreeOption.MultiSelect in _options) then
  begin
    if _autoMultiSelectColumn <> nil then
      (GetInitializedWaitForRefreshInfo as IDCControlWaitForRepaintInfo).ColumnsChanged;

    _autoMultiSelectColumn := nil;
    Exit;
  end

  else if _autoMultiSelectColumn = nil then
  begin
    var clmn: IDCTreeColumn;
    for clmn in _columns do
      if clmn.IsSelectionColumn then
        Exit;

    _autoMultiSelectColumn := TDCTreeCheckboxColumn.Create;
    _autoMultiSelectColumn.TreeControl := Self;
    _autoMultiSelectColumn.WidthSettings.WidthType := TDCColumnWidthType.Pixel;
    _autoMultiSelectColumn.WidthSettings.Width := 30;
    _autoMultiSelectColumn.Visualisation.Selectable := False;
    _autoMultiSelectColumn.Visualisation.Frozen := True;
    _autoMultiSelectColumn.Visualisation.Visible := False;
    _autoMultiSelectColumn.Tag := AUTO_SELECT_COLUMN_TAG;

    CheckShowAutoMultiSelectColumn;
  end;
end;

procedure TScrollControlWithCells.HandleTreeOptionsChange(const OldFlags, NewFlags: TDCTreeOptions);
begin
  inherited;

  if TDCTreeOption.HideHScrollBar in _options then
  begin
    _horzScrollBar.Visible := False;
    SetBasicVertScrollBarValues;
  end;

  var multiSelectChange := ((TDCTreeOption.MultiSelect in OldFlags) <> (TDCTreeOption.MultiSelect in NewFlags));
  if multiSelectChange then
  begin
    HandleMultiSelectOptionChanged;

    if (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn = 0 then
    begin
      _selectionInfo.BeginUpdate;
      try
        var selTreeInfo := (_selectionInfo as ITreeSelectionInfo);
        selTreeInfo.SelectedLayoutColumn := -1;
        CheckCorrectColumnSelection(selTreeInfo, GetActiveRow as IDCTreeRow);
      finally
        _selectionInfo.EndUpdate(True);
      end;
    end;
  end;

  var headerChange := ((TDCTreeOption.ShowHeaders in OldFlags) <> (TDCTreeOption.ShowHeaders in NewFlags));
  var headerGridChange := ((TDCTreeOption.ShowHeaderGrid in OldFlags) <> (TDCTreeOption.ShowHeaderGrid in NewFlags));
  var vertGridChange := ((TDCTreeOption.ShowVertGrid in OldFlags) <> (TDCTreeOption.ShowVertGrid in NewFlags));
  var horzGridChange := ((TDCTreeOption.ShowHorzGrid in OldFlags) <> (TDCTreeOption.ShowHorzGrid in NewFlags));

  if (headerChange <> headerGridChange) and not (TDCTreeOption.ShowHeaders in NewFlags) then
  begin
    if headerChange then
      _options := _options - [TDCTreeOption.ShowHeaderGrid]
    else if headerGridChange then
      _options := _options + [TDCTreeOption.ShowHeaders];
  end;

  if headerChange or headerGridChange or vertGridChange or horzGridChange then
  begin
    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    RefreshControl;
  end;
end;

function TScrollControlWithCells.HeaderAndTreeRows(OnlyNewRows: Boolean): List<IDCTreeRow>;
begin
  var headerShowing: Boolean := _headerRow <> nil;

  var viewCount := 0;
  if _view <> nil then
    viewCount := _view.ActiveViewRows.Count;

  if headerShowing then
  begin
    Result := CList<IDCTreeRow>.Create(viewCount + 1);
    Result.Add(_headerRow);
  end else
    Result := CList<IDCTreeRow>.Create(viewCount);

  if _view <> nil then
  begin
    var row: IDCRow;

//    if OnlyNewRows then
//    begin
//      for row in _newLoadedTreeRows do
//        Result.Add(row as IDCTreeRow);
//    end
//    else
      for row in _view.ActiveViewRows do
        Result.Add(row as IDCTreeRow);
  end;
end;

procedure TScrollControlWithCells.DataModelViewRowPropertiesChanged(Sender: TObject; Args: RowPropertiesChangedEventArgs);
begin
  if HasInternalSelectCount then
    Exit;

  inherited;

  if Args.Row = nil then
    Exit;

  var drv := GetDataModelView.FindRow(Args.Row);
  if drv = nil then
    Exit;

  var row := _view.GetActiveRowIfExists(drv.ViewIndex);
  if row = nil then
    Exit;

  var cell: IDCTreeCell;
  for cell in (row as IDCTreeRow).Cells.Values do
    if cell.ExpandButton <> nil then
      (cell.ExpandButton as TExpandButton).ShowExpanded := not RowIsExpanded(drv.ViewIndex);
end;

destructor TScrollControlWithCells.Destroy;
begin
  _headerRow := nil;
  _treeLayout := nil;

  inherited;
end;

function TScrollControlWithCells.DoCellCanChange(const OldCell, NewCell: IDCTreeCell): Boolean;
begin
  if (_model <> nil) and not _model.ObjectModelContext.ContextCanChange then
  begin
    // if row is not available anymore (after deletion), we must allow changing
    if _view.GetDataIndex(_model.ObjectContext) <> -1 then
      Exit(False);
  end;

  Result := True;
  if Assigned(_cellCanChange) then
  begin
    var args := DCCellCanChangeEventArgs.Create(OldCell, NewCell);
    try
      Result := _cellCanChange(Self, args);
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControlWithCells.DoCellChanged(const OldCell, NewCell: IDCTreeCell);
begin
  if Assigned(_cellChanged) then
  begin
    var args := DCCellChangedEventArgs.Create(OldCell, NewCell);
    try
      _cellChanged(Self, args);
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControlWithCells.DoCellChanging(const OldCell, NewCell: IDCTreeCell);
begin
  if Assigned(_cellChanging) then
  begin
    var args := DCCellChangeEventArgs.Create(OldCell, NewCell);
    try
      _cellChanging(Self, args);
    finally
      args.Free;
    end;
  end;
end;

function TScrollControlWithCells.DoCellFormatting(const Cell: IDCTreeCell; RequestForSort: Boolean; var Value: CObject) : Boolean;
begin
  Result := False;

  if Assigned(_cellFormatting) then
  begin
    var args := DCCellFormattingEventArgs.Create(Cell, Value);
    try
      args.RequestValueForSorting := RequestForSort;

      _cellFormatting(Self, args);
      Value := args.Value;
      Result := args.FormattingApplied;
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControlWithCells.DoCellLoaded(const Cell: IDCTreeCell; RequestForSort: Boolean; var PerformanceModeWhileScrolling: Boolean; var OverrideRowHeight: Single);
begin
  if Assigned(_CellLoaded) then
  begin
    var args := DCCellLoadedEventArgs.Create(Cell, TDCTreeOption.ShowVertGrid in  _options, PerformanceModeWhileScrolling);
    try
      args.RequestValueForSorting := RequestForSort;
      args.OverrideRowHeight := OverrideRowHeight;

      _CellLoaded(Self, args);

      if args.OverrideRowHeight <> -1 {> ManualRowHeight} then
        OverrideRowHeight := args.OverrideRowHeight;

      if args.CalculateCellAfterScrolling and IsScrolling then
        _view.NotifyRowControlsNeedReload(Cell.Row, True {force reload after scrolling is done});

      {var} PerformanceModeWhileScrolling := args.PerformanceModeWhileScrolling;
    finally
      args.Free;
    end;
  end;
end;

function TScrollControlWithCells.DoCellLoading(const Cell: IDCTreeCell; RequestForSort: Boolean; var PerformanceModeWhileScrolling: Boolean; var OverrideRowHeight: Single) : Boolean;
begin
  Result := True; // LoadDefaultData

  if Assigned(_CellLoading) then
  begin
    var args := DCCellLoadingEventArgs.Create(Cell, TDCTreeOption.ShowVertGrid in  _options, PerformanceModeWhileScrolling);
    try
      args.RequestValueForSorting := RequestForSort;
      args.OverrideRowHeight := OverrideRowHeight;

      _CellLoading(Self, args);
      Result := args.LoadDefaultData;

      if args.OverrideRowHeight <> -1 {> ManualRowHeight} then
        OverrideRowHeight := args.OverrideRowHeight;

      if args.CalculateCellAfterScrolling and IsScrolling then
        _view.NotifyRowControlsNeedReload(Cell.Row, True {force reload after scrolling is done});

      {var} PerformanceModeWhileScrolling := args.PerformanceModeWhileScrolling;
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControlWithCells.DoCellSelected(const Cell: IDCTreeCell; EventTrigger: TSelectionEventTrigger);
begin
  if Assigned(_cellSelected) then
  begin
    var args := DCCellSelectedEventArgs.Create(Cell, EventTrigger);
    try
      _cellSelected(Self, args);
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControlWithCells.DoColumnsChanged(const Column: IDCTreeColumn);
var
  args: ColumnChangedByUserEventArgs;

begin
  if Assigned(_onColumnsChanged) then
  begin
    var flatColumn := FlatColumnByColumn(Column);
    var newWidth: Single := -1;
    if (flatColumn <> nil) then
      newWidth := Column.CustomWidth; // = -1 when nothing chanegd

    args := ColumnChangedByUserEventArgs.Create(Column, newWidth);
    try
      _onColumnsChanged(Self, args);
    finally
      args.Free;
    end;
  end;
end;

function TScrollControlWithCells.DoSortingGetComparer(const SortDescription: IListSortDescriptionWithComparer{; const ReturnSortComparer: Boolean}) : IComparer<CObject>;
var
  args: DCColumnComparerEventArgs;

begin
  if Assigned(_SortingGetComparer) then
  begin
    args := DCColumnComparerEventArgs.Create(SortDescription{, ReturnSortComparer});
    try
      args.Comparer := SortDescription.Comparer;
      _SortingGetComparer(Self, args);
      Result := args.Comparer;
    finally
      args.Free;
    end;
  end else
    Result := SortDescription.Comparer;
end;

procedure TScrollControlWithCells.DoTreePositioned(const TotalColumnWidth: Single);
begin
  if Assigned(_onTreePositioned) then
  begin
    var args := DCTreePositionArgs.Create(TotalColumnWidth, Self);
    try
      _onTreePositioned(Self, args);
    finally
      args.Free;
    end;
  end;
end;

function TScrollControlWithCells.FlatColumnByColumn(const Column: IDCTreeColumn): IDCTreeLayoutColumn;
begin
  Result := nil;

  var flatClmn: IDCTreeLayoutColumn;
  if _treeLayout <> nil then
    for flatClmn in _treeLayout.FlatColumns do
      if flatClmn.Column = Column then
        Exit(flatClmn);
end;

function TScrollControlWithCells.DoOnCompareColumnCells(const Column: IDCTreeColumn; const Left, Right: CObject): Integer;
begin
  if Assigned(_onCompareColumnCells) then
    Result := _onCompareColumnCells(Self, Column, Left, Right) else
    Result := 0;
end;

function TScrollControlWithCells.DoOnCompareRows(const Left, Right: CObject): Integer;
begin
  if Assigned(_onCompareRows) then
    Result := _onCompareRows(Self, Left, Right) else
    Result := 0;
end;

procedure TScrollControlWithCells.DoRowLoaded(const ARow: IDCRow);
begin
  inherited;

  if not ARow.IsHeaderRow and not ARow.Enabled then
  begin
    var cell: IDCTreeCell;
    for cell in (ARow as IDCTreeRow).Cells.Values do
    begin
      if cell.InfoControl <> nil then
        cell.InfoControl.Enabled := False;
      if cell.SubInfoControl <> nil then
        cell.SubInfoControl.Enabled := False;
    end;
  end;
end;

function TScrollControlWithCells.DoCreateNewRow: IDCRow;
begin
  Result := TDCTreeRow.Create(Self);
end;

function TScrollControlWithCells.DoCreateNewCell(const ARow: IDCRow; const LayoutColumn: IDCTreeLayoutColumn): IDCTreeCell;
begin
  Result := TDCTreeCell.Create(ARow, LayoutColumn);
end;

procedure TScrollControlWithCells.DoHorzScrollBarChanged;
begin
  inherited;

  UpdatePositionAndWidthCells;
  _frozenRectLine.Visible := (_horzScrollBar.Value > _horzScrollBar.Min) and _treeLayout.HasFrozenColumns;
end;

function TScrollControlWithCells.ProvideRowForChanging(const FromSelectionInfo: IRowSelectionInfo): IDCRow;
begin
  var treeRow := inherited as IDCTreeRow;
  if treeRow = nil then Exit;

  // check if row is actual row that already contains the right cell
  if not treeRow.IsDummyRowForChanging then
    Exit(treeRow);

  var flatColumnIx := (FromSelectionInfo as ITreeSelectionInfo).SelectedLayoutColumn;

  if (flatColumnIx <> -1) then
  begin
    var cell: IDCTreeCell := DoCreateNewCell(treeRow, _treeLayout.LayoutColumns[flatColumnIx]);
    treeRow.Cells.Add(flatColumnIx, cell);
  end;

  Result := treeRow;
end;

function TScrollControlWithCells.TextForSizeCalc(const Text: string): string;
begin
  Result := Text + ' _';
end;

procedure TScrollControlWithCells.TryScrollToCellByKey(var Key: Word; var KeyChar: WideChar);
begin
//  var gotit := False;
//
//  for i := lbItems.ItemIndex + 1 to lbItems.Items.Count - 1 do
//    if lbItems.Items[i].StartsWith(KeyChar, True) then
//    begin
//      gotit := True;
//      lbItems.ItemIndex := i;
//      break;
//    end;
//
//  if not gotit and (lbItems.ItemIndex > 0) then
//  begin
//    for i := 0 to lbItems.ItemIndex do
//      if lbItems.Items[i].StartsWith(KeyChar, True) then
//      begin
//        lbItems.ItemIndex := i;
//        break;
//      end;
//  end;
end;

procedure TScrollControlWithCells.CheckCorrectColumnSelection(const SelectionInfo: ITreeSelectionInfo; const Row: IDCTreeRow);
begin
  if (SelectionInfo.SelectedLayoutColumn = -1) or ((Row <> nil) and not Row.Cells.ContainsKey(SelectionInfo.SelectedLayoutColumn)) then
  begin
    SelectionInfo.BeginUpdate;
    try
      SelectionInfo.SelectedLayoutColumn := GetFlatColumnByKey(vkHome, [], -1).Index; // get first valid column
    finally
      SelectionInfo.EndUpdate(True {ignore events});
    end;
  end;
end;

function TScrollControlWithCells.TrySelectItem(const RequestedSelectionInfo: IRowSelectionInfo; Shift: TShiftState): Boolean;

  procedure UpdateCurrentRowCheckedState;
  begin
    _selectionInfo.BeginUpdate;
    try
      if _selectionInfo.IsChecked(_selectionInfo.DataIndex) then
        _selectionInfo.Deselect(_selectionInfo.DataIndex)
      else
      begin
        var row := GetActiveRow;
        _selectionInfo.AddToSelection(row.DataIndex, row.ViewListIndex, row.DataItem, False);
      end;
    finally
      _selectionInfo.EndUpdate(not CanRealignContent);
    end;
  end;

begin
  Result := False;
  if (_treeLayout = nil { will get here later again}) or not _selectionInfo.CanSelect(RequestedSelectionInfo.DataIndex) then
    Exit;

  var currentSelection := _selectionInfo as ITreeSelectionInfo;
  var requestedSelection := RequestedSelectionInfo as ITreeSelectionInfo;

  var rowChange := currentSelection.DataIndex <> requestedSelection.DataIndex;
  var rowAlreadySelected := not rowChange or currentSelection.IsSelected(requestedSelection.DataIndex);
  var clmnChange := currentSelection.SelectedLayoutColumn <> requestedSelection.SelectedLayoutColumn;
  var clmnAlreadySelected := not clmnChange or currentSelection.SelectedLayoutColumns.Contains(requestedSelection.SelectedLayoutColumn);

  if not currentSelection.IsMultiSelection then
  begin
    // not changed for example when sorting/filtering activated
    if (ssShift in Shift) and rowAlreadySelected and clmnAlreadySelected then
    begin
      // nothing special to do
      ScrollSelectedIntoView(RequestedSelectionInfo);
      DoCellSelected(GetActiveCell, _selectionInfo.LastSelectionEventTrigger);
      Exit;
    end
    else if (SelectionType <> TSelectionType.CellSelection) and not rowChange then
    begin
      // nothing special to do
      ScrollSelectedIntoView(RequestedSelectionInfo);

      // ignore change event, for no row change took place
      currentSelection.BeginUpdate;
      try
        currentSelection.SelectedLayoutColumn := requestedSelection.SelectedLayoutColumn;
      finally
        currentSelection.EndUpdate(True);
      end;

      DoCellSelected(GetActiveCell, _selectionInfo.LastSelectionEventTrigger);

      if (ssCtrl in Shift) and (_selectionInfo.LastSelectionEventTrigger = TSelectionEventTrigger.Click) then
        UpdateCurrentRowCheckedState;

      Exit(True);
    end
    else if not rowChange and not clmnChange then
    begin
      // nothing special to do
      ScrollSelectedIntoView(RequestedSelectionInfo);

      // nothing special to do
      DoCellSelected(GetActiveCell, _selectionInfo.LastSelectionEventTrigger);

      if (ssCtrl in Shift) and (_selectionInfo.LastSelectionEventTrigger = TSelectionEventTrigger.Click) then
        UpdateCurrentRowCheckedState;

      Exit(True);
    end;
  end;

  // Okay, we now know for sure that we have a changed cell..
  // old row can be scrolled out of view. So always work with dummy rows
  var customShift := Shift;

  // old activecell
  CheckCorrectColumnSelection(currentSelection, GetActiveRow as IDCTreeRow);

  var dummyOldRow := ProvideRowForChanging(currentSelection) as IDCTreeRow;
  var oldCell: IDCTreeCell := nil;
  if dummyOldRow <> nil then
    dummyOldRow.Cells.TryGetValue(currentSelection.SelectedLayoutColumn, oldCell);

  // new activecell
  if requestedSelection.SelectedLayoutColumn = -1 then
    requestedSelection.SelectedLayoutColumn := currentSelection.SelectedLayoutColumn;

  var dummyNewRow := ProvideRowForChanging(requestedSelection) as IDCTreeRow;
  var newCell: IDCTreeCell := nil;
  if dummyNewRow <> nil then
    newCell := dummyNewRow.Cells[requestedSelection.SelectedLayoutColumn];

  var ignoreSelectionChanges := not CanRealignContent;
  if not DoCellCanChange(oldCell, newCell) then
    Exit;

  // DoCellCanChange can trigger a ViewReset
  // since we are selecting, we can ignore any set of the dataitem..
  if _waitForRepaintInfo <> nil then
    _waitForRepaintInfo.ClearSelectionInfo;

  DoCellChanging(oldCell, newCell);

  _selectionInfo.BeginUpdate;
  try
    if SelectionType <> TSelectionType.CellSelection then
    begin
      InternalDoSelectRow(requestedSelection.DataIndex, requestedSelection.ViewListIndex, requestedSelection.DataItem, Shift);
      currentSelection.SelectedLayoutColumn := requestedSelection.SelectedLayoutColumn;
    end
    else begin
      if not rowAlreadySelected then
        InternalDoSelectRow(requestedSelection.DataIndex, requestedSelection.ViewListIndex, requestedSelection.DataItem, customShift)
      else if not (ssShift in Shift) and clmnAlreadySelected and (not clmnChange or (ssCtrl in Shift)) then
        InternalDoSelectRow(requestedSelection.DataIndex, requestedSelection.ViewListIndex, requestedSelection.DataItem, customShift);

      if (ssShift in Shift) or (not (ssCtrl in Shift)) or (_selectionInfo.LastSelectionEventTrigger = TSelectionEventTrigger.Key) then
      begin
        InternalDoSelectColumn(requestedSelection.SelectedLayoutColumn, customShift);

        var row := GetActiveRow;
        if row <> nil then // delete makes row = nil
          VisualizeRowSelection(row);
      end;
    end;
  finally
    _selectionInfo.EndUpdate(ignoreSelectionChanges);
  end;

  DoCellChanged(oldCell, newCell);

  Result := True;
end;

procedure TScrollControlWithCells.UpdateScrollAndSelectionByKey(var Key: Word; Shift: TShiftState);
begin
  var treeSelectionInfo := _selectionInfo as ITreeSelectionInfo;
  var flatColumn := GetFlatColumnByKey(Key, Shift, (_selectionInfo as ITreeSelectionInfo).SelectedLayoutColumn);
  var rowViewListIndex := GetRowViewListIndexByKey(Key, Shift);

  if rowViewListIndex = -1 then
  begin
    // check if no row visible / available anymore
    // refreshcontrol in case a row was showing, butis filtered out now
    if (_view <> nil) and (_view.ViewCount = 0) then
      RefreshControl(True);

    Exit;
  end;

  if (treeSelectionInfo.SelectedLayoutColumn <> flatColumn.Index) then
  begin
    _selectionInfo.LastSelectionEventTrigger := TSelectionEventTrigger.Key;

    var requestedSelection := _selectionInfo.Clone as ITreeSelectionInfo;
    requestedSelection.UpdateLastSelection(_view.GetDataIndex(rowViewListIndex), rowViewListIndex, _view.GetViewList[rowViewListIndex]);
    requestedSelection.SelectedLayoutColumn := flatColumn.Index;

    if TrySelectItem(requestedSelection, Shift) then
      Key := 0;
  end
  else
    inherited;
end;

function TScrollControlWithCells.FlatColumnIndexByLayoutIndex(const LayoutIndex: Integer): Integer;
begin
  if (LayoutIndex = -1) or (LayoutIndex > _treeLayout.LayoutColumns.Count - 1) then
    Exit(-1);

  var layoutColumn := _treeLayout.LayoutColumns[LayoutIndex];
  Result := _treeLayout.FlatColumns.IndexOf(layoutColumn);
end;

procedure TScrollControlWithCells.InternalDoSelectColumn(const LayoutColumnIndex: Integer; Shift: TShiftState);
begin
  var treeSelectionInfo := _selectionInfo as ITreeSelectionInfo;
  if (ssShift in Shift) then
  begin
    var currentLayoutFlatIndex := FlatColumnIndexByLayoutIndex(treeSelectionInfo.SelectedLayoutColumn);
    var requestedLayoutFlatIndex := FlatColumnIndexByLayoutIndex(LayoutColumnIndex);

    var index := currentLayoutFlatIndex;
    if requestedLayoutFlatIndex <> index then
    begin
      while requestedLayoutFlatIndex <> index do
      begin
        if not treeSelectionInfo.SelectedLayoutColumns.Contains(index) then
          treeSelectionInfo.SelectedLayoutColumns.Add(index);

        if requestedLayoutFlatIndex < index then
          dec(index) else
          inc(index);
      end;

      if not treeSelectionInfo.SelectedLayoutColumns.Contains(LayoutColumnIndex) then
        treeSelectionInfo.SelectedLayoutColumns.Add(LayoutColumnIndex);

      treeSelectionInfo.SelectedLayoutColumn := LayoutColumnIndex;
    end;
  end
  else if not treeSelectionInfo.SelectedLayoutColumns.Contains(LayoutColumnIndex) or (treeSelectionInfo.SelectedLayoutColumns.Count > 1) then
  begin
    if (treeSelectionInfo.SelectedLayoutColumns.Contains(LayoutColumnIndex)) and (ssCtrl in Shift) then
      Exit; // keep current columns selected

    treeSelectionInfo.SelectedLayoutColumns.Clear;
    treeSelectionInfo.SelectedLayoutColumns.Add(LayoutColumnIndex);
    treeSelectionInfo.SelectedLayoutColumn := LayoutColumnIndex;
  end;
end;

function TScrollControlWithCells.IsScrollingHideColumnsFromIndexStored: Boolean;
begin
  Result := _scrollingHideColumnsFromIndex <> 5;
end;

function TScrollControlWithCells.IsSortingOrFiltering: Boolean;
begin
  Result := _isSortingOrFiltering > 0;
end;

function TScrollControlWithCells.IsSpecifiedColumnReload: Boolean;
begin
  Result := _reloadForSpecificColumn <> nil;
end;

procedure TScrollControlWithCells.InitHeader;
begin
  // make sure that the content does not execute a Resized
  //avoid DoContentResized/OnContentResized in between
  Self.BeginUpdate;
  try
    var headerWasVisible := _headerRow <> nil;
    if _headerRow <> nil then
    begin
      _headerRow.Control.Visible := False;
      {$IFDEF WEBASSEMBLY}
      // In Delphi object is destroyed but in .NET the object just becomes unreferenced, so we call DisposeOf
      //var parent := _headerRow.Control.Parent;
      //if parent <> nil then
      Self.DoRemoveObject(_headerRow.Control.Parent);
      {$ENDIF}
      _headerRow := nil;
    end;

    if (TDCTreeOption.ShowHeaders in _options) then
    begin
      _headerRow := TDCHeaderRow.Create(Self);
      _headerRow.DataIndex := -1;
      _headerRow.CreateHeaderControls(Self);
      {$IFNDEF WEBASSEMBLY}
      _headerRow.ContentControl.OnClick := OnHeaderClick;
      _headerRow.ContentControl.OnMouseUp := OnHeaderMouseUp;
      {$ELSE}
      _headerRow.ContentControl.OnClick := @OnHeaderClick;
      _headerRow.ContentControl.OnMouseUp := @OnHeaderMouseUp;
      {$ENDIF}

      if _treeLayout.RecalcRequired then
        _treeLayout.RecalcColumnWidthsBasic;

      var flatColumn: IDCTreeLayoutColumn;
      for flatColumn in _treeLayout.FlatColumns do
      begin
        var headerCell: IHeaderCell := THeaderCell.Create(_headerRow, flatColumn);
        {$IFNDEF WEBASSEMBLY}
        headerCell.OnHeaderCellResizeClicked := OnHeaderCellResizeClicked;
        {$ELSE}
        headerCell.OnHeaderCellResizeClicked := @OnHeaderCellResizeClicked;
        {$ENDIF}

        var dummyPerformanceMode: Boolean;
        var dummyManualHeight: Single := -1;
        DoCellLoading(headerCell, False, {var} dummyPerformanceMode, {var} dummyManualHeight);

        if headerCell.Control = nil then
          flatColumn.CreateCellBaseControls(TreeOption_ShowHeaderGrid in _options, headerCell);

        headerCell.Control.Height := _headerRow.Height;

        flatColumn.UpdateCellControlsByRow(headerCell);

        (headerCell.InfoControl as ICaption).Text := CStringToString(flatColumn.Column.Caption);

        DoCellLoaded(headerCell, False, {var} dummyPerformanceMode, {var} dummyManualHeight);

        _headerRow.Cells.Add(flatColumn.Index, headerCell);
      end;

      DoRowLoaded(_headerRow);
    end;

    SetBasicVertScrollBarValues;
    if headerWasVisible <> (_headerRow <> nil) then
    begin
      if not headerWasVisible then
        _content.Height := _content.Height - HeaderHeight else
        _content.Height := Self.Height;

      CalculateScrollBarMax;
    end;
  finally
    Self.EndUpdate;
  end;
end;

procedure TScrollControlWithCells.LoadDefaultDataIntoControl(const Cell: IDCTreeCell; const IsSubProp: Boolean);
begin
  try
    var ctrl: IDCControl;
    var propName: CString;
    var infoClass: TInfoControlClass;

    if not IsSubProp then
    begin
      ctrl := cell.InfoControl;
      propName := cell.Column.PropertyName;
      infoClass := cell.Column.InfoControlClass;
    end
    else
    begin
      ctrl := Cell.SubInfoControl;
      propName := cell.Column.SubPropertyName;
      infoClass := cell.Column.SubInfoControlClass;
    end;

    var cellValue: CObject;
    _localCheckSetInDefaultData := False;
    if ctrl <> nil then
    begin
      cellValue := ProvideCellData(cell, propName, IsSubProp);

      if infoClass = TInfoControlClass.Text then
      begin
        var cellText: CString;
        if DoCellFormatting(cell, False, {var} cellValue) then
          celltext := cellValue.ToString(True) else
          celltext := cell.Column.GetFormattedValue(cell, cellValue);

        (ctrl as ICaption).Text := CStringToString(celltext);
      end
      else if infoClass = TInfoControlClass.CheckBox then
      begin
        DoCellFormatting(cell, False, {var} cellValue);
        (ctrl as IIsChecked).IsChecked := cellValue.GetValue<Boolean>(False);
        _localCheckSetInDefaultData := True;
      end;

      {$IFDEF APP_PLATFORM}
//      Assert(False, ' Code needs checking');
//      if not CString.IsNullOrEmpty(propName) and not formatApplied and (cellValue <> nil) and (_app <> nil) and (cell.Column.InfoControlClass = TInfoControlClass.Text) then
//      begin
//        var item_type := GetItemType;
//        if item_type <> nil then
//        begin
//          var prop := item_type.PropertyByName(propName);
//          var descr: IPropertyDescriptor;
//          if Interfaces.Supports<IPropertyDescriptor>(prop, descr) and (descr.Formatter <> nil) then
//          begin
//            (ctrl as ICaption).Text := CStringToString(descr.Formatter.Format(nil {Context}, cellValue, nil));
//            Exit;
//          end;
//        end;
//      end;
      {$ENDIF}
    end;

    if (cellValue <> nil) then
      cell.LayoutColumn.UpdateColumnContainsData(TColumnContainsData.Yes, cell.Data);

  except
    LoadDefaultDataIntoControl(Cell, IsSubProp);
  end;
end;

procedure TScrollControlWithCells.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;

  // no mouse down is detected
  if not _scrollStopWatch_mouse.IsRunning then
    Exit;

  if _horzScrollBar.Visible then
  begin
    var xDiffSinceLastMove := (X - _mousePositionOnMouseDown.X);
    var xAlreadyMovedSinceMouseDown := _scrollbarPositionsOnMouseDown.X - _horzScrollBar.Value;

    if (xDiffSinceLastMove < -10) or (xDiffSinceLastMove > 10) then
      _horzScrollBar.Value := _horzScrollBar.Value - (xDiffSinceLastMove - xAlreadyMovedSinceMouseDown);
  end;
end;

function TScrollControlWithCells.RadioInsteadOfCheck: Boolean;
begin
  Result := not (TDCTreeOption.MultiSelect in  _options);
end;

function TScrollControlWithCells.GetCellControlData(const Cell: IDCTreeCell): CObject;

  function CheckCtrl(CtrlClass: TInfoControlClass; const Ctrl: IDCControl): CObject;
  begin
    Result := nil;
    if (Ctrl = nil) or not Ctrl.Visible then
      Exit;

    case CtrlClass of
      TInfoControlClass.Text: Exit((Ctrl as ICaption).Text);
      TInfoControlClass.CheckBox: Exit((Ctrl as IIsChecked).IsChecked);
      TInfoControlClass.Button, TInfoControlClass.Glyph:
      begin
        var imgCtrl: IImageControl;
        if interfaces.Supports<IImageControl>(Ctrl, imgCtrl) then
          Exit(imgCtrl.ImageIndex) else
          Exit(nil);
      end;
    end;
  end;

begin
  // heavy method.. DON'T use if it is not needed!!
  Result := CheckCtrl(cell.Column.InfoControlClass, cell.InfoControl);
  if Result = nil then
    Result := CheckCtrl(cell.Column.SubInfoControlClass, cell.SubInfoControl);
end;

procedure TScrollControlWithCells.PrepareCellControls(const Cell: IDCTreeCell);
begin
  if Cell.Control = nil then
    Cell.LayoutColumn.CreateCellBaseControls(TDCTreeOption.ShowVertGrid in _options, Cell);

  Cell.LayoutColumn.UpdateCellControlsByRow(Cell);

  if cell.ExpandButton <> nil then
  begin
    (cell.ExpandButton as TExpandButton).ShowExpanded := not RowIsExpanded(cell.Row.ViewListIndex);
    {$IFNDEF WEBASSEMBLY}
    cell.ExpandButton.OnClick := OnExpandCollapseHierarchy;
    {$ELSE}
    cell.ExpandButton.OnClick := @OnExpandCollapseHierarchy;
    {$ENDIF}
  end;
end;

procedure TScrollControlWithCells.TryLoadDataIntoCellControls(const Cell: IDCTreeCell; LoadDefaultData, PerformanceModeWhileScrolling: Boolean);
begin
  // checkbox selection
  if Cell.Column.IsSelectionColumn then
  begin
    Cell.InfoControl.Visible := _selectionInfo.CanSelect(Cell.Row.DataIndex);
    Cell.LayoutColumn.UpdateColumnContainsData(TColumnContainsData.Yes, Cell.Data {True / False});
  end
  else if LoadDefaultData and (not IsFastScrolling or not PerformanceModeWhileScrolling) then
  begin
    LoadDefaultDataIntoControl(cell, False);
    if not CString.IsNullOrEmpty(cell.Column.SubPropertyName) then
      LoadDefaultDataIntoControl(cell, True);
  end;
end;

procedure TScrollControlWithCells.InnerInitRow(const Row: IDCRow; RowHeightNeedsRecalc: Boolean = False);
begin
  var cell: IDCTreeCell;
  var treeRow := Row as IDCTreeRow;

  // if we do horz lines, we do them on cell controls..
  if (TreeOption_ShowVertGrid in _options) then
    treeRow.ControlAsRowLayout.Sides := [];

  var manualHeight: Single := -1;

  var l: List<IDCTreeLayoutColumn>;
  if _reloadForSpecificColumn <> nil then
  begin
    l := CList<IDCTreeLayoutColumn>.Create;
    l.Add(_reloadForSpecificColumn)
  end else
    l := _treeLayout.FlatColumns;

//  var moreThan3Columns := l.Count > 3;

  var flatColumn: IDCTreeLayoutColumn;
  for flatColumn in l do
  begin
    var performanceModeWhileScrolling := False; //moreThan3Columns and (flatColumn.Column.InfoControlClass <> TInfoControlClass.Text) and not flatColumn.Column.IsSelectionColumn;

    if not treeRow.Cells.TryGetValue(flatColumn.Index, cell) then
    begin
      cell := DoCreateNewCell(Row, flatColumn);
      treeRow.Cells.Add(flatColumn.Index, cell);
    end else
    begin
      if (cell.InfoControl <> nil) then
        cell.InfoControl.Visible := True;
      if (cell.SubInfoControl <> nil) then
        cell.SubInfoControl.Visible := True;
    end;

    var loadDefaultData := DoCellLoading(cell, False, {var} performanceModeWhileScrolling, {var} manualHeight);

    PrepareCellControls(Cell);
    TryLoadDataIntoCellControls(Cell, loadDefaultData, performanceModeWhileScrolling);

    DoCellLoaded(cell, False, {var} performanceModeWhileScrolling, {var} manualHeight);

    Cell.PerformanceModeWhileScrolling := performanceModeWhileScrolling;

    if (flatColumn.ContainsData = TColumnContainsData.Unknown) then
    begin
      var ctrlData := GetCellControlData(Cell);
      if ctrlData <> nil then
        flatColumn.UpdateColumnContainsData(TColumnContainsData.Yes, ctrlData)
    end;
  end;

  if manualHeight <> -1 then
    Row.Control.Height := Ceil(manualHeight)
  else begin
    // only get cached row height if row height is correctly calculated withouth scrollbar scrolling
    var cachedHeight := _view.CachedRowHeight(Row.ViewListIndex);
    if cachedHeight = -1 then
      Row.Control.Height := CalculateRowHeight(Row as IDCTreeRow) else
      Row.Control.Height := cachedHeight;
  end;

  inherited;
end;

function TScrollControlWithCells.CalculateCellWidth(const LayoutColumn: IDCTreeLayoutColumn; const Cell: IDCTreeCell): Single;
begin
  Assert(LayoutColumn.Column.WidthType = TDCColumnWidthType.AlignToContent);

  if not Cell.IsHeaderCell and (LayoutColumn.Column.InfoControlClass <> TInfoControlClass.Text) and (LayoutColumn.Column.SubInfoControlClass <> TInfoControlClass.Text) then
  begin
    Result := 0;
    if Cell.InfoControl <> nil then
      Result := Cell.InfoControl.Width + (2*_cellLeftRightPadding);

    if Cell.SubInfoControl <> nil then
      Result := CMath.Max(Result, Cell.SubInfoControl.Width + (2*_cellLeftRightPadding));

    if Result = 0 then
    begin
      if Cell.Control <> nil then
        Result := Cell.Control.Width else
        Result := 35;
    end;

    Exit;
  end;

  Result := 0;
  if Cell.InfoControl = nil then Exit;

  if Cell.IsHeaderCell or (LayoutColumn.Column.InfoControlClass = TInfoControlClass.Text) then
  begin
    var txt := Cell.InfoControl as ITextControl;

    var customMargins := 0.0;
    if (Cell.InfoControl.Margins.Left > 0) or (Cell.InfoControl.Margins.Right > 0) then
      customMargins := Cell.InfoControl.Margins.Left + Cell.InfoControl.Margins.Right;

    Result := txt.TextWidthWithPadding + (2*_cellLeftRightPadding) + customMargins;
  end;

  if not Cell.IsHeaderCell and (Cell.Column.SubInfoControlClass = TInfoControlClass.Text) then
  begin
    var subTxt := Cell.SubInfoControl as ITextControl;

    var customMargins := 0.0;
    if (Cell.SubInfoControl.Margins.Left > 0) or (Cell.SubInfoControl.Margins.Right > 0) then
      customMargins := Cell.SubInfoControl.Margins.Left + Cell.SubInfoControl.Margins.Right;

    var subWidth := subTxt.TextWidthWithPadding + (2*_cellLeftRightPadding) + customMargins;

    Result := CMath.Max(Result, subWidth);
  end;

  if Cell.IsHeaderCell then
  begin
    var headerCell := Cell as IHeaderCell;
    if (headerCell.SortControl <> nil) then
      Result := Result + headerCell.SortControl.Width + (2*_cellTopBottomPadding);

    if (headerCell.FilterControl <> nil) then
      Result := Result + headerCell.FilterControl.Width + (2*_cellTopBottomPadding);
  end
  else begin
    if Cell.ExpandButton <> nil then
      Result := Result + Cell.ExpandButton.Width + _cellLeftRightPadding;

    // give a little extra space to editable AlignToContent columns
    // for example with dropdown, it has space to drop down itself + scrollbar width
    if not Cell.Column.ReadOnly and not (TDCTreeOption.ReadOnly in _options) then
      Result := Result + 15;
  end;
end;

function TScrollControlWithCells.CalculateCellControlHeight(const Cell: IDCTreeCell; GoSub: Boolean): Single;
begin
  var ctrl: IDCControl;
  var infoCtrlClass: TInfoControlClass;
  var bounds: TRectF;

  if not GoSub then begin
    ctrl := Cell.InfoControl;
    infoCtrlClass := Cell.Column.InfoControlClass;
    bounds := Cell.CustomInfoControlBounds;
  end else begin
    ctrl := Cell.SubInfoControl;
    infoCtrlClass := Cell.Column.SubInfoControlClass;
    bounds := Cell.CustomSubInfoControlBounds;
  end;

  if Cell.Column.Visualisation.IgnoreHeightByRowCalculation or (ctrl = nil) or not ctrl.Visible then
    Exit(0);

  if not bounds.IsEmpty then
    Exit(bounds.Height);

  if infoCtrlClass = TInfoControlClass.Text then
  begin
    var txt := ctrl as ITextControl;
    if Length(txt.Text) = 0 then
      Exit(0);

    Result := txt.TextHeight;
  end else
    Result := ctrl.Height;
end;

function TScrollControlWithCells.CalculateRowControlWidth(const ForceRealContentWidth: Boolean): Single;
begin
  if ForceRealContentWidth then
    Exit(inherited);

  Result := 0.0;
  if (_treeLayout <> nil) and (_treeLayout.FlatColumns.Count > 0) then
  begin
    var lastFlatColumn := _treeLayout.FlatColumns[_treeLayout.FlatColumns.Count - 1];
    Result := CMath.Min(inherited, lastFlatColumn.Left + lastFlatColumn.Width);
  end;
end;

function TScrollControlWithCells.CalculateRowHeight(const Row: IDCTreeRow): Single;
begin
  if _rowHeightFixed > 0 then
    Exit(_rowHeightFixed);

  // always do a recheck if row is scrolling into view again
  // dataitem can be changed without us knowing
  if not Row.IsScrollingIntoView then
  begin
    var calculatedheight := _view.CachedRowHeight(Row.ViewListIndex);
    if calculatedheight <> -1 then
      Exit(calculatedheight);
  end;

  Result := 0.0;
  var cell: IDCTreeCell;
  for cell in Row.Cells.Values do
    if not cell.Column.Visualisation.IgnoreHeightByRowCalculation then
    begin
      var h := CalculateCellControlHeight(Cell, False) + CalculateCellControlHeight(Cell, True);
      Result := CMath.Max(Result, h);
    end;

  Result := Ceil(Result + 2*_cellTopBottomPadding);

  if (_rowHeightMax > 0) and (_rowHeightMax < Result) then
    Result := _rowHeightMax;
end;

procedure TScrollControlWithCells.GetSortAndFilterImages(out ImageList: TCustomImageList; out FilterIndex, SortAscIndex, SortDescIndex: Integer);
begin
  {$IFNDEF WEBASSEMBLY}
  if _frmHeaderPopupMenu = nil then
    _frmHeaderPopupMenu := TfrmFMXPopupMenuDataControl.Create(Self);

  var popUpFrm := (_frmHeaderPopupMenu as TfrmFMXPopupMenuDataControl);
  ImageList := popUpFrm.ImageListPopup;
  FilterIndex := 4;
  SortAscIndex := 0;
  SortDescIndex := 1;
  {$ELSE}
  raise NotImplementedException.Create('procedure TScrollControlWithCells.GetSortAndFilterImages(out ImageList: TCustomImageList; out FilterIndex, SortAscIndex, SortDescIndex: Integer)');
  {$ENDIF}
end;

procedure TScrollControlWithCells.InitLayout;
begin
  if (_view <> nil) and (_columns.Count = 0) then
    CreateDefaultColumns;

  // if during reading the component the "OptionsChanged" came before the "loading of columns"
  if (_autoMultiSelectColumn <> nil) then
  begin
    var clmn: IDCTreeColumn;
    for clmn in _columns do
      if clmn.IsSelectionColumn then
      begin
        _autoMultiSelectColumn := nil;
        Break;
      end;    
  end;

  if _treeLayout = nil then
    _treeLayout := TDCTreeLayout.Create(Self) else
    _treeLayout.UpdateLayoutColumnList;
end;

procedure TScrollControlWithCells.CreateDefaultColumns; //(const AList: ITreeColumnList);
var
  typeData: &Type;
  propInfo: _PropertyInfo;
  i : Integer;
  col : IDCTreeColumn;
//  dummy: CObject;

  function AssignDefaultColumn: IDCTreeColumn;
  begin
    Result := TDCTreeColumn.Create;
    // Result.TreeControl := Self;
    Result.WidthSettings.WidthType := TDCColumnWidthType.AlignToContent;
    Result.WidthSettings.WidthMax := 400;
    _columns.Add(Result);
  end;

begin
  Assert(_columns.Count = 0);
  _defaultColumnsGenerated := True;

  if ViewIsDataModelView then
  begin
    var clmns := GetDataModelView.DataModel.Columns;

    for i := 0 to clmns.Count - 1 do
    begin
      col := AssignDefaultColumn;
      col.PropertyName := clmns[i].Name;
      col.Caption := col.PropertyName;
    end;
  end else
  begin
    typeData := GetItemType;

    if not typeData.IsUnknown {and not typeData.Equals(_ColumnPropertiesTypeData)} then
    begin
      BeginUpdate;
      try
        var props := typeData.GetProperties;

        for i := 0 to High(props) do
        begin
          propInfo := props[i];
          try
            col := AssignDefaultColumn;
            col.PropertyName := propInfo.Name;
            col.Caption := propInfo.Name;
          except
            ; // Some properties may not work (are not supported)
          end;
        end;
      finally
        EndUpdate;
      end;
    end;
  end;

  if _Columns.Count = 0 then
  begin
    col := AssignDefaultColumn;
    col.PropertyName := COLUMN_SHOW_DEFAULT_OBJECT_TEXT;
    col.Caption := 'item';
  end;
end;

procedure TScrollControlWithCells.DoContentResized(WidthChanged, HeightChanged: Boolean);
begin
  if WidthChanged then
  begin
    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    if _autoFitColumns and (_view <> nil) then
      ResetView;
  end;

  if HeightChanged then
    _frozenRectLine.Height := _content.Height;

  inherited;
end;

procedure TScrollControlWithCells.DoCollapseOrExpandRow(const ViewListIndex: Integer; DoExpand: Boolean);
begin
  inherited;
  UpdatePositionAndWidthCells;
end;

procedure TScrollControlWithCells.OnExpandCollapseHierarchy(Sender: TObject);

  procedure DoCollapseOrExpandRowQueued([weak] View: IBaseInterface; ViewListIndex: Integer; SetExpanded: Boolean);
  begin
    // await full mouse click
    TThread.ForceQueue(nil, procedure
    begin
      if View = nil then
        Exit;

      _treeLayout.ResetColumnDataAvailability(False);
      DoCollapseOrExpandRow(ViewListIndex, SetExpanded);
    end);
  end;

begin
  var viewListIndex := (Sender as TControl).Tag;

  var drv: IDataRowView;
  if not _view.GetViewList[viewListIndex].TryAsType<IDataRowView>(drv) then
    Exit;

  var setExpanded := not drv.DataView.IsExpanded[drv.Row];

  var row := _view.GetActiveRowIfExists(viewListIndex) as IDCTreeRow;
  var selInfo := _selectionInfo as ITreeSelectionInfo;

  var ix: Integer;
  for ix := 0 to _treeLayout.FlatColumns.Count - 1 do
  begin
    var flatColumn := _treeLayout.FlatColumns[ix];
    if row.Cells[flatColumn.Index].ExpandButton = Sender then
    begin
      selInfo.BeginUpdate;
      try
        selInfo.SelectedLayoutColumn := _treeLayout.FlatColumns[ix].Index;
      finally
        selInfo.EndUpdate(True);
      end;

      Break;
    end;
  end;

  Self.Current := ViewListIndex;
  DoCollapseOrExpandRowQueued(_view, ViewListIndex, SetExpanded);
end;

function TScrollControlWithCells.OnGetCellDataForSorting(const Cell: IDCTreeCell): CObject;
begin
  AtomicIncrement(_isSortingOrFiltering);
  try
    if Cell.Column.SortType = TSortType.PropertyValue then
      Exit(Cell.Column.ProvideCellData(cell, cell.Column.PropertyName))
    else if Cell.Column.SortType = TSortType.RowComparer then
      Exit(Cell.Row.DataItem);

    var dummyPerfMode: Boolean;
    var dummyHeightVar: Single;
    var loadDefaultData := DoCellLoading(Cell, True, dummyPerfMode, dummyHeightVar);

    if loadDefaultData then
    begin
      Result := Cell.Column.ProvideCellData(cell, cell.Column.PropertyName);
      if not DoCellFormatting(cell, True, {var} Result) and (Cell.Column.SortType = TSortType.Displaytext) then
        Result := Cell.Column.GetFormattedValue(cell, Result);
    end else
    begin
      DoCellLoaded(Cell, True, dummyPerfMode, dummyHeightVar);
      Result := (Cell.InfoControl as ICaption).Text;
    end;

    Exit(Result);

//    if Cell.Column.SortType = TSortType.Displaytext then
//      Exit(Result)
//    else if Cell.Column.SortType = TSortType.CellData then
//      // KV: 10/11/2025 -> This line should also return 'Result'
//      Exit(cell.Data)
//    else if Cell.Column.SortType = TSortType.ColumnCellComparer then
//    begin
//      if cell.Data <> nil then
//        Exit(cell.Data)
//      else if cellValue <> nil then
//        Exit(cellValue)
//      else
//        Exit(Result);
//    end;
  finally
    AtomicDecrement(_isSortingOrFiltering);
  end;
end;

procedure TScrollControlWithCells.set_AutoCenterTree(const Value: Boolean);
begin
  if _autoCenterTree <> Value then
  begin
    _autoCenterTree := Value;

    if _realignState = TRealignState.RealignDone then
      ExecuteAfterRealignOnly(True);
  end;
end;

procedure TScrollControlWithCells.set_AutoFitColumns(const Value: Boolean);
begin
  if _autoFitColumns <> Value then
  begin
    _autoFitColumns := Value;

    if not Value then
      _autoExtraColumnSizeMax := -1;

    if _treeLayout <> nil then
      ExecuteAfterRealignOnly(True);
  end;
end;

procedure TScrollControlWithCells.set_CellLeftRightPadding(const Value: Single);
begin
  _cellLeftRightPadding := Value;
end;

procedure TScrollControlWithCells.set_CellTopBottomPadding(const Value: Single);
begin
  _cellTopBottomPadding := Value;
end;

procedure TScrollControlWithCells.set_HeaderHeight(const Value: Single);
begin
  if not SameValue(_headerHeight, Value) then
  begin
    _headerHeight := Value;

    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    RefreshControl;
  end;
end;

procedure TScrollControlWithCells.set_headerTextBottomMargin(const Value: Single);
begin
  if not SameValue(_headerTextBottomMargin, Value) then
  begin
    _headerTextBottomMargin := Value;

    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    RefreshControl;
  end;
end;

procedure TScrollControlWithCells.set_headerTextTopMargin(const Value: Single);
begin
  if not SameValue(_headerTextTopMargin, Value) then
  begin
    _headerTextTopMargin := Value;

    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    RefreshControl;
  end;
end;

procedure TScrollControlWithCells.set_AutoExtraColumnSizeMax(const Value: Single);
begin
  if not SameValue(_autoExtraColumnSizeMax, Value) then
  begin
    _autoExtraColumnSizeMax := Value;

    if _autoExtraColumnSizeMax < 0 then
      _autoExtraColumnSizeMax := -1;

    _autoFitColumns := _autoExtraColumnSizeMax >= 0;

    if _treeLayout <> nil then
      _treeLayout.ForceRecalc;

    RefreshControl;
  end;
end;

{ TDCTreeColumnList }

constructor TDCTreeColumnList.Create(const Owner: IColumnsControl);
begin
  inherited Create;
  SaveTypeData := True;
  _treeControl := Owner;
end;

constructor TDCTreeColumnList.Create(const Owner: IColumnsControl; const col: IEnumerable<IDCTreeColumn>);
begin
  inherited Create;
  var c: IDCTreeColumn;
  for c in col do
    Add(c);

  SaveTypeData := True;
  _treeControl := Owner;
end;

destructor TDCTreeColumnList.Destroy;
begin

  inherited;
end;

function TDCTreeColumnList.FindColumnByCaption(const Caption: CString): IDCTreeColumn;
var
  i: Integer;
begin
  i := FindIndexByCaption(Caption);
  if i <> -1 then
    Exit(Self[i]);

  Exit(nil);
end;

function TDCTreeColumnList.FindColumnByPropertyName(const Name: CString): IDCTreeColumn;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  begin
    if CString.Equals(Self[i].PropertyName, Name) then
      Exit(Self[i]);
  end;

  Result := nil;
end;

function TDCTreeColumnList.FindColumnByTag(const Value: CObject): IDCTreeColumn;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  begin
    if CObject.Equals(Self[i].Tag, Value) then
      Exit(Self[i]);
  end;

  Result := nil;
end;

function TDCTreeColumnList.FindIndexByCaption(const Caption: CString): Integer;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  begin
    if not CString.IsNullOrEmpty(Caption) and CString.Equals(Self[i].Caption, Caption) then
      Exit(i);
  end;

  Result := -1;
end;

function TDCTreeColumnList.FindIndexByTag(const Tag: CObject): Integer;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  begin
    if (Tag <> nil) and CObject.Equals(Self[i].Tag, Tag) then
      Exit(i);
  end;

  Result := -1;
end;

function TDCTreeColumnList.get_TreeControl: IColumnsControl;
begin
  Result := _treeControl;
end;

procedure TDCTreeColumnList.InsertItem(index: Integer; const value: IDCTreeColumn);
begin
  Value.TreeControl := _treeControl;
  inherited;
end;

function TDCTreeColumnList.ColumnLayoutToJSON: TJSONObject;
var
  arr: TJSONArray;
  co: TJSONObject;
  column: IDCTreeColumn;
  i: Integer;
  jo: TJSONObject;

begin
  jo := TJSONObject.Create;
  arr := TJSONArray.Create;

  for i := 0 to Count - 1 do
  begin
    column := Self[i];

    if CString.IsNullOrEmpty(column.Caption) then
      continue;

    co := TJSONObject.Create;

    co.AddPair('Property', CStringToString(column.PropertyName));
    co.AddPair('Caption', CStringToString(column.Caption));

    if column.CustomHidden and not column.Frozen then
      co.AddPair('CustomHidden', TJSONTrue.Create) else
      co.AddPair('CustomHidden', TJSONFalse.Create);
    co.AddPair('CustomWidth', TJSONNumber.Create(column.CustomWidth));

    if column.ReadOnly then
      co.AddPair('ReadOnly', TJSONTrue.Create) else
      co.AddPair('ReadOnly', TJSONFalse.Create);
    if column is TDCTreeCheckboxColumn then
      co.AddPair('Checkbox', TJSONTrue.Create) else
      co.AddPair('Checkbox', TJSONFalse.Create);
    co.AddPair('Index', TJSONNumber.Create(Self.IndexOf(column)));

    if (column.Tag <> nil) then
    begin
      var p: _PropertyInfo;
      {$IFNDEF WEBASSEMBLY}
      if column.Tag.IsInterface and Interfaces.Supports<_PropertyInfo>(column.Tag, p) then
        co.AddPair('Tag', p.OwnerType.Name + '.' + p.Name)
      else if not CString.IsNullOrEmpty(column.Tag.ToString) then
        co.AddPair('Tag', column.Tag.ToString);
      {$ELSE}
      if column.Tag.IsInterface and Interfaces.Supports<_PropertyInfo>(column.Tag, p) then
        co.AddPair('Tag', p.DeclaringType.Name + '.' + p.Name)
      else if not CString.IsNullOrEmpty(column.Tag.ToString) then
        co.AddPair('Tag', column.Tag.ToString);
      {$ENDIF}
    end;

    if (column.InfoControlClass <> TInfoControlClass.Text) then
      co.AddPair('InfoControlClass', TJSONNumber.Create(Integer(column.InfoControlClass)));
    co.AddPair('SubPropertyname', CStringToString(column.SubPropertyName));
    if (column.SubInfoControlClass <> TInfoControlClass.Custom) then
      co.AddPair('SubinfoControlClass', TJSONNumber.Create(Integer(column.SubInfoControlClass)));

    arr.AddElement(co);
  end;

  jo.AddPair('columns', arr);
  Exit(jo);
end;

procedure TDCTreeColumnList.RestoreColumnLayoutFromJSON(const Value: TJSONObject);
var
  arr: TJSONArray;
  caption: string;
  checkbox: Boolean;
  col: TJSONObject;
  column: IDCTreeColumn;
  tag_string: string;
  index: Integer;
  jv: TJSONValue;
  n: Integer;
  propertyname, subPropertyname: string;
  customHidden: Boolean;
  customWidth: Single;
  &readonly: Boolean;
  infoCtrlClass, subinfoCtrlClass: Integer;

  procedure AddColumnToProjectControl;
  begin
    column := TDCTreeColumn.Create;
    column.TreeControl := _treeControl;
    column.IsCustomColumn := True;
    column.Caption := caption;
    column.PropertyName := StringToCString(propertyname);
    column.Tag := StringToCString(tag_string);

    column.InfoControlClass := TInfoControlClass(infoCtrlClass);

    column.SubControlSettings.SubPropertyName := subPropertyname;
    column.SubControlSettings.SubInfoControlClass := TInfoControlClass(subinfoCtrlClass);

    column.WidthSettings.WidthType := TDCColumnWidthType.AlignToContent;
    column.Visualisation.ReadOnly := readonly;

    column.SortAndFilter.ShowSortMenu := True;
    column.SortAndFilter.ShowFilterMenu := True;
    column.SortAndFilter.Sort := TSortType.CellData;

    column.Visualisation.AllowHide := True;
    column.Visualisation.AllowResize := True;
    column.CustomHidden := customHidden;
    column.CustomWidth := customWidth;

    Insert(Index, column);
  end;

begin
  if Count > 0 then
  begin
    var clmnIx: Integer;
    for clmnIx := Count - 1 downto 0 do
      if get_Item(clmnIx).IsCustomColumn then
        RemoveAt(clmnIx);
    
  end;
    
  if (Value <> nil) and Value.TryGetValue<TJSONArray>('columns', arr) then
  begin
    for jv in arr do
    begin
      col := jv as TJSONObject;

      if not col.TryGetValue<string>('Caption', caption) or CString.IsNullOrEmpty(caption) then continue;
      if not col.TryGetValue<string>('Tag', tag_string) then tag_string := '';

      if not col.TryGetValue<string>('Property', propertyName) then propertyName := '';
      if not col.TryGetValue<Integer>('InfoControlClass', infoCtrlClass) then infoCtrlClass := Integer(TInfoControlClass.Text);

      if not col.TryGetValue<string>('SubPropertyname', subPropertyname) then subPropertyname := '';
      if not col.TryGetValue<Integer>('SubinfoControlClass', subinfoCtrlClass) then subinfoCtrlClass := Integer(TInfoControlClass.Custom);

      if not col.TryGetValue<Boolean>('CustomHidden', customHidden) then customHidden := False;
      if not col.TryGetValue<Single>('CustomWidth', customWidth) then customWidth := -1;

      if not col.TryGetValue<Boolean>('ReadOnly', readonly) then readonly := False;
      if not col.TryGetValue<Boolean>('Checkbox', checkbox) then checkbox := False;
      if not col.TryGetValue<Integer>('Index', index) then index := -1;

      n := FindIndexByCaption(caption);
      if n = -1 then
      begin
        AddColumnToProjectControl;
      end
      else
      begin
        column := Self[n];
        if column.Visible and not column.CustomHidden and (index >= 0) and (index <> n) then
        begin
          RemoveAt(n);
          index := CMath.Min(index, Count);
          Insert(index, column);
        end;
      end;

      column.CustomHidden := customHidden and column.AllowHide;
      column.CustomWidth := customWidth;
    end;
  end;
end;

{ TDCTreeColumn }

function TDCTreeColumn.Clone: IDCTreeColumn;
begin
  Result := CreateInstance;

  Result.TreeControl := _treeControl;
  Result.caption := _caption;
  Result.propertyName := _propertyName;
  Result.tag := _tag;

  Result.SortAndFilter := _SortAndFilter.Clone;
  Result.WidthSettings := _WidthSettings.Clone;
  Result.SubControlSettings := _SubControlSettings.Clone;
  Result.Visualisation := _Visualisation.Clone;
  Result.Hierarchy := _Hierarchy.Clone;

  Result.InfoControlClass := _infoControlClass;
  Result.CustomWidth := _customWidth;
  Result.CustomHidden := _customHidden;
  Result.IsCustomColumn := _isCustomColumn;

  Result.formatProvider := _formatProvider;
end;

constructor TDCTreeColumn.Create;
begin
  inherited Create;

  _infoControlClass := TInfoControlClass.Text;
  _customWidth := -1;

  _widthSettings := TDCColumnWidthSettings.Create;
  _sortAndFilter := TDCColumnSortAndFilter.Create;
  _subControlSettings := TDCColumnSubControlSettings.Create;
  _visualisation := TDCColumnVisualisation.Create;
  _hierarchy := TDCColumnHierarchy.Create;
end;

function TDCTreeColumn.CreateInstance: IDCTreeColumn;
begin
  Result := TDCTreeColumn.Create;
end;

destructor TDCTreeColumn.Destroy;
begin

  inherited;
end;

function TDCTreeColumn.get_AllowHide: Boolean;
begin
  Result := _visualisation.AllowHide;
end;

function TDCTreeColumn.get_AllowResize: Boolean;
begin
  Result := _visualisation.AllowResize;
end;

function TDCTreeColumn.get_Caption: CString;
begin
  Result := _caption;
end;

function TDCTreeColumn.get_CustomHidden: Boolean;
begin
  Result := _customHidden;
end;

function TDCTreeColumn.get_CustomWidth: Single;
begin
  Result := _customWidth;
end;

function TDCTreeColumn.get_Format: CString;
begin
  Result := _visualisation.Format;
end;

function TDCTreeColumn.get_FormatProvider: IFormatProvider;
begin
  Result := _formatProvider;
end;

function TDCTreeColumn.get_Frozen: Boolean;
begin
  Result := _visualisation.Frozen;
end;

function TDCTreeColumn.get_Hierarchy: IDCColumnHierarchy;
begin
  Result := _hierarchy;
end;

function TDCTreeColumn.get_Indent: Single;
begin
  Result := _hierarchy.Indent;
end;

function TDCTreeColumn.get_InfoControlClass: TInfoControlClass;
begin
  Result := _infoControlClass;
end;

function TDCTreeColumn.get_IsCustomColumn: Boolean;
begin
  Result := _isCustomColumn;
end;

function TDCTreeColumn.get_PropertyName: CString;
begin
  Result := _propertyName;
end;

function TDCTreeColumn.get_ReadOnly: Boolean;
begin
  Result := _visualisation.ReadOnly;
end;

function TDCTreeColumn.get_Selectable: Boolean;
begin
  Result := _visualisation.Selectable;
end;

function TDCTreeColumn.get_ShowFilterMenu: Boolean;
begin
  Result := _SortAndFilter.ShowFilterMenu;
end;

function TDCTreeColumn.get_ShowHierarchy: Boolean;
begin
  Result := _hierarchy.ShowHierarchy;
end;

function TDCTreeColumn.get_ShowSortMenu: Boolean;
begin
  Result := _SortAndFilter.ShowSortMenu;
end;

function TDCTreeColumn.get_SortType: TSortType;
begin
  Result := _SortAndFilter.Sort;
end;

function TDCTreeColumn.get_SubControlSettings: IDCColumnSubControlSettings;
begin
  Result := _subControlSettings;
end;

function TDCTreeColumn.get_SubInfoControlClass: TInfoControlClass;
begin
  Result := _subControlSettings.SubInfoControlClass;
end;

function TDCTreeColumn.get_SubPropertyName: CString;
begin
  Result := _subControlSettings.SubPropertyName;
end;

function TDCTreeColumn.get_Tag: CObject;
begin
  Result := _tag;
end;

function TDCTreeColumn.get_TreeControl: IColumnsControl;
begin
  Result := _treeControl;
end;

function TDCTreeColumn.get_SortAndFilter: IDCColumnSortAndFilter;
begin
  Result := _SortAndFilter;
end;

function TDCTreeColumn.get_Visible: Boolean;
begin
  Result := _visualisation.Visible;
end;

function TDCTreeColumn.get_Visualisation: IDCColumnVisualisation;
begin
  Result := _visualisation;
end;

function TDCTreeColumn.get_Width: Single;
begin
  Result := _widthSettings.Width;
end;

function TDCTreeColumn.get_WidthMax: Single;
begin
  Result := _widthSettings.WidthMax;
end;

function TDCTreeColumn.get_WidthMin: Single;
begin
  Result := _widthSettings.WidthMin;
end;

function TDCTreeColumn.get_WidthSettings: IDCColumnWidthSettings;
begin
  Result := _widthSettings;
end;

function TDCTreeColumn.get_WidthType: TDCColumnWidthType;
begin
  Result := _widthSettings.WidthType;
end;

function TDCTreeColumn.HasPropertyAttached: Boolean;
begin
  Result := not CString.IsNullOrEmpty(_propertyName) or
    ((_tag <> nil) and _tag.IsInterface and interfaces.Supports<_PropertyInfo>(_tag));
end;

function TDCTreeColumn.IsSelectionColumn: Boolean;
begin
  Result := False;
end;

function TDCTreeColumn.GetFormattedValue(const Cell: IDCTreeCell; const CellValue: CObject): CString;
begin
  Result := nil;

  if CellValue <> nil then
  begin
    if CellValue.IsDateTime and CDateTime(CellValue).Equals(CDateTime.MinValue) then
      Exit;

    if not CString.IsNullOrEmpty(get_format) or (_formatProvider <> nil) then
    begin
      var formatSpec: CString;
      if not CString.IsNullOrEmpty(get_format) then
        formatSpec := CString.Concat('{0:', get_format, '}') else
        formatSpec := '{0}';

      Result := CString.Format(_formatProvider, formatSpec, [CellValue]);
    end else
      Result := CellValue.ToString;
  end;
end;

function TDCTreeColumn.ProvideCellData(const Cell: IDCTreeCell; const PropName: CString; IsSubProp: Boolean = False): CObject;
begin
//  // Just in case properties have not been initialized
//  InitializeColumnPropertiesFromColumns;

//  if Cell.Index > 1 then
//    Exit('Pizza');

  var data: CObject := nil;
  if not CString.IsNullOrEmpty(PropName) then
  begin
    var drv: IDataRowView;
    var dr: IDataRow;
    var rowCtrl: IRowsControl;

    if CString.Equals(PropName, COLUMN_SHOW_DEFAULT_OBJECT_TEXT) then
      data := Cell.Row.DataItem
    else if interfaces.Supports<IRowsControl>(_treeControl, rowCtrl) and rowCtrl.ViewIsDataModelView then
    begin
      if Cell.Row.DataItem.TryAsType<IDataRowView>(drv) then
        data := rowCtrl.GetDataModel.GetPropertyValue(PropName, drv.Row)
      else if Cell.Row.DataItem.TryAsType<IDataRow>(dr) then
        data := rowCtrl.GetDataModel.GetPropertyValue(PropName, dr);
    end
    else begin
      var aType := _treeControl.GetItemType;
      var prop: _PropertyInfo := nil;
      var resetProp := _cachedType <> aType;
      _cachedType := aType;

      if not IsSubProp then
        prop := _cachedProp
      else begin
        if not CString.Equals(PropName, _subPropertyName) then
        begin
          _subPropertyName := PropName;
          _cachedSubProp := nil;
        end;

        prop := _cachedSubProp;
      end;

      if resetProp or (prop = nil) then
      begin
        prop := _cachedType.PropertyByName(PropName);

        // KV 06/11: Don't want an error when property does not exist.
        //        if prop = nil then
        //          Assert(prop <> nil, 'Please make sure property is published and {M+} is assigned');
        if prop = nil then
          Exit;

        if not IsSubProp then
          _cachedProp := prop else
          _cachedSubProp := prop;
      end;

      data := prop.GetValue(Cell.Row.DataItem, []);
    end;
  end
  else if not Cell.Column.HasPropertyAttached and (Cell.Column.InfoControlClass = TInfoControlClass.CheckBox) then
    data := (Cell.InfoControl as IIsChecked).IsChecked;

  if not IsSubProp then
    Cell.Data := data else
    Cell.SubData := data;

  Exit(data);
end;

procedure TDCTreeColumn.set_Caption(const Value: CString);
begin
  _caption := Value;
end;

procedure TDCTreeColumn.set_CustomHidden(const Value: Boolean);
begin
  if _customHidden <> Value then
  begin
    _customHidden := Value;
    _treeControl.ColumnVisibilityChanged(Self, True);
  end;
end;

procedure TDCTreeColumn.set_CustomWidth(const Value: Single);
begin
  _customWidth := Value;
end;

procedure TDCTreeColumn.set_FormatProvider(const Value: IFormatProvider);
begin
  _formatProvider := Value;
end;

procedure TDCTreeColumn.set_Hierarchy(const Value: IDCColumnHierarchy);
begin
  _hierarchy := Value;
end;

function TDCTreeColumn.get_UserDefinedWidth: Single;
begin
  Result := _userDefinedWidth;
end;

procedure TDCTreeColumn.set_UserDefinedWidth(const Value: Single);
begin
  if _userDefinedWidth <> Value then
  begin
    _userDefinedWidth := Value;
//    OnPropertyChanged('UserDefinedWidth');
  end;
end;

procedure TDCTreeColumn.set_InfoControlClass(const Value: TInfoControlClass);
begin
  _infoControlClass := Value;
end;

procedure TDCTreeColumn.set_IsCustomColumn(const Value: Boolean);
begin
  _isCustomColumn := Value;
end;

procedure TDCTreeColumn.set_PropertyName(const Value: CString);
begin
  if not CString.Equals(_propertyName, Value) then
  begin
    _propertyName := Value;
    _cachedProp := nil;
  end;
end;

procedure TDCTreeColumn.set_SortAndFilter(const Value: IDCColumnSortAndFilter);
begin
  _sortAndFilter := Value;
end;

procedure TDCTreeColumn.set_SubControlSettings(const Value: IDCColumnSubControlSettings);
begin
  _subControlSettings := Value;
end;

procedure TDCTreeColumn.set_Tag(const Value: CObject);
begin
  _tag := Value;
end;

procedure TDCTreeColumn.set_TreeControl(const Value: IColumnsControl);
begin
  _treeControl := Value;
end;

procedure TDCTreeColumn.set_Visualisation(const Value: IDCColumnVisualisation);
begin
  _visualisation := Value;
end;

procedure TDCTreeColumn.set_WidthSettings(const Value: IDCColumnWidthSettings);
begin
  _widthSettings := Value;
end;

{ TDataControlWaitForRepaintInfo }

procedure TDataControlWaitForRepaintInfo.ColumnsChanged;
begin
  _viewStateFlags := _viewStateFlags + [TTreeViewState.ColumnsChanged];

  if _owner.IsInitialized then
    _owner.RefreshControl(True);
end;

function TDataControlWaitForRepaintInfo.get_CellSizeUpdates: Dictionary<Integer, Single>;
begin
  Result := _cellSizeUpdates;
end;

function TDataControlWaitForRepaintInfo.get_ViewStateFlags: TTreeViewStateFlags;
begin
  Result := _viewStateFlags;
end;

procedure TDataControlWaitForRepaintInfo.set_CellSizeUpdates(const Value: Dictionary<Integer, Single>);
begin
  _cellSizeUpdates := Value;
  _viewStateFlags := _viewStateFlags + [TTreeViewState.ColumnSizeChanged];
end;

procedure TDataControlWaitForRepaintInfo.set_ViewStateFlags(const Value: TTreeViewStateFlags);
begin
  _viewStateFlags := Value;
  if _owner.IsInitialized then
    _owner.RefreshControl;
end;

{ TTreeLayoutColumn }

constructor TTreeLayoutColumn.Create(const AColumn: IDCTreeColumn; const ColumnControl: IColumnsControl);
begin
  inherited Create;
  _column := AColumn;
  _treeControl := ColumnControl;
  _index := -1;
  _containsData := TColumnContainsData.Unknown;
  _calculatedHorzAlign := TTextAlign.Leading;
  _calculatedVertAlign := TTextAlign.Center;

  _hideColumnInView := not AColumn.Visible;
end;

procedure TTreeLayoutColumn.UpdateCellControlsByRow(const Cell: IDCTreeCell);
begin
  if Cell.IsHeaderCell then
  begin
    var headerCell := Cell as IHeaderCell;

    var imgList: TCustomImageList := nil;
    var filterIndex: Integer := -1;
    var sortAscIndex: Integer := -1;
    var sortDescIndex: Integer := -1;

    if (_activeFilter <> nil) or (_activeSort <> nil) then
      _treeControl.GetSortAndFilterImages({out} imgList, {out} filterIndex, {out} sortAscIndex, {out} sortDescIndex);

    if (_activeFilter <> nil) and (headerCell.FilterControl = nil) then
    begin
      headerCell.FilterControl := TGlyph.Create(Cell.Control);
      headerCell.FilterControl.Align := TAlignLayout.None;
      headerCell.FilterControl.HitTest := False;
      headerCell.FilterControl.Width := HEADER_IMG_SIZE;
      headerCell.FilterControl.Height := HEADER_IMG_SIZE;
      (headerCell.FilterControl as TGlyph).Images := imgList;
      (headerCell.FilterControl as TGlyph).ImageIndex := filterIndex;

      Cell.Control.AddObject(headerCell.FilterControl);
    end
    else if (_activeFilter = nil) and (headerCell.FilterControl <> nil) then
    begin
      headerCell.FilterControl.Free;
      headerCell.FilterControl := nil;
    end;

    if (_activeSort <> nil) then
    begin
      if (headerCell.SortControl = nil) then
      begin
        headerCell.SortControl := TGlyph.Create(Cell.Control);
        headerCell.SortControl.Align := TAlignLayout.None;
        headerCell.SortControl.HitTest := False;
        headerCell.SortControl.Width := HEADER_IMG_SIZE;
        headerCell.SortControl.Height := HEADER_IMG_SIZE;
        (headerCell.SortControl as TGlyph).Images := imgList;
        Cell.Control.AddObject(headerCell.SortControl);
      end;

      (headerCell.SortControl as TGlyph).ImageIndex := IfThen(_activeSort.SortDirection = ListSortDirection.Ascending, sortAscIndex, sortDescIndex);
    end
    else if (_activeSort = nil) and (headerCell.SortControl <> nil) then
    begin
      headerCell.SortControl.Free;
      headerCell.SortControl := nil;
    end;

    if headerCell.FilterControl <> nil then
      headerCell.FilterControl.Tag := Cell.Row.ViewListIndex;

    if headerCell.SortControl <> nil then
      headerCell.SortControl.Tag := Cell.Row.ViewListIndex;
  end
  else if Cell.Column.ShowHierarchy and Cell.Row.HasChildren then
  begin
    if Cell.ExpandButton = nil then
    begin
      Cell.ExpandButton := TExpandButton.Create(Cell.Control);
      Cell.ExpandButton.Align := TAlignLayout.None;
      Cell.ExpandButton.HitTest := True;
      Cell.ExpandButton.Width := 8;
      Cell.ExpandButton.Height := 8;
      Cell.ExpandButton.TouchTargetExpansion.Rect := RectF(4, 4, 4, 4);

      Cell.Control.AddObject(Cell.ExpandButton);
    end;

    Cell.ExpandButton.Tag := Cell.Row.ViewListIndex;
  end
  else if cell.ExpandButton <> nil then
  begin
    cell.ExpandButton.Free;
    cell.ExpandButton := nil;
  end;

  // max width of text
  var maxWidth: Single;
  if cell.Column.CustomWidth > 0 then
    maxWidth := cell.Column.CustomWidth else
    maxWidth := IfThen(cell.Column.WidthMax > 0, cell.Column.WidthMax, -1);

  maxWidth := maxWidth - (2*_treeControl.CellLeftRightPadding);

  if Cell.IsHeaderCell or (Cell.Column.InfoControlClass = TInfoControlClass.Text) and (cell.InfoControl <> nil) then
    (cell.InfoControl as ITextControl).MaxWidth := Trunc(maxWidth); // can be <= 0, in that case there is no maxwidth

  if (Cell.Column.SubInfoControlClass = TInfoControlClass.Text) and (cell.SubInfoControl <> nil) then
    (cell.SubInfoControl as ITextControl).MaxWidth := Trunc(maxWidth); // can be <= 0, in that case there is no maxwidth
end;

procedure TTreeLayoutColumn.UpdateColumnContainsData(const ContainsData: TColumnContainsData; const CellDataExample: CObject);
begin
  if _containsData = ContainsData then
    Exit;

  _containsData := ContainsData;

  if (_containsData = TColumnContainsData.Yes) then
  begin
    case _column.Visualisation.HorzAlign of
      TDCTextAlign.Leading: _calculatedHorzAlign := TTextAlign.Leading;
      TDCTextAlign.Center: _calculatedHorzAlign := TTextAlign.Center;
      TDCTextAlign.Trailing: _calculatedHorzAlign := TTextAlign.Trailing;

      else {TDCTextAlign.Default} begin
        if CellDataExample = nil then
          _calculatedHorzAlign := TTextAlign.Leading
        else if CellDataExample.IsDateTime or CellDataExample.IsNumeric then
          _calculatedHorzAlign := TTextAlign.Trailing
        else
          _calculatedHorzAlign := TTextAlign.Leading;
      end;
    end;

    case _column.Visualisation.VertAlign of
      TDCTextAlign.Leading: _calculatedVertAlign := TTextAlign.Leading;
      TDCTextAlign.Center: _calculatedVertAlign := TTextAlign.Center;
      TDCTextAlign.Trailing: _calculatedVertAlign := TTextAlign.Trailing;

      else {TDCTextAlign.Default}
        _calculatedVertAlign := TTextAlign.Center;
    end;
  end;
end;

procedure TTreeLayoutColumn.UpdateCellControlsPositions(const Cell: IDCTreeCell; ForceIsValid: Boolean = False);
begin
  Assert(not _HideColumnInView);

  Cell.HideCellInView := False;
  //doanimate
//  FMX.Ani.TAnimator.AnimateFloatDelay(Cell.Control, 'Width', get_Width, 0.3, 0.5);
  Cell.Control.Width := get_Width;
  Cell.Control.Height := Cell.Row.Control.Height;
  Cell.Control.Position.Y := 0;

  var spaceUsed := 0.0;

  if Cell.IsHeaderCell then
  begin
    var headerCell := Cell as IHeaderCell;
    var startYPos := Cell.Control.Width - CELL_MIN_INDENT - (2*_treeControl.CellLeftRightPadding);

    (headerCell.InfoControl as ITextSettings).TextSettings.HorzAlign := headerCell.LayoutColumn.CalculatedHorzAlign;

    if headerCell.FilterControl <> nil then
    begin
      headerCell.FilterControl.Position.Y := (headerCell.Control.Height - HEADER_IMG_SIZE)/2;
      headerCell.FilterControl.Position.X := startYPos;
      headerCell.FilterControl.Width := HEADER_IMG_SIZE;
      headerCell.FilterControl.Height := HEADER_IMG_SIZE;

      startYPos := startYPos - HEADER_IMG_SIZE - (2*_treeControl.CellLeftRightPadding);
    end;
    if headerCell.SortControl <> nil then
    begin
      headerCell.SortControl.Position.Y := (headerCell.Control.Height - HEADER_IMG_SIZE)/2;
      headerCell.SortControl.Position.X := startYPos;
      headerCell.SortControl.Width := HEADER_IMG_SIZE;
      headerCell.SortControl.Height := HEADER_IMG_SIZE;
    end;
  end
  else begin
    var indentPerLevel := CMath.Max(Cell.Column.Indent, CELL_MIN_INDENT) + _treeControl.CellLeftRightPadding;

    if Cell.ExpandButton <> nil then
    begin
      cell.ExpandButton.Position.Y := _treeControl.CellTopBottomPadding;
      cell.ExpandButton.Position.X := _treeControl.CellLeftRightPadding + (indentPerLevel * cell.Row.ParentCount);
      spaceUsed := indentPerLevel * (cell.Row.ParentCount {can be 0} + 1);
    end
    else if Cell.Column.ShowHierarchy or (Cell.Column.Indent > 0) then
      spaceUsed := indentPerLevel * (cell.Row.ParentCount {can be 0});
  end;

  var validMain := (Cell.InfoControl <> nil) and (Cell.InfoControl.Visible or ForceIsValid);
  if validMain and (Cell.Column.InfoControlClass = TInfoControlClass.Text) then
  begin
    validMain := ForceIsValid or (Length((Cell.InfoControl as ICaption).Text) > 0);
    (Cell.InfoControl as ITextSettings).TextSettings.HorzAlign := Cell.LayoutColumn.CalculatedHorzAlign;
    Cell.InfoControl.Visible := validMain; // not neccessary, but for performance...
  end;

  var validSub := (Cell.SubInfoControl <> nil) and (Cell.SubInfoControl.Visible or ForceIsValid);
  if validSub and (Cell.Column.SubInfoControlClass = TInfoControlClass.Text) then
  begin
    validSub := ForceIsValid or (Length((Cell.SubInfoControl as ICaption).Text) > 0);
    (Cell.SubInfoControl as ITextSettings).TextSettings.HorzAlign := Cell.LayoutColumn.CalculatedHorzAlign;
    Cell.SubInfoControl.Visible := validSub; // not neccessary, but for performance...
  end;

  var heightSet := True;
  var availableCtrlWidth := get_Width - spaceUsed - (2*_treeControl.CellLeftRightPadding);

  if validSub then
  begin
    if Cell.CustomSubInfoControlBounds.IsEmpty then
    begin
      if not Cell.IsHeaderCell and (Cell.Column.SubInfoControlClass = TInfoControlClass.CheckBox) then
      begin
        Cell.SubInfoControl.Width := 16;
        Cell.SubInfoControl.Position.X := spaceUsed + _treeControl.CellLeftRightPadding + ((availableCtrlWidth - Cell.SubInfoControl.Width) / 2);
      end else
      begin
        Cell.SubInfoControl.Width := availableCtrlWidth;
        Cell.SubInfoControl.Position.X := spaceUsed + _treeControl.CellLeftRightPadding + Cell.SubInfoControl.Margins.Left;
      end;

      heightSet := False;
    end else
      Cell.SubInfoControl.BoundsRect := Cell.CustomSubInfoControlBounds;
  end;

  if validMain then
  begin
    if Cell.CustomInfoControlBounds.IsEmpty then
    begin
      if not Cell.IsHeaderCell and (Cell.Column.InfoControlClass = TInfoControlClass.CheckBox) then
      begin
        Cell.InfoControl.Width := 16;
        Cell.InfoControl.Position.X := spaceUsed + _treeControl.CellLeftRightPadding + ((availableCtrlWidth - Cell.InfoControl.Width) / 2);
      end else
      begin
        Cell.InfoControl.Width := get_Width - spaceUsed - (2*_treeControl.CellLeftRightPadding);
        Cell.InfoControl.Position.X := spaceUsed + _treeControl.CellLeftRightPadding + Cell.InfoControl.Margins.Left;
      end;

      heightSet := False;
    end else
      Cell.InfoControl.BoundsRect := Cell.CustomInfoControlBounds;
  end;

  if heightSet then
    Exit;

  var ctrlHeight := cell.Control.Height;

  var row := (cell.Row as IDCTReeRow);
  if not validSub or not validMain then
  begin
    var ctrl := Cell.InfoControl;
    if not validMain then
      ctrl := Cell.SubInfoControl;

    var txtCtrl: ITextControl;
    if not cell.IsHeaderCell and Interfaces.Supports<ITextControl>(cell.InfoControl, txtCtrl) then
    begin
      if txtCtrl.TextHeightWithPadding > (ctrlHeight - (2*_treeControl.CellTopBottomPadding)) then
        (txtCtrl as ITextSettings).TextSettings.VertAlign := TTextAlign.Leading else
        (txtCtrl as ITextSettings).TextSettings.VertAlign := TTextAlign.Center;

      ctrl.Height := ctrlHeight - (2*_treeControl.CellTopBottomPadding);
    end;

    case Cell.LayoutColumn.CalculatedVertAlign of
      TTextAlign.Leading: ctrl.Position.Y := _treeControl.CellTopBottomPadding;
      TTextAlign.Center: ctrl.Position.Y := (ctrlHeight - ctrl.Height) / 2;
      TTextAlign.Trailing: ctrl.Position.Y := ctrlHeight - ctrl.Height - _treeControl.CellTopBottomPadding;
    end;

    if Cell.IsHeaderCell and validMain then
    begin
      var txt := Cell.InfoControl as ITextControl;
      if Cell.InfoControl.Height < txt.TextHeight then
      begin
        Cell.InfoControl.Position.Y := CMath.Max(0, (Cell.Control.Height - txt.TextHeight)/2);
        Cell.InfoControl.Padding.Top := 0;
        Cell.InfoControl.Height := txt.TextHeight;
      end;
    end;

    Exit;
  end;

  // if 2 controls are visible in 1 cell
  if (cell.Column.InfoControlClass = TInfoControlClass.Text) then
    cell.InfoControl.Height := (cell.InfoControl as ITextControl).TextHeight;

  if (cell.Column.SubInfoControlClass = TInfoControlClass.Text) then
    cell.SubInfoControl.Height := (cell.SubInfoControl as ITextControl).TextHeight;

  case Cell.LayoutColumn.CalculatedVertAlign of
    TTextAlign.Leading: cell.InfoControl.Position.Y := _treeControl.CellTopBottomPadding;
    TTextAlign.Center: cell.InfoControl.Position.Y := CMath.Max(0, (ctrlHeight - cell.InfoControl.Height - cell.SubInfoControl.Height) / 2);
    TTextAlign.Trailing: cell.InfoControl.Position.Y := ctrlHeight - cell.InfoControl.Height - cell.SubInfoControl.Height - _treeControl.CellTopBottomPadding;
  end;

  cell.SubInfoControl.Position.Y := cell.InfoControl.Position.Y + cell.InfoControl.Height;
end;

function TTreeLayoutColumn.CreateInfoControl(const Cell: IDCTreeCell; const ControlClassType: TInfoControlClass): IDCControl;
begin
  Result := nil;
  case ControlClassType of
    TInfoControlClass.Custom:
      Exit;

    TInfoControlClass.Text: begin
      Result := DataControlClassFactory.CreateText(Cell.Control);
      Result.HitTest := False;
      Result.Align := TAlignLayout.None;

      var txt_settings: ITextSettings;
      if Interfaces.Supports<ITextSettings>(Result, txt_settings) then
      begin
        // txt_settings.MaxWidth := Cell.Column.WidthMax - (Cell.Column.TreeControl.CellLeftRightPadding * 2); // can be 0
        if (Cell.Column.WidthType <> TDCColumnWidthType.AlignToContent) or (Cell.Column.WidthMax > 0) then
          txt_settings.TextSettings.Trimming := TTextTrimming.Character else
          txt_settings.TextSettings.Trimming := TTextTrimming.None;

        txt_settings.TextSettings.HorzAlign := TTextAlign.Leading;
        txt_settings.TextSettings.VertAlign := TTextAlign.Center;
        txt_settings.TextSettings.WordWrap := False;
      end;
    end;

    TInfoControlClass.CheckBox: begin
      if Cell.Column.IsSelectionColumn and _treeControl.RadioInsteadOfCheck  then
        Result := DataControlClassFactory.CreateRadioButton(Cell.Control) else
        Result := DataControlClassFactory.CreateCheckBox(Cell.Control);

      Result.HitTest := False;
      Result.Align := TAlignLayout.None;
    end;

    TInfoControlClass.Button: begin
      Result := DataControlClassFactory.CreateButton(Cell.Control);
      Result.Align := TAlignLayout.None;
    end;

    TInfoControlClass.Glyph: begin
      Result := DataControlClassFactory.CreateGlyph(Cell.Control);
      Result.Align := TAlignLayout.None;
    end;
  end;
end;

destructor TTreeLayoutColumn.Destroy;
begin

  inherited;
end;

procedure TTreeLayoutColumn.CreateCellBase(const ShowVertGrid: Boolean; const Cell: IDCTreeCell);
begin
  // in case user assigns cell control in CellLoading the tree allows that
  if Cell.Control = nil then
  begin
    if Cell.IsHeaderCell then
      Cell.BackgroundControl := DataControlClassFactory.CreateHeaderCellRect(Cell.Row.Control) else
      Cell.BackgroundControl := DataControlClassFactory.CreateRowCellRect(Cell.Row.Control);

    var rect := Cell.BackgroundControl.AsControl;

    if Cell.IsHeaderCell then
    begin
      if Cell.Column.AllowResize then
      begin
        var splitterLy := TLayout.Create(rect);
        splitterLy.Align := TAlignLayout.Right;
        splitterLy.Cursor := crSizeWE;
        splitterLy.HitTest := True;
        splitterLy.Width := 1;
        splitterLy.TouchTargetExpansion.Rect := RectF(10, 0, 6, 0);

        rect.AddObject(splitterLy);

        var headerCell := Cell as IHeaderCell;
        headerCell.ResizeControl := splitterLy;
      end;
    end;

    Cell.Control.HitTest := False;
  end;

  Cell.Control.Align := TAlignLayout.None;
end;

procedure TTreeLayoutColumn.CreateCellBaseControls(const ShowVertGrid: Boolean; const Cell: IDCTreeCell);
begin
  CreateCellBase(ShowVertGrid, Cell);

  var ctrl: IDCControl;
  if Cell.IsHeaderCell then
  begin
    ctrl := CreateInfoControl(Cell, TInfoControlClass.Text);
    ctrl.Height := (Cell.Row as IDCHeaderRow).ContentControl.Height - _treeControl.HeaderTextTopMargin - _treeControl.HeaderTextBottomMargin;
    ctrl.Position.Y := _treeControl.HeaderTextTopMargin;
  end else
    ctrl := CreateInfoControl(Cell, Cell.Column.InfoControlClass);

  if ctrl <> nil then
  begin
    Cell.Control.AddObject(ctrl.Control);
    Cell.InfoControl := ctrl;

    if not Cell.IsHeaderCell and (Cell.Column.SubInfoControlClass <> TInfoControlClass.Custom) then
    begin
      var subCtrl := CreateInfoControl(Cell, Cell.Column.SubInfoControlClass);
      Cell.Control.AddObject(subCtrl.Control);
      Cell.SubInfoControl := subCtrl;
    end;
  end;
end;

procedure TTreeLayoutColumn.CreateCellStyleControl(const StyleLookUp: CString; const ShowVertGrid: Boolean; const Cell: IDCTreeCell);
begin
  CreateCellBase(ShowVertGrid, Cell);

  // this method is called from CellLoading (or when wrongly used also in "CellLoaded")
  // those methods also are called for HeaderCells
  // To avoid adding the HeaderCell check in every CellLoading/CellLoaded we do this check here
  if Cell.IsHeaderCell then
    Exit;

  Assert((Cell.Column.InfoControlClass = TInfoControlClass.Custom) and (Cell.Column.SubInfoControlClass = TInfoControlClass.Custom),
     'Column (Sub)InfoControlClass must be "Custom" to assign StyleLookUp');

  var styledControl: TStyledControl;
  if Cell.InfoControl = nil then
  begin
    styledControl := TStyledControl.Create(Cell.Control);
    styledControl.Align := TAlignLayout.Client;
    styledControl.HitTest := False;
    Cell.InfoControl := TDCControlImpl.Create(styledControl);
    Cell.Control.AddObject(styledControl);
  end else
    styledControl := Cell.InfoControl.Control as TStyledControl;

  styledControl.StyleLookup := StyleLookUp;
end;

function TTreeLayoutColumn.get_ActiveFilter: ITreeFilterDescription;
begin
  Result := _activeFilter;
end;

function TTreeLayoutColumn.get_ActiveSort: IListSortDescription;
begin
  Result := _activeSort;
end;

function TTreeLayoutColumn.get_Column: IDCTreeColumn;
begin
  Result := _column;
end;

function TTreeLayoutColumn.get_ContainsData: TColumnContainsData;
begin
  Result := _containsData;
end;

function TTreeLayoutColumn.get_CalculatedHorzAlign: TTextAlign;
begin
  Result := _calculatedHorzAlign;
end;

function TTreeLayoutColumn.get_CalculatedVertAlign: TTextAlign;
begin
  Result := _calculatedVertAlign;
end;

function TTreeLayoutColumn.get_HideColumnInView: Boolean;
begin
  Result := _HideColumnInView;

  if _column.Visualisation.HideWhenEmpty and (_containsData <> TColumnContainsData.Unknown) and not Result then
    Result := _containsData = TColumnContainsData.No;
end;

function TTreeLayoutColumn.get_Index: Integer;
begin
  Result := _index;
end;

function TTreeLayoutColumn.get_Left: Single;
begin
  Result := _left;
end;

function TTreeLayoutColumn.get_Width: Single;
begin
  if not SameValue(get_Column.CustomWidth, -1) then
    Result := get_Column.CustomWidth else
    Result := _width;
end;

procedure TTreeLayoutColumn.set_ActiveFilter(const Value: ITreeFilterDescription);
begin
  _activeFilter := Value;
end;

procedure TTreeLayoutColumn.set_ActiveSort(const Value: IListSortDescription);
begin
  _activeSort := Value;
end;

//procedure TTreeLayoutColumn.set_CustomHidden(const Value: Boolean);
//begin
//  if _userHidColumn <> Value then
//  begin
//    _userHidColumn := Value;
//    _column.Visualisation.Visible := False;
//    _treeControl.ColumnVisibilityChanged(_column);
//  end;
//end;
//
//procedure TTreeLayoutColumn.set_CustomWidth(const Value: Single);
//begin
//  if not SameValue(_userWidth, _width) then
//    _userWidth := Value else
//    _userWidth := -1;
//end;

procedure TTreeLayoutColumn.set_HideColumnInView(const Value: Boolean);
begin
  _HideColumnInView := Value;
end;

procedure TTreeLayoutColumn.set_Index(const Value: Integer);
begin
  _index := Value;
end;

procedure TTreeLayoutColumn.set_Left(Value: Single);
begin
  _left := Value;
end;

procedure TTreeLayoutColumn.set_Width(Value: Single);
begin
  if Value < 0 then
    _width := Value else
    _width := Value;
end;

{ TDCTreeLayout }

constructor TDCTreeLayout.Create(const ColumnControl: IColumnsControl);
begin
  inherited Create;

  _columnsControl := ColumnControl;
  _layoutColumns := CList<IDCTreeLayoutColumn>.Create;

  UpdateLayoutColumnList;
end;

destructor TDCTreeLayout.Destroy;
begin
  _layoutColumns := nil;
  _flatColumns := nil;

  inherited;
end;

function TDCTreeLayout.FrozenColumnWidth: Single;
begin
  RecalcColumnWidthsBasic;

  Result := 0.0;
  
  var clmn: IDCTreeLayoutColumn;
  for clmn in get_FlatColumns do
  begin
    // frozen columns are the first columns in the list
    if not clmn.Column.Frozen then
      Exit;

    Result := Result + clmn.Width;
  end;
end;

function TDCTreeLayout.get_FlatColumns: List<IDCTreeLayoutColumn>;
begin
  if (_flatColumns = nil) and (_layoutColumns <> nil) then
  begin
    // The following is performance wise not nice, but since there are not that many columns, this will be done very quick
    // we need to sort, check and update these indexes because AutoFitColumns/ UserHide can change the order/visibility of columns

    // BEGIN sort columns
    var lyCLmnsCopy: List<IDCTreeLayoutColumn> := CList<IDCTreeLayoutColumn>.Create(_layoutColumns);

    _layoutColumns.Sort(
      function(const X, Y: IDCTreeLayoutColumn): Integer
      begin
        Result := -CBoolean(X.Column.Frozen).CompareTo(y.Column.Frozen);

        if Result = 0 then
          Result := CInteger(lyCLmnsCopy.IndexOf(X)).CompareTo(lyCLmnsCopy.IndexOf(Y));
      end);
    // END sort columns

    _flatColumns := CList<IDCTreeLayoutColumn>.Create;
    var ix: Integer;
    for ix := 0 to _layoutColumns.Count - 1 do
    begin
      var layoutColumn := _layoutColumns[ix];
      if not layoutColumn.HideColumnInView then
        _flatColumns.Add(layoutColumn);

      if layoutColumn.Index <> ix then
        layoutColumn.Index := ix;
    end;
  end;

  Result := _flatColumns;
end;

function TDCTreeLayout.get_LayoutColumns: List<IDCTreeLayoutColumn>;
begin
  Result := _layoutColumns;
end;

function TDCTreeLayout.HasFrozenColumns: Boolean;
begin
  if _layoutColumns <> nil then
  begin
    var clmn: IDCTreeLayoutColumn;
    for clmn in _layoutColumns do
      if clmn.Column.Frozen and not clmn.HideColumnInView then
        Exit(True);
    
  end;
    
  Result := False;
end;

function TDCTreeLayout.ContentOverFlow: Integer;
begin
  RecalcColumnWidthsBasic;

  var totalWidth := 0.0;
  var layoutClmn: IDCTreeLayoutColumn;
  for layoutClmn in _flatColumns do
    totalWidth := totalWidth + layoutClmn.Width;

  if _columnsControl.Control.Width < totalWidth then
    Result := Round(totalWidth - _columnsControl.Control.Width) else
    Result := 0;
end;

function TDCTreeLayout.ColumnCanAddWidth(const LayoutColumn: IDCTreeLayoutColumn): Boolean;
begin
  Result := SameValue(LayoutColumn.Column.CustomWidth, -1) and
    ((LayoutColumn.Column.WidthMax = 0) or (LayoutColumn.Column.WidthMax > LayoutColumn.Width));
end;

procedure TDCTreeLayout.RecalcColumnWidthsBasic;
var
  layoutClmn: IDCTreeLayoutColumn;
begin
  if not _recalcRequired then
    Exit;

  _recalcRequired := False;

  // make sure we get all layout columns, even in case of AutoFitColumns (because they can become visible again)
  var lyColumn: IDCTreeLayoutColumn;
  for lyColumn in _layoutColumns do
  begin
    if lyColumn.HideColumnInView <> (not lyColumn.Column.Visible or lyColumn.Column.CustomHidden) then
    begin
      lyColumn.HideColumnInView := not lyColumn.HideColumnInView;
      _columnsControl.ColumnVisibilityChanged(lyColumn.Column, False);
    end;
  end;

  // reset _flatColumns and update indexes
  _flatColumns := nil;
  get_FlatColumns;

  var totalPercCount: Single := 0;
  var fullPercentageNumber := 100.0;

  var columnsToCalculate: List<Integer> := CList<Integer>.Create;
  for layoutClmn in get_FlatColumns do
    if not _isScrolling or SameValue(layoutClmn.Width, 0) then
      columnsToCalculate.Add(layoutClmn.Index);

  var totalWidth := _columnsControl.CalculateRowControlWidth(True);
  var widthLeft := totalWidth;

  var round: Integer;
  for round := 1 to 3 do
  begin
    var ix: Integer;
    for ix := columnsToCalculate.Count - 1 downto 0 do
    begin
      layoutClmn := _layoutColumns[columnsToCalculate[ix]];

      if round = 1 then
      begin
        if layoutClmn.Column.WidthType = TDCColumnWidthType.Pixel then
          layoutClmn.Width := layoutClmn.Column.Width;

        // pixel columns and columns resized by users
        if (layoutClmn.Column.WidthType = TDCColumnWidthType.Pixel) or (layoutClmn.Column.CustomWidth <> -1) then
        begin
          widthLeft := widthLeft - layoutClmn.Width;
          columnsToCalculate.RemoveAt(ix);
        end

        // align to content columns
        else if layoutClmn.Column.WidthType = TDCColumnWidthType.AlignToContent then
        begin
          // width already set
          layoutClmn.Width := CMath.Max(layoutClmn.Width, layoutClmn.Column.WidthMin);
          if layoutClmn.Column.WidthMax > 0 then
            layoutClmn.Width := CMath.Min(layoutClmn.Width, layoutClmn.Column.WidthMax);

          if layoutClmn.Width > 215 then
            layoutClmn.Width := layoutClmn.Width + 5 - 10 + 5;

          widthLeft := widthLeft - layoutClmn.Width;
          columnsToCalculate.RemoveAt(ix);
        end

        else if (layoutClmn.Column.WidthType = TDCColumnWidthType.Percentage) then
          totalPercCount := totalPercCount + layoutClmn.Column.Width;
      end

      else if round in [2,3] then
      begin
        if (layoutClmn.Column.WidthType = TDCColumnWidthType.Percentage) and ((layoutClmn.Column.WidthMin > 0) = (round = 2)) then
        begin
          var w: Single;
          if totalPercCount > fullPercentageNumber then
            w := widthLeft / (fullPercentageNumber / (layoutClmn.Column.Width * (fullPercentageNumber / totalPercCount))) else
            w := widthLeft / (fullPercentageNumber / layoutClmn.Column.Width);

          if (w < layoutClmn.Column.WidthMin) then
            w := layoutClmn.Column.WidthMin
          else if (layoutClmn.Column.WidthMax > 0) and (w > layoutClmn.Column.WidthMax) then
            w := layoutClmn.Column.WidthMax;

          layoutClmn.Width := w;
          totalPercCount := totalPercCount - layoutClmn.Column.Width;
          fullPercentageNumber := fullPercentageNumber - layoutClmn.Column.Width;
          widthLeft := widthLeft - w;

          columnsToCalculate.RemoveAt(ix);
        end;
      end;
    end;
  end;

  {$IFNDEF WEBASSEMBLY}
  assert(columnsToCalculate.Count = 0);
  {$ENDIF}

  var startXPosition: Double := 0;
  for layoutClmn in _flatColumns do
  begin
    layoutClmn.Left := startXPosition;
    startXPosition := startXPosition + layoutClmn.Width;
  end;
end;

procedure TDCTreeLayout.RecalcColumnWidthsAutoFit;
begin
  // calculate ALL layoutcolumns that are visible by default
  if _recalcRequired then
    RecalcColumnWidthsBasic;

  var layoutClmn: IDCTreeLayoutColumn;

  // at this point get_FlatCOlumns contains also columns that are out of view

  // step 1: hide all columns that do not fit on the right
  var minimumTotalWidth := 0.0;

  var rowControlWidth := _columnsControl.CalculateRowControlWidth(True);

  var ix: Integer;
  for ix := 0 to 1 do
    for layoutClmn in get_FlatColumns do
    begin
      var minColumnWidth: Single := -1;
      case layoutClmn.Column.WidthType of
        Percentage:
        begin
          // already at round 0
          if ix = 1 then
            Continue;

          if SameValue(layoutClmn.Column.CustomWidth, -1) then
            minColumnWidth := layoutClmn.Column.WidthMin else
            minColumnWidth := layoutClmn.Width;
        end;
        Pixel:
        begin
          // already at round 0
          if ix = 1 then
            Continue;

          minColumnWidth := layoutClmn.Width;
        end;
        AlignToContent:
        begin
          // calculate in round 1
          if ix = 0 then
            Continue;


          var available := rowControlWidth - minimumTotalWidth;
          if (available < layoutClmn.Width) and (available >= layoutClmn.Column.WidthMin) and (layoutClmn.Column.WidthMin > 0) then
            layoutClmn.Width := available;

          minColumnWidth := layoutClmn.Width;
        end;
      end;

      if not SameValue(minColumnWidth, -1) then
      begin
        if minimumTotalWidth + minColumnWidth - 0.01 > rowControlWidth then
        begin
          layoutClmn.HideColumnInView := True;
          Continue;
        end;

        minimumTotalWidth := minimumTotalWidth + minColumnWidth;
      end;
    end;

  var widthLeft := rowControlWidth - minimumTotalWidth;
  Assert(Ceil(widthLeft) >= 0);

  var potentialCount := 0;
  var lyClmn: IDCTreeLayoutColumn;
  for lyClmn in _layoutColumns do
    if (lyClmn.Column.Visible and not lyClmn.Column.CustomHidden) then
      inc(potentialCount);

  // reset _flatColumns and update indexes
  _flatColumns := nil;
  get_FlatColumns;

  // step 2: expand columns to make all columns fit perfectly in view
  var autoFitWidthType := TDCColumnWidthType.Pixel;
  for layoutClmn in get_FlatColumns do
  begin
    if (layoutClmn.Column.WidthType <> TDCColumnWidthType.Percentage) and not ColumnCanAddWidth(layoutClmn) then
      Continue;

    case layoutClmn.Column.WidthType of
      Percentage:
          autoFitWidthType := TDCColumnWidthType.Percentage;
      AlignToContent:
        if (autoFitWidthType = TDCColumnWidthType.Pixel) then
          autoFitWidthType := TDCColumnWidthType.AlignToContent;
    end;
  end;

  var addableColumns: List<IDCTreeLayoutColumn> := CList<IDCTreeLayoutColumn>.Create;
  for layoutClmn in get_FlatColumns do
    if (layoutClmn.Column.WidthType = autoFitWidthType) and ColumnCanAddWidth(layoutClmn) then
      addableColumns.Add(layoutClmn);

//  var extraWidthPerColumnOng := widthLeft / addableColumns.Count;
//  if (_flatColumns.Count = potentialCount) and (extraWidthPerColumnOng > 20) then
//    Exit;

  var ix2: Integer;
  // add width to max size columns
  if addableColumns.Count > 0 then
    for ix2 := addableColumns.Count - 1 downto 0 do
    begin
      var flatClmn := addableColumns[ix2];
      if flatClmn.Column.WidthMax = 0 then
        Continue;

      var extraWidthPerColumn := widthLeft / addableColumns.Count;

      var newWidth: Single;
      // percentageColumns are set back to minimum width
      if autoFitWidthType = TDCColumnWidthType.Percentage then
        newWidth := flatClmn.Column.WidthMin + extraWidthPerColumn else
        newWidth := flatClmn.Width + extraWidthPerColumn;

      if newWidth > flatClmn.Column.WidthMax then
      begin
        widthLeft := widthLeft - (flatClmn.Column.WidthMax - flatClmn.Width);
        flatClmn.Width := flatClmn.Column.WidthMax;
        addableColumns.RemoveAt(ix2);
      end;
    end;

  // add width to all remaining columns
  var ix3: Integer;
  if addableColumns.Count > 0 then
    for ix3 := addableColumns.Count - 1 downto 0 do
    begin
      var flatClmn := addableColumns[ix3];
      var extraWidthPerColumn := widthLeft / addableColumns.Count;
      if (_flatColumns.Count = potentialCount) and ((_columnsControl.AutoExtraColumnSizeMax/potentialCount) > extraWidthPerColumn) then
        extraWidthPerColumn := CMath.Min(extraWidthPerColumn, _columnsControl.AutoExtraColumnSizeMax);

      // percentageColumns are set back to minimum width
      if autoFitWidthType = TDCColumnWidthType.Percentage then
        flatClmn.Width := flatClmn.Column.WidthMin + extraWidthPerColumn else
        flatClmn.Width := flatClmn.Width + extraWidthPerColumn;

      widthLeft := widthLeft - extraWidthPerColumn;
      addableColumns.RemoveAt(ix3);
    end;

  var startXPosition: Double := 0;
  for layoutClmn in _flatColumns do
  begin
    layoutClmn.Left := startXPosition;
    startXPosition := startXPosition + layoutClmn.Width;
  end;
end;

function TDCTreeLayout.RecalcRequired: Boolean;
begin
  Result := _recalcRequired;
end;

procedure TDCTreeLayout.ForceRecalc;
begin
  _recalcRequired := True;
end;

procedure TDCTreeLayout.UpdateLayoutColumnList;
begin
  var fullClmnList := _columnsControl.FullColumnList;
  if _layoutColumns.Count > 0 then
  begin
    var lyClmnIx: Integer;
    for lyClmnIx := _layoutColumns.Count - 1 downto 0 do
      if not fullClmnList.Contains(_layoutColumns[lyClmnIx].Column) then
        _layoutColumns.RemoveAt(lyClmnIx);
  end;

  var updatedLayoutClmns: List<IDCTreeLayoutColumn> := CList<IDCTreeLayoutColumn>.Create;
  var clmnIx: Integer;
  for clmnIx := 0 to fullClmnList.Count - 1 do
  begin
    var clmn := fullClmnList[clmnIx];

    var lyColumn := _columnsControl.FlatColumnByColumn(clmn);
    if lyColumn = nil then
      lyColumn := TTreeLayoutColumn.Create(clmn, _columnsControl);

    updatedLayoutClmns.Add(lyColumn);
  end;

  _layoutColumns := updatedLayoutClmns;
  _recalcRequired := True;
end;

procedure TDCTreeLayout.ResetColumnDataAvailability(OnlyForInsertedRows: Boolean);
begin
  var recalcNeeded := False;
  var lyClmn: IDCTreeLayoutColumn;
  for lyClmn in _layoutColumns do
  begin
    if not OnlyForInsertedRows or (lyClmn.ContainsData = TColumnContainsData.No) then
    begin
      lyClmn.UpdateColumnContainsData(TColumnContainsData.Unknown, nil);

      if lyClmn.Column.Visualisation.HideWhenEmpty then
        recalcNeeded := True;
    end;
  end;

  if recalcNeeded then
    _flatColumns := nil;
end;

procedure TDCTreeLayout.SetTreeIsScrolling(const IsScrolling: Boolean);
begin
  _isScrolling := IsScrolling;
end;

procedure TDCTreeLayout.UpdateColumnWidth(const FlatColumnIndex: Integer; const Width: Single);
begin
  var flatClmn := _layoutColumns[FlatColumnIndex];

  if not SameValue(flatClmn.Width, Width) then
  begin
    flatClmn.Width := CMath.Max(Width, flatClmn.Column.WidthMin);
    if flatClmn.Column.WidthMax > 0 then
      flatClmn.Width := CMath.Min(Width, flatClmn.Column.WidthMax);

    _recalcRequired := True;
  end;
end;

{ TDCTreeCell }

function TDCTreeCell.InPerformanceMode: Boolean;
begin
  if _performanceModeWhileScrolling then
    Result := ((_performanceLayout <> nil) and _performanceLayout.Visible) else
    Result := False;
end;

procedure TDCTreeCell.CheckPerformanceRoutine(GoPerformanceMode: Boolean);
begin
  if not _performanceModeWhileScrolling then
    Exit
  else if GoPerformanceMode = ((_performanceLayout <> nil) and _performanceLayout.Visible) then
    Exit
  else if (_infoControl = nil) and (_subInfoControl = nil) then
    Exit;

  TogglePerformanceMode(GoPerformanceMode);
end;

procedure TDCTreeCell.ClearCellForReassignment;
begin
  if InPerformanceMode then
    TogglePerformanceMode(False);
end;

constructor TDCTreeCell.Create(const ARow: IDCRow; const LayoutColumn: IDCTreeLayoutColumn);
begin
  inherited Create;
  _row := ARow;
  _layoutColumn := LayoutColumn;
end;

destructor TDCTreeCell.Destroy;
begin
//  FreeAndNil(_performanceLayout);

  inherited;
end;

function TDCTreeCell.get_Column: IDCTreeColumn;
begin
  Result := _layoutColumn.Column;
end;

function TDCTreeCell.get_Control: TControl;
begin
  if _backgroundControl <> nil then
    Result := _backgroundControl.AsControl else
    Result := nil;
end;

function TDCTreeCell.get_BackgroundControl: IBackgroundControl;
begin
  Result := _backgroundControl;
end;

function TDCTreeCell.get_CustomInfoControlBounds: TRectF;
begin
  Result := _customInfoControlBounds;
end;

function TDCTreeCell.get_CustomSubInfoControlBounds: TRectF;
begin
  Result := _customSubInfoControlBounds;
end;

function TDCTreeCell.get_CustomTag: CObject;
begin
  Result := _customTag;
end;

function TDCTreeCell.get_Data: CObject;
begin
  Result := _data;
end;

function TDCTreeCell.get_ExpandButton: TLayout;
begin
  Result := _expandButton;
end;

function TDCTreeCell.get_HideCellInView: Boolean;
begin
  Result := not get_Control.Visible;
end;

function TDCTreeCell.get_Index: Integer;
begin
  Result := _layoutColumn.Index;
end;

//function TDCTreeCell.get_Index: Integer;
//begin
//  Result := _index;
//end;

function TDCTreeCell.get_InfoControl: IDCControl;
begin
  Result := _infoControl;
end;

function TDCTreeCell.get_LayoutColumn: IDCTreeLayoutColumn;
begin
  Result := _layoutColumn;
end;

function TDCTreeCell.get_PerformanceModeWhileScrolling: Boolean;
begin
  Result := _performanceModeWhileScrolling;
end;

function TDCTreeCell.get_Row: IDCRow;
begin
  Result := _row;
end;

function TDCTreeCell.get_SubData: CObject;
begin
  Result := _subData;
end;

function TDCTreeCell.get_SubInfoControl: IDCControl;
begin
  Result := _subInfoControl;
end;

function TDCTreeCell.IsHeaderCell: Boolean;
begin
  Result := False;
end;

//procedure TDCTreeCell.set_Control(const Value: TControl);
//begin
//  if _control <> nil then
//    FreeAndNil(_control);
//
//  _control := Value;
//end;

procedure TDCTreeCell.set_BackgroundControl(const Value: IBackgroundControl);
begin
  if _backgroundControl <> nil then
    _backgroundControl.AsControl.Free;

  _backgroundControl := Value;
end;

procedure TDCTreeCell.set_CustomInfoControlBounds(const Value: TRectF);
begin
  _customInfoControlBounds := Value;
end;

procedure TDCTreeCell.set_CustomSubInfoControlBounds(const Value: TRectF);
begin
  _customSubInfoControlBounds := Value;
end;

procedure TDCTreeCell.set_CustomTag(const Value: CObject);
begin
  _customTag := Value;
end;

procedure TDCTreeCell.set_Data(const Value: CObject);
begin
  _data := Value;
end;

procedure TDCTreeCell.set_ExpandButton(const Value: TLayout);
begin
  _expandButton := Value;
end;

procedure TDCTreeCell.set_HideCellInView(const Value: Boolean);
begin
  get_Control.Visible := not Value;
end;

procedure TDCTreeCell.set_InfoControl(const Value: IDCControl);
begin
  _infoControl := Value;
end;

procedure TDCTreeCell.set_PerformanceModeWhileScrolling(const Value: Boolean);
begin
  if _performanceModeWhileScrolling <> Value then
  begin
    if _performanceModeWhileScrolling and InPerformanceMode then
      TogglePerformanceMode(False);

    _performanceModeWhileScrolling := Value
  end;
end;

procedure TDCTreeCell.set_SubData(const Value: CObject);
begin
  _subData := Value;
end;

procedure TDCTreeCell.set_SubInfoControl(const Value: IDCControl);
begin
  _subInfoControl := Value;
end;

procedure TDCTreeCell.TogglePerformanceMode(const Activate: Boolean);
begin
  if Activate then
  begin
    if _performanceLayout = nil then
    begin
      _performanceLayout := TFastLayout.Create(get_Control);
      _performanceLayout.Align := TAlignLayout.None;
      get_Control.AddObject(_performanceLayout);
    end;

    _performanceLayout.Position.X := 0;
    _performanceLayout.Position.Y := 0;
    _performanceLayout.Width := _layoutColumn.Width;
    _performanceLayout.Height := get_Control.Height;
    _performanceLayout.Visible := True;
  end
  else if _performanceLayout <> nil then
    _performanceLayout.Visible := False;

  if (_infoControl <> nil) then
    _infoControl.Opacity := IfThen(not Activate, 1, 0);

  if (_subInfoControl <> nil) then
    _subInfoControl.Opacity := IfThen(not Activate, 1, 0);
end;

procedure TDCTreeCell.UpdateSelectionRect(OwnerIsFocused: Boolean);
begin
  if _selectionRect = nil then
  begin
    var rect := TRectangle.Create(get_Control);
    rect.Align := TAlignLayout.Contents;
    rect.Sides := [];
    rect.Opacity := 0.3;
    rect.HitTest := False;

    _selectionRect := rect;
    get_Control.AddObject(_selectionRect);
    _selectionRect.BringToFront;
  end;

  var clr: TAlphaColor;
  if OwnerIsFocused then
    clr := DEFAULT_ROW_SELECTION_ACTIVE_COLOR else
    clr := DEFAULT_ROW_SELECTION_INACTIVE_COLOR;

  (_selectionRect as TRectangle).Fill.Color := clr;
end;

procedure TDCTreeCell.UpdateSelectionVisibility(const RowIsSelected: Boolean; const SelectionInfo: ITreeSelectionInfo; OwnerIsFocused: Boolean);
begin
  if not RowIsSelected or not SelectionInfo.ColumnIsSelected(get_LayoutColumn.Index) then
  begin
    FreeAndNil(_selectionRect);
    Exit;
  end;

  UpdateSelectionRect(OwnerIsFocused);
end;

{ TDCTreeRow }

procedure TDCTreeRow.ClearRowForReassignment;
begin
  inherited;

  if _contentCellSizes <> nil then
    _contentCellSizes.Clear;

  var cell: IDCTreeCell;
  for cell in get_Cells.Values do
    cell.ClearCellForReassignment;

//  if _innerRowControl <> nil then
//    _innerRowControl.Visible := False;
end;

destructor TDCTreeRow.Destroy;
begin
  get_Cells.Clear;
  inherited;
end;

function TDCTreeRow.get_Cells: Dictionary<Integer, IDCTreeCell>;
begin
  if _cells = nil then
    _cells := CDictionary<Integer, IDCTreeCell>.Create;

  Result := _cells;
end;

function TDCTreeRow.get_ContentCellSizes: Dictionary<Integer, Single>;
begin
  if _contentCellSizes = nil then
    _contentCellSizes := CDictionary<Integer, Single>.Create;

  Result := _contentCellSizes;

end;

function TDCTreeRow.get_FrozenColumnRowControl: TControl;
begin
  Result := _frozenColumnRowControl;
end;

function TDCTreeRow.get_NonFrozenColumnRowControl: TControl;
begin
  Result := _nonFrozenColumnRowControl;
end;

procedure TDCTreeRow.ResetCells;
begin
  _cells := nil;
end;

function TDCTreeRow.IsDummyRowForChanging: Boolean;
begin
  Result := _control = nil;
end;

procedure TDCTreeRow.set_FrozenColumnRowControl(const Value: TControl);
begin
  _frozenColumnRowControl := Value;
end;

procedure TDCTreeRow.set_NonFrozenColumnRowControl(const Value: TControl);
begin
  _nonFrozenColumnRowControl := Value;
end;

procedure TDCTreeRow.UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean);
begin
  var rowWasSelected := _selectionRect <> nil;

  inherited;

  var rowIsSelected := _selectionRect <> nil;
  if (not rowWasSelected and not rowIsSelected) or (SelectionInfo.SelectionType <> TSelectionType.CellSelection) then
    Exit;

  if rowIsSelected then
    _selectionRect.Opacity := 0.0; // make cell selection more visible

  var cell: IDCTreeCell;
  for cell in _cells.Values do
    cell.UpdateSelectionVisibility(rowIsSelected, SelectionInfo as ITreeSelectionInfo, OwnerIsFocused);
end;

//function TDCTreeRow.get_InnerRowControl: TControl;
//begin
//  Result := _innerRowControl;
//end;
//
//procedure TDCTreeRow.set_InnerRowControl(const Value: TControl);
//begin
//  _innerRowControl := Value;
//end;
//
//function TDCTreeRow.get_PlaceInnerRowAtBottom: Boolean;
//begin
//  Result := _placeInnerRowAtBottom;
//end;
//
//procedure TDCTreeRow.set_PlaceInnerRowAtBottom(const Value: Boolean);
//begin
//  _placeInnerRowAtBottom := Value;
//end;
//
//procedure TDCTreeRow.UpdatePositionAndWidthInnerRowControl;
//begin
//  if (_innerRowControl = nil) or not _innerRowControl.Visible then
//    Exit;
//
//  _innerRowControl.Width := Self._control.Width;
//  _innerRowControl.Position.X := 0.0;
//  _innerRowControl.Position.Y := IfThen(_placeInnerRowAtBottom, Self._control.Height - _innerRowControl.Height, 0);
//end;

{ THeaderCell }

function THeaderCell.get_FilterControl: TControl;
begin
  Result := _filterControl;
end;

function THeaderCell.get_ResizeControl: TControl;
begin
  Result := _resizeControl;
end;

function THeaderCell.get_SortControl: TControl;
begin
  Result := _sortControl;
end;

function THeaderCell.IsHeaderCell: Boolean;
begin
  Result := True;
end;

procedure THeaderCell.OnResizeControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Assigned(_onHeaderCellResizeClicked) then
    _onHeaderCellResizeClicked(Self);
end;

procedure THeaderCell.set_FilterControl(const Value: TControl);
begin
  _filterControl := Value;
end;

procedure THeaderCell.set_OnHeaderCellResizeClicked(const Value: TOnHeaderCellResizeClicked);
begin
  _onHeaderCellResizeClicked := Value;
end;

procedure THeaderCell.set_ResizeControl(const Value: TControl);
begin
  if _resizeControl <> nil then
    _resizeControl.Free;

  _resizeControl := Value;

  {$IFNDEF WEBASSEMBLY}
  if _resizeControl <> nil then
    _resizeControl.OnMouseDown := OnResizeControlMouseDown;
  {$ELSE}
  if _resizeControl <> nil then
    _resizeControl.OnMouseDown := @OnResizeControlMouseDown;
  {$ENDIF}
end;

procedure THeaderCell.set_SortControl(const Value: TControl);
begin
  _sortControl := Value;
end;

{ TTreeSelectionInfo }

procedure TTreeSelectionInfo.Clear;
begin
  _lastSelectedLayoutColumn := -1;
  inherited;
end;

procedure TTreeSelectionInfo.ClearMultiSelections;
begin
  inherited;

  if _SelectedLayoutColumns = nil then
    Exit;

  _SelectedLayoutColumns.Clear;
  _SelectedLayoutColumns.Add(_lastSelectedLayoutColumn);
end;

function TTreeSelectionInfo.ColumnIsSelected(const ClmnIndex: Integer): Boolean;
begin
  Result := (get_SelectedLayoutColumn = ClmnIndex) or _SelectedLayoutColumns.Contains(ClmnIndex);
end;

function TTreeSelectionInfo.Clone: IRowSelectionInfo;
begin
  Result := inherited Clone;
  (Result as ITreeSelectionInfo).SelectedLayoutColumn := _lastSelectedLayoutColumn;
end;

constructor TTreeSelectionInfo.Create(const RowsControl: IRowsControl);
begin
  inherited;

  _SelectedLayoutColumns := CList<Integer>.Create;
  _lastSelectedLayoutColumn := -1;
end;

function TTreeSelectionInfo.CreateInstance: IRowSelectionInfo;
begin
  Result := TTreeSelectionInfo.Create(nil {clones don't get the treecontrol, for they dopn't need to make changes});
end;

function TTreeSelectionInfo.get_SelectedLayoutColumn: Integer;
begin
  Result := _lastSelectedLayoutColumn;
end;

function TTreeSelectionInfo.get_SelectedLayoutColumns: List<Integer>;
begin
  Result := _SelectedLayoutColumns;
end;

procedure TTreeSelectionInfo.set_SelectedLayoutColumn(const Value: Integer);
begin
  if _lastSelectedLayoutColumn <> Value then
  begin
    _lastSelectedLayoutColumn := Value;
    DoSelectionInfoChanged;
  end;
end;

{ TDCTreeCheckboxColumn }

constructor TDCTreeCheckboxColumn.Create;
begin
  inherited;

  _infoControlClass := TInfoControlClass.CheckBox;
end;

function TDCTreeCheckboxColumn.CreateInstance: IDCTreeColumn;
begin
  Result := TDCTreeCheckboxColumn.Create;
end;

//function TDCTreeCheckboxColumn.GetDefaultCellData(const Cell: IDCTreeCell; const CellValue: CObject; FormatApplied: Boolean): CObject;
//begin
//  var bool: Boolean;
//  if (CellValue = nil) or not CellValue.TryAsType<Boolean>(bool) then
//    bool := False;
//
//  Result := bool;
//end;

function TDCTreeCheckboxColumn.get_Selectable: Boolean;
begin
  Result := True;
end;

function TDCTreeCheckboxColumn.IsSelectionColumn: Boolean;
begin
  Result := True;
end;

{ TDCColumnSortAndFilter }

procedure TDCColumnSortAndFilter.Assign(const Source: IBaseInterface);
var
  _src: IDCColumnSortAndFilter;

begin
  if Interfaces.Supports(Source, IDCColumnSortAndFilter, _src) then
  begin
    _showFilterMenu := _src.ShowFilterMenu;
    _showSortMenu := _src.ShowSortMenu;
    _sortType := _src.Sort;
  end;
end;

function TDCColumnSortAndFilter.Clone: IDCColumnSortAndFilter;
begin
  var clone := TDCColumnSortAndFilter.Create;
  Result := clone;
  clone.Assign(Self);
end;

function TDCColumnSortAndFilter.get_ShowFilterMenu: Boolean;
begin
  Result := _showFilterMenu;
end;

function TDCColumnSortAndFilter.get_ShowSortMenu: Boolean;
begin
  Result := _showSortMenu;
end;

function TDCColumnSortAndFilter.get_SortType: TSortType;
begin
  Result := _sortType;
end;

procedure TDCColumnSortAndFilter.set_ShowFilterMenu(const Value: Boolean);
begin
  _showFilterMenu := Value;
end;

procedure TDCColumnSortAndFilter.set_ShowSortMenu(const Value: Boolean);
begin
  _showSortMenu := Value;
end;

procedure TDCColumnSortAndFilter.set_SortType(const Value: TSortType);
begin
  _sortType := Value;
end;

{ TDCColumnWidthSettings }

procedure TDCColumnWidthSettings.Assign(const Source: IBaseInterface);
var
  _src: IDCColumnWidthSettings;

begin
  if Interfaces.Supports(Source, IDCColumnWidthSettings, _src) then
  begin
    _width := _src.Width;
    _widthMin := _src.WidthMin;
    _widthMax := _src.WidthMax;
    _widthType := _src.WidthType;
  end;
end;

function TDCColumnWidthSettings.Clone: IDCColumnWidthSettings;
begin
  var clone := TDCColumnWidthSettings.Create;
  Result := clone;
  clone.Assign(Self);
end;

constructor TDCColumnWidthSettings.Create;
begin
  inherited Create;

  _widthType := TDCColumnWidthType.Pixel;
  _width := 50;
end;

function TDCColumnWidthSettings.get_Width: Single;
begin
  if _widthType = TDCColumnWidthType.AlignToContent then
    Result := 0 else
    Result := _width;
end;

function TDCColumnWidthSettings.get_WidthMax: Single;
begin
  if _widthType = TDCColumnWidthType.Pixel then
    Result := _width
  else if SameValue(_widthMin, _widthMax) then
    Result := 0
  else
    Result := _widthMax;

  Result := CMath.Max(Result, 0);
end;

function TDCColumnWidthSettings.get_WidthMin: Single;
begin
  if _widthType = TDCColumnWidthType.Pixel then
    Result := _width
  else if SameValue(_widthMin, _widthMax) then
    Result := 0
  else
    Result := _widthMin;

  Result := CMath.Max(Result, 0);
end;

function TDCColumnWidthSettings.get_WidthType: TDCColumnWidthType;
begin
  Result := _widthType;
end;

procedure TDCColumnWidthSettings.set_Width(const Value: Single);
begin
  _width := Value;
end;

procedure TDCColumnWidthSettings.set_WidthMax(const Value: Single);
begin
  _widthMax := Value;
end;

procedure TDCColumnWidthSettings.set_WidthMin(const Value: Single);
begin
  _widthMin := Value;
end;

procedure TDCColumnWidthSettings.set_WidthType(const Value: TDCColumnWidthType);
begin
  _widthType := Value;
end;

{ TDCColumnSubControlSettings }

procedure TDCColumnSubControlSettings.Assign(const Source: IBaseInterface);
var
  _src: IDCColumnSubControlSettings;

begin
  if Interfaces.Supports(Source, IDCColumnSubControlSettings, _src) then
  begin
    _subPropertyName := _src.SubPropertyName;
    _subInfoControlClass := _src.SubInfoControlClass;
  end;
end;

function TDCColumnSubControlSettings.Clone: IDCColumnSubControlSettings;
begin
  var clone := TDCColumnSubControlSettings.Create;
  Result := clone;
  clone.Assign(Self);
end;

function TDCColumnSubControlSettings.get_SubInfoControlClass: TInfoControlClass;
begin
  Result := _subInfoControlClass;
end;

function TDCColumnSubControlSettings.get_SubPropertyName: CString;
begin
  Result := _subPropertyName;
end;

procedure TDCColumnSubControlSettings.set_SubInfoControlClass(const Value: TInfoControlClass);
begin
  _subInfoControlClass := Value;
end;

procedure TDCColumnSubControlSettings.set_SubPropertyName(const Value: CString);
begin
  _subPropertyName := Value;
end;

{ TDCColumnHierarchy }

procedure TDCColumnHierarchy.Assign(const Source: IBaseInterface);
var
  _src: IDCColumnHierarchy;

begin
  if Interfaces.Supports(Source, IDCColumnHierarchy, _src) then
  begin
    _showHierarchy := _src.ShowHierarchy;
    _indent := _src.Indent;
  end;
end;

function TDCColumnHierarchy.Clone: IDCColumnHierarchy;
begin
  var clone := TDCColumnHierarchy.Create;
  Result := clone;
  clone.Assign(Self);
end;

function TDCColumnHierarchy.get_Indent: Single;
begin
  Result := _indent;
end;

function TDCColumnHierarchy.get_ShowHierarchy: Boolean;
begin
  Result := _showHierarchy;
end;

procedure TDCColumnHierarchy.set_Indent(const Value: Single);
begin
  _indent := Value;
end;

procedure TDCColumnHierarchy.set_ShowHierarchy(const Value: Boolean);
begin
  _showHierarchy := Value;
end;

{ TDCColumnVisualisation }

procedure TDCColumnVisualisation.Assign(const Source: IBaseInterface);
var
  _src: IDCColumnVisualisation;

begin
  if Interfaces.Supports(Source, IDCColumnVisualisation, _src) then
  begin
    _visible := _src.Visible;
    _frozen := _src.Frozen;
    _readOnly := _src.ReadOnly;
    _selectable := _src.Selectable;
    _allowHide := _src.AllowHide;
    _allowResize := _src.AllowResize;
    _hideWhenEmpty := _src.HideWhenEmpty;
    _hideGrid := _src.HideGrid;
    _ignoreHeightByRowCalculation := _src.IgnoreHeightByRowCalculation;
    _format := _src.Format;
    _horzAlign := _src.HorzAlign;
    _vertAlign := _src.VertAlign;
  end;
end;

function TDCColumnVisualisation.Clone: IDCColumnVisualisation;
begin
  var clone := TDCColumnVisualisation.Create;
  Result := clone;
  clone.Assign(Self);
end;

constructor TDCColumnVisualisation.Create;
begin
  inherited Create;

  _visible := True;
  _selectable := True;
  _horzAlign := TDCTextAlign.Default;
  _vertAlign := TDCTextAlign.Default;
end;

function TDCColumnVisualisation.get_Format: CString;
begin
  Result := _format;
end;

function TDCColumnVisualisation.get_HorzAlign: TDCTextAlign;
begin
  Result := _horzAlign;
end;

function TDCColumnVisualisation.get_VertAlign: TDCTextAlign;
begin
  Result := _vertAlign;
end;

function TDCColumnVisualisation.get_Frozen: Boolean;
begin
  Result := _frozen;
end;

function TDCColumnVisualisation.get_HideGrid: Boolean;
begin
  Result := _hideGrid;
end;

function TDCColumnVisualisation.get_HideWhenEmpty: Boolean;
begin
  Result := _hideWhenEmpty;
end;

function TDCColumnVisualisation.get_IgnoreHeightByRowCalculation: Boolean;
begin
  Result := _ignoreHeightByRowCalculation;
end;

function TDCColumnVisualisation.get_ReadOnly: Boolean;
begin
  Result := _readOnly;
end;

function TDCColumnVisualisation.get_Selectable: Boolean;
begin
  Result := _selectable;
end;

function TDCColumnVisualisation.get_Visible: Boolean;
begin
  Result := _visible;
end;

function TDCColumnVisualisation.get_AllowHide: Boolean;
begin
  Result := _allowHide;
end;

function TDCColumnVisualisation.get_AllowResize: Boolean;
begin
  Result := _allowResize;
end;

procedure TDCColumnVisualisation.set_Format(const Value: CString);
begin
  _format := Value;
end;

procedure TDCColumnVisualisation.set_HorzAlign(const Value: TDCTextAlign);
begin
  _horzAlign := Value;
end;

procedure TDCColumnVisualisation.set_VertAlign(const Value: TDCTextAlign);
begin
  _vertAlign := Value;
end;

procedure TDCColumnVisualisation.set_Frozen(const Value: Boolean);
begin
  _frozen := Value;
end;

procedure TDCColumnVisualisation.set_HideGrid(const Value: Boolean);
begin
  _hideGrid := Value;
end;

procedure TDCColumnVisualisation.set_HideWhenEmpty(const Value: Boolean);
begin
  _hideWhenEmpty := Value;
end;

procedure TDCColumnVisualisation.set_IgnoreHeightByRowCalculation(const Value: Boolean);
begin
  _ignoreHeightByRowCalculation := Value;
end;

procedure TDCColumnVisualisation.set_ReadOnly(const Value: Boolean);
begin
  _readOnly := Value;
end;

procedure TDCColumnVisualisation.set_Selectable(Value: Boolean);
begin
  _selectable := Value;
end;

procedure TDCColumnVisualisation.set_AllowHide(const Value: Boolean);
begin
  _allowHide := Value;
end;

procedure TDCColumnVisualisation.set_AllowResize(const Value: Boolean);
begin
  _allowResize := Value;
end;

procedure TDCColumnVisualisation.set_Visible(const Value: Boolean);
begin
  _visible := Value;
end;

{ THeaderColumnResizeControl }

constructor THeaderColumnResizeControl.Create(const TreeControl: IColumnsControl);
begin
  inherited Create;
  _treeControl := TreeControl;
end;

procedure THeaderColumnResizeControl.StartResizing(const HeaderCell: IHeaderCell);
begin
  _headerCell := HeaderCell;

  Assert(_columnResizeControl = nil);
  var ly := TLayout.Create(_treeControl.Control);
  ly.HitTest := True;
  ly.Align := TAlignLayout.None;
  ly.BoundsRect := _headerCell.Row.Control.BoundsRect;
  {$IFNDEF WEBASSEMBLY}
  ly.OnMouseMove := DoSplitterMouseMove;
  ly.OnMouseUp := DoSplitterMouseUp;
  ly.OnMouseLeave := DoSplitterMouseLeave;
  {$ELSE}
  ly.OnMouseMove := @DoSplitterMouseMove;
  ly.OnMouseUp := @DoSplitterMouseUp;
  ly.OnMouseLeave := @DoSplitterMouseLeave;
  {$ENDIF}
  ly.Cursor := crSizeWE;

  _treeControl.Control.AddObject(ly);
  _columnResizeFullHeaderControl := ly;

  var cellRect := TRectangle.Create(_columnResizeFullHeaderControl);
  cellRect.Fill.Color := TAlphaColor($AABBCCDD);
  cellRect.Stroke.Dash := TStrokeDash.Dot;
  cellRect.Align := TAlignLayout.None;
  cellRect.HitTest := False; // Let the mouse move be handled by _columnResizeFullHeaderControl
  cellRect.BoundsRect := _headerCell.Control.BoundsRect;

  var c: TControl := _headerCell.Control;

  cellRect.Position.X := 0;
  while c <> _headerCell.Row.Control do
  begin
    cellRect.Position.X := cellRect.Position.X + c.Position.X;
    c := c.ParentControl;
  end;

  _columnResizeFullHeaderControl.AddObject(cellRect);

  _columnResizeControl := cellRect;
end;

procedure THeaderColumnResizeControl.StopResizing;
begin
  FreeAndNil(_columnResizeFullHeaderControl);
  _columnResizeControl := nil;
end;

procedure THeaderColumnResizeControl.DoSplitterMouseLeave(Sender: TObject);
begin
  TThread.ForceQueue(nil, procedure
  begin
    StopResizing;
  end);
end;

procedure THeaderColumnResizeControl.DoSplitterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  var NewSize := X - _columnResizeControl.Position.X;
  if NewSize < _headerCell.Column.WidthMin then
    NewSize := _headerCell.Column.WidthMin;

  // we accept a column to be more width than maxWidth
//  else if (_headerCell.Column.WidthMax > _headerCell.Column.WidthMin) and (NewSize > _headerCell.Column.WidthMax) then
//    NewSize := _headerCell.Column.WidthMax;

  _columnResizeControl.Size.Width := NewSize;
  _columnResizeFullHeaderControl.Repaint;
end;

procedure THeaderColumnResizeControl.DoSplitterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  _headerCell.Column.CustomWidth := _columnResizeControl.Size.Width;
  _treeControl.ColumnWidthChanged(_headerCell.Column);
  StopResizing;
end;

{ TExpandButton }

constructor TExpandButton.Create(Owner: TComponent);
begin
  inherited;

  _minRect := TRectangle.Create(Self);
  _minRect.Height := 2;
  _minRect.HitTest := False;
  _minRect.Align := TAlignLayout.VertCenter;
  _minRect.XRadius := 1;
  _minRect.YRadius := 2;
  _minRect.Stroke.Kind := TBrushKind.None;
  _minRect.Fill.Color := TAlphaColors.Navy;
  Self.AddObject(_minRect);

  _plusRect := TRectangle.Create(Self);
  _plusRect.Width := 2;
  _plusRect.HitTest := False;
  _plusRect.Align := TAlignLayout.HorzCenter;
  _plusRect.XRadius := 2;
  _plusRect.YRadius := 1;
  _plusRect.Stroke.Kind := TBrushKind.None;
  _plusRect.Fill.Color := TAlphaColors.Navy;
  Self.AddObject(_plusRect);
end;

procedure TExpandButton.DoMouseLeave;
begin
  inherited;

  _minRect.Fill.Color := TAlphaColors.Navy;
  _plusRect.Fill.Color := TAlphaColors.Navy;
end;

procedure TExpandButton.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;

  _minRect.Fill.Color := TAlphaColors.Orange;
  _plusRect.Fill.Color := TAlphaColors.Orange;
end;

procedure TExpandButton.set_ShowExpanded(const Value: Boolean);
begin
  _plusRect.Visible := Value;
end;

{ TDCHeaderRow }

procedure TDCHeaderRow.CreateHeaderControls(const Owner: IColumnsControl);
begin
  _contentControl := DataControlClassFactory.CreateHeaderRect(Owner.Control).AsControl;
  _contentControl.Stored := False;
  _contentControl.Align := TAlignLayout.Top;
  _contentControl.Height := Owner.HeaderHeight;
  Owner.Control.AddObject(_contentControl);

  var headerRect := TLayout.Create(_contentControl);
  headerRect.Stored := False;
  headerRect.Align := TAlignLayout.None;
  headerRect.Height := _contentControl.Height;
  headerRect.HitTest := False;
  _contentControl.AddObject(headerRect);

  set_Control(headerRect);
end;

destructor TDCHeaderRow.Destroy;
begin
  _contentControl.Free;
  _contentControl := nil;
  _control := nil; // already freed by parent above

  inherited;
end;

function TDCHeaderRow.get_ContentControl: TControl;
begin
  Result := _contentControl;
end;

function TDCHeaderRow.get_IsHeaderRow: Boolean;
begin
  Result := True;
end;

{ TFastLayout }

procedure TFastLayout.DoPaint;
begin
  inherited;

  Self.Canvas.Stroke.Kind := TBrushKind.None;
  Self.Canvas.Fill.Color := TAlphaColors.Slategray;

  var rect := RectF(5, 5, Self.Width - 10, 15);
  Self.Canvas.FillRect(rect, 3, 3, AllCorners, 0.3, TCornerType.Round);
end;

end.

