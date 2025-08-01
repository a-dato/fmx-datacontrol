﻿unit FMX.ScrollControl.WithCells.PopupMenu;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.ImageList,
  System.Math,
  System.Collections.Generic,
  System_,
  System.Collections,
  System.Generics.Defaults,
  System.ComponentModel,

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

  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.Impl,
  FMX.ScrollControl.WithRows.Impl,
  FMX.ScrollControl.WithEditableCells.Impl,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.Events,
  FMX.ScrollControl.DataControl.Impl;

type
//  IFilterItem = interface;

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
  strict private

//    _FilterBorder: TLayout;
    _data: List<CObject>;
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
    procedure LoadFilterItems(const Data: Dictionary<CObject, CString>; Comparer: IComparer<CObject>; Selected: List<CObject>; SelectEmptyValue: Boolean; CompareText: Boolean);
    property  PopupResult: TPopupResult read _PopupResult;
    property  AllowClearColumnFilter: Boolean write SetAllowClearColumnFilter;
    property  SelectedItems: List<CObject> read get_SelectedItems;

    property LayoutColumn: IDCTreeLayoutColumn read get_LayoutColumn write set_LayoutColumn;
  end;

//  IFilterItem = interface(IBaseInterface)
//    function  get_Data: CObject;
//    procedure set_Data(const Value: CObject);
//    function  get_Text: CString;
//    procedure set_Text(const Value: CString);
//    function  get_Checked: Boolean;
//    procedure set_Checked(const Value: Boolean);
//
//    property Data: CObject
//      read  get_Data
//      write set_Data;
//
//    property Text: CString
//      read  get_Text
//      write set_Text;
//
//    property Checked: Boolean
//      read  get_Checked
//      write set_Checked;
//  end;
//
//  {$M+}
//  TFilterItem = class(TBaseInterfacedObject, IFilterItem)
//  protected
//    _Data: CObject;
//    _Text: CString;
//    _Checked: Boolean;
//    function  get_Data: CObject;
//    procedure set_Data(const Value: CObject);
//    function  get_Text: CString;
//    procedure set_Text(const Value: CString);
//    function  get_Checked: Boolean;
//    procedure set_Checked(const Value: Boolean);
//  public
//    constructor Create(const Data: CObject; const Text: CString; const Checked: Boolean);
//  published
//    property Data: CObject read  get_Data write set_Data;
//    property Text: CString read  get_Text write set_Text;
//    property Checked: Boolean read  get_Checked write set_Checked;
//  end;
//  {$M-}

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

    for var i := 0 to PopupListBox.Count - 1 do
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

procedure TfrmFMXPopupMenuDataControl.LoadFilterItems(const Data: Dictionary<CObject, CString>; Comparer: IComparer<CObject>; Selected: List<CObject>; SelectEmptyValue, CompareText: Boolean);
//var
//  checked: Boolean;
//  item: IFilterItem;
//  kv: KeyValuePair<CObject, CString>;
begin
  _data := CList<CObject>.Create(Data.Count);
  for var pair in Data do
    _data.Add(pair.Key);

  _data.Sort(
      function (const x, y: CObject): Integer
      begin
        if CompareText then
        begin
          if Comparer <> nil then
            Result := Comparer.Compare(x.ToString, y.ToString) else
            Result := CObject.Compare(x.ToString, y.ToString);
        end
        else if Comparer <> nil then
          Result := Comparer.Compare(x, y)
        else
          Result := CObject.Compare(x, y);
      end);

  _dataControl.DataList := _data as IList;
  _dataControl.AssignSelection(Selected as IList);

  // add filter
  if edSearch.Text <> string.Empty then
    edSearchChangeTracking(nil);
end;

function TfrmFMXPopupMenuDataControl.get_LayoutColumn: IDCTreeLayoutColumn;
begin
  Result := _LayoutColumn;
end;

function TfrmFMXPopupMenuDataControl.get_SelectedItems: List<CObject>;
begin
  Result := _dataControl.SelectedItems;
  if (Result.Count = 0) or (Result.Count = _data.Count) then
    Result := nil;
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

end.
