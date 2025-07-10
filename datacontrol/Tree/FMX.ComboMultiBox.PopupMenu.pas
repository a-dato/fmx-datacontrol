unit FMX.ComboMultiBox.PopupMenu;

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

  TfrmComboMultiBoxPopup = class(TForm)
    filterlist: TRectangle;
    lyFilter: TLayout;
    cbSelectAll: TCheckBox;
    edSearch: TEdit;
    Timer1: TTimer;
    Line1: TLine;
    Button1: TButton;
    procedure btnApplyFiltersClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbSelectAllClick(Sender: TObject);
    procedure edSearchChangeTracking(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    _data: List<CObject>;
    _parentControl: TControl;
    _oldSelection: List<CObject>;

    _selectUpdateCount: Integer;
    _onSelectionChanged: TNotifyEvent;

    function  get_IsOpen: Boolean;
    procedure set_IsOpen(const Value: Boolean);

    function  get_SelectedItems: List<CObject>;

    procedure TreeCellSelected(const Sender: TObject; e: DCCellSelectedEventArgs);
    procedure TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);

    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure CancelChanges;

  public
    DataControl: TDataControl;

    constructor Create(ParentControl: TControl); reintroduce;

    property  SelectedItems: List<CObject> read get_SelectedItems;

    property IsOpen: Boolean read get_IsOpen write set_IsOpen;
    property OnSelectionChanged: TNotifyEvent write _onSelectionChanged;
  end;

implementation

uses
  FMX.ScrollControl.SortAndFilter,
  FMX.ScrollControl.WithRows.Intf;

{$R *.fmx}

procedure TfrmComboMultiBoxPopup.FormDeactivate(Sender: TObject);
begin
  Close;
end;

constructor TfrmComboMultiBoxPopup.Create(ParentControl: TControl);
begin
  inherited Create(ParentControl);
  _parentControl := ParentControl;

  DataControl := TDataControl.Create(Self);
  DataControl.Align := TAlignLayout.Client;
  DataControl.Options := [TDCTreeOption.MultiSelect];
  DataControl.RowHeightFixed := 26;
  DataControl.AllowNoneSelected := True;
  DataControl.CellSelected := TreeCellSelected;
  DataControl.CellFormatting := TreeCellFormatting;
  filterlist.AddObject(DataControl);

  var column1: IDCTreeCheckboxColumn := TDCTreeCheckboxColumn.Create;
  column1.WidthSettings.WidthType := TDCColumnWidthType.Pixel;
  column1.WidthSettings.Width := 30;
  column1.Caption := '*';
  DataControl.Columns.Add(column1);

  var column2: IDCTreeColumn := TDCTreeColumn.Create;
  column2.PropertyName := '[object]';
  column2.Visualisation.ReadOnly := True;
  column2.WidthSettings.WidthType := TDCColumnWidthType.Percentage;
  column2.WidthSettings.Width := 100;
  DataControl.Columns.Add(column2);
end;

function TfrmComboMultiBoxPopup.get_IsOpen: Boolean;
begin
  Result := Self.Visible;
end;

function TfrmComboMultiBoxPopup.get_SelectedItems: List<CObject>;
begin
  Result := DataControl.SelectedItems;
  if (Result.Count = 0) or (Result.Count = _data.Count) then
    Result := nil;
end;

procedure TfrmComboMultiBoxPopup.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if not get_IsOpen then
  begin
    if (Key = vkReturn) or ((Key = vkDown) and (ssAlt in Shift)) then
    begin
      set_IsOpen(True);
      Key := 0;
    end;

    if Key <> 0 then
      inherited;
    Exit;
  end;

  if Key = vkReturn then
  begin
    set_IsOpen(False);
    Key := 0;
  end
  else if Key = vkEscape then
  begin
    CancelChanges;
    set_IsOpen(False);
    Key := 0;
  end
  else if (Key in [vkDown, vkUp, vkPrior, vkNext, vkSpace]) or ((Key = vkA) and (ssCtrl in Shift)) then
    DataControl.KeyDown({var} Key, KeyChar, Shift);

  if Key <> 0 then
    inherited;
end;

procedure TfrmComboMultiBoxPopup.CancelChanges;
begin
  DataControl.ClearSelections;

  if _oldSelection <> nil then
    DataControl.AssignSelection(_oldSelection as IList);
end;

procedure TfrmComboMultiBoxPopup.set_IsOpen(const Value: Boolean);
begin
  if get_IsOpen = Value then
    Exit;

  if Value then
  begin
    _oldSelection := DataControl.SelectedItems;

    var absPf := _parentControl.LocalToScreen(PointF(0, _parentControl.Height + 5));
    Left := Round(absPf.X);
    Top := Round(absPf.Y);
    Width := Round(_parentControl.Width);
    Show;

    edSearch.Text := '';
  end else
    Hide;
end;

procedure TfrmComboMultiBoxPopup.btnApplyFiltersClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmComboMultiBoxPopup.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmComboMultiBoxPopup.cbSelectAllClick(Sender: TObject);
begin
  if _selectUpdateCount > 0 then
    Exit;

  TThread.ForceQueue(nil, procedure
  begin
    if cbSelectAll.IsChecked then
      DataControl.SelectAll else
      DataControl.ClearSelections;
  end);
end;

procedure TfrmComboMultiBoxPopup.TreeCellSelected(const Sender: TObject; e: DCCellSelectedEventArgs);
begin
  var totalCount := DataControl.View.ViewCount;
  var doCheck := DataControl.SelectionCount = totalCount;

  if doCheck <> cbSelectAll.IsChecked then
  begin
    inc(_selectUpdateCount);
    try
      cbSelectAll.IsChecked := doCheck;
    finally
      dec(_selectUpdateCount);
    end;
  end;

  if Assigned(_onSelectionChanged) then
    _onSelectionChanged(Self);
end;

procedure TfrmComboMultiBoxPopup.edSearchChangeTracking(Sender: TObject);
begin
  if get_IsOpen then
    DataControl.UpdateColumnFilter(DataControl.Columns[1], edSearch.Text.ToLower, nil);
end;

procedure TfrmComboMultiBoxPopup.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Timer1.Enabled := False;
end;

procedure TfrmComboMultiBoxPopup.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TfrmComboMultiBoxPopup.Timer1Timer(Sender: TObject);
begin
  if (DataControl <> nil) and (DataControl.View <> nil) and (DataControl.SelectedItems <> nil) then
    cbSelectAll.IsChecked := DataControl.View.ViewCount = DataControl.SelectedItems.Count;
end;

procedure TfrmComboMultiBoxPopup.TreeCellFormatting(const Sender: TObject; e: DCCellFormattingEventArgs);
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
