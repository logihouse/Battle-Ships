unit misc;

interface
uses winsock, fmx.dialogs, SysUtils, system.UITypes;

var midx, midy : integer;


function yes(ask : string) : boolean;
procedure ShowMessage(s : string);
function GetHostName : ansistring;
function get(var s : string) : string;
function getint(var s : string) : integer;

implementation

procedure ShowMessage(s : string);
begin
  showmessagepos(s, midx, midy);
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



function GetHostName : ansistring;
var host : ansistring;
begin
  host := '                                        ';
  WinSock.gethostname(@host[1], 20);
  host := trim(host);
  result := host;
end;

function yes(ask : string) : boolean;
//var ADialogType: TMsgDlgType;
begin
  result :=
  MessageDlg(
  ask,
  TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK,  TMsgDlgBtn.mbCancel], 0) = ord(TMsgDlgBtn.mbOK);

end;

initialization
   midx := 300;
   midy := 300;
end.
