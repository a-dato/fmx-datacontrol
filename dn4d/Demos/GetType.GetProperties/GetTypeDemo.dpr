program GetTypeDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  PropertiesMain in 'PropertiesMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
