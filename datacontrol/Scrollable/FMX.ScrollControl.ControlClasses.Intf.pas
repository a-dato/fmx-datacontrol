unit FMX.ScrollControl.ControlClasses.Intf;

interface

uses
  System_,
  System.Collections,
  {$IFNDEF WEBASSEMBLY}
  System.Classes,
  System.Types,
  FMX.Types,
  FMX.Controls,
  FMX.Objects
  {$ELSE}
  Wasm.FMX.Controls,
  Wasm.FMX.Types,
  {$ENDIF}
  , System.UITypes;

type
  // Interface that handles communication between a cell editor inside the tree control
  // and the actual control used for the editing
  IDCControl = interface(IBaseInterface)
    ['{D407A256-CED9-4FCD-8AED-E6B6578AE83D}']
    function  get_Control: TControl;

    function  get_Align: TAlignLayout;
    procedure set_Align(const Value: TAlignLayout);
    function  get_BoundsRect: TRectF;
    procedure set_BoundsRect(const Value: TRectF);
    function  get_Cursor: TCursor;
    procedure set_Cursor(const Value: TCursor);
    function  get_HitTest: Boolean;
    procedure set_HitTest(const Value: Boolean);
    function  get_Enabled: Boolean;
    procedure set_Enabled(const Value: Boolean);
    function  get_Margins: TBounds;
    procedure set_Margins(const Value: TBounds);
    function  get_Padding: TBounds;
    procedure set_Padding(const Value: TBounds);
    function  get_Position: TPosition;
    procedure set_Position(const Value: TPosition);
    function  get_Width: Single;
    procedure set_Width(const Value: Single);
    function  get_Height: Single;
    procedure set_Height(const Value: Single);
    function  get_Value: CObject;
    procedure set_Value(const Value: CObject);
    function  get_OnClick: TNotifyEvent;
    procedure set_OnClick(const Value: TNotifyEvent);
    function  get_Opacity: Single;
    procedure set_Opacity(const Value: Single);
    function  get_Tag: CObject;
    procedure set_Tag(const Value: CObject);
    function  get_OnExit: TNotifyEvent;
    procedure set_OnExit(const Value: TNotifyEvent);
    function  get_Visible: Boolean;
    procedure set_Visible(const Value: Boolean);

    procedure SetFocus;

    property Control: TControl read get_Control;
    property OnExit: TNotifyEvent read get_OnExit write set_OnExit;

    property Align: TAlignLayout read get_Align write set_Align;
    property Cursor: TCursor read get_Cursor write set_Cursor;
    property BoundsRect: TRectF read get_BoundsRect write set_BoundsRect;
    property Enabled: Boolean read get_Enabled write set_Enabled;
    property HitTest: Boolean read get_HitTest write set_HitTest;
    property Padding: TBounds read get_Padding write set_Padding;
    property Margins: TBounds read get_Margins write set_Margins;
    property Position: TPosition read get_Position write set_Position;
    property Width: Single read get_Width write set_Width;
    property Height: Single read get_Height write set_Height;
    property OnClick: TNotifyEvent read get_OnClick write set_OnClick;
    property Opacity: Single read get_Opacity write set_Opacity;
    property Tag: CObject read get_Tag write set_Tag;
    property Value: CObject read get_Value write set_Value;
    property Visible: Boolean read get_Visible write set_Visible;
  end;

  ITextControl = interface
    ['{8C5C0E98-B7DF-45A5-A476-C7E2C382242A}']
    function  get_CalcAsAutoHeight: Boolean;
    procedure set_CalcAsAutoHeight(const Value: Boolean);
//    function  get_CalcAsAutoWidth: Boolean;
//    procedure set_CalcAsAutoWidth(const Value: Boolean);
    function  get_MaxWidth: Integer;
    procedure set_MaxWidth(const Value: Integer);
    function  GetText: string;
    procedure SetText(const Value: string);

    function TextWidth: Single;
    function TextHeight: Single;
    function TextHeightWithPadding: Single;
    function TextWidthWithPadding: Single;

    property CalcAsAutoHeight: Boolean read get_CalcAsAutoHeight write set_CalcAsAutoHeight;
    property MaxWidth: Integer read get_MaxWidth write set_MaxWidth;
    property Text: string read GetText write SetText;
  end;

  IImageControl = interface
    ['{BBB416C1-0739-4EE9-B081-EEB73E78CBD6}']
    function  get_ImageIndex: Integer;
    procedure set_ImageIndex(const Value: Integer);

    property ImageIndex: Integer read get_ImageIndex write set_ImageIndex;
  end;

  IClearableControl = interface
    ['{1A39DDA2-4937-47C6-8CC2-F9F4885EA854}']
    function  get_ShowClearButton: Boolean;
    procedure set_ShowClearButton(const Value: Boolean);
    property ShowClearButton: Boolean read get_ShowClearButton write set_ShowClearButton;
  end;

  TFormatItem = function(const Item: CObject): CString of object;
  TFilterItem = function(const Item: CObject; const ItemText, Filter: string) : Boolean of object;
  TComboBeforePopup = procedure(var APicklist: IList) of object;

  // Interface that handles communication between a cell editor inside the tree control
  // and the actual control used for the editing
  IDCEditControl = interface(IDCControl)
    ['{D407A256-CED9-4FCD-8AED-E6B6578AE83D}']
    function  get_Control: TControl;
    function  get_DefaultValue: CObject;
    procedure set_DefaultValue(const Value: CObject);
    function  get_FormatItem: TFormatItem;
    procedure set_FormatItem(const Value: TFormatItem);
    function  get_OnChange: TNotifyEvent;
    procedure set_OnChange(Value: TNotifyEvent);
    function  get_OnKeyDown: TKeyEvent;
    procedure set_OnKeyDown(const Value: TKeyEvent);
    function  get_ShowClearButton: Boolean;
    procedure set_ShowClearButton(const Value: Boolean);

    procedure DoKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure DoKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

    property OnChange: TNotifyEvent read get_OnChange write set_OnChange;
    property OnKeyDown: TKeyEvent read get_OnKeyDown write set_OnKeyDown;
    property FormatItem: TFormatItem read get_FormatItem write set_FormatItem;
    property DefaultValue: CObject read get_DefaultValue write set_DefaultValue;
    property ShowClearButton: Boolean read get_ShowClearButton write set_ShowClearButton;
  end;

  IDateEditControl = interface(IDCEditControl)
    ['{87A26C96-F3EE-4929-8936-979FBED812FF}']
    function  get_Date: CDateTime;
    procedure set_Date(const Value: CDateTime);

    procedure OpenPicker;
    property Date: CDateTime read get_Date write set_Date;
  end;

  ICheckBoxControl = interface(IDCEditControl)
    ['{8F8E1E4B-E8F9-48A8-A277-5AE73151ECA5}']

  end;

  IRadioButtonControl = interface(IDCEditControl)
    ['{B9DD1F02-C4CF-48F2-97D6-333F8AF69405}']

  end;

  IComboEditControl = interface
    ['{0A5E499C-31BB-42B8-BDD5-16EFA661C377}']
    function  get_AutoFilter: Boolean;
    procedure set_AutoFilter(const Value: Boolean);
    function  get_ItemIndex: Integer;
    procedure set_ItemIndex(const Value: Integer);
    function  get_FilterItem: TFilterItem;
    procedure set_FilterItem(const Value: TFilterItem);
    function  get_BeforePopup: TComboBeforePopup;
    procedure set_BeforePopup(const Value: TComboBeforePopup);
    function  get_FormatItem: TFormatItem;
    procedure set_FormatItem(const Value: TFormatItem);
    function  get_PickList: IList;
    procedure set_PickList(const Value: IList);
    function  get_Text: CString;
    procedure set_Text(const Value: CString);

    function  FindBestMatch(const Text: string) : Integer;
    procedure DropDown;

    property ItemIndex: Integer read get_ItemIndex write set_ItemIndex;
    property BeforePopup: TComboBeforePopup read get_BeforePopup write set_BeforePopup;
    property AutoFilter: Boolean read get_AutoFilter write set_AutoFilter;
    property FilterItem: TFilterItem read get_FilterItem write set_FilterItem;
    property FormatItem: TFormatItem read get_FormatItem write set_FormatItem;
    property PickList: IList read get_PickList write set_PickList;
    property Text: CString read get_Text write set_Text;
  end;

  IBackgroundControl = interface
    ['{C0F12B2D-7C93-478F-809F-BC8A66166F84}']
    function  GetXRadius: Single;
    procedure SetXRadius(const Value: Single);
    function  GetYRadius: Single;
    procedure SetYRadius(const Value: Single);
    function  GetCorners: TCorners;
    procedure SetCorners(const Value: TCorners);
    function  GetSides: TSides;
    procedure SetSides(const Value: TSides);
    function  GetFillColor: TAlphaColor;
    procedure SetFillColor(const Value: TAlphaColor);
    function  GetStrokeColor: TAlphaColor;
    procedure SetStrokeColor(const Value: TAlphaColor);

    function AsControl: TControl;

    property Corners: TCorners read GetCorners write SetCorners;
    property Sides: TSides read GetSides write SetSides;
    property XRadius: Single read GetXRadius write SetXRadius;
    property YRadius: Single read GetYRadius write SetYRadius;
    property FillColor: TAlphaColor read GetFillColor write SetFillColor;
    property StrokeColor: TAlphaColor read GetStrokeColor write SetStrokeColor;
  end;

  IRowLayout = interface
    ['{C553D374-7432-4700-8C60-849A4F0CF5A8}']
    function  get_UseBuffering: Boolean;
    procedure set_UseBuffering(const Value: Boolean);
    function  get_Sides: TSides;
    procedure set_Sides(const Value: TSides);

    procedure ResetBuffer;
    function  Background: IBackgroundControl;

    property UseBuffering: Boolean read get_UseBuffering write set_UseBuffering;
    property Sides: TSides read get_Sides write set_Sides;
  end;

  IDCControlClassFactory = interface
    ['{08ADE46F-92EA-4A14-9208-51FD5347C754}']
    function CreateHeaderRect(const Owner: TComponent): IBackgroundControl;
    function CreateHeaderCellRect(const Owner: TComponent): IBackgroundControl;

    function IsCustomFactory: Boolean;

    function CreateRowCellRect(const Owner: TComponent): IBackgroundControl;
    function CreateRowRect(const Owner: TComponent): IBackgroundControl;

    function CreateText(const Owner: TComponent): IDCControl;
    function CreateButton(const Owner: TComponent): IDCControl;
    function CreateGlyph(const Owner: TComponent): IDCControl;

    function CreateEdit(const Owner: TComponent): IDCEditControl;
    function CreateComboEdit(const Owner: TComponent): IDCEditControl;
    function CreateCheckBox(const Owner: TComponent): IDCEditControl;
    function CreateRadioButton(const Owner: TComponent): IDCEditControl;
    function CreateMemo(const Owner: TComponent): IDCEditControl;
    function CreateDateEdit(const Owner: TComponent): IDateEditControl;

    procedure HandleRowBackground(const RowRect: IBackgroundControl; AlternateAvailable: Boolean; Alternate: Boolean);
  end;

implementation

end.


