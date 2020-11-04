
{******************************************************************************}
{                                                                              }
{                           Delphi Kisa Seed128                                }
{                                                                              }
{                       Copyright (C) TeakHyun Kang                            }
{                                                                              }
{                       https://github.com/kth920517                           }
{                       https://developist.tistory.com/                        }
{                                                                              }
{******************************************************************************}

unit SeedEncDec;

interface

uses
  System.SysUtils, NetEncoding, SeedCore;

const
  SEED_ENCRYPT = 0;
  SEED_DECRYPT = 1;
  BLOCK_SIZE = 16;

type
  TCryptMode = (cmECB, cmCBC);

  TSeedInfo = record
    Mode     : TCryptMode;
    UserKey  : Array[0..15] of BYTE;
    IV       : Array[0..15] of BYTE;
    RoundKey : Array[0..31] of LongWord;
    Data     : TBytes;

    procedure Init;
    procedure SetUserKey(const AKey: string);
    procedure SetIV(const AIV: string); overload;
    procedure SetIV(const AIV: array of Byte); overload;
  end;
  PSeedInfo = ^TSeedInfo;

  ISeed = interface
    procedure InitForECB(const AUserKey: string);
    procedure InitForCBC(const AUserKey, AIV: string);
    procedure Init(const AUserKey, AIV: string; AMode: TCryptMode);

    function EncryptForECB(const AUserKey, AData: string): string;
    function EncryptForCBC(const AUserKey, AIV, AData: string): string;
    function Encrypt(const AData: string): string;

    function DecryptForECB(const AUserKey, AData: string): string;
    function DecryptForCBC(const AUserKey, AIV, AData: string): string;
    function Decrypt(const AData: string): string;

    procedure Burn;
  end;

  TSeed = class(TInterfacedObject, ISeed)
  private
    SeedInfo: PSeedInfo;

    isInitialized : Boolean;
    isProcessed : Boolean;

    FPaddingLength : Integer;
    FInLength : Integer;
    FOutLength : Integer;
    FInData : TBytes;
    FOutData : TBytes;

    Base64Encoding : TBase64Encoding;

    function ByteArrayToHex(AData: array of Byte; ASplit: Char = #0): string;

    procedure Reset;
    procedure PKCS5Padding(AType: Integer; var AData: TBytes);
    procedure BlockXOR(var ABlockData: array of Byte; const AIV: array of Byte);
    procedure PrepareData(AType: Integer; AData: string);
  public
    constructor Create(ACharPerLine: ShortInt = 76; ALineSeparator: string = sLineBreak);
    destructor Destroy; override;

    procedure InitForECB(const AUserKey: string);
    procedure InitForCBC(const AUserKey, AIV: string);
    procedure Init(const AUserKey, AIV: string; AMode: TCryptMode);

    function EncryptForECB(const AUserKey, AData: string): string;
    function EncryptForCBC(const AUserKey, AIV, AData: string): string;
    function Encrypt(const AData: string): string;

    function DecryptForECB(const AUserKey, AData: string): string;
    function DecryptForCBC(const AUserKey, AIV, AData: string): string;
    function Decrypt(const AData: string): string;

    procedure Burn;

    property InLength: Integer read FInLength;
    property OutLength: Integer read FOutLength;
    property PaddingLength: Integer read FPaddingLength;
  end;

  TSeedHelper = class helper for TSeed
    function getKeyToHex(Split: Char = #0): string;
    function getInDataToHex(Split: Char = #0): string;
    function getOutDataToHex(Split: Char = #0): string;
  end;

implementation

{ TSeedInfo }

procedure TSeedInfo.Init;
begin
  Mode := cmCBC;

  FillChar(Self.UserKey, 16, 0);
  FillChar(Self.IV, 16, 0);
  FillChar(Self.RoundKey, 32, 0);

  SetLength(Self.Data, 0);
end;

procedure TSeedInfo.SetIV(const AIV: array of Byte);
begin
  FillChar(Self.IV, 16, 0);
  Move(AIV, Self.IV, 16);
end;

procedure TSeedInfo.SetIV(const AIV: string);
var
  TempIV : TBytes;
begin
  TempIV := TEncoding.UTF8.GetBytes(AIV);

  if Length(TempIV) <> 16 then
    raise Exception.Create('IV is Not 16 digits in length.');

  Move(TempIV[0], Self.IV, 16);
end;

procedure TSeedInfo.SetUserKey(const AKey: string);
var
  TempKey : TBytes;
begin
  TempKey := TEncoding.UTF8.GetBytes(AKey);

  if Length(TempKey) <> 16 then
    raise Exception.Create('UserKey is Not 16 digits in length.');

  Move(TempKey[0], Self.UserKey, 16);
end;

{ TSeed }

constructor TSeed.Create(ACharPerLine: ShortInt; ALineSeparator: string);
begin
  try
    Base64Encoding := TBase64Encoding.Create(ACharPerLine, ALineSeparator);

    New(SeedInfo);

    Burn;
  except
    on E: Exception do
      raise Exception.Create('[Create Error] ' + E.Message);
  end;
end;

destructor TSeed.Destroy;
begin
  Burn;

  Dispose(SeedInfo);

  if Assigned(Base64Encoding) then Base64Encoding.Free;  

  inherited;
end;

procedure TSeed.Burn;
begin
  Reset;
  SeedInfo.Init;
end;

function TSeed.ByteArrayToHex(AData: array of Byte; ASplit: Char): string;
var
  I: integer;
begin
  Result := '';

  for I := Low(AData) to High(AData) do begin
    if not Result.IsEmpty then Result := Result + ASplit;

    Result := Result + IntToHex(AData[I], 2);
  end;
end;

procedure TSeed.PKCS5Padding(AType: Integer; var AData: TBytes);
var
  I: Integer;
  bPadding : Boolean;
  PaddingByte : Byte;
begin
  try
    if AType = SEED_ENCRYPT then begin
      FPaddingLength := BLOCK_SIZE - (InLength mod BLOCK_SIZE);

      if PaddingLength <> 0 then begin
        SetLength(AData, InLength + PaddingLength);

        for I := InLength to InLength + PaddingLength - 1 do
          AData[I] := Byte(PaddingLength);
      end;
    end
    else begin
      PaddingByte := AData[High(AData)];
      FPaddingLength := Integer(PaddingByte);

      if PaddingLength <> 0 then begin
        bPadding := False;

        for I := High(AData) downto OutLength - PaddingLength do begin
          bPadding := (AData[I] = PaddingByte);

          if not bPadding then break;
        end;

        if bPadding then
          SetLength(AData, InLength - PaddingLength)
        else
          SetLength(AData, InLength);
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create('[Padding Error] ' + E.Message);
  end;
end;

procedure TSeed.PrepareData(AType: Integer; AData: string);
begin
  try
    if AType = SEED_ENCRYPT then
      SeedInfo^.Data := TEncoding.UTF8.GetBytes(AData)
    else begin
      SeedInfo^.Data := Base64Encoding.DecodeStringToBytes(AData);
    end;

    FInLength := Length(SeedInfo^.Data);

    SetLength(FInData, InLength);
    Move(SeedInfo^.Data[0], FInData[0], InLength);
  except
    on E: Exception do
      raise Exception.Create('[Prepare Error] ' + E.Message);
  end;
end;

procedure TSeed.Reset;
begin
  isInitialized := False;
  isProcessed := False;

  FInLength := 0;
  FOutLength := 0;
  FPaddingLength := 0;

  SetLength(FInData, 0);
  SetLength(FOutData, 0);
end;

procedure TSeed.BlockXOR(var ABlockData: array of Byte; const AIV: array of Byte);
var
  I : Integer;
begin
   for I := Low(ABlockData) to High(AIV) do
      ABlockData[I] := ABlockData[I] xor AIV[I];
end;

procedure TSeed.InitForCBC(const AUserKey, AIV: string);
begin
  Self.Init(AUserKey, AIV, cmCBC);
end;

procedure TSeed.InitForECB(const AUserKey: string);
begin
  Self.Init(AUserKey, '', cmECB);
end;

procedure TSeed.Init(const AUserKey, AIV: string; AMode: TCryptMode);
begin
  try
    SeedInfo^.Mode := AMode;
    SeedInfo.SetUserKey(AUserKey);

    if (SeedInfo^.Mode = cmCBC) then SeedInfo.SetIV(AIV);

    SeedEncRoundKey(SeedInfo^.RoundKey, SeedInfo^.UserKey);

    isInitialized := True;
  except
    on E: Exception do
      raise Exception.Create('[Init Error] ' + E.Message);
  end;
end;

function TSeed.EncryptForCBC(const AUserKey, AIV, AData: string): string;
begin
  InitForCBC(AUserKey, AIV);

  Result := Encrypt(AData);
end;

function TSeed.EncryptForECB(const AUserKey, AData: string): string;
begin
  InitForECB(AUserKey);

  Result := Encrypt(AData);
end;

function TSeed.Encrypt(const AData: string): string;
var
  I : Integer;
  nStep : Integer;
  BlockData : Array[0..15] of BYTE;
begin
  nStep := 1;

  try
    if not isInitialized then
      raise Exception.Create('It''s not initialized.');

    nStep := 2;
    PrepareData(SEED_ENCRYPT, AData);

    nStep := 3;
    PKCS5Padding(SEED_ENCRYPT, FInData);

    nStep := 4;
    FOutLength := InLength + PaddingLength;
    SetLength(FOutData, FOutLength);

    nStep := 5;
    I := 0;

    while I < FOutLength do begin
      FillChar(BlockData, BLOCK_SIZE, 0);
      Move(FInData[I], BlockData, BLOCK_SIZE);

      if (SeedInfo^.Mode = cmCBC) then BlockXOR(BlockData, SeedInfo^.IV);

      SeedEncrypt(BlockData, SeedInfo^.RoundKey);
      Move(BlockData[0], FOutData[I], BLOCK_SIZE);

      if (SeedInfo^.Mode = cmCBC) then SeedInfo.SetIV(BlockData);

      Inc(I, BLOCK_SIZE);
    end;

    Result := Base64Encoding.EncodeBytesToString(FOutData);

    isProcessed := True;
  except
    on E: Exception do
      raise Exception.Create('[Encrypt Error Step ' + nStep.ToString + '] ' + E.Message);
  end;
end;

function TSeed.DecryptForCBC(const AUserKey, AIV, AData: string): string;
begin
  InitForCBC(AUserKey, AIV);

  Result := Decrypt(AData);
end;

function TSeed.DecryptForECB(const AUserKey, AData: string): string;
begin
  InitForECB(AUserKey);

  Result := Decrypt(AData);
end;

function TSeed.Decrypt(const AData: string): string;
var
  I : Integer;
  nStep : Integer;
  BlockData : Array[0..15] of BYTE;
begin
  nStep := 1;

  try
    if not isInitialized then
      raise Exception.Create('It''s not initialized.');

    nStep := 2;
    PrepareData(SEED_DECRYPT, AData);

    nStep := 3;
    FOutLength := InLength;
    SetLength(FOutData, FOutLength);

    nStep := 4;
    I := 0;

    while I < FOutLength do begin
      FillChar(BlockData, BLOCK_SIZE, 0);
      Move(FInData[I], BlockData, BLOCK_SIZE);

      SeedDecrypt(BlockData, SeedInfo^.RoundKey);

      if (SeedInfo^.Mode = cmCBC) then begin
        BlockXOR(BlockData, SeedInfo^.IV);
        SeedInfo.SetIV(FInData[I]);
      end;

      Move(BlockData[0], FOutData[I], BLOCK_SIZE);

      Inc(I, BLOCK_SIZE);
    end;

    nStep := 5;
    PKCS5Padding(SEED_DECRYPT, FOutData);

    Result := TEncoding.UTF8.GetString(FOutData);

    isProcessed := True;
  except
    on E: Exception do
      raise Exception.Create('[Encrypt Error Step ' + nStep.ToString + '] ' + E.Message);
  end;
end;

{ TSeedHelper }

function TSeedHelper.getKeyToHex(Split: Char): string;
begin
  Result := '';

  if not Self.isInitialized then Exit;

  Result := Self.ByteArrayToHex(Self.SeedInfo^.UserKey, Split);
end;

function TSeedHelper.getInDataToHex(Split: Char): string;
begin
  Result := '';

  if not Self.isProcessed then Exit;

  Result := Self.ByteArrayToHex(Self.SeedInfo^.Data, Split);
end;

function TSeedHelper.getOutDataToHex(Split: Char): string;
begin
  Result := '';

  if not Self.isProcessed then Exit;

  Result := Self.ByteArrayToHex(FOutData, Split);
end;

end.
