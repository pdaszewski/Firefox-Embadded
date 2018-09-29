unit PrzegladarkaFirefoxfrm;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  StdCtrls, ExtCtrls, ShellApi, Windows;

type
  TPrzegladarkaFirefox = class(TForm)
    Panel_wbudowany: TPanel;
    procedure Uruchom_Firefox_ze_strona(sciezka_firefoxa, strona: String);
    procedure Uruchom(sciezka_firefoxa, strona, tytul: String);
    procedure FormCreate(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  PrzegladarkaFirefox: TPrzegladarkaFirefox;
  juz_uruchomiony: Boolean;

implementation

{$R *.dfm}

procedure TPrzegladarkaFirefox.FormCreate(Sender: TObject);
begin
  juz_uruchomiony := False;
end;

procedure TPrzegladarkaFirefox.Uruchom(sciezka_firefoxa, strona, tytul: String);
Begin
  if FileExists(sciezka_firefoxa) = True then
  Begin
    PrzegladarkaFirefox.Show;
    if juz_uruchomiony = False then
    Begin
      Caption := tytul;
      WindowState := wsMaximized;
      Uruchom_Firefox_ze_strona(sciezka_firefoxa, strona);
      juz_uruchomiony := True;
    End;
  End
  else
    ShowMessage('Nie mogê odszukaæ programu Firefox!');
End;

procedure TPrzegladarkaFirefox.Uruchom_Firefox_ze_strona(sciezka_firefoxa, strona: String);
Var
  Lista: TStringList;
  poz, skok: Integer;
  uchwyt: hwnd;
  linia, numer_uchwytu: String;
  zabezpieczenie: Integer;

  procedure ShowAppEmbedded(WindowHandle: THandle; Container: TWinControl);
  var
    WindowStyle: Integer;
    FAppThreadID: Cardinal;
  begin
    WindowStyle := GetWindowLong(WindowHandle, GWL_STYLE);
    WindowStyle := WindowStyle - WS_CAPTION - WS_BORDER - WS_OVERLAPPED - WS_THICKFRAME;
    SetWindowLong(WindowHandle, GWL_STYLE, WindowStyle);
    FAppThreadID := GetWindowThreadProcessId(WindowHandle, nil);
    AttachThreadInput(GetCurrentThreadId, FAppThreadID, True);
    Windows.SetParent(WindowHandle, Container.Handle);
    SendMessage(Container.Handle, WM_UPDATEUISTATE, UIS_INITIALIZE, 0);
    UpdateWindow(WindowHandle);
    SetWindowLong(Container.Handle, GWL_STYLE, GetWindowLong(Container.Handle, GWL_STYLE) or WS_CLIPCHILDREN);

    // Poni¿ej wa¿na linijka: wpis -120 to przesuniêcie okna w górê, a +150 to rozci¹gniêcie canvas w dó³ - tak by umieœciæ wszystko ³adnie!!
    SetWindowPos(WindowHandle, 0, 0, -120, Container.ClientWidth, Container.ClientHeight + 150, SWP_NOZORDER);
    SetForegroundWindow(WindowHandle);
  end;

  function EnumWindowsProc(hwnd: hwnd; List: TStringList): BOOL; stdcall;
  var
    s: string;
    IsVisible, IsOwned, IsAppWindow: Boolean;
  begin
    Result := True;
    IsVisible := IsWindowVisible(hwnd);
    if not IsVisible then
      exit;
    IsOwned := GetWindow(hwnd, GW_OWNER) <> 0;
    if IsOwned then
      exit;
    IsAppWindow := GetWindowLongPtr(hwnd, GWL_STYLE) and WS_EX_APPWINDOW <> 0;
    if not IsAppWindow then
      exit;
    SetLength(s, GetWindowTextLength(hwnd));
    GetWindowText(hwnd, PChar(s), Length(s) + 1);
    // Wyszukujê okno gdzie w nazwie jest Firefox i FX
    if (Pos('Firefox', s) > 0) and (Pos('FX', s) > 0) then
    Begin
      s := s + '-::' + IntToStr(hwnd);
      List.Add(s);
    End;
  end;

Begin
  Lista := TStringList.Create;
  Lista.Clear;
  // Najpierw przeszukujê listê procesów by nie odszukaæ Firefox zombi - taki Firefox, który jest zawieszony
  EnumWindows(@EnumWindowsProc, lparam(Lista));
  if Lista.Count > 0 then // Jeœli znajdê:
  Begin
    linia := Lista.Strings[0];
    poz := Pos('-::', linia);
    numer_uchwytu := Trim(Copy(linia, poz + 3, 100));
    uchwyt := StrToInt(numer_uchwytu);
    Windows.TerminateProcess(uchwyt, 0); // Ubijam proces!
  end;
  Sleep(100); // Odczekujê sekundê - tak na wszelki wypade3k

  // Uruchamiam now¹ instancjê Firefox z wstawion¹ stron¹
  ShellExecute(0, 'Open', PChar('"' + sciezka_firefoxa + '"'), PChar('-new-window ' + strona), PChar(''), SW_MAXIMIZE);
  // http://195.117.152.84/teleopiekun/

  Lista.Clear;
  zabezpieczenie := 0;
  // Wyszukujê now¹ instancjê firefox - powtarzam 100 razy po 1 sekundzie, lub do odnalezienie w³aœciwego okna
  Repeat
    Sleep(100);
    Application.ProcessMessages;
    Lista.Clear;
    EnumWindows(@EnumWindowsProc, lparam(Lista)); // Samo wyszukiwanie okna.
    zabezpieczenie := zabezpieczenie + 1;
  Until (Lista.Count > 0) or (zabezpieczenie = 100);
  if Lista.Count > 0 then // Jeœli coœ znalaz³em
  Begin
    linia := Lista.Strings[0];
    poz := Pos('-::', linia);
    numer_uchwytu := Trim(Copy(linia, poz + 3, 100));
    uchwyt := StrToInt(numer_uchwytu);
    ShowAppEmbedded(uchwyt, Panel_wbudowany);
    // Przejmujê proces i wyœwietlam go we wskazanym komponencie (popatrz na wielkoœæ aplikacji po przechwyceniu!!!)
  end
  else
  Begin
    ShowMessage('Nie uda³o siê uruchomiæ Firefox!');
  end;
  Lista.Free;
End;

end.
