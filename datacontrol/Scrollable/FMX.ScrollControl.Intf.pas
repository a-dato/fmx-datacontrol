unit FMX.ScrollControl.Intf;

interface

uses
  System_, System.Types;

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

  TDCHintEventArgs = class(EventArgs)
  private
    LocalPoint: TPointF;
    MouseIsSticking: Boolean;
  public
    ShowCustomHint: Boolean;

    function GetLocalPoint: TPointF;
    function GetMouseIsSticking: Boolean;

    constructor Create(const ShowHint: Boolean; AtPoint: TPointF; AMouseIsSticking: Boolean);
  end;

  TCustomToolTipEvent = procedure(Sender: TObject; const HintEventArgs: TDCHintEventArgs) of object;

implementation

{ TDCHintEventArgs }

constructor TDCHintEventArgs.Create(const ShowHint: Boolean; AtPoint: TPointF; AMouseIsSticking: Boolean);
begin
  ShowCustomHint := ShowHint;
  LocalPoint := AtPoint;
  MouseIsSticking := AMouseIsSticking;
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


