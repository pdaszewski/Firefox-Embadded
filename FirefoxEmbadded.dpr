program FirefoxEmbadded;

uses
  Vcl.Forms,
  AOknoGlfrm in 'AOknoGlfrm.pas' {AOknoGl},
  PrzegladarkaFirefoxfrm in 'PrzegladarkaFirefoxfrm.pas' {PrzegladarkaFirefox};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Firefox Embadded';
  Application.CreateForm(TAOknoGl, AOknoGl);
  Application.CreateForm(TPrzegladarkaFirefox, PrzegladarkaFirefox);
  Application.Run;
end.
