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
    [Weak] BScene: TAdaptableBufferedLayout;
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
    property Scene: TAdaptableBufferedLayout read BScene;
  end;

  TAddedControlFreeNotification = class(TInterfacedObject, IFreeNotification)
  private
    _bffLayout: TAdaptableBufferedLayout;
  public
    constructor Create(BufferLayout: TAdaptableBufferedLayout);
    procedure FreeNotification(AObject: TObject);
  end;

  TAdaptableBufferedLayout = class(TLayout)
  protected
    AScene, AStoredScene: TAdaptableBufferedScene;
    FUseBuffering: Boolean;
    FAddedChildren: TArray<TFMXObject>;

    _freeNotify: IFreeNotification;

    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean);

    procedure Paint; override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    procedure DoResized; override;
    function  ObjectAtPoint(P: TPointF): IControl; override;

    procedure OnAddedChildDestroy(const AObject: TFMXObject);
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
  BScene := AScene;
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

  AbsoluteRect := BScene.LocalToAbsolute(R);
//  BScene.RepaintRect(AbsoluteRect);

  // for skia canvas required because not TCanvasStyle.SupportClipRects :(
  // without SKIA the following was enough: BScene.RepaintRect(AbsoluteRect)
  if BScene.CanRepaint and not AbsoluteRect.IsEmpty then
  begin
    if BScene.HasDisablePaintEffect then
      BScene.UpdateEffects;

    if (BScene.Canvas <> nil) and (TCanvasStyle.SupportClipRects in BScene.Canvas.GetCanvasStyle) then
      BScene.Scene.AddUpdateRect(AbsoluteRect) else
      BScene.Scene.AddUpdateRect(R);
  end;
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
  Result := BScene;
end;

function TAdaptableBufferedScene.GetSceneScale: Single;
begin
  Result := FBuffer.BitmapScale;
end;

function TAdaptableBufferedScene.GetStyleBook: TStyleBook;
begin
  if BScene.Scene = nil then
    Result := nil
  else
    Result := BScene.Scene.StyleBook;
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
  Result := BScene.LocalToScreen(P);
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
  Result := BScene.ScreenToLocal(P);
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
  if BScene.Scene = nil then
    Scale := FScreenService.GetScreenScale
  else
    Scale := BScene.Scene.GetSceneScale;

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
    Result := (ANewScene <> nil) and (ANewScene.GetObject = BScene.Scene.GetObject);
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
  Result := BScene;
end;

{ TAdaptableBufferedLayout }

constructor TAdaptableBufferedLayout.Create(AOwner: TComponent);
begin
  inherited;

  FUseBuffering := True;
  if not (csDesigning in ComponentState) then
  begin
    AScene := TAdaptableBufferedScene.Create(Self);
    AScene.Parent := Self;
    AScene.Stored := False;
  end;

  SetLength(FAddedChildren, 0);
  _freeNotify := TAddedControlFreeNotification.Create(Self);
end;

destructor TAdaptableBufferedLayout.Destroy;
begin
  FreeAndNil(AScene);
  inherited;
end;

procedure TAdaptableBufferedLayout.DoAddObject(const AObject: TFmxObject);
begin
  if ((AScene <> nil) and (AObject <> AScene)) and (TArray.IndexOf<TFMXObject>(FAddedChildren, AObject) = -1) then
  begin
    SetLength(FAddedChildren, Length(FAddedChildren) + 1);
    FAddedChildren[High(FAddedChildren)] := AObject;

    AObject.AddFreeNotify(_freeNotify);
  end;

  if (AScene <> nil) and (AObject <> AScene) and FUseBuffering then
    AScene.AddObject(AObject)
  else
    inherited;
end;

procedure TAdaptableBufferedLayout.DoResized;
begin
  inherited;
  if AScene <> nil then
    AScene.SetSize(Round(Width), Round(Height));
end;

function TAdaptableBufferedLayout.get_UseBuffering: Boolean;
begin
  Result := FUseBuffering;
end;

function TAdaptableBufferedLayout.ObjectAtPoint(P: TPointF): IControl;
begin
  Result := nil;
  if AScene <> nil then
    Result := AScene.ObjectAtPoint(P);
  if Result = nil then
    Result := inherited ObjectAtPoint(P);
end;

procedure TAdaptableBufferedLayout.OnAddedChildDestroy(const AObject: TFMXObject);
begin
  var ix := TArray.IndexOf<TFmxObject>(FAddedChildren, AObject);
  if (ix = -1) then
    Exit;

  if ix <> High(FAddedChildren) then
  begin
    for var ix2 := ix to High(FAddedChildren) - 1 do
      FAddedChildren[ix] := FAddedChildren[ix + 1];
  end;

  SetLength(FAddedChildren, Length(FAddedChildren) - 1);
end;

procedure TAdaptableBufferedLayout.Paint;
begin
  if AScene <> nil then
  begin
    if not FUseBuffering then
    begin
      AScene.UpdateBuffer;
      AScene.Invalidate;
    end;

    AScene.DrawTo;
    Canvas.DrawBitmap(AScene.Buffer, AScene.Buffer.BoundsF, LocalRect, AbsoluteOpacity, True);
  end;

  if (csDesigning in ComponentState) and not Locked then
    DrawDesignBorder;
end;

procedure TAdaptableBufferedLayout.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;

  AObject.RemoveFreeNotify(_freeNotify);
  OnAddedChildDestroy(AObject);
end;

procedure TAdaptableBufferedLayout.ResetBuffer;
begin
  var scene: TAdaptableBufferedScene;
  if AScene <> nil then
    scene := AScene else
    scene := AStoredScene;

  if scene <> nil then
  begin
    scene.UpdateBuffer;
    scene.Invalidate;
  end;
end;

procedure TAdaptableBufferedLayout.set_UseBuffering(const Value: Boolean);
begin
  if FUseBuffering = Value then
    Exit;

  FUseBuffering := Value;

  if FUseBuffering then
  begin
    AScene := AStoredScene;
    AStoredScene := nil;
  end else begin
    AStoredScene := AScene;
    AScene := nil;
  end;

  for var item in FAddedChildren do
  begin
    item.Parent := nil;
    DoAddObject(item);
  end;
end;

{ TAddedControlFreeNotification }

constructor TAddedControlFreeNotification.Create(BufferLayout: TAdaptableBufferedLayout);
begin
  inherited Create;

  _bffLayout := BufferLayout;
end;

procedure TAddedControlFreeNotification.FreeNotification(AObject: TObject);
begin
  var fmxObj := TFMXObject(AObject);
  _bffLayout.DoRemoveObject(fmxObj);
end;

end.


