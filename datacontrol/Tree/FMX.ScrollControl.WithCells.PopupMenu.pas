unit FMX.ScrollControl.WithCells.PopupMenu;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Effects,
  FMX.ImgList,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Objects,
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Types,
  Wasm.System.UITypes,
  Wasm.System.Classes,

  Wasm.FMX.Types,
  Wasm.FMX.Controls,
  Wasm.FMX.Forms,
  Wasm.FMX.Graphics,
  Wasm.FMX.Dialogs,
  Wasm.FMX.ListBox,
  Wasm.FMX.Layouts,
  Wasm.FMX.Effects,
  Wasm.FMX.ImgList,
  Wasm.FMX.Controls.Presentation,
  Wasm.FMX.Edit,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Objects,
  {$ENDIF}
  System.Variants,
  System.ImageList,
  System.Math,
  System.Collections.Generic,
  System_,
  System.Collections,
  System.Generics.Defaults,
  System.ComponentModel,

  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.Impl,
  FMX.ScrollControl.WithRows.Impl,
  FMX.ScrollControl.WithEditableCells.Impl,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.Events,
  FMX.ScrollControl.DataControl.Impl, FMX.TabControl, FMX.DateTimeCtrls;

type
  TfrmFMXPopupMenuDataControl = class(TForm)
    PopupListBox: TListBox;
    lbiSortSmallToLarge: TListBoxItem;
    lbiSortLargeToSmall: TListBoxItem;
    lbiClearFilter: TListBoxItem;
    lbiClearSortAndFilter: TListBoxItem;
    lbiHideColumn: TListBoxItem;
    ImageListPopup: TImageList;
    lbiDelimiter: TListBoxItem;
    lbiAddColumnAfter: TListBoxItem;
    lbiDelimiter2: TListBoxItem;
    filterlist: TRectangle;
    Layout1: TLayout;
    cbSelectAll: TCheckBox;
    edSearch: TEdit;
    btnApplyFilters: TButton;
    Timer1: TTimer;
    Line1: TLine;
    lyListBoxBackGround: TLayout;
    tcFilterControls: TTabControl;
    tsTreeControl: TTabItem;
    tsDateRange: TTabItem;
    dtpFrom: TDateEdit;
    dtpTo: TDateEdit;
    lblFrom: TLabel;
    lblTo: TLabel;
    btnApplyDateRange: TButton;
    procedure btnApplyDateRangeClick(Sender: TObject);
    procedure btnApplyFiltersClick(Sender: TObject);
    procedure cbSelectAllClick(Sender: TObject);
    procedure dtpFromChange(Sender: TObject);
    procedure edSearchChangeTracking(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure lbiSortSmallToLargeClick(Sender: TObject);
    procedure lbiSortLargeToSmallClick(Sender: TObject);
    procedure lbiAddColumnAfterClick(Sender: TObject);
    procedure lbiHideColumnClick(Sender: TObject);
    procedure lbiClearFilterClick(Sender: TObject);
    procedure lbiClearSortAndFilterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
        Shift: TShiftState);
    procedure lbiSortSmallToLargeMouseEnter(Sender: TObject);
    procedure lbiSortSmallToLargeMouseLeave(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  public type
    TPopupResult = (ptCancel, ptSortAscending, ptSortDescending, ptAddColumnAfter, ptHideColumn, ptClearFilter, ptClearSortAndFilter, ptClearAll, ptFilter, ptFilterDateRange);

  private
  {$IFNDEF WEBASSEMBLY}
  strict private
  {$ELSE}
  private
  {$ENDIF}

    _PopupResult: TPopupResult;
    _dataControl: TDataControl;
    _data: Dictionary<CObject, CString>;

    [unsafe] _LayoutColumn: IDCTreeLayoutColumn;

    procedure CreateItemFiltersControls;
    procedure SetAllowClearColumnFilter(Value: Boolean);

    function  get_LayoutColumn: IDCTreeLayoutColumn;
    procedure set_LayoutColumn(const Value: IDCTreeLayoutColumn);
    function  get_Start: CDateTime;
    procedure set_Start(const Value: CDateTime);
    function  get_Stop: CDateTime;
    procedure set_Stop(const Value: CDateTime);

    procedure TreeCellSelected(const Sender: TObject; e: DCCellSelectedEventArgs);
    procedure TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);

  public
    destructor Destroy; override;

    procedure ShowPopupMenu(const ScreenPos: TPointF; ShowItemFilters, ShowItemSortOptions, ShowItemAddColumAfter, ShowItemHideColumn: Boolean);
    function  SelectedItems(out NullValueSelected: Boolean) : List<CObject>;

    procedure EnableItem(Index: integer; Value: boolean);
    procedure LoadFilterItems(const Data: Dictionary<CObject, CString>; const Comparer: IComparer<CObject>; const Selected: List<CObject>;
      ShowNullValue: Boolean; SelectNullValue: Boolean; UseTextCompare: Boolean);
    procedure LoadDateRange(const Start: CDateTime; const Stop: CDateTime; ShowTimeValue: Boolean);

    property  PopupResult: TPopupResult read _PopupResult;
    property  AllowClearColumnFilter: Boolean write SetAllowClearColumnFilter;
    property  Start: CDateTime read get_Start write set_Start;
    property  Stop: CDateTime read get_Stop write set_Stop;
    property LayoutColumn: IDCTreeLayoutColumn read get_LayoutColumn write set_LayoutColumn;
  end;

implementation

uses
  FMX.ScrollControl.SortAndFilter,
  FMX.ScrollControl.WithRows.Intf;

{$R *.fmx}

procedure TfrmFMXPopupMenuDataControl.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Instead of this FormClose will be called TCustomTreeControl.HeaderPopupMenu_Closed!
end;

procedure TfrmFMXPopupMenuDataControl.EnableItem(Index: integer; Value: boolean);
begin
  with PopupListBox.ListItems[Index] do
  begin
    Enabled := Value;
    Selectable := Value;
  end;
end;

procedure TfrmFMXPopupMenuDataControl.ShowPopupMenu(const ScreenPos: TPointF; ShowItemFilters, ShowItemSortOptions, ShowItemAddColumAfter, ShowItemHideColumn: Boolean);
{ • ShowItemFilters - Tree and filters search box, Clear Filter
  • ShowItemSortOptions - Sort items(2), Clear All (Filter + Sort) }

  procedure CalculateMenuHeight;
  var
    item: TListBoxItem;
  begin
    var lbHeight: Double := 6;
    var filterListHeight := 0;

    var i: Integer;
    for i := 0 to PopupListBox.Count - 1 do
    begin
      item := PopupListBox.ListItems[i];
      if item.Visible then
        lbHeight := lbHeight + PopupListBox.ListItems[i].Height;
      if item.IsSelected then
        item.IsSelected := false;
    end;

    if filterlist.Visible then
      filterListHeight := 202;

    lyListBoxBackGround.Height := lbHeight;
    Height := Ceil(lbHeight + filterListHeight + {Padding.Bottom + Padding.Top + 1 +} 20);
  end;

begin
  _PopupResult := TPopupResult.ptCancel;

  Timer1.Enabled := True;

  PopupListBox.StylesData['background.Visible'] := False;
  btnApplyFilters.Enabled := False;
  btnApplyDateRange.Enabled := False;

  Left := Trunc(ScreenPos.X);
  Top := Trunc(ScreenPos.Y);

  if ShowItemFilters then
    CreateItemFiltersControls;

  // ShowItemSortOptions
  lbiSortSmallToLarge.Visible := ShowItemSortOptions;
  lbiSortLargeToSmall.Visible := ShowItemSortOptions;
  lbiClearFilter.Visible := ShowItemFilters;
  filterlist.Visible := ShowItemFilters;
  lbiClearSortAndFilter.Visible := ShowItemFilters or ShowItemSortOptions;

  lbiAddColumnAfter.Visible := ShowItemAddColumAfter;
  lbiHideColumn.Visible := ShowItemHideColumn;

  CalculateMenuHeight;

  Show;
end;

procedure TfrmFMXPopupMenuDataControl.CreateItemFiltersControls;
begin
  if _dataControl <> nil then
    Exit;

  _dataControl := TDataControl.Create(Self);
  _dataControl.Align := TAlignLayout.Client;
  _dataControl.Options := [TDCTreeOption.MultiSelect];
  _dataControl.RowHeightFixed := 26;
  _dataControl.CellSelected := TreeCellSelected;
  _dataControl.CellFormatting := TreeCellFormatting;

  filterlist.AddObject(_dataControl);

  var column1: IDCTreeCheckboxColumn := TDCTreeCheckboxColumn.Create;
  column1.WidthSettings.WidthType := TDCColumnWidthType.Pixel;
  column1.WidthSettings.Width := 30;
  column1.Caption := '*';
  _dataControl.Columns.Add(column1);

  var column2: IDCTreeColumn := TDCTreeColumn.Create;
  column2.PropertyName := '[object]';
  column2.Visualisation.ReadOnly := True;
  column2.WidthSettings.WidthType := TDCColumnWidthType.Percentage;
  column2.WidthSettings.Width := 100;
  _dataControl.Columns.Add(column2);
end;

destructor TfrmFMXPopupMenuDataControl.Destroy;
begin

  inherited;
end;

procedure TfrmFMXPopupMenuDataControl.btnApplyDateRangeClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptFilterDateRange;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.LoadFilterItems(const Data: Dictionary<CObject, CString>;
    const Comparer: IComparer<CObject>; const Selected: List<CObject>;
    ShowNullValue: Boolean; SelectNullValue: Boolean; UseTextCompare: Boolean);
begin
  tcFilterControls.ActiveTab := tsTreeControl;

  _data := Data;
  var items: List<CObject> := CList<CObject>.Create(Data.Keys);

  items.Sort(
      function (const x, y: CObject): Integer
      begin
        if (Comparer <> nil) then
          Result := Comparer.Compare(x, y)
        else if UseTextCompare then
          Result := CString.Compare(Data[x], Data[y])
        else
          Result := CObject.Compare(x, y);
      end);

  if ShowNullValue then
    items.Insert(0, NO_VALUE);

  _dataControl.DataList := items as IList;

  if Selected <> nil then
    _dataControl.AssignSelection(Selected as IList);

  if SelectNullValue then
    _dataControl.SelectItem(NO_VALUE, False);
end;

procedure TfrmFMXPopupMenuDataControl.LoadDateRange(const Start: CDateTime; const Stop: CDateTime; ShowTimeValue: Boolean);
begin
  tcFilterControls.ActiveTab := tsDateRange;
  dtpFrom.Date := Start;
  dtpTo.Date := Stop;
  btnApplyDateRange.Enabled := False;
end;

function TfrmFMXPopupMenuDataControl.get_LayoutColumn: IDCTreeLayoutColumn;
begin
  Result := _LayoutColumn;
end;

function TfrmFMXPopupMenuDataControl.get_Start: CDateTime;
begin
  Result := dtpFrom.DateTime;
end;

function TfrmFMXPopupMenuDataControl.get_Stop: CDateTime;
begin
  Result := dtpTo.DateTime;
end;

function TfrmFMXPopupMenuDataControl.SelectedItems(out NullValueSelected: Boolean) : List<CObject>;
begin
  var selected := _dataControl.SelectedItems;
  NullValueSelected := False;

  Result := CList<CObject>.Create(selected.Count);

  for var item in selected do
  begin
    if item.IsString and CObject.Equals(item, NO_VALUE) then
    begin
      NullValueSelected := True;
      continue;
    end;
    Result.Add(item);
  end;
end;

procedure TfrmFMXPopupMenuDataControl.SetAllowClearColumnFilter(Value: Boolean);
begin
  EnableItem(lbiClearFilter.Index, Value);
end;

procedure TfrmFMXPopupMenuDataControl.set_LayoutColumn(const Value: IDCTreeLayoutColumn);
begin
  _LayoutColumn := Value;
end;

procedure TfrmFMXPopupMenuDataControl.set_Start(const Value: CDateTime);
begin
  dtpFrom.DateTime := Value;
end;

procedure TfrmFMXPopupMenuDataControl.set_Stop(const Value: CDateTime);
begin
  dtpTo.DateTime := Value;
end;

//procedure TfrmFMXPopupMenu.set_Items(const Value: List<IFilterItem>);
//begin
//  _Items := Value;
//  filterList.DataList := _Items as IList;
//end;

procedure TfrmFMXPopupMenuDataControl.btnApplyFiltersClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptFilter;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.cbSelectAllClick(Sender: TObject);
begin
  TThread.ForceQueue(nil, procedure
  begin
    if cbSelectAll.IsChecked then
      _dataControl.SelectAll else
      _dataControl.ClearSelections;
  end);
end;

procedure TfrmFMXPopupMenuDataControl.dtpFromChange(Sender: TObject);
begin
  btnApplyDateRange.Enabled := True;
end;

procedure TfrmFMXPopupMenuDataControl.TreeCellSelected(const Sender: TObject; e: DCCellSelectedEventArgs);
begin
  btnApplyFilters.Enabled := True;
end;

procedure TfrmFMXPopupMenuDataControl.edSearchChangeTracking(Sender: TObject);
begin
//  var filterByText: IListFilterDescription := TTreeFilterDescription.Create(_dataControl.Layout.FlatColumns[1] , _dataControl.OnGetCellDataForSorting);
//  (filterByText as TTreeFilterDescription).FilterText := edSearch.Text.ToLower;
//
//  _dataControl.AddFilterDescription(filterByText, True);

  _dataControl.UpdateColumnFilter(_dataControl.Columns[1], edSearch.Text.ToLower, nil, False);
end;

procedure TfrmFMXPopupMenuDataControl.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Timer1.Enabled := False;
end;

procedure TfrmFMXPopupMenuDataControl.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TfrmFMXPopupMenuDataControl.lbiSortSmallToLargeClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptSortAscending;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiSortLargeToSmallClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptSortDescending;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiAddColumnAfterClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptAddColumnAfter;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiHideColumnClick(Sender: TObject);
begin
 _PopupResult := TPopupResult.ptHideColumn;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiClearSortAndFilterClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptClearSortAndFilter;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiClearFilterClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptClearFilter;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.lbiSortSmallToLargeMouseEnter(Sender: TObject);
begin
  (Sender as TListBoxItem).Opacity := 0.5;
end;

procedure TfrmFMXPopupMenuDataControl.lbiSortSmallToLargeMouseLeave(Sender: TObject);
begin
  (Sender as TListBoxItem).Opacity := 1;
end;

procedure TfrmFMXPopupMenuDataControl.Timer1Timer(Sender: TObject);
begin
  if (_dataControl <> nil) and (_dataControl.View <> nil) and (_dataControl.SelectedItems <> nil) then
    cbSelectAll.IsChecked := _dataControl.View.ViewCount = _dataControl.SelectedItems.Count;
end;

procedure TfrmFMXPopupMenuDataControl.TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);
begin
  if e.Cell.IsHeaderCell then
    Exit;

  var s: CString;
  if _data.TryGetValue(e.value, s) then
  begin
    e.Value := s;
    e.FormattingApplied := True;
  end;

//  if (e.Value = nil) or (e.Value.GetType.IsDateTime and CDateTime(e.Value).Equals(CDateTime.MinValue)) then
//  begin
//    e.Value := 'no value';
//    e.FormattingApplied := True;
//  end;
end;

end.
