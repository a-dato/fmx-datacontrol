unit FMX.ScrollControl.ControlClasses;

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
  FMX.Layouts,
  FMX.TextLayout,
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
  Wasm.FMX.Layouts,
  Wasm.FMX.TextLayout,
  {$ENDIF}
  System_,
  ADato.FMX.FastControls.Text,
  ADato.FMX.FastControls.Button;

type
  // Interface that handles communication between a cell editor inside the tree control
  // and the actual control used for the editing
  IEditControl = interface(IBaseInterface)
    ['{D407A256-CED9-4FCD-8AED-E6B6578AE83D}']
    function get_Control: TControl;

    property Control: TControl read get_Control;
  end;

  TEditControl = class(TBaseInterfacedObject, IEditControl)
  protected
    _control: TControl;

    function get_Control: TControl;

  public
    constructor Create(AControl: TControl);
  end;

  IDataControlClassFactory = interface
    ['{08ADE46F-92EA-4A14-9208-51FD5347C754}']
    function CreateHeaderRect(const Owner: TComponent): TRectangle;
    function CreateHeaderCellRect(const Owner: TComponent): TRectangle;

    function IsCustomFactory: Boolean;

    function CreateRowCellRect(const Owner: TComponent): TRectangle;
    function CreateRowRect(const Owner: TComponent): TRectangle;

    function CreateText(const Owner: TComponent): TFastText;
    function CreateCheckBox(const Owner: TComponent): TCheckBox;
    function CreateRadioButton(const Owner: TComponent): TRadioButton;
    function CreateButton(const Owner: TComponent): TFastButton;
    function CreateGlyph(const Owner: TComponent): TGlyph;
    function CreateEdit(const Owner: TComponent): TEdit;
    function CreateMemo(const Owner: TComponent): TMemo;
    function CreateDateEdit(const Owner: TComponent): TDateEdit;
    function CreateComboEdit(const Owner: TComponent): TComboEdit;

    procedure HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean);
  end;

  TDataControlClassFactory = class(TInterfacedObject, IDataControlClassFactory)
  private
    _isCustomFactory: Boolean;
  public
    constructor Create; reintroduce;
    {$IFDEF WEBASSEMBLY}
    class constructor Create;
    {$ENDIF}

    function CreateHeaderRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowRect(const Owner: TComponent): TRectangle; virtual;

    function IsCustomFactory: Boolean;

    function CreateHeaderCellRect(const Owner: TComponent): TRectangle; virtual;
    function CreateRowCellRect(const Owner: TComponent): TRectangle; virtual;

    function CreateText(const Owner: TComponent): TFastText; virtual;
    function CreateCheckBox(const Owner: TComponent): TCheckBox; virtual;
    function CreateRadioButton(const Owner: TComponent): TRadioButton; virtual;
    function CreateButton(const Owner: TComponent): TFastButton; virtual;
    function CreateGlyph(const Owner: TComponent): TGlyph; virtual;
    function CreateEdit(const Owner: TComponent): TEdit; virtual;
    function CreateMemo(const Owner: TComponent): TMemo; virtual;
    function CreateDateEdit(const Owner: TComponent): TDateEdit; virtual;
    function CreateComboEdit(const Owner: TComponent): TComboEdit; virtual;

    procedure HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean); virtual;
  end;

var
  // see Initialization section
  DataControlClassFactory: IDataControlClassFactory;

  DEFAULT_GREY_COLOR: TAlphaColor;
  DEFAULT_WHITE_COLOR: TAlphaColor;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR: TAlphaColor;
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR: TAlphaColor;
  DEFAULT_ROW_HOVER_COLOR: TAlphaColor;

  DEFAULT_HEADER_BACKGROUND: TAlphaColor;
  DEFAULT_HEADER_STROKE: TAlphaColor;
  DEFAULT_CELL_STROKE: TAlphaColor;

implementation

uses
  {$IFNDEF WEBASSEMBLY}
  System.SysUtils,
  System.Types
  {$ELSE}
  Wasm.System.SysUtils,
  Wasm.System.Types
  {$ENDIF}
  ;

{ TDataControlClassFactory }

function TDataControlClassFactory.CreateHeaderRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

  Result.HitTest := True;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Red;
  {$ELSE}
  Result.Fill.Color := DEFAULT_HEADER_BACKGROUND;
  {$ENDIF}
  Result.Stroke.Color := TAlphaColors.Null;
  Result.Sides := [];
end;

constructor TDataControlClassFactory.Create;
begin
  inherited;

  _isCustomFactory := Self.ClassType <> TDataControlClassFactory;
end;

{$IFDEF WEBASSEMBLY}
class constructor TDataControlClassFactory.Create;
begin
  DEFAULT_GREY_COLOR := TAlphaColor($FFF1F2F7);
  DEFAULT_WHITE_COLOR := TAlphaColors.Null;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR := TAlphaColor($886A5ACD);
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR := TAlphaColor($88778899);
  DEFAULT_ROW_HOVER_COLOR := TAlphaColor($335B8BCD);

  DEFAULT_HEADER_BACKGROUND := TAlphaColors.Null;
  DEFAULT_HEADER_STROKE := TAlphaColors.Grey;
  DEFAULT_CELL_STROKE := TAlphaColors.Lightgray;    
end;
{$ENDIF}

function TDataControlClassFactory.CreateMemo(const Owner: TComponent): TMemo;
begin
  Result := TMemo.Create(Owner);
end;

function TDataControlClassFactory.CreateButton(const Owner: TComponent): TFastButton;
begin
  Result := TFastButton.Create(Owner);
end;

function TDataControlClassFactory.CreateCheckBox(const Owner: TComponent): TCheckBox;
begin
  Result := TCheckBox.Create(Owner);
end;

function TDataControlClassFactory.CreateComboEdit(const Owner: TComponent): TComboEdit;
begin
  Result := TComboEdit.Create(Owner);
end;

function TDataControlClassFactory.CreateDateEdit(const Owner: TComponent): TDateEdit;
begin
  Result := TDateTimeEditOnKeyDownOverride.Create(Owner);
end;

function TDataControlClassFactory.CreateEdit(const Owner: TComponent): TEdit;
begin
  Result := TEdit.Create(Owner);
end;

function TDataControlClassFactory.CreateGlyph(const Owner: TComponent): TGlyph;
begin
  Result := TGlyph.Create(Owner);
end;

function TDataControlClassFactory.CreateHeaderCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);

//  Result.Fill.Kind := TBrushKind.None;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Yellow;
  Result.Stroke.Color := TAlphaColors.Yellow;
  Result.Sides := [TSide.Bottom];
  {$ELSE}
  Result.Fill.Color := TAlphaColors.Null;
  Result.Stroke.Color := DEFAULT_HEADER_STROKE;
  Result.Sides := [TSide.Bottom];
  {$ENDIF}
end;

function TDataControlClassFactory.CreateRadioButton(const Owner: TComponent): TRadioButton;
begin
  Result := TRadioButton.Create(Owner);
end;

function TDataControlClassFactory.CreateRowCellRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Kind := TBrushKind.Solid;
  Result.Fill.Color := TAlphaColors.Green;
  Result.Stroke.Color := TAlphaColors.Green;
  {$ELSE}
  Result.Fill.Kind := TBrushKind.None;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
  {$ENDIF}
end;

function TDataControlClassFactory.CreateRowRect(const Owner: TComponent): TRectangle;
begin
  Result := TRectangle.Create(Owner);
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  Result.Fill.Color := TAlphaColors.Darkslategray;
  Result.Stroke.Color := TAlphaColors.Darkslategray;
  {$ELSE}
  Result.Fill.Color := DEFAULT_WHITE_COLOR;
  Result.Stroke.Color := DEFAULT_CELL_STROKE;
  {$ENDIF}
end;

function TDataControlClassFactory.CreateText(const Owner: TComponent): TFastText;
begin
  Result := TFastText.Create(Owner);
  Result.VertTextAlign := TTextAlign.Center;
  Result.CalcAsAutoWidth := True;
end;

procedure TDataControlClassFactory.HandleRowBackground(const RowRect: TRectangle; Alternate: Boolean);
begin
//  RowRect.Fill.Kind := TBrushKind.Solid;
  {$IF Defined(DEBUG) and Defined(WEBASSEMBLY)}
  if Alternate then
    RowRect.Fill.Color := TAlphaColors.Cyan else
    RowRect.Fill.Color := TAlphaColors.Cyan;
  {$ELSE}
  if Alternate then
    RowRect.Fill.Color := DEFAULT_GREY_COLOR else
    RowRect.Fill.Color := DEFAULT_WHITE_COLOR;
  {$ENDIF}
end;

function TDataControlClassFactory.IsCustomFactory: Boolean;
begin
  Result := _isCustomFactory;
end;

{ TEditControl }

constructor TEditControl.Create(AControl: TControl);
begin
  _control := AControl;
end;

function TEditControl.get_Control: TControl;
begin
  Result := _control;
end;

initialization
  DataControlClassFactory := TDataControlClassFactory.Create;

  DEFAULT_GREY_COLOR := TAlphaColor($FFF1F2F7);
  DEFAULT_WHITE_COLOR := TAlphaColors.Null;

  DEFAULT_ROW_SELECTION_ACTIVE_COLOR := TAlphaColor($886A5ACD);
  DEFAULT_ROW_SELECTION_INACTIVE_COLOR := TAlphaColor($88778899);
  DEFAULT_ROW_HOVER_COLOR := TAlphaColor($335B8BCD);

  DEFAULT_HEADER_BACKGROUND := TAlphaColors.Null;
  DEFAULT_HEADER_STROKE := TAlphaColors.Grey;
  DEFAULT_CELL_STROKE := TAlphaColors.Lightgray;

finalization
  DataControlClassFactory := nil;

end.


