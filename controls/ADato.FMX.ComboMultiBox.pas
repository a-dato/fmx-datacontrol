unit ADato.FMX.ComboMultiBox;

interface

uses
  System_,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Collections,
  System.Collections.Generic,
  System.UITypes,

  FMX.Edit,
  FMX.Controls,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Layouts,
  FMX.Forms,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.Graphics,
  FMX.ScrollControl.DataControl.Impl,
  FMX.ScrollControl.Events,
  ADato.FMX.ComboMultiBox.PopupMenu;

type
  TComboMultiBox = class(TRectangle)
  protected
    _dropDownButton: TDropDownEditButton;
    _txt: TText;
    _popupMenu: TfrmComboMultiBoxPopup;

    procedure DropDownButtonClick(Sender: TObject);
    procedure UpdateDisplayText;

    procedure set_Items(Value: IList);

    procedure OnClosePopup(Sender: TObject; var Action: TCloseAction);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure OnSelectionChange(Sender: TObject);

    function  get_SelectedItems: IList;
    procedure set_SelectedItems(const Value: IList);
    function  get_items: IList;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DropDown;

  public
    property Items: IList read get_items write set_Items;
    property SelectedItems: IList read get_SelectedItems write set_SelectedItems;
  end;

implementation

uses
  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.WithRows.Intf;

{ TComboMultiBox }

constructor TComboMultiBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  _dropDownButton := TDropDownEditButton.Create(Self);
  _dropDownButton.Align := TAlignLayout.Right;
  _dropDownButton.OnClick := DropDownButtonClick;
  Self.AddObject(_dropDownButton);

  _txt := TText.Create(Self);
  _txt.Align := TAlignLayout.Client;
  _txt.HorzTextAlign := TTextAlign.Leading;
  _txt.TextSettings.Font.Style := [TFontStyle.fsUnderline];
  _txt.Margins.Left := 5;
  _txt.HitTest := True;
  _txt.OnClick := DropDownButtonClick;
  _txt.Cursor := crHandPoint;
  _txt.WordWrap := False;
  _txt.Trimming := TTextTrimming.Character;
  Self.AddObject(_txt);

  _popupMenu := TfrmComboMultiBoxPopup.Create(Self);
  _popupMenu.OnClose := OnClosePopup;
  _popupMenu.OnSelectionChanged := OnSelectionChange;
end;

destructor TComboMultiBox.Destroy;
begin
//  FreeAndNil(_popup);
  FreeAndNil(_popupMenu);
  inherited;
end;

procedure TComboMultiBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if not _popupMenu.IsOpen then
    DropDown;
end;

procedure TComboMultiBox.DropDown;
begin
  _popupMenu.IsOpen := not _popupMenu.IsOpen;

  if _popupMenu.IsOpen then
  begin
    _popupMenu.Width := Round(CMath.Max(Width, 250));
    _popupMenu.Height := Round(CMath.Min(_popupMenu.DataControl.DataList.Count, 8)*_popupMenu.DataControl.RowHeightFixed + _popupMenu.lyFilter.Height);

    _popupMenu.edSearch.SetFocus;
  end;
end;

procedure TComboMultiBox.DropDownButtonClick(Sender: TObject);
begin
  DropDown;
end;

procedure TComboMultiBox.OnClosePopup(Sender: TObject; var Action: TCloseAction);
begin
  UpdateDisplayText;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TComboMultiBox.OnSelectionChange(Sender: TObject);
begin
  UpdateDisplayText;
end;

procedure TComboMultiBox.UpdateDisplayText;
begin
  var s: CString := nil;

  var selected := get_SelectedItems;
  if (selected = nil) or (selected.Count = 0) then
    s := 'None selected'
  else if selected.Count = _popupMenu.DataControl.DataList.Count then
    s := 'All selected'
  else
    for var item in get_SelectedItems do
    begin
      if s <> nil then
        s := CString.Concat(s, ', ');

      s := CString.Concat(s, item.ToString);
    end;

  _txt.Text := CStringToString(s);
end;

function TComboMultiBox.get_items: IList;
begin
  Result := _popupMenu.DataControl.DataList;
end;

function TComboMultiBox.get_SelectedItems: IList;
begin
  Result := _popupMenu.DataControl.SelectedItems as IList;
end;

procedure TComboMultiBox.set_Items(Value: IList);
begin
  _popupMenu.DataControl.DataList := Value;
end;

procedure TComboMultiBox.set_SelectedItems(const Value: IList);
begin
  if _popupMenu.DataControl.DataList = nil then
    raise Exception.Create('Datalist needs to be set first');

  _popupMenu.DataControl.AssignSelection(Value);
end;

end.
