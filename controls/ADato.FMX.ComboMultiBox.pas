unit ADato.FMX.ComboMultiBox;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
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
  ADato.FMX.ComboMultiBox.PopupMenu,
  {$ELSE}  
  Wasm.System.SysUtils,
  Wasm.System.Classes,
  Wasm.System.UITypes,
  Wasm.FMX.Edit,
  Wasm.FMX.Controls,
  Wasm.FMX.ListBox,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Types,
  Wasm.FMX.Layouts,
  Wasm.FMX.Forms,
  Wasm.FMX.Objects,
  Wasm.FMX.Controls.Presentation,
  Wasm.FMX.Graphics,
  {$ENDIF}
  System_,
  System.Collections,
  System.Collections.Generic,

  FMX.ScrollControl.DataControl.Impl,
  FMX.ScrollControl.Events,
  ADato.FMX.FastControls.Text;

type
  TComboMultiBox = class(TLayout)
  protected
    {$IFNDEF WEBASSEMBLY}
    _dropDownButton: TControl;
    _clearButton: TControl;
    _popupMenu: TfrmComboMultiBoxPopup;
    {$ENDIF}
    _txt: TFastText;
    _beforeDropDown: TProc;
    _cellSelected: CellSelectedEvent;
    _showNoneSelected: Boolean;
    _inClearClick: Boolean;

    procedure ClearButtonClick(Sender: TObject);
    procedure DropDownButtonClick(Sender: TObject);
    procedure UpdateDisplayText;

    procedure set_Items(Value: IList);

    procedure OnClosePopup(Sender: TObject; var Action: TCloseAction);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure CellSelectedEvent(const Sender: TObject; e: DCCellSelectedEventArgs);

    function  get_SelectedItems: IList;
    procedure set_SelectedItems(const Value: IList);
    function  get_items: IList;

    function  CreateBackgroundRect: TRectangle; virtual;
    function  CreateText: TFastText; virtual;
    function  CreateDropDownButton: TControl; virtual;
    function  CreateClearButton: TControl; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  DataControl: TDataControl;
    procedure DropDown;

    function  InClearClick: Boolean;

    property  TextControl: TFastText read _txt;

  public
    property BeforeDropDown: TProc read _beforeDropDown write _beforeDropDown;
    property Items: IList read get_items write set_Items;
    property SelectedItems: IList read get_SelectedItems write set_SelectedItems;
    property CellSelected: CellSelectedEvent read _cellSelected write _cellSelected;
    property ShowNoneSelected: Boolean write _showNoneSelected default True;
  end;

implementation

uses
  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.WithCells.Impl,
  FMX.ScrollControl.WithRows.Intf;

{ TComboMultiBox }

procedure TComboMultiBox.ClearButtonClick(Sender: TObject);
begin
  _inClearClick := True;
  try
    set_SelectedItems(nil);
  finally
    _inClearClick := False;
  end;
end;

constructor TComboMultiBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  CanFocus := True;

  var rect := CreateBackgroundRect;
  rect.Align := TAlignLayout.Contents;
  Self.AddObject(rect);
  rect.SendToBack;

  {$IFNDEF WEBASSEMBLY}
  _dropDownButton := CreateDropDownButton;
  _dropDownButton.Align := TAlignLayout.Right;
  _dropDownButton.OnClick := DropDownButtonClick;
  Self.AddObject(_dropDownButton);

  _clearButton := CreateClearButton;
  _clearButton.Align := TAlignLayout.MostRight;
  _clearButton.OnClick := ClearButtonClick;
  Self.AddObject(_clearButton);
  {$ENDIF}

  _txt := CreateText;
  _txt.Align := TAlignLayout.Client;
  _txt.HorzTextAlign := TTextAlign.Leading;
  _txt.VertTextAlign := TTextAlign.Center;
  _txt.TextSettings.Font.Style := [];
  _txt.Margins.Left := 5;
  _txt.HitTest := True;
  {$IFNDEF WEBASSEMBLY}
  _txt.OnClick := DropDownButtonClick;
  {$ELSE}
  _txt.OnClick := @DropDownButtonClick;
  {$ENDIF}
  _txt.Cursor := crHandPoint;
  _txt.WordWrap := False;
  _txt.Trimming := TTextTrimming.Character;
  Self.AddObject(_txt);

  {$IFNDEF WEBASSEMBLY}
  _popupMenu := TfrmComboMultiBoxPopup.Create(Self);
  _popupMenu.OnClose := OnClosePopup;
  _popupMenu.CellSelected := CellSelectedEvent;
  {$ENDIF}

  _showNoneSelected := True;
end;

function TComboMultiBox.CreateBackgroundRect: TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Fill.Color := TAlphaColors.Lightgrey;
  Result.Stroke.Color := TAlphaColors.Darkgrey;
end;

function TComboMultiBox.CreateClearButton: TControl;
begin
  Result := TClearEditButton.Create(Self);
end;

function TComboMultiBox.CreateDropDownButton: TControl;
begin
  Result := TDropDownEditButton.Create(Self);
end;

function TComboMultiBox.CreateText: TFastText;
begin
  Result := TFastText.Create(Self);
end;

function TComboMultiBox.DataControl: TDataControl;
begin
  Result := _popupMenu.DataControl;
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
  if not _popupMenu.IsOpen and Assigned(_beforeDropDown) then
    _beforeDropDown();

  _popupMenu.IsOpen := not _popupMenu.IsOpen;

  if _popupMenu.IsOpen then
  begin
    _popupMenu.Width := Round(CMath.Max(Width, 175));
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

procedure TComboMultiBox.CellSelectedEvent(const Sender: TObject; e: DCCellSelectedEventArgs);
begin
  UpdateDisplayText;

  if Assigned(_cellSelected) then
    _cellSelected(Self, e);
end;

procedure TComboMultiBox.UpdateDisplayText;
begin
  var s: CString := nil;

  var selected := get_SelectedItems;
  if (selected = nil) or (selected.Count = 0) then
  begin
    if _showNoneSelected then
      s := 'None selected' else
      s := nil;
  end
  else if selected.Count = _popupMenu.DataControl.DataList.Count then
    s := 'All selected'
  else
  begin
    var item: CObject;
    for item in get_SelectedItems do
    begin
      if s <> nil then
        s := CString.Concat(s, ', ');

      s := CString.Concat(s, item.ToString);
    end;    
  end;

  _txt.Text := CStringToString(s);

  _clearButton.Enabled := (selected <> nil) and (selected.Count > 0);
end;

function TComboMultiBox.get_items: IList;
begin
  Result := _popupMenu.DataControl.DataList;
end;

function TComboMultiBox.get_SelectedItems: IList;
begin
  Result := _popupMenu.DataControl.SelectedItems as IList;
end;

function TComboMultiBox.InClearClick: Boolean;
begin
  Result := _inClearClick;
end;

procedure TComboMultiBox.set_Items(Value: IList);
begin
  _popupMenu.DataControl.DataList := Value;
end;

procedure TComboMultiBox.set_SelectedItems(const Value: IList);
begin
  if _popupMenu.DataControl.DataList = nil then
  begin
    if Assigned(_beforeDropDown) then
      _beforeDropDown();

    if _popupMenu.DataControl.DataList = nil then
      raise Exception.Create('Datalist needs to be set first');
  end;

  if (Value <> nil) and (Value.Count > 0) then
    _popupMenu.DataControl.AssignSelection(Value) else
    _popupMenu.DataControl.ClearSelections;
end;

end.
