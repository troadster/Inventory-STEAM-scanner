unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,regexpr, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs,
  sSkinManager, acProgressBar, sRadioButton, sEdit, sButton, sMemo, sGauge,
  Vcl.ImgList, acAlphaImageList, Vcl.Imaging.pngimage, Vcl.ExtCtrls, acImage;

type
  TForm1 = class(TForm)
    IdHTTP1: TIdHTTP;
    Memo1: TsMemo;
    Button1: TsButton;
    Edit1: TsEdit;
    csgo: TsRadioButton;
    dota2: TsRadioButton;
    sSkinManager1: TsSkinManager;
    TF2: TsRadioButton;
    STEAM: TsRadioButton;
    sGauge1: TsGauge;
    sButton1: TsButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Memo1Enter(Sender: TObject);
    procedure sButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
     Working = class(TThread)
  private
   html,textmemo:string;
   rege:tregexpr;
   http:tidhttp;
  protected
    procedure Execute; override;
    procedure MemoText;
  public
    constructor Create(CreateSuspended: Boolean);
  end;

var
  Form1: TForm1;
  id:string;
  steamid:string;
  CS: TCriticalSection;
  items:tstringlist;
  Work,first,focus:boolean;
  I,tp:integer;
  allmoney:Double;
  tradeitems:integer;
  thr:integer;
  Proxy:tstringlist;
implementation

{$R *.dfm}

function Pars(T_, ForS, _T: string): string;
var
  a, b: integer;
begin

  Result := '';
  if (T_ = '') or (ForS = '') or (_T = '') then
    Exit;
  a := Pos(T_, ForS);
  if a = 0 then
    Exit
  else
    a := a + Length(T_);
  ForS := Copy(ForS, a, Length(ForS) - a + 1);
  b := Pos(_T, ForS);
  if b > 0 then
    Result := Copy(ForS, 1, b - 1);
end;

constructor Working.Create(CreateSuspended: Boolean);   //Создание потока
begin
  inherited Create(CreateSuspended);
end;

procedure TForm1.Button1Click(Sender: TObject);
var a:integer;
begin
if button1.Caption='Начать' then begin
if trim(edit1.Text)='' then ShowMessage('Введите steamid!') else begin

button1.Caption:='Остановить';
if csgo.Checked then id:='730'; if dota2.Checked then id:='570';  if tf2.Checked then id:='440'; if steam.Checked then id:='753';
sGauge1.Progress:=0;
steamid:=edit1.Text;
memo1.Lines.Clear;
work:=true;
i:=-1;
allmoney:=0;
tp:=-1;
items.Clear;
thr:=0;
tradeitems:=0;
first:=false;
for a := 0 to 10 do begin
Working.Create(false);
inc(thr);
end;
end;
end else begin
button1.Caption:='Начать';
work:=false;
Memo1.lines.Add('Работа остановлена пользователем.');
end;
end;

procedure working.Execute;
var
Link,IP,port,item,money,name:string;
poptk:integer;
begin
try begin

http:=tidhttp.Create(nil);
http.Request.UserAgent:='Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36 OPR/15.0.1147.153';
http.HandleRedirects:=true; http.RedirectMaximum:=2;
http.Request.Host:='steamcommunity.com';
Http.ReadTimeout:=7000;
cs.Enter;
if first=false then begin
if id='753' then
html:=http.Get('http://steamcommunity.com/profiles/'+steamid+'/inventory/json/'+id+'/6/') else
html:=http.Get('http://steamcommunity.com/profiles/'+steamid+'/inventory/json/'+id+'/2/');
if pos('"success":true',html)<>0 then begin
   rege:=TRegExpr.Create;
   rege.Expression:=('"market_name"(.*?)"descriptions"');
   if rege.Exec(HTML) then repeat
   items.Add(rege.Match[1]);
   Until
   not
   rege.ExecNext; // Готово!
   rege.Free;
   form1.sGauge1.MaxValue:=items.Count;
   textmemo:=('Всего вещей: ' + inttostr(items.Count));
   Synchronize(MemoText);
   first:=true;
end else begin
textmemo:=('Инвентарь не доступен или в нем нет предметов');
Synchronize(MemoText);
work:=false;
end;
end;
if proxy.Count>1 then begin

     if tp=proxy.Count then tp:= 0;
     inc(tp);
     IP:=Copy(Proxy[tp], 1, Pos(':',Proxy[tp])-1);//Копируем айпи
     PORT:=Copy(Proxy[tp], Pos(':', Proxy[tp])+1, Length(Proxy[tp])); //Копируем порт
     http.ProxyParams.ProxyServer:=IP;//Вставляем Айпи и
     http.ProxyParams.ProxyPort:=strtoint(PORT);        //Порт
end;
cs.Leave;
  // for i := 0 to Items.Count-1 do begin


  while work do begin
  cs.Enter;
    inc(i);
       if i=items.Count then
   work:=false;
   TExtMemo:='+1';
   Synchronize(MemoText);
  cs.Leave;

  if work then begin

   if pos('"tradable":0',items[i]) or (pos('"marketable":0',items[i]))<>0  then    inc(tradeitems) else begin
   item:=pars(':"',Items[i],'","name_color"');
   link:=StringReplace(item,' ','%20',[rfReplaceAll, rfIgnoreCase]);

   for poptk:=0 to 3 do begin
   try
   html:=http.Get('http://steamcommunity.com/market/search/render/?query='+link+'&search_descriptions=0&start=0&count=0');
   except
  // sleep(30000);
   html:='1';
   end;
      money:=pars('&#36;',html,'USD'); money:=StringReplace(money,'.',',',[rfReplaceAll, rfIgnoreCase]);
      if money='' then begin
      if proxy.Count>1 then begin
      cs.Enter;
      if tp=proxy.Count then tp:= 0;

      inc(tp);
     IP:=Copy(Proxy[tp], 1, Pos(':',Proxy[tp])-1);//Копируем айпи
     PORT:=Copy(Proxy[tp], Pos(':', Proxy[tp])+1, Length(Proxy[tp])); //Копируем порт
     http.ProxyParams.ProxyServer:=IP;//Вставляем Айпи и
     http.ProxyParams.ProxyPort:=strtoint(PORT);        //Порт
     cs.Leave;
      end;
      end else
   if html='1' then else break;
   end;

   //html:=http.Get('http://steamcommunity.com/market/listings/'+id+'/'+link);
   if money='' then begin
   cs.Enter;
   textmemo:=('Не удалось получить цену предмета: '+item);
   Synchronize(MemoText);
   if i=items.Count then
   work:=false;
   cs.Leave;
   end
   else begin
   cs.Enter;
   allmoney:=strtofloat(trim(money))+allmoney;
   TextMemo:=(item + ' [' + money + ' USD]');
   Synchronize(MemoText);
   cs.Leave;
   end;  //конец проверки на передоваемость
   end;
  end;
   end; // конец цикла
   dec(thr);
   http.Free;
   if thr=0 then begin
   if id='730' then name:='CSGO'; if id='570' then name:='DOTA2'; if id='440' then name:='TF2'; if id='753' then name:='STEAM';
   form1.button1.Caption:='Начать';
   TextMemo:=('Общая стоимость предметов инвентаря '+name+': ' +FloatToStr(allmoney) + ' USD'+#13#10+'Непередаваемых предметов: '+ inttostr( tradeitems));
   Synchronize(MemoText);
   end;
end;

 except
    on E : Exception
    do begin
    cs.Enter;

    cs.Leave;
     TextMemo:=(E.ClassName+' поднята ошибка, с сообщением : '+E.Message+#13#10+'Работа остановлена программой. Напишите об ошибке разработчику!');
      work:=false;
      Synchronize(MemoText);

    end;
    end;

end;


procedure Working.MemoText;
begin
if textmemo='+1' then
Form1.sGauge1.Progress:=form1.sGauge1.Progress+1
else
Form1.Memo1.Lines.Add(textmemo);
if pos('поднята ошибка, с сообщением',textmemo)<>0 then Form1.button1.Caption:='Начать';
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
CS.Free;
Proxy.Free;
Items.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
http:tidhttp;
html:string;
begin
try begin
http:=tidhttp.Create(nil);
http.Get('http://melkei.mcdir.ru/steambp/count.php');
html:=http.Get('http://melkei.mcdir.ru/steambp/count.txt');
Form1.Caption:=Form1.Caption+' | Всего запустило: ' + html;
end;
except

end;
Memo1.Lines.Add('Посмотреть обновления, ответы на вопросы можно тут:');
Memo1.Lines.Add('http://gcd-team.ru/forum/showthread.php?p=2486');
Memo1.Lines.Add('Автор: Melkei');
CS:= TCriticalSection.Create;
focus:=true;
items:=tstringlist.Create;
Proxy:=tstringlist.Create;

end;

procedure TForm1.Memo1Enter(Sender: TObject);
begin
{if focus then begin
if memo1.Focused then edit1.SetFocus;
focus:=false;
end;}
end;

procedure TForm1.sButton1Click(Sender: TObject);
begin
  ShowMessage('Прокси только http/s !');
 OpenDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
 if OpenDialog1.Execute then
  begin
   Proxy.Clear;
   Proxy.LoadFromFile(OpenDialog1.FileName);
   ShowMessage('Загружено '+inttostr(Proxy.Count)+' прокси');
  end;
  end;

end.
