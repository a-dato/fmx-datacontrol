unit ADato.FMX.DataControl.Register;

interface

uses
  Classes,
  FMX.Types,
  FMX.StdCtrls,
  FMX.ScrollControl.DataControl.Impl,
  FMX.ScrollControl.Impl,
  FMX.ScrollControl.Events;

procedure Register;

implementation

procedure Register;
const
  COMPONENTS_NAME = 'A-Dato FMX DataControl';
begin
  RegisterComponents(COMPONENTS_NAME, [TDataControl]);
  RegisterComponents(COMPONENTS_NAME, [TScrollControl]);

end;

end.


