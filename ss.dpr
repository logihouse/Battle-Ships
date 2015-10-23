program ss;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  FMX.Forms,
  uFrmMain in 'uFrmMain.pas' {frmMain},
  misc in 'misc.pas',
  udmSock in 'udmSock.pas' {dmSock: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmSock, dmSock);
  Application.Run;
end.
