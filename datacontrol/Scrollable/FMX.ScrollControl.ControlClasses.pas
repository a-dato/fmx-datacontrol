unit FMX.ScrollControl.ControlClasses;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Memo,
  FMX.Objects,
  FMX.Edit,
  FMX.ComboEdit,
  FMX.DateTimeCtrls,
  FMX.Graphics,
  System.Classes,
  System.UITypes,
  FMX.ActnList,
  FMX.ImgList,
  FMX.Types,
  FMX.Layouts,
  FMX.TextLayout,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Memo,
  Wasm.FMX.Objects,
  Wasm.FMX.Edit,
  Wasm.FMX.ComboEdit,
  Wasm.FMX.DateTimeCtrls,
  Wasm.FMX.Graphics,
  Wasm.System.Classes,
  Wasm.System.UITypes,
  Wasm.FMX.ActnList,
  Wasm.FMX.ImgList,
  Wasm.FMX.Types,
  Wasm.FMX.Layouts,
  Wasm.FMX.TextLayout,
  {$ENDIF}
  System_,
  ADato.FMX.FastControls.Text,
  ADato.FMX.FastControls.Button, System.Collections, System.Collections.Generic;

type
  {$IFDEF EDITCONTROL}
  TFormatItem = reference to function(const Item: CObject; ItemIndex: Integer) : CString;
  TItemShowing = reference to function(const Item: CObject; ItemIndex: Integer; const Text: string) : Boolean;

  // Interface that handles communication between a cell editor inside the tree control
  // and the actual control used for the editing
  IEditControl = interface(IBaseInterface)
    ['{D407A256-CED9-4FCD-8AED-E6B6578AE83D}']
    function  get_Control: TControl;
    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_FormatItem: TFormatItem;
    procedure set_FormatItem(const Value: TFormatItem);
    function  get_ItemShowing: TItemShowing;
    procedure set_ItemShowing(const Value: TItemShowing);
    function  get_OnExit: TNotifyEvent;
    procedure set_OnExit(const Value: TNotifyEvent);
    function  get_OnKeyDown: TKeyEvent;
    procedure set_OnKeyDown(const Value: TKeyEvent);
    function  get_Position: TPosition;
    procedure set_Position(const Value: TPosition);
    function  get_Width: Single;
    procedure set_Width(const Value: Single);
    function  get_Height: Single;
    procedure set_Height(const Value: Single);
    function  get_Value: CObject;
    procedure set_Value(const Value: CObject);

    procedure SetFocus;
    function  RefreshItems: Boolean;
    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

    property Control: TControl read get_Control;
    property OnExit: TNotifyEvent read get_OnExit write set_OnExit;
    property OnKeyDown: TKeyEvent read get_OnKeyDown write set_OnKeyDown;

    property FormatItem: TFormatItem read get_FormatItem write set_FormatItem;
    property ItemShowing: TItemShowing read get_ItemShowing write set_ItemShowing;
    property Position: TPosition read get_Position write set_Position;
    property Width: Single read get_Width write set_Width;
    property Height: Single read get_Height write set_Height;
    property DefaultValue: CObject read get_DefaultValue write set_DefaultValue;
    property Value: CObject read get_Value write set_Value;
  end;

  IComboEditControl = interface(IEditControl)
    ['{0A5E499C-31BB-42B8-BDD5-16EFA661C377}']
    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);

    procedure DropDown;

    property PickList: IList read get_PickList write set_PickList;
  end;

  TEditControlImpl = class(TBaseInterfacedObject, IEditControl)
  protected
    _control: TControl;
    _DefaultValue: CObject;
    _FormatItem: TFormatItem;
    _ItemShowing: TItemShowing;

    function  get_Control: TControl;
    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_FormatItem: TFormatItem;
    procedure set_FormatItem(const Value: TFormatItem);
    function  get_ItemShowing: TItemShowing;
    procedure set_ItemShowing(const Value: TItemShowing);
    function  get_OnExit: TNotifyEvent;
    procedure set_OnExit(const Value: TNotifyEvent);
    function  get_OnKeyDown: TKeyEvent;
    procedure set_OnKeyDown(const Value: TKeyEvent);
    function  get_Position: TPosition;
    procedure set_Position(const Value: TPosition);
    function  get_Width: Single;
    procedure set_Width(const Value: Single);
    function  get_Height: Single;
    procedure set_Height(const Value: Single);
    function  get_Value: CObject; virtual;
    procedure set_Value(const Value: CObject); virtual;

    procedure Dispose; override;
    function  DoFormatItem(const Item: CObject; ItemIndex: Integer; out Value: string) : Boolean; virtual;
    function  DoItemShowing(const Item: CObject; ItemIndex: Integer; const Text: string) : Boolean; virtual;
    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;
    procedure DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;

    procedure SetFocus;
    function  RefreshItems: Boolean; virtual;
  public
    constructor Create(AControl: TControl);
  end;

  TTextEditControlImpl = class(TEditControlImpl)
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;
  end;

  TComboEditControlImpl = class(TEditControlImpl, IComboEditControl)
  protected
    _PickList: IList;
    _ItemsShowing: IList;

    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);

    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    function  ActivePickList: IList;
    procedure DropDown;
    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    function  MatchText(const Text: string; const Search: string) : Boolean;
    function  MatchTextIndex(const Text: string; const Search: string) : Integer;
    function  FindBestMatch(const Items: List<string>; const Text: string; var Pos: Integer) : Integer;
    function  RefreshItems: Boolean; override;
  end;

  TTextEditControl = class(TEdit, IEditControl)
  protected
    _editControl: IEditControl;

    function get_EditControl: IEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IEditControl read get_EditControl implements IEditControl;
  end;

  TComboEditControl = class(TComboEdit, IEditControl)
  protected
    _editControl: IEditControl;

    function get_EditControl: IEditControl;

    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IEditControl read get_EditControl implements IEditControl;
  end;
  {$ENDIF}

  IDataControlClassFactory = interface
    ['{08ADE46F-92EA-4A14-9208-51FD5347C754}']
    function CreateHeaderRect(const Owner: TComponent): TRectangle;
    function CreateHeaderCellRect(const Owner: TComponent): TRectangle;

    function IsCustomFactory: Boolean;

    function CreateRowCellRect(const Owner: TComponent): TRectangle;
    function CreateRowRect(const Owner: TComponent): TRectangle;

    function CreateText(const Owner: TComponent): TFastText;
    function CreateCheckBox(const Owner: TComponent): TCheckBox;
    function CreateRadioButton(const Owner: TComponent): TRadioButton;
    function CreateButton(const Owner: TComponent): TFastButton;
    function CreateGlyph(const Owner: TComponent): TGlyph;
    function CreateMemo(const Owner: TComponent): TMemo;
    function CreateDateEdit(const Owner: TComponent): TDateEdit;

    {$IFDEF EDITCONTROL}
    function CreateEdit(const Owner: TComponent): IEditControl;
    function CreateComboEdit(const Owner: TComponent): IEditControl;
    {$ELSE}
    function CreateEdit(const Owner: TComponent): TEdit;
    function CreateComboEdit(const Owner: TComponent): TComboEdit;
    {$ENDIF}

    procedure HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean);
  end;

  TDataControlClassFactory = class(TInterfacedObject, IDataControlClassFactory)
  private
    _isCustomFactory: Boolean;
  public
    constructor Create; reintroduce;
    {$IFDEF WEBASSEMBLY}
    class constructor Create;
    {$ENDIF}

    function CreateHeaderRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowRect(const Owner: TComponent): TRectangle; virtual;

    function IsCustomFactory: Boolean;

    function CreateHeaderCellRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowCellRect(const Owner: TComponent): TRectangle; virtual;

    function CreateText(const Owner: TComponent): TFastText; virtual;
    function CreateCheckBox(const Owner: TComponent): TCheckBox; virtual;
    function CreateRadioButton(const Owner: TComponent): TRadioButton; virtual;
    function CreateButton(const Owner: TComponent): TFastButton; virtual;
    function CreateGlyph(const Owner: TComponent): TGlyph; virtual;
    function CreateMemo(const Owner: TComponent): TMemo; virtual;
    function CreateDateEdit(const Owner: TComponent): TDateEdit; virtual;
    {$IFDEF EDITCONTROL}
    function CreateEdit(const Owner: TComponent): IEditControl; virtual;
    function CreateComboEdit(const Owner: TComponent): IEditControl; virtual;
    {$ELSE}
    function CreateEdit(const Owner: TComponent): TEdit; virtual;
    function CreateComboEdit(const Owner: TComponent): TComboEdit; virtual;
    {$ENDIF}

    procedure HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean); virtual;
  end;

var
  // see Initialization section
  DataControlClassFactory: IDataControlClassFactory;

  DEFAULT_GREY_COLOR: TAlphaColor;
  DEFAULT_WHITE_COLOR: TAlphaColor;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR: TAlphaColor;
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR: TAlphaColor;
  DEFAULT_ROW_HOVER_COLOR: TAlphaColor;

  DEFAULT_HEADER_BACKGROUND: TAlphaColor;
  DEFAULT_HEADER_STROKE: TAlphaColor;
  DEFAULT_CELL_STROKE: TAlphaColor;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Types
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Types
  {$ENDIF}
  ;

{ TDataControlClassFactory }

function TDataControlClassFactory.CreateHeaderRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

  Result.HitTest := True;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Red;
  {$ELSE}
  Result.Fill.Color := DEFAULT_HEADER_BACKGROUND;
  {$ENDIF}
  Result.Stroke.Color := TAlphaColors.Null;
  Result.Sides := [];
end;

constructor TDataControlClassFactory.Create;
begin
  inherited;

  _isCustomFactory := Self.ClassType <> TDataControlClassFactory;
end;

{$IFDEF WEBASSEMBLY}
class constructor TDataControlClassFactory.Create;
begin
  DEFAULT_GREY_COLOR := TAlphaColor($FFF1F2F7);
  DEFAULT_WHITE_COLOR := TAlphaColors.Null;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR := TAlphaColor($886A5ACD);
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR := TAlphaColor($88778899);
  DEFAULT_ROW_HOVER_COLOR := TAlphaColor($335B8BCD);

  DEFAULT_HEADER_BACKGROUND := TAlphaColors.Null;
  DEFAULT_HEADER_STROKE := TAlphaColors.Grey;
  DEFAULT_CELL_STROKE := TAlphaColors.Lightgray;    
end;
{$ENDIF}

function TDataControlClassFactory.CreateMemo(const Owner: TComponent): TMemo;
begin
  Result := TMemo.Create(Owner);
end;

function TDataControlClassFactory.CreateButton(const Owner: TComponent): TFastButton;
begin
  Result := TFastButton.Create(Owner);
end;

function TDataControlClassFactory.CreateCheckBox(const Owner: TComponent): TCheckBox;
begin
  Result := TCheckBox.Create(Owner);
end;

{$IFDEF EDITCONTROL}
function TDataControlClassFactory.CreateEdit(const Owner: TComponent): IEditControl;
begin
  Result := TTextEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateComboEdit(const Owner: TComponent): IEditControl;
begin
  Result := TComboEditControl.Create(Owner);
end;
{$ELSE}
function TDataControlClassFactory.CreateEdit(const Owner: TComponent): TEdit;
begin
  Result := TEdit.Create(Owner);
end;

function TDataControlClassFactory.CreateComboEdit(const Owner: TComponent): TComboEdit;
begin
  Result := TComboEdit.Create(Owner);
end;
{$ENDIF}

function TDataControlClassFactory.CreateDateEdit(const Owner: TComponent): TDateEdit;
begin
  Result := TDateTimeEditOnKeyDownOverride.Create(Owner);
end;

function TDataControlClassFactory.CreateGlyph(const Owner: TComponent): TGlyph;
begin
  Result := TGlyph.Create(Owner);
end;

function TDataControlClassFactory.CreateHeaderCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

//  Result.Fill.Kind := TBrushKind.None;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Yellow;
  Result.Stroke.Color := TAlphaColors.Yellow;
  Result.Sides := [TSide.Bottom];
  {$ELSE}
  Result.Fill.Color := TAlphaColors.Null;
  Result.Stroke.Color := DEFAULT_HEADER_STROKE;
  Result.Sides := [TSide.Bottom];
  {$ENDIF}
end;

function TDataControlClassFactory.CreateRadioButton(const Owner: TComponent): TRadioButton;
begin
  Result := TRadioButton.Create(Owner);
end;

function TDataControlClassFactory.CreateRowCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Kind := TBrushKind.Solid;
  Result.Fill.Color := TAlphaColors.Green;
  Result.Stroke.Color := TAlphaColors.Green;
  {$ELSE}
  Result.Fill.Kind := TBrushKind.None;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
  {$ENDIF}
end;

function TDataControlClassFactory.CreateRowRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Darkslategray;
  Result.Stroke.Color := TAlphaColors.Darkslategray;
  {$ELSE}
  Result.Fill.Color := DEFAULT_WHITE_COLOR;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
  {$ENDIF}
end;

function TDataControlClassFactory.CreateText(const Owner: TComponent): TFastText;
begin
  Result := TFastText.Create(Owner);
  Result.VertTextAlign := TTextAlign.Center;
  Result.CalcAsAutoWidth := True;
end;

procedure TDataControlClassFactory.HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean);
begin
//  RowRect.Fill.Kind := TBrushKind.Solid;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  if Alternate then
    RowRect.Fill.Color := TAlphaColors.Cyan else
    RowRect.Fill.Color := TAlphaColors.Cyan;
  {$ELSE}
  if Alternate then
    RowRect.Fill.Color := DEFAULT_GREY_COLOR else
    RowRect.Fill.Color := DEFAULT_WHITE_COLOR;
  {$ENDIF}
end;

function TDataControlClassFactory.IsCustomFactory: Boolean;
begin
  Result := _isCustomFactory;
end;

{$IFDEF EDITCONTROL}
{ TEditControl }
constructor TTextEditControl.Create(AOwner: TComponent);
begin
  inherited;

  _editControl := TTextEditControlImpl.Create(Self);
end;

function TTextEditControl.get_EditControl: IEditControl;
begin
  Result := _editControl;
end;

{ TComboEditControl }
constructor TComboEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _editControl := TComboEditControlImpl.Create(Self);
end;

procedure TComboEditControl.DoExit;
begin
;
end;

function TComboEditControl.get_EditControl: IEditControl;
begin
  Result := _editControl;
end;

{ TEditControlImpl }

constructor TEditControlImpl.Create(AControl: TControl);
begin
  _control := AControl;
  _control.OnKeyUp := DoKeyUp;
end;

procedure TEditControlImpl.Dispose;
begin
  inherited;
  FreeAndNil(_control);
end;

function TEditControlImpl.DoFormatItem(const Item: CObject; ItemIndex: Integer; out Value: string) : Boolean;
begin
  if Assigned(_FormatItem) then
    Value := CStringToString(_FormatItem(Item, ItemIndex)) else
    Value := CStringToString(Item.ToString);
  Result := Value <> '';
end;

function TEditControlImpl.DoItemShowing(const Item: CObject; ItemIndex: Integer; const Text: string) : Boolean;
begin
  if Assigned(_ItemShowing) then
    Result := _ItemShowing(Item, ItemIndex, Text) else
    Result := True;
end;

procedure TEditControlImpl.DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin

end;

procedure TEditControlImpl.DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin

end;

function TEditControlImpl.get_Control: TControl;
begin
  Result := _control;
end;

function TEditControlImpl.get_DefaultValue: CObject;
begin
  Result := _DefaultValue;
end;

procedure TEditControlImpl.set_DefaultValue(const Value: CObject);
begin
  _DefaultValue := Value;
end;

function TEditControlImpl.get_FormatItem: TFormatItem;
begin
  Result := _FormatItem;
end;

function TEditControlImpl.get_Height: Single;
begin
  Result := _control.Height;
end;

function TEditControlImpl.get_ItemShowing: TItemShowing;
begin
  Result := _ItemShowing;
end;

function TEditControlImpl.get_OnExit: TNotifyEvent;
begin
  Result := _control.OnExit;
end;

function TEditControlImpl.get_OnKeyDown: TKeyEvent;
begin
  Result := _control.OnKeyDown;
end;

function TEditControlImpl.get_Position: TPosition;
begin
  Result := _control.Position;
end;

function TEditControlImpl.get_Value: CObject;
begin

end;

function TEditControlImpl.get_Width: Single;
begin
  Result := _control.Width;
end;

function TEditControlImpl.RefreshItems: Boolean;
begin

end;

procedure TEditControlImpl.SetFocus;
begin
  _control.SetFocus;
end;

procedure TEditControlImpl.set_FormatItem(const Value: TFormatItem);
begin
  _FormatItem := Value;
end;

procedure TEditControlImpl.set_Height(const Value: Single);
begin
  _control.Height := Value;
end;

procedure TEditControlImpl.set_ItemShowing(const Value: TItemShowing);
begin
  _ItemShowing := Value;
end;

procedure TEditControlImpl.set_OnExit(const Value: TNotifyEvent);
begin
  _control.OnExit := Value;
end;

procedure TEditControlImpl.set_OnKeyDown(const Value: TKeyEvent);
begin
  _control.OnKeyDown := Value;
end;

procedure TEditControlImpl.set_Position(const Value: TPosition);
begin
  _control.Position := Value;
end;

procedure TEditControlImpl.set_Value(const Value: CObject);
begin

end;

procedure TEditControlImpl.set_Width(const Value: Single);
begin
  _control.Width := Value;
end;
{$ENDIF}

{$IFDEF EDITCONTROL}
{ TComboEditControlImpl }

procedure TComboEditControlImpl.DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key in [vkUp, vkDown, vkPrior, vkNext, vkHome, vkEnd]) and (_control is TComboEdit) then
  begin
    var ce := _control as TComboEdit;

    case Key of
      vkUp:
      begin
        ce.ItemIndex := CMath.Max(0, ce.ItemIndex - 1);
        Key := 0;
      end;
      vkDown:
      begin
        ce.ItemIndex := CMath.Min(ce.Items.Count - 1, ce.ItemIndex + 1);
        Key := 0;
      end;
      vkPrior:
      begin
        ce.ItemIndex := CMath.Max(0, ce.ItemIndex - 10);
        Key := 0;
      end;
      vkNext:
      begin
        ce.ItemIndex := CMath.Min(ce.Items.Count - 1, ce.ItemIndex + 10);
        Key := 0;
      end;
      vkHome:
      begin
        ce.ItemIndex := 0;
        Key := 0;
      end;
      vkEnd:
      begin
        ce.ItemIndex := ce.Items.Count - 1;
        Key := 0;
      end;
    end;
  end;
end;

function TComboEditControlImpl.MatchTextIndex(const Text: string; const Search: string) : Integer;
begin
  Result := Text.ToLower.IndexOf(Search.ToLower);
end;

function TComboEditControlImpl.MatchText(const Text: string; const Search: string) : Boolean;
begin
  Result := MatchTextIndex(Text, Search) <> -1;
end;

function TComboEditControlImpl.FindBestMatch(const Items: List<string>; const Text: string; var Pos: Integer) : Integer;
begin
  Result := -1;
  Pos := Integer.MaxValue;

  for var i := 0 to Items.Count - 1 do
  begin
    var p := MatchTextIndex(Items[i], Text);
    if (p <> -1) and (p < Pos) then
    begin
      Result := i;
      Pos := p;
    end;
  end;
end;

function TComboEditControlImpl.RefreshItems: Boolean;
begin
  if _control is TComboEdit then
  begin
    var ce := _control as TComboEdit;
    if _PickList <> nil then
    begin
      var itemsShowing: List<CObject> := nil;
      var items: List<string> := CList<string>.Create(_PickList.Count);
      var i := 0;
      for var o in _PickList do
      begin
        var s: string;
        if DoFormatItem(o, i, s) then
        begin
          if DoItemShowing(o, i, s) then
          begin
            items.Add(s);
            if itemsShowing <> nil then
              itemsShowing.Add(o);
          end
          else if itemsShowing = nil then
            itemsShowing := CList<CObject>.Create;
        end;
        inc(i);
      end;

      var itemUpdateNeeded := False;

      if items.Count = ce.Items.Count then
      begin
        for var n := 0 to ce.Items.Count - 1 do
        begin
          if items[n] <> ce.Items[n] then
          begin
            itemUpdateNeeded := True;
            break;
          end;
        end;
      end else
        itemUpdateNeeded := True;

      if itemUpdateNeeded then
      begin
        ce.BeginUpdate;
        try
          var text := ce.Text;

          ce.Clear;
          ce.ItemIndex := -1;

          if items.Count = 0 then
            ce.Items.Add('')

          else
          begin
            for var s in items do
              ce.Items.Add(s);

            var pos: Integer;
            ce.ItemIndex := FindBestMatch(items, text, {var} pos);
            if ce.ItemIndex <> -1 then
            begin
              ce.SelStart := pos + Length(text);
              ce.SelLength := Length(items[0]) - ce.SelStart;
            end;
          end;
        finally
          ce.EndUpdate;
        end;

        _ItemsShowing := itemsShowing as IList;
      end;
    end;
  end;
end;

procedure TComboEditControlImpl.DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if (Key = vkBack) or (KeyChar in ['a'..'z', 'A'..'Z']) then
    RefreshItems;
end;

function TComboEditControlImpl.ActivePickList: IList;
begin
  if _ItemsShowing <> nil then
    Result := _ItemsShowing else
    Result := _PickList;
end;

procedure TComboEditControlImpl.DropDown;
begin
  if _control is TComboEdit then
  begin
    var ce := _control as TComboEdit;
    RefreshItems;
    ce.DropDown;
  end;
end;

function TComboEditControlImpl.get_PickList: IList;
begin
  Result := _PickList;
end;

function TComboEditControlImpl.get_Value: CObject;
begin
  if _control is TComboEdit then
  begin
    var ce := _control as TComboEdit;
    var items := ActivePickList;
    if (items <> nil) and (ce.ItemIndex >= 0) and (ce.ItemIndex < items.Count) then
      Result := items[ce.ItemIndex] else
      Result := _DefaultValue;
  end;
end;

procedure TComboEditControlImpl.set_PickList(const Value: IList);
begin
  _PickList := Value;
end;

procedure TComboEditControlImpl.set_Value(const Value: CObject);
begin
  if _control is TComboEdit then
  begin
    var ce := _control as TComboEdit;
    var items := ActivePickList;

    if items <> nil then
    begin
      var i := items.IndexOf(Value);
      if i <> ce.ItemIndex then
      begin
        ce.BeginUpdate;
        try
          ce.ItemIndex := i;
        finally
          ce.EndUpdate;
        end;
      end;
    end;
  end;
end;
{$ENDIF}

{ TTextEditControlImpl }
{$IFDEF EDITCONTROL}
function TTextEditControlImpl.get_Value: CObject;
begin
  if _control is TCustomEdit then
    Result := (_control as TCustomEdit).Text;
end;

procedure TTextEditControlImpl.set_Value(const Value: CObject);
begin
  var s: string;
  if (_control is TCustomEdit) and DoFormatItem(Value, - 1, s) then
  begin
    var ce := _control as TCustomEdit;
    ce.Text := s;
    ce.SelectAll;
  end;
end;
{$ENDIF}

initialization
  DataControlClassFactory := TDataControlClassFactory.Create;

  DEFAULT_GREY_COLOR := TAlphaColor($FFF1F2F7);
  DEFAULT_WHITE_COLOR := TAlphaColors.Null;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR := TAlphaColor($886A5ACD);
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR := TAlphaColor($88778899);
  DEFAULT_ROW_HOVER_COLOR := TAlphaColor($335B8BCD);

  DEFAULT_HEADER_BACKGROUND := TAlphaColors.Null;
  DEFAULT_HEADER_STROKE := TAlphaColors.Grey;
  DEFAULT_CELL_STROKE := TAlphaColors.Lightgray;

finalization
  DataControlClassFactory := nil;

end.


