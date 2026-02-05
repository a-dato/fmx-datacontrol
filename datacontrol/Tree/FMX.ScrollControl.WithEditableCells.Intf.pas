unit FMX.ScrollControl.WithEditableCells.Intf;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  FMX.Controls, 
  System.Classes, 
  FMX.Types, 
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.System.Classes,
  Wasm.FMX.Types,
  {$ENDIF}
  System_,
  FMX.ScrollControl.WithCells.Intf,
  System.Collections, System.Collections.Generic;

type
  ITreeEditingInfo = interface
    ['{8E62DCA3-F014-4442-A00B-1A812C4A81B4}']
    function  get_EditItem: CObject;
    procedure set_EditItem(const Value: CObject);
    function  get_EditItemDataIndex: Integer;

    function  RowIsEditing: Boolean;
    function  CellIsEditing: Boolean;

    procedure BeginEndEditCell;
    procedure EndEndEditCell;
    function  InsideEndEditCell: Boolean;

    function  IsNew: Boolean;

    procedure StartRowEdit(DataIndex: Integer; const EditItem: CObject; IsNew: Boolean);
    procedure StartCellEdit(DataIndex, FlatColumnIndex: Integer);

    procedure CellEditingFinished;
    procedure RowEditingFinished;

    property  EditItemDataIndex: Integer read get_EditItemDataIndex;
    property  EditItem: CObject read get_EditItem write set_EditItem;
  end;

  IDCCellEditor = interface
    ['{3278B3F2-2D64-4049-9AF2-EE411F3AE509}']
    function  get_Cell: IDCTreeCell;
    function  get_ContainsFocus: Boolean;
    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_Modified: Boolean;
    function  get_Value: CObject;
    procedure set_Value(const Value: CObject);
    function  get_OriginalValue: CObject;
    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);
    function  get_Editor: TControl;
    function  get_IsMultiLine: Boolean;
    function  get_UserCanClear: Boolean;
    procedure set_UserCanClear(const Value: Boolean);

    procedure BeginEdit(const Value: CObject; SelectAll: Boolean = True);
    procedure EndEdit;

    function  TryBeginEditWithUserKey(const OriginalValue: CObject; const UserKey: CString): Boolean;

//    function  ParseValue(var AValue: CObject): Boolean;

    property Cell: IDCTreeCell read get_Cell;
    property ContainsFocus: Boolean read get_ContainsFocus;
    property DefaultValue: CObject read get_DefaultValue write set_DefaultValue;
    property Modified: Boolean read get_Modified;
    property Value: CObject read get_Value write set_Value;
    property OriginalValue: CObject read get_OriginalValue;
    property Editor: TControl read get_editor;
    property PickList: IList read get_PickList write set_PickList;
    property IsMultiLine: Boolean read get_IsMultiLine;
    property UserCanClear: Boolean read get_UserCanClear write set_UserCanClear;
  end;

  IDataControlEditorHandler = interface
    ['{58AD8937-68E6-4390-A908-589B02CE1E27}']
    procedure OnEditorKeyDown(const CellEditor: IDCCellEditor; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure OnEditorExit;

    function  DoCellParsing(const Cell: IDCTreeCell; IsCheckOnEndEdit: Boolean; var AValue: CObject): Boolean;
    function  DoCellFormatting(const Cell: IDCTreeCell; RequestForSort: Boolean; var Value: CObject) : Boolean;
  end;

implementation

end.
