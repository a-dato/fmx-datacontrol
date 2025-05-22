unit PropertiesMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, System_,
  FMX.Edit;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowProperties(const AType: &Type);
  end;

  {$M+}
  ICompany = interface(IBaseInterface)
    function get_Name: string;
    procedure set_Name(const Value: string);

    property Name: string read get_Name write set_Name;
  end;

  TCompany = class(TBaseInterfacedObject, ICompany)
  protected
    _Address: string;
    _Name: string;

    function  get_Address: string;
    procedure set_Address(const Value: string);
    function  get_Name: string;
    procedure set_Name(const Value: string);

  published
    property Address: string read get_Address write set_Address;
    property Name: string read get_Name write set_Name;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  ADato.Extensions.intf,
  ADato.Extensions.impl;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowProperties(&Type.From<ICompany>);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ShowProperties(&Type.From<TCompany>);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Edit1.Text <> '' then
    ExtensionManager.AddProperty(&Type.From<ICompany>, CustomProperty.Create(&Type.From<ICompany>, Edit1.Text, Edit2.Text, &Type.From<string>));
end;

procedure TForm1.ShowProperties(const AType: &Type);
begin
  Memo1.Lines.Clear;
  for var prop in AType.GetProperties do
    Memo1.Lines.Add(prop.Name);
end;

{ TCompany }

function TCompany.get_Address: string;
begin
  Result := _Address;
end;

function TCompany.get_Name: string;
begin
  Result := _Name;
end;

procedure TCompany.set_Address(const Value: string);
begin
  _Address := Value;
end;

procedure TCompany.set_Name(const Value: string);
begin
  _Name := Value;
end;

end.
