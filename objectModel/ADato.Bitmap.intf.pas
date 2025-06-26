{$I ..\Source\Adato.inc}

unit ADato.Bitmap.intf;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Graphics,
  {$ELSE}
  Wasm.FMX.Graphics,
  {$ENDIF}
  System_;

type
  IADatoBitmap = interface(IBaseInterface)
    ['{3E69353C-F0F3-48DC-820E-084AC71FC8AC}']
    function  get_Bitmap: TBitmap;
    procedure set_Bitmap(const Value: TBitmap);

    property Bitmap: TBitmap read get_Bitmap write set_Bitmap;
  end;

implementation

end.
