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
    procedure RestartWaitForRealignTimer(DoWait: Boolean = False; OnlyForRealignWhenScrollingStopped: Boolean = False);

  // scrolling events
  protected
    _scrollUpdateCount: Integer;
    _realignState: TRealignState;

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
    _mouseWheelCycle: Integer;
    _mouseWheelSmoothScrollTimer: TTimer;

    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;

    procedure MouseRollingBoostTimer(Sender: TObject);

    function  CanRealignScrollCheck(ForceOnScrollbarEnds: Boolean = False): Boolean;
    function  RealignContentTime: Integer;

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
    _customHintPos: TPointF;
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

    _totalDataHeight: Single;

    _realignContentTime: Int64;
    _paintTime: Int64;

    _realignContentRequested: Boolean;

    _scrollingType: TScrollingType;
    _onViewPortPositionChanged: TOnViewportPositionChange;
    _lastContentBottomRight: TPointF;

    _prevRealignTime: Integer;

    _realignStopwatch: TStopwatch;

    {$IFDEF DEBUG}
    _stopwatch0, _stopwatch1, _stopwatch2, _stopwatch3: TStopwatch;
    _debugCheck: Boolean;
    {$ENDIF}

    procedure RealignContentStart; virtual;
    procedure BeforeRealignContent; virtual;
    procedure RealignContent; virtual;
    procedure AfterRealignContent; virtual;
    procedure RealignFinished; virtual;

    procedure DoRealignContent; virtual;
    function  RealignedButNotPainted: Boolean;
    procedure BeforePainting; virtual;

    procedure SetBasicVertScrollBarValues; virtual;
    procedure SetBasicHorzScrollBarValues; virtual;

    procedure CalculateScrollBarMax; virtual; abstract;
    procedure ScrollManualInstant(YChange: Integer); virtual;
    procedure ScrollManualTryAnimated(YChange: Integer; CumulativeYChangeFromPrevChange: Boolean);

    procedure UpdateScrollbarMargins;
    function  ScrollingWasActivePreviousRealign: Boolean;

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
    function  IsUpdating: Boolean; override;
    procedure RefreshControl(const DataChanged: Boolean = False); virtual;

    function  TryHandleKeyNavigation(var Key: Word; Shift: TShiftState): Boolean;

    property VertScrollBar: TSmallScrollBar read get_VertScrollBar;
    property Content: TControl read get_Content;
    property Control: TControl read get_Control;

  published
    property OnViewPortPositionChanged: TOnViewportPositionChange read _onViewPortPositionChanged write _onViewPortPositionChanged;
    property OnCustomToolTipEvent: TCustomToolTipEvent read _onCustomToolTipEvent write _onCustomToolTipEvent;
    property OnStickyClick: TNotifyEvent read _onStickyClick write _onStickyClick;

  {$IFDEF DEBUG}
  protected
    _onLog: TDoLog;

  public
    procedure TurnWheel;
    property OnLog: TDoLog write _onLog;

  {$ENDIF}
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

  {$IFDEF DEBUG}
  _debugCheck := True;
//  _debugCheck := False;
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

  CalculateScrollBarMax;
  UpdateScrollbarMargins;
end;

function TScrollControl.CanRealignContent: Boolean;
begin
  Result := (_updateCount = 0);
end;

function TScrollControl.CanRealignScrollCheck(ForceOnScrollbarEnds: Boolean = False): Boolean;
begin
  Result := (_paintTime <> -1) and not _scrollStopWatch_scrollbar.IsRunning or (_scrollStopWatch_scrollbar.ElapsedMilliseconds > RealignContentTime);

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
    _scrollingType := TScrollingType.None;

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

  _realignContentRequested := False;

  RealignContentStart;
  try
    BeforeRealignContent;
    try
      RealignContent;
      AfterRealignContent;
    finally
      RealignFinished;
    end;
  finally
    _scrollingType := TScrollingType.None;
  end;

  _scrollStopWatch_scrollbar := TStopwatch.StartNew;
end;

procedure TScrollControl.DoViewPortPositionChanged;
begin
  var newViewPointPos := GetViewPortPosition;
  if Assigned(_onViewPortPositionChanged) then
    _onViewPortPositionChanged(Self, _oldViewPortPos, newViewPointPos, False);

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

function TScrollControl.IsInitialized: Boolean;
begin
  Result := _realignState <> TRealignState.Waiting;
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
  _customHintPos := PointF(X, Y);

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
      ScrollManualInstant(Round(yDiffSinceLastMove - yAlreadyMovedSinceMouseDown));
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

  ScrollManualInstant(scrollBy);

  if (_mouseRollingBoostDistanceToGo >= -5) and (_mouseRollingBoostDistanceToGo <= 5) then
    _mouseRollingBoostTimer.Enabled := False;
end;

procedure TScrollControl.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
const
  ScrollBigStepsDivider = 5;
  WheelDeltaDivider = 120;
begin
  inherited;

  if Handled or (_scrollingType <> TScrollingType.None) then
    Exit;

  var goUp := WheelDelta > 0;
  if goUp and SameValue(_vertScrollBar.Value, 0) then
    Exit
  else if not goUp and SameValue(_vertScrollBar.Value + _vertScrollBar.ViewportSize, _vertScrollBar.Max) then
    Exit;

  Handled := True;
  var scrollDIstance := ifThen(goUp, 1, -1) *Round(DefaultMoveDistance(not goUp, 3));
  if not CanRealignContent or not CanRealignScrollCheck then
  begin
    _mouseWheelDistanceToGo := _mouseWheelDistanceToGo + scrollDIstance;
    Exit;
  end;


//  ScrollManualTryAnimated(ifThen(goUp, 1, -1) * scrollDistance, _mouseWheelSmoothScrollTimer.Enabled);

//  if _mouseWheelDistanceToGo <> 0 then
//  begin
    ScrollManualInstant(_mouseWheelDistanceToGo + scrollDIstance);
    _mouseWheelDistanceToGo := 0;
//    _mouseWheelSmoothScrollTimer.Enabled := False;
//  end else
//    ScrollManualTryAnimated(scrollDistance, False)
end;

procedure TScrollControl.MouseWheelSmoothScrollingTimer(Sender: TObject);
begin
  inc(_mouseWheelCycle);

  if _scrollStopWatch_wheel_lastSpin.IsRunning then
  begin
    if (_scrollStopWatch_wheel_lastSpin.ElapsedMilliseconds > 250) then
    begin
      _mouseWheelSmoothScrollTimer.Enabled := False;
      _scrollStopWatch_wheel_lastSpin.Reset;
    end;

    exit;
  end;

// // start slow, go faster in the middle, end slow
//  var distancePart: Double;
//  distancePart := CMath.Min(_mouseWheelCycle * 0.09, 0.6);

  // scroll steady, with all done in 500 ms
  var distancePart := _mouseWheelCycle / (750/_mouseWheelSmoothScrollTimer.Interval);
  var scrollPart := Round(_mouseWheelDistanceToGo * distancePart);

  if (_mouseWheelDistanceToGo > -1) and (_mouseWheelDistanceToGo < 1) then
  begin
    ScrollManualInstant(_mouseWheelDistanceToGo);
    _mouseWheelSmoothScrollTimer.Enabled := False;
    Exit;
  end;

//  var scrollPart := Round(_mouseWheelDistanceToGo / ((350-(_mouseWheelCycle*_mouseWheelSmoothScrollTimer.Interval))/_mouseWheelSmoothScrollTimer.Interval));

  if scrollPart <> 0 then
  begin
    _mouseWheelDistanceToGo := _mouseWheelDistanceToGo - scrollPart;
    ScrollManualInstant(scrollPart);
  end
  else //if (scrollPart = 0) {or ((_mouseWheelDistanceToGo > -1) and (_mouseWheelDistanceToGo < 1)) ==> rounded scrollPart already does the trick} then
  begin
    ScrollManualInstant(_mouseWheelDistanceToGo);
    _mouseWheelSmoothScrollTimer.Enabled := False;
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
    var args := TDCHintEventArgs.Create(DoShow, _customHintPos, _customHintShowing, _mouseIsSticking);
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

  if _scrollUpdateCount <> 0 then
    Exit;

  DoHorzScrollBarChanged;
end;

procedure TScrollControl.OnScrollBarChange(Sender: TObject);
begin
  DoViewPortPositionChanged;

  Log('OnScrollBarChange val: ' + _vertScrollBar.Value.ToString);
  Log('OnScrollBarChange max: ' + _vertScrollBar.Max.ToString);

  if _scrollUpdateCount <> 0 then
    Exit;

  // only get's here when scrolling with scrollbar!
  // otherwise _scrollUpdateCount > 0

  if (_scrollingType = TScrollingType.None) and CanRealignScrollCheck(True {force realign at scrollbar ends}) then
  begin
    _scrollingType := TScrollingType.WithScrollBar;

    DoRealignContent;
  end;

  RestartWaitForRealignTimer;
  TryStartWaitForRealignTimer;
end;

procedure TScrollControl.Paint;
begin
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

procedure TScrollControl.RealignContent;
begin
  _realignState := TRealignState.Realigning;
end;

function TScrollControl.RealignContentTime: Integer;
begin
  Result := CMath.Min(500, Round((_realignContentTime+_paintTime) * 1.1));
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

  BeginUpdate;
  _totalDataHeight := _content.Height;
end;

procedure TScrollControl.RealignFinished;
begin
  _realignState := TRealignState.RealignDone;
  EndUpdate;

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
      if SameValue(oldVal, _vertScrollBar.Value) then
        Exit;
    finally
      dec(_scrollUpdateCount);
    end;
  end;

  if CanRealignScrollCheck then
  begin
    if not SameValue(YChange, 0) then
      _scrollingType := TScrollingType.Other;

    DoRealignContent;
  end else
  begin
    RestartWaitForRealignTimer;
    TryStartWaitForRealignTimer;
  end;
end;

procedure TScrollControl.ScrollManualTryAnimated(YChange: Integer; CumulativeYChangeFromPrevChange: Boolean);
begin
  if (_scrollingType <> TScrollingType.None) then
    Exit;

  if not CumulativeYChangeFromPrevChange then
  begin
    _mouseWheelDistanceToGo := 0;
    _mouseWheelCycle := 0;
  end;

//  var scrollDown := _mouseWheelDistanceToGo + YChange < 0;
  var oneRowHeight := IfThen(YChange < 0, -YChange, YChange);

  var tryGoImmediate: Boolean;
  var forceGoImmediate: Boolean;
  if YChange > 0 then
  begin
    forceGoImmediate := (_mouseWheelDistanceToGo + YChange > (oneRowHeight*1.5));
    tryGoImmediate := (_mouseWheelDistanceToGo < YChange) or (_mouseWheelDistanceToGo + YChange > oneRowHeight);
  end
  else
  begin
    forceGoImmediate := (_mouseWheelDistanceToGo + YChange < (-oneRowHeight*1.5));
    tryGoImmediate := (_mouseWheelDistanceToGo > YChange) or (_mouseWheelDistanceToGo + YChange < -oneRowHeight);
  end;

  {$IFDEF DEBUG}
//  forceGoImmediate := True;
  {$ENDIF}

  // stop smooth scrolling and go fast
  if forceGoImmediate or (_mouseWheelSmoothScrollTimer.Enabled and tryGoImmediate) then
  begin
    if CumulativeYChangeFromPrevChange then
      _mouseWheelDistanceToGo := _mouseWheelDistanceToGo + YChange else
      _mouseWheelDistanceToGo := YChange;

    _scrollStopWatch_wheel_lastSpin := TStopWatch.StartNew;

    ScrollManualInstant(_mouseWheelDistanceToGo);
    _mouseWheelDistanceToGo := 0;

    Exit;
  end;

  _mouseWheelDistanceToGo := _mouseWheelDistanceToGo + YChange;
  {$IFNDEF WEBASSEMBLY}
  _scrollStopWatch_wheel_lastSpin.Reset;
  {$ELSE}
//  try
//    _scrollStopWatch_wheel_lastSpin.Reset;
//  except
//    on e: Exception do
//    begin
//    end;
//  end;
  {$ENDIF}

  _mouseWheelSmoothScrollTimer.Enabled := True;
  MouseWheelSmoothScrollingTimer(nil);
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
    _scrollStopWatch_mouse.Reset
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
    _timerDoRealignRefreshInterval := CMath.Max(_checkWaitForRealignTimer.Interval, CMath.Min(500, CMath.Max(10, (RealignContentTime*3))));
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


