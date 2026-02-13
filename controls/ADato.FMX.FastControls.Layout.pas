unit ADato.FMX.FastControls.Layout;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.Math, System.SysUtils, System.Generics.Collections, System.Types, System.UITypes,
  System.Messaging, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Platform,
  FMX.Layouts, FMX.ScrollControl.ControlClasses.Intf;

type
  TAdaptableBitmapLayout = class(TLayout)
  protected
    _bitmap: TBitmap;

    _useBuffering: Boolean;
    _originalBackgroundColorIsNull: Boolean;

    _resetBufferRequired: Boolean;
    _creatingBitmap: Boolean;

    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean); virtual;

    procedure LoadBitmap;
    procedure PrepareForPaint; override;
    procedure Painting; override;
    procedure Paint; override;
    procedure DoPaint; override;
    procedure PaintChildren; override;
    procedure AfterPaint; override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    procedure DoResized; override;
    function  ObjectAtPoint(P: TPointF): IControl; override;

    function ShouldInheritPaint: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ResetBuffer;

    property UseBuffering: Boolean read get_UseBuffering write set_UseBuffering default True;
    property OriginalBackgroundColorIsNull: Boolean read _originalBackgroundColorIsNull write _originalBackgroundColorIsNull default True;
  end;

  TBackgroundControl = class(TControl, IBackgroundControl)
  private
    FStrokeThickness: Single;
  protected
    FYRadius: Single;
    FXRadius: Single;
    FCorners: TCorners;
    FSides: TSides;
    FFillColor: TAlphaColor;
    FStrokeColor: TAlphaColor;

    function  GetXRadius: Single;
    procedure SetXRadius(const Value: Single);
    function  GetYRadius: Single;
    procedure SetYRadius(const Value: Single);
    function  GetCorners: TCorners;
    procedure SetCorners(const Value: TCorners);
    function  GetSides: TSides;
    procedure SetSides(const Value: TSides);
    function  GetFillColor: TAlphaColor;
    procedure SetFillColor(const Value: TAlphaColor);
    function  GetStrokeColor: TAlphaColor;
    procedure SetStrokeColor(const Value: TAlphaColor);

    function  AsControl: TControl;

    function GetShapeRect: TRectF;
    function HasStroke: Boolean;

    procedure DoInternalChanged; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;

    property Corners: TCorners read GetCorners write SetCorners;
    property Sides: TSides read GetSides write SetSides;
    property XRadius: Single read GetXRadius write SetXRadius;
    property YRadius: Single read GetYRadius write SetYRadius;
    property FillColor: TAlphaColor read GetFillColor write SetFillColor;
    property StrokeColor: TAlphaColor read GetStrokeColor write SetStrokeColor;
  end;


implementation

uses
  FMX.Forms, FMX.Text, System.Rtti, System.Math.Vectors, ADato.TraceEvents.intf;

{ TBackgroundControl }

constructor TBackgroundControl.Create(AOwner: TComponent);
begin
  inherited;

  FSides := AllSides;
  FCorners := AllCorners;
  FStrokeThickness := 1;

  CanParentFocus := True;
  HitTest := False;
end;

procedure TBackgroundControl.Paint;
begin
  if FFillColor <> TAlphaColors.Null then
  begin
    Canvas.Fill.Color := FFillColor;
    Canvas.FillRect(LocalRect, FXRadius, FYRadius, FCorners, AbsoluteOpacity, TCornerType.Round);
  end;

  inherited;

  var drawStroke := (FStrokeColor <> TAlphaColors.Null) and (FSides <> []);
  if drawStroke then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := FStrokeColor;
    Canvas.Stroke.Thickness := FStrokeThickness;

    if (FXRadius = 0) and (YRadius = 0) then
    begin
      var drawingRect := GetShapeRect;
      var topRight := PointF(drawingRect.Right,drawingRect.Top);
      var bottomLeft := PointF(drawingRect.Left,drawingRect.Bottom);

      if TSide.Top in FSides then
        Canvas.DrawLine(drawingRect.TopLeft, topRight, AbsoluteOpacity);

      if TSide.Bottom in FSides then
        Canvas.DrawLine(bottomLeft, drawingRect.BottomRight, AbsoluteOpacity);

      if TSide.Left in FSides then
        Canvas.DrawLine(drawingRect.TopLeft, bottomLeft, AbsoluteOpacity);

      if TSide.Right in FSides then
        Canvas.DrawLine(topRight, drawingRect.BottomRight, AbsoluteOpacity);
    end
    else begin
      if FSides <> AllSides then
        Canvas.DrawRectSides(GetShapeRect, FXRadius, FYRadius, FCorners,  AbsoluteOpacity, FSides, TCornerType.Round) else
        Canvas.DrawRect(GetShapeRect, XRadius, YRadius, FCorners, AbsoluteOpacity, TCornerType.Round);
    end;
  end;
end;

procedure TBackgroundControl.DoInternalChanged;
begin
  Repaint;
end;

function TBackgroundControl.GetCorners: TCorners;
begin
  Result := FCorners;
end;

function TBackgroundControl.GetFillColor: TAlphaColor;
begin
  Result := FFillColor;
end;

function TBackgroundControl.GetShapeRect: TRectF;
begin
  Result := LocalRect;
  if HasStroke then
    InflateRect(Result, -(FStrokeThickness / 2), -(FStrokeThickness / 2));
end;

function TBackgroundControl.GetSides: TSides;
begin
  Result := FSides;
end;

function TBackgroundControl.GetStrokeColor: TAlphaColor;
begin
  Result := FStrokeColor;
end;

function TBackgroundControl.GetXRadius: Single;
begin
  Result := FXRadius;
end;

function TBackgroundControl.GetYRadius: Single;
begin
  Result := FYRadius;
end;

function TBackgroundControl.AsControl: TControl;
begin
  Result := Self;
end;

function TBackgroundControl.HasStroke: Boolean;
begin
  Result := (FStrokeColor <> TAlphaColors.Null) and (FSides <> []);
end;

procedure TBackgroundControl.SetCorners(const Value: TCorners);
begin
  if FCorners <> Value then
  begin
    FCorners := Value;
    DoInternalChanged;
  end;
end;

procedure TBackgroundControl.SetFillColor(const Value: TAlphaColor);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    DoInternalChanged;
  end;
end;

procedure TBackgroundControl.SetSides(const Value: TSides);
begin
  if FSides <> Value then
  begin
    FSides := Value;
    DoInternalChanged;
  end;
end;

procedure TBackgroundControl.SetStrokeColor(const Value: TAlphaColor);
begin
  if FStrokeColor <> Value then
  begin
    FStrokeColor := Value;
    DoInternalChanged;
  end;
end;

procedure TBackgroundControl.SetXRadius(const Value: Single);
var
  NewValue: Single;
begin
  if csDesigning in ComponentState then
    NewValue := Min(Value, Min(Width / 2, Height / 2))
  else
    NewValue := Value;
  if not SameValue(FXRadius, NewValue, TEpsilon.Vector) then
  begin
    FXRadius := NewValue;
    DoInternalChanged;
  end;
end;

procedure TBackgroundControl.SetYRadius(const Value: Single);
var
  NewValue: Single;
begin
  if csDesigning in ComponentState then
    NewValue := Min(Value, Min(Width / 2, Height / 2))
  else
    NewValue := Value;
  if not SameValue(FYRadius, NewValue, TEpsilon.Vector) then
  begin
    FYRadius := NewValue;
    DoInternalChanged;
  end;
end;

{ TAdaptableBitmapLayout }

constructor TAdaptableBitmapLayout.Create(AOwner: TComponent);
begin
  inherited;

  _useBuffering := False;
  _resetBufferRequired := True;
  _originalBackgroundColorIsNull := True;
end;

destructor TAdaptableBitmapLayout.Destroy;
begin
  FreeAndNil(_bitmap);
  inherited;
end;

procedure TAdaptableBitmapLayout.DoAddObject(const AObject: TFmxObject);
begin
  inherited;
  ResetBuffer;
end;

procedure TAdaptableBitmapLayout.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;
  ResetBuffer;
end;

procedure TAdaptableBitmapLayout.DoResized;
begin
  inherited;
  ResetBuffer;
end;

function TAdaptableBitmapLayout.get_UseBuffering: Boolean;
begin
  Result := _useBuffering;
end;

procedure TAdaptableBitmapLayout.LoadBitmap;
begin
//  var isBeforePaint := (Self.Canvas = nil) or (Self.Canvas.BeginSceneCount = 0);

  EventTracer.StartTimer('TAdaptableBitmapLayout', 'LoadBitmap');
  var scale := Self.Scene.GetSceneScale;
  if (_bitmap <> nil) and (_bitmap.BitmapScale <> scale) then
    _resetBufferRequired := True;

  if get_UseBuffering and _resetBufferRequired then
  begin
    _resetBufferRequired := False;

    _creatingBitmap := True;
    try
      var logicalW: Integer := Ceil(Self.Width * scale);
      var logicalH: Integer := Ceil(Self.Height * scale);

      if (_bitmap = nil) or (_bitmap.Width <> logicalW) or (_bitmap.Height <> logicalH) or (_bitmap.BitmapScale <> scale) then
        FreeAndNil(_bitmap);
//
      if (_bitmap = nil) then
      begin
        _bitmap := TBitmap.Create(logicalW, logicalH);
        _bitmap.CanvasQuality := TCanvasQuality.HighPerformance;
        _bitmap.BitmapScale := scale;
      end

      // try to have a background color, because clearing will cost a lot of time!!
      else if OriginalBackgroundColorIsNull then
        _bitmap.Clear(0);

      if _bitmap.Canvas.BeginScene then
      try
        PaintTo(_bitmap.Canvas, TRectF.Create(0, 0, Self.Width, Self.Height));
      finally
        _bitmap.Canvas.EndScene;
      end;
    finally
      _creatingBitmap := False;
    end;
  end;
  EventTracer.PauseTimer('TAdaptableBitmapLayout', 'LoadBitmap');
end;

function TAdaptableBitmapLayout.ObjectAtPoint(P: TPointF): IControl;
begin
  Result := inherited;
end;

procedure TAdaptableBitmapLayout.PrepareForPaint;
begin
  LoadBitmap;
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;
end;

procedure TAdaptableBitmapLayout.Painting;
begin
  LoadBitmap;
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;
end;

procedure TAdaptableBitmapLayout.Paint;
begin
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;

  var destRect := RectF(0, 0, Self.Width, Self.Height);
  Canvas.DrawBitmap(_bitmap, RectF(0, 0, _bitmap.Width, _bitmap.Height), destRect, 1.0, False);
end;

procedure TAdaptableBitmapLayout.PaintChildren;
begin
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;
end;

procedure TAdaptableBitmapLayout.DoPaint;
begin
end;

procedure TAdaptableBitmapLayout.AfterPaint;
begin
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;
end;

function TAdaptableBitmapLayout.ShouldInheritPaint: Boolean;
begin
  Result := not get_UseBuffering or _creatingBitmap;
end;

procedure TAdaptableBitmapLayout.ResetBuffer;
begin
  _resetBufferRequired := True;
  InvalidateRect(LocalRect);
end;

procedure TAdaptableBitmapLayout.set_UseBuffering(const Value: Boolean);
begin
  if csDesigning in ComponentState then
  begin
    _useBuffering := False;
    Exit;
  end;

  if get_UseBuffering = Value then
    Exit;

  _useBuffering := Value;

  ResetBuffer;
end;

end.


