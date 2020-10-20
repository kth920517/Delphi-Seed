object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Seed128'
  ClientHeight = 593
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 91
    Width = 416
    Height = 502
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 91
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnTest: TButton
      Left = 327
      Top = 7
      Width = 82
      Height = 38
      Caption = 'ECB Test'
      TabOrder = 0
      OnClick = btnTestClick
    end
    object edtUserKey: TEdit
      Left = 8
      Top = 8
      Width = 313
      Height = 21
      MaxLength = 16
      TabOrder = 1
      TextHint = 'UserKey'
    end
    object edtIV: TEdit
      Left = 8
      Top = 35
      Width = 313
      Height = 21
      MaxLength = 16
      TabOrder = 2
      TextHint = 'IV'
    end
    object edtText: TEdit
      Left = 8
      Top = 62
      Width = 313
      Height = 21
      TabOrder = 3
      TextHint = 'Text'
    end
    object Button1: TButton
      Left = 327
      Top = 47
      Width = 82
      Height = 37
      Caption = 'CBC Test'
      TabOrder = 4
      OnClick = Button1Click
    end
  end
end
