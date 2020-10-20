program Seed128Demo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  Seed in '..\Seed.pas',
  SeedEncDec in '..\SeedEncDec.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
