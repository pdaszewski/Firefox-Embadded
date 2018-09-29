unit AOknoGlfrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TAOknoGl = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AOknoGl: TAOknoGl;

implementation

{$R *.dfm}

uses PrzegladarkaFirefoxfrm;

procedure TAOknoGl.SpeedButton1Click(Sender: TObject);
begin
  PrzegladarkaFirefox.Uruchom('C:\Program Files\Mozilla Firefox\firefox.exe',
    'http://fxsystems.com.pl', 'FX Systems');
end;

end.
