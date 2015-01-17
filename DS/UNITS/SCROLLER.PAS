{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

unit Scroller;

interface

  uses QCrt, Color80, StrAsm;

  const
    Attr = $03;
    ScanCount = $f;

  var
    SyncDelay : byte;

  function  CSpace ( S : String; W : Byte) : String;
  procedure WaitSync;
  procedure ScrollUp;
  function  PopByte ( var S : String ) : byte;
  procedure WriteStr ( S : String );

implementation

  function CSpace ( S : String; W : Byte) : String;
    begin
      S := Trim(S);
      S := LSpace( RSpace( S, W div 2 + Length(S) div 2 ), W);
      CSpace := S;
    end;

  procedure WaitSync;
    var I : byte;
    begin
      for I := 1 to SyncDelay do
        begin
          While Port[$3da] and $8 <> $8 do;
          While Port[$3da] and $8 = $8 do;
        end;
    end;

  procedure ScrollUp;
    var
      I : byte;
    begin
      for I := 0 to ScanCount do
        begin
          Port[$3d4] := $08;
          Port[$3d5] := I;
          WaitSync;
        end;
    end;

  function PopByte ( var S : String ) : byte;
    begin
      PopByte := Ord(S[1]);
      if S = '' then PopByte := 0;
      Delete( S, 1, 1 );
    end;

  procedure WriteStr ( S : String );
    var
      X, Y : Integer;
      C, P : byte;
      Attr : byte;
    begin
      Y := WhereY;
      S := RSpace(S, 80);
      Attr := TextAttr;
      while S <> '' do
        begin
          P := 1;
          For X := 1 to 80 do
            begin
              if P <= Length(S) then
                begin
                  C := Ord(S[P]);
                  if C = 27 then
                    begin
                      Inc(P);
                      Attr := Ord(S[P]);
                      Inc(P);
                      C := Ord(S[P]);
                    end;
                  Inc(P);
                  CO80Screen^[Y + 1, X, Asc] := C;
                end
              else
                CO80Screen^[Y + 1, X, Asc] := 32;
              CO80Screen^[Y + 1, X, Atr] := Attr;
            end;
          Delete (S, 1, P - 1);
          if Y = 25 then
            begin
              ScrollUp;
              Port[$3d4] := $08;
              Port[$3d5] := 0;
              Move ( Co80Screen^[2], Co80Screen^[1], 4000 );
            end
          else
            WriteLn;
        end;
    end;
begin
  SyncDelay := 1;
end.