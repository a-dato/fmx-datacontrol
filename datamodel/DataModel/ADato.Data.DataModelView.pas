unit ADato.Data.DataModelView;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  Classes,
  {$ELSE}
  Wasm.System.Classes,
  {$ENDIF}
  System_,
  ADato.Data.DataModel.intf;

type
  {$IFNDEF WEBASSEMBLY}
  [ComponentPlatformsAttribute(pidAllPlatforms)]
  {$ENDIF}
  TDataModelViewComponent = class(
    TComponent,
    IDataModelView)
  protected
    _FilterRecord   : FilterEventHandlerProc;
    _dataModelView  : IDataModelView;

    procedure set_FilterRecord(Value: FilterEventHandlerProc);
    function  get_DataModel: IDataModel;
    procedure set_DataModel(Value: IDataModel);

    procedure DataModelView_FilterRecord( const Sender: IBaseInterface;
                                          e: FilterEventArgs);

  public
    constructor Create(AOwner: TComponent); override;

    property View: IDataModelView
      read _dataModelView implements IDataModelView;

  published
    property Model: IDataModel
      read  get_DataModel
      write set_DataModel;

    property FilterRecord: FilterEventHandlerProc
      read  _FilterRecord
      write set_FilterRecord;
  end;


implementation

uses
  ADato.ComponentModel,
  ADato.Data.DataModel.impl;


{ TDataModelViewComponent }

constructor TDataModelViewComponent.Create(AOwner: TComponent);
begin
  inherited;
  _dataModelView := TDataModelView.Create(nil);
  {$IFNDEF WEBASSEMBLY}
  (_dataModelView as IRemoteQueryControllerSupport).InterfaceComponentReference := Self;
  {$ELSE}
  raise NotImplementedException.Create('TDataModelViewComponent.Create(AOwner: TComponent)');
  {$ENDIF}
end;

procedure TDataModelViewComponent.DataModelView_FilterRecord(
  const Sender: IBaseInterface;
  e: FilterEventArgs);
begin
  if Assigned(_FilterRecord) then
    _FilterRecord(Sender, e);
end;

function TDataModelViewComponent.get_DataModel: IDataModel;
begin
  Result := _dataModelView.DataModel;
end;

procedure TDataModelViewComponent.set_DataModel(Value: IDataModel);
begin
  _dataModelView.DataModel := Value;
end;

procedure TDataModelViewComponent.set_FilterRecord(
  Value: FilterEventHandlerProc);
begin
  _FilterRecord := Value;

  {$IFNDEF WEBASSEMBLY}
  if Assigned(_FilterRecord) then
    _dataModelView.FilterRecord.Add(DataModelView_FilterRecord) else
    _dataModelView.FilterRecord.Remove(DataModelView_FilterRecord);
  {$ELSE}
  if Assigned(_FilterRecord) then
    _dataModelView.FilterRecord += DataModelView_FilterRecord else
    _dataModelView.FilterRecord -= DataModelView_FilterRecord;
  {$ENDIF}
end;

end.


