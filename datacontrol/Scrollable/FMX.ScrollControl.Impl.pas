unit FMX.ScrollControl.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.Classes,
  System.SysUtils,
  System.UITypes,
  System.Types,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Controls,
  FMX.Objects,
  {$ELSE}
  Wasm.System,
  Wasm.System.SysUtils,
  Wasm.System.Classes,
  Wasm.System.UITypes,
  Wasm.System.Types,
  Wasm.FMX.Layouts,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Types,
  Wasm.FMX.Controls,
  Wasm.FMX.Objects,
  Wasm.System.Math,
  {$ENDIF}
  System_,
  System.Diagnostics,
  FMX.ScrollControl.Intf;

type
  TCustomSmallScrollBar = class(TSmallScrollBar)
  public
    function IsTracking: Boolean;
  end;

  TScrollControl = class(TLayout, IRefreshControl, IScrollControl)
  private
    _clickEnable: Boolean;
    _safeObj: IBaseInterface;
    _checkWaitForRealignTimer: TTimer; // for info see: WaitForRealignEndedWithoutAnotherScrollTimer
    _oldViewPortPos: TPointF;

    function get_Content: TControl;
    function get_Control: TControl;
    function get_VertScrollBar: TSmallScrollBar;

  protected
    _timerDoRealignWhenScrollingStopped: Boolean;
    _timerDoRealignRefreshInterval: Integer;

    procedure DoViewPortPositionChanged; virtual;
    procedure OnHorzScrollBarChange(Sender: TObject); virtual;
    procedure OnScrollBarChange(Sender: TObject);

    function  MouseIsDown: Boolean;

    procedure TryStartWaitForRealignTimer;
    procedure StopWaitForRealignTimer;
    procedure RestartWaitForRealignTimer(OnlyForRealignWhenScrollingStopped: Boolean = False);

  // scrolling events
  protected
    _scrollUpdateCount: Integer;
    _realignState: TRealignState;
    _scrollingType: TScrollingType;

    _scrollStopWatch_scrollbar: TStopwatch;
    _scrollStopWatch_mouse: TStopwatch;
    _scrollStopWatch_mouse_lastMove: TStopwatch;
    _scrollStopWatch_wheel_lastSpin: TStopwatch;

    _mousePositionOnMouseDown: TPointF;
    _scrollbarPositionsOnMouseDown: TPointF;
    _mouseRollingLastPoints: array of TPointF;
    _mouseRollingLastTicks: array of Int64;
    _mouseRollingSampleCount: Integer;

    // Pixels still to travel. Positive moves toward the top, same sign as ScrollManualInstant.
    // Wheel input and touch flings share this so both ease out the same way.
    _scrollDistanceToGo: Single;
    _scrollSubPixel: Single;
    _scrollTau: Single;
    _scrollAnimClock: TStopwatch;
    _applyingSmoothScroll: Boolean;
    _mouseWheelSmoothScrollTimer: TTimer;

    _controlWasFocusedBeforeMouseDown: Boolean;
    _rightClickPopupIsOpen: Boolean;

    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;
    procedure HandleRightClick(Shift: TShiftState; X, Y: Single);

    procedure MouseRollingBoostTimer(Sender: TObject);
    procedure StopSmoothScroll(const FinishScrolling: Boolean = True);
    procedure AddSmoothScrollDistance(const DistancePx, Tau: Single);
    procedure ApplySmoothScrollFrame(const DtSeconds: Single);

    function  CanRealignScrollCheck(ForceOnScrollbarEnds: Boolean = False): Boolean;
    function  RealignContentTime: Integer; virtual;

    procedure AfterScrolling; virtual;

    procedure WaitForRealignEndedWithoutAnotherScrollTimer(Sender: TObject);
    procedure MouseWheelSmoothScrollingTimer(Sender: TObject);

    function  DefaultMoveDistance(ScrollDown: Boolean; RowCount: Integer): Single; virtual; abstract;
    procedure UserClicked(Button: TMouseButton; Shift: TShiftState; const X, Y: Single); virtual; abstract;

    procedure DoHorzScrollBarChanged; virtual;
    function  GetViewPortPosition: TPointF;

    function  TryExecuteMouseScrollBoostOnMouseEventStopped: Boolean;
    function  MouseScrollingBoostDistance: Single;
    procedure UpdateMouseScrollingLastMoves(Reset: Boolean; LastPoint: TPointF);

  protected
    _customHintShowing: Boolean;
    _customHintTimer: TTimer;
    _lastMousePos: TPointF;
    _mouseIsSticking: Boolean;
    _onStickyClick: TNotifyEvent;

    _onCustomToolTipEvent: TCustomToolTipEvent;

    procedure OnCustomHintTimer(Sender: TObject);

    procedure DoHintChange(DoShow: Boolean);

  protected
    _vertScrollBar: TSmallScrollBar;
    _horzScrollBar: TSmallScrollBar;

    _content: TControl;
    _updateCount: Integer;

    _realignContentTime: Int64;
    _paintTime: Int64;

    _realignContentRequested: Boolean;

    _onViewPortPositionChanged: TOnViewportPositionChange;
    _lastContentBottomRight: TPointF;

    _prevRealignTime: Integer;

    _realignStopwatch: TStopwatch;
//    _tickAtStart: Integer;

    {$IFDEF DEBUG}
    _debugCheck: Boolean;
    {$ENDIF}

    procedure RealignContentStart; virtual;
    procedure BeforeRealignContent; virtual;
    procedure RealignContent; virtual;
    procedure AfterRealignContent; virtual;
    procedure RealignFinished; virtual;

    procedure DoRealignContent; virtual;
    function  RealignedButNotPainted: Boolean; virtual;
    procedure BeforePainting; virtual;

    procedure SetBasicVertScrollBarValues; virtual;
    procedure SetBasicHorzScrollBarValues; virtual;

    procedure CalculateScrollBarMax; virtual; abstract;
    procedure ScrollManualInstant(YChange: Integer); virtual;
    procedure ScrollManualTryAnimated;

    procedure UpdateScrollbarMargins;
    function  ScrollingWasActivePreviousRealign: Boolean;

    procedure StartScrolling;
    procedure StopScrolling;

    function  IsScrolling: Boolean; virtual;
    function  IsFastScrolling(ScrollbarOnly: Boolean = False): Boolean; virtual;

  protected
    _logs: TStringList;
    class var _logIx: Integer;
    procedure Log(const Message: CString);
  public
    procedure SaveLog;

  protected
    procedure OnContentResized(Sender: TObject);
    procedure DoContentResized(WidthChanged, HeightChanged: Boolean); virtual;

    function  CanRealignContent: Boolean; virtual;
    function  RealignContentRequested: Boolean; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  IsInitialized: Boolean;
    procedure RequestRealignContent;

    procedure ForceImmeditiateRealignContent;

    procedure Painting; override;
    procedure Paint; override;
    procedure PaintChildren; override;
    procedure PrepareForPaint; override;
    function  IsUpdating: Boolean; override;
    procedure RefreshControl(const DataChanged: Boolean = False); virtual;

    function  TryHandleKeyNavigation(var Key: Word; Shift: TShiftState): Boolean;

    property VertScrollBar: TSmallScrollBar read get_VertScrollBar;
    property Content: TControl read get_Content;
    property Control: TControl read get_Control;

  {$IFDEF DEBUG}
  protected
    _onLog: TDoLog;

  public
    procedure TurnWheel;
    property OnLog: TDoLog write _onLog;
  {$ENDIF}

  public
    // designer properties & events
    property OnViewPortPositionChanged: TOnViewportPositionChange read _onViewPortPositionChanged write _onViewPortPositionChanged;
    property OnCustomToolTipEvent: TCustomToolTipEvent read _onCustomToolTipEvent write _onCustomToolTipEvent;
    property OnStickyClick: TNotifyEvent read _onStickyClick write _onStickyClick;
  end;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.Math,
  {$ELSE}
  Wasm.System.Math,
  {$ENDIF}
  FMX.ControlCalculations, ADato.TraceEvents.intf;

{ TScrollControl }

constructor TScrollControl.Create(AOwner: TComponent);
begin
  inherited;
  _safeObj := TBaseInterfacedObject.Create;
  _realignState := TRealignState.Waiting;
  _realignContentRequested := True;

  {$IFDEF DEBUG}
  _debugCheck := True;
  {$ENDIF}

  Self.HitTest := True;
  Self.CanFocus := True;
//  Self.Fill.Color := TAlphaColors.Orange;
//  Self.Stroke.Color := TAlphaColors.Null;

  _vertScrollBar := TCustomSmallScrollBar.Create(Self);
  _vertScrollBar.Stored := False;
  _vertScrollBar.Orientation := TOrientation.Vertical;
  _vertScrollBar.Width := 10;
  _vertScrollBar.Align := TAlignLayout.Right;
  {$IFNDEF WEBASSEMBLY}
  _vertScrollBar.OnChange := OnScrollBarChange;
  {$ELSE}
  _vertScrollBar.OnChange := @OnScrollBarChange;
  {$ENDIF}
  _vertScrollBar.SmallChange := 23; // same as Delphi under windows
  _vertScrollBar.Visible := False;
  Self.AddObject(_vertScrollBar);

  _horzScrollBar := TCustomSmallScrollBar.Create(Self);
  _horzScrollBar.Stored := False;
  _horzScrollBar.Orientation := TOrientation.Horizontal;
  _horzScrollBar.Height := 10;
  _horzScrollBar.Align := TAlignLayout.Bottom;
  _horzScrollBar.Margins.Right := _vertScrollBar.Width;
  {$IFNDEF WEBASSEMBLY}
  _horzScrollBar.OnChange := OnHorzScrollBarChange;
  {$ELSE}
  _horzScrollBar.OnChange := @OnHorzScrollBarChange;
  {$ENDIF}
  _horzScrollBar.Visible := False;
  Self.AddObject(_horzScrollBar);

  _content := TLayout.Create(Self);
  _content.Stored := False;
  _content.Align := TAlignLayout.Client;
  _content.ClipChildren := True;

  {$IFNDEF WEBASSEMBLY}
  _content.OnResized := OnContentResized;
  {$ELSE}
  _content.OnResized := @OnContentResized;
  {$ENDIF}
  Self.AddObject(_content);

  SetBasicVertScrollBarValues;
  SetBasicHorzScrollBarValues;

  _scrollStopWatch_scrollbar := TStopwatch.Create;
  _scrollStopWatch_mouse := TStopwatch.Create;

  _checkWaitForRealignTimer := TTimer.Create(Self);
  _checkWaitForRealignTimer.Stored := False;
  _checkWaitForRealignTimer.Interval := 500;
  {$IFNDEF WEBASSEMBLY}
  _checkWaitForRealignTimer.OnTimer := WaitForRealignEndedWithoutAnotherScrollTimer;
  {$ELSE}
  _checkWaitForRealignTimer.OnTimer := @WaitForRealignEndedWithoutAnotherScrollTimer;
  {$ENDIF}
  _checkWaitForRealignTimer.Enabled := False;

  _mouseWheelSmoothScrollTimer := TTimer.Create(Self);
  _mouseWheelSmoothScrollTimer.Stored := False;
  {$IFNDEF WEBASSEMBLY}
  _mouseWheelSmoothScrollTimer.OnTimer := MouseWheelSmoothScrollingTimer;
  {$ELSE}
  _mouseWheelSmoothScrollTimer.OnTimer := @MouseWheelSmoothScrollingTimer;
  {$ENDIF}
  _mouseWheelSmoothScrollTimer.Interval := 16;
  _mouseWheelSmoothScrollTimer.Enabled := False;
  _scrollTau := 0.12;

  _customHintTimer := TTimer.Create(Self);
  _customHintTimer.Stored := False;
  {$IFNDEF WEBASSEMBLY}
  _customHintTimer.OnTimer := OnCustomHintTimer;
  {$ELSE}
  _customHintTimer.OnTimer := @OnCustomHintTimer;
  {$ENDIF}
  _customHintTimer.Interval := 500;
  _customHintTimer.Enabled := False;

  SetLength(_mouseRollingLastPoints, 3);
  SetLength(_mouseRollingLastTicks, 3);
  UpdateMouseScrollingLastMoves(True, TPointF.Zero);
end;

destructor TScrollControl.Destroy;
begin
  _safeObj := nil;

  FreeAndNil(_mouseWheelSmoothScrollTimer);
  FreeAndNil(_checkWaitForRealignTimer);

  inherited;
end;

procedure TScrollControl.AfterRealignContent;
begin
  _realignState := TRealignState.AfterRealign;

  CalculateScrollBarMax;
  UpdateScrollbarMargins;
end;

procedure TScrollControl.AfterScrolling;
begin
  _scrollingType := TScrollingType.None;

  var wasEnabled := _checkWaitForRealignTimer.Enabled and (_timerDoRealignRefreshInterval > 0);
  _timerDoRealignRefreshInterval := 0;
  _checkWaitForRealignTimer.Enabled := False;

  if wasEnabled then
    RefreshControl;
end;

procedure TScrollControl.BeforePainting;
begin
  if RealignContentRequested and CanRealignContent then
  begin
    SetBasicVertScrollBarValues;
    DoRealignContent;
  end;
end;

procedure TScrollControl.BeforeRealignContent;
begin
  _realignState := TRealignState.BeforeRealign;

//  CalculateScrollBarMax;
//  UpdateScrollbarMargins;
end;

function TScrollControl.CanRealignContent: Boolean;
begin
  Result := (_updateCount = 0);
end;

function TScrollControl.CanRealignScrollCheck(ForceOnScrollbarEnds: Boolean = False): Boolean;
begin
  Result := (not IsFastScrolling(False) or (_paintTime <> -1)) and (not _scrollStopWatch_scrollbar.IsRunning or (_scrollStopWatch_scrollbar.ElapsedMilliseconds > RealignContentTime));

  if not Result and ForceOnScrollbarEnds then
  begin
    if (_vertScrollBar.Value = 0) or (_vertScrollBar.Value > _vertScrollBar.Max - _vertScrollBar.ViewportSize - 10) then
      Exit(True);
  end;
end;

procedure TScrollControl.WaitForRealignEndedWithoutAnotherScrollTimer(Sender: TObject);
begin
  // To improve performance (A LOT) we have to check => _scrollStopWatch_scrollbar.ElapsedMilliseconds < _realignContentTime*1.1
  // but if no other scrollaction is coming when this check returns False
  // we have to make sure that the scrolling is done anyway

  if (_vertScrollBar as TCustomSmallScrollBar).IsTracking then
  begin
    // still scrolling, so nothing to do now
    if _timerDoRealignWhenScrollingStopped then
      Exit;

    _scrollingType := TScrollingType.WithScrollBar;
  end else
  begin
    // still scrolling, so nothing to do now
    if _timerDoRealignWhenScrollingStopped and (Abs(_scrollDistanceToGo) > 0.5) then
    begin
      if not _scrollAnimClock.IsRunning then
        _scrollAnimClock := TStopwatch.StartNew;

      _mouseWheelSmoothScrollTimer.Enabled := True;
      Exit;
    end;

    AfterScrolling;
    Exit;
  end;

  _checkWaitForRealignTimer.Enabled := False;
  _timerDoRealignRefreshInterval := 0;
  _timerDoRealignWhenScrollingStopped := False;

  DoRealignContent;

  RestartWaitForRealignTimer(True);
  TryStartWaitForRealignTimer;
end;

procedure TScrollControl.TryStartWaitForRealignTimer;
begin
  if _timerDoRealignRefreshInterval > 0 then
  begin
    _checkWaitForRealignTimer.Interval := _timerDoRealignRefreshInterval;
    _checkWaitForRealignTimer.Enabled := False;
    _checkWaitForRealignTimer.Enabled := True;
  end;
end;

procedure TScrollControl.DoContentResized(WidthChanged, HeightChanged: Boolean);
begin
  if WidthChanged then
    SetBasicHorzScrollBarValues;

  if HeightChanged then
    SetBasicVertScrollBarValues;

  // the method AfterRealign must be executed
  // but if not painted yet it will get there on it's own..
  if (WidthChanged or HeightChanged) and (_realignState in [TRealignState.AfterRealign, TRealignState.RealignDone]) then
  begin
    _timerDoRealignRefreshInterval := 1;
    TryStartWaitForRealignTimer;
  end;

  _lastContentBottomRight := PointF(_content.Width, _content.Height);
end;

procedure TScrollControl.DoHorzScrollBarChanged;
begin

end;

procedure TScrollControl.DoMouseLeave;
begin
  _clickEnable := False;
  _customHintTimer.Enabled := False;
  _mouseIsSticking := False;
  _lastMousePos := TPointF.Zero;
  DoHintChange(False);

  inherited;

  TryExecuteMouseScrollBoostOnMouseEventStopped;
end;

procedure TScrollControl.DoRealignContent;
begin
  if not (_realignState in [TRealignState.Waiting, TRealignState.RealignDone]) then
    Exit;

  if not CanRealignContent or not ControlEffectiveVisible(Self) then
  begin
    _realignContentRequested := True;
    Exit;
  end;

  RealignContentStart;      // timeless 1/40
  try
    BeforeRealignContent;   // timeless 1/40
    RealignContent;         // costs 15/40
    AfterRealignContent;    // costs 5/40
  finally
    RealignFinished;        // immens 20/40
  end;

  _scrollStopWatch_scrollbar := TStopwatch.StartNew;
end;

procedure TScrollControl.DoViewPortPositionChanged;
begin
  var newViewPointPos := GetViewPortPosition;
  if Assigned(_onViewPortPositionChanged) then
    _onViewPortPositionChanged(Self, _oldViewPortPos, newViewPointPos, False);

//  if (Round(_vertScrollBar.Value) mod 78 = 0) then
//    _oldViewPortPos := newViewPointPos else
    _oldViewPortPos := newViewPointPos;
end;

procedure TScrollControl.ForceImmeditiateRealignContent;
begin
  BeforePainting;
end;

function TScrollControl.GetViewPortPosition: TPointF;
begin
  var horzScrollBarPos := 0.0;
  if _horzScrollBar.Visible then
    horzScrollBarPos := _horzScrollBar.Value;

  var vertScrollBarPos := 0.0;
  if _vertScrollBar.Visible then
    vertScrollBarPos := _vertScrollBar.Value;

  Result := PointF(horzScrollBarPos, vertScrollBarPos);
end;

function TScrollControl.get_Content: TControl;
begin
  Result := _content;
end;

function TScrollControl.get_Control: TControl;
begin
  Result := Self;
end;

function TScrollControl.get_VertScrollBar: TSmallScrollBar;
begin
  Result := _vertScrollBar;
end;

procedure TScrollControl.StartScrolling;
begin
  Assert(_scrollingType = TScrollingType.None);
  _scrollingType := TScrollingType.Other;
end;

procedure TScrollControl.StopScrolling;
begin
  _scrollingType := TScrollingType.None;
end;

procedure TScrollControl.StopWaitForRealignTimer;
begin
  _checkWaitForRealignTimer.Enabled := False;
end;

function TScrollControl.IsFastScrolling(ScrollbarOnly: Boolean = False): Boolean;
begin
  if not IsScrolling then
    Exit(False);

  // check scrollbar change
  if (_scrollingType = TScrollingType.WithScrollBar) then
    Exit(ScrollingWasActivePreviousRealign);

  if ScrollbarOnly then
    Exit(False);

  // Wheel or finger fling still moving quickly. The slow tail is not "fast":
  // that last part should realign at full quality.
  if _mouseWheelSmoothScrollTimer.Enabled or (Abs(_scrollDistanceToGo) > 1) then
  begin
    var tau := _scrollTau;
    if tau < 0.04 then
      tau := 0.12;

    if (Abs(_scrollDistanceToGo) / tau) > 900 then
      Exit(True);

    if _scrollStopWatch_wheel_lastSpin.IsRunning and (_scrollStopWatch_wheel_lastSpin.ElapsedMilliseconds < 200) then
      Exit(True);
  end;

  Result := False;
end;

function TScrollControl.IsInitialized: Boolean;
begin
  Result := _realignState <> TRealignState.Waiting;
end;

function TScrollControl.IsScrolling: Boolean;
begin
  Result := _scrollingType <> TScrollingType.None;
end;

function TScrollControl.MouseScrollingBoostDistance: Single;
begin
  // Pixels per second of the finger. Positive means the finger moved down.
  Result := 0;

  if _mouseRollingSampleCount < 2 then
    Exit;

  var newest := _mouseRollingSampleCount - 1;
  var oldest := newest - 1;

  // Prefer a window of about 80ms so a slow start doesn't dilute a fast release.
  var ix: Integer;
  for ix := newest - 1 downto 0 do
  begin
    if (_mouseRollingLastTicks[newest] - _mouseRollingLastTicks[ix]) > 80 then
      Break;

    oldest := ix;
  end;

  var dtMs := _mouseRollingLastTicks[newest] - _mouseRollingLastTicks[oldest];
  if dtMs < 8 then
    Exit;

  Result := ((_mouseRollingLastPoints[newest].Y - _mouseRollingLastPoints[oldest].Y) / dtMs) * 1000;
end;

function TScrollControl.IsUpdating: Boolean;
begin
  Result := inherited or ((_content <> nil) and _content.IsUpdating);
end;

procedure TScrollControl.Log(const Message: CString);
begin
  {$IFDEF DEBUG}
  if _logs = nil then
    _logs := TStringList.Create;

  _logs.Add(Self.Name + ': ' + Message);

  if Assigned(_onLog) then
    _onLog(Self.Name + ': ' + Message);
  {$ENDIF}
end;

procedure TScrollControl.UpdateMouseScrollingLastMoves(Reset: Boolean; LastPoint: TPointF);
begin
  if Reset then
  begin
    _mouseRollingSampleCount := 0;
    Exit;
  end;

  var tick := _scrollStopWatch_mouse.ElapsedMilliseconds;

  if _mouseRollingSampleCount < Length(_mouseRollingLastPoints) then
  begin
    _mouseRollingLastPoints[_mouseRollingSampleCount] := LastPoint;
    _mouseRollingLastTicks[_mouseRollingSampleCount] := tick;
    Inc(_mouseRollingSampleCount);
    Exit;
  end;

  _mouseRollingLastPoints[0] := _mouseRollingLastPoints[1];
  _mouseRollingLastPoints[1] := _mouseRollingLastPoints[2];
  _mouseRollingLastTicks[0] := _mouseRollingLastTicks[1];
  _mouseRollingLastTicks[1] := _mouseRollingLastTicks[2];
  _mouseRollingLastPoints[2] := LastPoint;
  _mouseRollingLastTicks[2] := tick;
end;

procedure TScrollControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
  begin
    if Button = TMouseButton.mbRight then
      HandleRightClick(Shift, X, Y);

    Exit;
  end;

  _clickEnable := True;

  _controlWasFocusedBeforeMouseDown := FIsFocused;

  // A finger down grabs the content. The coast stops, otherwise it fights the drag.
  StopSmoothScroll(False);

  inherited;

  _mousePositionOnMouseDown := PointF(X, Y - _content.Position.Y);
  _scrollbarPositionsOnMouseDown := GetViewPortPosition;

  if _scrollStopWatch_mouse.IsRunning then
    _scrollStopWatch_mouse.Reset;

  _scrollStopWatch_mouse.Start;

  if _scrollStopWatch_mouse_lastMove.IsRunning then
    _scrollStopWatch_mouse_lastMove.Reset;

  UpdateMouseScrollingLastMoves(True, PointF(X, Y));
  UpdateMouseScrollingLastMoves(False, PointF(X, Y));
end;

function TScrollControl.MouseIsDown: Boolean;
begin
  Result := _clickEnable;
end;

procedure TScrollControl.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  _lastMousePos := PointF(X, Y);

  _mouseIsSticking := False;

  if not IsScrolling then
  begin
    _customHintTimer.Enabled := False;
    _customHintTimer.Enabled := True;

    DoHintChange(True);
  end else
    DoHintChange(False {hide if visible} );

  if not _clickEnable then
    Exit;

  inherited;

  // no mouse down is detected
  if not _scrollStopWatch_mouse.IsRunning then
    Exit;

  if _vertScrollBar.Visible then
  begin
    UpdateMouseScrollingLastMoves(False, PointF(X, Y));

    var yDiffSinceLastMove := ((Y - _content.Position.Y) - _mousePositionOnMouseDown.Y);
    var yAlreadyMovedSinceMouseDown := _scrollbarPositionsOnMouseDown.Y - _vertScrollBar.Value;

    _scrollStopWatch_mouse_lastMove := TStopwatch.StartNew;

    if (yDiffSinceLastMove < -1) or (yDiffSinceLastMove > 1) then
    begin
      var yDiff := Round(yDiffSinceLastMove - yAlreadyMovedSinceMouseDown);

      if not IsScrolling then
        _scrollingType := TScrollingType.Other;

      ScrollManualInstant(yDiff);
    end;
  end;
end;

procedure TScrollControl.HandleRightClick(Shift: TShiftState; X, Y: Single);
begin
// not working, popupmenu is called without calling mousedown / mouseup.
  // PopupMenu is already shown by FMX. Treat a right-click as a click
  // so descendants can update the current row before the menu is used.
//  UserClicked(TMouseButton.mbRight, Shift, X, Y - _content.Position.Y);
end;

procedure TScrollControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if not _clickEnable then
    Exit;

  try
    inherited;

    var doMouseClick := True;
    if _vertScrollBar.Visible then
      doMouseClick := not TryExecuteMouseScrollBoostOnMouseEventStopped;

    if doMouseClick then
    begin
      var distance := _mousePositionOnMouseDown.Distance(PointF(X, Y - _content.Position.Y));
      doMouseClick := distance < 5;
    end;

    // determine the mouseUp as a click event
    if doMouseClick then
    begin
      UserClicked(Button, Shift, X, Y - _content.Position.Y);

      if Assigned(_onStickyClick) then
        _onStickyClick(Self);
    end;

    if _scrollStopWatch_mouse.IsRunning then
      _scrollStopWatch_mouse.Reset;
  finally
    _clickEnable := False;
  end;
end;

procedure TScrollControl.StopSmoothScroll(const FinishScrolling: Boolean);
begin
  _mouseWheelSmoothScrollTimer.Enabled := False;
  _scrollDistanceToGo := 0;
  _scrollSubPixel := 0;
  _scrollAnimClock.Reset;

  if _scrollStopWatch_wheel_lastSpin.IsRunning then
    _scrollStopWatch_wheel_lastSpin.Reset;

  if FinishScrolling and IsScrolling and not MouseIsDown then
    AfterScrolling;
end;

procedure TScrollControl.AddSmoothScrollDistance(const DistancePx, Tau: Single);
begin
  if (_scrollingType = TScrollingType.WithScrollBar) or (Abs(DistancePx) < 0.01) then
    Exit;

  // A direction change drops the old coast. Stacking against it feels sticky.
  if (_scrollDistanceToGo <> 0) and ((_scrollDistanceToGo > 0) <> (DistancePx > 0)) then
  begin
    _scrollDistanceToGo := 0;
    _scrollSubPixel := 0;
  end;

  _scrollDistanceToGo := _scrollDistanceToGo + DistancePx;
  _scrollTau := Tau;

  // Caps the speed, not the duration. The ease always settles in a few tau.
  var maxQueue := _content.Height * 3;
  if maxQueue < 360 then
    maxQueue := 360;

  if _scrollDistanceToGo > maxQueue then
    _scrollDistanceToGo := maxQueue
  else if _scrollDistanceToGo < -maxQueue then
    _scrollDistanceToGo := -maxQueue;

  if _scrollingType = TScrollingType.None then
    _scrollingType := TScrollingType.Other;

  if not _scrollAnimClock.IsRunning then
    _scrollAnimClock := TStopwatch.StartNew;

  _mouseWheelSmoothScrollTimer.Enabled := True;
end;

procedure TScrollControl.ApplySmoothScrollFrame(const DtSeconds: Single);

  function WheelInputIsArriving: Boolean;
  begin
    // Physical notches and trackpad packets arrive in bursts. Keep a fraction of a pixel
    // so the next packet adds to it, instead of rounding it away and ending the gesture.
    Result := _scrollStopWatch_wheel_lastSpin.IsRunning and (_scrollStopWatch_wheel_lastSpin.ElapsedMilliseconds < 90);
  end;

  procedure MovePixels(Pixels: Integer);
  begin
    if Pixels = 0 then
      Exit;

    _applyingSmoothScroll := True;
    try
      var oldVal := _vertScrollBar.Value;
      ScrollManualInstant(Pixels);
      if SameValue(oldVal, _vertScrollBar.Value, 0.5) then
        StopSmoothScroll(True);
    finally
      _applyingSmoothScroll := False;
    end;
  end;

begin
  var dt := DtSeconds;
  if dt < 0.001 then
    Exit;

  // A stalled frame must not teleport. 80ms is about five vsyncs.
  if dt > 0.08 then
    dt := 0.08;

  var pending := _scrollDistanceToGo + _scrollSubPixel;

  // Trunc never emits a leftover under 1px, so the timer would spin forever.
  // While the wheel is still sending, that leftover has to stay queued.
  if Abs(pending) < 1 then
  begin
    if WheelInputIsArriving then
      Exit;

    var rest := Round(pending);
    _scrollDistanceToGo := 0;
    _scrollSubPixel := 0;
    MovePixels(rest);

    if _mouseWheelSmoothScrollTimer.Enabled then
      StopSmoothScroll(True);

    Exit;
  end;

  var tau := _scrollTau;
  if tau < 0.04 then
    tau := 0.12;

  // Exponential ease: step = remaining * (1 - e^(-dt/tau)).
  // New wheel or fling distance extends "remaining", so the speed follows the input
  // and the release still coasts out. This is independent of the timer interval.
  var step := _scrollDistanceToGo * (1 - Exp(-dt / tau));
  _scrollDistanceToGo := _scrollDistanceToGo - step;
  _scrollSubPixel := _scrollSubPixel + step;

  var pixels := Trunc(_scrollSubPixel);
  _scrollSubPixel := _scrollSubPixel - pixels;
  if pixels = 0 then
    Exit;

  MovePixels(pixels);
end;

procedure TScrollControl.MouseRollingBoostTimer(Sender: TObject);
begin
  // Touch fling and mouse wheel share one clock.
  MouseWheelSmoothScrollingTimer(Sender);
end;

procedure TScrollControl.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
const
  WheelTau = 0.11;
  RowsPerNotch = 2;
  StandardNotch = 120;
begin
  inherited;

  if Handled or (_scrollingType = TScrollingType.WithScrollBar) or (WheelDelta = 0) then
    Exit;

  // The finger already owns the position. A wheel coast here would fight the drag.
  if MouseIsDown then
  begin
    Handled := True;
    Exit;
  end;

  var goUp := WheelDelta > 0;
  var scrollingIsDone := False;
  if goUp and SameValue(_vertScrollBar.Value, 0) then
    scrollingIsDone := True
  else if not goUp and SameValue(_vertScrollBar.Value + _vertScrollBar.ViewportSize, _vertScrollBar.Max) then
    scrollingIsDone := True;

  if scrollingIsDone then
  begin
    var queuedOpposite := (goUp and (_scrollDistanceToGo < 0)) or ((not goUp) and (_scrollDistanceToGo > 0));
    if not queuedOpposite then
      StopSmoothScroll(True);

    Exit;
  end;

  Handled := True;

  if not CanRealignContent then
    Exit;

  // One notch (WheelDelta 120) travels the same 2 rows as before.
  // Smaller deltas (trackpad, smooth wheel) scale with that, instead of each counting as a full notch.
  var scrollDown := WheelDelta < 0;
  var pixels := DefaultMoveDistance(scrollDown, RowsPerNotch) * (Abs(WheelDelta) / StandardNotch);
  if scrollDown then
    pixels := -pixels;

  var timerWasRunning := _mouseWheelSmoothScrollTimer.Enabled;
  AddSmoothScrollDistance(pixels, WheelTau);
  _scrollStopWatch_wheel_lastSpin := TStopwatch.StartNew;

  // Distance is queued before the first realign. Realign sets _paintTime to -1,
  // and doing that first used to make CanRealignScrollCheck reject the rest of the gesture.
  if (not timerWasRunning) and CanRealignScrollCheck then
  begin
    ApplySmoothScrollFrame(1 / 60);
    if _mouseWheelSmoothScrollTimer.Enabled then
      _scrollAnimClock := TStopwatch.StartNew;
  end;
end;

procedure TScrollControl.MouseWheelSmoothScrollingTimer(Sender: TObject);
begin
  if _scrollingType = TScrollingType.WithScrollBar then
  begin
    StopSmoothScroll(False);
    Exit;
  end;

  if (Abs(_scrollDistanceToGo) < 0.01) and (Abs(_scrollSubPixel) < 0.01) then
  begin
    StopSmoothScroll(True);
    Exit;
  end;

  if not _scrollAnimClock.IsRunning then
  begin
    _scrollAnimClock := TStopwatch.StartNew;
    Exit;
  end;

  var dtMs := _scrollAnimClock.ElapsedMilliseconds;
  if dtMs < 8 then
    Exit;

  // While a realign is still on screen, wait. After 250ms apply anyway so a missed paint cannot freeze the coast.
  if not CanRealignScrollCheck then
  begin
    if _scrollStopWatch_scrollbar.IsRunning and (_scrollStopWatch_scrollbar.ElapsedMilliseconds < 250) then
      Exit;
  end;

  var dt: Single := dtMs / 1000;
  _scrollAnimClock := TStopwatch.StartNew;
  ApplySmoothScrollFrame(dt);
end;

procedure TScrollControl.OnContentResized(Sender: TObject);
begin
  if _updateCount > 0 then
    Exit;

  var widthChanged := not SameValue(_lastContentBottomRight.X, _content.Width);
  var heightChanged := not SameValue(_lastContentBottomRight.Y, _content.Height);

  // in case header is removed and added.. Nothing actually changed..
  if not widthChanged and not heightChanged then
    Exit;

  DoContentResized(widthChanged, heightChanged);
end;

procedure TScrollControl.DoHintChange(DoShow: Boolean);
begin
  if not _customHintShowing and not DoShow then
    Exit;

  if Assigned(_onCustomToolTipEvent) then
  begin
    var args := TDCHintEventArgs.Create(DoShow, _lastMousePos, _customHintShowing, _mouseIsSticking);
    try
      _onCustomToolTipEvent(Self, args);
      _customHintShowing := args.ShowCustomHint;
    finally
      args.Free;
    end;
  end;
end;

procedure TScrollControl.OnCustomHintTimer(Sender: TObject);
begin
  _customHintTimer.Enabled := False;
//  if not IsMouseOver then
//    Exit;  // already at mouseLeave fired

  _mouseIsSticking := True;
  DoHintChange(True);
end;

procedure TScrollControl.OnHorzScrollBarChange(Sender: TObject);
begin
  DoViewPortPositionChanged;

  if (_scrollUpdateCount <> 0) or _realignContentRequested then
    Exit;

  DoHorzScrollBarChanged;
end;

procedure TScrollControl.OnScrollBarChange(Sender: TObject);
begin
  DoViewPortPositionChanged;

  if _scrollUpdateCount <> 0 then
    Exit;

  // The user grabbed the bar. A running coast would fight that drag.
  if (_vertScrollBar as TCustomSmallScrollBar).IsTracking then
    StopSmoothScroll(False);

  if CanRealignScrollCheck(True {force realign at scrollbar ends}) then
  begin
    _scrollingType := TScrollingType.WithScrollBar;
    DoRealignContent;
  end;

  RestartWaitForRealignTimer;
  TryStartWaitForRealignTimer;
end;

procedure TScrollControl.Paint;
begin
  // Paint itself won't cost any millisecond..
  inherited;
  if _paintTime = -1 then
    _paintTime := 0;
end;

procedure TScrollControl.PaintChildren;
begin
  var stopwatch := TStopwatch.StartNew;

  inherited;

  stopwatch.Stop;
  _paintTime := stopwatch.ElapsedMilliseconds;
end;

procedure SafeForceQueue([weak] IsAlive: IBaseInterface; Captured: Exception);
begin
  TThread.ForceQueue(nil, procedure
  begin
    if IsAlive = nil then
    begin
      Captured.Free;
      Exit;
    end;

    raise Captured;
  end);
end;

procedure TScrollControl.Painting;
begin
  try
    BeforePainting;
  except
    SafeForceQueue(_safeObj, Exception(AcquireExceptionObject));
  end;

  inherited;
end;

procedure TScrollControl.PrepareForPaint;
begin
  try
    BeforePainting;
  except
    SafeForceQueue(_safeObj, Exception(AcquireExceptionObject));
  end;

  inherited;
end;

procedure TScrollControl.RealignContent;
begin
  _realignState := TRealignState.Realigning;
end;

function TScrollControl.RealignContentTime: Integer;
begin
  // try to keep it stable
  Result := CMath.Max(CMath.Min(500, Round((_realignContentTime+_paintTime) * 1.1)), 10);
end;

function TScrollControl.RealignedButNotPainted: Boolean;
begin
  Result := _paintTime = -1;
end;

procedure TScrollControl.RealignContentStart;
begin
  {$IFNDEF WEBASSEMBLY}
  if not _realignStopwatch.IsRunning then
    _realignStopwatch := TStopwatch.StartNew;
  {$ENDIF}

  _paintTime := -1;
  _realignContentRequested := False;

//  BeginUpdate;
end;

procedure TScrollControl.RealignFinished;
begin
  _realignState := TRealignState.RealignDone;
//  EndUpdate; // will actually cost a lot when scrolling..

//  _tickAtStart := 0;

  TryStartWaitForRealignTimer;

  {$IFNDEF WEBASSEMBLY}
  _realignStopwatch.Stop;
  _realignContentTime := _realignStopwatch.ElapsedMilliseconds;
  {$ENDIF}

  if _scrollingType <> TScrollingType.None then
    _prevRealignTime := Environment.TickCount;
end;

procedure TScrollControl.RefreshControl(const DataChanged: Boolean = False);
begin
  if CanRealignContent then
    _realignState := TRealignState.Waiting;

  RequestRealignContent;
end;

procedure TScrollControl.SaveLog;
begin
  {$IFDEF DEBUG}
  {$IFNDEF WEBASSEMBLY}
  if _logs <> nil then
  begin
    _logs.SaveToFile('d:\temp\treeinfo_' + _logIx.ToString + '.txt');
    FreeAndNil(_logs);
  end;
  {$ENDIF}
  {$ENDIF}
end;

function TScrollControl.ScrollingWasActivePreviousRealign: Boolean;
begin
  Result := _prevRealignTime > (Environment.TickCount - 250);
end;

procedure TScrollControl.ScrollManualInstant(YChange: Integer);
begin
  Assert(_scrollingType <> TScrollingType.WithScrollBar);

  // Drag and other instant moves cancel a coast. The animator itself is the exception:
  // it owns _scrollDistanceToGo and must not clear it by applying a frame.
  if not _applyingSmoothScroll then
  begin
    var cancelAnimation := _mouseWheelSmoothScrollTimer.Enabled or (Abs(_scrollDistanceToGo) > 0.01);
    if cancelAnimation then
    begin
      StopSmoothScroll(False);
      if not MouseIsDown and (_scrollingType = TScrollingType.Other) then
        _scrollingType := TScrollingType.None;
    end;
  end;

  if YChange <> 0 then
  begin
    inc(_scrollUpdateCount);
    try
      var oldVal := _vertScrollBar.Value;
      _vertScrollBar.Value := _vertScrollBar.Value - YChange;

      // in case the scroll Min/Max is hit
      if SameValue(oldVal, _vertScrollBar.Value, 0.5) then
      begin
        AfterScrolling;
        Exit;
      end;
    finally
      dec(_scrollUpdateCount);
    end;
  end;

  var needsScroll := not SameValue(YChange, 0) and not IsScrolling;
  if needsScroll then
    StartScrolling;
  try
    DoRealignContent;
  finally
    if needsScroll then
      StopScrolling;
  end;
end;

procedure TScrollControl.ScrollManualTryAnimated;
begin
  if (Abs(_scrollDistanceToGo) < 0.5) and (Abs(_scrollSubPixel) < 0.5) then
    Exit;

  var timerWasRunning := _mouseWheelSmoothScrollTimer.Enabled;
  if _scrollingType = TScrollingType.None then
    _scrollingType := TScrollingType.Other;

  if not _scrollAnimClock.IsRunning then
    _scrollAnimClock := TStopwatch.StartNew;

  _mouseWheelSmoothScrollTimer.Enabled := True;

  if (not timerWasRunning) and CanRealignScrollCheck then
  begin
    ApplySmoothScrollFrame(1 / 60);
    if _mouseWheelSmoothScrollTimer.Enabled then
      _scrollAnimClock := TStopwatch.StartNew;
  end;
end;

//function TScrollControl.VertScrollbarIsTracking: Boolean;
//begin
//  Result := (_vertScrollBar as TCustomSmallScrollBar).IsTracking;
//end;

procedure TScrollControl.SetBasicHorzScrollBarValues;
begin
  _horzScrollBar.Min := 0;
  _horzScrollBar.ViewportSize := _content.Width;
end;

procedure TScrollControl.SetBasicVertScrollBarValues;
begin
  _vertScrollBar.Min := 0;
  _vertScrollBar.ViewportSize := _content.Height;
end;

function TScrollControl.TryExecuteMouseScrollBoostOnMouseEventStopped: Boolean;
const
  TouchTau = 0.32;
  MinFlingSpeed = 160; // px/s, a slow release should stop with the finger
begin
  Result := False;

  if _scrollingType = TScrollingType.WithScrollBar then
    Exit;

  var pixelPerSecond := MouseScrollingBoostDistance;
  if (Abs(pixelPerSecond) >= MinFlingSpeed) and _scrollStopWatch_mouse.IsRunning and (_scrollStopWatch_mouse_lastMove.ElapsedMilliseconds < 150) then
  begin
    // Distance of an exponential coast equals speed * tau.
    AddSmoothScrollDistance(pixelPerSecond * TouchTau, TouchTau);
    Result := True;
  end;

  if _scrollStopWatch_mouse.IsRunning then
  begin
    _scrollStopWatch_mouse.Reset;
    if not _mouseWheelSmoothScrollTimer.Enabled and IsScrolling then
      AfterScrolling;
  end;
end;

function TScrollControl.TryHandleKeyNavigation(var Key: Word; Shift: TShiftState): Boolean;
begin
  var char: WideChar := ' ';
  KeyDown(key, char, Shift);
  Result := Key = 0;
end;

{$IFDEF DEBUG}
procedure TScrollControl.TurnWheel;
begin
  var Handled: Boolean := False;

  MouseWheel([], -120, Handled);
end;
{$ENDIF}

function TScrollControl.RealignContentRequested: Boolean;
begin
  Result := _realignContentRequested;
end;

procedure TScrollControl.RequestRealignContent;
begin
  _realignContentRequested := True;

  if CanRealignContent then
    Self.Repaint;
end;

procedure TScrollControl.RestartWaitForRealignTimer(OnlyForRealignWhenScrollingStopped: Boolean = False);
begin
  _timerDoRealignWhenScrollingStopped := _timerDoRealignWhenScrollingStopped or OnlyForRealignWhenScrollingStopped;
  _timerDoRealignRefreshInterval := CMath.Min(500, CMath.Max(10, (RealignContentTime*4)));
end;

procedure TScrollControl.UpdateScrollbarMargins;
begin
  if not _horzScrollBar.Visible then
    Exit;

  _horzScrollBar.Margins.Right := IfThen(_vertScrollBar.Visible, _vertScrollBar.Width, 0);
end;

{ TCustomSmallScrollBar }

function TCustomSmallScrollBar.IsTracking: Boolean;
begin
  Result := (Self.Track <> nil) and Self.Track.IsTracking;
end;

end.


