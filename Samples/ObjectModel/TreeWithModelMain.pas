unit TreeWithModelMain;

interface

uses
  System_,
  FMX.DataControl.Impl, FMX.DataControl.ScrollableControl,
  FMX.DataControl.ScrollableRowControl, FMX.DataControl.Static,
  FMX.DataControl.Editable, System.Classes, System.Actions, FMX.ActnList,
  FMX.StdCtrls, FMX.Edit, FMX.Controls, FMX.Controls.Presentation, FMX.Types,
  FMX.Layouts, FMX.Forms, ADato.Data.DataModel.intf,
  ADato.ObjectModel.List.intf, FMX.DataControl.Events;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Button2: TButton;
    Layout2: TLayout;
    edNameByBinding: TEdit;
    Label1: TLabel;
    ActionList1: TActionList;
    acExpand: TAction;
    acCollapse: TAction;
    Button4: TButton;
    Button5: TButton;
    Button9: TButton;
    Button1: TButton;
    DataControl1: TDataControl;
    procedure acCollapseExecute(Sender: TObject);
    procedure acExpandExecute(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure DataControl1RowAdding(const Sender: TObject; e: DCAddingNewEventArgs);

  private

  protected

  public
    _objectListModel: IObjectListModel;
    _companyDataModel: IDataModel;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  ApplicationObjects,
  ADato.ObjectModel.List.Tracking.intf,
  ADato.ObjectModel.List.Tracking.impl,
  System.Collections,
  ADato.ObjectModel.Binders,
  ADato.ObjectModel.List.impl,
  ADato.ObjectModel.DataModel.impl;

{$R *.fmx}

procedure TForm1.acCollapseExecute(Sender: TObject);
begin
  DataControl1.CollapseCurrentRow;
end;

procedure TForm1.acExpandExecute(Sender: TObject);
begin
  DataControl1.ExpandCurrentRow;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  var model: IObjectListModel := TObjectListModelWithChangeTracking<ICompany>.Create(function: ICompany begin Result := TCompany.Create; end);
  model.Context := TAppObjects.CreateCompanyList as IList;

  var bind := TPropertyBinding.CreateBindingByControl(edNameByBinding);
  model.ObjectModelContext.Bind('Name', bind);

  DataControl1.Model := model;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  var model: IObjectListModel := TObjectListModel<ICompany>.Create;
  model.Context := TAppObjects.CreateCompanyList as IList;

  var bind := TPropertyBinding.CreateBindingByControl(edNameByBinding);
  model.ObjectModelContext.Bind('Name', bind);

  DataControl1.Model := model;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  _companyDataModel := TAppObjects.CreateCompanyDataModel;

  DataControl1.Columns[0].Hierarchy.ShowHierarchy := True;
  DataControl1.Columns[0].Hierarchy.Indent := 10;
  DataControl1.RowAdding := DataControl1RowAdding;
  DataControl1.DataModelView := _companyDataModel.DefaultView;

  _objectListModel := TDataModelObjectListModel.Create(False, function: CObject begin Result := TCompany.Create; end);
  _objectListModel.Context := _companyDataModel as IList;

  var bind := TPropertyBinding.CreateBindingByControl(edNameByBinding);
  _objectListModel.ObjectModelContext.Bind('Name', bind);
end;

procedure TForm1.DataControl1RowAdding(const Sender: TObject; e: DCAddingNewEventArgs);
begin
;
end;

//procedure TForm1.TreeControlAddingNew(Sender: TObject; Args: AddingNewEventArgs);
//begin
//  if (FMXTreeControl1.Row = nil) or (FMXTreeControl1.Row.Level = 0) then
//  begin
//    var c: ICompany := TCompany.Create;
//    Args.NewObject := c;
//  end
//  else
//  begin
//    var u: IUser := TUser.Create;
//    Args.NewObject := u;
//  end;
//end;

end.
