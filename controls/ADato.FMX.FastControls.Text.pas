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
  ADato.ObjectModel.Binders,
  FMX.ScrollControl.ControlClasses.Intf;

type
  TFastControl = class(TLayout)
  protected
    _controlIsLoaded: Boolean;
    _isAlive: IInterface;

    _waitingForRepaint: Boolean;
    _recalcNeeded: Boolean;
    _autoWidth: Boolean;
    _autoSizeNeeded: Boolean;

    _recalcIndex: Integer;

    procedure Loaded; override;
    procedure RepaintNeeded;
    procedure RecalcNeeded; virtual;

    function  ShouldRecalculate: Boolean;
    procedure ControlLoadedCalculate;
    procedure Calculate; virtual;

    procedure CalculateSafeAutoSize;
    function  DoAutoSize: Boolean; virtual;
    procedure ApplyAutoSize; virtual; abstract;

    procedure DoResized; override;
    procedure PaddingChanged; override;
    procedure RecalcOpacity; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure EndUpdate; override;
    procedure PrepareForPaint; override;
    procedure Painting; override;

    procedure ForceRealign(OnlyWhenRealignNeeded: Boolean = False);
    procedure RequestRealign;
  end;

  TDateTimeEditOnKeyDownOverride = class(TDateEdit)
  protected
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  end;

  TCheckPosition = (Left, Right);

  TFastText = class(TFastControl, IDCControl, ITextControl, ICaption, ITextSettings)
  protected
    _dcControl: IDCControl;
    function get_DCControl: IDCControl;

  public
    property DCControl: IDCControl read get_DCControl implements IDCControl;

  protected
    _text: string;
    _layout: TTextLayout;
    _settings: TTextSettings;
    _calcAsAutoHeight: Boolean;
    _underlineOnHover: Boolean;

    _textBounds: TRectF;
    _onChange: TNotifyEvent;
    _maxWidth: Integer;

    _mouseIsDown: Boolean;
    _hover: Boolean;

    // for checkbox ctrl
    _internalLeftPadding: Single;
    _internalRightPadding: Single;
    _internalBottomPadding: Single;

    // TInverseLabel
    _ignoreDefaultPaint: Boolean;

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
    function  get_MaxWidth: Integer;
    procedure set_MaxWidth(const Value: Integer);
    function  get_CalcAsAutoHeight: Boolean;
    procedure set_CalcAsAutoHeight(const Value: Boolean);
    function  get_Trimming: TTextTrimming;
    function  get_WordWrap: Boolean;

  protected
    procedure DoPaint; override;
    function  GetDefaultSize: TSizeF; override;
//    function  IsControlRectEmpty: Boolean; override;

    procedure Calculate; override;
    procedure EnsureLayoutForCanvas(const ACanvas: TCanvas);
    procedure InvalidateBoundsChange(const OldBounds, NewBounds: TRectF);
    procedure ApplyAutoSize; override;

    function  CalculateTextXPos: Single;
    function  CalculateTextYPos: Single;

    procedure DoMouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure SetVisible(const Value: Boolean); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function HasText: Boolean;
    function TextWidth: Single; virtual;
    function TextHeight: Single; virtual;
    function TextWidthWithPadding: Single;
    function TextHeightWithPadding: Single;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings;

  published
    property Text: string read GetText write SetText;
    property WordWrap: Boolean read get_WordWrap write set_WordWrap default False;
    property Trimming: TTextTrimming read get_Trimming write set_Trimming default TTextTrimming.None;
    property Style: TFontStyles read get_Style write set_Style default [];
    property VertTextAlign: TTextAlign read get_VertTextAlign write set_VertTextAlign default TTextAlign.Leading;
    property HorzTextAlign: TTextAlign read get_HorzTextAlign write set_HorzTextAlign default TTextAlign.Leading;

    property AutoWidth: Boolean read _autoWidth write set_AutoWidth default False;
    property MaxWidth: Integer read get_MaxWidth write set_MaxWidth default 0;
    property CalcAsAutoHeight: Boolean read get_calcAsAutoHeight write set_CalcAsAutoHeight default True;
    property UnderlineOnHover: Boolean read _underlineOnHover write _underlineOnHover default False;

    property HitTest {$IFNDEF WEBASSEMBLY}default False{$ENDIF};

    property OnChange: TNotifyEvent read _onChange write _onChange;
  end;

  TFastCheckbox = class(TFastText, IDCEditControl, ITextControl, IIsChecked, IIsSemiChecked)
  protected
    _editControl: IDCEditControl;

  strict private
    _stateChangedThisHover: Boolean;
    _checkAnimationTimer: TTimer;
    _checkAnimationStartedAt: UInt64;
    _checkAnimationDurationMs: Single;
    _checkAnimationFromState: TCheckState;
    _checkAnimationToState: TCheckState;
    _checkAnimationProgress: Single;
  private
    _checkPosition: TCheckPosition;
    _checkState: TCheckState;
    _checkSize: Single;
    _checkTextMargin: Single;
    _onCheckChange: TNotifyEvent;

    procedure CheckAnimationTimer(Sender: TObject);
    procedure ConfigureCheckAnimation(const FromState: TCheckState; const Immediate: Boolean = False);
    procedure EnsureCheckAnimationTimer;
    function  GetCheckAnimationT: Single;
    function  GetStateVisualProgress(const State: TCheckState): Single;
    function  InterpolatePoint(const FromPoint, ToPoint: TPointF; const Progress: Single): TPointF;
    function  InterpolateRect(const FromRect, ToRect: TRectF; const Progress: Single): TRectF;
    procedure SetCheckAnimationProgress(const Progress: Single);
    procedure StopCheckAnimation;

    function get_EditControl: IDCEditControl;
    function  get_CheckState: TCheckState;
    procedure set_CheckPosition(const Value: TCheckPosition);

    function  IsCheckedStored: Boolean;

  protected
    procedure Calculate; override;
    procedure DoPaint; override;
    procedure DoMouseLeave; override;
    function  GetCheckColor: TAlphaColor; virtual;
    function  GetIsChecked: Boolean; virtual;
    function  IsRadioButton: Boolean; virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DrawAnimatedCheckMark(const Rect: TRectF; const DrawOpacity, Progress: Single; const Color: TAlphaColor); virtual;
    procedure PaintCheckedVisual(const Rect, InnerRect: TRectF; const Radius, DrawOpacity, Progress: Single; const AccentColor, CheckMarkColor: TAlphaColor); virtual;
    procedure PaintGrayedVisual(const Rect, InnerRect: TRectF; const Radius, DrawOpacity, Progress: Single; const AccentColor: TAlphaColor); virtual;
    procedure PaintUncheckedVisual(const Rect: TRectF; const Radius, DrawOpacity, Progress, HighlightProgress: Single; const AccentColor: TAlphaColor); virtual;
    procedure SetCheckStateCore(const Value: TCheckState; const TriggerEvents: Boolean = True); virtual;
    procedure set_CheckState(const Value: TCheckState); virtual;
    procedure SetIsChecked(const Value: Boolean); virtual;
    procedure ToggleCheckState; virtual;

  public
    constructor Create(AOwner: TComponent); override;

    procedure UpdateState(CheckCount, TotalCount: Integer);

    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
    property EditControl: IDCEditControl read get_EditControl implements IDCEditControl;

  published
    property CheckPosition: TCheckPosition read _checkPosition write set_CheckPosition default TCheckPosition.Left;
    property CheckState: TCheckState read get_CheckState write set_CheckState default TCheckState.Unchecked;
    property OnCheckChange: TNotifyEvent read _onCheckChange write _onCheckChange;

    property OnClick;
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

  TFastCheckboxControlBinding = class(TControlBinding<TFastText>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    procedure UpdateControlEditability(IsEditable: Boolean); override;
  end;

  TFastCheckboxControlSmartLinkBinding = class(TFastCheckboxControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

const
  SUBTEXT_NEGATIVE_MARGIN = 0;

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
  , ADato.ObjectModel.intf, FMX.ScrollControl.ControlClasses,
  {$IFDEF SKIA}
  FMX.Skia,
  {$ENDIF}
  System.Math.Vectors;

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

procedure TFastText.EnsureLayoutForCanvas(const ACanvas: TCanvas);
begin
  var layoutClass := TTextLayoutManager.DefaultTextLayout;
  if ACanvas <> nil then
    layoutClass := TTextLayoutManager.TextLayoutByCanvas(ACanvas.ClassType);

  if (_layout = nil) or (_layout.ClassType <> layoutClass) then
  begin
    FreeAndNil(_layout);
    _layout := layoutClass.Create(ACanvas);
    _layout.Font.Family := APPLICATION_FONT_FAMILY;
    _recalcNeeded := True;
  end;

  if _layout.LayoutCanvas <> ACanvas then
    _layout.LayoutCanvas := ACanvas;
end;

constructor TFastText.Create(AOwner: TComponent);
begin
  inherited;

  _dcControl := TDCControlImpl.Create(Self);

//  {$IFNDEF WEBASSEMBLY}
//  _layout := TTextLayoutManager.DefaultTextLayout.Create;
//  {$ELSE}
//  _layout := TTextLayoutManager.DefaultTextLayout.Create(Self.Canvas);
//  {$ENDIF}
//  _layout.Font.Family := APPLICATION_FONT_FAMILY;

  _settings := TTextSettings.Create(Self);
  _settings.VertAlign := TTextAlign.Leading;
  _settings.HorzAlign := TTextAlign.Leading;

  _calcAsAutoHeight := True;
end;

function TFastText.get_DCControl: IDCControl;
begin
  Result := _dcControl;
end;

destructor TFastText.Destroy;
begin
  FreeAndNil(_layout);
  FreeAndNil(_settings);

  inherited;
end;

function TFastText.CalculateTextXPos: Single;
begin
  Result := Padding.Left + _internalLeftPadding;
  case get_HorzTextAlign of
    TTextAlign.Center: Result := (Self.Width - _textBounds.Width) / 2;
    TTextAlign.Leading: Result := Padding.Left + _internalLeftPadding;
    TTextAlign.Trailing: Result := Self.Width - TextWidth - Padding.Right - _internalRightPadding;
  end;
end;

function TFastText.CalculateTextYPos: Single;
begin
  var totHeight := _textBounds.Height;
  Result := Padding.Top;
  case get_VertTextAlign of
    TTextAlign.Center: Result := (Self.Height - totHeight - _internalBottomPadding) / 2;
    TTextAlign.Leading: Result := Padding.Top;
    TTextAlign.Trailing: Result := Self.Height - totHeight - Padding.Bottom - _internalBottomPadding;
  end;
end;

procedure TFastText.DoPaint;
begin
  {$IFDEF WEBASSEMBLY}
  if Self.Parent.IsOfType<TControl> then
    _layout.TopLeft := (Self.Parent as TControl).LocalToAbsolute({TPointF.Create(0, 0}TPointF.Create(0, 15));
  {$ENDIF}

  inherited;

  if not _ignoreDefaultPaint then
  begin
    _layout.Opacity := AbsoluteOpacity;
    _layout.TopLeft := PointF(CalculateTextXPos, CalculateTextYPos);

    var maxW := CMath.Min(TextWidthWithPadding - _internalLeftPadding - _internalRightPadding, Self.Width - _layout.TopLeft.X);
    var maxH := CMath.Min(TextHeightWithPadding - _internalBottomPadding, Self.Height - _layout.TopLeft.Y);

    _layout.MaxSize := PointF(maxW, maxH);

  //  {$IFDEF DEBUG}
  //  Self.Canvas.Fill.Color := TAlphaColors.Mediumpurple;
  //  Self.Canvas.FillRect(RectF(0, 0, Self.Width, Self.Height), 0.2);
  //
  //  Self.Canvas.Fill.Color := TAlphaColors.Darkred;
  //  Self.Canvas.FillRect(RectF(_layout.TopLeft.X, _layout.TopLeft.Y, _layout.TopLeft.X + _layout.MaxSize.X, _layout.TopLeft.Y + _layout.MaxSize.Y), 0.05);
  //  {$ENDIF}

    _layout.RenderLayout(Canvas);
  end;

  if _hover and _underlineOnHover then
  begin
    var textBottom := CMath.Min(_layout.TopLeft.Y + _layout.MaxSize.Y, Self.Height);
    var textWidth := CMath.Min(_textBounds.Width, Self.Width - _layout.TopLeft.X);

    Canvas.Stroke.Color := _layout.Color;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.DrawLine(PointF(_layout.TopLeft.X, textBottom), PointF(_layout.TopLeft.X + textWidth, textBottom), AbsoluteOpacity * IfThen(_mouseIsDown, 0.3, 1));
  end;
end;

//function TFastText.IsControlRectEmpty: Boolean;
//begin
//  Result := inherited or (Length(GetText) = 0) or SameValue(AbsoluteOpacity, 0)
//end;

function TFastText.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(50, 16);
end;

function TFastText.GetDefaultTextSettings: TTextSettings;
begin
  ControlLoadedCalculate;
  Result := _settings;
end;

function TFastText.GetResultingTextSettings: TTextSettings;
begin
  ControlLoadedCalculate;
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

function TFastText.get_MaxWidth: Integer;
begin
  Result := _maxWidth;
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

function TFastText.HasText: Boolean;
begin
  Result := Length(_text) > 0;
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

procedure TFastText.InvalidateBoundsChange(const OldBounds, NewBounds: TRectF);
begin
  var dirtyRect := TRectF.Union(OldBounds, NewBounds);
  var padding := 2.0;
  if (Scene <> nil) and (Scene.GetSceneScale > 0) then
    padding := padding / Scene.GetSceneScale;

  dirtyRect.Inflate(padding, padding);

  if ParentControl <> nil then
    ParentControl.InvalidateRect(dirtyRect)
  else
    Repaint;
end;

procedure TFastText.ApplyAutoSize;
begin
  var newWidth := TextWidthWithPadding;
  if SameValue(Self.Width, newWidth) then
    Exit;

  var oldBounds := BoundsRect;
  Self.Width := newWidth;
  var newBounds := BoundsRect;

  InvalidateBoundsChange(oldBounds, newBounds);
end;

procedure TFastText.Calculate;
begin
  var layoutCanvas := Self.Canvas;
  if layoutCanvas = nil then
    layoutCanvas := TCanvasManager.MeasureCanvas;

  EnsureLayoutForCanvas(layoutCanvas);

  if not ShouldRecalculate then
    Exit;

  inherited;

  var maxInternalWidth := _maxWidth - Padding.Left - Padding.Right - _internalLeftPadding - _internalRightPadding;
  var maxWidth := IfThen(_maxWidth > 0, maxInternalWidth, IfThen(get_WordWrap, Self.Width, 9999));
  var maxHeight := IfThen(get_WordWrap or _calcAsAutoHeight, 9999, Self.Height - Padding.Top - Padding.Bottom);

  // italic and Trailing horz align does not work together because of the extra space italic text needs.. This is not calculated correctly..
  var needsItalicCorrection := (_settings.HorzAlign = TTextAlign.Trailing) and (TFontStyle.fsItalic in _settings.Font.Style);
//  Assert(not needsItalicCorrection);

  _layout.BeginUpdate;
  try
    _layout.Text := GetText;
    if needsItalicCorrection then
      _layout.Text := _layout.Text + #$202F + #8288; // #8288 is a not visible, non-width character. This triggers the ' ' to be taken into account
    _layout.LayoutCanvas.Font.Size := _settings.Font.Size;
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

  {$IFDEF SKIA}
  // bad code, but neccesssary.. SKIA does not calculate italic fonts right..
  if GlobalUseSkia and (TFontStyle.fsItalic in _layout.Font.Style) then
    _textBounds := RectF(_textBounds.Left, _textBounds.Top, _textBounds.Right + 3, _textBounds.Bottom);
  {$ENDIF}
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

procedure TFastText.SetVisible(const Value: Boolean);
begin
  if Value <> GetVisible then
    inherited;
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

function TFastText.get_CalcAsAutoHeight: Boolean;
begin
  Result := _calcAsAutoHeight;
end;

procedure TFastText.set_CalcAsAutoHeight(const Value: Boolean);
begin
  if _calcAsAutoHeight <> Value then
  begin
    _calcAsAutoHeight := Value;
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

procedure TFastText.set_MaxWidth(const Value: Integer);
begin
  if _maxWidth <> Value then
  begin
    _maxWidth := Value;
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
  ControlLoadedCalculate;
  Result := _textBounds.Height;
end;

function TFastText.TextHeightWithPadding: Single;
begin
  Result := TextHeight + Self.Padding.Top + Self.Padding.Bottom + _internalBottomPadding;
end;

function TFastText.TextStored: Boolean;
begin
  Result := False;
end;

function TFastText.TextWidth: Single;
begin
  ControlLoadedCalculate;
  Result := _textBounds.Width;
end;

function TFastText.TextWidthWithPadding: Single;
begin
  Result := TextWidth + Padding.Left + Padding.Right + _internalLeftPadding + _internalRightPadding;
end;

{ TFastCheckBox }
constructor TFastCheckBox.Create(AOwner: TComponent);
begin
  inherited;

  HitTest := True;
  CanFocus := True;

  _checkPosition := TCheckPosition.Left;
  _checkState := TCheckState.Unchecked;
  _checkSize := 12;
  _checkTextMargin := 6;
  _checkAnimationDurationMs := 140;
  _checkAnimationFromState := TCheckState.Unchecked;
  _checkAnimationToState := TCheckState.Unchecked;
  _checkAnimationProgress := 1;
  _internalLeftPadding := _checkSize + {2 *} _checkTextMargin;
  _internalRightPadding := 0;

  Self.set_VertTextAlign(TTextAlign.Center);
  Self.set_HorzTextAlign(TTextAlign.Leading);

  CanFocus := True;
  HitTest := True;
  EnableExecuteAction := True;

  _editControl := TCheckBoxControlImpl.Create(Self);
end;

procedure TFastCheckbox.EnsureCheckAnimationTimer;
begin
  if _checkAnimationTimer = nil then
  begin
    _checkAnimationTimer := TTimer.Create(Self);
    _checkAnimationTimer.Enabled := False;
    _checkAnimationTimer.Interval := 15;
    {$IFNDEF WEBASSEMBLY}
    _checkAnimationTimer.OnTimer := CheckAnimationTimer;
    {$ELSE}
    _checkAnimationTimer.OnTimer := @CheckAnimationTimer;
    {$ENDIF}
  end;
end;

procedure TFastCheckbox.StopCheckAnimation;
begin
  if _checkAnimationTimer <> nil then
    _checkAnimationTimer.Enabled := False;
end;

function TFastCheckbox.GetCheckAnimationT: Single;
begin
  if _checkAnimationDurationMs <= 0 then
    Exit(1);

  Result := EnsureRange((TThread.GetTickCount64 - _checkAnimationStartedAt) / _checkAnimationDurationMs, 0, 1);
end;

procedure TFastCheckbox.SetCheckAnimationProgress(const Progress: Single);
begin
  var nextProgress := EnsureRange(Progress, 0, 1);

  if SameValue(_checkAnimationProgress, nextProgress, 0.001) then
    Exit;

  _checkAnimationProgress := nextProgress;
  RepaintNeeded;
end;

function TFastCheckbox.GetStateVisualProgress(const State: TCheckState): Single;
begin
  if _checkAnimationFromState = _checkAnimationToState then
    Exit(IfThen(State = _checkAnimationToState, 1, 0));

  if State = _checkAnimationFromState then
    Exit(1 - _checkAnimationProgress);

  if State = _checkAnimationToState then
    Exit(_checkAnimationProgress);

  Result := 0;
end;

procedure TFastCheckbox.ConfigureCheckAnimation(const FromState: TCheckState; const Immediate: Boolean = False);
begin
  _checkAnimationFromState := FromState;
  _checkAnimationToState := _checkState;

  if Immediate then
  begin
    StopCheckAnimation;
    _checkAnimationFromState := _checkState;
    _checkAnimationToState := _checkState;
    SetCheckAnimationProgress(1);
    Exit;
  end;

  if _checkAnimationFromState = _checkAnimationToState then
  begin
    SetCheckAnimationProgress(1);
    Exit;
  end;

  EnsureCheckAnimationTimer;
  _checkAnimationStartedAt := TThread.GetTickCount64;
  SetCheckAnimationProgress(0);
  _checkAnimationTimer.Enabled := True;
  RepaintNeeded;
end;

procedure TFastCheckbox.CheckAnimationTimer(Sender: TObject);
begin
  var t := GetCheckAnimationT;
  var easedT := 1 - Power(1 - t, 3);

  SetCheckAnimationProgress(easedT);

  if t >= 1 then
  begin
    _checkAnimationFromState := _checkAnimationToState;
    StopCheckAnimation;
  end;
end;

function TFastCheckbox.InterpolatePoint(const FromPoint, ToPoint: TPointF; const Progress: Single): TPointF;
begin
  Result := PointF(
    FromPoint.X + ((ToPoint.X - FromPoint.X) * Progress),
    FromPoint.Y + ((ToPoint.Y - FromPoint.Y) * Progress));
end;

function TFastCheckbox.InterpolateRect(const FromRect, ToRect: TRectF; const Progress: Single): TRectF;
begin
  Result := RectF(
    FromRect.Left + ((ToRect.Left - FromRect.Left) * Progress),
    FromRect.Top + ((ToRect.Top - FromRect.Top) * Progress),
    FromRect.Right + ((ToRect.Right - FromRect.Right) * Progress),
    FromRect.Bottom + ((ToRect.Bottom - FromRect.Bottom) * Progress));
end;

procedure TFastCheckBox.UpdateState(CheckCount, TotalCount: Integer);
begin
  if CheckCount = TotalCount then
    set_CheckState(TCheckState.Checked)
  else if CheckCount = 0 then
    set_CheckState(TCheckState.Unchecked)
  else
    set_CheckState(TCheckState.Grayed);
end;

function TFastCheckBox.get_EditControl: IDCEditControl;
begin
  Result := _editControl;
end;

procedure TFastCheckBox.Calculate;
begin
  if ShouldRecalculate then
  begin
    _internalLeftPadding := IfThen(_checkPosition = TCheckPosition.Left, _checkSize + {2 *} _checkTextMargin, 0);
    _internalRightPadding := IfThen(_checkPosition = TCheckPosition.Right, _checkSize + {2 *} _checkTextMargin, 0);
  end;

  inherited;
end;

procedure TFastCheckBox.DoMouseLeave;
begin
  inherited;
  _stateChangedThisHover := False;
end;

procedure TFastCheckBox.DoPaint;
begin
  var storedOpacity := GetAbsoluteOpacity;
  if Enabled and _hover and not _stateChangedThisHover then
    FAbsoluteOpacity := storedOpacity * 0.7;

  inherited;

  FAbsoluteOpacity := storedOpacity;

  var availableHeight := Self.Height - Padding.Top - Padding.Bottom;
  var checkSize := CMath.Min(availableHeight, _checkSize);
  if checkSize <= 0 then
    Exit;

  var startYPos := Padding.Top + (availableHeight - checkSize) / 2;
  var startXPos := IfThen(_checkPosition = TCheckPosition.Left, Padding.Left {+ _checkTextMargin}, Width - Padding.Right {- _checkTextMargin} - checkSize);
  var rect := RectF(startXPos, startYPos, startXPos + checkSize, startYPos + checkSize);
  var innerRect := RectF(startXPos + 2, startYPos + 2, startXPos + checkSize - 2, startYPos + checkSize - 2);
  var radius := IfThen(IsRadioButton, checkSize / 2, 1);

  var accentColor := GetCheckColor;
  var uncheckedProgress := GetStateVisualProgress(TCheckState.Unchecked);
  var checkedProgress := GetStateVisualProgress(TCheckState.Checked);
  var grayedProgress := GetStateVisualProgress(TCheckState.Grayed);
  var highlightProgress := IfThen((_hover and not _stateChangedThisHover) or IsFocused, 1, 0);

  var checkMarkColor := IfThen(
    (TAlphaColorRec(accentColor).R * 0.299) +
    (TAlphaColorRec(accentColor).G * 0.587) +
    (TAlphaColorRec(accentColor).B * 0.114) > 160,
    TAlphaColors.Black,
    TAlphaColors.White);

  var drawOpacity := AbsoluteOpacity * IfThen(Enabled, 1, 0.45);

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1 + (0.5 * CMath.Max(CMath.Max(checkedProgress, grayedProgress), highlightProgress));

  PaintUncheckedVisual(rect, radius, drawOpacity, uncheckedProgress, highlightProgress, accentColor);
  PaintCheckedVisual(rect, innerRect, radius, drawOpacity, checkedProgress, accentColor, checkMarkColor);
  PaintGrayedVisual(rect, innerRect, radius, drawOpacity, grayedProgress, accentColor);

  Canvas.Stroke.Color := accentColor;
  if IsRadioButton then
    Canvas.DrawEllipse(rect, drawOpacity) else
    Canvas.DrawRect(rect, radius, radius, AllCorners, drawOpacity);
end;

procedure TFastCheckbox.PaintUncheckedVisual(const Rect: TRectF; const Radius, DrawOpacity, Progress, HighlightProgress: Single; const AccentColor: TAlphaColor);
begin
  if Progress <= 0 then
    Exit;

  Canvas.Fill.Color := AccentColor;

  var backgroundOpacity := DrawOpacity * Progress * (0.02 + (0.08 * HighlightProgress));
  if backgroundOpacity <= 0 then
    Exit;

  if IsRadioButton then
    Canvas.FillEllipse(Rect, backgroundOpacity) else
    Canvas.FillRect(Rect, Radius, Radius, AllCorners, backgroundOpacity);
end;

procedure TFastCheckbox.PaintCheckedVisual(const Rect, InnerRect: TRectF; const Radius, DrawOpacity, Progress: Single; const AccentColor, CheckMarkColor: TAlphaColor);
begin
  if Progress <= 0 then
    Exit;

  Canvas.Fill.Color := AccentColor;

  if IsRadioButton then
  begin
    var inset := (InnerRect.Width * 0.35) * (1 - Progress);
    var animatedInnerRect := RectF(InnerRect.Left + inset, InnerRect.Top + inset, InnerRect.Right - inset, InnerRect.Bottom - inset);
    Canvas.FillEllipse(animatedInnerRect, DrawOpacity * Progress);
    Exit;
  end;

  var fillInset := (Rect.Width * 0.22) * (1 - Progress);
  var startRect := RectF(Rect.Left + fillInset, Rect.Top + fillInset, Rect.Right - fillInset, Rect.Bottom - fillInset);
  var animatedRect := InterpolateRect(startRect, Rect, Progress);

  Canvas.FillRect(animatedRect, Radius, Radius, AllCorners, DrawOpacity * Progress);
  DrawAnimatedCheckMark(animatedRect, DrawOpacity, Progress, CheckMarkColor);
end;

procedure TFastCheckbox.PaintGrayedVisual(const Rect, InnerRect: TRectF; const Radius, DrawOpacity, Progress: Single; const AccentColor: TAlphaColor);
begin
  if Progress <= 0 then
    Exit;

  Canvas.Fill.Color := AccentColor;

  if IsRadioButton then
  begin
    var inset := (InnerRect.Width * 0.35) * (1 - Progress);
    var animatedInnerRect := RectF(InnerRect.Left + inset, InnerRect.Top + inset, InnerRect.Right - inset, InnerRect.Bottom - inset);
    Canvas.FillEllipse(animatedInnerRect, DrawOpacity * 0.9 * Progress);
    Exit;
  end;

  var fillInset := (InnerRect.Width * 0.28) * (1 - Progress);
  var startRect := RectF(InnerRect.Left + fillInset, InnerRect.Top + fillInset, InnerRect.Right - fillInset, InnerRect.Bottom - fillInset);
  var animatedRect := InterpolateRect(startRect, InnerRect, Progress);

  Canvas.FillRect(animatedRect, Radius, Radius, AllCorners, DrawOpacity * 0.9 * Progress);
end;

procedure TFastCheckbox.DrawAnimatedCheckMark(const Rect: TRectF; const DrawOpacity, Progress: Single; const Color: TAlphaColor);
begin
  if Progress <= 0 then
    Exit;

  Canvas.Stroke.Color := Color;
  Canvas.Stroke.Thickness := CMath.Max(1.5, Rect.Width / 6);

  var p1 := PointF(Rect.Left + Rect.Width / 5, Rect.Top + Rect.Height / 2);
  var p2 := PointF(Rect.Left + Rect.Width * 2 / 5, Rect.Top + Rect.Height * 7 / 10);
  var p3 := PointF(Rect.Left + Rect.Width * 4 / 5, Rect.Top + Rect.Height / 4);
  var markOpacity := DrawOpacity * EnsureRange(0.35 + (0.65 * Progress), 0, 1);

  if Progress < 0.5 then
  begin
    Canvas.DrawLine(p1, InterpolatePoint(p1, p2, Progress / 0.5), markOpacity);
    Exit;
  end;

  Canvas.DrawLine(p1, p2, markOpacity);
  Canvas.DrawLine(p2, InterpolatePoint(p2, p3, (Progress - 0.5) / 0.5), markOpacity);
end;

function TFastCheckbox.GetIsChecked: Boolean;
begin
  Result := _checkState = TCheckState.Checked;
end;

function TFastCheckbox.IsRadioButton: Boolean;
begin
  Result := False;
end;

function TFastCheckbox.GetCheckColor: TAlphaColor;
begin
  Result := TAlphaColors.Grey;
end;

function TFastCheckbox.get_CheckState: TCheckState;
begin
  Result := _checkState;
end;

procedure TFastCheckBox.set_CheckPosition(const Value: TCheckPosition);
begin
  if _checkPosition <> Value then
  begin
    _checkPosition := Value;
    case _checkPosition of
      TCheckPosition.Left: set_HorzTextAlign(TTextAlign.Leading);
      TCheckPosition.Right: set_HorzTextAlign(TTextAlign.Trailing);
    end;

    RecalcNeeded;
  end;
end;

procedure TFastCheckBox.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;

  if Enabled and (KeyChar = ' ') then
  begin
    ToggleCheckState;
    Click;
    KeyChar := #0;
  end;
end;

procedure TFastCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Enabled and _mouseIsDown then
  begin
    ToggleCheckState;
    _stateChangedThisHover := True;
  end;

  inherited;
end;

procedure TFastCheckbox.SetIsChecked(const Value: Boolean);
begin
  if Value then
    set_CheckState(TCheckState.Checked) else
    set_CheckState(TCheckState.Unchecked);
end;

procedure TFastCheckbox.set_CheckState(const Value: TCheckState);
begin
  SetCheckStateCore(Value);
end;

procedure TFastCheckbox.SetCheckStateCore(const Value: TCheckState; const TriggerEvents: Boolean);
begin
  if _checkState <> Value then
  begin
    var previousState := _checkState;
    _checkState := Value;
    ConfigureCheckAnimation(previousState, Self.IsUpdating or not Visible or (csLoading in ComponentState));

    if TriggerEvents and Assigned(_onCheckChange) and not Self.IsUpdating then
      _onCheckChange(Self);

    if TriggerEvents and Assigned(_onChange) and not Self.IsUpdating then
      _onChange(Self);

    RepaintNeeded;
  end;
end;

procedure TFastCheckbox.ToggleCheckState;
begin
  if _checkState <> TCheckState.Checked then
    Self.CheckState := TCheckState.Checked else
    Self.CheckState := TCheckState.Unchecked;
end;

function TFastCheckbox.IsCheckedStored: Boolean;
begin
  Result := False;
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
  if IsUpdating or not IsBoundProperty(AProperty) then Exit;

  _value := Value;
  if Value <> nil then
    _Control.Text := CStringToString(Value.ToString) else
    _Control.Text := '';
end;

procedure TFastTextControlBinding.UpdateControlEditability(IsEditable: Boolean);
begin
  // textControls can't be edited, therefor always should be true so that they can be copied!!
  _control.Enabled := True;
end;

{ TFastTextControlSmartLinkBinding }

procedure TFastTextControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if not IsBoundProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;


{ TFastTextControlBinding }

function TFastCheckboxControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := nil;
  {$ELSE}
  Result := (_Control as IIsChecked).IsChecked;
  {$ENDIF}
end;

procedure TFastCheckboxControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or not IsBoundProperty(AProperty) then Exit;

  _value := Value;
  if Value <> nil then
    (_Control as IIsChecked).IsChecked := Value.AsType<Boolean> else
    (_Control as IIsChecked).IsChecked := False;
end;

procedure TFastCheckboxControlBinding.UpdateControlEditability(IsEditable: Boolean);
begin
  _control.Enabled := IsEditable;
end;

{ TFastTextControlSmartLinkBinding }

procedure TFastCheckboxControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if not IsBoundProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TFastControl }
constructor TFastControl.Create(AOwner: TComponent);
begin
  inherited;
  _recalcNeeded := True;
  _isAlive := TInterfacedObject.Create;
end;

destructor TFastControl.Destroy;
begin
  _isAlive := nil;
  inherited;
end;

procedure TFastControl.Loaded;
begin
  _controlIsLoaded := True;
  inherited;
end;

procedure TFastControl.RepaintNeeded;
begin
  if not FInPaintTo and not _waitingForRepaint then
  begin
    _waitingForRepaint := True;
    Repaint;
  end;
end;

procedure TFastControl.ForceRealign(OnlyWhenRealignNeeded: Boolean = False);
begin
  if not OnlyWhenRealignNeeded then
    RequestRealign;

  ControlLoadedCalculate;
end;

procedure TFastControl.RecalcOpacity;
begin
  inherited;
  Repaint;
end;

procedure TFastControl.RequestRealign;
begin
  RecalcNeeded;
end;

procedure TFastControl.Painting;
begin
  _waitingForRepaint := False;
  ControlLoadedCalculate;

  inherited;
end;

procedure TFastControl.PrepareForPaint;
begin
  Calculate;
  inherited;
end;

procedure TFastControl.PaddingChanged;
begin
  inherited;
  RecalcNeeded;
end;

procedure TFastControl.Calculate;
begin
  _recalcNeeded := False;
end;

function TFastControl.ShouldRecalculate: Boolean;
begin
  Result := _recalcNeeded and _controlIsLoaded and (_recalcIndex = 0)
    { and not IsUpdating}; // check kanbanboard if it should be on, for textwidth calcs are done in applystylelookup
end;

procedure TFastControl.ControlLoadedCalculate;
begin
  // for runtime controls, the method "Loaded" is not called!
  // sometimes we want to force calculate..
  _controlIsLoaded := True;
  Calculate;
end;

procedure TFastControl.RecalcNeeded;
begin
  _recalcNeeded := True;
  CalculateSafeAutoSize;
  RepaintNeeded;
end;

function TFastControl.DoAutoSize: Boolean;
begin
  Result := _autoWidth;
end;

procedure TFastControl.CalculateSafeAutoSize;
begin
  if not ShouldRecalculate or not DoAutoSize then
    Exit;

  _autoSizeNeeded := True;
  TThread.ForceQueue(nil, procedure
  begin
    if not _autoSizeNeeded then
      Exit;

    if (Scene <> nil) and DoAutoSize then
    begin
      Calculate;
      ApplyAutoSize;
      RepaintNeeded;

      _autoSizeNeeded := False;
    end;
  end);
end;

procedure TFastControl.DoResized;
begin
  inherited;

  if not IsUpdating then
    RecalcNeeded;
end;

procedure TFastControl.EndUpdate;
begin
  inherited;
  CalculateSafeAutoSize;
end;

initialization
  TPropertyBinding.RegisterClassBinding(TFastText,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TFastTextControlSmartLinkBinding.Create(TFastText(Control)) end);

  TPropertyBinding.RegisterClassBinding(TFastCheckbox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TFastCheckboxControlSmartLinkBinding.Create(TFastCheckbox(Control)) end);


end.


