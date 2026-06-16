unit ADato.FMX.FastControls.Layout;

interface

{$SCOPEDENUMS ON}

uses
  {$IFNDEF WEBASSEMBLY}
  System.Classes, System.Math, System.SysUtils, System.Generics.Collections, System.Types, System.UITypes,
  System.Messaging, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Platform,
  FMX.Layouts, 
  {$ELSE}
  Wasm.System.Classes,
  Wasm.System.Types,
  Wasm.System.UITypes,
  Wasm.FMX.Types,
  Wasm.FMX.Controls,
  Wasm.FMX.Layouts,
  Wasm.FMX.Graphics,
  {$ENDIF}
  System_,
  FMX.ScrollControl.ControlClasses.Intf;

type
  TAdaptableBitmapLayout = class(TLayout)
  protected
    _bitmap: TBitmap;

    _useBuffering: Boolean;
    _originalBackgroundColorIsNull: Boolean;

    _resetBufferRequired: Boolean;
    _creatingBitmap: Boolean;
    _stylesPreparedForBuffer: Boolean;
    {$IFNDEF WEBASSEMBLY}
    _styleChangedId: TMessageSubscriptionId;
    {$ENDIF}

    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean); virtual;

    {$IFNDEF WEBASSEMBLY}
    procedure StyleChangedHandler(const Sender: TObject; const Msg: System.Messaging.TMessage);
    {$ENDIF}

    function  NeedsBitmapReload: Boolean;
    procedure LoadBitmap;
  public
    procedure PrepareForPaint; override;
  protected
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
    FColorOpacity: Single;

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
    function  GetColorOpacity: Single;
    procedure SetColorOpacity(const Value: Single);

    function  AsControl: TControl;

    function GetShapeRect: TRectF;
    function HasStroke: Boolean;

    procedure DoInternalChanged; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure DoPaint; override;

    property Corners: TCorners read GetCorners write SetCorners;
    property Sides: TSides read GetSides write SetSides;
    property XRadius: Single read GetXRadius write SetXRadius;
    property YRadius: Single read GetYRadius write SetYRadius;
    property FillColor: TAlphaColor read GetFillColor write SetFillColor;
    property StrokeColor: TAlphaColor read GetStrokeColor write SetStrokeColor;
    property ColorOpacity: Single read GetColorOpacity write SetColorOpacity;
  end;


implementation

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Forms, FMX.Text, System.Rtti, System.Math.Vectors, ADato.TraceEvents.intf;
  {$ELSE}
  Wasm.FMX.Forms;
  {$ENDIF}

{ TBackgroundControl }

constructor TBackgroundControl.Create(AOwner: TComponent);
begin
  inherited;

  FSides := AllSides;
  FCorners := AllCorners;
  FStrokeThickness := 1;
  FColorOpacity := 1;

  CanParentFocus := True;
  HitTest := False;
end;

procedure TBackgroundControl.Paint;
begin
  if (FFillColor <> TAlphaColors.Null) and (ColorOpacity > 0) then
  begin
    var alpha := Round(EnsureRange(ColorOpacity, 0, 1) * $FF);
    Canvas.Fill.Color := (FFillColor and $00FFFFFF) or (TAlphaColor(alpha) shl 24);
    Canvas.FillRect(LocalRect, FXRadius, FYRadius, FCorners, AbsoluteOpacity, TCornerType.Round);
  end;

  inherited;
end;

procedure TBackgroundControl.DoInternalChanged;
begin
  Repaint;
end;

procedure TBackgroundControl.DoPaint;
begin
  inherited;

  var drawStroke := (FStrokeColor <> TAlphaColors.Null) and (FSides <> []);
  if drawStroke then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Dash := TStrokeDash.Solid;
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

function TBackgroundControl.GetColorOpacity: Single;
begin
  Result := FColorOpacity;
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

procedure TBackgroundControl.SetColorOpacity(const Value: Single);
begin
  if FColorOpacity <> Value then
  begin
    FColorOpacity := Value;
    DoInternalChanged;
  end;
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
  _stylesPreparedForBuffer := False;
  _originalBackgroundColorIsNull := True;
  {$IFNDEF WEBASSEMBLY}
  _styleChangedId := TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage, StyleChangedHandler);
  {$ENDIF}
end;

destructor TAdaptableBitmapLayout.Destroy;
begin
  {$IFNDEF WEBASSEMBLY}
  TMessageManager.DefaultManager.Unsubscribe(TStyleChangedMessage, _styleChangedId);
  {$ENDIF}
  FreeAndNil(_bitmap);
  inherited;
end;

procedure TAdaptableBitmapLayout.DoAddObject(const AObject: TFmxObject);
begin
  inherited;
  _stylesPreparedForBuffer := False;
  ResetBuffer;
end;

procedure TAdaptableBitmapLayout.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;
  _stylesPreparedForBuffer := False;
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

  procedure CheckChild(const Control: TControl);
  begin
    if not Control.Visible then
      Exit;

    // required for checkboxes!

    if Control is TStyledControl then
    begin
      var stCtrl := TStyledControl(Control);
      if stCtrl.StyleState <> TStyleState.Applied then
        stCtrl.ApplyStyleLookup;
    end;

    if Control.ControlsCount = 0 then
      Exit;

    for var ctrl in Control.Controls do
      if ctrl.Visible then
        CheckChild(ctrl);
  end;

begin
  if not NeedsBitmapReload then
    Exit;

  _resetBufferRequired := False;

  if not _stylesPreparedForBuffer then
  begin
    for var child in Self.Controls do
      if child.Visible then
        CheckChild(child);

    _stylesPreparedForBuffer := True;
  end;

  _creatingBitmap := True;
  try
    var scale := Self.Scene.GetSceneScale;
    var logicalW: Integer := Ceil(Self.Width * scale);
    var logicalH: Integer := Ceil(Self.Height * scale);

    var reload := False; // reuse the existing bitmap when size and scale are unchanged

    if reload or (_bitmap = nil) or (_bitmap.Width <> logicalW) or (_bitmap.Height <> logicalH) or (_bitmap.BitmapScale <> scale) then
      FreeAndNil(_bitmap);

    if (_bitmap = nil) then
    begin
      _bitmap := TBitmap.Create(logicalW, logicalH);
      _bitmap.CanvasQuality := TCanvasQuality.HighPerformance;
      _bitmap.BitmapScale := scale;
    end

    // try to have a background color, because clearing will cost a lot of time!!
    else //if OriginalBackgroundColorIsNull then
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

function TAdaptableBitmapLayout.NeedsBitmapReload: Boolean;
begin
  Result := False;
  if _creatingBitmap or not get_UseBuffering or (Scene = nil) or (Width <= 0) or (Height <= 0) then
    Exit;

  if (_bitmap <> nil) and (_bitmap.BitmapScale <> Self.Scene.GetSceneScale) then
    _resetBufferRequired := True;

  Result := _resetBufferRequired;
end;

function TAdaptableBitmapLayout.ObjectAtPoint(P: TPointF): IControl;
begin
  Result := inherited;
end;

procedure TAdaptableBitmapLayout.PrepareForPaint;
begin
//  LoadBitmap;
  if ShouldInheritPaint then
    inherited;
end;

procedure TAdaptableBitmapLayout.Painting;
begin
  if NeedsBitmapReload then
    LoadBitmap;

  if ShouldInheritPaint then
    inherited;
end;

procedure TAdaptableBitmapLayout.Paint;
begin
  if ShouldInheritPaint then
  begin
    inherited;
    Exit;
  end;

  if _bitmap <> nil then
  begin
    var destRect := RectF(0, 0, Self.Width, Self.Height);
    Canvas.DrawBitmap(_bitmap, RectF(0, 0, _bitmap.Width, _bitmap.Height), destRect, 1.0, False);
  end;
end;

procedure TAdaptableBitmapLayout.PaintChildren;
begin
  if ShouldInheritPaint then
    inherited;
end;

procedure TAdaptableBitmapLayout.DoPaint;
begin
end;

procedure TAdaptableBitmapLayout.AfterPaint;
begin
  if ShouldInheritPaint then
    inherited;
end;

function TAdaptableBitmapLayout.ShouldInheritPaint: Boolean;
begin
  Result := not get_UseBuffering or _creatingBitmap;
end;

{$IFNDEF WEBASSEMBLY}
procedure TAdaptableBitmapLayout.StyleChangedHandler(const Sender: TObject; const Msg: System.Messaging.TMessage);
var
  Message: TStyleChangedMessage;
begin
  Message := TStyleChangedMessage(Msg);

  if (Message.Scene <> nil) and (Scene <> nil) and (Message.Scene <> Scene) then
    Exit;

  _stylesPreparedForBuffer := False;
  ResetBuffer;
end;
{$ENDIF}

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

  {$IFDEF DEBUG}
  _useBuffering := False;
  {$ELSE}
  _useBuffering := Value;
  {$ENDIF}

  ResetBuffer;
end;

end.


