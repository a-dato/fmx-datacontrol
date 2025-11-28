{$IFNDEF WEBASSEMBLY}
{$I ..\Source\Adato.inc}
{$ENDIF}

unit ADato.ComponentModel;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  TypInfo,
  Classes,
  Generics.Defaults,
  {$ELSE}
  Wasm.System.Classes,
  {$ENDIF}
  System_,
  System.Collections,
  System.ComponentModel,
  System.Runtime.Serialization;

type
  {$M+}
  UpdateFlag = (ApplyUpdate, IgnoreUpdate);
  IUpdateableObjectWithUpdateFlag = interface
    ['{76AEEAE0-1A5F-4552-835C-3C3C41421485}']

    procedure BeginUpdate(Flag: UpdateFlag);
    procedure EndUpdate(Flag: UpdateFlag);
  end;

  IEditState = interface
    ['{EC5D63DB-349F-4EE9-94F0-441DA3BA0158}']
    function IsEditOrNew: Boolean;
  end;

  IListSortDescription = interface(IBaseInterface)
    ['{C8130412-27DD-40C2-B1BE-08CB37DB6E2F}']
    function  get_SortDirection: ListSortDirection;
    procedure set_SortDirection(const Value: ListSortDirection);
    function  get_LoadSortableValueInternal: Boolean;
    procedure set_LoadSortableValueInternal(const Value: Boolean);

    function  Compare(const Left, Right: CObject): Integer;
    function  GetSortableValue(const AObject: CObject): CObject;

    function  Equals(const Sort: IListSortDescription): Boolean;

    procedure SortBegin;
    procedure SortCompleted;
    procedure ToggleDirection;

    property SortDirection: ListSortDirection read get_SortDirection write set_SortDirection;
    property LoadSortableValueInternal: Boolean read get_LoadSortableValueInternal write set_LoadSortableValueInternal;
  end;

  CListSortDescription = class(TBaseInterfacedObject, IListSortDescription, IComparer<CObject>)
  protected
    _SortDirection: ListSortDirection;
    _LoadSortableValueInternal: Boolean;

    function  get_SortDirection: ListSortDirection;
    procedure set_SortDirection(const Value: ListSortDirection);
    function  get_LoadSortableValueInternal: Boolean;
    procedure set_LoadSortableValueInternal(const Value: Boolean);

  public
    constructor Create(const ASortDirection: ListSortDirection);

    function  Equals(const Sort: IListSortDescription): Boolean; virtual;
    function  Compare(const Left, Right: CObject): Integer; virtual;
    function  GetSortableValue(const AObject: CObject): CObject; virtual;

    procedure SortBegin; virtual;
    procedure SortCompleted; virtual;

    procedure ToggleDirection;

    property SortDirection: ListSortDirection read  get_SortDirection write set_SortDirection;
    property LoadSortableValueInternal: Boolean read get_LoadSortableValueInternal write set_LoadSortableValueInternal;
  end;

  IListSortDescriptionWithComparer = interface(IListSortDescription)
    ['{CD4AEAC1-31B8-435D-B5E8-6ACEB99CF80C}']
    function  get_Comparer: IComparer<CObject>;
    procedure set_Comparer(const Value: IComparer<CObject>);

    property Comparer: IComparer<CObject>
      read  get_Comparer
      write set_Comparer;
  end;

  CListSortDescriptionWithComparer = class(CListSortDescription, IListSortDescriptionWithComparer, IComparer<CObject>)
  protected
    _Comparer: IComparer<CObject>;

    function  get_Comparer: IComparer<CObject>;
    procedure set_Comparer(const Value: IComparer<CObject>);

  public
    constructor Create(const ASortDirection: ListSortDirection; const AComparer: IComparer<CObject>); reintroduce; overload;

    function  Equals(const Sort: IListSortDescription): Boolean; override;
    function  Compare(const Left, Right: CObject): Integer; override;

    property Comparer: IComparer<CObject>
      read  get_Comparer
      write set_Comparer implements IComparer<CObject>;
  end;

  IListSortDescriptionWithProperty = interface(IListSortDescription)
    ['{F9557DC6-18C4-48F7-9B10-935F88081F57}']
    function  get_PropertyDescriptor: CString;
    procedure set_PropertyDescriptor(const Value: CString);

    property PropertyDescriptor: CString
      read  get_PropertyDescriptor
      write set_PropertyDescriptor;
  end;

  CListSortDescriptionWithProperty = class(CListSortDescription, IListSortDescriptionWithProperty)
  protected
    _PropertyDescriptor: CString;

    function  get_PropertyDescriptor: CString;
    procedure set_PropertyDescriptor(const Value: CString);

  public
    constructor Create(const ASortDirection: ListSortDirection; const APropertyDescriptor: CString); reintroduce;

    function  Equals(const Sort: IListSortDescription): Boolean; override;
    function  GetSortableValue(const AObject: CObject): CObject; override;

    property PropertyDescriptor: CString
      read  get_PropertyDescriptor
      write set_PropertyDescriptor;
  end;

  IListFilterDescription = interface(IBaseInterface)
    ['{4B7CC330-CBB0-4B9E-B9BA-9E8D521208F5}']
    function  get_ShowEmptyValues: Boolean;
    procedure set_ShowEmptyValues(const Value: Boolean);

    function IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean;
    function GetFilterableValue(const AObject: CObject): CObject;

    function EqualToSort(const Sort: IListSortDescription): Boolean;
    function ToSortDescription: IListSortDescription;

    property ShowEmptyValues: Boolean read get_ShowEmptyValues write set_ShowEmptyValues;
  end;

  CListFilterDescription = class(TBaseInterfacedObject, IListFilterDescription)
  private
    _ShowEmptyValues: Boolean;
    function  get_ShowEmptyValues: Boolean;
    procedure set_ShowEmptyValues(const Value: Boolean);

  public
    constructor Create;

    function GetFilterableValue(const AObject: CObject): CObject; virtual;
    function IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean; virtual; abstract;

    function EqualToSort(const Sort: IListSortDescription): Boolean; virtual;
    function ToSortDescription: IListSortDescription; virtual;

    property ShowEmptyValues: Boolean read get_ShowEmptyValues write set_ShowEmptyValues;
  end;

  IListFilterDescriptionWithComparer = interface(IListFilterDescription)
    ['{26382F29-57E2-4F17-85AE-4FA22789C0C3}']
    function get_Comparer: IComparer<CObject>;
    property Comparer: IComparer<CObject> read get_Comparer;
  end;

  CListFilterDescriptionWithComparer = class(CListFilterDescription, IListFilterDescriptionWithComparer)
  protected
    _Comparer: IComparer<CObject>;
    function get_Comparer: IComparer<CObject>;
  public
    constructor Create(const Comparer: IComparer<CObject>);

    function IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean; override;
    function ToSortDescription: IListSortDescription; override;

    property Comparer: IComparer<CObject> read get_Comparer;
  end;

  IListFilterDescriptionForText = interface(IListFilterDescription)
    ['{C6E73EC0-9A67-4249-9724-B878918E5AF1}']
    function get_FilterText: CString;
    function get_PropertyName: CString;

    property FilterText: CString read get_FilterText;
    property PropertyName: CString read get_PropertyName;
  end;

  CListFilterDescriptionForText = class(CListFilterDescription, IListFilterDescriptionForText)
  protected
    _FilterText: CString;
    _PropertyName: CString;

    function get_FilterText: CString;
    function get_PropertyName: CString;

    function MatchText(const TextData: CString): Boolean;
  public
    constructor Create(const FilterText: CString); {; const Comparer: IComparer<CObject> = nil);} reintroduce; overload;
    constructor Create(const FilterText, PropertyName: CString {; const Comparer: IComparer<CObject> = nil} ); reintroduce; overload;

    function GetFilterableValue(const AObject: CObject): CObject; override;
    function IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean; override;
    function ToSortDescription: IListSortDescription; override;

    property FilterText: CString read get_FilterText;
    property PropertyName: CString read get_PropertyName;
  end;

  TEditableObjectSupport = class(
    TBaseInterfacedObject,
    IEditableObject)
  protected
    _target: CObject;
    _properties: PropertyInfoArray;
    _data: array of CObject;

    procedure BeginEdit;
    procedure CancelEdit;
    procedure EndEdit;

  public
    constructor Create(const Target: CObject);
  end;

  IRemoteQueryControllerSupport = interface(IBaseInterface)
    ['{DACD9408-98F4-43FA-A18C-CDE3D113E31E}']
    function  get_InterfaceComponentReference: IInterfaceComponentReference;
    procedure set_InterfaceComponentReference(const Value: IInterfaceComponentReference);

    procedure AddQueryController(const Value: IInterface);
    procedure RemoveQueryController(const Value: IInterface);

    // Gives access to this interface even when it's not implemented
    // by the implementing class
    property InterfaceComponentReference: IInterfaceComponentReference
      read  get_InterfaceComponentReference
      write set_InterfaceComponentReference;
  end;

  TRemoteQueryControllerSupport = class(
    TBaseInterfacedObject,
    IRemoteQueryControllerSupport)
  private
    // QueryInterface provides a way to overide the interface
    // used for querying other interfaces
    {$IFNDEF WEBASSEMBLY}
    _QueryControllers: array of Pointer;
    {$ELSE}
    _QueryControllers: array of IInterface;
    {$ENDIF}
    {$IFNDEF WEBASSEMBLY}[unsafe]{$ENDIF}_InterfaceComponentReference: IInterfaceComponentReference;

  protected
    function  get_InterfaceComponentReference: IInterfaceComponentReference;
    procedure set_InterfaceComponentReference(const Value: IInterfaceComponentReference);

    procedure AddQueryController(const Value: IInterface);
    procedure RemoveQueryController(const Value: IInterface);

    function  QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function  DotNetQueryInterface<T>: T;
  end;

implementation

{$IFDEF DELPHI}
uses
  SysUtils;
{$ENDIF}

{ IListSortDescription }

function CListSortDescription.Compare(const Left, Right: CObject): Integer;
begin
  Result := CObject.Compare(Left, Right);
end;

constructor CListSortDescription.Create(const ASortDirection: ListSortDirection);
begin
  _SortDirection := ASortDirection;
  _LoadSortableValueInternal := False;
end;

function CListSortDescription.Equals(const Sort: IListSortDescription): Boolean;
begin
  Result := _SortDirection = Sort.SortDirection;
end;

function CListSortDescription.GetSortableValue(const AObject: CObject): CObject;
begin
  Result := AObject;
end;

function CListSortDescription.get_LoadSortableValueInternal: Boolean;
begin
  Result := _LoadSortableValueInternal;
end;

function CListSortDescription.get_SortDirection: ListSortDirection;
begin
  Result := _SortDirection;
end;

procedure CListSortDescription.set_LoadSortableValueInternal(const Value: Boolean);
begin
  _LoadSortableValueInternal := Value;
end;

procedure CListSortDescription.set_SortDirection(const Value: ListSortDirection);
begin
  _SortDirection := Value;
end;

procedure CListSortDescription.SortBegin;
begin

end;

procedure CListSortDescription.SortCompleted;
begin

end;

procedure CListSortDescription.ToggleDirection;
begin
  if _SortDirection = ListSortDirection.Ascending then
    _SortDirection := ListSortDirection.Descending else
    _SortDirection := ListSortDirection.Ascending;
end;

{ CListSortDescriptionWithComparer }

function CListSortDescriptionWithComparer.Compare(const Left, Right: CObject): Integer;
begin
  Result := _SortDirection.ToMultiplier * _Comparer.Compare(Left, Right);
end;

constructor CListSortDescriptionWithComparer.Create(const ASortDirection: ListSortDirection; const AComparer: IComparer<CObject>);
begin
  inherited Create(ASortDirection);
  _Comparer := AComparer;
end;

function CListSortDescriptionWithComparer.Equals(const Sort: IListSortDescription): Boolean;
var
  cmp: IListSortDescriptionWithComparer;
begin
  Result :=
      Interfaces.Supports(Sort, IListSortDescriptionWithComparer, cmp) and
      (_Comparer = cmp.Comparer) and
      (Self._SortDirection = cmp.SortDirection);
end;

function CListSortDescriptionWithComparer.get_Comparer: IComparer<CObject>;
begin
  Result := _Comparer;
end;

procedure CListSortDescriptionWithComparer.set_Comparer(const Value: IComparer<CObject>);
begin
  _Comparer := Value;
end;

{ CListSortDescriptionWithProperty }

constructor CListSortDescriptionWithProperty.Create(const ASortDirection: ListSortDirection; const APropertyDescriptor: CString);
begin
  inherited Create(ASortDirection);
  _PropertyDescriptor := APropertyDescriptor;
end;

function CListSortDescriptionWithProperty.Equals(const Sort: IListSortDescription): Boolean;
var
  pds: IListSortDescriptionWithProperty;
begin
  Result :=
      (Interfaces.Supports<IListSortDescriptionWithProperty>(Sort, pds)) and
      CString.Equals(Self.PropertyDescriptor, pds.PropertyDescriptor) and
      (Self._SortDirection = pds.SortDirection);
end;

function CListSortDescriptionWithProperty.GetSortableValue(const AObject: CObject): CObject;
begin
  if AObject = nil then
    Exit(nil);

  if CString.Equals(_PropertyDescriptor, '[Object]') then
    Exit(AObject);

  var prop := AObject.GetType.PropertyByName(_PropertyDescriptor);
  if prop = nil then
    raise Exception.Create(CString.Format('No property with name {0}', _PropertyDescriptor));

  Result := prop.GetValue(AObject, []);
end;

function CListSortDescriptionWithProperty.get_PropertyDescriptor: CString;
begin
   Result := _PropertyDescriptor;
end;

procedure CListSortDescriptionWithProperty.set_PropertyDescriptor(const Value: CString);
begin
  _PropertyDescriptor := Value;
end;

{ CBaseFilterDescription }

constructor CListFilterDescription.Create;
begin
  _ShowEmptyValues := True;
end;

function CListFilterDescription.EqualToSort(const Sort: IListSortDescription): Boolean;
begin
  Result := False;
end;

function CListFilterDescription.GetFilterableValue(const AObject: CObject): CObject;
begin
  Result := AObject;
end;

function CListFilterDescription.get_ShowEmptyValues: Boolean;
begin
  Result := _ShowEmptyValues;
end;

procedure CListFilterDescription.set_ShowEmptyValues(const Value: Boolean);
begin
  _ShowEmptyValues := Value;
end;

function CListFilterDescription.ToSortDescription: IListSortDescription;
begin
  Result := CListSortDescription.Create(ListSortDirection.Ascending);
end;

{ CListFilterDescriptionWithComparer }

constructor CListFilterDescriptionWithComparer.Create(const Comparer: IComparer<CObject>);
begin
  _Comparer := Comparer;
end;

function CListFilterDescriptionWithComparer.get_Comparer: IComparer<CObject>;
begin
  Result := _Comparer;
end;

function CListFilterDescriptionWithComparer.IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean;
begin
  Result := (_Comparer = nil) or (_Comparer.Compare(Value, nil) = 0);
end;

function CListFilterDescriptionWithComparer.ToSortDescription: IListSortDescription;
begin
  Result := CListSortDescriptionWithComparer.Create(ListSortDirection.Ascending, _Comparer);
end;

{ CListFilterByText }

constructor CListFilterDescriptionForText.Create(const FilterText: CString) ;//; const Comparer: IComparer<CObject> = nil);
begin
  inherited Create; //(Comparer);
  _FilterText := FilterText;
end;

constructor CListFilterDescriptionForText.Create(const FilterText, PropertyName: CString); //; const Comparer: IComparer<CObject> = nil);
begin
  inherited Create; //(Comparer);
  _FilterText := FilterText;
  _PropertyName := PropertyName;
end;

function CListFilterDescriptionForText.GetFilterableValue(const AObject: CObject): CObject;
begin
  var prop := AObject.GetType.PropertyByName(_PropertyName);
  Result := prop.GetValue(AObject, []);
end;

function CListFilterDescriptionForText.get_FilterText: CString;
begin
  Result := _FilterText;
end;

function CListFilterDescriptionForText.get_PropertyName: CString;
begin
  Result := _PropertyName;
end;

function CListFilterDescriptionForText.IsMatch(const Value: CObject; DataIndex: Integer = -1): Boolean;
var
  prop: _PropertyInfo;
  data: CObject;
  datalist: IList;
  searchObj: CObject;
begin
  {$IFNDEF WEBASSEMBLY}
  if Value = nil then
    Exit(True);

  if not CString.IsNullOrEmpty(_PropertyName) and not CString.Equals(_PropertyName, '[Object]') then
    prop := Value.GetType.PropertyByName(_PropertyName) else
    prop := nil;

  if (prop <> nil) then
    data := prop.GetValue(Value, []) else
    data := Value;

  if (data <> nil) then
  begin
    datalist := nil;
    if not data.IsInterface or not data.TryAsType<IList>(datalist) then
      searchObj := data;

    if datalist <> nil then
    begin
      Result := False;
      for searchObj in datalist do
        if inherited IsMatch(searchObj, DataIndex) and MatchText(searchObj.ToString) then
          Exit(True);
    end else
      Result := MatchText(searchObj.ToString);
  end else
    Result := _ShowEmptyValues;
  {$ELSE}
  raise NotImplementedException.Create('function CListFilterDescriptionForText.IsMatch(const Value: CObject): Boolean');
  {$ENDIF}
end;

function CListFilterDescriptionForText.MatchText(const TextData: CString): Boolean;
begin
  if CString.IsNullOrEmpty(TextData) then
    Result := _ShowEmptyValues or CString.IsNullOrEmpty(_FilterText)
  else if not CString.IsNullOrEmpty(_FilterText) then
    Result := TextData.ToLower.Contains(_FilterText.ToLower)
  else
    Result := True;
end;

function CListFilterDescriptionForText.ToSortDescription: IListSortDescription;
begin
  Result := CListSortDescriptionWithProperty.Create(ListSortDirection.Ascending, _PropertyName);
end;

{ TEditableObjectSupport }

procedure TEditableObjectSupport.BeginEdit;
var
  i: Integer;

begin
  _properties := _target.GetType.GetProperties;
  if _properties = nil then
    Exit;

  SetLength(_data, Length(_properties));

  for i := 0 to High(_properties) do
    _data[i] := _properties[i].GetValue(_target, []);
end;

procedure TEditableObjectSupport.CancelEdit;
var
  i: Integer;

begin
  if _properties = nil then
    Exit;

  for i := 0 to High(_properties) do
    _properties[i].SetValue(_target, _data[i], []);

  Finalize(_data);
end;

constructor TEditableObjectSupport.Create(const Target: CObject);
begin
  inherited Create;
  _target := Target;
end;

procedure TEditableObjectSupport.EndEdit;
begin
  Finalize(_data);
end;

{ TRemoteQueryControllerSupport }

function  TRemoteQueryControllerSupport.get_InterfaceComponentReference: IInterfaceComponentReference;
begin
  Result := _InterfaceComponentReference;
end;

procedure TRemoteQueryControllerSupport.set_InterfaceComponentReference(const Value: IInterfaceComponentReference);
begin
  _InterfaceComponentReference := Value;
end;

procedure TRemoteQueryControllerSupport.AddQueryController(const Value: IInterface);
begin
  SetLength(_QueryControllers, Length(_QueryControllers) + 1);
  {$IFDEF DELPHI}
  _QueryControllers[High(_QueryControllers)] := Pointer(Value);
  {$ELSE}
  _QueryControllers[High(_QueryControllers)] := Value;
  {$ENDIF}
end;

procedure TRemoteQueryControllerSupport.RemoveQueryController(const Value: IInterface);
var
  i, y: Integer;

begin
  for i := 0 to High(_QueryControllers) do
  begin
    {$IFDEF DELPHI}
    if _QueryControllers[i] = Pointer(Value) then
    begin
      for y := i to High(_QueryControllers) - 1 do
        _QueryControllers[y] := _QueryControllers[y+1];
      SetLength(_QueryControllers, High(_QueryControllers));
      Exit;
    end;
    {$ELSE}
    if _QueryControllers[i] = Value then
    begin
      for y := i to High(_QueryControllers) - 1 do
        _QueryControllers[y] := _QueryControllers[y+1];
      SetLength(_QueryControllers, High(_QueryControllers));
      Exit;
    end;
    {$ENDIF}
  end;

  Assert(False, 'QueryController could not be found');
end;
//
function TRemoteQueryControllerSupport.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  {$IFDEF DELPHI}
  GUID_IInterfaceComponentReference: TGUID = '{E28B1858-EC86-4559-8FCD-6B4F824151ED}';
  {$ELSE}
  GUID_IInterfaceComponentReference: TGUID = TGuid.Parse('{E28B1858-EC86-4559-8FCD-6B4F824151ED}');
  {$ENDIF}

var
  i: Integer;

begin
  {$IFDEF DELPHI}
  if (_InterfaceComponentReference <> nil) and IsEqualGUID(IID, GUID_IInterfaceComponentReference) then
  begin
    Pointer(Obj) := _InterfaceComponentReference;
    if Pointer(Obj) <> nil then IInterface(Obj)._AddRef;
    Result := 0;
  end
  else if GetInterface(IID, Obj) then
    Result := 0
  else
  begin
    i := 0;
    Result := E_NOINTERFACE;
    while (Result = E_NOINTERFACE) and (i <= High(_QueryControllers)) do
    begin
      Result := IInterface(_QueryControllers[i]).QueryInterface(IID, Obj);
      inc(i);
    end;
  end;
  {$ENDIF}
end;

function TRemoteQueryControllerSupport.DotNetQueryInterface<T>: T;
begin
  Result := Default(T);

  {$IFDEF LYNXWEB}
  for item in _QueryControllers do
  begin
    if Interfaces.Supports<T>(item, out Result) then
      Exit(Result);
  end;
  {$ENDIF}
end;

end.


