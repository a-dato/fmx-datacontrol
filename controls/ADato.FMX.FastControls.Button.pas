unit ADato.FMX.FastControls.Button;

interface

uses
  System_,
  System.Math.Vectors,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.UITypes,

  FMX.ImgList,
  FMX.ActnList,
  FMX.Types,
  FMX.Layouts,
  FMX.TabControl,
  FMX.Graphics,
  System.ImageList;

type
  TButtonType = (None, Positive, Negative, Emphasized);
  TUnderlineType = (NoUnderline, Color1, Color2, Color3, Color4);
  TTagType = (NoBounds, RoundPost, SignPost);
  TImagePosition = (Left, Right, Top, Bottom, Center);

  TFastButtonConfig = class;

  TADatoLineF = record
    Start: TPointF;
    Stop: TPointF;
    constructor Create(const AStart, AStop: TPointF);

    function IsEmpty: Boolean;
  end;

  TADatoClickLayout = class(TLayout, ICaption)
  protected
    _polygon: TPolygon;
    _innerBounds: TRectF;
    _imageIndex: Integer;
    _reselectable: Boolean;
    _tagItem: CObject;
    _rowNumber: Integer;

    _hoverSide, _hover: Boolean;
    _tagIndex: Integer;

    _sideBounds: TRectF;
    _imageBounds: TRectF;
    _textBounds: TRectF;
    _subTextBounds: TRectF;

    // ICaption
    function  GetText: string;
    procedure SetText(const Value: string);
    function  TextStored: Boolean;

    function  get_Polygon: TPolygon;
    function  get_TagType: TTagType;
    procedure set_TagType(const Value: TTagType);
    function  get_SubText: string;
    procedure set_SubText(const Value: string);
    function  get_SwabTextSubText: Boolean;
    procedure set_SwabTextSubText(const Value: Boolean);
    function  get_ImageName: string;
    procedure set_ImageName(const Value: string);

  protected
    _isAddTag: Boolean;
    _config: TFastButtonConfig;

    function  get_Radius: Single; virtual;
    function  get_Images: TCustomImageList; virtual; abstract;

    procedure SetPadding(const Left, Top: Single);

    function  HasText: Boolean;
    function  HasSubText: Boolean;

    function  HasImage: Boolean;
    function  HasButtonEvent: Boolean; virtual;
    function  HasSideButton: Boolean; virtual;
    function  MouseIsDown: Boolean; virtual; abstract;

    function  CreateConfig: TFastButtonConfig; virtual;

    procedure Calculate; virtual;

    procedure DoPaint; override;

    function  CheckHoveredChanged(const ParentPoint: TPointF): Boolean; virtual;
    function  GetPaintOpacity: Single;

    function  GetBitmap(const Images: TCustomImageList; const BitmapSize: TSize; const BitmapIndex: Integer): TBitmap; virtual;

    property Polygon: TPolygon read get_Polygon;
    property InnerBounds: TRectF read _innerBounds;
    property RowNumber: Integer read _rowNumber write _rowNumber;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetLeftPadding(const InnerOffset: Single);
    procedure SetTopPadding(const InnerOffset: Single);
    procedure SetTagPosition(const LeftTop: TPointF; const WidthWithPadding: Single);
    procedure UpdateBoundsByRowNo(const RowNo, RowCount: Integer);

    function  GetUnderline: TADatoLineF;

    procedure PaintBitmap;

    property Reselectable: Boolean read _reselectable write _reselectable;
    property TagItem: CObject read _tagItem write _tagItem;
    property TagIndex: Integer read _tagIndex write _tagIndex;

  public
    property Text: string read GetText write SetText;
    property SubText: string read get_SubText write set_SubText;
    property SwabTextSubText: Boolean read get_SwabTextSubText write set_SwabTextSubText default False;
    property TagType: TTagType read get_TagType;
    property ImageName: string read get_ImageName write set_ImageName;
    property Config: TFastButtonConfig read _config;
  end;

  TChangeType = (DoRepaint, DoRecalc, ControlAdded, ControlRemoved);
  TOnTagChange = procedure(const ADatoClickLayout: TADatoClickLayout; const ChangeType: TChangeType) of object;

  TCustomADatoTagRunTimeControl = class(TLayout);

  TFastButtonConfig = class(TCollectionItem)
  strict private
    _id: string;
    _text: string;
    _subText: string;
    _swabTextSubText: Boolean;
    _imagename: string;
    _imageSizeInt: Single;
    _imagePosition: TImagePosition;
    _imagePositionMargin: Integer;
    _tagType: TTagType;
    _tabItem: TTabItem;
    _innertagscontrol: TCustomADatoTagRunTimeControl;
    _drawLineLeft: Boolean;
    _tag: TADatoClickLayout;
    _fontSize: Single;
    _fontColor: TAlphaColor;
    _fontStyles: TFontStyles;

    _onRequestRecalc: TOnTagChange;

    procedure set_Innertagscontrol(const Value: TCustomADatoTagRunTimeControl);

  private
    procedure set_Imagename(const Value: string);
    procedure set_TagType(const Value: TTagType);
    procedure SetText(const Value: string);
    procedure set_SubText(const Value: string);
    procedure set_ImagePosition(const Value: TImagePosition);
    procedure set_ImageSizeInt(const Value: Single);
    procedure set_ImagePositionMargin(const Value: Integer);
    function  get_SubText: string;
    procedure set_DrawLineLeft(const Value: Boolean);
    procedure set_FontColor(const Value: TAlphaColor);
    procedure set_FontSize(const Value: Single);
    procedure set_FontStyles(const Value: TFontStyles);
    procedure set_SwabTextSubText(const Value: Boolean);

  protected
    procedure AskForRecalc(ChangeType: TChangeType);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property OnRequestRecalc: TOnTagChange write _onRequestRecalc;
    property FontSize: Single read _fontSize write set_FontSize;
    property FontColor: TAlphaColor read _fontColor write set_FontColor;
    property FontStyles: TFontStyles read _fontStyles write set_FontStyles;
    property Tag: TADatoClickLayout read _tag write _tag;
    property ImageSizeInt: Single read _imageSizeInt write set_ImageSizeInt;

  published
    property ID: string read _id write _id;
    property Text: string read _text write SetText;
    property SubText: string read get_SubText write set_SubText;
    property SwabTextSubText: Boolean read _swabTextSubText write set_SwabTextSubText default False;

    property Imagename: string read _imagename write set_Imagename;
    property ImagePosition: TImagePosition read _imagePosition write set_ImagePosition default TImagePosition.Left;
    property ImagePositionMargin: Integer read _imagePositionMargin write set_ImagePositionMargin default 3;

    property TagType: TTagType read _tagType write set_TagType default TTagType.NoBounds;
    property DrawLineLeft: Boolean read _drawLineLeft write set_DrawLineLeft default False;

    property TabItem: TTabItem read _tabItem write _tabItem;
    property Innertagscontrol: TCustomADatoTagRunTimeControl read _innertagscontrol write set_Innertagscontrol;
  end;

  TFastButton = class(TADatoClickLayout, IIsChecked)
  private
    _buttonType: TButtonType;
    _emphasizePicture: Boolean;
    _showHoverEffect: Boolean;
    _showUnderline: Boolean;
    _translatable: Boolean;
    _underlineType: TUnderlineType;
//    _images: TCustomImageList;
    _recalcNeeded: Boolean;
    _waitForRepaint: Boolean;
    _mouseIsDown: Boolean;
    _autoWidth: Boolean;
    _contentHorzAlign: TTextAlign;

    _imagesLink: TImageLink;

    procedure set_ButtonType(const Value: TButtonType);
    procedure set_EmphasizePicture(const Value: Boolean);
    procedure set_ShowUnderline(const Value: Boolean);
    procedure set_Translatable(const Value: Boolean);
    procedure set_UnderlineType(const Value: TUnderlineType);

    function  get_ImagePosition: TImagePosition;
    procedure set_ImagePosition(const Value: TImagePosition);
    function  get_imagePositionMargin: Integer;
    procedure set_ImagePositionMargin(const Value: Integer);
    procedure set_ImageIndex(const Value: Integer);
    function  get_imageIndex: Integer;
    procedure set_AutoWidth(const Value: Boolean);
    function  get_ContentHorzAlign: TTextAlign;
    procedure set_ContentHorzAlign(const Value: TTextAlign);
    procedure set_Images(const Value: TCustomImageList);

  protected
    function  get_Images: TCustomImageList; override;
    function  get_Radius: Single; override;
    function  MouseIsDown: Boolean; override;

    procedure Calculate; override;
    procedure DoPaint; override;
    procedure Painting; override;
    procedure DoResized; override;

    procedure SetEnabled(const Value: Boolean); override;
    procedure SetVisible(const Value: Boolean); override;

    procedure DoMouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure ActionChange(Sender: TBasicAction; CheckDefaults: Boolean); override;

    procedure RecalcNeeded;
    procedure RepaintNeeded;
    procedure OnConfigRequestRecalc(const ADatoClickLayout: TADatoClickLayout; const ChangeType: TChangeType);

    procedure PaddingChanged; override;
    function  GetSidePadding: Single;

    // IIsChecked
    function  GetIsChecked: Boolean;
    procedure SetIsChecked(const Value: Boolean);
    function  IsCheckedStored: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareForPaint; override;
    function  CalcWidth: Single;

    function  DoClick: Boolean;

    property IsChecked: Boolean read GetIsChecked write SetIsChecked;

  published
    property Images: TCustomImageList read get_Images write set_Images;
    property ImagePosition: TImagePosition read get_ImagePosition write set_ImagePosition default Center;
    property ImagePositionMargin: Integer read get_imagePositionMargin write set_ImagePositionMargin default -1;
    property ImageIndex: Integer read get_imageIndex write set_ImageIndex;

    property Translatable: Boolean read _translatable write set_Translatable default False;
    property ShowHoverEffect: Boolean read _showHoverEffect write _showHoverEffect default True;
    property ShowUnderline: Boolean read _showUnderline write set_ShowUnderline default False;
    property UnderlineType: TUnderlineType read _underlineType write set_UnderlineType default TUnderlineType.NoUnderline;
    property ButtonType: TButtonType read _buttonType write set_ButtonType default TButtonType.None;
    property ForceOrange: Boolean read _emphasizePicture write set_EmphasizePicture;
    property AutoWidth: Boolean read _autoWidth write set_AutoWidth default False;
    property ContentHorzAlign: TTextAlign read get_ContentHorzAlign write set_ContentHorzAlign default TTextAlign.Leading;

    property Action;
    property Text;
    property SubText;
    property SwabTextSubText;
    property ImageName;
  end;

implementation

uses
  System.Math, System.Actions, FMX.Controls;

{ TADatoClickLayout }

function TADatoClickLayout.HasButtonEvent: Boolean;
begin
  Result := Assigned(OnClick);
end;

function TADatoClickLayout.HasImage: Boolean;
begin
  Result := (Length(get_ImageName) > 0) and (get_Images <> nil);
end;

function TADatoClickLayout.HasSideButton: Boolean;
begin
  Result := False;
end;

function TADatoClickLayout.HasSubText: Boolean;
begin
  Result := HasText and (Length(get_SubText) > 0) and ((_config.ImagePosition <> TImagePosition.Center) or not HasImage);
end;

function TADatoClickLayout.HasText: Boolean;
begin
  Result := (Length(GetText) > 0) and ((_config.ImagePosition <> TImagePosition.Center) or not HasImage);
end;

procedure TADatoClickLayout.Calculate;
begin
  var w := 0.0;

  var cv := Self.Canvas;
  if cv = nil then
    cv := TCanvasManager.MeasureCanvas;

  cv.Font.Size := _config.FontSize;
  var textHeight := cv.TextHeight('Gg'); // > in case of empty text we need a height.
  var subTextHeight := 0.0;
  if HasText then
  begin
    w := cv.TextWidth(Self.Text);

    if HasSubText then
    begin
      cv.Font.Size := 10;
      var w2 := cv.TextWidth(Self.SubText);
      w := System.Math.Max(w, w2);
      subTextHeight := cv.TextHeight('Gg');
    end;

//    if get_TagType <> TTagType.NoBounds then
//      w := w + 2; // total of margins to stroke
  end;

  // we use negative margins for subTextHeight to m ake text and subtext closer to each other
  var totalTextsHeight := textHeight + System.Math.Max(0, (subTextHeight - 3));
  var h := totalTextsHeight;

  var sideButtonSize := 12;
  var sideButtonMargin := 0;
  if HasSideButton then
  begin
    sideButtonMargin := 9;
    w := w + sideButtonSize + sideButtonMargin {margin};
  end;

  var offset: Single := 0;
  case get_TagType of
    SignPost: offSet := h/2;
    RoundPost: begin
      offSet := 5;
      w := w + 10;
    end;
//    NoBounds: offSet := 0;
  end;

  var yOffSet := 0.0;
  if HasImage then
  begin
    var imgSize := _config.ImageSizeInt;
    if (_config.ImagePosition in [TImagePosition.Center, TImagePosition.Left, TImagePosition.Right]) then
    begin
      w := w + imgSize;
      h := System.Math.Min(System.Math.Max(h, imgSize), Self.Height);
      if HasText and (_config.ImagePosition in [TImagePosition.Left, TImagePosition.Right]) then
        w := w + _config.ImagePositionMargin;
    end
    else begin
      h := h + Padding.Top + Padding.Bottom;
      h := h + imgSize + IfThen(HasText, _config.ImagePositionMargin, 0);
      w := System.Math.Min(System.Math.Max(w, imgSize), Self.Width);
    end;
  end;

  case get_TagType of
    SignPost: begin
      SetLength(_polygon, 6);
      _polygon[0] := PointF(offset, 0);
      _polygon[1] := PointF(w + offset, 0);
      _polygon[2] := PointF(w + offset, h);
      _polygon[3] := PointF(offset, h);
      _polygon[4] := PointF(0, h / 2);
      _polygon[5] := _polygon[0];

      _innerBounds := RectF(0, 0, w + offset, h);
    end else
    begin
      SetLength(_polygon, 5);
      _polygon[0] := PointF(offset, 0);
      _polygon[1] := PointF(w + offset, 0);
      _polygon[2] := PointF(w + offset, h);
      _polygon[3] := PointF(offset, h);
      _polygon[4] := _polygon[0];

      _innerBounds := RectF(0, 0, w + offset, h);
    end;
  end;

  var wLeft := w;

  if HasSideButton then
  begin
    var startY := (h-sideButtonSize)/2;
    _sideBounds := RectF(offset + wLeft - sideButtonSize, startY, offSet + wLeft, startY + sideButtonSize);
    wLeft := wLeft - _sideBounds.Width - sideButtonMargin {margin};
  end else
    _sideBounds := TRectF.Empty;

  if HasImage then
  begin
    var imgSize := _config.ImageSizeInt;
    case _config.ImagePosition of
      TImagePosition.Left: begin
        var topBottomPadding := System.Math.Max(0, (h - imgSize) / 2);
        _imageBounds := RectF(offset, topBottomPadding, offSet+imgSize, h-topBottomPadding);
        wLeft := wLeft - _imageBounds.Width - _config.ImagePositionMargin;
      end;
      TImagePosition.Right: begin
        var topBottomPadding := System.Math.Max(0, (h - imgSize) / 2);
        _imageBounds := RectF(_innerBounds.Right - imgSize, topBottomPadding, _innerBounds.Right, h-topBottomPadding);
        wLeft := wLeft - _imageBounds.Width - _config.ImagePositionMargin;
      end;
      TImagePosition.Top: begin
        var xStart := offSet + (w-imgSize)/2;
        _imageBounds := RectF(xStart, Padding.Top, xStart + imgSize, Padding.Top + imgSize);
      end;
      TImagePosition.Bottom: begin
        var xStart := offSet + (w-imgSize)/2;
        _imageBounds := RectF(xStart, _innerBounds.Bottom - imgSize - Padding.Bottom, xStart + imgSize, _innerBounds.Bottom - Padding.Bottom);
      end;
      TImagePosition.Center: begin
        var xStart := offSet + (w-imgSize)/2;
        var yStart := System.Math.Max(0, (h-imgSize) / 2);
        _imageBounds := RectF(xStart, yStart, xStart + imgSize, yStart + imgSize);
      end;
    end;
  end;

  if (_config.ImagePosition = TImagePosition.Center) and HasImage then
  begin
    _textBounds := TRectF.Empty;
    _subTextBounds := TRectF.Empty;
    Exit;
  end;

  if HasText then
  begin
    if not HasImage then
    begin
      var topOffSet := IfThen(HasSubText, (h - totalTextsHeight) / 2, (h - textHeight)/2);
      _textBounds := RectF(offSet, topOffSet, offSet + wLeft, topOffSet + textHeight)
    end
    else if _config.ImagePosition = TImagePosition.Left then
    begin
      var topOffSet := IfThen(HasSubText, (h - totalTextsHeight) / 2, (h - textHeight)/2);
      _textBounds := RectF(_imageBounds.Right + _config.ImagePositionMargin, topOffSet, _imageBounds.Right + _config.ImagePositionMargin + wLeft, topOffSet + textHeight)
    end
    else if _config.ImagePosition = TImagePosition.Right then
    begin
      var topOffSet := IfThen(HasSubText, (h - totalTextsHeight) / 2, (h - textHeight)/2);
      _textBounds := RectF(offSet, topOffSet, _imageBounds.Left - _config.ImagePositionMargin, topOffSet + textHeight)
    end
    else if _config.ImagePosition = TImagePosition.Top then
      _textBounds := RectF(offSet, _imageBounds.Bottom + _config.ImagePositionMargin, offSet + wLeft, _imageBounds.Bottom + _config.ImagePositionMargin + textHeight)
    else // bottom
      _textBounds := RectF(offSet, Padding.Top, offSet + wLeft, Padding.Top + textHeight);
  end else
    _textBounds := TRectF.Empty;

  if HasSubText then
    _subTextBounds := RectF(_textBounds.Left, _textBounds.Bottom - 3, _textBounds.Right, _textBounds.Bottom - 3 + subTextHeight) else
    _subTextBounds := TRectF.Empty;

  if _config.SwabTextSubText and HasText and HasSubText then
  begin
    _subTextBounds.Offset(0, _textBounds.Top - _subTextBounds.Top);
    _textBounds.Offset(0, _subTextBounds.Bottom - 3);
  end;
end;

function TADatoClickLayout.CheckHoveredChanged(const ParentPoint: TPointF): Boolean;
begin
  if not Self.Visible then
    Exit(False);

  var mouseOnTag := BoundsRect.Contains(ParentPoint);

  if (_hover <> (mouseOnTag and Enabled)) and (_isAddTag or HasButtonEvent) then
  begin
    _hover := not _hover;
    Result := True;
  end else
    Result := False;

  if not HasSideButton or (not mouseOnTag and not _hoverSide) then
    Exit;

  var localPoint := ParentPoint;
  localPoint.Offset(-BoundsRect.TopLeft);

  if _hoverSide <> _sideBounds.Contains(localPoint) then
  begin
    _hoverSide := not _hoverSide;
    Result := True;
  end;
end;

constructor TADatoClickLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  _imageIndex := -1;

  CanFocus := True;
end;

function TADatoClickLayout.CreateConfig: TFastButtonConfig;
begin
  Result := TFastButtonConfig.Create(nil);
end;

destructor TADatoClickLayout.Destroy;
begin
  if _config <> nil then
  begin
    _config.OnRequestRecalc := nil;
    FreeAndNil(_config);
  end;

  inherited;
end;

function TADatoClickLayout.get_ImageName: string;
begin
  Result := _config.Imagename;
end;

function TADatoClickLayout.get_Polygon: TPolygon;
begin
  Result := _polygon;
end;

function TADatoClickLayout.get_Radius: Single;
begin
  Result := IfThen(get_TagType = TTagType.RoundPost, 3, 0);
end;

function TADatoClickLayout.get_SubText: string;
begin
  Result := _config.SubText;
end;

function TADatoClickLayout.get_SwabTextSubText: Boolean;
begin
  Result := _config.SwabTextSubText;
end;

function TADatoClickLayout.get_TagType: TTagType;
begin
  Result := _config.TagType;
end;

function TADatoClickLayout.GetBitmap(const Images: TCustomImageList; const BitmapSize: TSize; const BitmapIndex: Integer): TBitmap;
begin
  Result := Images.Bitmap(BitmapSize, BitmapIndex);
end;

function TADatoClickLayout.GetPaintOpacity: Single;
begin
  if not Self.Enabled then
    Result := Opacity * 0.6 else
    Result := Opacity;
end;

function TADatoClickLayout.GetText: string;
begin
  Result := _config.Text;
end;

procedure TADatoClickLayout.set_TagType(const Value: TTagType);
begin
  _config.TagType := Value;
end;

function TADatoClickLayout.TextStored: Boolean;
begin
  Result := False;
end;

procedure TADatoClickLayout.set_ImageName(const Value: string);
begin
  if _config.ImageName <> Value then
  begin
    _config.ImageName := Value;
    _imageIndex := -1;
  end;
end;

procedure TADatoClickLayout.set_SubText(const Value: string);
begin
  _config.SubText := Value;
end;

procedure TADatoClickLayout.set_SwabTextSubText(const Value: Boolean);
begin
  _config.SwabTextSubText := Value;
end;

procedure TADatoClickLayout.SetText(const Value: string);
begin
  _config.Text := Value;
end;

procedure TADatoClickLayout.UpdateBoundsByRowNo(const RowNo, RowCount: Integer);
begin
  case get_TagType of
    RoundPost, SignPost: begin
      var startY := ((_innerBounds.Height+5) * (RowNo - 1));
      Self.BoundsRect := RectF(BoundsRect.Left, startY, BoundsRect.Right, startY + _innerBounds.Height);
    end;
    NoBounds: begin
      var startY := ((ParentControl.Height / RowCount) * (RowNo - 1));
      var stopY := ((ParentControl.Height / RowCount) * RowNo);
      Self.BoundsRect := RectF(BoundsRect.Left, startY, BoundsRect.Right, stopY);
    end;
  end;
end;

function TADatoClickLayout.GetUnderline: TADatoLineF;
begin
  var bounds := BoundsRect;
  var localY := (bounds.Height / 2) + 10;
  if _innerBounds.Bottom + 2 > localY then
    localY := _innerBounds.Bottom + 2;

  var y := localY + bounds.Top;

  if HasText then
  begin
    Result := TADatoLineF.Create(
      PointF(bounds.Left + _textBounds.Left + 6, y),
      PointF(bounds.Left + _textBounds.Right - 6, y)
    );
  end
  else if HasImage then
  begin
    Result := TADatoLineF.Create(
      PointF(bounds.Left + _imageBounds.Left + 2, y),
      PointF(bounds.Left + _imageBounds.Right - 2, y)
    );
  end;

end;

procedure TADatoClickLayout.SetTagPosition(const LeftTop: TPointF; const WidthWithPadding: Single);
begin
  Self.BoundsRect := RectF(LeftTop.X, LeftTop.Y, LeftTop.X + WidthWithPadding, LeftTop.Y + _innerBounds.Height + (2*_innerBounds.Top));
end;

procedure TADatoClickLayout.SetTopPadding(const InnerOffset: Single);
begin
  SetPadding(0, InnerOffset);
end;

procedure TADatoClickLayout.SetLeftPadding(const InnerOffset: Single);
begin
  SetPadding(InnerOffset, 0);
end;

procedure TADatoClickLayout.SetPadding(const Left, Top: Single);
begin
  for var pointIx := 0 to System.High(_polygon) do
  begin
    var p := _polygon[pointIx];
    p.Offset(Left, Top);
    _polygon[pointIx] := p;
  end;

  _sideBounds.Offset(Left, Top);
  _imageBounds.Offset(Left, Top);
  _textBounds.Offset(Left, Top);
  _subTextBounds.Offset(Left, Top);
  _innerBounds.Offset(Left, Top);

//  _innerBounds := RectF(_polygon[4].X, _polygon[0].Y, _polygon[1].X, _polygon[2].Y);
end;

procedure TADatoClickLayout.PaintBitmap;
begin
  var screenScale: Single;
  if Scene <> nil then
    screenScale := Scene.GetSceneScale else
    screenScale := 1;

  var w := Round(_imageBounds.Width * screenScale);
  if _config.ImagePosition = TImagePosition.Right then
    w := w + 1 + 1 - 2;

  var h := Round(_imageBounds.Height * screenScale);
  var bitmapSize := TSize.Create(w, h);
//  if not Stretch then
//    Images.BestSize(ImageIndex, BitmapSize);

  if (_imageIndex = -1) and (Length(get_ImageName) > 0) then
    _imageIndex := get_Images.Source.IndexOf(get_ImageName);

  if (_imageIndex = -1) then
    Exit;

  var bitmap := GetBitmap(get_Images, bitmapSize, _imageIndex);
  try
    if bitmap <> nil then
    begin
      var bitmapRect := TRectF.Create(0, 0, Bitmap.Width, Bitmap.Height);
      var imgRect := _imageBounds.Round; //TRectF.Create(CenteredRect(_imageBounds.Round, TRectF.Create(0, 0, Bitmap.Width / ScreenScale, Bitmap.Height/ ScreenScale).Round));
      Canvas.DrawBitmap(Bitmap, BitmapRect, imgRect, IfThen(Enabled, 1, 0.6), False);
    end;
  finally
    bitmap.Free;
  end;
end;

procedure TADatoClickLayout.DoPaint;
begin
  var cvs := Self.Canvas;

  cvs.Font.Size := _config.FontSize;
  cvs.Fill.Color := TAlphaColor($FFF2F5F9);
  cvs.Stroke.Kind := TBrushKind.Solid;

  case get_TagType of
    TTagType.RoundPost: cvs.FillRect(_innerBounds, get_radius, get_Radius, AllCorners, GetPaintOpacity * IfThen(_isAddTag, 0.6, 1));
    TTagType.SignPost: cvs.FillPolygon(_polygon, GetPaintOpacity * IfThen(_isAddTag, 0.6, 1));
  end;

  if _hover or _hoverSide then
  begin
    cvs.Fill.Color := TAlphaColor($FFC3CBE6);

    if _hoverSide then
      cvs.FillRect(_sideBounds, get_Radius, get_Radius, AllCorners, GetPaintOpacity * IfThen(MouseIsDown, 0.6, 1))
    else if get_TagType = TTagType.RoundPost then
      cvs.FillRect(_innerBounds, get_Radius, get_Radius, AllCorners, GetPaintOpacity * IfThen(MouseIsDown, 0.6, 1))
    else if get_TagType = TTagType.SignPost then
      cvs.FillPolygon(_polygon, GetPaintOpacity * IfThen(MouseIsDown, 0.6, 1));
  end;

  var horzAlign := TTextAlign.Center;
//  if tag_tagType <> TTagType.RoundPost then
//  begin
    if _config.ImagePosition = TImagePosition.Left then
      horzAlign := TTextAlign.Leading
    else if _config.ImagePosition = TImagePosition.Right then
      horzAlign := TTextAlign.Trailing;
//  end;

  if HasText then
  begin
//    Canvas.Stroke.Color := GetLynxXFontColor(_contrast, _contrastSpeciale);
    cvs.Fill.Color := _config.FontColor;
    cvs.Font.Style := _config.FontStyles;
    cvs.FillText(_textBounds, Text, False, GetPaintOpacity, [], horzAlign, TTextAlign.Leading);
  end;

  if HasSubText then
  begin
    cvs.Fill.Color := TAlphaColors.Lightslategray;
    cvs.Font.Style := [];
    cvs.Font.Size := 10;
    cvs.FillText(_subTextBounds, SubText, False, GetPaintOpacity, [], horzAlign, TTextAlign.Leading);
  end;

  if HasImage then
    PaintBitmap;

  if HasSideButton then
  begin
    var marg := 3;
    cvs.Stroke.Color := TAlphaColors.Black;
    cvs.DrawLine(PointF(_sideBounds.Left+marg, _sideBounds.Top+marg), PointF(_sideBounds.Right-marg, _sideBounds.Bottom-marg), GetPaintOpacity);
    cvs.DrawLine(PointF(_sideBounds.Left+marg, _sideBounds.Bottom-marg), PointF(_sideBounds.Right-marg, _sideBounds.Top+marg), GetPaintOpacity);
  end;

  cvs.Stroke.Color := TAlphaColor($FFDCDCDC);

  case get_TagType of
    TTagType.RoundPost: begin
      cvs.DrawRect(_innerBounds, 3, 3, AllCorners, GetPaintOpacity, TCornerType.Round);
    end;
    TTagType.SignPost: begin
      cvs.DrawPolygon(_polygon, GetPaintOpacity);
    end;
  end;

  // paint between line
  if _config.DrawLineLeft then
  begin
    var xPos := CMath.Max( _innerBounds.Left - 10, 0);

    var lineHeight := CMath.Min(_innerBounds.Height, 16);
    var yPos := (Height-lineHeight)/2;

    Canvas.Stroke.Thickness := 1;
    Canvas.Stroke.Color := TAlphaColors.Lightslategrey;
    Canvas.DrawLine(PointF(xPos, yPos), PointF(xPos, yPos+lineHeight), 1);
  end;


//  cvs.Stroke.Color := TAlphaColors.Navy;
//  cvs.DrawRect(RectF(0,0,Width,Height), 1);
//
//  cvs.Fill.Color := TAlphaColors.Yellow;
//  cvs.FillRect(_innerBounds, 0.5);
//
//  cvs.Fill.Color := TAlphaColors.Orange;
//  cvs.FillRect(_imageBounds, 0.5);
//
//  cvs.Fill.Color := TAlphaColors.Grey;
//  cvs.FillRect(_textBounds, 0.5);
//
//  cvs.Fill.Color := TAlphaColors.Pink;
//  cvs.FillRect(_subTextBounds, 0.5);
//
//  cvs.Fill.Color := TAlphaColors.Blueviolet;
//  cvs.FillRect(_sideBounds, 0.5);

  inherited;
end;

{ TFastButton }

procedure TFastButton.ActionChange(Sender: TBasicAction; CheckDefaults: Boolean);
begin
  inherited;

  SetIsChecked(GetIsChecked);

  if Length(GetText) = 0 then
    SetText(TAction(Sender).Text);
end;

procedure TFastButton.Calculate;
begin
  if _recalcNeeded then
  begin
    _recalcNeeded := False;
    inherited;

    var innerPadding := GetSidePadding;
    if _autoWidth then
      Self.Width := _innerBounds.Width + 2*innerPadding;

    var horzAlign := get_ContentHorzAlign;
    if ((Width - InnerBounds.Width) / 2) < innerPadding then
      horzAlign := TTextAlign.Center;

    case horzAlign of
      TTextAlign.Center: SetLeftPadding((Width - InnerBounds.Width) / 2);
      TTextAlign.Leading: SetLeftPadding(innerPadding);
      TTextAlign.Trailing: SetLeftPadding(Width - InnerBounds.Width - innerPadding);
    end;

    var heightAvailable := Height - Margins.Top - Margins.Bottom;
    SetTopPadding(System.Math.Max(0, (heightAvailable - InnerBounds.Height)/2));
  end;
end;

function TFastButton.CalcWidth: Single;
begin
  Calculate;
  Result := _innerBounds.Width + (2*GetSidePadding);
end;

constructor TFastButton.Create(AOwner: TComponent);
begin
  inherited;

  HitTest := True;
  Width := 100;
  Height := 25;

  _config := CreateConfig;
  _config.TagType := TTagType.NoBounds;
  _config.OnRequestRecalc := OnConfigRequestRecalc;
  _config.FontColor := TAlphaColor($FF2C2C2C);
  _config.FontSize := 13;
  _config.FontStyles := [];
  _config.ImageSizeInt := 16;

  ImagePosition := TImagePosition.Center;

  _showHoverEffect := True;
  _showUnderline := False;
  _underlineType := TUnderlineType.NoUnderline;
  set_ButtonType(TButtonType.None);
  _contentHorzAlign := TTextAlign.Leading;

  ImagePositionMargin := 3;

  _imagesLink := TImageLink.Create;
end;

procedure TFastButton.DoPaint;
begin
  _waitForRepaint := False;

  var outerRect := RectF(0, 0, Width, Height);
  if _buttonType = TButtonType.Emphasized then
  begin
    Canvas.Fill.Color := TAlphaColor($FF4E6CA3);
    Canvas.FillRect(outerRect, 3, 3, AllCorners, GetPaintOpacity * 0.4);
  end
  else if _buttonType = TButtonType.Positive then
  begin
    Canvas.Fill.Color := TAlphaColor($FF37539E);
    Canvas.FillRect(outerRect, 3, 3, AllCorners, GetPaintOpacity);
  end
  else if _buttonType = TButtonType.Negative then
  begin
    Canvas.Fill.Color := TAlphaColor($FFFDFDFE);
    Canvas.FillRect(outerRect, 3, 3, AllCorners, GetPaintOpacity);
  end;

  if not _showHoverEffect then
  begin
    _hover := False;
    _hoverSide := False;
  end;

  if _hover and (get_TagType = TTagType.NoBounds) then
  begin
    Canvas.Fill.Color := TAlphaColor($FFC3CBE6);
    Canvas.FillRect(outerRect, get_Radius, get_Radius, AllCorners, 0.6 * IfThen(MouseIsDown, 0.5, 1));
  end;

  inherited;

  Canvas.Stroke.Thickness := 1;
  if _buttonType = TButtonType.Emphasized then
  begin
//    Canvas.Stroke.Color := TAlphaColor($8899ACCF);
//    Canvas.DrawRect(RectF(0,0, Width, Height), 3, 3, AllCorners, 1);
  end
  else if _buttonType = TButtonType.Negative then
  begin
    Canvas.Stroke.Color := TAlphaColor($FF37539E) ;//99ACCF);
    Canvas.DrawRect(outerRect, 3, 3, AllCorners, GetPaintOpacity);
  end;

//  Canvas.Fill.Color := TAlphaColors.Blue;
//  Canvas.FillRect(_innerBounds, 0.6);
//
//  Canvas.Fill.Color := TAlphaColors.Green;
//  Canvas.FillRect(get_ImageBounds, 0.6);
//
//  Canvas.Fill.Color := TAlphaColors.Orange;
//  Canvas.FillRect(get_TextBounds, 0.6);
end;

procedure TFastButton.DoResized;
begin
  inherited;
  RecalcNeeded;
end;

function TFastButton.GetIsChecked: Boolean;
begin
  if Action <> nil then
    Result := (Action as TContainedAction).Checked else
    Result := _buttonType = TButtonType.Emphasized;
end;

function TFastButton.get_ContentHorzAlign: TTextAlign;
begin
  if get_ImagePosition = TImagePosition.Center then
    Result := TTextAlign.Center else
    Result := _contentHorzAlign;
end;

function TFastButton.get_imageIndex: Integer;
begin
  Result := _imageIndex;
end;

function TFastButton.get_ImagePosition: TImagePosition;
begin
  Result := _config.ImagePosition;
end;

function TFastButton.get_imagePositionMargin: Integer;
begin
  Result := _config.ImagePositionMargin;
end;

function TFastButton.get_Images: TCustomImageList;
begin
  Result := TCustomImageList(_imagesLink.Images);
end;

function TFastButton.get_Radius: Single;
begin
  Result := IfThen(ButtonType <> TButtonType.None, 3, 0);
end;

function TFastButton.IsCheckedStored: Boolean;
begin
  Result := False;
end;

procedure TFastButton.RecalcNeeded;
begin
  _recalcNeeded := True;
  RepaintNeeded;
end;

procedure TFastButton.RepaintNeeded;
begin
  if not FInPaintTo and not _waitForRepaint then
  begin
    _waitForRepaint := True;
    Repaint;
  end;
end;

procedure TFastButton.SetEnabled(const Value: Boolean);
begin
  inherited;
  RepaintNeeded;
end;

procedure TFastButton.SetIsChecked(const Value: Boolean);
begin
  if GetIsChecked <> Value then
  begin
    if Value then
      ButtonType := TButtonType.Emphasized else
      ButtonType := TButtonType.None;
  end;
end;

procedure TFastButton.SetVisible(const Value: Boolean);
begin
  inherited;

end;

procedure TFastButton.OnConfigRequestRecalc(const ADatoClickLayout: TADatoClickLayout; const ChangeType: TChangeType);
begin
  case ChangeType of
    DoRepaint: RepaintNeeded;
    DoRecalc: RecalcNeeded;
    ControlAdded: ;
    ControlRemoved: ;
  end;
end;

procedure TFastButton.PaddingChanged;
begin
  inherited;
  RecalcNeeded;
end;

procedure TFastButton.Painting;
begin
  Calculate;
  inherited;
end;

procedure TFastButton.PrepareForPaint;
begin
  Calculate;
  inherited;
end;

procedure TFastButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  _mouseIsDown := True;
  inherited;

  RepaintNeeded;
end;

function TFastButton.DoClick: Boolean;
begin
  if not Self.Visible then
    Exit(False);

  if Assigned(OnClick) then
    OnClick(Self)
  else if (Action <> nil) then
    Action.Execute;
end;

function TFastButton.MouseIsDown: Boolean;
begin
  Result := _mouseIsDown;
end;

procedure TFastButton.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;

  if not _hover then
  begin
    _hover := Self.Enabled;
    RepaintNeeded;
  end;
end;

procedure TFastButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;

  _mouseIsDown := False;

  DoClick;

  RepaintNeeded;
end;

destructor TFastButton.Destroy;
begin
  FreeAndNil(_imagesLink);
  inherited;
end;

procedure TFastButton.DoMouseLeave;
begin
  inherited;
  _mouseIsDown := False;
  _hover := False;
  RepaintNeeded;
end;

procedure TFastButton.set_ButtonType(const Value: TButtonType);
begin
  if _ButtonType <> Value then
  begin
    _ButtonType := Value;
    RepaintNeeded;
  end;
end;

procedure TFastButton.set_AutoWidth(const Value: Boolean);
begin
  if _autoWidth <> Value then
  begin
    _autoWidth := Value;
    RecalcNeeded;
  end;
end;

procedure TFastButton.set_ContentHorzAlign(const Value: TTextAlign);
begin
  if _contentHorzAlign <> Value then
  begin
    _contentHorzAlign := Value;
    RecalcNeeded;
  end;
end;

procedure TFastButton.set_EmphasizePicture(const Value: Boolean);
begin
  if _EmphasizePicture <> Value then
  begin
    _EmphasizePicture := Value;
    RepaintNeeded;
  end;
end;

procedure TFastButton.set_ImageIndex(const Value: Integer);
begin
  if (Length(get_ImageName) = 0) and (_imagesLink.Images <> nil) then
    set_ImageName(get_Images.Source.Items[Value].Name);
end;

procedure TFastButton.set_ImagePosition(const Value: TImagePosition);
begin
  _config.ImagePosition := Value;
end;

procedure TFastButton.set_ImagePositionMargin(const Value: Integer);
begin
  _config.ImagePositionMargin := Value;
end;

procedure TFastButton.set_Images(const Value: TCustomImageList);
begin
  _imagesLink.Images := Value;
end;

procedure TFastButton.set_ShowUnderline(const Value: Boolean);
begin
  if _showUnderline <> Value then
  begin
    _showUnderline := Value;
    RepaintNeeded;
  end;
end;

procedure TFastButton.set_Translatable(const Value: Boolean);
begin
  if _translatable <> Value then
  begin
    _translatable := Value;
    RecalcNeeded;
  end;
end;

procedure TFastButton.set_UnderlineType(const Value: TUnderlineType);
begin
  if _underlineType <> Value then
  begin
    _underlineType := Value;
    RepaintNeeded;
  end;
end;

function TFastButton.GetSidePadding: Single;
begin
  Result := System.Math.Min(10, System.Math.Max(5, (Self.Height - _innerBounds.Height)/2));
end;

{ TFastButtonConfig }

constructor TFastButtonConfig.Create(Collection: TCollection);
begin
  inherited;
  _imagePositionMargin := 3;
  _imagePosition := TImagePosition.Left;
  _imageSizeInt := 16;

  _fontSize := 10;
  _fontColor := TAlphaColor($FF2C2C2C);
end;

destructor TFastButtonConfig.Destroy;
begin
  AskForRecalc(TChangeType.ControlRemoved);
  inherited;
end;

function TFastButtonConfig.get_SubText: string;
begin
  if _subText = _text then
    Exit('');

  Result := _subText;
end;

procedure TFastButtonConfig.AskForRecalc(ChangeType: TChangeType);
begin
  if Assigned(_onRequestRecalc) then
    _onRequestRecalc(_tag, ChangeType);
end;

procedure TFastButtonConfig.set_DrawLineLeft(const Value: Boolean);
begin
  if _drawLineLeft <> Value then
  begin
    _drawLineLeft := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end;
end;

procedure TFastButtonConfig.set_FontColor(const Value: TAlphaColor);
begin
  if _fontColor <> Value then
  begin
    _fontColor := Value;
    AskForRecalc(TChangeType.DoRepaint);
  end;
end;

procedure TFastButtonConfig.set_FontSize(const Value: Single);
begin
  if _fontSize <> Value then
  begin
    _fontSize := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end;
end;

procedure TFastButtonConfig.set_FontStyles(const Value: TFontStyles);
begin
  if _fontStyles <> Value then
  begin
    _fontStyles := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end;
end;

procedure TFastButtonConfig.set_Imagename(const Value: string);
begin
  if _Imagename <> Value then
  begin
    _Imagename := Value;
    AskForRecalc(TChangeType.DoRepaint);
  end
end;

procedure TFastButtonConfig.set_ImagePosition(const Value: TImagePosition);
begin
  if _ImagePosition <> Value then
  begin
    _ImagePosition := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

procedure TFastButtonConfig.set_ImagePositionMargin(const Value: Integer);
begin
  if _imagePositionMargin <> Value then
  begin
    _imagePositionMargin := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

procedure TFastButtonConfig.set_ImageSizeInt(const Value: Single);
begin
  if _imageSizeInt <> Value then
  begin
    _imageSizeInt := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

procedure TFastButtonConfig.set_Innertagscontrol(const Value: TCustomADatoTagRunTimeControl);
begin
  if _innertagscontrol <> Value then
  begin
    _innertagscontrol := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end;
end;

procedure TFastButtonConfig.set_SubText(const Value: string);
begin
  if _subText <> Value then
  begin
    _subText := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end;
end;

procedure TFastButtonConfig.set_SwabTextSubText(const Value: Boolean);
begin
  if _swabTextSubText <> Value then
  begin
    _swabTextSubText := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

procedure TFastButtonConfig.set_TagType(const Value: TTagType);
begin
  if _tagType <> Value then
  begin
    _tagType := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

procedure TFastButtonConfig.SetText(const Value: string);
begin
  if _text <> Value then
  begin
    _text := Value;
    AskForRecalc(TChangeType.DoRecalc);
  end
end;

{ TADatoLineF }

constructor TADatoLineF.Create(const AStart, AStop: TPointF);
begin
  Start := AStart;
  Stop := AStop;
end;

function TADatoLineF.IsEmpty: Boolean;
begin
  Result := Start = Stop;
end;

end.


