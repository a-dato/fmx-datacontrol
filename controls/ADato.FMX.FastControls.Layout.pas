unit ADato.FMX.FastControls.Layout;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.Math, System.SysUtils, System.Generics.Collections, System.Types, System.UITypes,
  System.Messaging, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Platform,
  FMX.Layouts, FMX.ScrollControl.ControlClasses.Intf;

type
  TAdaptableBufferedLayout = class;

  TAdaptableBufferedScene = class(TFMXObject, IScene, IAlignRoot, IContent)
  private class var
    FScreenService: IFMXScreenService;
    class destructor Destroy;
  private
    [Weak] FScene: TAdaptableBufferedLayout;
    FBuffer: TBitmap;
    FControls: TControlList;
    FWidth: Integer;
    FHeight: Integer;
    FUpdateRects: array of TRectF;
    FLastWidth: Single;
    FLastHeight: Single;
    FDisableAlign: Boolean;

    { IScene }
    procedure AddUpdateRect(const R: TRectF);
    function GetUpdateRectsCount: Integer;
    function GetUpdateRect(const Index: Integer): TRectF;
    function GetObject: TFmxObject;
    function GetCanvas: TCanvas;
    function GetSceneScale: Single;
    function LocalToScreen(const P: TPointF): TPointF;
    function ScreenToLocal(const P: TPointF): TPointF;
    procedure ChangeScrollingState(const AControl: TControl; const Active: Boolean);
    procedure DisableUpdating;
    procedure EnableUpdating;
    function GetStyleBook: TStyleBook;
    procedure SetStyleBook(const Value: TStyleBook);
    { IAlignRoot }
    procedure Realign;
    procedure ChildrenAlignChanged;
    { IContent }
    function GetParent: TFmxObject;
    function GetChildrenCount: Integer;
    procedure Changed;
    procedure Invalidate;
    procedure UpdateBuffer;
  protected
    procedure ScaleChangedHandler(const Sender: TObject; const Msg: TMessage); virtual;
    procedure StyleChangedHandler(const Sender: TObject; const Msg: TMessage); virtual;
    procedure DrawTo;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    function ObjectAtPoint(P: TPointF): IControl;
  public
    constructor Create(const AScene: TAdaptableBufferedLayout); reintroduce;
    destructor Destroy; override;
    procedure SetSize(const AWidth, AHeight: Integer);
    property Buffer: TBitmap read FBuffer;
    property Scene: TAdaptableBufferedLayout read FScene;


  end;

  TAdaptableBufferedLayout = class(TLayout)
  protected
    FScene: TAdaptableBufferedScene;
    FUseBuffering: Boolean;

    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean);

    procedure Paint; override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoResized; override;
    function  ObjectAtPoint(P: TPointF): IControl; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ResetBuffer;

    property UseBuffering: Boolean read get_UseBuffering write set_UseBuffering default True;
  end;

implementation

uses
  FMX.Forms, FMX.Text, System.Rtti;

{ TAdaptableBufferedScene }

constructor TAdaptableBufferedScene.Create(const AScene: TAdaptableBufferedLayout);
begin
  inherited Create(nil);
  if FScreenService = nil then
    TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, FScreenService);
  FScene := AScene;
  FWidth := Round(AScene.Width);
  FHeight := Round(AScene.Height);
  FBuffer := TBitmap.Create;
  UpdateBuffer;
  FControls := TControlList.Create;
  FControls.Capacity := 10;
  TMessageManager.DefaultManager.SubscribeToMessage(TScaleChangedMessage, ScaleChangedHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage, StyleChangedHandler);
end;

destructor TAdaptableBufferedScene.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TStyleChangedMessage, StyleChangedHandler);
  TMessageManager.DefaultManager.Unsubscribe(TScaleChangedMessage, ScaleChangedHandler);
  DeleteChildren;
  FreeAndNil(FControls);
  FreeAndNil(FBuffer);
  inherited;
end;

procedure TAdaptableBufferedScene.AddUpdateRect(const R: TRectF);
var
  AbsoluteRect: TRectF;
begin
  if csDestroying in ComponentState then
    Exit;

  SetLength(FUpdateRects, Length(FUpdateRects) + 1);
  FUpdateRects[High(FUpdateRects)] := R;

  AbsoluteRect := FScene.LocalToAbsolute(R);
  FScene.RepaintRect(AbsoluteRect);

  {$IFDEF SKIA}
  // for skia canvas :(
  if FScene.CanRepaint and not AbsoluteRect.IsEmpty then
  begin
    if (FScene.Canvas = nil) or not (TCanvasStyle.SupportClipRects in FScene.Canvas.GetCanvasStyle) then
      FScene.Scene.AddUpdateRect(R);
  end;
  {$ENDIF}
end;

procedure TAdaptableBufferedScene.ChangeScrollingState(const AControl: TControl; const Active: Boolean);
begin
end;

procedure TAdaptableBufferedScene.ChildrenAlignChanged;
begin
end;

class destructor TAdaptableBufferedScene.Destroy;
begin
  FScreenService := nil;
end;

procedure TAdaptableBufferedScene.DisableUpdating;
begin
end;

procedure TAdaptableBufferedScene.DoAddObject(const AObject: TFmxObject);
var
  ChildControl: TControl;
begin
  inherited;
  if AObject is TControl then
  begin
    ChildControl := TControl(AObject);
    ChildControl.SetNewScene(Self);
    ChildControl.RecalcOpacity;
    ChildControl.RecalcAbsolute;
    ChildControl.RecalcUpdateRect;
    ChildControl.RecalcHasClipParent;
    ChildControl.RecalcEnabled;

    FControls.Add(ChildControl);

    if ChildControl.Align = TAlignLayout.None then
      ChildControl.Repaint
    else
      Realign;
  end;
end;

procedure TAdaptableBufferedScene.DoRemoveObject(const AObject: TFmxObject);
var
  ChildControl: TControl;
begin
  inherited;
  if AObject is TControl then
  begin
    ChildControl := TControl(AObject);
    FControls.Remove(ChildControl);
    ChildControl.SetNewScene(nil);
  end;
end;

procedure TAdaptableBufferedScene.Invalidate;
begin
  AddUpdateRect(TRectF.Create(0, 0, FWidth, FHeight));
end;

type
  TOpenControl = class(TControl);

procedure TAdaptableBufferedScene.DrawTo;

  function NeedPaintControl(const AControl: TControl): Boolean;
  var
    DrawRect: TRectF;
    I: Integer;
  begin
    DrawRect := UnionRect(AControl.ChildrenRect, AControl.UpdateRect);
    for I := Low(FUpdateRects) to High(FUpdateRects) do
      if IntersectRect(FUpdateRects[I], DrawRect) then
        Exit(True);
    Result := False;
  end;

var
  I: Integer;
  AllowPaint: Boolean;
  Control: TControl;
begin
  if Length(FUpdateRects) = 0 then
    Exit;

  if FBuffer.Canvas.BeginScene(@FUpdateRects) then
  try
    FBuffer.Canvas.Clear(TAlphaColorRec.Null);

    for I := 0 to FControls.Count - 1 do
    begin
      Control := FControls[I];
      if Control.Visible or Control.ShouldTestMouseHits then
      begin
        if Control.UpdateRect.IsEmpty then
          Continue;
        AllowPaint := Control.InPaintTo;
        if not AllowPaint then
          AllowPaint := NeedPaintControl(Control);
        if AllowPaint then
          TOpenControl(Control).PaintInternal;
      end;
    end;
  finally
    FBuffer.Canvas.EndScene;
  end;
  SetLength(FUpdateRects, 0);
end;

procedure TAdaptableBufferedScene.EnableUpdating;
begin
end;

function TAdaptableBufferedScene.GetCanvas: TCanvas;
begin
  Result := FBuffer.Canvas;
end;

function TAdaptableBufferedScene.GetObject: TFmxObject;
begin
  Result := Self;
end;

function TAdaptableBufferedScene.GetSceneScale: Single;
begin
  Result := FBuffer.BitmapScale;
end;

function TAdaptableBufferedScene.GetStyleBook: TStyleBook;
begin
  if FScene.Scene = nil then
    Result := nil
  else
    Result := FScene.Scene.StyleBook;
end;

function TAdaptableBufferedScene.GetUpdateRect(const Index: Integer): TRectF;
begin
  Result := FUpdateRects[Index];
end;

function TAdaptableBufferedScene.GetUpdateRectsCount: Integer;
begin
  Result := Length(FUpdateRects);
end;

function TAdaptableBufferedScene.LocalToScreen(const P: TPointF): TPointF;
begin
  Result := FScene.LocalToScreen(P);
end;

function TAdaptableBufferedScene.ObjectAtPoint(P: TPointF): IControl;
var
  I: Integer;
  Control: TControl;
  NewObj: IControl;
begin
  if FControls.Count = 0 then
    Exit(nil);

  for I := FControls.Count - 1 downto 0 do
  begin
    Control := FControls[I];
    if not Control.Visible then
      Continue;

    NewObj := IControl(Control).ObjectAtPoint(P);
    if NewObj <> nil then
      Exit(NewObj);
  end;
end;

procedure TAdaptableBufferedScene.ScaleChangedHandler(const Sender: TObject; const Msg: TMessage);
begin
  UpdateBuffer;
end;

function TAdaptableBufferedScene.ScreenToLocal(const P: TPointF): TPointF;
begin
  Result := FScene.ScreenToLocal(P);
end;

procedure TAdaptableBufferedScene.Realign;
var
  Padding: TBounds;
begin
  Padding := TBounds.Create(TRectF.Empty);
  try
    AlignObjects(Self, Padding, FWidth, FHeight, FLastWidth, FLastHeight, FDisableAlign);
  finally
    Padding.Free;
  end;
end;

procedure TAdaptableBufferedScene.UpdateBuffer;
var
  Scale: Single;
begin
  if FScene.Scene = nil then
    Scale := FScreenService.GetScreenScale
  else
    Scale := FScene.Scene.GetSceneScale;

  FBuffer.BitmapScale := Scale;
  FBuffer.SetSize(Ceil(FWidth * Scale), Ceil(FHeight * Scale));
//  Invalidate;
end;

procedure TAdaptableBufferedScene.SetSize(const AWidth, AHeight: Integer);
begin
  if (FWidth <> AWidth) or (FHeight <> AHeight) then
  begin
    FWidth := AWidth;
    FHeight := AHeight;
    UpdateBuffer;
    Realign;
  end;
end;

procedure TAdaptableBufferedScene.SetStyleBook(const Value: TStyleBook);
begin
end;

procedure TAdaptableBufferedScene.StyleChangedHandler(const Sender: TObject; const Msg: TMessage);

  function IsOurScene(const ANewScene: IScene): Boolean;
  begin
    Result := (ANewScene <> nil) and (ANewScene.GetObject = FScene.Scene.GetObject);
  end;

  function IsStyleOverriden(const ANewStyleBook: TStyleBook): Boolean;
  begin
    Result := GetStyleBook <> ANewStyleBook;
  end;

var
  Message: TStyleChangedMessage;
begin
  Message := TStyleChangedMessage(Msg);
  if not IsOurScene(Message.Scene) or IsStyleOverriden(Message.Value) then
    Exit;

  try
    TMessageManager.DefaultManager.SendMessage(nil, TStyleChangedMessage.Create(GetStyleBook, Self), True);
  except
    Application.HandleException(Self);
  end;
  UpdateBuffer;
end;

function TAdaptableBufferedScene.GetChildrenCount: Integer;
begin
  if Children = nil then
    Result := 0
  else
    Result := Children.Count;
end;

procedure TAdaptableBufferedScene.Changed;
begin
end;

function TAdaptableBufferedScene.GetParent: TFmxObject;
begin
  Result := FScene;
end;

{ TAdaptableBufferedLayout }

constructor TAdaptableBufferedLayout.Create(AOwner: TComponent);
begin
  inherited;

  FUseBuffering := True;
  if not (csDesigning in ComponentState) then
  begin
    FScene := TAdaptableBufferedScene.Create(Self);
    FScene.Parent := Self;
    FScene.Stored := False;
  end;
end;

destructor TAdaptableBufferedLayout.Destroy;
begin
  FreeAndNil(FScene);
  inherited;
end;

procedure TAdaptableBufferedLayout.DoAddObject(const AObject: TFmxObject);
begin
  if (FScene <> nil) and (AObject <> FScene) then
    FScene.AddObject(AObject)
  else
    inherited;
end;

procedure TAdaptableBufferedLayout.DoResized;
begin
  inherited;
  if FScene <> nil then
    FScene.SetSize(Round(Width), Round(Height));
end;

function TAdaptableBufferedLayout.get_UseBuffering: Boolean;
begin
  Result := FUseBuffering;
end;

function TAdaptableBufferedLayout.ObjectAtPoint(P: TPointF): IControl;
begin
  Result := nil;
  if FScene <> nil then
    Result := FScene.ObjectAtPoint(P);
  if Result = nil then
    Result := inherited ObjectAtPoint(P);
end;

procedure TAdaptableBufferedLayout.Paint;
begin
  if FScene <> nil then
  begin
    if not FUseBuffering then
      FScene.Invalidate;

    FScene.DrawTo;
    Canvas.DrawBitmap(FScene.Buffer, FScene.Buffer.BoundsF, LocalRect, AbsoluteOpacity, True);
  end;

  if (csDesigning in ComponentState) and not Locked then
    DrawDesignBorder;
end;

procedure TAdaptableBufferedLayout.ResetBuffer;
begin
  if FScene <> nil then
    FScene.Invalidate;
end;

procedure TAdaptableBufferedLayout.set_UseBuffering(const Value: Boolean);
begin
  if FUseBuffering = Value then
    Exit;

  FUseBuffering := Value;
end;

end.


