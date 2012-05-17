unit umd5;

interface

uses Windows, SysUtils;

type
  THash = DWord;
function md5(buf: AnsiString): AnsiString;

implementation

var
  HEX: array [Word] of string;

function LRot32(a, b: LongWord): LongWord;
asm
  mov ecx, edx
  rol eax, cl
end;

function md5(buf: AnsiString): AnsiString;
type
  pint = ^Integer;
  tdata = array [0 .. 15] of DWord;
  pdata = ^tdata;
  tbyte = array [0 .. 15] of byte;
  pbyte = ^tbyte;
var
  i, Len: Integer;
  data: pdata;
  CurrentHash: array [0 .. 3] of DWord;
  P: array [0 .. 7] of Word absolute CurrentHash;
  a, b, C, D: DWord;
begin
  Len := Length(buf);
  SetLength(buf, 64);
  buf[Len + 1] := #$80;
  FillChar(buf[Len + 2], 63 - Len, 0);
  pint(@buf[57])^ := Len * 8;
  CurrentHash[0] := $67452301;
  CurrentHash[1] := $EFCDAB89;
  CurrentHash[2] := $98BADCFE;
  CurrentHash[3] := $10325476;
  a := CurrentHash[0];
  b := CurrentHash[1];
  C := CurrentHash[2];
  D := CurrentHash[3];
  data := addr(buf[1]);
  a := b + LRot32(a + (D xor (b and (C xor D))) + data^[0] + $D76AA478, 7);
  D := a + LRot32(D + (C xor (a and (b xor C))) + data^[1] + $E8C7B756, 12);
  C := D + LRot32(C + (b xor (D and (a xor b))) + data^[2] + $242070DB, 17);
  b := C + LRot32(b + (a xor (C and (D xor a))) + data^[3] + $C1BDCEEE, 22);
  a := b + LRot32(a + (D xor (b and (C xor D))) + data^[4] + $F57C0FAF, 7);
  D := a + LRot32(D + (C xor (a and (b xor C))) + data^[5] + $4787C62A, 12);
  C := D + LRot32(C + (b xor (D and (a xor b))) + data^[6] + $A8304613, 17);
  b := C + LRot32(b + (a xor (C and (D xor a))) + data^[7] + $FD469501, 22);
  a := b + LRot32(a + (D xor (b and (C xor D))) + data^[8] + $698098D8, 7);
  D := a + LRot32(D + (C xor (a and (b xor C))) + data^[9] + $8B44F7AF, 12);
  C := D + LRot32(C + (b xor (D and (a xor b))) + data^[10] + $FFFF5BB1, 17);
  b := C + LRot32(b + (a xor (C and (D xor a))) + data^[11] + $895CD7BE, 22);
  a := b + LRot32(a + (D xor (b and (C xor D))) + data^[12] + $6B901122, 7);
  D := a + LRot32(D + (C xor (a and (b xor C))) + data^[13] + $FD987193, 12);
  C := D + LRot32(C + (b xor (D and (a xor b))) + data^[14] + $A679438E, 17);
  b := C + LRot32(b + (a xor (C and (D xor a))) + data^[15] + $49B40821, 22);
  a := b + LRot32(a + (C xor (D and (b xor C))) + data^[1] + $F61E2562, 5);
  D := a + LRot32(D + (b xor (C and (a xor b))) + data^[6] + $C040B340, 9);
  C := D + LRot32(C + (a xor (b and (D xor a))) + data^[11] + $265E5A51, 14);
  b := C + LRot32(b + (D xor (a and (C xor D))) + data^[0] + $E9B6C7AA, 20);
  a := b + LRot32(a + (C xor (D and (b xor C))) + data^[5] + $D62F105D, 5);
  D := a + LRot32(D + (b xor (C and (a xor b))) + data^[10] + $02441453, 9);
  C := D + LRot32(C + (a xor (b and (D xor a))) + data^[15] + $D8A1E681, 14);
  b := C + LRot32(b + (D xor (a and (C xor D))) + data^[4] + $E7D3FBC8, 20);
  a := b + LRot32(a + (C xor (D and (b xor C))) + data^[9] + $21E1CDE6, 5);
  D := a + LRot32(D + (b xor (C and (a xor b))) + data^[14] + $C33707D6, 9);
  C := D + LRot32(C + (a xor (b and (D xor a))) + data^[3] + $F4D50D87, 14);
  b := C + LRot32(b + (D xor (a and (C xor D))) + data^[8] + $455A14ED, 20);
  a := b + LRot32(a + (C xor (D and (b xor C))) + data^[13] + $A9E3E905, 5);
  D := a + LRot32(D + (b xor (C and (a xor b))) + data^[2] + $FCEFA3F8, 9);
  C := D + LRot32(C + (a xor (b and (D xor a))) + data^[7] + $676F02D9, 14);
  b := C + LRot32(b + (D xor (a and (C xor D))) + data^[12] + $8D2A4C8A, 20);
  a := b + LRot32(a + (b xor C xor D) + data^[5] + $FFFA3942, 4);
  D := a + LRot32(D + (a xor b xor C) + data^[8] + $8771F681, 11);
  C := D + LRot32(C + (D xor a xor b) + data^[11] + $6D9D6122, 16);
  b := C + LRot32(b + (C xor D xor a) + data^[14] + $FDE5380C, 23);
  a := b + LRot32(a + (b xor C xor D) + data^[1] + $A4BEEA44, 4);
  D := a + LRot32(D + (a xor b xor C) + data^[4] + $4BDECFA9, 11);
  C := D + LRot32(C + (D xor a xor b) + data^[7] + $F6BB4B60, 16);
  b := C + LRot32(b + (C xor D xor a) + data^[10] + $BEBFBC70, 23);
  a := b + LRot32(a + (b xor C xor D) + data^[13] + $289B7EC6, 4);
  D := a + LRot32(D + (a xor b xor C) + data^[0] + $EAA127FA, 11);
  C := D + LRot32(C + (D xor a xor b) + data^[3] + $D4EF3085, 16);
  b := C + LRot32(b + (C xor D xor a) + data^[6] + $04881D05, 23);
  a := b + LRot32(a + (b xor C xor D) + data^[9] + $D9D4D039, 4);
  D := a + LRot32(D + (a xor b xor C) + data^[12] + $E6DB99E5, 11);
  C := D + LRot32(C + (D xor a xor b) + data^[15] + $1FA27CF8, 16);
  b := C + LRot32(b + (C xor D xor a) + data^[2] + $C4AC5665, 23);
  a := b + LRot32(a + (C xor (b or (not D))) + data^[0] + $F4292244, 6);
  D := a + LRot32(D + (b xor (a or (not C))) + data^[7] + $432AFF97, 10);
  C := D + LRot32(C + (a xor (D or (not b))) + data^[14] + $AB9423A7, 15);
  b := C + LRot32(b + (D xor (C or (not a))) + data^[5] + $FC93A039, 21);
  a := b + LRot32(a + (C xor (b or (not D))) + data^[12] + $655B59C3, 6);
  D := a + LRot32(D + (b xor (a or (not C))) + data^[3] + $8F0CCC92, 10);
  C := D + LRot32(C + (a xor (D or (not b))) + data^[10] + $FFEFF47D, 15);
  b := C + LRot32(b + (D xor (C or (not a))) + data^[1] + $85845DD1, 21);
  a := b + LRot32(a + (C xor (b or (not D))) + data^[8] + $6FA87E4F, 6);
  D := a + LRot32(D + (b xor (a or (not C))) + data^[15] + $FE2CE6E0, 10);
  C := D + LRot32(C + (a xor (D or (not b))) + data^[6] + $A3014314, 15);
  b := C + LRot32(b + (D xor (C or (not a))) + data^[13] + $4E0811A1, 21);
  a := b + LRot32(a + (C xor (b or (not D))) + data^[4] + $F7537E82, 6);
  D := a + LRot32(D + (b xor (a or (not C))) + data^[11] + $BD3AF235, 10);
  C := D + LRot32(C + (a xor (D or (not b))) + data^[2] + $2AD7D2BB, 15);
  b := C + LRot32(b + (D xor (C or (not a))) + data^[9] + $EB86D391, 21);
  Inc(CurrentHash[0], a);
  Inc(CurrentHash[1], b);
  Inc(CurrentHash[2], C);
  Inc(CurrentHash[3], D);
  Result := StrLower(PChar(HEX[P[0]]));
  for i := 1 to 7 do Result := Concat(Result, StrLower(PChar(HEX[P[i]])));
end;

var
  DEC, Tmp: Integer;
  LH: AnsiString;

initialization

for DEC := 0 to $FFFF do begin
  Tmp := DEC and $FF;
  LH := IntToHex(Tmp, 2);
  Tmp := DEC shr 8;
  HEX[DEC] := Concat(LH, IntToHex(Tmp, 2));
end;

end.
