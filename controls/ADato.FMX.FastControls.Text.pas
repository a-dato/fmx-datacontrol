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
  FMX.Layouts,
  FMX.TextLayout, 
  System.Types,
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
  Wasm.System.Types,
  {$ENDIF}
  System_,
  ADato.ObjectModel.Binders;

type
  TDateTimeEditOnKeyDownOverride = class(TDateEdit)
  protected
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  end;

  TFastText = class(TLayout, ICaption, ITextSettings)
  protected
    _text: string;
    _subText: string;
    _layout: TTextLayout;
    _subTextlayout: TTextLayout;
    _settings: TTextSettings;
    _style: TStyledSettings;
    _autoWidth: Boolean;
    _calcAsAutoWidth: Boolean;
    _underlineOnHover: Boolean;

    _recalcNeeded: Boolean;
    _recalcNeededWithOwnCanvas: Boolean;
    _waitingForRepaint: Boolean;
    _ignoreDefaultPaint: Boolean;

    _textBounds: TRectF;
    _subTextBounds: TRectF;
    _onChange: TNotifyEvent;
    _maxWidth: Single;

    _subTextFontSize: Single;
    _subTextFontColor: TAlphaColor;

    _mouseIsDown: Boolean;
    _hover: Boolean;

    // for checkbox ctrl
    _internalLeftPadding: Single;
    _internalRightPadding: Single;

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
    procedure set_SubText(const Value: string);

  protected
    procedure DoPaint; override;
//    procedure Painting; override;
    procedure DoResized; override;

    procedure Calculate; virtual;
    procedure RecalcNeeded;
    procedure RepaintNeeded;

    procedure CalculateText(const MaxWidth, MaxHeight: Single);
    procedure CalculateSubText(const MaxWidth, MaxHeight: Single);

    procedure DoMouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;
//    procedure PrepareForPaint; override;
    procedure RecalcOpacity; override;

    function TextWidth: Single;
    function TextHeight: Single;
    function TextWidthWithPadding: Single;
    function TextHeightWithPadding: Single;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings;
    property SubText: string read _subText write set_SubText;

  published
    property Text: string read GetText write SetText;
    property WordWrap: Boolean read get_WordWrap write set_WordWrap default False;
    property Trimming: TTextTrimming read get_Trimming write set_Trimming default TTextTrimming.None;
    property Style: TFontStyles read get_Style write set_Style default [];
    property VertTextAlign: TTextAlign read get_VertTextAlign write set_VertTextAlign default TTextAlign.Leading;
    property HorzTextAlign: TTextAlign read get_HorzTextAlign write set_HorzTextAlign default TTextAlign.Leading;

    property AutoWidth: Boolean read _autoWidth write set_AutoWidth default False;
    property CalcAsAutoWidth: Boolean read _calcAsAutoWidth write set_CalcAsAutoWidth default False;
    property MaxWidth: Single write _maxWidth;
    property UnderlineOnHover: Boolean read _underlineOnHover write _underlineOnHover default False;

    property HitTest {$IFNDEF WEBASSEMBLY}default False{$ENDIF};

    property OnChange: TNotifyEvent read _onChange write _onChange;
  end;


  TFastTextControlBinding = class(TControlBinding<TFastText>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    procedure UpdateControlEditability(IsEditable: Boolean); override;
  end;

  TFastTextControlSmartLinkBinding = class(TFastTextControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

const
  SUBTEXT_NEGATIVE_MARGIN = -2;

var
  APPLICATION_FONT_FAMILY: string = 'Segoe UI';

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Math
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Math
  {$ENDIF}
  , ADato.ObjectModel.intf;

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


procedure TFastText.CalculateSubText(const MaxWidth, MaxHeight: Single);
begin
  if Length(_subText) = 0 then
  begin
    _subTextBounds := TRectF.Empty;
    Exit;
  end;

  var cv := Self.Canvas;
  if cv = nil then
    cv := TCanvasManager.MeasureCanvas;

  cv.Font.Size := _settings.Font.Size;

  _subTextlayout.BeginUpdate;
  try
    _subTextlayout.Text := _subText;
    _subTextlayout.LayoutCanvas := cv;
    _subTextlayout.TopLeft := PointF(0,0);
    _subTextlayout.MaxSize := PointF(maxWidth, maxHeight);
    _subTextlayout.HorizontalAlign := _settings.HorzAlign;
    _subTextlayout.VerticalAlign := _settings.VertAlign;
    _subTextlayout.WordWrap := get_WordWrap;
    _subTextlayout.Trimming := get_Trimming;
    _subTextlayout.Font := _settings.Font;
    _subTextlayout.Font.Size := _subTextFontSize;
    _subTextlayout.Font.Style := [];
    _subTextlayout.Color := _subTextFontColor;
  finally
    _subTextlayout.EndUpdate;
  end;

  _subTextBounds := _subTextlayout.TextRect;
end;

procedure TFastText.CalculateText(const MaxWidth, MaxHeight: Single);
begin
  var cv := Self.Canvas;
  if cv = nil then
  begin
    cv := TCanvasManager.MeasureCanvas;
    _recalcNeededWithOwnCanvas := True;
  end else
    _recalcNeededWithOwnCanvas := False;

  cv.Font.Size := _settings.Font.Size;

  _layout.BeginUpdate;
  try
    _layout.Text := GetText;
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

  _textBounds := _layout.TextRect;
end;

constructor TFastText.Create(AOwner: TComponent);
begin
  inherited;

  {$IFNDEF WEBASSEMBLY}
  _layout := TTextLayoutManager.DefaultTextLayout.Create;
  {$ELSE}
  _layout := TTextLayoutManager.DefaultTextLayout.Create(Self.Canvas);
  {$ENDIF}
  _layout.Font.Family := APPLICATION_FONT_FAMILY;

  _settings := TTextSettings.Create(Self);
  _settings.VertAlign := TTextAlign.Leading;
  _settings.HorzAlign := TTextAlign.Leading;

  _subText := '';
  _subTextFontSize := 10;
  _subTextFontColor := TAlphaColors.Lightslategray;
end;

destructor TFastText.Destroy;
begin
  FreeAndNil(_layout);
  FreeAndNil(_subTextlayout);
  FreeAndNil(_settings);

  inherited;
end;

procedure TFastText.DoPaint;
begin
  _waitingForRepaint := False;

  {$IFDEF WEBASSEMBLY}
  if Self.Parent.IsOfType<TControl> then
    _layout.TopLeft := (Self.Parent as TControl).LocalToAbsolute({TPointF.Create(0, 0}TPointF.Create(0, 15));
  {$ENDIF}

//  Self.Canvas.Fill.Color := TALphaColors.Purple;
//  Self.Canvas.FillRect(RectF(0,0,Width,Height), 0.2);

  inherited;

  if not _ignoreDefaultPaint then
  begin
    _layout.Opacity := AbsoluteOpacity;
    _layout.RenderLayout(Canvas);

    if Length(_subText) > 0 then
    begin
      _subTextlayout.Opacity := AbsoluteOpacity;
      _subTextlayout.RenderLayout(Canvas);
    end;
  end;

  if _hover and _underlineOnHover and not _mouseIsDown then
  begin
    Canvas.Stroke.Color := _layout.Color;

    var rect := _layout.TextRect;
    Canvas.DrawLine(PointF(rect.Left, rect.Bottom), PointF(rect.Right, rect.Bottom), AbsoluteOpacity);
  end;
end;

procedure TFastText.DoResized;
begin
  inherited;
  RecalcNeeded;
end;

procedure TFastText.Paint;
begin
  Calculate;
  inherited;
end;

//procedure TFastText.Painting;
//begin
////  Calculate;
//
//  inherited;
//end;

//procedure TFastText.PrepareForPaint;
//begin
////  Calculate;
//
//  inherited;
//end;

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

procedure TFastText.DoMouseLeave;
begin
  inherited;
  _mouseIsDown := False;
  _hover := False;

  RepaintNeeded;
end;

procedure TFastText.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  _mouseIsDown := True;
  inherited;

  RepaintNeeded;
end;

procedure TFastText.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;

  if not _hover and Self.Enabled then
  begin
    _hover := True;
    RepaintNeeded;
  end;
end;

procedure TFastText.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;

  _mouseIsDown := False;
  RepaintNeeded;
end;

procedure TFastText.RecalcNeeded;
begin
  _recalcNeeded := True;
  RepaintNeeded;
end;

procedure TFastText.RecalcOpacity;
begin
  inherited;
  Repaint;
end;

procedure TFastText.RepaintNeeded;
begin
  if not FInPaintTo and not _waitingForRepaint then
  begin
    _waitingForRepaint := True;
    Repaint;
  end;
end;

procedure TFastText.Calculate;
begin
  if not _recalcNeeded then
  begin
    if not _recalcNeededWithOwnCanvas or (Self.Canvas = nil) then
      Exit;
  end;

  _recalcNeeded := False;

  var maxWidth := IfThen(_autoWidth or _calcAsAutoWidth, 9999, IfThen(_maxWidth > 0, _maxWidth, Self.Width - Padding.Left - Padding.Right - _internalLeftPadding - _internalRightPadding));
  var maxHeight := IfThen(get_WordWrap, 9999, Self.Height - Padding.Top - Padding.Bottom);

  CalculateSubText(maxWidth, maxHeight);
  CalculateText(maxWidth, maxHeight);

  if _autoWidth then
    Self.Width := TextWidthWithPadding;

  var subTextHeightSubstraction := CMath.Max(_subTextBounds.Height + SUBTEXT_NEGATIVE_MARGIN, 0);

  _layout.BeginUpdate;
  try
    _layout.TopLeft := PointF(Self.Padding.Left + _internalLeftPadding, Self.Padding.Top);
    _layout.MaxSize := PointF(
      Self.Width - Self.Padding.Left - Self.Padding.Right - _internalLeftPadding - _internalRightPadding,
      Self.Height - Self.Padding.Top - Self.Padding.Bottom - subTextHeightSubstraction);
  finally
    _layout.EndUpdate;
  end;

  if _subTextlayout <> nil then
  begin
    _subTextlayout.BeginUpdate;
    try
      _subTextlayout.TopLeft := PointF(Self.Padding.Left + _internalLeftPadding, Self.Padding.Top + subTextHeightSubstraction);
      _subTextlayout.MaxSize := PointF(
        Self.Width - Self.Padding.Left - Self.Padding.Right - _internalLeftPadding - _internalRightPadding,
        Self.Height - Self.Padding.Top - Self.Padding.Bottom - subTextHeightSubstraction);
    finally
      _subTextlayout.EndUpdate;
    end;
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

    if _autoWidth then
      Calculate; // do immideate outside paint

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
    _autoWidth := Value and not (Self.Align in [TAlignLayout.Client, TAlignLayout.Top, TAlignLayout.MostTop, TAlignLayout.Bottom, TAlignLayout.MostBottom]);
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

procedure TFastText.set_SubText(const Value: string);
begin
  if _subText <> Value then
  begin
    _subText := Value;

    if _subTextlayout = nil then
      {$IFNDEF WEBASSEMBLY}
      _subTextlayout := TTextLayoutManager.DefaultTextLayout.Create;
      {$ELSE}
      _subTextlayout := TTextLayoutManager.DefaultTextLayout.Create(nil);
      {$ENDIF}

    RecalcNeeded;

    if _autoWidth then
      Calculate; // do immideate outside paint
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
  Result := _textBounds.Height + CMath.Max(_subTextBounds.Height + SUBTEXT_NEGATIVE_MARGIN, 0);
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
  Result := CMath.Max(_textBounds.Width, _subTextBounds.Width);
end;

function TFastText.TextWidthWithPadding: Single;
begin
  Result := TextWidth + Padding.Left + Padding.Right + _internalLeftPadding + _internalRightPadding;
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

procedure TFastTextControlBinding.UpdateControlEditability(IsEditable: Boolean);
begin
  // textControls can't be edited, therefor always should be true so that they can be copied!!

//  inherited;
  _control.Enabled := True;
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


