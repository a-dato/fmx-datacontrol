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
  System.Types,
  System.UITypes,
  FMX.ActnList,
  FMX.ImgList,
  FMX.Types,
  FMX.Layouts,
  FMX.TextLayout,
  FMX.Text,
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
  System.Collections,
  System.Collections.Generic,
  FMX.ScrollControl.ControlClasses.Intf,
  ADato.FMX.FastControls.Button,
  ADato.FMX.FastControls.Layout;

type
  TDCControlImpl = class(TBaseInterfacedObject, IDCControl, ITextControl, ICaption, ITextActions, ITextSettings)
  protected
    _control: TControl;
    _tag: CObject;

    function  get_Align: TAlignLayout;
    procedure set_Align(const Value: TAlignLayout);
    function  get_BoundsRect: TRectF;
    procedure set_BoundsRect(const Value: TRectF);
    function  get_Control: TControl;
    function  get_Cursor: TCursor;
    procedure set_Cursor(const Value: TCursor);
    function  get_HitTest: Boolean;
    procedure set_HitTest(const Value: Boolean);
    function  get_Enabled: Boolean;
    procedure set_Enabled(const Value: Boolean);
    function  get_Margins: TBounds;
    procedure set_Margins(const Value: TBounds);
    function  get_Padding: TBounds;
    procedure set_Padding(const Value: TBounds);
    function  get_Position: TPosition;
    procedure set_Position(const Value: TPosition);
    function  get_Width: Single;
    procedure set_Width(const Value: Single);
    function  get_Height: Single;
    procedure set_Height(const Value: Single);
    function  get_OnClick: TNotifyEvent;
    procedure set_OnClick(const Value: TNotifyEvent);
    function  get_OnExit: TNotifyEvent;
    procedure set_OnExit(const Value: TNotifyEvent);
    function  get_Opacity: Single;
    procedure set_Opacity(const Value: Single);
    function  get_Value: CObject; virtual;
    procedure set_Value(const Value: CObject); virtual;
    function  get_Visible: Boolean;
    procedure set_Visible(const Value: Boolean);

    function  get_Tag: CObject;
    procedure set_Tag(const Value: CObject);

    function  get_Caption: ICaption;
    function  get_TextActions: ITextActions;
    function  get_TextControl: ITextControl;
    function  get_TextSettings: ITextSettings;

    procedure Dispose; override;
    procedure SetFocus;

    property Caption: ICaption read get_Caption implements ICaption;
    property TextControl: ITextControl read get_TextControl implements ITextControl;
    property TextActions: ITextActions read get_TextActions implements ITextActions;
    property TextSettings: ITextSettings read get_TextSettings implements ITextSettings;
  public
    constructor Create(AControl: TControl);
  end;

  TEditControlImpl = class(TDCControlImpl, IDCEditControl)
  protected
    _DefaultValue: CObject;
    _FormatItem: TFormatItem;

    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_FormatItem: TFormatItem;
    procedure set_FormatItem(const Value: TFormatItem);
    function  get_OnChange: TNotifyEvent; virtual;
    procedure set_OnChange(Value: TNotifyEvent); virtual;
    function  get_OnKeyDown: TKeyEvent;
    procedure set_OnKeyDown(const Value: TKeyEvent);
    function  get_ShowClearButton: Boolean;
    procedure set_ShowClearButton(const Value: Boolean);

    procedure Dispose; override;
    function  DoFormatItem(const Item: CObject; out Value: string) : Boolean; virtual;
    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;
    procedure DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;
  public
    constructor Create(AControl: TControl);
  end;

  TImageControlImpl = class(TDCControlImpl, IImageControl)
    function  get_ImageIndex: Integer;
    procedure set_ImageIndex(const Value: Integer);
  end;

  TTextEditControlImpl = class(TEditControlImpl)
  protected
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;
  end;

  TCheckBoxControlImpl = class(TEditControlImpl, ICheckBoxControl, IIsChecked)
  protected
    function  get_IsChecked: IIsChecked;

    function  get_OnChange: TNotifyEvent; override;
    procedure set_OnChange(Value: TNotifyEvent); override;
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    property IsChecked: IIsChecked read get_IsChecked implements IIsChecked;
  end;

  TDateEditControlImpl = class(TEditControlImpl, IDateEditControl)
  protected
    function  get_Date: CDateTime;
    procedure set_Date(const Value: CDateTime);

    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    procedure OpenPicker;
  end;

  TRadioButtonControlImpl = class(TEditControlImpl, IRadioButtonControl, IGroupName, IIsChecked)
  protected
    function  get_IsChecked: IIsChecked;
    function  get_GroupName: IGroupName;

    function  get_OnChange: TNotifyEvent; override;
    procedure set_OnChange(Value: TNotifyEvent); override;
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    property GroupName: IGroupName read get_GroupName implements IGroupName;
    property IsChecked: IIsChecked read get_IsChecked implements IIsChecked;
  end;

  TComboEditControlImpl = class(TEditControlImpl, IComboEditControl)
  protected
    _autoFilter: Boolean;
    _PickList: IList;
    _itemsLoaded: Boolean;
    _filterItem: TFilterItem;
    _ItemsShowing: IList;
    _BeforePopup: TComboBeforePopup;

    function  get_AutoFilter: Boolean;
    procedure set_AutoFilter(const Value: Boolean);
    function  get_ItemIndex: Integer; virtual;
    procedure set_ItemIndex(const Value: Integer); virtual;
    function  get_ItemCount: Integer; virtual;
    function  get_FilterItem: TFilterItem;
    procedure set_FilterItem(const Value: TFilterItem);
    function  get_BeforePopup: TComboBeforePopup;
    procedure set_BeforePopup(const Value: TComboBeforePopup);
    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);
    function  get_Text: CString;
    procedure set_Text(const Value: CString);
    function  get_Value: CObject; override;
    procedure set_Value(const Value: CObject); override;

    function  ComboItems : List<string>; virtual;
    function  ComboIsDroppedDown : Boolean; virtual;
    procedure ComboClear; virtual;
    procedure ComboAdd(const str: string); virtual;
    function  ComboUpdateItems(const Items: List<string>) : Boolean; virtual;

    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;

    function  MatchText(const Text: string; const Search: string) : Boolean;
    function  MatchTextIndex(const Text: string; const Search: string) : Integer;
    function  FindBestMatch(const Text: string) : Integer; overload;
    function  FindBestMatch(const Items: List<string>; const Text: string; var Pos: Integer) : Integer; overload;

    function  ActivePickList: IList;
    function  IsFiltered: Boolean;
    procedure DropDown; virtual;
    function  DoFilterItem(const Item: CObject; const ItemText, Filter: string) : Boolean; virtual;
    function  RefreshItems: Boolean;
    procedure DoBeforePopup;
  end;

  TComboBoxControlImpl = class(TComboEditControlImpl)
  protected
    function  get_ItemIndex: Integer; override;
    procedure set_ItemIndex(const Value: Integer); override;
    function  get_ItemCount: Integer; override;

    function  ComboItems : List<string>; override;
    function  ComboIsDroppedDown : Boolean; override;
    procedure ComboClear; override;
    procedure ComboAdd(const str: string); override;

    procedure DropDown; override;
  end;

  TTextEditControl = class(TEdit, IDCEditControl)
  protected
    _editControl: IDCEditControl;

    function get_EditControl: IDCEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;
  end;

  TMemoEditControl = class(TMemo, IDCEditControl)
  protected
    _editControl: IDCEditControl;

    function get_EditControl: IDCEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;
  end;

  TCheckBoxEditControl = class(TCheckBox, IDCEditControl)
  protected
    _editControl: IDCEditControl;

    function get_EditControl: IDCEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;
  end;

  TComboEditControl = class(TComboEdit, IDCEditControl)
  protected
    _editControl: IDCEditControl;

    function get_EditControl: IDCEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;
  end;

  TDateEditControl = class(TDateEdit, IDateEditControl)
  protected
    _dateControl: IDateEditControl;

    function get_DateControl: IDateEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property DateControl: IDateEditControl read get_DateControl implements IDateEditControl;
  end;

  TRadioButtonEditControl = class(TRadioButton, IDCEditControl)
  protected
    _editControl: IDCEditControl;

    function get_EditControl: IDCEditControl;

  public
    constructor Create(AOwner: TComponent); override;

    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;
  end;

  TGlyphControl = class(TGlyph, IDCControl)
  protected
    _dcControl: IDCControl;
    function  get_DCControl: IDCControl;

  public
    constructor Create(AOwner: TComponent); override;
    property DCControl: IDCControl read get_DCControl implements IDCControl;
  end;

  TRowLayout = class(TAdaptableBufferedLayout, IRowLayout)
  protected
    _rect: TRectangle;
//    _useBuffering: Boolean;

//    function  get_UseBuffering: Boolean;
//    procedure set_UseBuffering(const Value: Boolean);
    function  get_Sides: TSides;
    procedure set_Sides(const Value: TSides);

    procedure DoResized; override;
  public
    constructor Create(AOwner: TComponent; Background: TRectangle); reintroduce;

    procedure Paint; override;

    function  Background: TRectangle;
//    procedure ResetBuffer;

    property Sides: TSides read get_Sides write set_Sides;
//    property UseBuffering: Boolean read get_UseBuffering write set_UseBuffering default True;
  end;


  TRowLayout2x = class(TLayout, IRowLayout)
  protected
    _rect: TRectangle;

    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean);
    function  get_Sides: TSides;
    procedure set_Sides(const Value: TSides);

    procedure ResetBuffer;
    function  Background: TRectangle;
    procedure DoResized; override;
  public
    constructor Create(AOwner: TComponent; Background: TRectangle); reintroduce;

    property UseBuffering: Boolean read get_UseBuffering write set_UseBuffering;
    property Sides: TSides read get_Sides write set_Sides;
  end;

  TDataControlClassFactory = class(TInterfacedObject, IDCControlClassFactory)
  private
    _isCustomFactory: Boolean;
  public
    constructor Create; reintroduce;

    function CreateHeaderRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowRect(const Owner: TComponent): TRectangle; virtual;

    function IsCustomFactory: Boolean;

    function CreateHeaderCellRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowCellRect(const Owner: TComponent): TRectangle; virtual;

    function CreateText(const Owner: TComponent): IDCControl; virtual;
    function CreateButton(const Owner: TComponent): IDCControl; virtual;
    function CreateGlyph(const Owner: TComponent): IDCControl; virtual;

    function CreateCheckBox(const Owner: TComponent): IDCEditControl; virtual;
    function CreateRadioButton(const Owner: TComponent): IDCEditControl; virtual;
    function CreateMemo(const Owner: TComponent): IDCEditControl; virtual;
    function CreateDateEdit(const Owner: TComponent): IDateEditControl; virtual;
    function CreateEdit(const Owner: TComponent): IDCEditControl; virtual;
    function CreateComboEdit(const Owner: TComponent): IDCEditControl; virtual;

    procedure HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean); virtual;
  end;

var
  // see Initialization section
  DataControlClassFactory: IDCControlClassFactory;

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
  System.SysUtils
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Types
  {$ENDIF}
  , ADato.FMX.FastControls.Text, FMX.ListBox, ADato.TraceEvents.intf;

{ TDataControlClassFactory }

function TDataControlClassFactory.CreateHeaderRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

  Result.HitTest := True;
  Result.Fill.Color := DEFAULT_HEADER_BACKGROUND;
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

function TDataControlClassFactory.CreateButton(const Owner: TComponent): IDCControl;
begin
   Result := TFastButton.Create(Owner);
end;

function TDataControlClassFactory.CreateCheckBox(const Owner: TComponent): IDCEditControl;
begin
  Result := TCheckBoxEditControl.Create(Owner);
  Result.Width := 16;
  Result.Height := 16;
end;

function TDataControlClassFactory.CreateEdit(const Owner: TComponent): IDCEditControl;
begin
  Result := TTextEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateMemo(const Owner: TComponent): IDCEditControl;
begin
  Result := TMemoEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateComboEdit(const Owner: TComponent): IDCEditControl;
begin
  Result := TComboEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateDateEdit(const Owner: TComponent): IDateEditControl;
begin
  // Result := TDateTimeEditOnKeyDownOverride.Create(Owner);
  Result := TDateEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateRadioButton(const Owner: TComponent): IDCEditControl;
begin
  Result := TRadioButtonEditControl.Create(Owner);
end;

function TDataControlClassFactory.CreateGlyph(const Owner: TComponent): IDCControl;
begin
   Result := TGlyphControl.Create(Owner);
end;

function TDataControlClassFactory.CreateHeaderCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

//  Result.Fill.Kind := TBrushKind.None;
  Result.Fill.Color := TAlphaColors.Null;
  Result.Stroke.Color := DEFAULT_HEADER_STROKE;
  Result.Sides := [TSide.Bottom];
end;

function TDataControlClassFactory.CreateRowCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  Result.Fill.Kind := TBrushKind.None;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
end;

function TDataControlClassFactory.CreateRowRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  Result.Fill.Color := DEFAULT_WHITE_COLOR;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
end;

function TDataControlClassFactory.CreateText(const Owner: TComponent): IDCControl;
begin
  var ctrl := TFastText.Create(Owner);
  ctrl.VertTextAlign := TTextAlign.Center;

  Result := ctrl;
end;

procedure TDataControlClassFactory.HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean);
begin
//  RowRect.Fill.Kind := TBrushKind.Solid;
  if Alternate then
    RowRect.Fill.Color := DEFAULT_GREY_COLOR else
    RowRect.Fill.Color := DEFAULT_WHITE_COLOR;
end;

function TDataControlClassFactory.IsCustomFactory: Boolean;
begin
  Result := _isCustomFactory;
end;

{ TEditControl }
constructor TTextEditControl.Create(AOwner: TComponent);
begin
  inherited;

  _editControl := TTextEditControlImpl.Create(Self);
end;

function TTextEditControl.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

{ TMemoEditControl }
constructor TMemoEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _editControl := TTextEditControlImpl.Create(Self);
end;

function TMemoEditControl.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

{ TCheckBoxEditControl }
constructor TCheckBoxEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _editControl := TCheckBoxControlImpl.Create(Self);
end;

function TCheckBoxEditControl.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

{ TDateTimeEditControl }
constructor TDateEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _dateControl := TDateEditControlImpl.Create(Self);
end;

function TDateEditControl.get_DateControl: IDateEditControl;
begin
  Result := _dateControl;
end;

{ TRadioButtonEditControl }
constructor TRadioButtonEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _editControl := TRadioButtonControlImpl.Create(Self);
end;

function TRadioButtonEditControl.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

{ TComboEditControl }
constructor TComboEditControl.Create(AOwner: TComponent);
begin
  inherited;
  _editControl := TComboEditControlImpl.Create(Self);
end;

function TComboEditControl.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

{ TDCControlImpl }
constructor TDCControlImpl.Create(AControl: TControl);
begin
  _control := AControl;
end;

function TDCControlImpl.get_Padding: TBounds;
begin
  Result := _control.Padding;
end;

function TDCControlImpl.get_Position: TPosition;
begin
  Result := _control.Position;
end;

function TDCControlImpl.get_Value: CObject;
begin

end;

function TDCControlImpl.get_Visible: Boolean;
begin
  Result := _control.Visible;
end;

function TDCControlImpl.get_Width: Single;
begin
  Result := _control.Width;
end;

function TDCControlImpl.get_Tag: CObject;
begin
  Result := _tag;
end;

function TDCControlImpl.get_Caption: ICaption;
begin
  Interfaces.Supports<ICaption>(_control, Result);
end;

function TDCControlImpl.get_TextActions: ITextActions;
begin
  Interfaces.Supports<ITextActions>(_control, Result);
end;

function TDCControlImpl.get_TextControl: ITextControl;
begin
  Interfaces.Supports<ITextControl>(_control, Result);
end;

function TDCControlImpl.get_TextSettings: ITextSettings;
begin
  Interfaces.Supports<ITextSettings>(_control, Result);
end;

procedure TDCControlImpl.Dispose;
begin
  inherited;
  FreeAndNil(_control);
end;

procedure TDCControlImpl.SetFocus;
begin
  _control.SetFocus;
end;

procedure TDCControlImpl.set_Align(const Value: TAlignLayout);
begin
  _control.Align := Value;
end;

procedure TDCControlImpl.set_BoundsRect(const Value: TRectF);
begin
  _control.BoundsRect := Value;
end;

procedure TDCControlImpl.set_Cursor(const Value: TCursor);
begin
  _control.Cursor := Value;
end;

procedure TDCControlImpl.set_Enabled(const Value: Boolean);
begin
  _control.Enabled := Value;
end;

procedure TDCControlImpl.set_Height(const Value: Single);
begin
  _control.Height := Value;
end;

procedure TDCControlImpl.set_HitTest(const Value: Boolean);
begin
  _control.HitTest := Value;
end;

procedure TDCControlImpl.set_Margins(const Value: TBounds);
begin
  _control.Margins := Value;
end;

procedure TDCControlImpl.set_OnClick(const Value: TNotifyEvent);
begin
  _control.OnClick := Value;
end;

procedure TDCControlImpl.set_OnExit(const Value: TNotifyEvent);
begin
  _control.OnExit := Value;
end;

procedure TDCControlImpl.set_Opacity(const Value: Single);
begin
  _control.Opacity := Value;
end;

procedure TDCControlImpl.set_Padding(const Value: TBounds);
begin
  _control.Padding := Value;
end;

procedure TDCControlImpl.set_Position(const Value: TPosition);
begin
  _control.Position := Value;
end;

procedure TDCControlImpl.set_Tag(const Value: CObject);
begin
  _tag := Value;
end;

procedure TDCControlImpl.set_Value(const Value: CObject);
begin

end;

procedure TDCControlImpl.set_Visible(const Value: Boolean);
begin
  _control.Visible := Value;
end;

procedure TDCControlImpl.set_Width(const Value: Single);
begin
  _control.Width := Value;
end;

function TDCControlImpl.get_Align: TAlignLayout;
begin
  Result := _control.Align;
end;

function TDCControlImpl.get_BoundsRect: TRectF;
begin
  result := _control.BoundsRect;
end;

function TDCControlImpl.get_Control: TControl;
begin
  Result := _control;
end;

function TDCControlImpl.get_Cursor: TCursor;
begin
  Result := _control.Cursor;
end;

function TDCControlImpl.get_Enabled: Boolean;
begin
  Result := _control.Enabled;
end;

function TDCControlImpl.get_Height: Single;
begin
  Result := _control.Height;
end;

function TDCControlImpl.get_HitTest: Boolean;
begin
  Result := _control.HitTest;
end;

function TDCControlImpl.get_Margins: TBounds;
begin
  Result := _control.Margins;
end;

function TDCControlImpl.get_OnClick: TNotifyEvent;
begin
  Result := _control.OnClick;
end;

function TDCControlImpl.get_OnExit: TNotifyEvent;
begin
  Result := _control.OnExit;
end;

function TDCControlImpl.get_Opacity: Single;
begin
  Result := _control.Opacity;
end;

{ TEditControlImpl }
constructor TEditControlImpl.Create(AControl: TControl);
begin
  inherited;
//  {$IFDEF DEBUG}
//  AControl.OnKeyDown := DoKeyDown;
//  AControl.OnKeyUp := DoKeyUp;
//  {$ENDIF}
end;

procedure TEditControlImpl.Dispose;
begin
  inherited;
  FreeAndNil(_control);
end;

function TEditControlImpl.DoFormatItem(const Item: CObject; out Value: string) : Boolean;
begin
  if Assigned(_FormatItem) then
    Value := CStringToString(_FormatItem(Item)) else
    Value := CStringToString(Item.ToString);
  Result := Value <> '';
end;

procedure TEditControlImpl.DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin

end;

procedure TEditControlImpl.DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin

end;


function TEditControlImpl.get_ShowClearButton: Boolean;
begin
  var ccCtrl: IClearableControl;
  Result := interfaces.Supports<IClearableControl>(_control, ccCtrl) and ccCtrl.ShowClearButton;
end;

function TEditControlImpl.get_DefaultValue: CObject;
begin
  Result := _DefaultValue;
end;

procedure TEditControlImpl.set_ShowClearButton(const Value: Boolean);
begin
  var ccCtrl: IClearableControl;
  if interfaces.Supports<IClearableControl>(_control, ccCtrl) then
    ccCtrl.ShowClearButton := Value;
end;

procedure TEditControlImpl.set_DefaultValue(const Value: CObject);
begin
  _DefaultValue := Value;
end;

function TEditControlImpl.get_FormatItem: TFormatItem;
begin
  Result := _FormatItem;
end;

function TEditControlImpl.get_OnChange: TNotifyEvent;
begin

end;

function TEditControlImpl.get_OnKeyDown: TKeyEvent;
begin
  Result := _control.OnKeyDown;
end;

procedure TEditControlImpl.set_FormatItem(const Value: TFormatItem);
begin
  _FormatItem := Value;
end;

procedure TEditControlImpl.set_OnChange(Value: TNotifyEvent);
begin

end;

procedure TEditControlImpl.set_OnKeyDown(const Value: TKeyEvent);
begin
  _control.OnKeyDown := Value;
end;

{ TComboEditControlImpl }
procedure TComboEditControlImpl.DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkBack) and (_control is TComboEdit) then
  begin
    var ce := _control as TComboEdit;
    var txt := ce.Text;
    var pos := ce.CaretPosition;
    if ce.SelLength > 0 then
      txt := txt.Remove(ce.SelStart, ce.SelLength);
    if pos > 0 then
      txt := txt.Remove(pos - 1, 1);
    ce.Text := txt;
    ce.CaretPosition := pos - 1;
    Key := 0;
    if IsFiltered then
      RefreshItems;
    Exit;
  end;

  if not _ItemsLoaded then
    RefreshItems;

  if ssAlt in Shift then
    Exit;

  if (_PickList <> nil) and (Key in [vkUp, vkDown, vkPrior, vkNext]) then
  begin
    var v := get_Value;
    var i: Integer;
    if v <> nil then
      i := _PickList.IndexOf(v) else
      i := -1;

    var idx := i;
    case Key of
      vkUp:     dec(idx);
      vkDown:   inc(idx);
      vkPrior:  dec(idx, 10);
      vkNext:   inc(idx, 10);
//      vkHome:
//        if    idx := 0;
//      vkEnd:    idx := _PickList.Count;
    end;

    idx := CMath.Min(CMath.Max(idx, 0), _PickList.Count - 1);

    if (idx >= 0) and (i <> idx) then
    begin
      set_Value(_PickList[idx]);
      Key := 0;
    end;
  end;
end;

procedure TComboEditControlImpl.DoBeforePopup;
begin
  if Assigned(_BeforePopup) then
    _BeforePopup({var} _PickList);
end;

function TComboEditControlImpl.DoFilterItem(const Item: CObject; const ItemText, Filter: string) : Boolean;
begin
  if Filter = '' then
    Result := True
  else if _autoFilter then
    Result := ItemText.ToLower.Contains(Filter.ToLower)
  else if Assigned(_filterItem) then
    Result := _filterItem(Item, ItemText, Filter)
  else
    Result := True;
end;

function TComboEditControlImpl.MatchTextIndex(const Text: string; const Search: string) : Integer;
begin
  Result := Text.ToLower.IndexOf(Search.ToLower);
end;

function TComboEditControlImpl.MatchText(const Text: string; const Search: string) : Boolean;
begin
  Result := MatchTextIndex(Text, Search) <> -1;
end;

function TComboEditControlImpl.FindBestMatch(const Text: string) : Integer;
begin
  var items := ActivePickList;
  if items <> nil then
  begin
    var p: Integer;
    var l: List<string> := CList<string>.Create(items.Count);
    var s: string;
    for var o in items do
      if DoFormatItem(o, s) then
        l.Add(s);
    Result := FindBestMatch(l, Text, p);
  end else
    Result := -1;
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

procedure TComboEditControlImpl.ComboAdd(const str: string);
begin
  (_control as TComboEdit).Items.Add(str);
end;

function TComboEditControlImpl.ComboUpdateItems(const Items: List<string>) : Boolean;
begin
  var current := ComboItems;
  var changed := ((current = nil) and (Items <> nil)) or (current.Count <> Items.Count);

  if not changed then
  begin
    for var i := 0 to current.Count - 1 do
    begin
      changed := current[i] <> Items[i];
      if changed then
        break;
    end;
  end;

  if changed then
  begin
    _control.BeginUpdate;
    try
      ComboClear;
      for var s in Items do
        ComboAdd(s);
    finally
      _control.EndUpdate;
    end;
  end;

  Result := changed;
end;

function TComboEditControlImpl.ComboItems : List<string>;
begin
  var strings := (_control as TComboEdit).Items;
  if (strings <> nil) and (strings.Count > 0) then
  begin
    Result := CList<string>.Create(strings.Count);
    for var s in strings do
      Result.Add(s);
  end;
end;

function TComboEditControlImpl.ComboIsDroppedDown : Boolean;
begin
  Result := (_control as TComboEdit).DroppedDown;
end;

procedure TComboEditControlImpl.ComboClear;
begin
  (_control as TComboEdit).Clear;
  (_control as TComboEdit).ItemIndex := -1;
end;

function TComboEditControlImpl.RefreshItems: Boolean;
begin
  Result := False; // Drop down did not change

  DoBeforePopup;

  if _PickList = nil then
    Exit;

  var items: List<string>;
  if not _itemsLoaded or IsFiltered then
  begin
    _itemsLoaded := True;
    var itemsShowing := CList<CObject>.Create(_PickList.Count);
    items := CList<string>.Create(_PickList.Count);
    var filter := get_Text;

    for var o in _PickList do
    begin
      var itemtext: string;
      if DoFormatItem(o, itemtext) then
        if DoFilterItem(o, itemtext, filter) then
        begin
          items.Add(itemtext);
          itemsShowing.Add(o);
        end;
    end;

    _ItemsShowing := itemsShowing as IList;
  end else
    items := ComboItems;

  ComboUpdateItems(items);

  if (_control is TComboEdit) then
  begin
    var ce := _control as TComboEdit;

    var text := get_Text;
    var pos: Integer;
    var match_index := FindBestMatch(items, text, {var} pos);
    if match_index <> -1 then
    begin
      ce.Text := items[match_index];
      ce.SelStart := pos + Length(text);
      ce.SelLength := Length(items[match_index]) - ce.SelStart;
      ce.CaretPosition := ce.SelStart;
    end;
  end;
end;

procedure TComboEditControlImpl.DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  if CharInSet(KeyChar, [' ', 'a'..'z', 'A'..'Z', '0'..'9']) then
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
  RefreshItems;
  (_control as TComboEdit).DropDown;
end;

function TComboEditControlImpl.get_AutoFilter: Boolean;
begin
  Result := _autoFilter;
end;

function TComboEditControlImpl.get_BeforePopup: TComboBeforePopup;
begin
  Result := _BeforePopup;
end;

function TComboEditControlImpl.get_ItemCount: Integer;
begin
  Result := (_control as TComboEdit).Count;
end;

function TComboEditControlImpl.get_ItemIndex: Integer;
begin
  Result := (_control as TComboEdit).ItemIndex;
end;

procedure TComboEditControlImpl.set_AutoFilter(const Value: Boolean);
begin
  _autoFilter := Value;
end;

procedure TComboEditControlImpl.set_BeforePopup(const Value: TComboBeforePopup);
begin
  _BeforePopup := Value;
end;

procedure TComboEditControlImpl.set_ItemIndex(const Value: Integer);
begin
  (_control as TComboEdit).ItemIndex := Value;
  if Value = -1 then
    (_control as TComboEdit).Text := '';
end;

function TComboEditControlImpl.get_FilterItem: TFilterItem;
begin
  Result := _filterItem;
end;

procedure TComboEditControlImpl.set_FilterItem(const Value: TFilterItem);
begin
  _filterItem := Value;
end;

function TComboEditControlImpl.get_PickList: IList;
begin
  Result := _PickList;
end;

function TComboEditControlImpl.get_Value: CObject;
begin
  var items := ActivePickList;
  if (items <> nil) and (get_ItemIndex >= 0) and (get_ItemIndex < items.Count) then
    Result := items[get_ItemIndex] else
    Result := _DefaultValue;
end;

function TComboEditControlImpl.IsFiltered: Boolean;
begin
  Result := _autoFilter or Assigned(_filterItem);
end;

procedure TComboEditControlImpl.set_PickList(const Value: IList);
begin
  _PickList := Value;
end;

procedure TComboEditControlImpl.set_Value(const Value: CObject);
begin
  var items := ActivePickList;
  var idx: Integer;

  if (Value <> nil) and (Items <> nil) then
  begin
    idx := items.IndexOf(Value);
    if idx = get_ItemIndex then
      Exit;
  end else
    idx := -1;

  if _itemsLoaded then
  begin
    set_ItemIndex(idx);
    Exit;
  end;

  ComboClear;

  if Value = nil then
    Exit;

  var s: string;
  var itemsShowing: List<CObject> := CList<CObject>.Create(1);

  if DoFormatItem(Value, s) then
  begin
    itemsShowing.Add(Value);
    _ItemsShowing := itemsShowing as IList;
    ComboAdd(s);
    set_ItemIndex(0);
  end;
end;

function TComboEditControlImpl.get_Text: CString;
begin
  if _control is TComboEdit then
    Result := (_control as TComboEdit).Text
  else if _control is TComboBox then
    Result := (_control as TComboBox).Text;
end;

procedure TComboEditControlImpl.set_Text(const Value: CString);
begin
  if _control is TComboEdit then
  begin
    var ce := _control as TComboEdit;
    ce.BeginUpdate;
    try
      ce.Text := CStringToString(Value);
      RefreshItems;
    finally
      ce.EndUpdate;
    end;
  end
  else if _control is TComboBox then
  begin
    var ce := _control as TComboBox;
    ce.BeginUpdate;
    try
      RefreshItems;
      ce.itemIndex := ce.Items.IndexOf(Value);
    finally
      ce.EndUpdate;
    end;
  end;
end;

{ TTextEditControlImpl }
function TTextEditControlImpl.get_Value: CObject;
begin
  if _control is TCustomEdit then
    Result := (_control as TCustomEdit).Text;
end;

procedure TTextEditControlImpl.set_Value(const Value: CObject);
begin
  var s: string;
  if (_control is TCustomEdit) and DoFormatItem(Value, s) then
  begin
    var ce := _control as TCustomEdit;
    ce.Text := s;
  end;
end;

{ TCheckBoxControlImpl }
function TCheckBoxControlImpl.get_OnChange: TNotifyEvent;
begin
  Result := (_control as TCheckBox).OnChange;
end;

function TCheckBoxControlImpl.get_Value: CObject;
begin
  if _control is TCheckBox then
    Result := (_control as TCheckBox).IsChecked;
end;

procedure TCheckBoxControlImpl.set_OnChange(Value: TNotifyEvent);
begin
  (_control as TCheckBox).OnChange := Value;
end;

procedure TCheckBoxControlImpl.set_Value(const Value: CObject);
begin
  if (_control is TCheckBox) then
    (_control as TCheckBox).IsChecked := Value.GetValue<Boolean>(False);
end;

function TCheckBoxControlImpl.get_IsChecked: IIsChecked;
begin
  Interfaces.Supports<IIsChecked>(_control, Result);
end;

function TDateEditControlImpl.get_Date: CDateTime;
begin
  Result := (_control as TDateEdit).Date;
end;

{ TDateTimeControlImpl }
function TDateEditControlImpl.get_Value: CObject;
begin
  Result := CDateTime.Create((_control as TDateEdit).Date);
end;

procedure TDateEditControlImpl.OpenPicker;
begin
  (_control as TDateEdit).OpenPicker;
end;

procedure TDateEditControlImpl.set_Date(const Value: CDateTime);
begin
  (_control as TDateEdit).Date := Value;
end;

procedure TDateEditControlImpl.set_Value(const Value: CObject);
begin
  var dt: CDateTime;
  if Value.TryGetValue<CDateTime>(dt) then
    (_control as TDateEdit).Date := dt.DelphiDateTime;
end;

{ TRadioButtonControlImpl }
function TRadioButtonControlImpl.get_Value: CObject;
begin
  if _control is TCustomEdit then
    Result := (_control as TCustomEdit).Text;
end;

procedure TRadioButtonControlImpl.set_OnChange(Value: TNotifyEvent);
begin
  (_control as TRadioButton).OnChange := Value;
end;

procedure TRadioButtonControlImpl.set_Value(const Value: CObject);
begin
  var s: string;
  if (_control is TCustomEdit) and DoFormatItem(Value, s) then
  begin
    var ce := _control as TCustomEdit;
    ce.Text := s;
  end;
end;

function TRadioButtonControlImpl.get_IsChecked: IIsChecked;
begin
  Interfaces.Supports<IIsChecked>(_control, Result);
end;

function TRadioButtonControlImpl.get_OnChange: TNotifyEvent;
begin
  Result := (_control as TRadioButton).OnChange;
end;

function TRadioButtonControlImpl.get_GroupName: IGroupName;
begin
  Interfaces.Supports<IGroupName>(_control, Result);
end;

{ TImageControlImpl }

function TImageControlImpl.get_ImageIndex: Integer;
begin

end;

procedure TImageControlImpl.set_ImageIndex(const Value: Integer);
begin

end;

{ TGlyphControl }

constructor TGlyphControl.Create(AOwner: TComponent);
begin
  inherited;
  _dcControl := TDCControlImpl.Create(Self);
end;

function TGlyphControl.get_DCControl: IDCControl;
begin
  Result := _dcControl;
end;

{ TComboBoxControlImpl }
function TComboBoxControlImpl.get_ItemCount: Integer;
begin
  Result := (_control as TComboBox).Count;
end;

function TComboBoxControlImpl.get_ItemIndex: Integer;
begin
  Result := (_control as TComboBox).ItemIndex;
end;

procedure TComboBoxControlImpl.set_ItemIndex(const Value: Integer);
begin
  (_control as TComboBox).ItemIndex := Value;
end;

procedure TComboBoxControlImpl.ComboAdd(const str: string);
begin
  (_control as TComboBox).Items.Add(str);
end;

procedure TComboBoxControlImpl.ComboClear;
begin
  (_control as TComboBox).Clear;
end;

function TComboBoxControlImpl.ComboIsDroppedDown: Boolean;
begin
  Result := (_control as TComboBox).DroppedDown;
end;

function TComboBoxControlImpl.ComboItems: List<string>;
begin
  var strings := (_control as TComboBox).Items;
  if (strings <> nil) and (strings.Count > 0) then
  begin
    Result := CList<string>.Create(strings.Count);
    for var s in strings do
      Result.Add(s);
  end;
end;

procedure TComboBoxControlImpl.DropDown;
begin
  RefreshItems;
  (_control as TComboBox).DropDown;
end;

{ TRowLayout }

function TRowLayout.Background: TRectangle;
begin
  Result := _rect;
end;

constructor TRowLayout.Create(AOwner: TComponent; Background: TRectangle);
begin
  inherited Create(AOwner);

  _rect := Background;
  _rect.ClipChildren := True;
  _rect.HitTest := False;
  _rect.Align := TAlignLayout.Contents;
  Self.AddObject(Background);

  _rect.SendToBack;

//  _useBuffering := True;
end;

procedure TRowLayout.DoResized;
begin
  inherited;

  _rect.Width := Self.Width;
  _rect.Height := Self.Height;
end;

function TRowLayout.get_Sides: TSides;
begin
  Result := _rect.Sides;
end;

//function TRowLayout.get_UseBuffering: Boolean;
//begin
//  Result := _useBuffering;
//end;

procedure TRowLayout.Paint;
begin
//  // note that Self.Scene is the original IScene
//  if not _useBuffering and (Self.Scene.GetUpdateRectsCount > 0) then
//    ResetBuffer;

  inherited;
end;

//procedure TRowLayout.ResetBuffer;
//begin
//  // looks drastic, but we cannot access any buffer thingies..
//  // therefor we trigger DoResized
//
//  var w := Self.Width;
//  Self.Width := w - 1;
//  Self.Width := w;
//end;

procedure TRowLayout.set_Sides(const Value: TSides);
begin
  _rect.Sides := Value;
end;

//procedure TRowLayout.set_UseBuffering(const Value: Boolean);
//begin
//  _useBuffering := Value;
//end;

{ TRowLayout2x }

function TRowLayout2x.Background: TRectangle;
begin
  Result := _rect;
end;

constructor TRowLayout2x.Create(AOwner: TComponent; Background: TRectangle);
begin
  inherited Create(AOwner);

  _rect := Background;
  _rect.ClipChildren := True;
  _rect.HitTest := False;
  _rect.Align := TAlignLayout.Contents;
  Self.AddObject(Background);

  _rect.SendToBack;

end;

procedure TRowLayout2x.DoResized;
begin
  inherited;

end;

function TRowLayout2x.get_Sides: TSides;
begin
  Result := _rect.Sides;
end;

function TRowLayout2x.get_UseBuffering: Boolean;
begin
  Result := False;
end;

procedure TRowLayout2x.ResetBuffer;
begin

end;

procedure TRowLayout2x.set_Sides(const Value: TSides);
begin
  _rect.Sides := Value;
end;

procedure TRowLayout2x.set_UseBuffering(const Value: Boolean);
begin

end;

initialization
  DataControlClassFactory := TDataControlClassFactory.Create;

  DEFAULT_GREY_COLOR := TAlphaColor($FFF1F2F7);
  DEFAULT_WHITE_COLOR := TAlphaColors.Null;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR := TAlphaColor($886A5ACD);
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR := TAlphaColor($88778899);
  {$IFDEF WEBASSEMBLY}
  DEFAULT_ROW_HOVER_COLOR := TAlphaColors.Lightgray;
  {$ELSE}
  DEFAULT_ROW_HOVER_COLOR := TAlphaColor($335B8BCD);
  {$ENDIF}

  DEFAULT_HEADER_BACKGROUND := TAlphaColors.Null;
  DEFAULT_HEADER_STROKE := TAlphaColors.Grey;
  {$IFDEF WEBASSEMBLY}
  DEFAULT_CELL_STROKE := TAlphaColors.White;
  {$ELSE}
  DEFAULT_CELL_STROKE := TAlphaColors.Lightgray;
  {$ENDIF}

finalization
  DataControlClassFactory := nil;

end.


