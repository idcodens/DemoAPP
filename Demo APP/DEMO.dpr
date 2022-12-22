program DEMO;

uses
  System.StartUpCopy,
  FMX.Forms,
  uDemo in 'uDemo.pas' {frmDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDemo, frmDemo);
  Application.Run;
end.
