unit ADato.FMX.Controls.Intf;

interface

uses
  {$IFDEF WEBASSEMBLY}
  Wasm.System.Classes,
  Wasm.FMX.Controls
  {$ELSE}
  System.Classes,
  FMX.Controls
  {$ENDIF}
  ;

type
  IFocusableControlsContainer = interface
    ['{37E734BD-628E-4DB2-AC47-FB3720AD4D64}']
    function  FirstFocusableControl: TControl;
    procedure ExecuteKeyFromExternal(var Key: Word; var KeyChar: Char; Shift: TShiftState; const ActiveChild: TControl = nil);
  end;

  ILayoutInvalidationContainer = interface
    ['{6D2F3A52-7240-48C1-81EF-F511E4C0B49F}']
    procedure RequestChildLayoutChanged(const Child: TControl);
  end;

implementation

end.
