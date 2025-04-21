{$I ..\Source\Adato.inc}

unit ADato.Bitmap.impl;

interface

uses
  {$IFDEF DELPHI}
  FMX.Graphics,
  {$ENDIF}
  System_,
  ADato.Bitmap.intf;

type
  TADatoBitmap = class(TBaseInterfacedObject, IADatoBitmap)
  private
    _bitmap: TBitmap;
    function  get_Bitmap: TBitmap;
    procedure set_Bitmap(const Value: TBitmap);
  public
    constructor Create(const ABitmap: TBitmap); overload;
    destructor Destroy; override;

    property Bitmap: TBitmap read get_Bitmap write set_Bitmap;
  end;

implementation

{ TADatoBitmap }

constructor TADatoBitmap.Create(const ABitmap: TBitmap);
begin
  inherited Create;
  _bitmap := ABitmap;
end;

destructor TADatoBitmap.Destroy;
begin
  {$IFDEF DELPHI}
  _bitmap.Free;
  inherited;
  {$ENDIF}
end;

function TADatoBitmap.get_Bitmap: TBitmap;
begin
  Result := _bitmap;
end;

procedure TADatoBitmap.set_Bitmap(const Value: TBitmap);
begin
  _bitmap := Value;
end;

end.
