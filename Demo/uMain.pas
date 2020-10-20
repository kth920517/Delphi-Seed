unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    edtUserKey: TEdit;
    edtIV: TEdit;
    edtText: TEdit;
    btnTest: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    procedure btnTestClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Seed, SeedEncDec;

{$R *.dfm}

procedure TForm1.btnTestClick(Sender: TObject);
var
  Seed : ISeed;
  EncData : string;
  DecData : string;
begin
  Memo1.Clear;
  Seed := TSeed.Create;

  Memo1.Lines.Add('Mode : ECB');

  Seed.InitForECB(edtUserKey.Text);
  EncData := Seed.Encrypt(edtText.Text);

  Memo1.Lines.Add('------Encrypt------');
  Memo1.Lines.Add('KeyToHex : ' + sLineBreak + TSeed(Seed).getKeyToHex(','));
  Memo1.Lines.Add('InDataToHex : ' + sLineBreak + TSeed(Seed).getInDataToHex(','));
  Memo1.Lines.Add('EncDataToHex : ' + sLineBreak + TSeed(Seed).getOutDataToHex(','));
  Memo1.Lines.Add('EncData : ' + sLineBreak + EncData);

  Seed.Burn;

  Seed.InitForECB(edtUserKey.Text);
  DecData := Seed.Decrypt(EncData);

  Memo1.Lines.Add('------Decrypt------');
  Memo1.Lines.Add('KeyToHex : ' + sLineBreak + TSeed(Seed).getKeyToHex(','));
  Memo1.Lines.Add('InDataToHex : ' + sLineBreak + TSeed(Seed).getInDataToHex(','));
  Memo1.Lines.Add('DecDataToHex : ' + sLineBreak + TSeed(Seed).getOutDataToHex(','));
  Memo1.Lines.Add('DecData : ' + sLineBreak + DecData);
  Memo1.Lines.Add('-------------------');
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Seed : ISeed;
  EncData : string;
  DecData : string;
begin
  Memo1.Clear;
  Seed := TSeed.Create;

  Memo1.Lines.Add('Mode : CBC');

//  Seed.InitForCBC(edtUserKey.Text, edtIV.Text);
//  EncData := Seed.Encrypt(edtText.Text);
  EncData := Seed.EncryptForCBC(edtUserKey.Text, edtIV.Text, edtText.Text);

  Memo1.Lines.Add('------Encrypt------');
  Memo1.Lines.Add('KeyToHex : ' + sLineBreak + TSeed(Seed).getKeyToHex(','));
  Memo1.Lines.Add('InDataToHex : ' + sLineBreak + TSeed(Seed).getInDataToHex(','));
  Memo1.Lines.Add('EncDataToHex : ' + sLineBreak + TSeed(Seed).getOutDataToHex(','));
  Memo1.Lines.Add('EncData : ' + sLineBreak + EncData);

  Seed.Burn;

//  Seed.InitForCBC(edtUserKey.Text, edtIV.Text);
//  DecData := Seed.Decrypt(EncData);
  DecData := Seed.DecryptForCBC(edtUserKey.Text, edtIV.Text, EncData);

  Memo1.Lines.Add('------Decrypt------');
  Memo1.Lines.Add('KeyToHex : ' + sLineBreak + TSeed(Seed).getKeyToHex(','));
  Memo1.Lines.Add('InDataToHex : ' + sLineBreak + TSeed(Seed).getInDataToHex(','));
  Memo1.Lines.Add('DecDataToHex : ' + sLineBreak + TSeed(Seed).getOutDataToHex(','));
  Memo1.Lines.Add('DecData : ' + sLineBreak + DecData);
  Memo1.Lines.Add('-------------------');
end;

end.
