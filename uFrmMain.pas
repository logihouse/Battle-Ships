
unit uFrmMain;

interface

uses
  winsock, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types,  FMX.Controls, FMX.Forms, FMX.Dialogs,
   FMX.Objects, FMX.Layouts, FMX.ListBox,
  IdCustomTCPServer, IdTCPServer, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdContext, IdCmdTCPClient,  FMX.Memo, FMX.Edit, IdSocketHandle,
  IdUDPServer, IdUDPBase, IdUDPClient, misc;

type tcommand = (cmdStrike, cmdReadyToPlay, cmdYouStart, cmdHit, cmdMissed, cmdChat, cmdYouLost, cmdInvitefrom, cmdInviteAccept, cmdOther);
const command : array [cmdStrike..pred(cmdOther)] of string[20] =
('Shoot', 'ImReady', 'YouStart', 'Hit', 'Missed', 'Chat', 'YouLost', 'InviteFrom', 'InviteAccept');

const maxi = 10;
      maxj = 10;
      dx = 32;



var  Myturn, Ready, OpponentReady, playing : boolean;

type ttile = class;



 tboard =  array [-1..maxi, -1..maxj] of tTile;

 ttile = class
  i,j, state, vesselid  : integer;
  board : tboard;
  rect : trectangle;
  procedure BuildClick;
  procedure SendClick;
  procedure ReceiveClick;
  Procedure Hit;
  Procedure Missed;
  Procedure SendMessage(aCommand : tcommand; text : string = '' );
  constructor Create(ai, aj : integer; arect : trectangle );
end;


var myboard, remoteboard :  tboard;

type
  TfrmMain = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    lbHeader: TLabel;
    Panel1: TPanel;
    ListBox1: TListBox;
    Button1: TButton;
    Panel2: TPanel;
    Edit1: TEdit;
    Button2: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    Button3: TButton;
    btnInvite: TButton;
    cbHosts: TComboBox;
    procedure Rectangle1Click(Sender: TObject);
    procedure Rectangle1SendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure serverConnect(AContext: TIdContext);
    procedure Button2Click(Sender: TObject);
    procedure info(s : string);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnInviteClick(Sender: TObject);
    procedure cbHostsChange(Sender: TObject);

  private
    { Private declarations }
    itemstext : string;
    host : ansistring;
    function IsreadyToPlay: boolean;
    function IHaveWon: boolean;
    Procedure SendMessage(cmd : tcommand; text : string);
  public
    Procedure StartGamePlay;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses  udmSock;

{$R *.fmx}



procedure TfrmMain.info(s: string);
begin
 while memo1.Lines.Count > 2 do
 memo1.Lines.Delete(0);

 memo1.lines.Add(s);
 memo1.Visible := false;
 memo1.Visible := true;

end;

Function TfrmMain.IsreadyToPlay : boolean;
var
  I, j, n : Integer;
begin
 n := 0;
 result := false;
 if not dmSock.client.Connected then
 begin
    //client.IOHandler.WriteLn( '123');
    showmessage('Not connected');
    exit;
 end;
 listbox1.Items.Text := itemstext;
 for I := 0 to maxi-1 do
 for j := 0 to maxj-1 do
 begin
   if myboard[i,j].state = 1 then
   begin
     inc(n);
   end
   else
   begin
     if n > 1 then
     listbox1.Items.Values[inttostr(n)] :=
     inttostr(strtointdef(listbox1.Items.Values[inttostr(n)], 0) -1);
     n := 0;
   end;
 end;
 for j := 0 to maxj-1 do
 for I := 0 to maxi-1 do
 begin
   if myboard[i,j].state = 1 then
     inc(n) else
   begin
     if n > 1 then
     listbox1.Items.Values[inttostr(n)] :=
     inttostr(strtointdef(listbox1.Items.Values[inttostr(n)], 0) -1);
     n := 0;
   end;
 end;
 for i := 0 to listbox1.Items.Count-1 do
   if pos('=0', listbox1.Items[i]) = 0 then
   exit;

 result := true;

end;

procedure TfrmMain.Button1Click(Sender: TObject);
var i,j : integer;
begin
  for I := -1 to maxi do
  for j := -1 to maxj do
  with myboard[i,j] do
  begin
    ttile(tagobject).Free;
    free;
  end;
  for I := -1 to maxi do
  for j := -1 to maxj do
  with remoteboard[i,j] do
  begin
    ttile(tagobject).Free;
    free;
  end;
  formcreate(nil);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  dmsock.SendMessage(cmdChat,edit1.Text);
  edit1.Text := '';
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
  host := misc.gethostname;
  dmSock.udps.Broadcast(host, 3456);
end;

procedure TfrmMain.cbHostsChange(Sender: TObject);
begin
  btnInvite.Enabled := cbHosts.itemindex <> -1;
end;

procedure TfrmMain.btnInviteClick(Sender: TObject);
begin
  if cbHosts.ItemIndex = -1 then exit;

  host := cbHosts.Items[cbHosts.ItemIndex];
  with dmSock do
  begin
    if client.connected then
    client.disconnect;
    client.host := host;
    client.connect;
    dmsock.SendMessage(CmdInviteFrom, misc.GetHostname);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);

var rect : trectangle;
    tile : ttile;
    test : string;

procedure BuildBoard(var aboard : tboard; panel : tpanel; tileowner : boolean);
var i, j : integer;
begin
  //test := trim(test);
  for i  := -1 to maxi do
  for j  := -1 to maxj do
  begin
    rect := trectangle.Create(self);
    with rect do
    begin
      parent := panel;
      position.x := i*dx;
      position.y := j* dx;
      Height := dx;
      Width := dx;
      fill.Color := talphacolors.White;

      Fill.Kind := TBrushKind.bkSolid;
      if tileowner then
      onclick := Rectangle1Click else
      onclick := Rectangle1SendClick;
      tile := ttile.Create(i,j, rect);
      tagobject :=  tile;
      aboard [i,j] := tile;
      tile.board := aboard;
      visible := (i in  [0..maxi-1]) and (j in  [0..maxj-1]);
    end;
  end;
  playing := false;
  ready := false;
  //midx := left + width div 2;
  //midy := top + height div 2;
end;

var host : string;

begin
  BuildBoard(myboard, panel1, true);
  BuildBoard(remoteboard, panel2, false);
  if itemstext = ''  then
  itemstext := listbox1.Items.Text;
  info('Build your ship in grid to the left. Click five adjacent tiles, either vertical or horizontal');
//  client.Connect;
  myTurn := true;
end;

function TfrmMain.IHaveWon: boolean;
var i,j, n : integer;
begin
  result := false;
  listbox1.Items.Text := itemstext;
 n := 0;
 for I := 0 to maxi-1 do
 for j := 0 to maxj-1 do
 begin
   if  remoteboard[i,j].state = 10 then
     inc(n)
   else
   begin
     if n > 1 then
     listbox1.Items.Values[inttostr(n)] :=
     inttostr(strtointdef(listbox1.Items.Values[inttostr(n)], 0) -1);
     n := 0;
   end;
 end;
 for j := 0 to maxj-1 do
 for I := 0 to maxi-1 do
 begin
   if remoteboard[i,j].state = 10 then
     inc(n) else
   begin
     if n > 1 then
     listbox1.Items.Values[inttostr(n)] :=
     inttostr(strtointdef(listbox1.Items.Values[inttostr(n)], 0) -1);
     n := 0;
   end;
 end;
 for i := 0 to listbox1.Items.Count-1 do
   if pos('=0', listbox1.Items[i]) = 0 then
   exit;

 result := true;

end;

procedure TfrmMain.serverConnect(AContext: TIdContext);
begin
  lbheader.Text := 'Connected';
end;

function get(var s : string) : string;
var p : integer;
begin
  p := pos(';', s);
  if p > 0 then
  begin
   result := copy(s, 1, p-1);
   s := copy(s, p+1, 1000);
  end else
  result := s;
end;

function getint(var s : string) : integer;
begin
  result := strtoint(get(s));
end;


procedure TfrmMain.StartGamePlay;
begin
   if opponentready then
   begin
     playing := true;
     if random < 0.5 then
     begin
       myturn := false;
       dmSock.SendMessage(cmdYoustart, 'You start')
     end else
     begin
     myturn := true;
     end;
   end;

end;

var s : string;


procedure TfrmMain.Rectangle1Click(Sender: TObject);
begin
  with sender as trectangle do
  begin
    (tagobject as ttile).Buildclick;
  end;
end;

procedure TfrmMain.Rectangle1SendClick(Sender: TObject);
begin
  with sender as trectangle do
  if playing then

  begin
    (tagobject as ttile).SendClick;
  end else info
  ('We are not playing');
end;

procedure TfrmMain.SendMessage(cmd: tcommand; text: string);
begin

end;

{ tile }

procedure ttile.Buildclick;
begin
  if ready then exit;

  case state of
    0 : begin state := 1;  rect.fill.color := TAlphaColors.Blue ;  end;
    1 : begin state := 0;  rect.fill.color := TAlphaColors.white ; end;
  end;
  if state = 1  then
  if frmMain.isreadytoplay then
  begin
     playing := true;
     ready := true;
     SendMessage(cmdReadyToPlay);
     showmessage('Battleship build!');
     frmMain.StartGamePlay;
     frmMain.info('Ready to play');
  end;

end;

constructor ttile.Create(ai, aj: integer; arect : trectangle);
begin
  i := ai;
  j := aj;
  rect := arect;
end;

procedure ttile.Hit;
begin
  state := 10;
  rect.fill.color := talphacolors.red;
  //frmMain.info('You were hit');
  if frmMain.IhaveWon then
  begin
    SendMessage(cmdYouLost);
    showmessage('You won');
    playing := false;
  end;
end;

procedure ttile.Missed;
begin
  state := 5;
  rect.fill.color := talphacolors.gray;
end;

procedure ttile.ReceiveClick;
begin
  if state =  1 then
  begin
   state := 2;
   rect.fill.color := talphacolors.Red;
   //myboard[i+1,j].ReceiveClick;
   //myboard[i,j+1].ReceiveClick;
   //myboard[i-1,j].ReceiveClick;
   //myboard[i,j-1].ReceiveClick;
   SendMessage(cmdHit);
  end else
  if state = 0 then
  begin
    state := 4;
    rect.fill.color := talphacolors.gray;
    SendMessage(CmdMissed);
  end;
  myturn := true;
end;

procedure ttile.Sendclick;
begin
 if myturn then
 begin
   if state=0 then
   begin
     SendMessage(cmdStrike);
     frmMain.fill.color := talphacolors.Red;
     myturn := false;
   end;
 end else
 frmMain.memo1.lines.add('It is not your turn');
end;

procedure ttile.SendMessage(aCommand : tcommand; text : string = '');
var s : string;
begin
  if text = '' then
  text := inttostr(i)+';'+inttostr(j);
  dmSock.SendMessage(Acommand,text);
end;

end.
