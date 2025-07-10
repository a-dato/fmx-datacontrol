unit ADato.PropertyAccessibility.Intf;

interface

uses
  System_;

type
  TEditableState = record
  const
    Invisible = 0;
    ReadOnly = 1;
    Editable = 2;
    MultiEditable = 3;
  private
    value: Integer;

  public
    function IsEditable: Boolean;
    function IsVisible: Boolean;

    class operator Equal(const L, R: TEditableState) : Boolean;
    class operator NotEqual(const L, R: TEditableState) : Boolean;
    class operator Implicit(AValue: Integer) : TEditableState;
    class operator Implicit(const AValue: TEditableState) : Integer;
  end;

  IPropertyAccessibility = interface(IBaseInterface)
    ['{B87E53A9-7B47-4F12-862C-8C5B098073EB}']
    function CanEditObject: Boolean;
    function CanEditProperty(const PropName: CString): TEditableState;

    procedure ClearEditablity(const PropName: CString);
  end;

implementation

{ TEditableStateHelper }

class operator TEditableState.Equal(const L, R: TEditableState): Boolean;
begin
  Result := L.value = R.value;
end;

class operator TEditableState.NotEqual(const L, R: TEditableState): Boolean;
begin
  Result := L.value <> R.value;
end;

class operator TEditableState.Implicit(AValue: Integer): TEditableState;
begin
  Result.value := AValue;
end;

class operator TEditableState.Implicit(const AValue: TEditableState): Integer;
begin
  Result := AValue.value;
end;

function TEditableState.IsEditable: Boolean;
begin
  Result := (value = TEditableState.Editable) or (value = TEditableState.MultiEditable);
end;

function TEditableState.IsVisible: Boolean;
begin
  Result := value <> TEditableState.Invisible;
end;

end.


