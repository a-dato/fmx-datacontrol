unit TreeSampleMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Forms,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, FMX.ScrollControl.Impl, FMX.ScrollControl.WithRows.Impl,
  FMX.ScrollControl.WithCells.Impl, FMX.ScrollControl.WithEditableCells.Impl,
  FMX.ScrollControl.DataControl.Impl, ADato.Data.DataModelViewDataset,
  Data.Bind.Components, Data.Bind.DBScope, Data.DB,
  Delphi.Extensions.VirtualDataset, ADato.Data.VirtualDatasetDataModel,
  ADato.Data.DatasetDataModel, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Actions, FMX.ActnList, FMX.StdCtrls, FMX.Edit, FMX.Controls,
  FMX.Controls.Presentation, FMX.Types, FMX.Layouts, ADato.Data.DataModel.intf;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Layout1: TLayout;
    Layout2: TLayout;
    Button3: TButton;
    ActionList1: TActionList;
    acExpand: TAction;
    acCollapse: TAction;
    Button4: TButton;
    Button5: TButton;
    FDMemTable1: TFDMemTable;
    TDataset: TButton;
    MemtableToDataModel: TDatasetDataModel;
    DataSource1: TDataSource;
    edNameByLiveBinding: TEdit;
    Label2: TLabel;
    DataModelNaqmeField: TWideStringField;
    BindSourceMemTableToDataModel: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    HierarchyToTDataset: TDataModelViewDataset;
    BindSourceHierarchyToDataset: TBindSourceDB;
    BindingsList2: TBindingsList;
    LinkControlToField2: TLinkControlToField;
    edDataModelName: TEdit;
    Label1: TLabel;
    DataControl1: TDataControl;
    procedure acCollapseExecute(Sender: TObject);
    procedure acExpandExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TDatasetClick(Sender: TObject);
  private

  protected
    procedure SetupMemTable;
    procedure SetupDataModelViewDataset;

  public
    _companyDataModel: IDataModel;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.Collections, ApplicationObjects;

{$R *.fmx}

procedure TForm1.acCollapseExecute(Sender: TObject);
begin
  DataControl1.CollapseCurrentRow;
end;

procedure TForm1.acExpandExecute(Sender: TObject);
begin
  DataControl1.ExpandCurrentRow;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  DataControl1.DataList := TAppObjects.CreateCompanyList as IList;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  _companyDataModel := TAppObjects.CreateCompanyDataModel;

  DataControl1.DataModelView := _companyDataModel.DefaultView;

  // Prepare for data aware components
  // TDataModelViewDataset presents an IDataModel/IDataModelView as a TDataset
  // Live binding is used to link field DataModelViewDataset1.Name to edit control edDataModelName

  SetupDataModelViewDataset;
  HierarchyToTDataset.DataModelView := _companyDataModel.DefaultView;
  HierarchyToTDataset.Open;
end;

procedure TForm1.TDatasetClick(Sender: TObject);
begin
  SetupMemTable;

  var l := TAppObjects.CreateCompanyList;

  FDMemTable1.DisableControls;

  for var c in l do
  begin
    FDMemTable1.Append;
    FDMemTable1.FieldByName('Name').AsString := c.Name;
    FDMemTable1.Post;
  end;

  FDMemTable1.EnableControls;

  MemtableToDataModel.Open;

  DataControl1.DataModelView := MemtableToDataModel.DataModelView;
end;

procedure TForm1.SetupDataModelViewDataset;
begin
  HierarchyToTDataset.Close;
  HierarchyToTDataset.Fields.Clear;

  var s := TVariantField.Create(HierarchyToTDataset);
  s.FieldName := 'Name';
  s.DataSet := HierarchyToTDataset;
end;

procedure TForm1.SetupMemTable;
begin
  MemtableToDataModel.Close;
  FDMemTable1.Close;
  FDMemTable1.Fields.Clear;
  var s := TWideStringField.Create(FDMemTable1);
  s.FieldName := 'Name';
  s.DataSet := FDMemTable1;
  FDMemTable1.Open;
end;

end.


