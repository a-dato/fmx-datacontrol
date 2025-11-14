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
  FMX.ScrollControl.DataControl.Impl;

type
  IFilterItem = interface;

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
    procedure btnApplyFiltersClick(Sender: TObject);
    procedure cbSelectAllClick(Sender: TObject);
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
    procedure Timer1Timer(Sender: TObject);
  public type
    TPopupResult = (ptCancel, ptSortAscending, ptSortDescending, ptAddColumnAfter, ptHideColumn, ptClearFilter, ptClearSortAndFilter, ptClearAll, ptFilter);

  private
    const TREE_COLUMN_NAME_TEXT = 'Text';
  {$IFNDEF WEBASSEMBLY}
  strict private
  {$ELSE}
  private
  {$ENDIF}

    _PopupResult: TPopupResult;
    _dataControl: TDataControl;

    [unsafe] _LayoutColumn: IDCTreeLayoutColumn;


    procedure CreateItemFiltersControls;
    procedure SetAllowClearColumnFilter(Value: Boolean);
//    procedure set_Items(const Value: List<IFilterItem>);
    function  get_SelectedItems: List<CObject>;
    function  get_LayoutColumn: IDCTreeLayoutColumn;
    procedure set_LayoutColumn(const Value: IDCTreeLayoutColumn);

    procedure TreeCellSelected(const Sender: TObject; e: DCCellSelectedEventArgs);
    procedure TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);

  public
    destructor Destroy; override;

    procedure ShowPopupMenu(const ScreenPos: TPointF; ShowItemFilters, ShowItemSortOptions, ShowItemAddColumAfter, ShowItemHideColumn: Boolean);


    procedure EnableItem(Index: integer; Value: boolean);
    procedure LoadFilterItems(const Data: Dictionary<CObject, CString>; const Comparer: IComparer<CObject>; const Selected: List<CObject>; CompareText: Boolean);
    property  PopupResult: TPopupResult read _PopupResult;
    property  AllowClearColumnFilter: Boolean write SetAllowClearColumnFilter;
    property  SelectedItems: List<CObject> read get_SelectedItems;

    property LayoutColumn: IDCTreeLayoutColumn read get_LayoutColumn write set_LayoutColumn;
  end;

  {$M+}
  IFilterItem = interface(IBaseInterface)
    function  get_Key: CObject;
    function  get_Text: CString;

    property Key: CObject read  get_Key;
    property Text: CString read  get_Text;
  end;

  TFilterItem = class(TBaseInterfacedObject, IFilterItem)
  protected
    _Key: CObject;
    _Text: CString;

    function  get_Key: CObject;
    function  get_Text: CString;

  public
    constructor Create(const Key: CObject; const Text: CString);

    function GetHashCode: Integer; override;
    function Equals(const other: CObject): Boolean; override;
    function ToString: CString; override;
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

//  if _FilterBorder <> nil then
//  begin
//    _EbSearch.Text := '';
//    exit;
//  end;
//
//  _FilterBorder := TLayout.Create(filterlist);
//  _FilterBorder.Align := TAlignLayout.Top;
//  _FilterBorder.Height := 37;
//
//  filterlist.AddObject(_FilterBorder);

  _dataControl := TDataControl.Create(Self);
  _dataControl.Align := TAlignLayout.Client;
  _dataControl.Options := [TDCTreeOption.MultiSelect];
  _dataControl.RowHeightFixed := 26;
  _dataControl.AllowNoneSelected := True;
  _dataControl.CellSelected := TreeCellSelected;
  _dataControl.CellFormatting := TreeCellFormatting;
  _dataControl.ItemType := &Type.From<IFilterItem>;

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

procedure TfrmFMXPopupMenuDataControl.LoadFilterItems(const Data: Dictionary<CObject, CString>; const Comparer: IComparer<CObject>; const Selected: List<CObject>; CompareText: Boolean);
begin
  var items: List<IFilterItem> := CList<IFilterItem>.Create(Data.Count);

  var selected_items: List<IFilterItem>;
  if Selected <> nil then
    selected_items := CList<IFilterItem>.Create(Selected.Count);

  var item: IFilterItem;
  var kv: KeyValuePair<CObject, CString>;

  for kv in Data do
  begin
    item := TFilterItem.Create(kv.Key, kv.Value);
    items.Add(item);

    if (Selected <> nil) and (Selected.Contains(kv.Key) or (CObject.Equals(kv.Key, NO_VALUE_KEY) and Selected.Contains(nil))) then
      selected_items.Add(item);
  end;

  items.Sort(
      function (const x, y: IFilterItem): Integer
      begin
        if Comparer <> nil then
          Result := Comparer.Compare(x.Key, y.Key)
        else if CompareText then
          Result := CString.Compare(x.Text, y.Text)
        else
          Result := CObject.Compare(x.Key, y.Key);
      end);

  _dataControl.DataList := items as IList;

  if selected_items <> nil then
    _dataControl.AssignSelection(selected_items as IList);
end;

function TfrmFMXPopupMenuDataControl.get_LayoutColumn: IDCTreeLayoutColumn;
begin
  Result := _LayoutColumn;
end;

function TfrmFMXPopupMenuDataControl.get_SelectedItems: List<CObject>;
begin
  var selected := _dataControl.SelectedItems<IFilterItem>;
  if (selected.Count = 0) or (selected.Count = _dataControl.DataList.Count) then
    Exit(nil);

  Result := CList<CObject>.Create(selected.Count);
  for var f in selected do
  begin
    if CObject.Equals(f.Key, NO_VALUE_KEY) then
      Result.Add(nil) else
      Result.Add(f.Key);
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

  _dataControl.UpdateColumnFilter(_dataControl.Columns[1], edSearch.Text.ToLower, nil);
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

procedure TfrmFMXPopupMenuDataControl.Timer1Timer(Sender: TObject);
begin
  if (_dataControl <> nil) and (_dataControl.View <> nil) and (_dataControl.SelectedItems <> nil) then
    cbSelectAll.IsChecked := _dataControl.View.ViewCount = _dataControl.SelectedItems.Count;
end;

procedure TfrmFMXPopupMenuDataControl.TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);
begin
  if e.Cell.IsHeaderCell then
    Exit;

  if (e.Value = nil) or (e.Value.GetType.IsDateTime and CDateTime(e.Value).Equals(CDateTime.MinValue)) then
  begin
    e.Value := 'no value';
    e.FormattingApplied := True;
  end;
end;

{ TFilterItem }

constructor TFilterItem.Create(const Key: CObject; const Text: CString);
begin
  _Key := Key;
  _Text := Text;
end;

function TFilterItem.GetHashCode: Integer;
begin
  Result := _Key.GetHashCode;
end;

function TFilterItem.Equals(const other: CObject): Boolean;
begin
  Result := CObject.Equals(_Key, other.AsType<IFilterItem>.Key);
end;

function TFilterItem.ToString: CString;
begin
  Result := _Text;
end;

function TFilterItem.get_Text: CString;
begin
  Result := _Text;
end;

function TFilterItem.get_Key: CObject;
begin
  Result := _Key;
end;

end.
