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
  TfrmFMXPopupMenuDataControl = class(TForm, IHeaderPopupMenu)
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
    lbiClearSort: TListBoxItem;
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
    procedure lbiClearSortClick(Sender: TObject);
    procedure lbiClearSortAndFilterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
        Shift: TShiftState);
    procedure lbiSortSmallToLargeMouseEnter(Sender: TObject);
    procedure lbiSortSmallToLargeMouseLeave(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  public type
    TPopupResult = TDCHeaderPopupResult;

  private
  {$IFNDEF WEBASSEMBLY}
  strict private
  {$ELSE}
  private
  {$ENDIF}

    _PopupResult: TPopupResult;
    _dataControl: TDataControl;
    _data: Dictionary<CObject, CString>;
    _filterPages: IList<IDCHeaderFilterPage>;
    _propertyTabs: TTabControl;
    _loadingPage: Boolean;
    _activePageIndex: Integer;

    [unsafe] _LayoutColumn: IDCTreeLayoutColumn;

    procedure CreateItemFiltersControls;
    procedure SetAllowClearColumnFilter(Value: Boolean);
    procedure EnsurePropertyTabs;
    function  VisibleListHeight(const List: TListBox): Single;
    procedure SetItemEnabled(const Item: TListBoxItem; Value: Boolean);
    procedure UpdateSortFilterActions;
    procedure UpdateActionCaptions;
    procedure ClearFilterPage(const PageIndex: Integer);
    function  IndexOfActiveFilterPage: Integer;
    procedure SaveActiveFilterPage;
    procedure ShowFilterPage(const PageIndex: Integer);
    procedure PropertyTabsChange(Sender: TObject);
    procedure CloseWithFilterResult(const SingleResult: TPopupResult);
    procedure MarkActivePageModified;

    function  get_LayoutColumn: IDCTreeLayoutColumn;
    procedure set_LayoutColumn(const Value: IDCTreeLayoutColumn);
    function  get_Start: CDateTime;
    procedure set_Start(const Value: CDateTime);
    function  get_Stop: CDateTime;
    procedure set_Stop(const Value: CDateTime);
    function  get_PopupResult: TDCHeaderPopupResult;
    function  get_FilterPages: IList<IDCHeaderFilterPage>;
    function  get_ActiveFilterPropertyName: CString;
    function  get_ImageList: TCustomImageList;

    procedure IHeaderPopupMenu.set_AllowClearColumnFilter = SetAllowClearColumnFilter;

    procedure TreeCellSelected(const Sender: TObject; e: DCSelectionEvent);
    procedure TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);

  public
    destructor Destroy; override;

    procedure ShowPopupMenu(const ScreenPos: TPointF; ShowItemFilters, ShowItemSortOptions, ShowItemAddColumAfter, ShowItemHideColumn: Boolean);
    function  SelectedItems(out NullValueSelected: Boolean) : List<CObject>;

    procedure EnableItem(Index: integer; Value: boolean);
    procedure LoadFilterItems(const Data: Dictionary<CObject, CString>; const Comparer: IComparer<CObject>; const Selected: List<CObject>; ShowNullValue: Boolean; SelectNullValue: Boolean; UseTextCompare: Boolean);
    procedure LoadDateRange(const Start: CDateTime; const Stop: CDateTime; ShowTimeValue: Boolean);
    procedure LoadFilterPages(const Pages: IList<IDCHeaderFilterPage>);

    property  PopupResult: TPopupResult read _PopupResult;
    property  FilterPages: IList<IDCHeaderFilterPage> read get_FilterPages;
    property  ActiveFilterPropertyName: CString read get_ActiveFilterPropertyName;
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

function TfrmFMXPopupMenuDataControl.VisibleListHeight(const List: TListBox): Single;
begin
  Result := 0;
  var itemIndex: Integer;
  for itemIndex := 0 to List.Count - 1 do
  begin
    var item := List.ListItems[itemIndex];
    if item.IsSelected then
      item.IsSelected := False;
    if item.Visible then
      Result := Result + item.Height;
  end;
end;

procedure TfrmFMXPopupMenuDataControl.SetItemEnabled(const Item: TListBoxItem; Value: Boolean);
begin
  Item.Enabled := Value;
  Item.Selectable := Value;
end;

function TfrmFMXPopupMenuDataControl.IndexOfActiveFilterPage: Integer;
begin
  Result := 0;
  if (_LayoutColumn = nil) or (_filterPages = nil) then
    Exit;

  var pageIndex: Integer;
  for pageIndex := 0 to _filterPages.Count - 1 do
  begin
    var page := _filterPages[pageIndex];
    var active: ITreeFilterDescription;
    if CString.IsNullOrEmpty(page.PropertyName) then
      active := _LayoutColumn.ActiveFilter
    else
      active := _LayoutColumn.PropertyFilter(page.PropertyName);

    if active <> nil then
      Exit(pageIndex);
  end;
end;

procedure TfrmFMXPopupMenuDataControl.ClearFilterPage(const PageIndex: Integer);
begin
  if (_filterPages = nil) or (PageIndex < 0) or (PageIndex >= _filterPages.Count) then
    Exit;

  var page := _filterPages[PageIndex];
  page.Selected := nil;
  page.SelectNullValue := False;
  page.Modified := False;

  if (_LayoutColumn = nil) or (_LayoutColumn.Column = nil) or (_LayoutColumn.Column.TreeControl = nil) then
    Exit;

  var tree := _LayoutColumn.Column.TreeControl.Control as TScrollControlWithCells;
  tree.UpdateColumnFilter(_LayoutColumn.Column, '', nil, False, page.PropertyName);
end;

procedure TfrmFMXPopupMenuDataControl.UpdateSortFilterActions;
begin
  var hasFilter := (_LayoutColumn <> nil) and _LayoutColumn.HasActiveFilter;
  var hasSort := (_LayoutColumn <> nil) and (_LayoutColumn.ActiveSort <> nil);

  SetItemEnabled(lbiClearFilter, hasFilter);
  SetItemEnabled(lbiClearSort, hasSort);
  SetItemEnabled(lbiClearSortAndFilter, hasFilter or hasSort);
  UpdateActionCaptions;
end;

procedure TfrmFMXPopupMenuDataControl.UpdateActionCaptions;
begin
  var suffix: CString := '';
  if (_filterPages <> nil) and (_filterPages.Count > 1) and (_activePageIndex >= 0) and (_activePageIndex < _filterPages.Count) then
  begin
    var tabCaption := _filterPages[_activePageIndex].Caption;
    if not CString.IsNullOrEmpty(tabCaption) then
      suffix := CString.Concat(' (', tabCaption, ')');
  end;

  lbiSortSmallToLarge.Text := CString.Concat('Sort smallest to largest', suffix);
  lbiSortLargeToSmall.Text := CString.Concat('Sort largest to smallest', suffix);
  lbiClearSort.Text := 'Clear sort';
  lbiClearFilter.Text := 'Clear filter';
  lbiClearSortAndFilter.Text := 'Clear sort and filter';
end;

procedure TfrmFMXPopupMenuDataControl.ShowPopupMenu(const ScreenPos: TPointF; ShowItemFilters, ShowItemSortOptions, ShowItemAddColumAfter, ShowItemHideColumn: Boolean);
begin
  _PopupResult := TPopupResult.ptCancel;
  _filterPages := nil;
  _activePageIndex := -1;
  if _propertyTabs <> nil then
    _propertyTabs.Visible := False;

  Timer1.Enabled := True;

  PopupListBox.StylesData['background.Visible'] := False;
  btnApplyFilters.Enabled := False;
  btnApplyDateRange.Enabled := False;

  Left := Trunc(ScreenPos.X);
  Top := Trunc(ScreenPos.Y);

  if ShowItemFilters then
    CreateItemFiltersControls;

  lbiSortSmallToLarge.Visible := ShowItemSortOptions;
  lbiSortLargeToSmall.Visible := ShowItemSortOptions;
  lbiClearSort.Visible := ShowItemSortOptions;
  lbiClearFilter.Visible := ShowItemFilters;
  filterlist.Visible := ShowItemFilters;
  lbiClearSortAndFilter.Visible := ShowItemFilters or ShowItemSortOptions;

  lbiAddColumnAfter.Visible := ShowItemAddColumAfter;
  lbiHideColumn.Visible := ShowItemHideColumn;

  UpdateActionCaptions;

  var menuHeight := VisibleListHeight(PopupListBox);
  if menuHeight > 0 then
    menuHeight := menuHeight + 6;
  lyListBoxBackGround.Height := menuHeight;

  var filterListHeight: Single := 0;
  if filterlist.Visible then
    filterListHeight := 202;

  Height := Ceil(menuHeight + filterListHeight + 20);

  Show;
end;

procedure TfrmFMXPopupMenuDataControl.CreateItemFiltersControls;
begin
  if _dataControl <> nil then
    Exit;

  _dataControl := TDataControl.Create(Self);
  _dataControl.Align := TAlignLayout.Client;
  _dataControl.Options := [TDCTreeOption.MultiSelect];
//  _dataControl.RowHeightFixed := 26;
  _dataControl.OnSelectionChanged := TreeCellSelected;
  _dataControl.CellFormatting := TreeCellFormatting;

  filterlist.AddObject(_dataControl);

  var column1: IDCTreeCheckboxColumn := TDCTreeCheckboxColumn.Create;
  column1.WidthSettings.WidthType := TDCColumnWidthType.Pixel;
  column1.WidthSettings.Width := 30;
  column1.Caption := '*';
  _dataControl.Columns.Add(column1);

  var column2: IDCTreeColumn := TDCTreeColumn.Create;
  column2.Caption := 'Values';
  column2.PropertyName := '[object]';
  column2.Visualisation.ReadOnly := True;
  column2.WidthSettings.WidthType := TDCColumnWidthType.Percentage;
  column2.WidthSettings.Width := 100;
  column2.Visualisation.HorzAlign := TDCTextAlign.Leading;
  _dataControl.Columns.Add(column2);
end;

destructor TfrmFMXPopupMenuDataControl.Destroy;
begin

  inherited;
end;

procedure TfrmFMXPopupMenuDataControl.btnApplyDateRangeClick(Sender: TObject);
begin
  CloseWithFilterResult(TPopupResult.ptFilterDateRange);
end;

procedure TfrmFMXPopupMenuDataControl.EnsurePropertyTabs;
begin
  if _propertyTabs <> nil then
    Exit;

  _propertyTabs := TTabControl.Create(Self);
  _propertyTabs.Parent := Self;
  _propertyTabs.Align := TAlignLayout.Top;
  _propertyTabs.TabHeight := 28;
  _propertyTabs.Height := 32;
  _propertyTabs.TabPosition := TTabPosition.Top;
  _propertyTabs.OnChange := PropertyTabsChange;
  _propertyTabs.Visible := False;
  if lyListBoxBackGround.Index >= 0 then
    _propertyTabs.Index := lyListBoxBackGround.Index + 1;
end;

procedure TfrmFMXPopupMenuDataControl.MarkActivePageModified;
begin
  if _loadingPage then
    Exit;

  if (_filterPages <> nil) and (_activePageIndex >= 0) and (_activePageIndex < _filterPages.Count) then
    _filterPages[_activePageIndex].Modified := True;
end;

procedure TfrmFMXPopupMenuDataControl.SaveActiveFilterPage;
begin
  if (_filterPages = nil) or (_activePageIndex < 0) or (_activePageIndex >= _filterPages.Count) then
    Exit;

  var page := _filterPages[_activePageIndex];
  if page.IsDateRange then
  begin
    page.Start := get_Start;
    page.Stop := get_Stop;
  end
  else
  begin
    var nullSelected := False;
    page.Selected := SelectedItems(nullSelected);
    page.SelectNullValue := nullSelected;
  end;
end;

procedure TfrmFMXPopupMenuDataControl.ShowFilterPage(const PageIndex: Integer);
begin
  if (_filterPages = nil) or (PageIndex < 0) or (PageIndex >= _filterPages.Count) then
    Exit;

  _loadingPage := True;
  try
    _activePageIndex := PageIndex;
    var page := _filterPages[PageIndex];

    if edSearch.Text <> '' then
      edSearch.Text := '';

    if page.IsDateRange then
      LoadDateRange(page.Start, page.Stop, False)
    else
      LoadFilterItems(page.Data, page.Comparer, page.Selected, page.ShowNullValue, page.SelectNullValue, page.UseTextCompare);
  finally
    _loadingPage := False;
  end;

  UpdateSortFilterActions;
end;

procedure TfrmFMXPopupMenuDataControl.PropertyTabsChange(Sender: TObject);
begin
  if _loadingPage or (_propertyTabs = nil) then
    Exit;

  var previousIndex := _activePageIndex;
  if previousIndex <> _propertyTabs.TabIndex then
    ClearFilterPage(previousIndex);

  ShowFilterPage(_propertyTabs.TabIndex);
end;

procedure TfrmFMXPopupMenuDataControl.CloseWithFilterResult(const SingleResult: TPopupResult);
begin
  SaveActiveFilterPage;
  if (_filterPages <> nil) and (_filterPages.Count > 1) then
    _PopupResult := TPopupResult.ptFilter
  else
    _PopupResult := SingleResult;
  Close;
end;

procedure TfrmFMXPopupMenuDataControl.LoadFilterPages(const Pages: IList<IDCHeaderFilterPage>);
begin
  _filterPages := Pages;
  if (Pages = nil) or (Pages.Count = 0) then
    Exit;

  if Pages.Count = 1 then
  begin
    if _propertyTabs <> nil then
      _propertyTabs.Visible := False;
    ShowFilterPage(0);
    Exit;
  end;

  EnsurePropertyTabs;

  _loadingPage := True;
  try
    while _propertyTabs.TabCount > 0 do
      _propertyTabs.Tabs[0].Free;

    var page: IDCHeaderFilterPage;
    for page in Pages do
    begin
      var tabItem := _propertyTabs.Add;
      tabItem.Text := page.Caption;
    end;

    _propertyTabs.Visible := True;
    _propertyTabs.TabIndex := IndexOfActiveFilterPage;
  finally
    _loadingPage := False;
  end;

  ShowFilterPage(_propertyTabs.TabIndex);

  if Width < 280 then
  begin
    var grow := Trunc(280 - Width);
    Left := Left - grow;
    if Left < 0 then
      Left := 0;
    Width := 280;
  end;
  Height := Height + Trunc(_propertyTabs.Height);
end;

function TfrmFMXPopupMenuDataControl.get_FilterPages: IList<IDCHeaderFilterPage>;
begin
  Result := _filterPages;
end;

function TfrmFMXPopupMenuDataControl.get_ActiveFilterPropertyName: CString;
begin
  Result := '';
  if (_filterPages <> nil) and (_activePageIndex >= 0) and (_activePageIndex < _filterPages.Count) then
    Result := _filterPages[_activePageIndex].PropertyName;
end;

procedure TfrmFMXPopupMenuDataControl.LoadFilterItems(const Data: Dictionary<CObject, CString>; const Comparer: IComparer<CObject>; const Selected: List<CObject>; ShowNullValue: Boolean; SelectNullValue: Boolean; UseTextCompare: Boolean);
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
  _dataControl.ClearSelectedItems;

  if Selected <> nil then
    _dataControl.AssignSelection(Selected as IList);

  if SelectNullValue then
    _dataControl.AddToSelection(NO_VALUE, False);

  btnApplyFilters.Enabled := False;
end;

procedure TfrmFMXPopupMenuDataControl.LoadDateRange(const Start: CDateTime; const Stop: CDateTime; ShowTimeValue: Boolean);
begin
  tcFilterControls.ActiveTab := tsDateRange;
  dtpTo.OnChange := dtpFromChange;
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

function TfrmFMXPopupMenuDataControl.get_PopupResult: TDCHeaderPopupResult;
begin
  Result := _PopupResult;
end;

function TfrmFMXPopupMenuDataControl.get_ImageList: TCustomImageList;
begin
  Result := ImageListPopup;
end;

function TfrmFMXPopupMenuDataControl.SelectedItems(out NullValueSelected: Boolean) : List<CObject>;
begin
  NullValueSelected := False;
  var selected := _dataControl.SelectedItems(False);
  if selected = nil then
    Exit(nil);

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
  UpdateSortFilterActions;
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
  CloseWithFilterResult(TPopupResult.ptFilter);
end;

procedure TfrmFMXPopupMenuDataControl.cbSelectAllClick(Sender: TObject);
begin
  TThread.ForceQueue(nil, procedure
  begin
    if cbSelectAll.IsChecked then
      _dataControl.SelectAll else
      _dataControl.ClearSelectedItems;
  end);
end;

procedure TfrmFMXPopupMenuDataControl.dtpFromChange(Sender: TObject);
begin
  MarkActivePageModified;
  btnApplyDateRange.Enabled := True;
end;

procedure TfrmFMXPopupMenuDataControl.TreeCellSelected(const Sender: TObject; e: DCSelectionEvent);
begin
  MarkActivePageModified;
  btnApplyFilters.Enabled := True;
end;

procedure TfrmFMXPopupMenuDataControl.edSearchChangeTracking(Sender: TObject);
begin
//  var filterByText: IListFilterDescription := TTreeFilterDescription.Create(_dataControl.Layout.FlatColumns[1] , _dataControl.OnGetCellDataForSorting);
//  (filterByText as TTreeFilterDescription).FilterText := edSearch.Text.ToLower;
//
//  _dataControl.AddFilterDescription(filterByText, True);

  _dataControl.UpdateColumnFilter(_dataControl.Columns[1], edSearch.Text.ToLower, nil, False, nil);
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

procedure TfrmFMXPopupMenuDataControl.lbiClearSortClick(Sender: TObject);
begin
  _PopupResult := TPopupResult.ptClearSort;
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
  if (_dataControl <> nil) and (_dataControl.View <> nil) and (_dataControl.SelectedItems(False) <> nil) then
    cbSelectAll.IsChecked := _dataControl.View.ViewCount = _dataControl.SelectedItems(False).Count;
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
