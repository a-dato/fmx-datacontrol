unit ADato.FMX.FastControls.Text;

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
  {$ENDIF}
  System_,
  FMX.Layouts,
  FMX.TextLayout, System.Types, ADato.ObjectModel.Binders;

type
  TDateTimeEditOnKeyDownOverride = class(TDateEdit)
  protected
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  end;

  TFastText = class(TLayout, ICaption, ITextSettings)
  protected
    _text: string;
    _layout: TTextLayout;
    _settings: TTextSettings;
    _style: TStyledSettings;
    _autoWidth: Boolean;
    _calcAsAutoWidth: Boolean;

    _recalcNeeded: Boolean;
    _recalcNeededWithOwnCanvas: Boolean;
    _waitingForRepaint: Boolean;
    _ignoreDefaultPaint: Boolean;

    _textBounds: TRectF;
    _onChange: TNotifyEvent;
    _maxWidth: Single;

    // ICaption
    function  GetText: string;
    procedure SetText(const Value: string);
    function  TextStored: Boolean;

    // ITextSettings
    function  GetDefaultTextSettings: TTextSettings;
    function  GetTextSettings: TTextSettings;
    procedure SetTextSettings(const Value: TTextSettings);
    function  GetResultingTextSettings: TTextSettings;
    function  GetStyledSettings: TStyledSettings;
    procedure SetStyledSettings(const Value: TStyledSettings);
    procedure set_WordWrap(const Value: Boolean);
    procedure set_Trimming(const Value: TTextTrimming);
    function  get_Style: TFontStyles;
    procedure set_Style(const Value: TFontStyles);
    function  get_HorzTextAlign: TTextAlign;
    procedure set_HorzTextAlign(const Value: TTextAlign);
    function  get_VertTextAlign: TTextAlign;
    procedure set_VertTextAlign(const Value: TTextAlign);
    procedure set_AutoWidth(const Value: Boolean);
    procedure set_CalcAsAutoWidth(const Value: Boolean);
    function  get_Trimming: TTextTrimming;
    function  get_WordWrap: Boolean;

  protected
    procedure DoPaint; override;
    procedure Painting; override;
    procedure DoResized; override;

    procedure Calculate; virtual;
    procedure RecalcNeeded;

//    procedure PaddingChanged; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareForPaint; override;
    procedure RecalcOpacity; override;

    function TextWidth: Single;
    function TextHeight: Single;
    function TextWidthWithPadding: Single;
    function TextHeightWithPadding: Single;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings;

    property CalcAsAutoWidth: Boolean read _calcAsAutoWidth write set_CalcAsAutoWidth default False;

  published
    property Text: string read GetText write SetText;
    property WordWrap: Boolean read get_WordWrap write set_WordWrap default False;
    property Trimming: TTextTrimming read get_Trimming write set_Trimming default TTextTrimming.None;
    property Style: TFontStyles read get_Style write set_Style default [];
    property VertTextAlign: TTextAlign read get_VertTextAlign write set_VertTextAlign default TTextAlign.Leading;
    property HorzTextAlign: TTextAlign read get_HorzTextAlign write set_HorzTextAlign default TTextAlign.Leading;

    property AutoWidth: Boolean read _autoWidth write set_AutoWidth default False;
    property MaxWidth: Single write _maxWidth;

    property HitTest default False;

    property OnChange: TNotifyEvent read _onChange write _onChange;
  end;


  TFastTextControlBinding = class(TControlBinding<TFastText>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TFastTextControlSmartLinkBinding = class(TFastTextControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils
  {$ELSE}
  Wasm.System.SysUtils
  {$ENDIF}
  , System.Math, ADato.ObjectModel.intf;

{ TDateTimeEditOnKeyDownOverride }

procedure TDateTimeEditOnKeyDownOverride.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
begin
  // Send vkReturn to any listener!
  // Delphi's TDateEdit control passes vkReturn to the Observer only

  if (Key = vkReturn) and Assigned(OnKeyDown) then
    OnKeyDown(Self, Key, KeyChar, Shift);

  inherited;
end;

{ TFastText }


constructor TFastText.Create(AOwner: TComponent);
begin
  inherited;

  _layout := TTextLayoutManager.DefaultTextLayout.Create;
  _settings := TTextSettings.Create(Self);

  _settings.VertAlign := TTextAlign.Leading;
  _settings.HorzAlign := TTextAlign.Leading;
end;

destructor TFastText.Destroy;
begin
  FreeAndNil(_layout);
  FreeAndNil(_settings);

  inherited;
end;

procedure TFastText.DoPaint;
begin
  _waitingForRepaint := False;

//  Self.Canvas.Fill.Color := TALphaCOlors.Purple;
//  Self.Canvas.FillRect(RectF(0,0,Width,Height), 0.2);

  inherited;

  if not _ignoreDefaultPaint then
  begin
    _layout.Opacity := AbsoluteOpacity;
    _layout.RenderLayout(Canvas);
  end;
end;

procedure TFastText.DoResized;
begin
  inherited;
  RecalcNeeded;
end;

//procedure TFastText.PaddingChanged;
//begin
//  inherited;
//  RecalcNeeded;
//end;

procedure TFastText.Painting;
begin
  Calculate;
  inherited;
end;

procedure TFastText.PrepareForPaint;
begin
  Calculate;
  inherited;
end;

function TFastText.GetDefaultTextSettings: TTextSettings;
begin
  Calculate;
  Result := _settings;
end;

function TFastText.GetResultingTextSettings: TTextSettings;
begin
  Calculate;
  Result := _settings;
end;

function TFastText.GetStyledSettings: TStyledSettings;
begin
  Result := [];
end;

function TFastText.GetText: string;
begin
  Result := _text;
end;

function TFastText.GetTextSettings: TTextSettings;
begin
//  Calculate;
  Result := _settings;
end;

function TFastText.get_HorzTextAlign: TTextAlign;
begin
  Result := _settings.HorzAlign;
end;

function TFastText.get_Style: TFontStyles;
begin
  Result := _settings.Font.Style;
end;

function TFastText.get_Trimming: TTextTrimming;
begin
  Result := _settings.Trimming;
end;

function TFastText.get_VertTextAlign: TTextAlign;
begin
  Result := _settings.VertAlign;
end;

function TFastText.get_WordWrap: Boolean;
begin
  Result := _settings.WordWrap;
end;

procedure TFastText.RecalcNeeded;
begin
  _recalcNeeded := True;
  if not FInPaintTo and not _waitingForRepaint then
  begin
    _waitingForRepaint := True;
    Repaint;
  end;
end;

procedure TFastText.RecalcOpacity;
begin
  inherited;
  Repaint;
end;

procedure TFastText.Calculate;
begin
  if not _recalcNeeded then
  begin
    if not _recalcNeededWithOwnCanvas or (Self.Canvas = nil) then
      Exit;
  end;

  _recalcNeeded := False;

  var cv := Self.Canvas;
  if cv = nil then
  begin
    cv := TCanvasManager.MeasureCanvas;
    _recalcNeededWithOwnCanvas := True;
  end else
    _recalcNeededWithOwnCanvas := False;

  cv.Font.Size := _settings.Font.Size;

  var maxWidth := IfThen(_autoWidth or _calcAsAutoWidth, 9999, IfThen(_maxWidth > 0, _maxWidth, Self.Width));
  var maxHeight := IfThen(get_WordWrap, 9999, Self.Height);
  var txt := GetText;
  if Length(txt) = 0 then
    txt := 'Gg';

  _layout.BeginUpdate;
  try
    _layout.Text := txt;
    _layout.LayoutCanvas := cv;
    _layout.TopLeft := PointF(0,0);
    _layout.MaxSize := PointF(maxWidth, maxHeight);
    _layout.HorizontalAlign := _settings.HorzAlign;
    _layout.VerticalAlign := _settings.VertAlign;
    _layout.WordWrap := get_WordWrap;
    _layout.Trimming := get_Trimming;

    _layout.Font := _settings.Font;
    _layout.Color := _settings.FontColor;
  finally
    _layout.EndUpdate;
  end;

  _textBounds :=  _layout.TextRect;
  if _autoWidth then
    Self.Width := _textBounds.Width + Self.Padding.Left + Self.Padding.Right;

  _layout.BeginUpdate;
  try
    _layout.Text := _text;
    _layout.TopLeft := PointF(Self.Padding.Left, Self.Padding.Top);
    _layout.MaxSize := PointF(Self.Width - Self.Padding.Left - Self.Padding.Right, Self.Height - Self.Padding.Top - Self.Padding.Bottom);
  finally
    _layout.EndUpdate;
  end;
end;

procedure TFastText.SetStyledSettings(const Value: TStyledSettings);
begin
end;

procedure TFastText.SetText(const Value: string);
begin
  if _text <> Value then
  begin
    _text := Value;
    RecalcNeeded;

    if Assigned(_onChange) then
      _onChange(Self);
  end;
end;

procedure TFastText.SetTextSettings(const Value: TTextSettings);
begin
  _settings := Value;
end;

procedure TFastText.set_AutoWidth(const Value: Boolean);
begin
  if _autoWidth <> Value then
  begin
    _autoWidth := Value;
    if _autoWidth then
      set_WordWrap(False);

    RecalcNeeded;
  end;
end;

procedure TFastText.set_CalcAsAutoWidth(const Value: Boolean);
begin
  if _calcAsAutoWidth <> Value then
  begin
    _calcAsAutoWidth := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_HorzTextAlign(const Value: TTextAlign);
begin
  if _settings.HorzAlign <> Value then
  begin
    _settings.HorzAlign := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_Style(const Value: TFontStyles);
begin
  if _settings.Font.Style <> Value then
  begin
    _settings.Font.Style := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_Trimming(const Value: TTextTrimming);
begin
  if _settings.Trimming <> Value then
  begin
    _settings.Trimming := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_VertTextAlign(const Value: TTextAlign);
begin
  if _settings.VertAlign <> Value then
  begin
    _settings.VertAlign := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_WordWrap(const Value: Boolean);
begin
  if _settings.WordWrap <> Value then
  begin
    _settings.WordWrap := Value;
    if _settings.WordWrap then
      _autoWidth := False;

    RecalcNeeded;
  end;
end;

function TFastText.TextHeight: Single;
begin
  Calculate;
  Result := _textBounds.Height;
end;

function TFastText.TextHeightWithPadding: Single;
begin
  Result := TextHeight + Self.Padding.Top + Self.Padding.Bottom;
end;

function TFastText.TextStored: Boolean;
begin
  Result := False;
end;

function TFastText.TextWidth: Single;
begin
  Calculate;
  Result := _textBounds.Width;
end;

function TFastText.TextWidthWithPadding: Single;
begin
  Result := TextWidth + Padding.Left + Padding.Right;
end;


{ TFastTextControlBinding }

function TFastTextControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := nil;
  {$ELSE}
  Result := _value;
  {$ENDIF}
end;

procedure TFastTextControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  if Value <> nil then
    _Control.Text := CStringToString(Value.ToString) else
    _Control.Text := '';
end;

{ TFastTextControlSmartLinkBinding }

procedure TFastTextControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

initialization
  TPropertyBinding.RegisterClassBinding(TFastText,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TFastTextControlSmartLinkBinding.Create(TFastText(Control)) end);


end.


