unit ADato.FMX.Controls.Intf;

interface

uses
  System.Classes, FMX.Controls;

type
  IFocusableControlsContainer = interface
    ['{37E734BD-628E-4DB2-AC47-FB3720AD4D64}']
    function  FirstFocusableControl: TControl;
    procedure ExecuteKeyFromExternal(var Key: Word; var KeyChar: Char; Shift: TShiftState; const ActiveChild: TControl = nil);
  end;

implementation

end.
