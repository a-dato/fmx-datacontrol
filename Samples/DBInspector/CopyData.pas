unit CopyData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Memo.Types, FMX.Edit,
  FMX.ScrollBox, FMX.Memo, FireDAC.Comp.BatchMove.SQL, FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.DataSet, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, OpenRecordset;

type
  TfrmCopyData = class(TFrame)
    cbSourceTables: TComboBox;
    Label1: TLabel;
    cbTargetDatabase: TComboBox;
    Label2: TLabel;
    mmSqlSelectQuery: TMemo;
    Label3: TLabel;
    edTargetTable: TEdit;
    Label4: TLabel;
    btnGo: TButton;
    btnAbort: TButton;
    btnRefresh: TSpeedButton;
    fdBatchMove: TFDBatchMove;
    fdSqlReader: TFDBatchMoveSQLReader;
    fdSqlWriter: TFDBatchMoveSQLWriter;
    fdSourceConnection: TFDConnection;
    fdTargetConnection: TFDConnection;
    lblPhase: TLabel;
    lblProgress: TLabel;
    Timer1: TTimer;
    procedure btnAbortClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure fdBatchMoveProgress(ASender: TObject; APhase: TFDBatchMovePhase);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    procedure RefreshConnections;
    procedure SetConnection(Connection: TFDConnection; SourceFrame: TOpenRecordSetFrame);
  end;

implementation

uses
  FMX.TabControl;

{$R *.fmx}

procedure TfrmCopyData.btnAbortClick(Sender: TObject);
begin
  fdBatchMove.AbortJob;
end;

procedure TfrmCopyData.SetConnection(Connection: TFDConnection; SourceFrame: TOpenRecordSetFrame);
begin
  Connection.Connected := False;
  Connection.Assign(SourceFrame.fdConnection);
  Connection.OnLogin := SourceFrame.fdConnection.OnLogin;
end;

procedure TfrmCopyData.btnGoClick(Sender: TObject);
begin
  if cbSourceTables.ItemIndex = -1 then
    raise Exception.Create('Source connection not set');
  if cbTargetDatabase.ItemIndex = -1 then
    raise Exception.Create('Target connection not set');
  if mmSqlSelectQuery.Text = '' then
    raise Exception.Create('Selection query missing');
  if edTargetTable.Text = '' then
    raise Exception.Create('Target table name missing');

  var frame := cbSourceTables.Items.Objects[cbSourceTables.ItemIndex] as TOpenRecordSetFrame;
  SetConnection(fdSourceConnection, frame);

  frame := cbTargetDatabase.Items.Objects[cbTargetDatabase.ItemIndex] as TOpenRecordSetFrame;
  SetConnection(fdTargetConnection, frame);

  fdSqlReader.ReadSQL := mmSqlSelectQuery.Text;
  fdSqlWriter.TableName := edTargetTable.Text;

  TThread.CreateAnonymousThread(procedure begin
    fdBatchMove.Execute;
  end).Start;
end;

procedure TfrmCopyData.btnRefreshClick(Sender: TObject);
begin
  RefreshConnections;
end;

procedure TfrmCopyData.fdBatchMoveProgress(ASender: TObject; APhase: TFDBatchMovePhase);
begin
  TThread.Queue(nil, procedure begin
    case APhase of
      psPreparing: lblPhase.Text := 'Phase: Preparing';
      psStarting: lblPhase.Text := 'Phase: Starting';
      psProgress: lblPhase.Text := 'Phase: Running';
      psFinishing: lblPhase.Text := 'Phase: Finishing';
      psUnpreparing: lblPhase.Text := 'Phase: Unpreparing';
    end;
  end);
end;

{ TfrmCopyData }

// Connections are loaded from open tabs
procedure TfrmCopyData.RefreshConnections;
begin
  cbSourceTables.Clear;
  cbTargetDatabase.Clear;

  var parent := Self.Parent;

  while (parent <> nil) and not (parent is TTabControl) do
    parent := parent.Parent;

  if parent = nil then
    Exit;

  var tc := parent as TTabControl;

  for var i := 0 to tc.TabCount - 1 do
  begin
    if tc.Tabs[i].TagObject is TOpenRecordSetFrame then
    begin
      var rs := tc.Tabs[i].TagObject as TOpenRecordSetFrame;
      if not cbSourceTables.Items.Contains(rs.ConnectionName) then
      begin
        cbSourceTables.Items.AddObject(rs.ConnectionName, rs);
        cbTargetDatabase.Items.AddObject(rs.ConnectionName, rs);
      end;
    end;
  end;
end;

procedure TfrmCopyData.Timer1Timer(Sender: TObject);
begin
  lblProgress.Text := string.Format('Progress: %d', [fdBatchMove.InsertCount + fdBatchMove.UpdateCount]);
end;

end.


