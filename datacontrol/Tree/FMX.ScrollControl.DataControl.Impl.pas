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
  FMX.ScrollControl.DataControl.Intf,
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
    property Columns;
    property AutoFitColumns;
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


