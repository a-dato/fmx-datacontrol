{$IFNDEF WEBASSEMBLY}
{$I ..\..\dn4d\Source\Adato.inc}
{$ENDIF}

unit FMX.ScrollControl.DataControl.Impl;

interface

uses
  {$IFNDEF WEBASSEMBLY}
  System.Classes,
  {$ELSE}
  Wasm.System.Classes,
  {$ENDIF}
  System_,
  System.Runtime.Serialization,
  FMX.ScrollControl.WithEditableCells.Impl,
  FMX.ScrollControl.WithCells.Intf,
  FMX.ScrollControl.WithCells.Impl;

type
  {$IFNDEF WEBASSEMBLY}
  [ComponentPlatformsAttribute(pidAllPlatforms)]
  {$ENDIF}
  TDataControl = class(TScrollControlWithEditableCells)
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    procedure Assign(Source: TPersistent); override;

  published
    // TScrollControl
    property OnViewPortPositionChanged;
    property OnCustomToolTipEvent;
    property OnStickyClick;

    // TScrollControlWithRows
    property SelectionType;
    property Options;
    property CanDragDrop;
    property RowHeightFixed;
    property RowHeightDefault;
    property RowHeightMax;
    property RowHeightSynchronizer;
    {$IFNDEF WEBASSEMBLY}
    property RowLoaded;
    property RowAligned;
    {$ENDIF}

    // TScrollControlWithCells designer properties
    property Columns;
    property AutoFitColumns;
    property AutoCenterTree;
    property HeaderHeight;
    property HeaderTextTopMargin;
    property HeaderTextBottomMargin;
    property AutoExtraColumnSizeMax;
    property ScrollingHideColumnsFromIndex;
    property CellTopBottomPadding;
    property CellLeftRightPadding;
    property PopupMenuClosed;
    property VisualizeParentChilds;

    // TScrollControlWithCells designer events
    property CellLoading;
    property CellLoaded;
    property CellFormatting;
    property CellCanChange;
    property CellChanging;
    property CellChanged;
    property CellSelected;
    property SortingGetComparer;
    property OnCompareRows;
    property OnCompareColumnCells;
    property OnColumnsChanged;
    property OnTreePositioned;

    // TScrollControlWithEditableCells
    property EditRowStart;
    property EditRowEnd;
    property EditCellStart;
    property EditCellEnd;
    property CellParsing;
    property CellCheckChanged;
    property OnCopyToClipBoard;
    property OnPasteFromClipBoard;
    property RowAdding;
    property RowDeleting;
    property RowDeleted;
  end;


implementation

uses
  System.Reflection;

{ TDataControl }

procedure TDataControl.Assign(Source: TPersistent);
var
  _sourceTree: TDataControl;

  procedure CopyColumns;
  var
    _clone          : IDCTreeColumn;
    i               : Integer;

  begin
    BeginUpdate;
    try
      _columns.Clear;

//      _defaultColumns := _sourceTree.DefaultColumns or (_sourceTree.Columns.Count = 0);
//
//      if not _defaultColumns then
//      begin
        for i := 0 to _sourceTree.Columns.Count - 1 do
        begin
          _clone := _sourceTree.Columns[i].Clone;
          _clone.TreeControl := Self;
          _columns.Add(_clone);
        end;
//      end;
    finally
      EndUpdate;
    end;
  end;

begin
  _sourceTree := Source as TDataControl;

//  if Interfaces.Supports<IDataControl>(Source, _sourceTree) then
//  begin
    // inherited;
    Data := _sourceTree.Data;
    CopyColumns;
    RefreshControl; //([TreeState.ColumnsChanged]);
//  end;
end;

procedure TDataControl.DefineProperties(Filer: TFiler);
begin
  inherited;
  {$IFNDEF WEBASSEMBLY}
  DefineDotNetProperties(Filer);
  {$ELSE}
  raise Exception.Create('Need to add DefineDotNetProperties to WASM');
  {$ENDIF}
end;


initialization
begin
  // Must use unique name here, VCL version of TTreeControl already
  // uses name 'TTreeColumn'
  {$IFNDEF WEBASSEMBLY}
  &Assembly.RegisterClass(TDCTreeColumn);
  &Assembly.RegisterClass(TDCTreeCheckboxColumn);
  {$ENDIF}
end;

finalization
begin
  {$IFNDEF WEBASSEMBLY}
  &Assembly.UnRegisterClass(TDCTreeColumn);
  &Assembly.UnRegisterClass(TDCTreeCheckboxColumn);
  {$ENDIF}
end;

end.


