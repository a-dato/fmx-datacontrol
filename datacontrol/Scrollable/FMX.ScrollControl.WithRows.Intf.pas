unit FMX.ScrollControl.WithRows.Intf;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls, 
  System.SysUtils,
  System.ComponentModel,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.ComponentModel,
  {$ENDIF}
  System_, 
  System.Collections.Generic, 
  ADato.Data.DataModel.intf, FMX.ScrollControl.Intf;

type
  TSelectionType = (HideSelection, CellSelection, RowSelection);

  TTreeRowState = (SortChanged, FilterChanged, RowChanged);
  TTreeRowStateFlags = set of TTreeRowState;
  TAlignDirection = (Undetermined, TopToBottom, BottomToTop);
  TSelectionEventTrigger = record
  const
    Internal = 0;
    External = 1;
    Click = 2;
    Key = 3;
  private
    value: Integer;
  public
    function IsUserEvent: Boolean;

    class operator Equal(const L, R: TSelectionEventTrigger) : Boolean;
    class operator NotEqual(const L, R: TSelectionEventTrigger) : Boolean;
    class operator Implicit(AValue: Integer) : TSelectionEventTrigger;
    class operator Implicit(const AValue: TSelectionEventTrigger) : Integer;
  end;

//(DataChanged {data list changed}, SortChanged)
//  ColumnsChanged, {DataBindingChanged {data source changed}}, ViewChanged, Refresh, OptionsChanged, CurrentRowChangedFromDataModel, CellChanged);

  TDoRowExpandCollapse = reference to procedure(const ViewListIndex: Integer);

  TSelectionCanChange = reference to function: Boolean;

  IDCRow = interface;

  IRowsControl = interface(IScrollControl)
    ['{DFFB7FC1-1AA5-419B-8125-6106792603B2}']
    function  get_AllowNoneSelected: Boolean;
    procedure set_AllowNoneSelected(const Value: Boolean);
    function  get_SelectionType: TSelectionType;
    procedure set_SelectionType(const Value: TSelectionType);

    procedure OnSelectionInfoChanged;

    function  ViewIsDataModelView: Boolean;
    function  GetDataModelView: IDataModelView;
    function  GetDataModel: IDataModel;

    property AllowNoneSelected: Boolean read get_AllowNoneSelected write set_AllowNoneSelected;
    property SelectionType: TSelectionType read get_SelectionType write set_SelectionType;
  end;

  TDataIndexArray = array of Integer;
  IRowSelectionInfo = interface
    ['{FC3AA96A-7C9A-4965-8329-3AC17AE28728}']
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

    procedure Clear;
    procedure ClearAllSelections;
    procedure ClearMultiSelections;

    function  CanSelect(const DataIndex: Integer): Boolean;
    function  HasSelection: Boolean;
    function  IsSelected(const DataIndex: Integer): Boolean;
    function  GetSelectionInfo(const DataIndex: Integer): IRowSelectionInfo;

    function  SelectedRowCount: Integer;
    function  SelectedDataIndexes: List<Integer>;

    procedure BeginUpdate;
    procedure EndUpdate(IgnoreChangeEvent: Boolean = False);

    function  Clone: IRowSelectionInfo;
    function  SelectionType: TSelectionType;

    procedure UpdateLastSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);

    procedure UpdateSingleSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
    procedure AddToSelection(const DataIndex, ViewListIndex: Integer; const DataItem: CObject);
    procedure Deselect(const DataIndex: Integer);
    procedure SelectedRowClicked(const DataIndex: Integer);

    property DataIndex: Integer read get_DataIndex;
    property DataItem: CObject read get_DataItem;
    property ViewListIndex: Integer read get_ViewListIndex;
    property IsMultiSelection: Boolean read get_IsMultiSelection;
//    property ForceScrollToSelection: Boolean read get_ForceScrollToSelection write set_ForceScrollToSelection;
    property LastSelectionEventTrigger: TSelectionEventTrigger read get_EventTrigger write set_EventTrigger;

    property NotSelectableDataIndexes: TDataIndexArray read get_NotSelectableDataIndexes write set_NotSelectableDataIndexes;
  end;

  IDCRow = interface(IBaseInterface)
    ['{C9AFABA4-644A-4FA7-A911-AC6ACFD7C608}']
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
    procedure set_Control(const Value: TControl);
    function  get_IsHeaderRow: Boolean;
    function  get_Enabled: Boolean;
    procedure set_Enabled(const Value: Boolean);
    function  get_CustomTag: CObject;
    procedure set_CustomTag(const Value: CObject);

    function  get_OwnerIsScrolling: Boolean;
    procedure set_OwnerIsScrolling(const Value: Boolean);

    function  Height: Single;
    function  HasChildren: Boolean;
    function  HasVisibleChildren: Boolean;
    function  ParentCount: Integer;
    function  IsOddRow: Boolean;

    procedure ClearRowForReassignment;
    function  IsClearedForReassignment: Boolean;
    function  IsScrollingIntoView: Boolean;

    procedure UpdateSelectionVisibility(const SelectionInfo: IRowSelectionInfo; OwnerIsFocused: Boolean);

    property DataIndex: Integer read get_DataIndex write set_DataIndex;
    property DataItem: CObject read get_DataItem write set_DataItem;
    property ConvertedDataItem: CObject read get_ConvertedDataItem;
    property ViewPortIndex: Integer read get_ViewPortIndex write set_ViewPortIndex;
    property ViewListIndex: Integer read get_ViewListIndex write set_ViewListIndex;
    property VirtualYPosition: Single read get_VirtualYPosition write set_VirtualYPosition;
    property Control: TControl read get_Control write set_Control;
    property IsHeaderRow: Boolean read get_IsHeaderRow;
    property Enabled: Boolean read get_Enabled write set_Enabled;

    // control below can be used to insert custom controls and recycle them if needed.
    property CustomTag: CObject read get_CustomTag write set_CustomTag;

    property OwnerIsScrolling: Boolean read get_OwnerIsScrolling write set_OwnerIsScrolling;
  end;

  TDoCreateNewRow = reference to function: IDCRow;

  TResetViewRec = record
  private
    _doResetView: Boolean;
    _resetViewIndex: Integer;
    _resetViewOneRowOnly: Boolean;
    _doRecalcSortedRows: Boolean;

  public
    function DoResetView: Boolean;
    function FromIndex: Integer;
    function OneRowOnly: Boolean;
    function RecalcSortedRows: Boolean;

    class function CreateNull: TResetViewRec; static;
    class function CreateNew(const Index: Integer; const OneRowOnly, RecalcSortedRows: Boolean): TResetViewRec; static;
    class function CreateFrom(const Index: Integer; const OneRowOnly, RecalcSortedRows: Boolean; const Existing: TResetViewRec): TResetViewRec; static;
  end;

  IWaitForRepaintInfo = interface
    ['{BA3C974D-09FF-42BD-887F-0D4523D8BDF1}']
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

    procedure ClearIrrelevantInfo;

    property RowStateFlags: TTreeRowStateFlags read get_RowStateFlags write set_RowStateFlags;
    property Current: Integer read get_Current write set_Current;
    property DataItem: CObject read get_DataItem write set_DataItem;
    property SortDescriptions: List<IListSortDescription> read get_SortDescriptions write set_SortDescriptions;
    property FilterDescriptions: List<IListFilterDescription> read get_FilterDescriptions write set_FilterDescriptions;
  end;

  TDCTreeOptionFlag = (
    TreeOption_ShowHeaders,
    TreeOption_ShowHeaderGrid,
    TreeOption_ShowVertGrid,
    TreeOption_ShowHorzGrid,

    TreeOption_HideVScrollBar,
    TreeOption_HideHScrollBar,

    TreeOption_AlternatingRowBackground,
    TreeOption_HideHoverEffect,
    TreeOption_ReadOnly,
    TreeOption_MultiSelect,
    TreeOption_AllowColumnUpdates,
    TreeOption_AllowAddNewRows,
    TreeOption_AllowDeleteRows
//    TreeOption_AutoCommit,
//    TreeOption_DisplayPartialRows
//    TreeOption_AssumeObjectTypesDiffer,
//    TreeOption_ShowDragImage,
//    TreeOption_ShowDragEffects,
//    TreeOption_CheckPropertyNames,
//    TreeOption_ColumnsCanResize,
//    TreeOption_ColumnsCanMove,
//    TreeOption_AllowColumnUpdates,
//    TreeOption_ScrollThroughRows,
//    TreeOption_AlwaysShowEditor,
//    TreeOption_DoNotTranslateCaption,
//    TreeOption_PreserveRowHeights
    );

//    TreeOption_AllowCellSelection,
//    TreeOption_GoRowSelection,
//    TreeOption_GoRowFocusRectangle,
//    TreeOption_HideFocusRectangle,

  TDCTreeOption = record
  const
    ShowHeaders: TDCTreeOptionFlag = TreeOption_ShowHeaders;
    ShowHeaderGrid: TDCTreeOptionFlag = TreeOption_ShowHeaderGrid;
    ShowVertGrid: TDCTreeOptionFlag = TreeOption_ShowVertGrid;
    ShowHorzGrid: TDCTreeOptionFlag = TreeOption_ShowHorzGrid;
    HideVScrollBar: TDCTreeOptionFlag = TreeOption_HideVScrollBar;
    HideHScrollBar: TDCTreeOptionFlag = TreeOption_HideHScrollBar;
    AlternatingRowBackground: TDCTreeOptionFlag = TreeOption_AlternatingRowBackground;
    HideHoverEffect: TDCTreeOptionFlag = TreeOption_HideHoverEffect;
    ReadOnly: TDCTreeOptionFlag = TreeOption_ReadOnly;
    MultiSelect: TDCTreeOptionFlag = TreeOption_MultiSelect;
    AllowColumnUpdates: TDCTreeOptionFlag = TreeOption_AllowColumnUpdates;
    AllowAddNewRows: TDCTreeOptionFlag = TreeOption_AllowAddNewRows;
    AllowDeleteRows: TDCTreeOptionFlag = TreeOption_AllowDeleteRows;
//    AutoCommit: TDCTreeOptionFlag = TreeOption_AutoCommit;
//    AllowCellSelection: TDCTreeOptionFlag = TreeOption_AllowCellSelection;
//    DisplayPartialRows: TDCTreeOptionFlag = TreeOption_DisplayPartialRows;
//    AssumeObjectTypesDiffer: TDCTreeOptionFlag = TreeOption_AssumeObjectTypesDiffer;
//    ShowDragImage: TDCTreeOptionFlag = TreeOption_ShowDragImage;
//    ShowDragEffects: TDCTreeOptionFlag = TreeOption_ShowDragEffects;
//    CheckPropertyNames: TDCTreeOptionFlag = TreeOption_CheckPropertyNames;
//    GoRowSelection: TDCTreeOptionFlag = TreeOption_GoRowSelection;
//    GoRowFocusRectangle: TDCTreeOptionFlag = TreeOption_GoRowFocusRectangle;
//    ColumnsCanResize: TDCTreeOptionFlag = TreeOption_ColumnsCanResize;
//    ColumnsCanMove: TDCTreeOptionFlag = TreeOption_ColumnsCanMove;
//    AllowColumnUpdates: TDCTreeOptionFlag = TreeOption_AllowColumnUpdates;
//    HideFocusRectangle: TDCTreeOptionFlag = TreeOption_HideFocusRectangle;
//    ScrollThroughRows: TDCTreeOptionFlag = TreeOption_ScrollThroughRows;
//    AlwaysShowEditor: TDCTreeOptionFlag = TreeOption_AlwaysShowEditor;
//    DoNotTranslateCaption: TDCTreeOptionFlag = TreeOption_DoNotTranslateCaption;
//    PreserveRowHeights: TDCTreeOptionFlag = TreeOption_PreserveRowHeights;
  end;

  TDCTreeOptions = set of TDCTreeOptionFlag;

const
  ROW_CONTENT_MARGIN = 5;

implementation

{ TSelectionEventTrigger }

function TSelectionEventTrigger.IsUserEvent: Boolean;
begin
  Result := (value in [TSelectionEventTrigger.Click, TSelectionEventTrigger.Key]);
end;

class operator TSelectionEventTrigger.Equal(const L, R: TSelectionEventTrigger): Boolean;
begin
  Result := L.value = R.value;
end;

class operator TSelectionEventTrigger.NotEqual(const L, R: TSelectionEventTrigger): Boolean;
begin
  Result := L.value <> R.value;
end;

class operator TSelectionEventTrigger.Implicit(AValue: Integer): TSelectionEventTrigger;
begin
  Result.value := AValue;
end;

class operator TSelectionEventTrigger.Implicit(const AValue: TSelectionEventTrigger): Integer;
begin
  Result := AValue.value;
end;

{ TResetViewRec }

class function TResetViewRec.CreateFrom(const Index: Integer; const OneRowOnly, RecalcSortedRows: Boolean; const Existing: TResetViewRec): TResetViewRec;
begin
  if not Existing._doResetView then
    Result := TResetViewRec.CreateNew(Index, OneRowOnly, RecalcSortedRows)
  else begin
    var ixMin := CMath.Min(Existing._resetViewIndex, Index);
    var resetOnlyOneRow := Existing._resetViewOneRowOnly and OneRowOnly and (Existing._resetViewIndex = Index);
    var recalcSorting := Existing._doRecalcSortedRows or RecalcSortedRows;

    Result := TResetViewRec.CreateNew(ixMin, resetOnlyOneRow, recalcSorting);
  end;
end;

class function TResetViewRec.CreateNew(const Index: Integer; const OneRowOnly, RecalcSortedRows: Boolean): TResetViewRec;
begin
  Result._doResetView := True;
  Result._resetViewIndex := Index;
  Result._resetViewOneRowOnly := OneRowOnly;
  Result._doRecalcSortedRows := RecalcSortedRows;
end;

class function TResetViewRec.CreateNull: TResetViewRec;
begin
  Result._doResetView := False;
  Result._resetViewIndex := -1;
  Result._resetViewOneRowOnly := True;
  Result._doRecalcSortedRows := False;
end;

function TResetViewRec.DoResetView: Boolean;
begin
  Result := _doResetView;
end;

function TResetViewRec.FromIndex: Integer;
begin
  Result := _resetViewIndex;
end;

function TResetViewRec.OneRowOnly: Boolean;
begin
  Result := _resetViewOneRowOnly;
end;

function TResetViewRec.RecalcSortedRows: Boolean;
begin
  Result := _doRecalcSortedRows;
end;

end.
