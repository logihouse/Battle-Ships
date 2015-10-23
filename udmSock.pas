unit udmSock;

interface

uses
  ufrmmain, System.SysUtils, System.Classes, IdContext, IdSocketHandle, IdUDPBase,
  IdUDPServer, IdCustomTCPServer, IdTCPServer, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, Vcl.ExtCtrls;

type
  TdmSock = class(TDataModule)
    client: TIdTCPClient;
    server: TIdTCPServer;
    udpS: TIdUDPServer;
    Timer1: TTimer;
    procedure serverExecute(AContext: TIdContext);
    procedure DataModuleCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure udpSUDPRead(AThread: TIdUDPListenerThread; AData: array of Byte;
      ABinding: TIdSocketHandle);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SendMessage(cmd : tcommand; text : string);
  end;

var
  dmSock: TdmSock;

implementation
uses misc;

{%CLASSGROUP 'FMX.Types.TFmxObject'}

{$R *.dfm}

procedure TdmSock.DataModuleCreate(Sender: TObject);
var host : string;
begin
  if client.connected  then client.Disconnect;
  server.DefaultPort := 3344;
  server.Active := false;
//  server.active := true;
  client.Port := 3344;
  Host := paramstr(1);
  if host = '' then
  host := '127.0.0.1';
  client.host := host;

end;

procedure TdmSock.SendMessage(cmd: tcommand; text: string);
begin
   //
   if client.Connected then

   client.IOHandler.WriteLn(Command[cmd]+';'+text);
end;

procedure TdmSock.serverExecute(AContext: TIdContext);
var s, cmd : string;
    i, j : integer;
    ac : tcommand;
begin
  sleep(100);
  s := acontext.Connection.IOHandler.readln('');
  try
    cmd := get(s);
    for ac := cmdStrike to pred(CmdOther) do
    if command[ac] = cmd then
    case ac of
    cmdStrike : begin
            i := getint(s);
            j := getint(s);
            myboard[i,j].ReceiveClick;
          end;
    CmdHit : begin
            i := getint(s);
            j := getint(s);
            remoteboard[i,j].Hit;
          end;
    CmdMissed : begin
            i := getint(s);
            j := getint(s);
            remoteboard[i,j].Missed;
          end;
    cmdChat : begin
            s := get(s);
            frmmain.info(s);
          end;
    cmdReadyToplay :
          begin
            opponentready := true;
            frmmain.info('Your opponent is ready to play');
          end;
    cmdInviteFrom :
          begin
            if yes('Accept invite from'+get(s)) then
            begin
              sendMessage(cmdInviteAccept, misc.gethostname);
            end;
          end;
    cmdInviteAccept :
          begin
            frmMain.StartGamePlay;
          end;
    cmdYoustart :
          begin
            myturn := true;
            frmmain.info('Playing. ');
            frmmain.info('It is your turn ');
          end;
    cmdYouLost :
          begin
            playing := false;
            //s := get(s);
            frmmain.info('You lost');
            frmmain.info('Click new game ');
          end;
    end;
  except
   on e : exception do
   frmmain.info(e.Message);
  end;
end;

procedure TdmSock.Timer1Timer(Sender: TObject);
begin
try
  if not server.Active then
  server.Active := true;
  if not client.Connected then
  client.Connect;
  udps.Active := true;
except
  frmmain.info('Not connected...');
end;
end;

procedure TdmSock.udpSUDPRead(AThread: TIdUDPListenerThread;
  AData: array of Byte; ABinding: TIdSocketHandle);

  var I: Integer;
      s : string;
begin
  s := '';
  for I := Low(adata) to High(adata) do
  s := s + ansichar(adata[i]);
  //s := ansistring(adata);
  if length(s) > 0 then
 // if s <> host then
  with frmMain.cbHosts do
  begin
    if items.IndexOf(s) = -1 then
    items.Add(s);
  end;

end;

end.
