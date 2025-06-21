{$I Adato.inc}
unit ADato.ObjectModel.Binders;

interface

uses
  {$IFDEF DELPHI}
  FMX.Edit, 
  FMX.StdCtrls, 
  FMX.ListBox, 
  FMX.Memo, 
  FMX.Controls,
  FMX.Types, 
  System.Classes, 
  FMX.SpinBox, 
  FMX.Objects,
  FMX.Graphics,
  FMX.NumberBox,
  FMX.ComboEdit,
  FMX.DateTimeCtrls,
  FMX.Colors,
  System.SysUtils,
  {$ELSE}
  ADato.CustomControls,
  System.Text,
  {$ENDIF}
  System_,
  ADato.PropertyAccessibility.Intf,
  ADato.ObjectModel.intf,
  System.Collections,
  System.Collections.Generic, System.UITypes
  {$IFDEF APP_PLATFORM}
  , App.PropertyDescriptor.intf
  {$ENDIF}
  ;

type
  IControlBinding = interface(IBaseInterface)
    ['{DCA5D541-5A9E-4D24-A0E1-DE880E1FB520}']
    function get_Control: TControl;

    procedure UpdateControlEditability(IsEditable: Boolean);
    procedure UpdateControlVisibility(IsVisible: Boolean);

    procedure OnFreeNotificationDestroy;

    property Control: TControl read get_Control;
  end;

  TControlBinding<T: TControl> = class;
  TControlBindingCreator = reference to function(const Control: TFMXObject): IPropertyBinding;

  TPropertyBinding = class(TBaseInterfacedObject, IPropertyBinding)
  protected
    {$IFDEF DELPHI}[weak]{$ENDIF} _ObjectModelContext: IObjectModelContext;
    {$IFDEF DELPHI}[weak]{$ENDIF} __PropertyInfo: _PropertyInfo;
    {$IFDEF APP_PLATFORM}
    _Descriptor: IPropertyDescriptor;
    {$ENDIF}

    _UpdateCount: Integer;
    _executeTriggers: Boolean;

    _pickList: IList;
    _funcPickList: TGetPickList;

    class var _bindersByClass: Dictionary<TClass, TControlBindingCreator>;

    {$IFDEF APP_PLATFORM}
    function get_Descriptor: IPropertyDescriptor;
    procedure set_Descriptor(const Value: IPropertyDescriptor);
    {$ENDIF}

    function  get_ObjectModelContext: IObjectModelContext; virtual;
    procedure set_ObjectModelContext(const Value: IObjectModelContext); virtual;

    function  get_PropertyInfo: _PropertyInfo;
    procedure set_PropertyInfo(const Value: _PropertyInfo);
    function  get_ExecuteTriggers: Boolean;
    procedure set_ExecuteTriggers(const Value: Boolean);

    function  IsChanged: Boolean; virtual;
    function  GetValue: CObject; virtual; abstract;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); virtual; abstract;

    function  GoWithPicklist: Boolean;
    function  GetFuncPickList: TGetPickList;
    procedure SetFuncPickList(const Value: TGetPickList); virtual;

    procedure BeginUpdate;
    procedure EndUpdate(FromNotifyModelEvent: Boolean = False); virtual;
    function  IsUpdating: Boolean; virtual;

    function  IsLinkedProperty(const AProperty: _PropertyInfo) : Boolean;

    function  WaitForNotifyModel: Boolean; virtual;
    procedure NotifyModel(Sender: TObject); virtual;
    procedure ExecuteOriginalOnChangeEvent; virtual; abstract;
  public
    class function  CreateBindingByControl(const Control: TFMXObject): IPropertyBinding;
    class procedure RegisterClassBinding(const ControlClass: TClass; const ControlBindingCreator: TControlBindingCreator);
  end;

  // FOR ALL DESCENDANDS OF TPROPERTYBINDING THAT HAVE CONTROLS
  TFreeControlNotification = class(TInterfacedObject, IFreeNotification)
  private
    [weak] _binding: IControlBinding;
  public
    constructor Create(const Binding: IControlBinding);
    procedure FreeNotification(AObject: TObject);
  end;

  TControlBinding<T: TControl> = class(TPropertyBinding, IControlBinding)
  protected
    _value: CObject;
    _control: T;
    _freeNotification: IFreeNotification;

    {$IFDEF DELPHI}
    [unsafe] _updated_rect: IControl;
    {$ELSE}
    _updated_rect: IControl;
    {$ENDIF}
    _updated_rect_index: Integer;

    // 02/24 JvA: After unbind and rebind other controls can be bound
    // this means that edit1 binding can be destroyed, and edit2 binding can be created
    // Events are getting strangled
    _orgChangeEvent: TNotifyEvent;

    procedure ValidateControl(const ControlEvent: TNotifyEvent);

    function  get_Control: TControl;

    function  get_Value(): CObject;
    procedure set_Value(const Value: CObject);
    procedure set_ObjectModelContext(const Value: IObjectModelContext); override;

    procedure EndUpdate(FromNotifyModelEvent: Boolean = False); override;
    function  IsUpdating: Boolean; override;
    procedure ExecuteOriginalOnChangeEvent; override;

    procedure OnContextChanged(const Sender: IObjectModelContext; const Item: CObject);
    procedure OnFreeNotificationDestroy;

    procedure UpdateControlEditability(IsEditable: Boolean);
    procedure UpdateControlVisibility(IsVisible: Boolean);

    procedure ExecuteFromLink(const Obj: CObject);
    procedure UpdatedByLink;
    procedure FreeAndNilRect;
    procedure HideAndClearUpdatedRect(const Index: Integer; const Rect: TRectangle);

  public
    constructor Create(const AControl: T);
    destructor Destroy; override;

    function Equals(const other: CObject): Boolean; override;

    property Value : CObject read get_Value write set_Value;
  end;

  TLabelControlBinding = class(TControlBinding<TLabel>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TLabelControlSmartLinkBinding = class(TLabelControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TButtonControlBinding = class(TControlBinding<TButton>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TButtonControlSmartLinkBinding = class(TButtonControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TTextControlBinding = class(TControlBinding<TText>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TTextControlSmartLinkBinding = class(TTextControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TEditControlBinding = class(TControlBinding<TEdit>)
  protected
    function TryConvertFromUserFriendlyText(out AResult: CObject): Boolean;

    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    function  WaitForNotifyModel: Boolean; override;
  public
    constructor Create(AControl: TEdit); reintroduce;

    {$IFDEF DELPHI}
    destructor Destroy; override;
    {$ENDIF}
  end;

  TEditControlSmartLinkBinding = class(TEditControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TNumberBoxControlBinding = class(TControlBinding<TNumberBox>)
  protected
    function GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

  public
    constructor Create(AControl: TNumberbox); reintroduce;
    destructor Destroy; override;
  end;

  TNumberBoxControlSmartLinkBinding = class(TNumberBoxControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TProgressbarControlBinding = class(TControlBinding<TProgressBar>)
  protected
    function GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TProgressbarControlSmartLinkBinding = class(TProgressbarControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TSpinControlBinding = class(TControlBinding<TSpinBox>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

  public
    constructor Create(AControl: TSpinBox); reintroduce;
    destructor Destroy; override;
  end;

  TSpinControlSmartLinkBinding = class(TSpinControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TComboBoxControlBinding = class(TControlBinding<TCombobox>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    {$IFDEF APP_PLATFORM}
    procedure ComboBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    {$ENDIF}

  public
    constructor Create(AControl: TCombobox); reintroduce;
    destructor Destroy; override;
  end;

  TComboboxControlSmartLinkBinding = class(TComboBoxControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TComboEditControlBinding = class(TControlBinding<TComboEdit>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TComboEdit); reintroduce;
    destructor Destroy; override;
  end;

  TComboEditControlSmartLinkBinding = class(TComboEditControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TMemoControlBinding = class(TControlBinding<TMemo>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;

    function WaitForNotifyModel: Boolean; override;
  public
    constructor Create(AControl: TMemo);
    destructor Destroy; override;
  end;

  TMemoControlSmartLinkBinding = class(TMemoControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  {$IFDEF DELPHI}
  TComboColorBoxControlBinding = class(TControlBinding<TComboColorBox>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TComboColorBox);
    destructor Destroy; override;
  end;

  TComboColorBoxControlSmartLinkBinding = class(TComboColorBoxControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;
  {$ENDIF}

  TSwitchControlBinding = class(TControlBinding<TSwitch>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TSwitch);
    {$IFNDEF LYNXWEB}
    destructor Destroy; override;
    {$ENDIF}
  end;

  TSwitchControlSmartLinkBinding = class(TSwitchControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TCheckBoxControlBinding = class(TControlBinding<TCheckBox>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TCheckBox);
    destructor Destroy; override;
  end;

  TCheckBoxControlSmartLinkBinding = class(TCheckBoxControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TDateControlBinding = class(TControlBinding<TDateEdit>)
  protected
    _defaultFormat: string;
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TDateEdit);
    destructor Destroy; override;
  end;

  TDateControlSmartLinkBinding = class(TDateControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
 end;

  TTimeControlBinding = class(TControlBinding<TTimeEdit>)
  protected
    _defaultFormat: string;
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  public
    constructor Create(AControl: TTimeEdit);
    destructor Destroy; override;
  end;

  TTimeControlSmartLinkBinding = class(TTimeControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TImageControlBinding = class(TControlBinding<TImage>)
  protected
    function  GetValue: CObject; override;
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

  TImageControlSmartLinkBinding = class(TImageControlBinding)
  protected
    procedure SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject); override;
  end;

implementation

uses
  {$IFDEF DELPHI}
  FMX.Text, 
  ADato.Bitmap.intf,
  System.Math,
  FMX.Ani,
  {$ENDIF}
  ADato.Duration,
  ADato.Data.DataModel.intf, System.JSON;

function TryConvertToUserFriendlyText(const Value: CObject; const PropertyInfo: _PropertyInfo; out AResult: CString): Boolean;
var
  cs: CString;
  l: IList;
  o: CObject;
  sb: StringBuilder;
begin
  Result := False;

  if (Value <> nil) and Value.IsInterface and Interfaces.Supports(Value, IList, l) then
  begin
    sb := CStringBuilder.Create;

    for o in l do
    begin
      if o = nil then
        continue;
      if sb.Length > 0 then
        sb.Append(', ');

      try
        cs := o.ToString;
      except
        continue;
      end;

      sb.Append(cs);
    end;

    AResult := sb.ToString;
    Exit(True);
  end;

  if PropertyInfo.GetType.IsOfType<CTimeSpan> then
  try
    AResult := Duration.Format(Value.AsType<CTimespan>, DurationSettings.Default, DurationFlags.None);
    Result := True;
  except
  end;
end;

constructor TEditControlBinding.Create(AControl: TEdit);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChangeTracking);

  {$IFDEF DELPHI}
  _Control.OnChangeTracking := NotifyModel;
  {$ELSE}
  _Control.OnChangeTracking := @NotifyModel;
  {$ENDIF}
end;

{$IFDEF DELPHI}
destructor TEditControlBinding.Destroy;
begin
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChangeTracking := _orgChangeEvent;

  inherited;
end;
{$ENDIF}

function TEditControlBinding.GetValue: CObject;
var
  o: CObject;
begin
  if GoWithPicklist then
    for o in _pickList do
      if (o <> nil) and CString.Equals(_Control.Text, CStringToString(o.ToString)) then
        Exit(o); // for example an IUser

  if not TryConvertFromUserFriendlyText({out} Result) then
    Result := StringToCString(_Control.Text);
end;

procedure TEditControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
var
  val: CString;
begin
  if (_UpdateCount > 0) or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if not TryConvertToUserFriendlyText(Value, __PropertyInfo, val) then
      if Value <> nil then
        val := Value.ToString;

    if Value <> nil then
      _Control.Text := CStringToString(val) else
      _Control.Text := '';
  finally
    EndUpdate;
  end;
end;

function TEditControlBinding.TryConvertFromUserFriendlyText(out AResult: CObject): Boolean;
begin
  Result := False;

  if __PropertyInfo.GetType.IsOfType<CTimeSpan> then
  try
    AResult := Duration.Parse(_Control.Text, DurationSettings.Default);
    Result := True;
  except
  end;
end;

function TEditControlBinding.WaitForNotifyModel: Boolean;
begin
  // if has selection, there will first be a Delete change action executed, before SetText is called.
  // This method will prevent executing NotifyModel twice

  // UPDATE: goed wrong when using Backspace!!

  {$IFDEF DELPHI}
//  var ispropertyEditMultiSelectDropdown := ((_Control.Owner is TPropertyEditPanelEx) and (_Control.Owner as TPropertyEditPanelEx).DropDownButtonShowing);
//  if ispropertyEditMultiSelectDropdown then
//    Exit;

  Result := False; //_Control.IsFocused and _Control.HasSelection;
  {$ENDIF}
end;

{ TPropertyBinding }

procedure TPropertyBinding.BeginUpdate;
begin
  AtomicIncrement(_UpdateCount);
end;

procedure TPropertyBinding.SetFuncPickList(const Value: TGetPickList);
begin
  _funcPickList := Value;
end;

class function TPropertyBinding.CreateBindingByControl(const Control: TFMXObject): IPropertyBinding;
begin
  var creatorFunc: TControlBindingCreator;

  var ctrlClass := Control.ClassType;
  while not _bindersByClass.TryGetValue(ctrlClass, creatorFunc) do
  begin
    ctrlClass := ctrlClass.ClassParent;
    if ctrlClass = TFmxObject then
    begin
      Assert(1=2, 'No binding class registered for type: ' + Control.ClassName);
      Exit(nil);
    end;
  end;

  // if a parentclass is not registered yet..
  if ctrlClass <> Control.ClassType then
    RegisterClassBinding(Control.ClassType, creatorFunc);

  Result := creatorFunc(Control);
end;

procedure TPropertyBinding.EndUpdate(FromNotifyModelEvent: Boolean = False);
begin
  AtomicDecrement(_UpdateCount);
end;

function TPropertyBinding.GoWithPicklist: Boolean;
begin
  if (_pickList <> nil) then
    Exit(True);

  if Assigned(_funcPickList) then
  begin
    _pickList := _funcPickList();
    Result := (_pickList <> nil) and (_pickList.Count > 0);
  end else
    Result := False;
end;

function TPropertyBinding.GetFuncPickList: TGetPickList;
begin
  Result := _funcPickList;
end;

function TPropertyBinding.get_PropertyInfo: _PropertyInfo;
begin
  Result := __PropertyInfo;
end;

function TPropertyBinding.IsChanged: Boolean;
begin
  Result := False;
end;

function TPropertyBinding.IsLinkedProperty(const AProperty: _PropertyInfo): Boolean;
begin
  // smartlink bidings search for original propinfo
  // (which can have another adress than this binding property).
//  Result := AProperty <> __PropertyInfo;

  // compare names, which is unique comparison for one object class..
  Result := not CString.Equals(AProperty.Name, __PropertyInfo.Name);
end;

function TPropertyBinding.IsUpdating: Boolean;
begin
  Result := (_UpdateCount > 0);
end;

procedure TPropertyBinding.NotifyModel(Sender: TObject);
begin
  if not IsUpdating and (_ObjectModelContext <> nil) then
  begin
    if WaitForNotifyModel then
      Exit;

    BeginUpdate;
    try
      _ObjectModelContext.UpdateValueFromBoundProperty(Self, GetValue, _executeTriggers);
    finally
      EndUpdate(True);
    end;
  end;

  ExecuteOriginalOnChangeEvent;
end;

class procedure TPropertyBinding.RegisterClassBinding(const ControlClass: TClass; const ControlBindingCreator: TControlBindingCreator);
begin
  if _bindersByClass = nil then
    _bindersByClass := CDictionary<TClass, TControlBindingCreator>.Create;

  // make it possible to override a registered controlbinding constructor
  _bindersByClass[ControlClass] := ControlBindingCreator;
end;

{$IFDEF APP_PLATFORM}
function TPropertyBinding.get_Descriptor: IPropertyDescriptor;
begin
  Result := _Descriptor;
end;

procedure TPropertyBinding.set_Descriptor(const Value: IPropertyDescriptor);
begin
  _Descriptor := Value;
end;
{$ENDIF}

function TPropertyBinding.get_ExecuteTriggers: Boolean;
begin
  Result := _executeTriggers;
end;

function TPropertyBinding.get_ObjectModelContext: IObjectModelContext;
begin
  Result := _ObjectModelContext;
end;

procedure TPropertyBinding.set_ExecuteTriggers(const Value: Boolean);
begin
  _executeTriggers := Value;
end;

procedure TPropertyBinding.set_ObjectModelContext(const Value: IObjectModelContext);
begin
  _ObjectModelContext := Value;
end;

procedure TPropertyBinding.set_PropertyInfo(const Value: _PropertyInfo);
begin
  __PropertyInfo := Value;
end;

function TPropertyBinding.WaitForNotifyModel: Boolean;
begin
  Result := False;
end;

{ TLabelControlBinding }


function TLabelControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := nil;
  {$ELSE}
  Result := _value;
  {$ENDIF}
end;

procedure TLabelControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  {$IFDEF APP_PLATFORM}
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if (_Descriptor <> nil) and (Value <> nil) then
    begin
      // Obj   -> IProject
      // Value -> Customer
      // var props := AProperty.Name.Split(['.']);
      var o := _Descriptor.Formatter.Unmarshal(Obj, Value);
      if o <> nil then
      begin
        var fmt := _Descriptor.Formatter.Format(Obj, o, nil);
        if fmt <> nil then
          _Control.Text := CStringToString(fmt);
      end;
    end;

  finally
    EndUpdate;
  end;
  {$ELSE}
  if (_UpdateCount > 0) or IsLinkedProperty(AProperty) then Exit;

  // use TrimStart/TrimEnd to remove Enters and avoid empty looking labels
  {$IFDEF DELPHI}
  var text := Value.ToString(True);
  if text <> nil then
    text := Value.ToString(True).TrimStart.TrimEnd;
  {$ELSE}
  var text: CString;
  if Value <> nil then
    text := Value.ToString;

  if not CString.IsNullOrEmpty(text) then
    text := text.TrimStart.TrimEnd;
  {$ENDIF}

  text := CStringToString(text);

  if not CString.Equals(text, _Control.Text) then
    _Control.Text := text;
  {$ENDIF}
end;

{ TComboBoxControlBinding }

constructor TComboBoxControlBinding.Create(AControl: TCombobox);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChange);

  {$IFDEF DELPHI}
  _Control.OnChange := NotifyModel;
  {$ELSE}
  _Control.OnChange := @NotifyModel;
  {$ENDIF}

  {$IFDEF APP_PLATFORM}
  _control.OnMouseDown := ComboboxMouseDown;
  {$ENDIF}
end;

destructor TComboBoxControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChange := _orgChangeEvent;

  inherited;
  {$ENDIF}
end;

{$IFDEF APP_PLATFORM}
procedure TComboBoxControlBinding.ComboBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if (Button = TMouseButton.mbLeft) and (_pickList = nil) and (_Descriptor <> nil) then
  begin
    var items := _Descriptor.Picklist.Items(nil);
    if items.TryGetValue<IList>(_picklist) then
    begin
      _control.BeginUpdate;
      try
        _control.Items.Clear;
        var formatter := _Descriptor.Formatter;

        for var item in _picklist do
        begin
          var s: CString;
          if formatter <> nil then
            s := formatter.Format(get_ObjectModelContext.Context, item, nil) else
            s := item.ToString();

          if not CString.IsNullOrEmpty(s) then
            _control.Items.Add(s);
        end;
      finally
        _control.EndUpdate;
      end;
    end;
  end;
end;
{$ENDIF}

function TComboBoxControlBinding.GetValue: CObject;
var
  o: CObject;
  s: CString;
begin
  {$IFDEF APP_PLATFORM}
  var ix := _control.ItemIndex;
  if _picklist = nil then
  begin
    if ix <> -1 then
      Exit(_control.Items[ix]);
  end
  else if (ix >= 0) and (ix < (_picklist.Count - 1)) then
  begin
    var item := _picklist[ix];
    if (item <> nil) and (_Descriptor <> nil) then
      Result := _Descriptor.Formatter.Marshal(get_ObjectModelContext.Context, item);
  end;
  {$ELSEIF DELPHI}
  var ix := _Control.ItemIndex;
  if not GoWithPicklist then
  if ix <> -1 then
      Exit(_Control.Items[ix]) else
      Exit(nil);

  if ix <> -1 then
    s := _Control.Items[ix] else
    s := nil;

  if GoWithPicklist and (s <> nil) then
    for o in _pickList do
      if (o <> nil) and CObject.Equals(s, CStringToString(o.ToString)) then
        Exit(o); // for example an IUser

  Result := nil;
  {$ELSE}
  if _Control.ItemIndex <> -1 then
    Result := _Control.Items[_Control.ItemIndex] else
    Result := nil;
  {$ENDIF}
end;

procedure TComboBoxControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  {$IFDEF APP_PLATFORM}
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if Value = nil then
    begin
      _control.ItemIndex := -1;
      Exit;
    end;

    var value_string: CString;

    if Value.IsString and (_Descriptor <> nil) then
    begin
      var js := TJsonObject.ParseJSONValue(Value.ToString(False));
      try
        var s: string;
        if js.TryGetValue<string>('Value', s) then
          value_string := s;
      finally
        js.Free;
      end;
    end;

    if value_string = nil then
      value_string := Value.ToString;

    if value_string <> nil then
    begin
      var i := -1;
      if _control.Items <> nil then
        i := _control.Items.IndexOf(value_string);

      if i = -1 then
      begin
        _control.Items.Clear;
        _control.Items.Add(value_string);
        _control.ItemIndex := 0;
      end else
        _control.ItemIndex := i;
    end;
  finally
    EndUpdate;
  end;
  {$ELSE}
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if (Value <> nil) and (_control.Items <> nil) then
    begin
      var s := CStringToString(Value.ToString);
      _control.ItemIndex := _control.Items.IndexOf(s);
    end else
      _control.ItemIndex := -1;
  finally
    EndUpdate;
  end;
  {$ENDIF}
end;

{ TMemoControlBinding }

constructor TMemoControlBinding.Create(AControl: TMemo);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChangeTracking);

  {$IFDEF DELPHI}
  _Control.OnChangeTracking := NotifyModel;
  {$ELSE}
  _Control.OnChangeTracking := @NotifyModel;
  {$ENDIF}
end;

destructor TMemoControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChangeTracking := _orgChangeEvent;
  {$ENDIF}
  inherited;
end;

function TMemoControlBinding.GetValue: CObject;
begin
  Result := _Control.Text;
end;

procedure TMemoControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if Value <> nil then
      _Control.Text := CStringToString(Value.ToString) else
      _Control.Text := '';
  finally
    EndUpdate;
  end;
end;

function TMemoControlBinding.WaitForNotifyModel: Boolean;
begin
  // if has selection, there will first be a Delete change action executed, before SetText is called.
  // This method will prevent executing NotifyModel twice

  Result := _Control.IsFocused and (_Control.SelLength > 0);
end;

{ TSwitchControlBinding }

constructor TSwitchControlBinding.Create(AControl: TSwitch);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnClick);

  {$IFDEF DELPHI}
  _Control.OnSwitch := NotifyModel;
  {$ELSE}
  _Control.OnSwitch := @NotifyModel;
  {$ENDIF}
end;

{$IFNDEF LYNXWEB}
destructor TSwitchControlBinding.Destroy;
begin
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnClick := _orgChangeEvent;
  inherited;
end;
{$ENDIF}

function TSwitchControlBinding.GetValue: CObject;
begin
  Result := _Control.IsChecked;
end;

procedure TSwitchControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    _Control.IsChecked := (Value <> nil) and Value.AsType<Boolean>;
  finally
    EndUpdate;
  end;
end;

{ TLabelControlSmartLinkBinding }

procedure TLabelControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TEditControlSmartLinkBinding }

procedure TEditControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TComboboxControlSmartLinkBinding }

procedure TComboboxControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TSwitchControlSmartLinkBinding }

procedure TSwitchControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TMemoControlSmartLinkBinding }

procedure TMemoControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TFreeControlNotification }

constructor TFreeControlNotification.Create(const Binding: IControlBinding);
begin
  inherited Create;
  _binding := Binding;
end;

procedure TFreeControlNotification.FreeNotification(AObject: TObject);
begin
  // normally ObjectModelContext will free the bindings in it's Unbind/Destroy :)
  // But is some cases the controls are freed without the Unbind being called
  // then we get here

  try
    _binding.OnFreeNotificationDestroy;
    _binding := nil;
  except
    _binding := nil;
  end;
end;

{ TSpinControlBinding }

constructor TSpinControlBinding.Create(AControl: TSpinBox);
begin
  inherited Create(AControl);

  {$IFDEF DELPHI}
  _Control.OnChangeTracking := NotifyModel;
  {$ELSE}
  _Control.OnChangeTracking := @NotifyModel
  {$ENDIF}
end;

destructor TSpinControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChangeTracking := _orgChangeEvent;
  inherited;
  {$ENDIF}
end;

function TSpinControlBinding.GetValue: CObject;
begin
  Result := _Control.Value;
end;

procedure TSpinControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
var
  d: Double;
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if Value <> nil then
      d := Value.AsType<Double> else
      d := 0;

    _Control.Min := CMath.Min(1, d);
    _Control.Value := d;
  finally
    EndUpdate;
  end;
end;

{ TSpinControlSmartLinkBinding }

procedure TSpinControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TTextControlBinding }

function TTextControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := nil;
  {$ELSE}
  Result := _value;
  {$ENDIF}
end;

procedure TTextControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  if Value <> nil then
    _Control.Text := CStringToString(Value.ToString) else
    _Control.Text := '';
end;

{ TTextControlSmartLinkBinding }

procedure TTextControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TControlBinding }

constructor TControlBinding<T>.Create(const AControl: T);
begin
  _Control := AControl;

  {$IFDEF DELPHI}
  _FreeNotification := TFreeControlNotification.Create(Self);
  _Control.AddFreeNotify(_FreeNotification);
  {$ENDIF}
end;

destructor TControlBinding<T>.Destroy;
begin
  FreeAndNilRect;

  set_ObjectModelContext(nil);
  {$IFDEF DELPHI}
  if (_control <> nil) then
    _control.RemoveFreeNotify(_freeNotification);
  {$ENDIF}

  _freeNotification := nil;
  _control := nil;

  inherited;
end;

procedure TControlBinding<T>.EndUpdate(FromNotifyModelEvent: Boolean = False);
begin
  if not FromNotifyModelEvent and _control.IsFocused then
  begin
    var textCtrl: ITextActions;
    if interfaces.Supports<ITextActions>(_control, textCtrl) then
    begin
      textCtrl.SelectAll;
      textCtrl.GoToTextEnd;
    end;
  end;


  inherited;
end;

function TControlBinding<T>.Equals(const other: CObject): Boolean;
begin
  Result := (get_Control = other.AsType<IControlBinding>.Control);
end;

procedure TControlBinding<T>.ExecuteFromLink(const Obj: CObject);
begin
  var &old := GetValue;

  SetValue(__propertyInfo, Obj, __propertyInfo.GetValue(obj, []));

  if not CObject.Equals(&old, GetValue) then
    UpdatedByLink;
end;

procedure TControlBinding<T>.ExecuteOriginalOnChangeEvent;
begin
  if Assigned(_orgChangeEvent) then
    _orgChangeEvent(_control);
end;

procedure TControlBinding<T>.FreeAndNilRect;
begin
  if _updated_rect <> nil then
  begin
    FreeAndNil(_updated_rect as TControl);
    _updated_rect := nil;
  end;

  inc(_updated_rect_index);
end;

function TControlBinding<T>.get_Control: TControl;
begin
  Result := _Control;
end;

function TControlBinding<T>.get_Value: CObject;
begin
  Result := _value;
end;

function TControlBinding<T>.IsUpdating: Boolean;
begin
  Result := inherited; // or (_control.IsUpdating);
end;

procedure TControlBinding<T>.OnContextChanged(const Sender: IObjectModelContext; const Item: CObject);
begin
  // control = nil when destroyed
  if _control = nil then
    Exit;

  var isEditable := True;
  var isVisible := True;

  var iwid: IPropertyAccessibility;
  if (item <> nil) and item.TryAsType<IPropertyAccessibility>(iwid) then
  begin
    var edState := iwid.CanEditProperty(__PropertyInfo.Name);
    isEditable := edState.IsEditable;
    isVisible := edState.IsVisible;
  end;

  UpdateControlEditability(isEditable);
  UpdateControlVisibility(isVisible);
end;

procedure TControlBinding<T>.OnFreeNotificationDestroy;
begin
  _control := nil;

  // is weak
  if _ObjectModelContext <> nil then
    _ObjectModelContext.Unbind(Self); // Note: this can free the binding
end;

procedure TControlBinding<T>.set_ObjectModelContext(const Value: IObjectModelContext);
begin
  if _ObjectModelContext <> nil then
  begin
    {$IFDEF DELPHI}
    _ObjectModelContext.OnContextChanged.Remove(OnContextChanged);
    {$ELSE}
    _ObjectModelContext.OnContextChanged -= OnContextChanged;
    {$ENDIF}
  end;

  inherited;

  if _ObjectModelContext <> nil then
  begin
    {$IFDEF DELPHI}
    _ObjectModelContext.OnContextChanged.Add(OnContextChanged);
    {$ELSE}
    _ObjectModelContext.OnContextChanged += OnContextChanged;
    {$ENDIF}

    OnContextChanged(_ObjectModelContext, _ObjectModelContext.Context);
  end else
    OnContextChanged(nil, nil);
end;

procedure TControlBinding<T>.set_Value(const Value: CObject);
begin
  _value := Value;
  NotifyModel(self);
end;

procedure TControlBinding<T>.UpdateControlEditability(IsEditable: Boolean);
begin
  _control.Enabled := IsEditable;
end;

procedure TControlBinding<T>.UpdateControlVisibility(IsVisible: Boolean);
begin
  {$IFDEF DEBUG}
  _control.Opacity := IfThen(not IsVisible, 0.2, 1);
  {$ELSE}
  _control.Opacity := IfThen(not IsVisible, 0, 1);
  {$ENDIF}
end;

procedure TControlBinding<T>.HideAndClearUpdatedRect(const Index: Integer; const Rect: TRectangle);
begin
  {$IFDEF DELPHI}
  TAnimator.AnimateFloatDelay(Rect, 'Opacity', 0, 0.4, 1);
  TThread.ForceQueue(nil,
    procedure
    begin
      // otherwise already freed
      if (Index = _updated_rect_index) then
        FreeAndNilRect;
    end, 3000);
  {$ENDIF}
end;

procedure TControlBinding<T>.UpdatedByLink;
begin
  FreeAndNilRect;

  {$IFDEF DELPHI}
  var rect := TRectangle.Create(_control);
  rect.Height := _control.Height - 6;
  rect.Width := 60;
  rect.Align := TAlignLayout.None;
  rect.Position.X := _control.Width - (rect.Width + 20);
  rect.Position.Y := 3;
  rect.Fill.Color := TAlphaColors.Lightblue;
  rect.Stroke.Thickness := 0;
  rect.XRadius := 3;
  rect.YRadius := 3;
  rect.Opacity := 0.7;
  _control.AddObject(rect);

  var title := TLabel.Create(rect);
  title.Text := 'Updated';
  title.Align := TAlignLayout.Client;
  title.TextSettings.HorzAlign := TTextAlign.Center;
  title.TextSettings.VertAlign := TTextAlign.Center;
  rect.AddObject(title);

  HideAndClearUpdatedRect(_updated_rect_index, rect);
  _updated_rect := rect;
  {$ENDIF}
end;

procedure TControlBinding<T>.ValidateControl(const ControlEvent: TNotifyEvent);
begin
  // 02/24 JvA: After unbind and rebind other controls can be bound
  // If events are the same, we will get a infite loop.
  // Events are getting strangled

  {$IFDEF DELPHI}
  var notifyEvent: TNotifyEvent := NotifyModel;
  if Assigned(ControlEvent) and (TMethod(ControlEvent).Code = TMethod(notifyEvent).Code) then
    raise Exception.Create('Events are getting strangled');
  {$ELSE}
  var notifyEvent: TNotifyEvent := @NotifyModel;
  if Assigned(ControlEvent) and AreEventsEqual(ControlEvent, notifyEvent) then
    raise Exception.Create('Events are getting strangled');
  {$ENDIF}

  {$IFDEF DELPHI}
  _orgChangeEvent := ControlEvent;
  {$ENDIF}
end;

{ TDateControlBinding }

constructor TDateControlBinding.Create(AControl: TDateEdit);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChange);

  _defaultFormat := _Control.Format;

  {$IFDEF DELPHI}
  _Control.OnChange := NotifyModel;

  // required for selecting date parts after setting format to ' ' for emptying
  if Trim(_defaultFormat) = string.Empty then
  begin
    if _Control.DateFormatKind = TDTFormatKind.Short then
      _defaultFormat := FormatSettings.ShortDateFormat else
      _defaultFormat := FormatSettings.LongDateFormat;
  end;
  {$ELSE}
  _Control.OnChange := @NotifyModel;
  {$ENDIF}
end;

destructor TDateControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChange := _orgChangeEvent;
  {$ENDIF}
  inherited;
end;

function TDateControlBinding.GetValue: CObject;
begin
  if not _Control.IsEmpty then
  begin
    // required for Delphi to select parts
    if _Control.Format <> _defaultFormat then
      _Control.Format := _defaultFormat;

    Result := CDateTime(_Control.DateTime)
  end else
    Result := CDateTime.MinValue;
end;

procedure TDateControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    {$IFDEF DOTNET}
    if Value = nil then 
    begin
      _control.Text := CDateTime.MinValue.ToString;
      Exit;
    end;
    {$ENDIF}

    var cdt := Value.AsType<CDateTime>;
    _Control.IsEmpty := cdt = CDateTime.MinValue;
    if cdt <> CDateTime.MinValue then
    begin
      {$IFDEF DELPHI}
      _Control.Format := _defaultFormat;
      _Control.DateTime := cdt.DelphiDateTime;
      {$ELSE}
      _Control.Format := _defaultFormat;
      _Control.DateTime := cdt.Date;
      {$ENDIF}
    end else
      _Control.Format := ' ';
  finally
    EndUpdate;
  end;
end;

{ TDateControlSmartLinkBinding }

procedure TDateControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TCheckBoxControlSmartLinkBinding }

procedure TCheckBoxControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TCheckBoxControlBinding }

constructor TCheckBoxControlBinding.Create(AControl: TCheckBox);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnClick);

  {$IFDEF DELPHI}
  _Control.OnClick := NotifyModel;
  {$ELSE}
  _Control.OnClick := @NotifyModel;
  {$ENDIF}
end;

destructor TCheckBoxControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnClick := _orgChangeEvent;
  {$ENDIF}
  inherited;
end;

function TCheckBoxControlBinding.GetValue: CObject;
begin
  // Called before change
  Result := not _Control.IsChecked;
end;

procedure TCheckBoxControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    _Control.IsChecked := (Value <> nil) and Value.AsType<Boolean>;
  finally
    EndUpdate;
  end;
end;


{ TTimeControlBinding }

constructor TTimeControlBinding.Create(AControl: TTimeEdit);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChange);

  _defaultFormat := _Control.Format;

  {$IFDEF DELPHI}
  _Control.OnChange := NotifyModel;

  // required for selecting date parts after setting format to ' ' for emptying
  if Trim(_defaultFormat) = string.Empty then
  begin
    if _Control.TimeFormatKind = TDTFormatKind.Short then
      _defaultFormat := FormatSettings.ShortTimeFormat.Replace('m','n') else
      _defaultFormat := FormatSettings.LongTimeFormat.Replace('m','n');
  end;
  {$ELSE}
  _Control.OnChange := @NotifyModel;
  {$ENDIF}
end;

destructor TTimeControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChange := _orgChangeEvent;
  {$ENDIF}
  inherited;
end;

function TTimeControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := CDateTime(_Control.DateTime);
  {$ENDIF}
end;

procedure TTimeControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    {$IFDEF DELPHI}
    var cdt := Value.AsType<CDateTime>;
    _Control.IsEmpty := cdt = CDateTime.MinValue;
    if cdt <> CDateTime.MinValue then
    begin
      _Control.Format := _defaultFormat;
      _Control.DateTime := Value.AsType<CDateTime>.DelphiDateTime;
    end else
      _Control.Format := ' ';
    {$ELSE}
    Self.Value := Convert.ToDateTime(Value);
    {$ENDIF}
  finally
    EndUpdate;
  end;
end;

{ TTimeControlSmartLinkBinding }

procedure TTimeControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TNumberBoxControlBinding }

constructor TNumberBoxControlBinding.Create(AControl: TNumberbox);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChangeTracking);

  {$IFDEF DELPHI}
  _Control.OnChangeTracking := NotifyModel;
  {$ELSE}
  _Control.OnChangeTracking := @NotifyModel;
  {$ENDIF}
end;

destructor TNumberBoxControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChangeTracking := _orgChangeEvent;
  inherited;
  {$ENDIF}
end;

function TNumberBoxControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  var number := _control.Model.ConvertTextToValue(_control.Text);
  if _control.ValueType = TNumValueType.Integer then
    Result := Round(number) else
    Result := number;
  {$ELSE}
  Result := Int32.Parse(_Control.Text);
  {$ENDIF}
end;

procedure TNumberBoxControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if Value <> nil then
      _control.Text := CStringToString(Value.ToString) else
      _control.Value := _control.Min;
  finally
    EndUpdate;
  end;
end;

{ TNumberBoxControlSmartLinkBinding }

procedure TNumberBoxControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TProgressbarControlBinding }

function TProgressbarControlBinding.GetValue: CObject;
begin
  Result := _Control.Value;
end;

procedure TProgressbarControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if Value <> nil then
      _Control.Value := Value.AsType<Single> else
      _Control.Value := 0;
  finally
    EndUpdate;
  end;
end;

{ TProgressbarControlSmartLinkBinding }

procedure TProgressbarControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TImageControlSmartLinkBinding }

procedure TImageControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TImageControlBinding }

function TImageControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := _Control.Bitmap;
  {$ELSE}
  Result := _value;
  {$ENDIF}
end;

procedure TImageControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    {$IFDEF DELPHI}
    if Value <> nil then
      _Control.Bitmap := Value.AsType<IADatoBitmap>.Bitmap else
      _Control.Bitmap := nil;
    {$ELSE}
      _value := Convert.Tostring(Value);
    {$ENDIF}
  finally
    EndUpdate;
  end;
end;

{ TButtonControlBinding }

function TButtonControlBinding.GetValue: CObject;
begin
  {$IFDEF DELPHI}
  Result := nil;
  {$ELSE}
  Result := _value;
  {$ENDIF}
end;

procedure TButtonControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;
  {$IFDEF DELPHI}
  if Value = nil then
    _Control.Text := '' else
    _Control.Text := CStringToString(Value.ToString);
  {$ELSE}
  _value := Convert.ToString(Value);
  {$ENDIF}
end;

{ TButtonControlSmartLinkBinding }

procedure TButtonControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TComboEditControlBinding }

constructor TComboEditControlBinding.Create(AControl: TComboEdit);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChangeTracking);

  {$IFDEF DELPHI}
  _Control.OnChangeTracking := NotifyModel;
  {$ELSE}
  (_Control as TComboEdit).OnChangeTracking := @NotifyModel;
  {$ENDIF}
end;

destructor TComboEditControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChangeTracking := _orgChangeEvent;

  inherited;
  {$ENDIF}
end;

function TComboEditControlBinding.GetValue: CObject;
var
  o: CObject;
  s: CString;
begin
  var ix := _Control.ItemIndex;
  if not GoWithPicklist then
  begin
  if ix <> -1 then
      Exit(_Control.Items[ix]) else
      Exit(nil);
  end;

  if ix <> -1 then
    s := _Control.Items[ix] else
    s := StringToCString(_Control.Text);

  if GoWithPicklist and (s <> nil) then
      for o in _pickList do
        if (o <> nil) and CObject.Equals(s, CStringToString(o.ToString)) then
            Exit(o); // for example an IUser

  Result := nil;
end;

procedure TComboEditControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
var
  val: CString;
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    if not TryConvertToUserFriendlyText(Value, __PropertyInfo, val) then
      if Value <> nil then
        val := Value.ToString;

    if Value <> nil then
    begin
      var s := CStringToString(val);
      var ix := _control.Items.IndexOf(s);
      if ix <> -1 then
        _control.ItemIndex := _control.Items.IndexOf(s) else
        _control.Text := s;
    end
    else
    begin
      _Control.ItemIndex := -1;
      _Control.Text := '';
    end;
  finally
    EndUpdate;
  end;
end;

{ TComboEditControlSmartLinkBinding }

procedure TComboEditControlSmartLinkBinding.SetValue( const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;

{ TComboColorBoxControlBinding }

{$IFDEF DELPHI}
constructor TComboColorBoxControlBinding.Create(AControl: TComboColorBox);
begin
  inherited Create(AControl);
  ValidateControl(_Control.OnChange);

  {$IFDEF DELPHI}
  _Control.OnChange := NotifyModel;
  {$ELSE}
  _Control.OnChangeTracking := @NotifyModel
  {$ENDIF}
end;

destructor TComboColorBoxControlBinding.Destroy;
begin
  {$IFDEF DELPHI}
  if (_Control <> nil) and ([csDestroying] * _Control.ComponentState = []) then
    _Control.OnChange := _orgChangeEvent;

  inherited;
  {$ENDIF}
end;

function TComboColorBoxControlBinding.GetValue: CObject;
begin
  Result := _Control.Color;
end;

procedure TComboColorBoxControlBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if IsUpdating or IsLinkedProperty(AProperty) then Exit;

  BeginUpdate;
  try
    _Control.Color := Value.AsType<Cardinal>;
  finally
    EndUpdate;
  end;
end;

{ TComboColorBoxControlSmartLinkBinding }

procedure TComboColorBoxControlSmartLinkBinding.SetValue(const AProperty: _PropertyInfo; const Obj, Value: CObject);
begin
  if _UpdateCount > 0 then Exit;

  if IsLinkedProperty(AProperty) then
    ExecuteFromLink(Obj) else
    inherited;
end;
{$ENDIF}

initialization
  TPropertyBinding.RegisterClassBinding(TLabel,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TLabelControlSmartLinkBinding.Create(TLabel(Control)) end);

  TPropertyBinding.RegisterClassBinding(TText,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TTextControlSmartLinkBinding.Create(TText(Control)) end);

  TPropertyBinding.RegisterClassBinding(TEdit,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TEditControlSmartLinkBinding.Create(TEdit(Control)) end);

  TPropertyBinding.RegisterClassBinding(TMemo,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TMemoControlSmartLinkBinding.Create(TMemo(Control)) end);

  TPropertyBinding.RegisterClassBinding(TCombobox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TComboboxControlSmartLinkBinding.Create(TCombobox(Control)) end);

  TPropertyBinding.RegisterClassBinding(TComboEdit,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TComboEditControlSmartLinkBinding.Create(TComboEdit(Control)) end);

  TPropertyBinding.RegisterClassBinding(TSpinbox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TSpinControlSmartLinkBinding.Create(TSpinbox(Control)) end);

  TPropertyBinding.RegisterClassBinding(TSwitch,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TSwitchControlSmartLinkBinding.Create(TSwitch(Control)) end);

  TPropertyBinding.RegisterClassBinding(TCheckbox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TCheckBoxControlSmartLinkBinding.Create(TCheckbox(Control)) end);

  TPropertyBinding.RegisterClassBinding(TDateEdit,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TDateControlSmartLinkBinding.Create(TDateEdit(Control)) end);

  TPropertyBinding.RegisterClassBinding(TTimeEdit,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TTimeControlSmartLinkBinding.Create(TTimeEdit(Control)) end);

  TPropertyBinding.RegisterClassBinding(TProgressBar,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TProgressBarControlSmartLinkBinding.Create(TProgressBar(Control)) end);

  TPropertyBinding.RegisterClassBinding(TImage,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TImageControlSmartLinkBinding.Create(TImage(Control)) end);

  TPropertyBinding.RegisterClassBinding(TNumberBox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TNumberBoxControlSmartLinkBinding.Create(TNumberBox(Control)) end);

  TPropertyBinding.RegisterClassBinding(TComboColorBox,
    function(const Control: TFMXObject): IPropertyBinding begin Result := TComboColorBoxControlSmartLinkBinding.Create(TComboColorBox(Control)) end);
end.
