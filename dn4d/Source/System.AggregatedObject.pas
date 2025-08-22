unit System.AggregatedObject;

interface

uses
  System_,
  System.Collections.Generic;

type
  TAggregatedBaseObject = class(TBaseInterfacedObject)
  private
    [Unsafe] FController: IInterface;  // unsafe/weak reference to controller
  protected
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; override;
    function _AddRef: Integer; override;
    function _Release: Integer; override;

    procedure Dispose; override;
  public
    constructor Create(const Controller: IInterface);
    property Controller: IInterface read FController write FController;
  end;

  TAggregatedList<T> = class(CList<T>)
  private
    [Unsafe] FController: IInterface;  // unsafe/weak reference to controller
  protected
    { IInterface }
    // function  IInterface.QueryInterface = QueryInterface;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override;
    function _AddRef: Integer; override;
    function _Release: Integer; override;

    procedure Dispose; override;
  public
    constructor Create(const Controller: IInterface);
    property Controller: IInterface read FController;
  end;

implementation

{ TAggregatedBaseObject }

constructor TAggregatedBaseObject.Create(const Controller: IInterface);
begin
  inherited Create;
  FController := Controller;
end;

procedure TAggregatedBaseObject.Dispose;
begin
  Free;
end;

function TAggregatedBaseObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := FController.QueryInterface(IID, Obj)
end;

function TAggregatedBaseObject._AddRef: Integer;
begin
  Result := FController._AddRef
end;

function TAggregatedBaseObject._Release: Integer;
begin
  Result := FController._release;
end;

{ TAggregatedList<T> }

constructor TAggregatedList<T>.Create(const Controller: IInterface);
begin
  inherited Create;
  FController := Controller;
end;

procedure TAggregatedList<T>.Dispose;
begin
  Free;
end;

function TAggregatedList<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
  if Result <> S_OK then
    Result := FController.QueryInterface(IID, Obj);
end;

function TAggregatedList<T>._AddRef: Integer;
begin
  Result := FController._AddRef;
end;

function TAggregatedList<T>._Release: Integer;
begin
  Result := FController._Release;
end;

end.
