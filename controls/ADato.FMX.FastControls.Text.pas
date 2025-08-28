unit ADato.FMX.FastControls.Text;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Memo,
  FMX.Objects,
  FMX.Edit,
  FMX.ComboEdit,
  FMX.DateTimeCtrls,
  FMX.Graphics,
  System.Classes,
  System.UITypes,
  FMX.ActnList,
  FMX.ImgList,
  FMX.Types,
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Memo,
  Wasm.FMX.Objects,
  Wasm.FMX.Edit,
  Wasm.FMX.ComboEdit,
  Wasm.FMX.DateTimeCtrls,
  Wasm.FMX.Graphics,
  Wasm.System.Classes,
  Wasm.System.UITypes,
  Wasm.FMX.ActnList,
  Wasm.FMX.ImgList,
  Wasm.FMX.Types,
  {$ENDIF}
  System_,
  FMX.Layouts,
  FMX.TextLayout;

type
  TDateTimeEditOnKeyDownOverride = class(TDateEdit)
  protected
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  end;

  TFastTextX = class(TLayout, ICaption, ITextSettings)
  protected
    _text: string;
    _wordWrap: Boolean;
    _layout: TTextLayout;
    _settings: TTextSettings;
    _style: TStyledSettings;

    _recalcNeeded: Boolean;
    _waitingForRepaint: Boolean;

    // ICaption
    function  GetText: string;
    procedure SetText(const Value: string);
    function  TextStored: Boolean;

    // ITextSettings
    function  GetDefaultTextSettings: TTextSettings;
    function  GetTextSettings: TTextSettings;
    procedure SetTextSettings(const Value: TTextSettings);
    function  GetResultingTextSettings: TTextSettings;
    function  GetStyledSettings: TStyledSettings;
    procedure SetStyledSettings(const Value: TStyledSettings);

    procedure set_WordWrap(const Value: Boolean);

  protected
    procedure DoPaint; override;
    procedure ValidateCanvas;
    procedure RecalcNeeded;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function TextWidth: Single;
    function TextHeight: Single;

  published
    property Text: string read GetText write SetText;
    property WordWrap: Boolean read _wordWrap write set_WordWrap;

    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings;
  end;

  TFastText = class(TFastTextX);

//  TFastRectangleX = class(TLayout)
//  private
//    _sides: TSides;
//    _fillColor: TAlphaColor;
//    _strokeColor: TAlphaColor;
//    _strokeDash: TStrokeDash;
//
//  public
//    property Sides: TSides read _sides write _sides;
//    property FillColor: TAlphaColor read _fillColor write _fillColor;
//    property StrokeColor: TAlphaColor read _strokeColor write _strokeColor;
//    property StrokeDash: TStrokeDash read _strokeDash write _strokeDash;
//  end;
//
//  TFastRectangle = class(TRectangle);

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils
  {$ELSE}
  Wasm.System.SysUtils
  {$ENDIF}
  , System.Types;

{ TDateTimeEditOnKeyDownOverride }

procedure TDateTimeEditOnKeyDownOverride.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
begin
  // Send vkReturn to any listener!
  // Delphi's TDateEdit control passes vkReturn to the Observer only

  if (Key = vkReturn) and Assigned(OnKeyDown) then
    OnKeyDown(Self, Key, KeyChar, Shift);

  inherited;
end;

{ TFastTextX }

constructor TFastTextX.Create(AOwner: TComponent);
begin
  inherited;

  _layout := TTextLayoutManager.DefaultTextLayout.Create;
  _settings := TTextSettings.Create(Self);
end;

destructor TFastTextX.Destroy;
begin
  FreeAndNil(_layout);
  FreeAndNil(_settings);

  inherited;
end;

procedure TFastTextX.DoPaint;
begin
  _waitingForRepaint := False;

  inherited;

  ValidateCanvas;
  _layout.RenderLayout(Canvas);
end;

function TFastTextX.GetDefaultTextSettings: TTextSettings;
begin
  Result := _settings;
end;

function TFastTextX.GetResultingTextSettings: TTextSettings;
begin
  Result := _settings;
end;

function TFastTextX.GetStyledSettings: TStyledSettings;
begin
  Result := [];
end;

function TFastTextX.GetText: string;
begin
  Result := _text;
end;

function TFastTextX.GetTextSettings: TTextSettings;
begin
  Result := _settings;
end;

procedure TFastTextX.RecalcNeeded;
begin
  _recalcNeeded := True;
  if not FInPaintTo and not _waitingForRepaint then
  begin
    _waitingForRepaint := True;
    Repaint;
  end;
end;

procedure TFastTextX.ValidateCanvas;
begin
  if not _recalcNeeded then
    Exit;

//  Canvas.Font.Assign(_layout.Font);

  _layout.BeginUpdate;
  try
    _layout.Text := _text;
    _layout.LayoutCanvas := Self.Canvas;
    _layout.TopLeft := PointF(0,0);
    _layout.Opacity := AbsoluteOpacity;
    _layout.MaxSize := PointF(FSize.Width, FSize.Height);
    _layout.HorizontalAlign := TTextAlign.Leading;
    _layout.VerticalAlign := TTextAlign.Center;
    _layout.WordWrap := _wordWrap;

    _layout.Font := _settings.Font;
    _layout.Color := _settings.FontColor;
  finally
    _layout.EndUpdate;
  end;
end;

procedure TFastTextX.SetStyledSettings(const Value: TStyledSettings);
begin
end;

procedure TFastTextX.SetText(const Value: string);
begin
  if _text <> Value then
  begin
    _text := Value;
    RecalcNeeded;
  end;
end;

procedure TFastTextX.SetTextSettings(const Value: TTextSettings);
begin
  _settings := Value;
end;

procedure TFastTextX.set_WordWrap(const Value: Boolean);
begin
  if _wordWrap <> Value then
  begin
    _wordWrap := Value;
    RecalcNeeded;
  end;
end;

function TFastTextX.TextHeight: Single;
begin
  ValidateCanvas;
  Result := _layout.TextHeight;
end;

function TFastTextX.TextStored: Boolean;
begin
  Result := False;
end;

function TFastTextX.TextWidth: Single;
begin
  ValidateCanvas;
  Result := _layout.TextWidth;
end;

end.


