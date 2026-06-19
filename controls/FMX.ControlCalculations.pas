unit FMX.ControlCalculations;

interface

uses
  System_,
  {$IFNDEF WEBASSEMBLY}
  System.Types,
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Memo,
  FMX.Objects,
  FMX.Graphics,
  FMX.TextLayout,
  FMX.Layouts,
  FMX.Types,
  FMX.Forms,
  FMX.Ani
  {$ELSE}
  Wasm.System.Types,
  Wasm.FMX.Controls,
  Wasm.FMX.StdCtrls,
  Wasm.FMX.Memo,
  Wasm.FMX.Objects,
  Wasm.FMX.Graphics,
  Wasm.FMX.TextLayout,
  Wasm.FMX.Layouts,
  Wasm.FMX.Types,
  Wasm.FMX.Forms,
  Wasm.FMX.Ani
  {$ENDIF}
  ;

  function  TextControlWidth(const TextControl: TControl; const Settings: TTextSettings; const Text: String; MinWidth: Single = -1; MaxWidth: Single = -1; TextHeight: Single = -1): Single;
  function  TextControlHeight(const TextControl: TControl; const Settings: TTextSettings; const Text: String; MinHeight: Single = -1; MaxHeight: Single = -1; TextWidth: Single = -1): Single;
  function  MemoTextHeight(const Memo: TMemo; MinHeight: Single = -1; MaxHeight: Single = -1): Single;

  procedure ScrollControlInView(const Control: TControl; const ScrollBox: TCustomScrollBox; ControlMargin: Single = 10);

  procedure BeginDefaultTextLayout;
  procedure EndDefaultTextLayout;

  function  ActiveControl: TControl;
  function  ControlEffectiveVisible(Control: TControl): Boolean;
  function  ControlHasSelection(Control: TControl): Boolean;
  function  MouseInObject(AControl: TControl): Boolean;
  function  OwnerForm(AControl: TControl): TCustomForm;

  function  ProvideAnimation(const Control: TControl; const PropertyName: CString; const NewValue: Single; const Duration: Single = 0.22): TFloatAnimation;
  function  ProvideAnimationDelay(const Control: TControl; const PropertyName: CString; const NewValue: Single; const Delay: Single = 0.2; const Duration: Single = 0.22): TFloatAnimation;

var
  DefaultLayout: TTextLayout;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.Math
  {$ELSE}
  Wasm.System.Types,
  Wasm.System.Math,
  Wasm.FMX.Types
  {$ENDIF}
  , FMX.Text, FMX.Edit;

var
  _textLayoutUpdateCount: Integer;

procedure BeginDefaultTextLayout;
begin
  inc(_textLayoutUpdateCount);

  if _textLayoutUpdateCount = 1 then
  begin
    {$IFNDEF WEBASSEMBLY}
    DefaultLayout := TTextLayoutManager.DefaultTextLayout.Create;
    {$ELSE}
    DefaultLayout := TTextLayoutManager.DefaultTextLayout.Create(nil);
    {$ENDIF}

    DefaultLayout.BeginUpdate;
    try
      DefaultLayout.TopLeft := PointF(0, 0);
      DefaultLayout.MaxSize := PointF(1000, 1000);
      DefaultLayout.WordWrap := False; // we want the full text width
      DefaultLayout.HorizontalAlign := TTextAlign.Leading;
      DefaultLayout.VerticalAlign := TTextAlign.Leading;
//      Layout.Color := Settings.FontColor;
      DefaultLayout.RightToLeft := False; // TFillTextFlag.RightToLeft in Flags;
    finally
      DefaultLayout.EndUpdate;
    end;
  end;
end;

procedure EndDefaultTextLayout;
begin
  dec(_textLayoutUpdateCount);
  Assert(_textLayoutUpdateCount >= 0);

  if _textLayoutUpdateCount = 0 then
  begin
    DefaultLayout.Free;
    DefaultLayout := nil;
  end;
end;

function TextControlWidth(const TextControl: TControl; const Settings: TTextSettings; const Text: string; MinWidth: Single = -1; MaxWidth: Single = -1; TextHeight: Single = -1): Single;
begin
  var layout: TTextLayout;
  if DefaultLayout <> nil then
    layout := DefaultLayout else
    layout := TTextLayoutManager.DefaultTextLayout.Create(nil);
  try
    Layout.BeginUpdate;
    try
      Layout.TopLeft := PointF(0, 0);
      Layout.MaxSize := PointF(9999, IfThen(TextHeight <> -1, TextHeight, TextControl.Height));
      Layout.WordWrap := False; // we want the full text width
      Layout.HorizontalAlign := TTextAlign.Leading;
      Layout.VerticalAlign := TTextAlign.Leading;
      Layout.Font := Settings.Font;
//      Layout.Color := Settings.FontColor;
      Layout.RightToLeft := False; // TFillTextFlag.RightToLeft in Flags;
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;

    Result := Layout.TextRect.Right;
  finally
    if DefaultLayout = nil then
      Layout.Free;
  end;

  if MinWidth <> -1 then
    Result := CMath.Max(Result, MinWidth);

  if MaxWidth <> -1 then
    Result := CMath.Min(Result, MaxWidth);
end;

function TextControlHeight(const TextControl: TControl; const Settings: TTextSettings; const Text: string; MinHeight: Single = -1; MaxHeight: Single = -1; TextWidth: Single = -1): Single;
begin
  var layout: TTextLayout;
  if DefaultLayout <> nil then
    layout := DefaultLayout else
    layout := TTextLayoutManager.DefaultTextLayout.Create(nil);

  try
    Layout.BeginUpdate;
    try
      Layout.TopLeft := PointF(0, 0);
      Layout.MaxSize := PointF(IfThen(TextWidth <> -1, TextWidth, TextControl.Width - 6 {inner padding}), 9999);
      Layout.WordWrap := Settings.WordWrap;
      Layout.Font := Settings.Font;
      Layout.RightToLeft := False; // TFillTextFlag.RightToLeft in Flags;

      // also empty line height should be taken into account
      if Length(Text) = 0 then
        Layout.Text := 'p' else
        Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;

    Result := Ceil(Layout.TextRect.Bottom);
  finally
    if DefaultLayout = nil then
      Layout.Free;
  end;

  if MinHeight <> -1 then
    Result := CMath.Max(Result, MinHeight);

  if MaxHeight <> -1 then
    Result := CMath.Min(Result, MaxHeight);
end;

function MemoTextHeight(const Memo: TMemo; MinHeight: Single = -1; MaxHeight: Single = -1): Single;

  function GetLineHeight(const Layout: TTextLayout; const Line: string = ''): Single;
  begin
    Layout.BeginUpdate;
    try
      // also empty line height should be taken into account
      if line = '' then
        Layout.Text := 'Gg' else
        Layout.Text := line;
    finally
      Layout.EndUpdate;
    end;

    Result := Layout.TextRect.Bottom - 4; {margin top bottom}
  end;

begin
  if Memo.Canvas = nil then
    Result := (Memo.Lines.Count * Memo.Font.Size) + 10
  else begin
    Result := 0;

    var layout: TTextLayout := TTextLayoutManager.TextLayoutByCanvas(Memo.Canvas.ClassType).Create(Memo.Canvas);
    try
      Layout.BeginUpdate;
      try
        Layout.TopLeft := PointF(6, 6);
        Layout.MaxSize := PointF(Memo.Width, 9999);
        Layout.WordWrap := True; // {Memo.WordWrap};
        Layout.HorizontalAlign := TTextAlign.Leading;
        Layout.VerticalAlign := TTextAlign.Leading;
        Layout.Font := Memo.Font;
        Layout.Color := Memo.Canvas.Fill.Color;
        Layout.RightToLeft := False; // TFillTextFlag.RightToLeft in Flags;
      finally
        Layout.EndUpdate;
      end;

      Result := Result + GetLineHeight(Layout);
      if Memo.Lines.Count > 0 then
      begin
        var ix: Integer;
        for ix := 0 to Memo.Lines.Count - 1 do
          Result := Result + GetLineHeight(Layout, Memo.Lines[ix]);
      end;
    finally
      Layout.Free;
    end;
  end;

  Result := Result + 12 {margins bottom-top};

  if MinHeight <> -1 then
    Result := CMath.Max(Result, MinHeight);

  if MaxHeight <> -1 then
  begin
    Memo.ShowScrollBars := Result > MaxHeight;
    Result := CMath.Min(Result, MaxHeight);
  end;
end;

function ActiveControl: TControl;
begin
  if Screen.ActiveForm is TCustomForm then
    Result := TCustomForm(Screen.ActiveForm).ActiveControl else
    Result := nil;
end;

function ControlEffectiveVisible(Control: TControl): Boolean;
begin
  var ctrl := Control;
  while (ctrl <> nil) do
  begin
    if not ctrl.Visible or (ctrl.Scene = nil) then
      Exit(False);

    ctrl := ctrl.ParentControl;
  end;

  Result := True;
end;

function ControlHasSelection(Control: TControl): Boolean;
begin
  Result := False;
  if (control = nil) or not interfaces.Supports<ITextActions>(Control) then
    Exit;

  if (control is TEdit) then
    Result := TEdit(control).SelLength > 0
  else if (control is TMemo) then
    Result := TMemo(control).SelLength > 0;
end;

procedure ScrollControlInView(const Control: TControl; const ScrollBox: TCustomScrollBox; ControlMargin: Single = 10);
begin
  if (Control = nil) or (ScrollBox = nil) then
    Exit;

  var ctrlTop := Control.Position.Y - ControlMargin;

  var p := Control.ParentControl;
  while p <> ScrollBox do
  begin
    if not (p is TScrollContent) then
      ctrlTop := ctrlTop + p.Position.Y;

    p := p.ParentControl;
  end;

  var ctrlBottom := ctrlTop + Control.Height + (2*ControlMargin);
  var scrollBoxYStart := ScrollBox.ViewportPosition.Y;
  var scrollBoxYEnd := scrollBoxYStart + ScrollBox.Height;

  // scroll up
  if ctrlTop < scrollBoxYStart then
  begin
    if ctrlTop < 30 then
      ScrollBox.ScrollBy(0, scrollBoxYStart) else
      ScrollBox.ScrollBy(0, scrollBoxYStart - ctrlTop);
  end

  // scroll down
  else if (ctrlBottom > scrollBoxYEnd) then
  begin
    // check if control is heigher then ScrollBox
    if ((scrollBoxYEnd - scrollBoxYStart) <= (ctrlBottom - ctrlTop)) then
      ScrollBox.ScrollBy(0, -1 * (ctrlTop - scrollBoxYStart))
    else if ctrlBottom > (ScrollBox.ContentBounds.Height - 30) then
      ScrollBox.ScrollBy(0, scrollBoxYEnd-ScrollBox.ContentBounds.Height)
    else
      ScrollBox.ScrollBy(0, scrollBoxYEnd-ctrlBottom)
  end;

  ScrollBox.RealignContent;
end;

function MouseInObject(AControl: TControl): Boolean;
begin
  var pos := Screen.MousePos;
  var localPos := AControl.ScreenToLocal(pos);
  Result := AControl.PointInObjectLocal(localPos.X, localPos.Y);
end;

function OwnerForm(AControl: TControl): TCustomForm;
begin
  var owner := AControl.Owner;
  while not (owner is TCustomForm) and (owner <> nil) do
    owner := owner.Owner;

  if owner <> nil then
    Result := owner as TCustomForm else
    Result := nil;
end;

function ProvideAnimation(const Control: TControl; const PropertyName: CString; const NewValue: Single; const Duration: Single = 0.22): TFloatAnimation;
begin
  TAnimator.StopPropertyAnimation(Control, PropertyName);

  Result := TFloatAnimation.Create(Control);
  Result.Parent := Control;
  Result.AnimationType := TAnimationType.Out;
  Result.Interpolation := TInterpolationType.Circular;
  Result.PropertyName := PropertyName;
  Result.StopValue := NewValue;
  Result.StartFromCurrent := True;
  Result.Duration := Duration;
end;

function ProvideAnimationDelay(const Control: TControl; const PropertyName: CString; const NewValue: Single; const Delay: Single = 0.2; const Duration: Single = 0.22): TFloatAnimation;
begin
  Result := ProvideAnimation(Control, PropertyName, NewValue, Duration);
  Result.Delay := Delay;
end;

end.