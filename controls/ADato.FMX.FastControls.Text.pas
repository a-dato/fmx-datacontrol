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
  FMX.Menus,
  FMX.Types,
  FMX.Layouts,
  FMX.TextLayout,
  FMX.Text,
  System.Types,
  System.ImageList,
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
  Wasm.FMX.Text,
  Wasm.System.Types,
  Wasm.System.ImageList,
  {$ENDIF}
  System_,
  ADato.ObjectModel.Binders,
  FMX.ScrollControl.ControlClasses.Intf;

type
  TAutoSize = (None, AutoWidth, AutoHeight);
  TAutoSizes = set of TAutoSize;

  TFastControl = class(TLayout)
  protected
    _controlIsLoaded: Boolean;
    _isAlive: IInterface;

    _waitingForRepaint: Boolean;
    _recalcNeeded: Boolean;
    _autoSize: TAutoSize;
    _autoSizeNeeded: Boolean;
    _forbiddenAutoSizeOptions: TAutoSizes;
    _internalUpdateCount: Integer;

    _recalcIndex: Integer;

    procedure Loaded; override;
    procedure RepaintNeeded;
    procedure RecalcNeeded; virtual;

    function  ShouldRecalculate: Boolean;
    procedure ControlLoadedCalculate;
    procedure DirectControlLoadedCalculate;
    procedure InternalCalculate;
    procedure Calculate; virtual;

    procedure ImmidiateAutoSize; virtual;
    procedure CalculateSafeAutoSize;
    function  DoAutoSize: Boolean; //virtual;
    procedure ApplyAutoSize; virtual;
    procedure set_AutoSize(const Value: TAutoSize); virtual;

    procedure DoResized; override;
    procedure PaddingChanged; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure EndUpdate; override;
    procedure PrepareForPaint; override;
    procedure Painting; override;
    procedure RecalcOpacity; override;

    procedure ForceRealign(OnlyWhenRealignNeeded: Boolean = False);
    procedure RequestRealign;

    property AutoSize: TAutoSize read _autoSize write set_AutoSize default None;
  end;

  TDateTimeEditOnKeyDownOverride = class(TDateEdit)
  protected
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  end;

  TCheckPosition = (Left, Right);

  TFastText = class(TFastControl, IDCControl, ITextControl, ICaption, ITextSettings, ITextActions)
  protected
    _dcControl: IDCControl;
    function get_DCControl: IDCControl;

  public
    property DCControl: IDCControl read get_DCControl implements IDCControl;

  private
    // ITextActions
    procedure DeleteSelection;
    procedure CopyToClipboard; // only for this one!
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure SelectWord;
    procedure ResetSelection;
    procedure GoToTextEnd;
    procedure GoToTextBegin;
    procedure Replace(const AStartPos: Integer; const ALength: Integer; const AStr: String);

  protected
    _text: String;
    _layout: TTextLayout;
    _settings: TTextSettings;
    _calcAsAutoHeight: Boolean;
    _underlineOnHover: Boolean;

    _textBounds: TRectF;
    _onChange: TNotifyEvent;
    _maxWidth: Integer;
    _imagesLink: TImageLink;
    _imageName: String;
    _imageIndex: Integer;
    _imageSizeInt: Single;
    _imageBounds: TRectF;

    {$IFNDEF WEBASSEMBLY}
    _copyPopupMenu: TPopupMenu;
    {$ENDIF}

    _mouseIsDown: Boolean;
    _hover: Boolean;
    _showTag: Boolean;
    _tagColor: TAlphaColor;
    _tagOpacity: Single;

    // for checkbox ctrl
    _internalLeftPadding: Single;
    _internalRightPadding: Single;
    _internalBottomPadding: Single;

    // TInverseLabel
    _ignoreDefaultPaint: Boolean;

    {$IFNDEF WEBASSEMBLY}
    procedure CopyMenuItemClick(Sender: TObject);
    procedure CreateCopyPopupMenu;
    {$ENDIF}

    // ICaption
    function  GetText: String;
    procedure SetText(const Value: String); virtual;
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

    procedure set_AutoSize(const Value: TAutoSize); override;
    function  get_MaxWidth: Integer;
    procedure set_MaxWidth(const Value: Integer);
    function  get_Images: TCustomImageList;
    procedure set_Images(const Value: TCustomImageList);
    function  get_ImageName: String;
    procedure set_ImageName(const Value: String);
    function  get_ImageSizeInt: Single;
    procedure set_ImageSizeInt(const Value: Single);
    function  get_CalcAsAutoHeight: Boolean;
    procedure set_CalcAsAutoHeight(const Value: Boolean);
    function  get_Trimming: TTextTrimming;
    function  get_WordWrap: Boolean;
    procedure set_ShowTag(const Value: Boolean);

  protected
    procedure DoPaint; override;
    function  GetDefaultSize: TSizeF; override;

    procedure Calculate; override;
    function  EnsureLayoutForCanvas(const ACanvas: TCanvas): Boolean;
    procedure InvalidateBoundsChange(const OldBounds, NewBounds: TRectF);
    procedure ApplyAutoSize; override;

    function  CalculateTextXPos: Single;
    function  CalculateTextYPos: Single;
    function  CalculateTagVerticalMargin: Single;
    function  HasImage: Boolean;
    function  ImageContentWidth: Single;
    function  ImageTextMargin: Single;
    procedure CalculateImageBounds;
    function  GetBitmap(const Images: TCustomImageList; const BitmapSize: TSize; const BitmapIndex: Integer): TBitmap; virtual;
    procedure PaintBitmap;

    procedure SetLeftRightPadding; virtual;

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

    property Images: TCustomImageList read get_Images write set_Images;
    property ImageName: String read get_ImageName write set_ImageName;
    property ImageSizeInt: Single read get_ImageSizeInt write set_ImageSizeInt;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings;

  published
    property Text: String read GetText write SetText;
    property WordWrap: Boolean read get_WordWrap write set_WordWrap default False;
    property Trimming: TTextTrimming read get_Trimming write set_Trimming default TTextTrimming.None;
    property Style: TFontStyles read get_Style write set_Style default [];
    property VertTextAlign: TTextAlign read get_VertTextAlign write set_VertTextAlign default TTextAlign.Leading;
    property HorzTextAlign: TTextAlign read get_HorzTextAlign write set_HorzTextAlign default TTextAlign.Leading;

    property MaxWidth: Integer read get_MaxWidth write set_MaxWidth default 0;
    property CalcAsAutoHeight: Boolean read get_calcAsAutoHeight write set_CalcAsAutoHeight default True;
    property UnderlineOnHover: Boolean read _underlineOnHover write _underlineOnHover default False;
    property ShowTag: Boolean read _showTag write set_ShowTag default False;

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

    function  get_EditControl: IDCEditControl;
    function  get_CheckState: TCheckState;
    procedure set_CheckPosition(const Value: TCheckPosition);

    function  IsCheckedStored: Boolean;
    procedure SetLeftRightPadding; override;

  protected
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

  TFastCheckboxControlBinding = class(TControlBinding<TFastText>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    procedure UpdateControlEditability(IsEditable: Boolean); override;
  end;

const
  TAG_VERT_MARGIN = 3.0;
  TAG_HORZ_MARGIN = 6.0;
  IMAGE_TEXT_MARGIN = 10.0;

var
  {$IFDEF MSWINDOWS}
  APPLICATION_FONT_FAMILY: String = 'Segoe UI Variable';
  {$ELSEIF Defined(MACOS)}
  APPLICATION_FONT_FAMILY: String = '.AppleSystemUIFont';
  {$ELSEIF Defined(IOS)}
  APPLICATION_FONT_FAMILY: String = '.SF UI Text';
  {$ELSEIF Defined(ANDROID)}
  APPLICATION_FONT_FAMILY: String = 'sans-serif';
  {$ELSE}
  APPLICATION_FONT_FAMILY: String = 'Segoe UI';
  {$ENDIF}

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Math,
  System.Math.Vectors,
  FMX.Platform
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Math,
  Wasm.FMX.Platform
  {$ENDIF}
  , ADato.ObjectModel.intf
  , FMX.ScrollControl.ControlClasses
  {$IFDEF SKIA}
  , FMX.Skia
  {$ENDIF}
  , ADato.TraceEvents.intf;

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

function TFastText.EnsureLayoutForCanvas(const ACanvas: TCanvas): Boolean;
begin
  // fast path: layout already bound to this exact canvas
  if (_layout <> nil) and (_layout.LayoutCanvas = ACanvas) then
    Exit(False);

  var layoutClass := TTextLayoutManager.DefaultTextLayout;
  if ACanvas <> nil then
    layoutClass := TTextLayoutManager.TextLayoutByCanvas(ACanvas.ClassType);

  // recreate only when the canvas type requires a different layout class (e.g. PDF printing)
  Result := (_layout = nil) or (_layout.ClassType <> layoutClass);
  if Result then
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

  // TFastControl forbids AutoHeight by default (for layouts/buttons).
  // Labels need AutoHeight so WordWrap can grow the control height.
  _forbiddenAutoSizeOptions := [];

  _dcControl := TDCControlImpl.Create(Self);

  _settings := TTextSettings.Create(Self);
  _settings.VertAlign := TTextAlign.Leading;
  _settings.HorzAlign := TTextAlign.Leading;

  _imagesLink := TImageLink.Create;
  _imageIndex := -1;
  _imageSizeInt := 16;

  _calcAsAutoHeight := True;

  _showTag := False;
  _tagColor := TAlphaColors.Grey;
  _tagOpacity := 0.15;
end;

function TFastText.get_DCControl: IDCControl;
begin
  Result := _dcControl;
end;

destructor TFastText.Destroy;
begin
  {$IFNDEF WEBASSEMBLY}
  PopupMenu := nil;
  FreeAndNil(_copyPopupMenu);
  {$ENDIF}

  FreeAndNil(_layout);
  FreeAndNil(_settings);
  FreeAndNil(_imagesLink);

  inherited;
end;

{$IFNDEF WEBASSEMBLY}
procedure TFastText.CopyMenuItemClick(Sender: TObject);
begin
  CopyToClipboard;
end;

procedure TFastText.CreateCopyPopupMenu;
begin
  if _copyPopupMenu <> nil then
    Exit;

  _copyPopupMenu := TPopupMenu.Create(Self);
  _copyPopupMenu.Stored := False;

  var copyItem := TMenuItem.Create(_copyPopupMenu);
  copyItem.Text := 'Copy';
  copyItem.OnClick := CopyMenuItemClick;
  _copyPopupMenu.AddObject(copyItem);

  PopupMenu := _copyPopupMenu;
end;
{$ENDIF}

function TFastText.CalculateTextXPos: Single;
begin
//  Result := Padding.Left + _internalLeftPadding;
  case get_HorzTextAlign of
    TTextAlign.Center: Result := ((Self.Width - (_textBounds.Width + ImageContentWidth)) / 2) + ImageContentWidth;
    TTextAlign.Leading: Result := Padding.Left + _internalLeftPadding + IfThen(_showTag, TAG_HORZ_MARGIN, 0) + ImageContentWidth;
    TTextAlign.Trailing: Result := Self.Width - _textBounds.Width - Padding.Right - _internalRightPadding - IfThen(_showTag, TAG_HORZ_MARGIN, 0);
  end;
end;

function TFastText.CalculateTextYPos: Single;
begin
  var totHeight := CMath.Max(_textBounds.Height, IfThen(HasImage, _imageSizeInt, 0));
  var tagVerticalMargin := CalculateTagVerticalMargin;
  var contentY: Single;
//  Result := Padding.Top;
  case get_VertTextAlign of
    TTextAlign.Center: contentY := (Self.Height - totHeight - _internalBottomPadding) / 2;
    TTextAlign.Leading: contentY := Padding.Top + tagVerticalMargin;
    TTextAlign.Trailing: contentY := Self.Height - totHeight - Padding.Bottom - _internalBottomPadding - tagVerticalMargin;
  end;

  Result := contentY + CMath.Max(0, (totHeight - _textBounds.Height) / 2);
end;

procedure TFastText.CalculateImageBounds;
begin
  if not HasImage then
  begin
    _imageBounds := TRectF.Empty;
    Exit;
  end;

  var imageLeft := CalculateTextXPos - _imageSizeInt - ImageTextMargin;
  var tagVerticalMargin := CalculateTagVerticalMargin;

  var contentY: Single;
  case get_VertTextAlign of
    TTextAlign.Center: contentY := Padding.Top + (Self.Height - 2*CalculateTagVerticalMargin - Padding.Top - Padding.Bottom - _imageSizeInt - _internalBottomPadding) / 2;
    TTextAlign.Leading: contentY := Padding.Top + tagVerticalMargin;
    TTextAlign.Trailing: contentY := Self.Height - _imageSizeInt - Padding.Bottom - _internalBottomPadding - tagVerticalMargin;
  end;

  _imageBounds := RectF(imageLeft, contentY, imageLeft + _imageSizeInt, contentY + _imageSizeInt);
end;

function TFastText.CalculateTagVerticalMargin: Single;
begin
  if not _showTag then
    Exit(0);

  if _calcAsAutoHeight then
    Exit(TAG_VERT_MARGIN);

  var contentHeight := CMath.Max(_textBounds.Height, IfThen(HasImage, _imageSizeInt, 0));
  var availableTagHeight := Self.Height - contentHeight - Padding.Top - Padding.Bottom - _internalBottomPadding;
  Result := CMath.Max(0, CMath.Min(TAG_VERT_MARGIN, availableTagHeight / 2));
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
    // Printing uses a different canvas (SKIA). Layout must match that canvas type.
    // Only when the layout got recreated the Calculate is needed.
    if EnsureLayoutForCanvas(Canvas) then
      Calculate;

    _layout.Opacity := AbsoluteOpacity;
    _layout.TopLeft := PointF(CalculateTextXPos, CalculateTextYPos);
    CalculateImageBounds;

    var maxW := CMath.Min(_textBounds.Width + Padding.Left + Padding.Right, Self.Width - _layout.TopLeft.X);
    var maxH := CMath.Min(_textBounds.Height + Self.Padding.Top + Self.Padding.Bottom, Self.Height - _layout.TopLeft.Y);

    _layout.MaxSize := PointF(maxW, maxH);

    // first show tag..
    if _showTag then
    begin
      var tagVerticalMargin := CalculateTagVerticalMargin;
      var contentLeft := _layout.TopLeft.X;
      var contentRight := _layout.TopLeft.X + _layout.MaxSize.X;
      if HasImage then
      begin
        contentLeft := _imageBounds.Left;
        contentRight := CMath.Max(contentRight, _imageBounds.Right);
      end;

      var contentTop := _layout.TopLeft.Y;
      var contentBottom := _layout.TopLeft.Y + _textBounds.Height;
      if HasImage then
      begin
        contentTop := CMath.Min(contentTop, _imageBounds.Top);
        contentBottom := CMath.Max(contentBottom, _imageBounds.Bottom);
      end;

      var p1 := PointF(contentLeft - TAG_HORZ_MARGIN, contentTop - tagVerticalMargin);
      var p2 := PointF(contentRight + TAG_HORZ_MARGIN, contentBottom + tagVerticalMargin);

      var rad := CMath.Min(10, (p2.Y - p1.Y) / 2);
      var rect := TRectF.Create(p1.X, p1.Y, p2.X, p2.Y);
      Canvas.Fill.Color := _tagColor;
      Canvas.FillRect(rect, rad*0.75, rad*1.2, AllCorners, AbsoluteOpacity * _tagOpacity, TCornerType.Round);
    end;

//    {$IFDEF DEBUG}
//    Self.Canvas.Fill.Color := TAlphaColors.Mediumpurple;
//    Self.Canvas.FillRect(RectF(0, 0, Self.Width, Self.Height), 0.2);
//
//    Self.Canvas.Fill.Color := TAlphaColors.Darkred;
//    Self.Canvas.FillRect(RectF(_layout.TopLeft.X, _layout.TopLeft.Y, _layout.TopLeft.X + _layout.MaxSize.X, _layout.TopLeft.Y + _layout.MaxSize.Y), 0.05);
//    {$ENDIF}

    if HasImage then
      PaintBitmap;

    _layout.RenderLayout(Canvas);
  end;

  if _hover and _underlineOnHover then
  begin
    var textBottom := CMath.Min(_layout.TopLeft.Y + _layout.MaxSize.Y, Self.Height);
    var atextWidth := CMath.Min(_textBounds.Width, Self.Width - _layout.TopLeft.X);

    Canvas.Stroke.Color := _layout.Color;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.DrawLine(PointF(_layout.TopLeft.X, textBottom), PointF(_layout.TopLeft.X + atextWidth, textBottom), AbsoluteOpacity * IfThen(_mouseIsDown, 0.3, 1));
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

function TFastText.GetBitmap(const Images: TCustomImageList; const BitmapSize: TSize; const BitmapIndex: Integer): TBitmap;
begin
  Result := Images.Bitmap(BitmapSize, BitmapIndex);
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

function TFastText.get_ImageName: String;
begin
  Result := _imageName;
end;

function TFastText.get_ImageSizeInt: Single;
begin
  Result := _imageSizeInt;
end;

function TFastText.get_Images: TCustomImageList;
begin
  Result := TCustomImageList(_imagesLink.Images);
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

function TFastText.HasImage: Boolean;
begin
  Result := (Length(_imageName) > 0) and (get_Images <> nil);
end;

function TFastText.ImageTextMargin: Single;
begin
  Result := IfThen(HasImage and HasText, IMAGE_TEXT_MARGIN, 0);
end;

function TFastText.ImageContentWidth: Single;
begin
  Result := IfThen(HasImage, _imageSizeInt + ImageTextMargin, 0);
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
  var oldBounds := BoundsRect;

  case _autoSize of
    TAutoSize.AutoWidth:
      begin
        var newWidth := TextWidthWithPadding;
        if SameValue(Self.Width, newWidth) then
          Exit;

        Self.Width := newWidth;
      end;

    TAutoSize.AutoHeight:
      begin
        var newHeight := TextHeightWithPadding;
        if SameValue(Self.Height, newHeight) then
          Exit;

        Self.Height := newHeight;
      end;
  else
    Exit;
  end;

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

  SetLeftRightPadding;

  inherited;

  var maxInternalWidth := _maxWidth - Padding.Left - Padding.Right - _internalLeftPadding - _internalRightPadding - ImageContentWidth;
  var maxWidth := IfThen(_maxWidth > 0, CMath.Max(0, maxInternalWidth), IfThen(get_WordWrap, CMath.Max(0, Self.Width - _internalLeftPadding - _internalRightPadding - ImageContentWidth), 9999));
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
  CalculateImageBounds;

  {$IFDEF SKIA}
  // bad code, but neccesssary.. SKIA does not calculate italic fonts right..
  if GlobalUseSkia and (TFontStyle.fsItalic in _layout.Font.Style) then
    _textBounds := RectF(_textBounds.Left, _textBounds.Top, _textBounds.Right + 3, _textBounds.Bottom);
  {$ENDIF}
end;

procedure TFastText.SetLeftRightPadding;
begin
  if not ShouldRecalculate then
    Exit;

  _internalLeftPadding := 0; //IfThen(_showTag, TAG_MARGIN, 0);
  _internalRightPadding := 0; //IfThen(_showTag, TAG_MARGIN, 0);
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

procedure TFastText.set_AutoSize(const Value: TAutoSize);
begin
  if Value = TAutoSize.AutoWidth then
    set_WordWrap(False);

  inherited;
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

procedure TFastText.set_ShowTag(const Value: Boolean);
begin
  if _showTag = Value then
    Exit;

  _showTag := Value;

  RecalcNeeded;
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

procedure TFastText.set_ImageName(const Value: String);
begin
  if _imageName <> Value then
  begin
    _imageName := Value;
    _imageIndex := -1;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_ImageSizeInt(const Value: Single);
begin
  if _imageSizeInt <> Value then
  begin
    _imageSizeInt := Value;
    RecalcNeeded;
  end;
end;

procedure TFastText.set_Images(const Value: TCustomImageList);
begin
  if _imagesLink.Images <> Value then
  begin
    _imagesLink.Images := Value;
    _imageIndex := -1;
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
    if _settings.WordWrap and (_autoSize = TAutoSize.AutoWidth) then
      _autoSize := TAutoSize.None;

    RecalcNeeded;
  end;
end;

function TFastText.TextHeight: Single;
begin
  ControlLoadedCalculate;
  Result := CMath.Max(_textBounds.Height, IfThen(HasImage, _imageSizeInt, 0)) + IfThen(_showTag, 2*TAG_VERT_MARGIN, 0);
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
  Result := _textBounds.Width + ImageContentWidth + IfThen(_showTag, 2*TAG_HORZ_MARGIN, 0);
end;

function TFastText.TextWidthWithPadding: Single;
begin
  Result := TextWidth + Padding.Left + Padding.Right + _internalLeftPadding + _internalRightPadding;
end;

procedure TFastText.PaintBitmap;
begin
  var screenScale: Single;
  if Scene <> nil then
    screenScale := Scene.GetSceneScale else
    screenScale := 1;

  var bitmapSize := TSize.Create(Round(_imageBounds.Width * screenScale), Round(_imageBounds.Height * screenScale));

  if (_imageIndex = -1) and (Length(_imageName) > 0) then
    _imageIndex := get_Images.Source.IndexOf(_imageName);

  if _imageIndex = -1 then
    Exit;

  var bitmap := GetBitmap(get_Images, bitmapSize, _imageIndex);
  try
    if bitmap <> nil then
    begin
      var bitmapRect := TRectF.Create(0, 0, bitmap.Width, bitmap.Height);
      Canvas.DrawBitmap(bitmap, bitmapRect, _imageBounds.Round, AbsoluteOpacity, False);
    end;
  finally
    bitmap.Free;
  end;
end;

procedure TFastText.CopyToClipboard;
var
  ClipService: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    ClipService.SetClipboard(Self.Text);
end;

procedure TFastText.DeleteSelection;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.CutToClipboard;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.PasteFromClipboard;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.SelectAll;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.SelectWord;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.ResetSelection;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.GoToTextEnd;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.GoToTextBegin;
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
end;

procedure TFastText.Replace(const AStartPos: Integer; const ALength: Integer; const AStr: string);
begin
  // nothing to do..
//  raise ENotImplemented.Create('Not implemented for this control');
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
  _checkTextMargin := 10;
  _checkAnimationDurationMs := 140;
  _checkAnimationFromState := TCheckState.Unchecked;
  _checkAnimationToState := TCheckState.Unchecked;
  _checkAnimationProgress := 1;

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

  var startYPos := Padding.Top + (availableHeight - checkSize) / 2;
  var startXPos := IfThen(_checkPosition = TCheckPosition.Left, CMath.Max(Padding.Left, Canvas.Stroke.Thickness/2), Width - CMath.Max(Padding.Right, Canvas.Stroke.Thickness/2) - checkSize);

  var rect := RectF(startXPos, startYPos, startXPos + checkSize, startYPos + checkSize);
  var innerRect := RectF(startXPos + 2, startYPos + 2, startXPos + checkSize - 2, startYPos + checkSize - 2);
  var radius := IfThen(IsRadioButton, checkSize / 2, 1);

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

procedure TFastCheckbox.SetLeftRightPadding;
begin
  if ShouldRecalculate then
  begin
    inherited;

    // 2 is for extra stroke..
    _internalLeftPadding := _internalLeftPadding + IfThen(_checkPosition = TCheckPosition.Left, _checkSize + {2 *} _checkTextMargin, 0);
    _internalRightPadding := _internalRightPadding + IfThen(_checkPosition = TCheckPosition.Right, _checkSize + {2 *} _checkTextMargin, 0);
  end;
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
  if IsUpdating then
    Exit;

  if IsBoundProperty(AProperty) then
  begin
    _value := Value;
    if Value <> nil then
      _Control.Text := CStringToString(Value.ToString) else
      _Control.Text := '';
  end else
    ExecuteFromLink(AProperty, Obj);
end;

procedure TFastTextControlBinding.UpdateControlEditability(IsEditable: Boolean);
begin
  // textControls can't be edited, therefor always should be true so that they can be copied!!
  _control.Enabled := True;
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
  if IsUpdating then
    Exit;

  if IsBoundProperty(AProperty) then
  begin
    _value := Value;
    if Value <> nil then
      (_Control as IIsChecked).IsChecked := Value.AsType<Boolean> else
      (_Control as IIsChecked).IsChecked := False;
  end else
    ExecuteFromLink(AProperty, Obj);
end;

procedure TFastCheckboxControlBinding.UpdateControlEditability(IsEditable: Boolean);
begin
  _control.Enabled := IsEditable;
end;

{ TFastControl }
constructor TFastControl.Create(AOwner: TComponent);
begin
  inherited;
  _recalcNeeded := True;
  _isAlive := TInterfacedObject.Create;
  _forbiddenAutoSizeOptions := [TAutoSize.AutoHeight];
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
  if not FInPaintTo then
    Repaint
//    and not _waitingForRepaint then
//  begin
//    _waitingForRepaint := True;
//    Repaint;
//  end;
end;

procedure TFastControl.ForceRealign(OnlyWhenRealignNeeded: Boolean = False);
begin
  if not OnlyWhenRealignNeeded then
    RequestRealign;

  inc(_internalUpdateCount);
//  BeginUpdate;
  try
    ControlLoadedCalculate;
  finally
//    EndUpdate;
    dec(_internalUpdateCount);
  end;
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
  if ShouldRecalculate and _autoSizeNeeded and DoAutoSize then
    ImmidiateAutoSize else
    InternalCalculate;

  inherited;
end;

procedure TFastControl.PaddingChanged;
begin
  inherited;
  RecalcNeeded;
end;

procedure TFastControl.InternalCalculate;

  procedure CalculateFastControlChildren(const Parent: TControl);
  begin
    for var ctrl in Parent.Controls do
      if ctrl.Visible and (ctrl.Opacity > 0) then
      begin
        CalculateFastControlChildren(ctrl);

        if ctrl is TFastControl then
          TFastControl(ctrl).InternalCalculate;
      end;
  end;

begin
  CalculateFastControlChildren(Self);
  Calculate;
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

procedure TFastControl.DirectControlLoadedCalculate;
begin
  // for runtime controls, the method "Loaded" is not called!
  // sometimes we want to force calculate..
  _controlIsLoaded := True;
  InternalCalculate;
end;

procedure TFastControl.ControlLoadedCalculate;

  procedure CalculateFastControlChildren(const Parent: TControl);
  begin
    for var ctrl in Parent.Controls do
      if ctrl.Visible and (ctrl.Opacity > 0) then
      begin
        CalculateFastControlChildren(ctrl);

        if ctrl is TFastControl then
          TFastControl(ctrl).DirectControlLoadedCalculate;
      end;
  end;

begin
  CalculateFastControlChildren(Self);
  DirectControlLoadedCalculate;
end;

procedure TFastControl.RecalcNeeded;
begin
  _recalcNeeded := True;
  CalculateSafeAutoSize;
  RepaintNeeded;
end;

function TFastControl.DoAutoSize: Boolean;
begin
  if _autoSize = TAutoSize.None then
    Exit(False);

  if _autoSize = TAutoSize.AutoWidth then
  begin
    Result := not (Self.Align in
      [
      TAlignLayout.MostTop,
      TAlignLayout.Top,
      TAlignLayout.Client,
      TAlignLayout.Bottom,
      TAlignLayout.MostBottom
      ]);
  end
  else if _autoSize = TAutoSize.AutoHeight then
  begin
    Result := not (Self.Align in
      [
      TAlignLayout.MostLeft,
      TAlignLayout.Left,
      TAlignLayout.Client,
      TAlignLayout.Right,
      TAlignLayout.MostRight
      ]);
  end;
end;

procedure TFastControl.ApplyAutoSize;
begin
end;

procedure TFastControl.set_AutoSize(const Value: TAutoSize);
begin
  var val := Value;
  if Value in _forbiddenAutoSizeOptions then
    val := TAutoSize.None;

  if _autoSize <> val then
  begin
    _autoSize := val;
    RecalcNeeded;
  end;
end;

procedure TFastControl.ImmidiateAutoSize;
begin
  if _autoSizeNeeded and (Scene <> nil) and DoAutoSize then
  begin
    _autoSizeNeeded := False;

    InternalCalculate;
    ApplyAutoSize;
    RepaintNeeded;
  end;
end;

procedure TFastControl.CalculateSafeAutoSize;

  procedure SafeForceQueue([weak] Alive: IInterface);
  begin
    TThread.ForceQueue(nil, procedure
    begin
      // PrepareForPaint normally handles the pending autosize. This queued
      // call is only a fallback for controls that do not enter that path.
      if (Alive <> nil) and _autoSizeNeeded then
        ImmidiateAutoSize;
    end);
  end;

begin
  if not ShouldRecalculate or not DoAutoSize then
    Exit;

  _autoSizeNeeded := True;
  SafeForceQueue(_isAlive);
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

  if not IsUpdating and (_internalUpdateCount = 0) and ShouldRecalculate then
  begin
    CalculateSafeAutoSize;
    RepaintNeeded;
  end;
//    RecalcNeeded;
end;

initialization
  TPropertyBinding.RegisterClassBinding(TFastText,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TFastTextControlBinding.Create(TFastText(Control)) end);

  TPropertyBinding.RegisterClassBinding(TFastCheckbox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TFastCheckboxControlBinding.Create(TFastCheckbox(Control)) end);


end.