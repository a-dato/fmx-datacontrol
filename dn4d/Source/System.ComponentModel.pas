{$I Adato.inc}

unit System.ComponentModel;

interface

uses
  TypInfo,
  Classes,
  Generics.Defaults,
  // Dialogs,
  System_,
  System.Collections,
  System.Runtime.Serialization;

type
  {$M+}
  IUpdatableObject = interface
    ['{3A369F1E-AC6C-4CD0-8A87-E2C41D4C579D}']
    procedure BeginUpdate;
    procedure EndUpdate;
  end;

  ICancelAddNew = interface(IBaseInterface)
    ['{CF222852-2560-41F9-A442-F30987CC75D5}']
    procedure CancelNew(itemIndex: Integer);
    procedure EndNew(itemIndex: Integer);
  end;

  IEditableObject = interface(IBaseInterface)
    ['{A8187702-0663-4648-8D3D-6EA1ED05EAEB}']
    procedure BeginEdit;
    procedure CancelEdit;
    procedure EndEdit;
  end;

  AddingNewEventArgs = class(EventArgs)
  protected
    _NewObject: CObject;

    function  get_NewObject: CObject;
    procedure set_NewObject(const Value: CObject);
  public
    property NewObject: CObject read get_NewObject write set_NewObject;
  end;

  AddingNewEventHandler = procedure(  Sender: TObject;
                                      Args: AddingNewEventArgs) of object;

  CancelEventArgs = class(EventArgs)
  private
    _Cancel: Boolean;

  public
    property Cancel: Boolean
      read  _Cancel
      write _Cancel;
  end;

  ListSortDirectionFlag = (SortDirection_Ascending, SortDirection_Descending);
  ListSortDirection = record
  const
    Ascending = ListSortDirectionFlag.SortDirection_Ascending;
    Descending = ListSortDirectionFlag.SortDirection_Descending;

  private
    Value: ListSortDirectionFlag;

  public
    function ToMultiplier: Integer;

    class operator Equal(L, R: ListSortDirection) : Boolean;
    class operator NotEqual(L, R: ListSortDirection) : Boolean;

    class operator Implicit(AValue: ListSortDirection) : ListSortDirectionFlag;
    class operator Implicit(AValue: ListSortDirectionFlag) : ListSortDirection;
  end;

  ListChangedTypeFlag = (
    ListChangedType_ItemAdded=1,
    ListChangedType_ItemDeleted=2,
    ListChangedType_ItemMoved=3,
    ListChangedType_ItemChanged=4,
    ListChangedType_ItemCancelled=8,
    ListChangedType_PropertyDescriptorAdded=5,
    ListChangedType_PropertyDescriptorChanged=7,
    ListChangedType_PropertyDescriptorDeleted=6,
    ListChangedType_Exception=9,
    ListChangedType_Reset=0
  );

  ListChangedType = record
  const
    ItemAdded = ListChangedTypeFlag.ListChangedType_ItemAdded;
    ItemChanged = ListChangedTypeFlag.ListChangedType_ItemChanged;
    ItemDeleted = ListChangedTypeFlag.ListChangedType_ItemDeleted;
    ItemMoved = ListChangedTypeFlag.ListChangedType_ItemMoved;
    ItemCancelled = ListChangedTypeFlag.ListChangedType_ItemCancelled;
    PropertyDescriptorAdded = ListChangedTypeFlag.ListChangedType_PropertyDescriptorAdded;
    PropertyDescriptorChanged = ListChangedTypeFlag.ListChangedType_PropertyDescriptorChanged;
    PropertyDescriptorDeleted = ListChangedTypeFlag.ListChangedType_PropertyDescriptorDeleted;
    Reset = ListChangedTypeFlag.ListChangedType_Reset;
    Exception = ListChangedTypeFlag.ListChangedType_Exception;

  private
    Value: ListChangedTypeFlag;

  public
    class operator Equal(const L, R: ListChangedType) : Boolean;
    class operator NotEqual(const L, R: ListChangedType) : Boolean;
    class operator Implicit(const AValue: ListChangedType) : Integer;
    class operator Implicit(AValue: ListChangedTypeFlag) : ListChangedType;
    class operator Implicit(const AValue: ListChangedType) : ListChangedTypeFlag;
  end;

  ListChangedEventArgs = class(EventArgs)
  protected
    _ListChangedType : ListChangedType;
    _NewIndex : Integer;
    _OldIndex : Integer;

  public
    constructor Create(AListChangedType: ListChangedType; ANewIndex: Integer); overload;
    constructor Create(AListChangedType: ListChangedType; ANewIndex: Integer; AOldIndex: Integer); overload;

    property ListChangedType: ListChangedType
      read _ListChangedType;
    property NewIndex: Integer
      read _NewIndex;
    property OldIndex: Integer
      read _OldIndex;
    // property PropertyDescriptor: PropertyDescriptor read get_PropertyDescriptor;
  end;

  ListChangedEventHandlerProc = procedure(  Sender: TObject;
                                            Args: ListChangedEventArgs) of object;

  ListChangedEventHandler = interface(IDelegate)
    procedure Add(Value: ListChangedEventHandlerProc);
    procedure Remove(value: ListChangedEventHandlerProc);
    procedure Invoke(Sender: TObject; Args: ListChangedEventArgs);
  end;

  ListChangedDelegate = class(
    Delegate,
    ListChangedEventHandler)

  protected
    procedure Add(Value: ListChangedEventHandlerProc);
    procedure Remove(value: ListChangedEventHandlerProc);
    procedure Invoke(Sender: TObject; Args: ListChangedEventArgs);
  end;

  PropertyChangedEventArgs = class(EventArgs)
  public
    PropertyName: CString;

    constructor Create(const AName: CString);
  end;

  PropertyChangedEventHandlerProc = procedure(Sender: TObject; Args: PropertyChangedEventArgs) of object;

  PropertyChangedEventHandler = interface(IDelegate)
    procedure Add(Value: PropertyChangedEventHandlerProc);
    procedure Remove(value: PropertyChangedEventHandlerProc);

    // Need to use CObject here so that we can pass Interfaces as well
    procedure Invoke(Sender: TObject; Args: PropertyChangedEventArgs);
  end;

  PropertyChangedDelegate = class(
    Delegate,
    PropertyChangedEventHandler)

  protected
    procedure Add(Value: PropertyChangedEventHandlerProc);
    procedure Remove(value: PropertyChangedEventHandlerProc);
    procedure Invoke(Sender: TObject; Args: PropertyChangedEventArgs);
  end;

  INotifyPropertyChanged = interface(IBaseInterface)
    ['{BA8CAFF6-54B2-4385-8456-4E7FB03D5C07}']
    function  get_PropertyChanged: PropertyChangedEventHandler;

    property PropertyChanged: PropertyChangedEventHandler
      read  get_PropertyChanged;
  end;

{$M+}
  TSerializableObject = class(
    TBaseInterfacedObject,
    ISerializable)

  protected
    // function  GetType: &Type; override;

    // ISerializable implementation
    procedure GetObjectData(const info: SerializationInfo; const context: StreamingContext); virtual;
    procedure SetObjectData(const info: SerializationInfo; const context: StreamingContext); virtual;

  public
    // Must declare (empty) virtual constructor
    // This constrcutor will be called whenever a new object is created
    // through Assembly.CreateInstanceFrom()
    constructor Create; virtual;

  end;
{$M-}

  SerializableClass = class of TSerializableObject;

  StandardValuesCollection = interface(ICollection)

  end;

  ITypeDescriptorContext = interface(IBaseInterface)
    ['{C560C397-CC14-46DE-A450-308E4E462B0B}']
  end;

  ITypeConverter = interface(IBaseInterface)
    ['{F268B921-B4D1-46C7-A8A8-96469BB5835A}']

    function GetStandardValues: ICollection; overload;
    function GetStandardValues(const context: ITypeDescriptorContext): StandardValuesCollection; overload;
  end;

  TypeConverter = class(TBaseInterfacedObject, ITypeConverter)
  type
    CStandardValuesCollection = class(
      TBaseInterfacedObject,
      StandardValuesCollection,
      ICollection,
      IEnumerable)

      // Fields
//    private
//      values: ICollection;

    protected
      function  get_InnerType: &Type;
      function  get_Count: Integer;
      function  get_Item(Index: Integer) : CObject;
      function  get_IsSynchronized: Boolean;
      function  get_SyncRoot: TObject;

    public
      constructor Create(const values: ICollection);
      procedure CopyTo(var a: CObject.ObjectArray; arrayIndex: Integer);
      function GetEnumerator: IEnumerator;

      // Properties
      property Count: Integer read get_Count;
      property Item[index: Integer]: CObject read get_Item;
    end;

  public
    function GetStandardValues: ICollection; overload; virtual;
    function GetStandardValues(const context: ITypeDescriptorContext): StandardValuesCollection; overload; virtual;
  end;

implementation

uses
  SysUtils,
  Variants;

{ ListChangedType }

class operator ListChangedType.Equal(const L, R: ListChangedType) : Boolean;
begin
  Result := L.Value = R.Value;
end;

class operator ListChangedType.NotEqual(const L, R: ListChangedType) : Boolean;
begin
  Result := L.Value <> R.Value;
end;

class operator ListChangedType.Implicit(AValue: ListChangedTypeFlag) : ListChangedType;
begin
  Result.Value := AValue;
end;

class operator ListChangedType.Implicit(const AValue: ListChangedType) : ListChangedTypeFlag;
begin
  Result := AValue.Value;
end;

class operator ListChangedType.Implicit(const AValue: ListChangedType) : Integer;
begin
  Result := Integer(AValue.Value);
end;

class operator ListSortDirection.Equal(L, R: ListSortDirection) : Boolean;
begin
  Result := L.Value = R.Value;
end;

class operator ListSortDirection.NotEqual(L, R: ListSortDirection) : Boolean;
begin
  Result := L.Value <> R.Value;
end;

function ListSortDirection.ToMultiplier: Integer;
begin
  if value = Ascending then
    Result := 1 else
    Result := -1;
end;

class operator ListSortDirection.Implicit(AValue: ListSortDirection) : ListSortDirectionFlag;
begin
  Result := AValue.Value;
end;

class operator ListSortDirection.Implicit(AValue: ListSortDirectionFlag) : ListSortDirection;
begin
  Result.Value := AValue;
end;

function AddingNewEventArgs.get_NewObject: CObject;
begin
  Result := _NewObject;
end;

procedure AddingNewEventArgs.set_NewObject(const Value: CObject);
begin
  _NewObject := Value;
end;

{ PropertyChangedDelegate }

procedure PropertyChangedDelegate.Add(Value: PropertyChangedEventHandlerProc);
begin
  inherited Add(TMethod(Value));
end;

procedure PropertyChangedDelegate.Invoke(Sender: TObject; Args: PropertyChangedEventArgs);
var
  cnt: Integer;

begin
  cnt := 0;
  while cnt < _events.Count do
  begin
    PropertyChangedEventHandlerProc(_events[cnt]^)(Sender, Args);
    inc(cnt);
  end;
end;

procedure PropertyChangedDelegate.Remove(value: PropertyChangedEventHandlerProc);
begin
  inherited Remove(TMethod(Value));
end;

{ PropertyChangedEventArgs }

constructor PropertyChangedEventArgs.Create(const AName: CString);
begin
  inherited Create;
  PropertyName := AName;
end;

{ ListChangedEventArgs }

constructor ListChangedEventArgs.Create(
  AListChangedType: ListChangedType;
  ANewIndex: Integer);
begin
  _ListChangedType := AListChangedType;
  _NewIndex := ANewIndex;
  _OldIndex := -1;
end;

constructor ListChangedEventArgs.Create(
  AListChangedType: ListChangedType;
  ANewIndex, AOldIndex: Integer);
begin
  _ListChangedType := AListChangedType;
  _NewIndex := ANewIndex;
  _OldIndex := AOldIndex;
end;

{ ListChangedDelegate }

procedure ListChangedDelegate.Add(Value: ListChangedEventHandlerProc);
begin
  inherited Add(TMethod(Value));
end;

procedure ListChangedDelegate.Invoke(
  Sender: TObject;
  Args: ListChangedEventArgs);
var
  cnt: Integer;

begin
  cnt := 0;
  // for cnt := 0 to -1 + _events.Count do
  while cnt < _events.Count do
  begin
    ListChangedEventHandlerProc(_events[cnt]^)(Sender, Args);
    inc(cnt);
  end;
end;

procedure ListChangedDelegate.Remove(value: ListChangedEventHandlerProc);
begin
  inherited Remove(TMethod(Value));
end;

{ TSerializableObject }

constructor TSerializableObject.Create;
begin
  inherited Create;
end;

//function TSerializableObject.GetType: &Type;
//begin
//  // TSerializableObject get their properties from the Class type (not from the interface they implement)
//  // Without this change, property serialization/deserialization fails
//  Result := &Type.Create(TTypes.System_Interface, Self.ClassInfo);
//end;

procedure TSerializableObject.GetObjectData(
  const info: SerializationInfo;
  const context: StreamingContext);
var
  prop: _PropertyInfo;
  Properties: PropertyInfoArray;
  Value: CObject;

begin
  Properties := GetType.GetProperties;
  for prop in Properties do
  begin
    // Properties of type 'CObject' need special handling since type must
    // be written as well
    if prop.GetType.IsOfType<CObject> then
    begin
      Value := prop.GetValue(Self, []);
      if Value <> nil then
        info.AddObjectValue(prop.Name, Value);
    end
    else
    begin
      Value := prop.GetValue(Self, []);

      if prop.PropInfo.PropType^.Kind = tkEnumeration then
      begin
        if Value.IsNumber then
          Value := GetEnumName(prop.PropInfo.PropType, Integer(Value));
      end;

      if Value <> nil then
        info.AddValue(prop.Name, Value);
    end;
  end;
end;

procedure TSerializableObject.SetObjectData(
  const info: SerializationInfo;
  const context: StreamingContext);

var
  prop: _PropertyInfo;
  Properties: PropertyInfoArray;
  Value: CString;
  Serializable: ISerializable;
  C: CObject;
  i: CInt64;
  t: &Type;

begin
  try
    Properties := GetType.GetProperties;
    for prop in Properties do
    begin
      t := prop.GetType;
      if t.IsInterfaceType then
      begin
        C := prop.GetValue(Self, []);
        if Interfaces.Supports(Interfaces.ToInterface(C), ISerializable, Serializable) then
          info.GetObject(prop.Name, Serializable) else
          continue;
      end
      else if t.IsOfType<CObject> then
      begin
        C := CObject.From<CObject>(info.GetObject(prop.Name));
        prop.SetValue(Self, C, []);
      end
      else if t.IsObjectType then
      begin
        C := prop.GetValue(Self, []);
        if Interfaces.Supports(Convert.ToObject(C), ISerializable, Serializable) then
          info.GetObject(prop.Name, Serializable) else
          continue;
      end
      else if t.IsOfType<CDateTime> then
      begin
        i := info.GetInt64(prop.Name);
        prop.SetValue(Self, CDateTime.Create(i), []);
      end
      else if t.IsOfType<CTimeSpan> then
      begin
        i := info.GetInt64(prop.Name);
        prop.SetValue(Self, CTimeSpan.Create(i), []);
      end
      else
      begin
        Value := info.GetString(prop.Name);
        if not CString.IsNullOrEmpty(Value) then
        begin
          C := CObject.FromType(t, Value);
          prop.SetValue(Self, C, []);
        end;
      end;
    end;
  except
    on E: Exception do
      if prop <> nil then
        raise Exception.Create(CString.Format('{0} (Property: ''{1}'')', E.Message, prop.Name));
  end;
end;

function TypeConverter.GetStandardValues: ICollection;
begin
  Result := GetStandardValues(nil);
end;

function TypeConverter.GetStandardValues(const context: ITypeDescriptorContext): StandardValuesCollection;
begin
  Result := nil;
end;

{ TypeConverter.CStandardValuesCollection }

procedure TypeConverter.CStandardValuesCollection.CopyTo(
  var a: CObject.ObjectArray; arrayIndex: Integer);
begin

end;

constructor TypeConverter.CStandardValuesCollection.Create(
  const values: ICollection);
begin

end;

function TypeConverter.CStandardValuesCollection.GetEnumerator: IEnumerator;
begin
  Result := nil;
end;

function TypeConverter.CStandardValuesCollection.get_InnerType: &Type;
begin
end;

function TypeConverter.CStandardValuesCollection.get_Count: Integer;
begin
  Result := 0;
end;

function TypeConverter.CStandardValuesCollection.get_IsSynchronized: Boolean;
begin
  Result := False;
end;

function TypeConverter.CStandardValuesCollection.get_Item(
  Index: Integer): CObject;
begin
  Result := nil;
end;

function TypeConverter.CStandardValuesCollection.get_SyncRoot: TObject;
begin
  Result := nil;
end;

end.


