unit FMX.PickList.Intf;

interface

uses
  System_,
  System.Collections;

type
  IPickListSupport = interface
    ['{F670376D-2A80-4963-B53A-3EF994D0263C}']
    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);

    property PickList: IList read get_PickList write set_PickList;
  end;

  TDataItemWithText = record
  public
    Data: CObject;
    Text: CString;

    constructor Create(const AData: CObject; const AText: CString);
  end;

implementation

{ TDataItemWithText }

constructor TDataItemWithText.Create(const AData: CObject; const AText: CString);
begin
  Data := AData;
  Text := AText;
end;

end.


