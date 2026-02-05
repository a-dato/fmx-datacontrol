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
    procedure RestartWaitForRealignTimer(DoWait: Boolean = False; OnlyForRealignWhenScrollingStopped: Boolean = False);

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
    _mouseRollingBoostTimer: TTimer;
    _mouseRollingBoostDistanceToGo: Integer;
    _mouseRollingLastPoints: array of TPointF;

    _mouseWheelDistanceToGo: Integer;
    _mouseWheelDistanceTotal: Integer;
    _mouseWheelSmoothScrollTimer: TTimer;

    _lastMouseWheel1, _lastMouseWheel2, _lastMouseWheel3: Integer;

    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

    procedure MouseRollingBoostTimer(Sender: TObject);

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
    _stopwatch: TStopwatch;
    _stopwatchPaint: TStopwatch;
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
    property Stopwatch: TStopwatch read _stopwatch;
    property StopwatchPaint: TStopwatch read _stopwatchPaint;
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
  FMX.ControlCalculations;

{ TScrollControl }

constructor TScrollControl.Create(AOwner: TComponent);
begin
  inherited;
  _safeObj := TBaseInterfacedObject.Create;
  _realignState := TRealignState.Waiting;
  _realignContentRequested := True;

  {$IFDEF DEBUG}
  _debugCheck := True;
  _stopwatch := TStopwatch.Create;
  _stopwatchPaint := TStopwatch.Create;
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

  _mouseRollingBoostTimer := TTimer.Create(Self);
  _mouseRollingBoostTimer.Stored := False;
  {$IFNDEF WEBASSEMBLY}
  _mouseRollingBoostTimer.OnTimer := MouseRollingBoostTimer;
  {$ELSE}
  _mouseRollingBoostTimer.OnTimer := @MouseRollingBoostTimer;
  {$ENDIF}
  _mouseRollingBoostTimer.Interval := 20;
  _mouseRollingBoostTimer.Enabled := False;
  Self.AddObject(_mouseRollingBoostTimer);

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
  _mouseWheelSmoothScrollTimer.Interval := 25;
  _mouseWheelSmoothScrollTimer.Enabled := False;

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
  UpdateMouseScrollingLastMoves(True, TPointF.Zero);
end;

destructor TScrollControl.Destroy;
begin
  _safeObj := nil;

  FreeAndNil(_mouseRollingBoostTimer);
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
  if _realignContentRequested and CanRealignContent then
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
  Result := (_paintTime <> -1) and (not _scrollStopWatch_scrollbar.IsRunning or (_scrollStopWatch_scrollbar.ElapsedMilliseconds > RealignContentTime));

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

  var restartAgain := False;
  if (_vertScrollBar as TCustomSmallScrollBar).IsTracking then
  begin
    // still scrolling, so nothing to do now
    if _timerDoRealignWhenScrollingStopped then
      Exit;

    _scrollingType := TScrollingType.WithScrollBar;
    restartAgain := True;
  end else
  begin
    if _scrollingType <> TScrollingType.Other then
      AfterScrolling;

    Exit;
  end;

  _checkWaitForRealignTimer.Enabled := False;
  _timerDoRealignRefreshInterval := 0;
  _timerDoRealignWhenScrollingStopped := False;

  DoRealignContent;

  if restartAgain then
  begin
    RestartWaitForRealignTimer(False, True);
    TryStartWaitForRealignTimer;
  end;
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

  // finger scroll change (only when boost is active)
  if _mouseRollingBoostTimer.Enabled then
    Exit(True);

  // check mouse wheel change
  if (_lastMouseWheel3 <> 0) {and (_lastMouseWheel3 > Environment.TickCount - 500)} then
  begin
//    if _tickAtStart = 0 then
//      _tickAtStart := Environment.TickCount;

    if _lastMouseWheel3 > _lastMouseWheel1 - 500 then
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
  var item: TPointF;
  for item in _mouseRollingLastPoints do
    if item.IsZero then
      Exit(0);

  var latestYChanges := _mouseRollingLastPoints[2].Y + _mouseRollingLastPoints[1].Y - (2*_mouseRollingLastPoints[0].Y);

  if (latestYChanges < -10) or (latestYChanges > 10) then
    Result := latestYChanges else
    Result := 0; // no mouse boost
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
  if Reset or LastPoint.IsZero then
  begin
    _mouseRollingLastPoints[0] := TPointF.Zero;
    _mouseRollingLastPoints[1] := TPointF.Zero;
  end else
  begin
    _mouseRollingLastPoints[0] := _mouseRollingLastPoints[1];
    _mouseRollingLastPoints[1] := _mouseRollingLastPoints[2];
  end;

  _mouseRollingLastPoints[2] := LastPoint;
end;

procedure TScrollControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  _clickEnable := True;

  inherited;

  _mouseRollingBoostTimer.Enabled := False;

  _mousePositionOnMouseDown := PointF(X, Y - _content.Position.Y);
  _scrollbarPositionsOnMouseDown := GetViewPortPosition;

  if _scrollStopWatch_mouse.IsRunning then
    _scrollStopWatch_mouse.Reset;

  _scrollStopWatch_mouse.Start;

  UpdateMouseScrollingLastMoves(True, PointF(X, Y));
end;

function TScrollControl.MouseIsDown: Boolean;
begin
  Result := _clickEnable;
end;

procedure TScrollControl.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  _lastMousePos := PointF(X, Y);

  _mouseIsSticking := False;
  _customHintTimer.Enabled := False;
  _customHintTimer.Enabled := True;

  DoHintChange(True);

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

procedure TScrollControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if not _clickEnable then Exit;

  try
    inherited;

    var doMouseClick := True;

    if _vertScrollBar.Visible then
      doMouseClick := not TryExecuteMouseScrollBoostOnMouseEventStopped;

    if doMouseClick then
      doMouseClick :=
        (X > _mousePositionOnMouseDown.X - 5) and (X < _mousePositionOnMouseDown.X + 5) and
        ((Y - _content.Position.Y) > _mousePositionOnMouseDown.Y - 5) and ((Y - _content.Position.Y) < _mousePositionOnMouseDown.Y + 5);

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

procedure TScrollControl.MouseRollingBoostTimer(Sender: TObject);
begin
  var scrollBy := Round(_mouseRollingBoostDistanceToGo * 0.1);
  if scrollBy < (_mouseRollingBoostDistanceToGo / 2) then
    scrollBy := _mouseRollingBoostDistanceToGo;

  _mouseRollingBoostDistanceToGo := _mouseRollingBoostDistanceToGo - scrollBy;

  if not IsScrolling then
    _scrollingType := TScrollingType.Other;

  var oldVal := _vertScrollbar.Value;
  ScrollManualInstant(scrollBy);
  if SameValue(_vertScrollbar.Value, oldVal, 0.5) then
    _mouseRollingBoostDistanceToGo := 0;

  if (_mouseRollingBoostDistanceToGo >= -5) and (_mouseRollingBoostDistanceToGo <= 5) then
  begin
    _mouseRollingBoostTimer.Enabled := False;
    AfterScrolling;
  end;
end;

procedure TScrollControl.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
const
  ScrollBigStepsDivider = 5;
  WheelDeltaDivider = 120;
begin
  inherited;

  if Handled or (_scrollingType = TScrollingType.WithScrollBar) then
    Exit;

  var goUp := WheelDelta > 0;
  var scrollingIsDone := False;
  if goUp and SameValue(_vertScrollBar.Value, 0) then
    scrollingIsDone := True
  else if not goUp and SameValue(_vertScrollBar.Value + _vertScrollBar.ViewportSize, _vertScrollBar.Max) then
    scrollingIsDone := True;

  if scrollingIsDone then
  begin
    if _scrollingType <> TScrollingType.None then
      AfterScrolling;

    Exit;
  end;

  Handled := True;

  var wasGoUp := _mouseWheelDistanceTotal > 0;
  if goUp <> wasGoUp then
  begin
    _mouseWheelDistanceToGo := 0;
    _mouseWheelDistanceTotal := 0;
  end;

  // how bigger this number, the more&longer the scrollcontrol keeps scrolling after mousewheel already stopped after a mousewheel boost
  var maxLeftToScroll := 200;
  var posIntToGo := IfThen(_mouseWheelDistanceToGo > 0, _mouseWheelDistanceToGo, -_mouseWheelDistanceToGo);
  var posWheelDelta := Round(IfThen(WheelDelta > 0, WheelDelta, -WheelDelta) * 1.0);
  var delta := CMath.Min(posWheelDelta, maxLeftToScroll - posIntToGo);

  if delta > 0 then
  begin
    if not goUp then
      delta := -delta;

    _mouseWheelDistanceToGo := _mouseWheelDistanceToGo + delta;
    _mouseWheelDistanceTotal := _mouseWheelDistanceTotal + delta;
  end;

  _lastMouseWheel3 := _lastMouseWheel2;
  _lastMouseWheel2 := _lastMouseWheel1;
  _lastMouseWheel1 := Environment.TickCount;

  if not CanRealignContent or not CanRealignScrollCheck then
    Exit;

  ScrollManualTryAnimated;
end;

procedure TScrollControl.MouseWheelSmoothScrollingTimer(Sender: TObject);

  procedure InternalOnScrollingEnded;
  begin
    _mouseWheelSmoothScrollTimer.Enabled := False;
    _mouseWheelDistanceToGo := 0;
    _mouseWheelDistanceTotal := 0;
    AfterScrolling;
  end;

begin
  if _scrollStopWatch_wheel_lastSpin.IsRunning then
  begin
    if (_scrollStopWatch_wheel_lastSpin.ElapsedMilliseconds > 250) then
    begin
      _mouseWheelSmoothScrollTimer.Enabled := False;
      _scrollStopWatch_wheel_lastSpin.Reset;
    end;

    exit;
  end;

  var wasAbove := _mouseWheelDistanceToGo > 0;

  var posIntTotal := IfThen(wasAbove, _mouseWheelDistanceTotal, -_mouseWheelDistanceTotal);
  var posIntToGo := IfThen(wasAbove, _mouseWheelDistanceToGo, -_mouseWheelDistanceToGo);

  var scrollSpeed := posIntTotal / 3.5;
  var scrollPart := Round(CMath.Min(scrollSpeed, posIntToGo * 0.7));

  // otherwise scrolling looks like its going backwards and too fast..
  if scrollPart > 75 then
    scrollPart := 75;

  if not wasAbove then
    scrollPart := -scrollPart;

  _mouseWheelDistanceToGo := _mouseWheelDistanceToGo - scrollPart;
  var isAbove := _mouseWheelDistanceToGo > 0;

  if (wasAbove <> isAbove) or ((_mouseWheelDistanceToGo > -1) and (_mouseWheelDistanceToGo < 1)) or SameValue(scrollPart, 0, 0.5) then
    InternalOnScrollingEnded
  else begin
    var oldVal := _vertScrollbar.Value;
    if not IsScrolling then
      _scrollingType := TScrollingType.Other;

    ScrollManualInstant(scrollPart);

    if SameValue(_vertScrollbar.Value, oldVal, 0.5) then
      InternalOnScrollingEnded;
  end;
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

procedure TScrollControl.Painting;
begin
  BeforePainting;
  inherited;
end;

procedure TScrollControl.PrepareForPaint;
begin
  BeforePainting;
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
  _mouseWheelSmoothScrollTimer.Enabled := False;

  if IsFastScrolling then
  begin
    ScrollManualInstant(_mouseWheelDistanceToGo);
    Exit;
  end;

  MouseWheelSmoothScrollingTimer(nil);
  _mouseWheelSmoothScrollTimer.Enabled := True;
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
begin
  Result := False;

  var pixelPerSecond := MouseScrollingBoostDistance;
  if not SameValue(pixelPerSecond, 0) and _scrollStopWatch_mouse.IsRunning and (_scrollStopWatch_mouse_lastMove.ElapsedMilliseconds < 150) then
  begin
    // give scrolling a boost after faste scroll
    _mouseRollingBoostDistanceToGo := Round(pixelPerSecond * 10);
    _mouseRollingBoostTimer.Enabled := True;

    Result := True;
  end;

  if _scrollStopWatch_mouse.IsRunning then
  begin
    _scrollStopWatch_mouse.Reset;
    if not _mouseRollingBoostTimer.Enabled and IsScrolling then
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

procedure TScrollControl.RequestRealignContent;
begin
  _realignContentRequested := True;

  if CanRealignContent then
    Self.Repaint;
end;

procedure TScrollControl.RestartWaitForRealignTimer(DoWait: Boolean = False; OnlyForRealignWhenScrollingStopped: Boolean = False);
begin
  _timerDoRealignWhenScrollingStopped := _timerDoRealignWhenScrollingStopped or OnlyForRealignWhenScrollingStopped;

  if DoWait then
    _timerDoRealignRefreshInterval := 500 else
    _timerDoRealignRefreshInterval := CMath.Min(500, CMath.Max(10, (RealignContentTime*3)));
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


