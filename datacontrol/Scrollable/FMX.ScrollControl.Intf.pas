unit FMX.ScrollControl.Intf;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.Types,
  FMX.Controls,
  FMX.StdCtrls,
  {$ELSE}
  Wasm.System.Types,
  Wasm.FMX.Controls,
  Wasm.FMX.StdCtrls,
  {$ENDIF}
  System_, System.Collections;

type
  TScrollingType = (None, WithScrollBar, Other);
  TRealignState = (Waiting, BeforeRealign, Realigning, AfterRealign, RealignDone);

  TDoLog = procedure(const Message: CString) of object;
  TOnViewportPositionChange = procedure(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean) of object;
  TPointFArray = array of CDatetime;

  IRefreshControl = interface
    ['{601E6614-EED5-4ACF-8032-9971E71C8BA1}']
    function  IsInitialized: Boolean;
    procedure RefreshControl(const DataChanged: Boolean = False);
  end;

  IScrollControl = interface
    ['{601E6614-EED5-4ACF-8032-9971E71C8BA1}']
    function get_Content: TControl;
    function get_Control: TControl;
    function get_VertScrollBar: TSmallScrollBar;

    property Content: TControl read get_Content;
    property Control: TControl read get_Control;
    property VertScrollBar: TSmallScrollBar read get_VertScrollBar;
  end;

  TDCHintEventArgs = class(EventArgs)
  private
    LocalPoint: TPointF;
    MouseIsSticking: Boolean;
    WasShowing: Boolean;
  public
    ShowCustomHint: Boolean;

    function GetLocalPoint: TPointF;
    function GetMouseIsSticking: Boolean;
    function GetHintWasShowing: Boolean;

    constructor Create(const ShowHint: Boolean; AtPoint: TPointF; AWasShowing, AMouseIsSticking: Boolean);
  end;

  TCustomToolTipEvent = procedure(Sender: TObject; const HintEventArgs: TDCHintEventArgs) of object;

implementation

{ TDCHintEventArgs }

constructor TDCHintEventArgs.Create(const ShowHint: Boolean; AtPoint: TPointF; AWasShowing, AMouseIsSticking: Boolean);
begin
  ShowCustomHint := ShowHint;
  LocalPoint := AtPoint;
  MouseIsSticking := AMouseIsSticking;
  WasShowing := AWasShowing;
end;

function TDCHintEventArgs.GetHintWasShowing: Boolean;
begin
  Result := WasShowing;
end;

function TDCHintEventArgs.GetLocalPoint: TPointF;
begin
  Result := LocalPoint;
end;

function TDCHintEventArgs.GetMouseIsSticking: Boolean;
begin
  Result := MouseIsSticking;
end;

end.


