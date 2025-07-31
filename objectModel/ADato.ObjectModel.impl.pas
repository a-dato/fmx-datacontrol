﻿{$IFNDEF WEBASSEMBLY}
{$I ADato.inc}
{$ENDIF}

unit ADato.ObjectModel.impl;

interface

uses
  {$IFDEF DELPHI}
  System.TypInfo,
  System.SysUtils,
  System.ComponentModel,
  {$ELSE}
  System.Reflection,
  ADato.TypeCustomization,
  Wasm.System.ComponentModel,
  {$ENDIF}
  System_,
  System.Collections,
  System.Collections.Generic,
  ADato.ObjectModel.intf
  {$IFDEF APP_PLATFORM}
  , App.PropertyDescriptor.intf
  {$ENDIF}
  ;

type
  TOrdinalTypeObjectModel = {$IFDEF DOTNET}public{$ENDIF}class(TBaseInterfacedObject, IObjectModel)
  protected
    _ObjectType: &Type;

    {$IFDEF DOTNET}
    function  GetTypeEx: &Type;
    {$ENDIF}

    function  GetType: &Type; {$IFDEF DELPHI}override;{$ENDIF}
    function  CreateObjectModelContext : IObjectModelContext;
    function  CreateInstance(const AObjectType: &Type): IObjectModel; virtual;
  public
    constructor Create(const AObjectType: &Type); virtual;

    procedure ResetModelProperties; virtual;
  end;

  TObjectModel = class(TOrdinalTypeObjectModel, IUpdatableObject)
  {$IFDEF DELPHI}
  protected
  {$ELSE}
  public
  {$ENDIF}
    _PropertyInfoArray: PropertyInfoArray;
    _UpdateCount: Integer;

    function  CreateInstance(const AObjectType: &Type): IObjectModel; override;

    // IUpdatableObject
    procedure BeginUpdate;
    procedure EndUpdate;

    function  GetPropertiesExternal: PropertyInfoArray;
    procedure TypePropertiesChanged(const AType: &Type);
  public
    constructor Create(const AObjectType: &Type); override;
    destructor Destroy; override;
    procedure ResetModelProperties; override;
  end;

  TObjectModelContext = class(TBaseInterfacedObject, IObjectModelContext, IUpdatableObject)
  protected
    _BoundProperties: List<_PropertyInfo>;
    _Context: CObject;
    _Model: IObjectModel;
    _OnContextCanChange: ContextCanChangeEventHandler;
    _OnContextChanging: ContextChangingEventHandler;
    _OnContextChanged: ContextChangedEventHandler;
    _OnPropertyChanged : PropertyChangedEventHandler;
    _UpdateCount: Integer;
//    _ContextChangingExecuted: Boolean;

    procedure BeginUpdate;
    procedure EndUpdate;

    function  get_Context: CObject;
    procedure set_Context(const Value: CObject); virtual;
    function  get_OnContextCanChange: ContextCanChangeEventHandler;
    function  get_OnContextChanging: ContextChangingEventHandler;
    function  get_OnContextChanged: ContextChangedEventHandler;
    function  get_OnPropertyChanged: PropertyChangedEventHandler;

    function  get_Model: IObjectModel;

    function  ContextCanChange : Boolean;
    procedure DoContextChanging; virtual;
    procedure DoContextChanged; virtual;

    procedure Bind(const AProperty: _PropertyInfo; const ABinding: IPropertyBinding); overload; virtual;
    procedure Bind(const PropName: string; const ABinding: IPropertyBinding); overload; virtual;
    procedure Link(const AProperty: _PropertyInfo; const ABinding: IPropertyBinding); overload; virtual;
    procedure Link(const PropName: string; const ABinding: IPropertyBinding); overload; virtual;
    procedure Unbind({const} ABinding: IPropertyBinding); overload;
    procedure Unbind; overload; virtual;

    function  CheckValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject) : Boolean; virtual;
    procedure PropertyNotifyBindings(const AProperty: IObjectModelProperty);

    procedure UpdateValue(const AProperty: _PropertyInfo; const Value: CObject; ExecuteTriggers: Boolean);
    procedure UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean); overload;  virtual;
    procedure UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean); overload; virtual;

    procedure UpdatePropertyBindingValues; overload; virtual;
    procedure UpdatePropertyBindingValues(const APropertyName: CString); overload; virtual;
    procedure AddTriggersAsLinks(const ACustomProperty: ICustomProperty; const AccessoryProperties: List<_PropertyInfo>);
    function  HasBindings: Boolean;

  public
    constructor Create(const AModel: IObjectModel);
    destructor  Destroy; override;

    function  Equals(const other: CObject): Boolean; {$IFDEF DELPHI}override;{$ENDIF}

    {$IFDEF DOTNET}
    event OnContextCanChange: ContextCanChangeEventHandler delegate _OnContextCanChange;
    event OnContextChanging: ContextChangingEventHandler delegate _OnContextChanging;
    event OnContextChanged: ContextChangedEventHandler delegate _OnContextChanged;
    event OnPropertyChanged: PropertyChangedEventHandler delegate _OnPropertyChanged;

    procedure InvokeOnPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
    {$ENDIF}
  end;

  {$IFDEF APP_PLATFORM}
  TObjectModelPropertyWrapper = class(CPropertyWrapper, IObjectModelProperty, IPropertyDescriptor)
  protected
    FBindings: List<IPropertyBinding>;

    function  get_ContainedProperty: _PropertyInfo; virtual;
    function  get_Bindings: List<IPropertyBinding>;
    function  get_PropertyDescriptor: IPropertyDescriptor;

    function  GetObjectProperty(const obj: CObject): _PropertyInfo; virtual;

    procedure AddBinding(const ABinding: IPropertyBinding);
    procedure RemoveBinding(const ABinding: IPropertyBinding);
    procedure Unbind(const Context: IObjectModelContext);

    function  IsLink(const ABinding: IPropertyBinding): Boolean;
    procedure AddLink(const ABinding: IPropertyBinding);
    procedure RemoveLink(const ABinding: IPropertyBinding);
    procedure NotifyBindings(const Context, Value: CObject; NotifyLinks: Boolean);

    function  GetValue(const obj: CObject; const index: array of CObject): CObject; override;
    procedure SetValue(const obj: CObject; const value: CObject; const index: array of CObject; ExecuteTriggers: Boolean = false); override;

  public
    constructor Create(const AProperty: _PropertyInfo);
    destructor Destroy; override;

    property PropertyDescriptor: IPropertyDescriptor read get_PropertyDescriptor implements IPropertyDescriptor;

  end;
  {$ELSE}
  TObjectModelPropertyWrapper = class({$IFDEF DELPHI}TBaseInterfacedObject, _PropertyInfo{$ELSE}CPropertyInfo, ITBaseInterfacedObject{$ENDIF}, IObjectModelProperty)
  public
    FContainedProperty: _PropertyInfo;
    FBindings: List<IPropertyBinding>;

    function  get_ContainedProperty: _PropertyInfo; virtual;
    function  get_Bindings: List<IPropertyBinding>;

    function  get_CanRead: Boolean; {$IFDEF DOTNET} override;  {$ENDIF}
    function  get_CanWrite: Boolean;{$IFDEF DOTNET} override;  {$ENDIF}
    function  get_Name: CString;    {$IFDEF DOTNET} override;  {$ENDIF}

    {$IFDEF DELPHI}
    function  get_OwnerType: &Type;
    function  get_PropInfo: IPropInfo;
    {$ENDIF}

    function  GetObjectProperty(const obj: CObject): _PropertyInfo; virtual;

    procedure AddBinding(const ABinding: IPropertyBinding);
    procedure RemoveBinding(const ABinding: IPropertyBinding);
    procedure Unbind(const Context: IObjectModelContext);

    function  IsLink(const ABinding: IPropertyBinding): Boolean;
    procedure AddLink(const ABinding: IPropertyBinding);
    procedure RemoveLink(const ABinding: IPropertyBinding);
    procedure NotifyBindings(const Context, Value: CObject; NotifyLinks: Boolean);

    function  GetType: &Type; {$IFDEF DELPHI}override;{$ENDIF}
    {$IFDEF DELPHI}
    function  IsIndexedProperty: Boolean;
    function  GetAttributes: TArray<TCustomAttribute>;
    {$ENDIF}
    function  GetValue(const obj: CObject; const index: array of CObject): CObject; {$IFDEF DOTNET} override;  {$ELSE} virtual; {$ENDIF}
    procedure SetValue(const obj: CObject; const value: CObject; const index: array of CObject; ExecuteTriggers: Boolean = false); {$IFDEF DOTNET} override; {$ELSE} virtual; {$ENDIF}

    property CanRead: Boolean read get_CanRead;
    property CanWrite: Boolean read get_CanWrite;
    property Name: CString read get_Name; {$IFDEF DOTNET}override;{$ENDIF}

  public
    constructor Create(const AProperty: _PropertyInfo);

    {$IFDEF DELPHI}
    destructor Destroy; override;
    {$ENDIF}
  end;
  {$ENDIF}

  {$IFDEF APP_PLATFORM}
  TPathProperty = class(CPropertyWrapper, IPropertyDescriptor, INotify)
  protected
    _propertyPath: TArray<_PropertyInfo>;

    function  get_PropertyDescriptor: IPropertyDescriptor;

    function  GetValue(const obj: CObject; const index: array of CObject): CObject; override;
    procedure SetValue(const obj: CObject; const Value: CObject; const index: array of CObject; ExecuteTriggers: Boolean = false); override;

    // INotify
    function  OnChanging(const Context: CObject; const Value: CObject) : CObject;
    procedure OnChanged(const Context: CObject; const Value: CObject);

  public
    constructor Create(const AProperty: _PropertyInfo; const APropertyPath: TArray<_PropertyInfo>);
    destructor Destroy; override;

    property PropertyDescriptor: IPropertyDescriptor read get_PropertyDescriptor implements IPropertyDescriptor;
  end;
  {$ENDIF}

implementation

uses
  ADato.Extensions.intf;

constructor TOrdinalTypeObjectModel.Create(const AObjectType: &Type);
begin
  inherited Create;
  _ObjectType := AObjectType;
end;

function TOrdinalTypeObjectModel.CreateInstance(const AObjectType: &Type): IObjectModel;
begin
  Result := TOrdinalTypeObjectModel.Create(AObjectType);
end;

function TOrdinalTypeObjectModel.GetType: &Type;
begin
  Result := _ObjectType;
end;

function TOrdinalTypeObjectModel.CreateObjectModelContext : IObjectModelContext;
begin
  Result := TObjectModelContext.Create(Self);
end;

procedure TOrdinalTypeObjectModel.ResetModelProperties;
begin
end;

{$IFDEF DOTNET}
function TOrdinalTypeObjectModel.GetTypeEx: &Type;
begin
  Result := _ObjectType;
end;
{$ENDIF}

constructor TObjectModelContext.Create(const AModel: IObjectModel);
begin
  inherited Create;
  _BoundProperties := CList<_PropertyInfo>.Create;
  _Model := AModel;

  {$IFDEF DELPHI}
  _OnContextCanChange := ContextCanChangeEventDelegate.Create;
  _OnContextChanging := ContextChangingEventDelegate.Create;
  _OnContextChanged := ContextChangedEventDelegate.Create;
  _OnPropertyChanged := PropertyChangedEventDelegate.Create;
  {$ENDIF}
end;

destructor TObjectModelContext.Destroy;
var
  {$IFDEF DELPHI}
  [unsafe]prop : _PropertyInfo;
  {$ELSE}
  prop : _PropertyInfo;
  {$ENDIF}

begin
  inherited;
  for prop in _BoundProperties do
    (prop as IObjectModelProperty).Unbind(Self);
end;

procedure TObjectModelContext.BeginUpdate;
begin
  inc(_UpdateCount);
end;

procedure TObjectModelContext.EndUpdate;
begin
  dec(_UpdateCount);
end;

function TObjectModelContext.get_Context: CObject;
begin
  Result := _Context;
end;

function TObjectModelContext.ContextCanChange : Boolean;
begin
  if _OnContextCanChange <> nil then
    Result := _OnContextCanChange.Invoke(Self, _Context) else
    Result := True;
end;

procedure TObjectModelContext.DoContextChanging;
begin
  if _OnContextChanging <> nil then
	  _OnContextChanging.Invoke(Self, _Context);
end;

procedure TObjectModelContext.DoContextChanged;
begin
  if _OnContextChanged <> nil then
	  _OnContextChanged.Invoke(Self, _Context);
end;

function TObjectModelContext.get_OnContextCanChange: ContextCanChangeEventHandler;
begin
 Result := _OnContextCanChange;
end;

function TObjectModelContext.get_OnContextChanging: ContextChangingEventHandler;
begin
 Result := _OnContextChanging;
end;

function TObjectModelContext.get_OnContextChanged: ContextChangedEventHandler;
begin
 Result := _OnContextChanged;
end;

function TObjectModelContext.get_OnPropertyChanged: PropertyChangedEventHandler;
begin
  Result := _OnPropertyChanged;
end;

procedure TObjectModelContext.PropertyNotifyBindings(const AProperty: IObjectModelProperty);
begin
  var value: CObject;
  if _Context <> nil then
    value := AProperty.GetValue(_Context, []) else
    value := nil;

  AProperty.NotifyBindings(_Context, value, False);
end;

procedure TObjectModelContext.set_Context(const Value: CObject);
begin
  // Check equality based on the internal object reference (DO not use Equals here)
  if CObject.ReferenceEquals(_Context, Value) then Exit;

  // if not _Context is clone (BeginEdit/CancelEdit)
  if _UpdateCount = 0 then
  begin
    if not ContextCanChange then Exit;

    DoContextChanging;
  end;

  _Context := Value;

  // due to override this will not be executed in BeginEdit
  UpdatePropertyBindingValues;

  // if not _Context is clone (BeginEdit/CancelEdit)
  if _UpdateCount = 0 then
    DoContextChanged;
end;

procedure TObjectModelContext.UpdatePropertyBindingValues(const APropertyName: CString);
var
  {$IFDEF DELPHI}
  [unsafe] prop: _PropertyInfo;
  {$ELSE}
  prop: _PropertyInfo;
  {$ENDIF}
begin
  for prop in _BoundProperties do
    if CString.Equals(prop.Name, APropertyName) then
      PropertyNotifyBindings(prop as IObjectModelProperty);
end;

procedure TObjectModelContext.UpdatePropertyBindingValues;
var
  {$IFDEF DELPHI}
  [unsafe] prop: _PropertyInfo;
  {$ELSE}
  prop: _PropertyInfo;
  {$ENDIF}
begin
  for prop in _BoundProperties do
    PropertyNotifyBindings(prop as IObjectModelProperty);
end;

function TObjectModelContext.HasBindings: Boolean;
begin
  Result := _BoundProperties.Count > 0;
end;

procedure TObjectModelContext.AddTriggersAsLinks(const ACustomProperty: ICustomProperty; const AccessoryProperties: List<_PropertyInfo>);
var
  cp: CustomProperty;
  {$IFDEF DELPHI}
  [unsafe] omProp: _PropertyInfo;
  [unsafe] modelProp: IObjectModelProperty;
  {$ELSE}
  omProp: _PropertyInfo;
  modelProp: IObjectModelProperty;
  {$ENDIF}
begin
  cp := ACustomProperty as CustomProperty;
  if CString.IsNullOrEmpty(cp.Trigger) then Exit;

  {$IFDEF DELPHI}
  omProp := _Model.GetType.PropertyByName(cp.Name);
  {$ELSE}
  omProp := _Model.GetType.GetProperty(cp.Name);
  {$ENDIF}

  var ap: _PropertyInfo;
  for ap in AccessoryProperties do
  begin
    if CObject.Equals(cp, ap) then Continue;

    // props are gettered by name
    if CString.Equals(cp.Name, ap.Name) then Continue;

    {$IFDEF DELPHI}
    modelProp := _Model.GetType.PropertyByName(ap.Name) as IObjectModelProperty;
    {$ELSE}
    modelProp := _Model.GetType.GetProperty(ap.Name) as IObjectModelProperty;
    {$ENDIF}

    if (modelProp = nil) then Continue;

    var binding: IPropertyBinding;
    for binding in modelProp.Bindings do
      if (binding.PropertyInfo <> nil) then
        Link(omProp, binding);
  end;
end;

function  TObjectModelContext.get_Model: IObjectModel;
begin
  Result := _Model;
end;

function TObjectModelContext.Equals(const other: CObject): Boolean;
var
  otherMdl: IObjectModelContext;
begin
  Result := other.TryAsType<IObjectModelContext>(otherMdl) and CObject.Equals(_Context, otherMdl.Context);
end;

procedure TObjectModelContext.Bind(const AProperty: _PropertyInfo; const ABinding: IPropertyBinding);
begin
  if AProperty = nil then
    raise ArgumentNullException.Create('AProperty');
  if ABinding = nil then
    raise ArgumentNullException.Create('ABinding');

  var prop: IObjectModelProperty;
  if Interfaces.Supports<IObjectModelProperty>(AProperty, prop) then
  begin
    prop.AddBinding(ABinding);
    ABinding.ObjectModelContext := Self;
    if not _BoundProperties.Contains(AProperty) then
      _BoundProperties.Add(AProperty);

    // Initialize binder with current property value
    PropertyNotifyBindings(prop);
  end else
    raise Exception.Create('Can only bind properties of type IObjectModelProperty');
end;

procedure TObjectModelContext.Bind(const PropName: string; const ABinding: IPropertyBinding);
begin
  {$IFDEF DELPHI}
  Bind(_Model.GetType.PropertyByName(PropName), ABinding);
  {$ELSE}
  Bind(_Model.GetTypeEx().GetProperty(PropName), ABinding);
  {$ENDIF}
end;

procedure TObjectModelContext.Link(const AProperty: _PropertyInfo; const ABinding: IPropertyBinding);
begin
  if AProperty = nil then
    raise ArgumentNullException.Create('AProperty');
  if ABinding = nil then
    raise ArgumentNullException.Create('ABinding');

  var o_prop: IObjectModelProperty;
  if Interfaces.Supports<IObjectModelProperty>(AProperty, o_prop) then
  begin
    Assert(AProperty <> ABinding.PropertyInfo);

    o_prop.AddLink(ABinding);
    if not _BoundProperties.Contains(AProperty) then
      _BoundProperties.Add(AProperty);
  end else
    raise Exception.Create('Can only link properties of type IObjectModelProperty');
end;

procedure TObjectModelContext.Link(const PropName: string; const ABinding: IPropertyBinding);
begin
  {$IFDEF DELPHI}
  Link(_Model.GetType.PropertyByName(PropName), ABinding);
  {$ELSE}
  Link(_Model.GetTypeEx().GetProperty(PropName), ABinding);
  {$ENDIF}
end;

procedure TObjectModelContext.Unbind({const} ABinding: IPropertyBinding);
var
  p: _PropertyInfo;
  pp: IObjectModelProperty;
begin
  var selected_pp: IObjectModelProperty := nil;

  var pInfo := ABinding.PropertyInfo;
  for p in _BoundProperties do
  begin
    if not Interfaces.Supports<IObjectModelProperty>(p, pp) then
    begin
      // shouldn't get here
      Assert(False);
      Continue;
    end;

    if (pInfo = p) then
      selected_pp := pp;

    pp.RemoveLink(ABinding);
  end;

  if selected_pp <> nil then
  begin
    selected_pp.RemoveBinding(ABinding);
    if selected_pp.Bindings.Count = 0 then
      _BoundProperties.Remove(selected_pp as _PropertyInfo);
  end;
end;

procedure TObjectModelContext.Unbind;
var
  p: _PropertyInfo;
  pp: IObjectModelProperty;
begin
  for p in _BoundProperties do
    if Interfaces.Supports<IObjectModelProperty>(p, pp) then
      pp.Unbind(Self);
  _BoundProperties := CList<_PropertyInfo>.Create;
end;

function TObjectModelContext.CheckValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject) : Boolean;
begin
  Result := True;
end;

procedure TObjectModelContext.UpdateValueFromBoundProperty(const APropertyName: CString; const Value: CObject; ExecuteTriggers: Boolean);
var
  prop: _PropertyInfo;
begin
  {$IFDEF DELPHI}
  prop := _Model.GetType.PropertyByName(APropertyName);
  {$ELSE}
  prop := _Model.GetType.GetProperty(APropertyName);
  {$ENDIF}
  UpdateValue(prop, Value, ExecuteTriggers);
end;

procedure TObjectModelContext.UpdateValueFromBoundProperty(const ABinding: IPropertyBinding; const Value: CObject; ExecuteTriggers: Boolean);
begin
  UpdateValue(ABinding.PropertyInfo, Value, ExecuteTriggers);
end;

procedure TObjectModelContext.UpdateValue(const AProperty: _PropertyInfo; const Value: CObject; ExecuteTriggers: Boolean);
begin
  Assert(AProperty.CanWrite, 'Property can''t write');
  (AProperty as TObjectModelPropertyWrapper).SetValue(_Context, Value, [], ExecuteTriggers);

	if(_OnPropertyChanged <> nil) then
    _OnPropertyChanged.Invoke(Self, _Context, AProperty);
end;

{ TObjectModel }
constructor TObjectModel.Create(const AObjectType: &Type);
begin
  inherited Create(AObjectType);

  {$IFDEF DELPHI}
  _ObjectType.GetPropertiesExternal := GetPropertiesExternal;
  GetType.GetProperties;
  {$ELSE}
  _ObjectType := new TypeExtensions(_ObjectType);
  TypeExtensions(_ObjectType).GetPropertiesExternal := @GetPropertiesExternal;
  GetTypeEx.GetProperties;
  {$ENDIF}

  if ExtensionManager <> nil then
  begin
    {$IFDEF DELPHI}
    ExtensionManager.OnTypePropertiesChanged.Add(TypePropertiesChanged);
    {$ELSE}
    ExtensionManager.OnTypePropertiesChanged += @TypePropertiesChanged;
    {$ENDIF}
  end;
end;

destructor TObjectModel.Destroy;
begin
  if ExtensionManager <> nil then
  begin
    {$IFDEF DELPHI}
    ExtensionManager.OnTypePropertiesChanged.Remove(TypePropertiesChanged);
    {$ELSE}
    ExtensionManager.OnTypePropertiesChanged -= @TypePropertiesChanged;
    {$ENDIF}
  end;
  inherited;
end;

function TObjectModel.CreateInstance(const AObjectType: &Type): IObjectModel;
begin
  Result := TObjectModel.Create(AObjectType);
end;

procedure TObjectModel.BeginUpdate;
begin
  inc(_UpdateCount);
end;

procedure TObjectModel.EndUpdate;
begin
  dec(_UpdateCount);
end;

procedure TObjectModel.TypePropertiesChanged(const AType: &Type);
begin
  _PropertyInfoArray := nil;
end;

function TObjectModel.GetPropertiesExternal: PropertyInfoArray;
begin
  if _PropertyInfoArray = nil then
  begin
    var props: PropertyInfoArray;
    if GlobalTypeDescriptor <> nil then
      props := GlobalTypeDescriptor.GetProperties(_ObjectType)
    else
      props := GetPropertiesFromType(_ObjectType,
          function(const OwnerType: &Type; const PropertyType: &Type; PropInfo: IPropInfo) : _PropertyInfo begin
            Result := CPropertyInfo.Create(OwnerType, PropertyType, PropInfo);
          end);

    SetLength(_PropertyInfoArray, Length(props));
    var i : Integer;
    for i := 0 to High(props) do
      _PropertyInfoArray[i] := TObjectModelPropertyWrapper.Create(props[i]) as _PropertyInfo;
  end;
  Result := _PropertyInfoArray;
end;

procedure TObjectModel.ResetModelProperties;
begin
  _PropertyInfoArray := nil;
end;

//function TObjectModel.PropertyByName(const Name: string): _PropertyInfo;
//begin
//   Result := &Array.Find(_ObjectType.GetProperties(), (prop) -> prop.Name.Equals(name));
//
//   //Result := Self.GetProperty(Name);
//  //Result := Self.GetProperty(Name);
//end;

{ TObjectModelPropertyWrapper }

procedure TObjectModelPropertyWrapper.AddBinding(const ABinding: IPropertyBinding);
begin
  FBindings.Add(ABinding);
  ABinding.PropertyInfo := Self;
end;

procedure TObjectModelPropertyWrapper.RemoveBinding(const ABinding: IPropertyBinding);
begin
  if FBindings.Remove(ABinding) then
  begin
    ABinding.PropertyInfo := nil;
//    ABinding.ObjectModelContext := nil;
  end;
end;

procedure TObjectModelPropertyWrapper.Unbind(const Context: IObjectModelContext);
var
  b: IPropertyBinding;
  i: Integer;
begin
  for i := FBindings.Count-1 downto 0 do
  begin
    b := FBindings[i];
    if b.ObjectModelContext = Context then
    begin
      RemoveBinding(b);
      b := nil;
    end;
  end;
end;

procedure TObjectModelPropertyWrapper.AddLink(const ABinding: IPropertyBinding);
begin
  FBindings.Add(ABinding);
end;

procedure TObjectModelPropertyWrapper.RemoveLink(const ABinding: IPropertyBinding);
begin
  FBindings.Remove(ABinding);
end;

function TObjectModelPropertyWrapper.IsLink(const ABinding: IPropertyBinding): Boolean;
begin
  Assert(ABinding.PropertyInfo <> nil, 'binding should be set');
  Result := not ABinding.PropertyInfo.Equals(Self);
end;

procedure TObjectModelPropertyWrapper.NotifyBindings(const Context, Value: CObject; NotifyLinks: Boolean);
begin
  var b: IPropertyBinding;
  for b in FBindings do
    if (NotifyLinks or not IsLink(b)) and CObject.Equals(b.ObjectModelContext.Context, Context) then
      b.SetValue(Self, Context, Value);
end;

{$IFDEF APP_PLATFORM}
constructor TObjectModelPropertyWrapper.Create(const AProperty: _PropertyInfo);
begin
  inherited;
  FBindings := CList<IPropertyBinding>.Create;
end;
{$ELSE}
constructor TObjectModelPropertyWrapper.Create(const AProperty: _PropertyInfo);
begin
  inherited Create;
  FContainedProperty := AProperty;
  FBindings := CList<IPropertyBinding>.Create;
end;
{$ENDIF}

{$IFDEF DELPHI}
destructor TObjectModelPropertyWrapper.Destroy;
begin
  inherited Destroy;
end;
{$ENDIF}

{$IFDEF APP_PLATFORM}
function TObjectModelPropertyWrapper.get_PropertyDescriptor: IPropertyDescriptor;
begin
  Interfaces.Supports<IPropertyDescriptor>(_property, Result);
end;

function TObjectModelPropertyWrapper.get_ContainedProperty: _PropertyInfo;
begin
  Result := _property;
end;
{$ELSE}
function TObjectModelPropertyWrapper.GetAttributes: TArray<TCustomAttribute>;
begin
  Result := FContainedProperty.GetAttributes;
end;

function TObjectModelPropertyWrapper.IsIndexedProperty: Boolean;
begin
  Result := FContainedProperty.IsIndexedProperty;
end;

function TObjectModelPropertyWrapper.GetType: &Type;
begin
  Result := FContainedProperty.GetType;
end;

function TObjectModelPropertyWrapper.get_CanRead: Boolean;
begin
  Result := FContainedProperty.get_Canread;
end;

function TObjectModelPropertyWrapper.get_CanWrite: Boolean;
begin
  Result := FContainedProperty.get_CanWrite;
end;

function TObjectModelPropertyWrapper.get_Name: CString;
begin
  Result := get_ContainedProperty.get_Name;
end;

{$IFDEF DELPHI}
function TObjectModelPropertyWrapper.get_OwnerType: &Type;
begin
  Result := FContainedProperty.get_OwnerType;
end;

function TObjectModelPropertyWrapper.get_PropInfo: IPropInfo;
begin
  Result := FContainedProperty.get_PropInfo;
end;
{$ENDIF}

function TObjectModelPropertyWrapper.get_ContainedProperty: _PropertyInfo;
begin
  Result := FContainedProperty;
end;

{$ENDIF}

function TObjectModelPropertyWrapper.GetValue(const obj: CObject; const index: array of CObject): CObject;
begin
  Result := GetObjectProperty(obj).GetValue(obj, index);
end;

function TObjectModelPropertyWrapper.get_Bindings: List<IPropertyBinding>;
begin
  Result := FBindings;
end;

function TObjectModelPropertyWrapper.GetObjectProperty(const obj: CObject): _PropertyInfo;
begin
  Result := get_ContainedProperty;
end;

procedure TObjectModelPropertyWrapper.SetValue(const Obj, Value: CObject; const Index: array of CObject; ExecuteTriggers: Boolean);
begin
  {$IFDEF DELPHI}
  GetObjectProperty(obj).SetValue(Obj, Value, Index, ExecuteTriggers);
  {$ELSE}
  GetObjectProperty(obj).SetValue(Obj, Value, Index);
  {$ENDIF}

  NotifyBindings(Obj, Value, True);
end;

{$IFDEF DOTNET}
procedure TObjectModelContext.InvokeOnPropertyChanged(const Sender: IObjectModelContext; const Context: CObject; const AProperty: _PropertyInfo);
begin
  _OnPropertyChanged.Invoke(Sender, Context, AProperty);
end;
{$ENDIF}

{$IFDEF APP_PLATFORM}
constructor TPathProperty.Create(const AProperty: _PropertyInfo; const APropertyPath: TArray<_PropertyInfo>);
begin
  inherited Create(AProperty);
  _propertyPath := APropertyPath;

  var notify: INotifyPropertyChanged;
  if (Length(_propertyPath) > 0) and Interfaces.Supports<INotifyPropertyChanged>(_propertyPath[0], notify) then
    notify.Add(Self);
end;

destructor TPathProperty.Destroy;
begin
  var notify: INotifyPropertyChanged;
  if (Length(_propertyPath) > 0) and Interfaces.Supports<INotifyPropertyChanged>(_propertyPath[0], notify) then
    notify.Remove(Self);
  inherited;
end;

function TPathProperty.get_PropertyDescriptor: IPropertyDescriptor;
begin
  Interfaces.Supports<IPropertyDescriptor>(_property, Result);
end;

procedure TPathProperty.OnChanged(const Context, Value: CObject);
begin
  if Value = nil then;
end;

function TPathProperty.OnChanging(const Context, Value: CObject): CObject;
begin
  var val := Value;

  for var i := 1 to High(_propertyPath) do
  begin
    val := _propertyPath[i].GetValue(val, []);
    if val = nil then
      Exit;
  end;

  SetValue(Context, val, [], True);
end;

function TPathProperty.GetValue(const obj: CObject; const index: array of CObject): CObject;
begin
  Result := inherited GetValue(obj, index);

//  Result := _propertyPath[0].GetValue(obj, []);
//  if Result = nil then
//    Exit;
//
//  for var i := 1 to High(_propertyPath) do
//  begin
//    Result := _propertyPath[i].GetValue(Result, []);
//    if Result = nil then
//      Exit;
//  end;
end;

procedure TPathProperty.SetValue(const obj: CObject; const Value: CObject; const index: array of CObject; ExecuteTriggers: Boolean = false);
begin
  inherited;
end;
{$ENDIF}

end.


