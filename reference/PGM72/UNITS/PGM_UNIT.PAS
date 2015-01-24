{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit PGM_UNIT;

interface


         procedure SetCursor       (NewCursor : Word);
         procedure NormCursor;
         procedure HideCursor;
         procedure InsCursor;
         procedure Color           (Forg, Backg : Integer);
         procedure Pause;
         Procedure Rkey            (Var Stn : String; MaxLen, MaxWin
                                                              : Integer;
                                    var Qt : Boolean                    );
         procedure SetSColor (Xpos, YPos, Cl : Integer);

         function GetText   (Xpos, YPos : Byte)               : Char;
         function GetSColor (Xpos, YPos : Byte)               : Byte;
         function GetTColor (CValue : Byte)                   : Byte;
         function GetBColor (CValue : Byte)                   : Byte;
         function LSpace    (IO : String;      MaxSize : Integer)  : String;
         function RSpace    (IO : String;      MaxSize : Integer)  : String;
         function LPad      (IO : String; Asc, MaxSize : Integer)  : String;
         function RPad      (IO : String; Asc, MaxSize : Integer)  : String;
         function PadNum    (Number, MaxSize : Integer)            : String;
         function Ucase     (IO : String)                     : String;
         function LCase     (IO : String)                     : String;
{        function InKey                                       : String;}
         function Trim      (IO :String)                      : String;
         function RTrim     (IO : String)                     : String;
         function LTrim     (IO : String)                     : String;
         function CheckSize (IO : String; MaxSize : Integer)  : String;
{         function AddSpace  (IO : String; MaxSize : Integer)  : String;}
         function Space     (Number : Integer)                : String;
         function ChrStr    (Ch : String; Number : Integer)   : String;
         function Mid       (IO : String; St, Ed : Integer)   : String;

function SearchStr (StartPos : integer; MainStr, SubStr : String) : Integer;


implementation

uses QCrtNM ,Dos, TxtMouse;

const
  Ins  = 3345;
  Norm = 3342;
  Off  = $2000;

procedure SetCursor(NewCursor : Word);
          var
             Reg : Registers;

          begin
               with Reg do
                    begin
                         AH := 1;
                         BH := 0;
                         CX := NewCursor;
                         Intr($10, Reg);
                    end;
          end;

procedure NormCursor;
          begin
               SetCursor (Norm)
          end;

procedure HideCursor;
          begin
               SetCursor (Off)
          end;

procedure InsCursor;
          begin
               SetCursor (Ins);
          end;

procedure Color (Forg, Backg : Integer);
          begin
               TextColor (Forg);
               TextBackGround (Backg);
          end;

          var
             I : String[2];

function InKey : String;
         begin
              I := '';
              If KeyPressed then
                 begin
                      I := ReadKey;
                      If I = Chr(0) then
                         I := I + ReadKey
                 end;
              Inkey := I
         end;

function Ltrim (IO :String): String;
         begin
              Ltrim := IO;
              If IO[1] = ' ' then
                 begin
                      Delete (IO,1,1);
                      Ltrim := Ltrim(IO);
                 end;
         end;

function Rtrim (IO :String): String;
         begin
              While IO[Length(IO)] = ' ' do
                      Delete (IO,Length(IO),1);
              Rtrim := IO;
         end;

function Trim (IO :String) : String;
         begin
              Trim := Ltrim(Rtrim(IO));
         end;

procedure Pause;
         begin
              While (Inkey ='') and (MouseButton1 = False) Do;
         end;

function CheckSize(IO : String; MaxSize : Integer): String;
         begin
              CheckSize := IO;
              If Length(IO) > MaxSize then
                 begin
                      Delete(IO,Length(IO),1);
                      CheckSize := CheckSize (IO,MaxSize)
                 end
         end;

function LSpace (IO : String; MaxSize : Integer) : String;
         begin
              While Length(IO)< MaxSize do
                 Insert (' ', IO, 1);
              LSpace := IO;
         end;

function RSpace (IO : String; MaxSize : Integer) : String;
         begin
              While Length(IO)< MaxSize do
                 Insert (' ', IO, Length(IO)+1);
              RSpace := IO;
         end;

function LPad (IO : String; asc, MaxSize : Integer) : String;
         begin
              While Length(IO)< MaxSize do
                 Insert (Chr(asc), IO, 1);
              LPad := IO;
         end;

function RPad (IO : String; asc, MaxSize : Integer) : String;
         begin
              While Length(IO)< MaxSize do
                 Insert (Chr(Asc), IO, Length(IO)+1);
              RPad := IO;
         end;

function PadNum (Number, MaxSize : Integer) : String;
         var
            IO : String;
         begin
              Str (Number, IO);
              While Length(IO)< MaxSize  do
                 Insert ('0', IO, 1);
              PadNum := IO;
         end;

{function AddSpace (IO : String; MaxSize : Integer) : String;
         begin
              AddSpace := IO;
              If Length(IO)< MaxSize then
                 begin
                      Insert (' ', IO, Length(IO)+1);
                      AddSpace := AddSpace (IO, MaxSize)
                 end
         end;
 }
function UCase (IO : String) : String;
         procedure U;
                   var
                      Loop : Integer;
                   begin
                        For Loop := 1 to Length (IO) do
                            IO[Loop] := UpCase (IO[Loop]);
                        UCase := IO;
                   end;
         begin
              U;
         end;

function LCase (IO : String) : String;
         procedure L;
                   var
                      Loop : Integer;
                      Hold : Char;
                   begin
                        For Loop := 1 to Length (IO) do
                            begin
                                 Hold := IO[Loop];
                                 If (Hold >= 'A') and (Hold <= 'Z') then
                                    IO[Loop] := Chr(Ord(Hold)+32)
                            end;
                        LCase := IO;
                   end;
         begin
              L;
         end;

function Space (Number : Integer) : String;
         procedure MakeSpaces;
                   Var
                      Sp : String;
                      Lp : Integer;

                   begin
                      Sp := '';
                      For Lp := 1 to Number do
                          Sp := Sp + ' ';
                      Space := Sp;
                   end;
         begin
              MakeSpaces
         end;

function ChrStr (Ch : String; Number : Integer) : String;
         procedure MakeStr;
                   Var
                      Sp : String;
                      Lp : Integer;

                   begin
                      Sp := '';
                      For Lp := 1 to Number do
                          Sp := Sp + Ch;
                      ChrStr := Sp;
                   end;
         begin
              MakeStr
         end;

function Mid (IO : String; St, Ed : Integer) : String;

         procedure Generate;
                   var
                      Hold : String;
                      I : Integer;
                   begin
                        Hold := '';
                        For I := St to Ed do
                            Hold := Hold + IO[I];
                        Mid := Hold;
                   end;
         begin
              Generate;
         end;

Procedure Rkey (Var Stn : String; MaxLen, MaxWin : Integer; Var Qt : boolean);
        var
            Cx, Cy, Sw, Ld, Ll, Ln, Cmd, Cp                      : Integer;
            Im, Cg                                               : Boolean;
            Ss, Sp, S1                                           : String;
            Key                                                  : String[2];

procedure SetInitValues (S : String; LenMax, WinMax : Integer);
          begin
               Cx := WhereX;
               Cy := WhereY;
               Sw := WinMax;
               Ld := 1;
               Ll := LenMax;
               Ln := LenMax;
              Cmd := 0;
               Cp := Length(S) + 1;
               Im := True;
               Cg := True;
               Qt := False;
               Ss := S;
               Sp := '';
               Key := '';
          end;

procedure RKey3;
          begin
               If Length(Ss) >= Ln then
                  begin
                       Sound (200);
                       Delay (100);
                       NoSound
                  end
               else
                   begin
                        If Im = False then
                           Delete (Ss, Cp, 1);
                        Insert (Key, Ss, Cp);
                        Cp := Cp + 1;
                   end;
          end;

procedure RKey4;
          begin
               If Cp = 1 then
                  begin
                       Sound (200);
                       Delay (100);
                       NoSound
                  end
               else
                   begin
                        Cp := Cp - 1;
                        Delete (Ss, Cp, 1)
                   end
          end;

procedure Rkey5;
          begin
               If Cp = Length(Ss) + 1 then
                  Begin
                       Sound (200);
                       Delay (100);
                       NoSound
                  end
               else
                   Delete (Ss, Cp, 1)
          end;

procedure RKey6;
          begin
               Cg := False;
               If Cp < Ld then
                  begin
                       Ld := Ld - 1;
                       Cg := True;
                  end;
               If Cp > Ld + Ll then
                  begin
                       Ld := Ld + 1;
                       Cg := True;
                  end
          end;

procedure RKey7;
          begin
               Cp := 1;
               Cg := True;
               While Cg = True do
                     Rkey6
          end;

procedure RKey8;
          begin
               Cp := Length(Ss) + 1;
               Cg := True;
               While Cg = True do
                     Rkey6
          end;

begin
     SetInitValues (Stn, MaxLen, MaxWin);
     If Ln + Cx > Sw + Cx then Ll := (Sw + Cx - 1) - Cx + 1;
     While Cg = True do
           RKey6;
     While (Key <> Chr(13)) and (Qt = False) do
           begin
                RKey6;
                Ll := Ln;
                If Ln + Cx > Sw + Cx then Ll := (Sw + Cx - 1) - Cx + 1;
                S1 := Mid(Ss+Space(Ln), Ld, Ll+Ld);
                Sp := '';
                If Length(S1) < Sw - Ld - 1 then
                    Sp := Space((Sw - Ld) - Length(S1) + 1);
                GotoXY (Cx, Cy);
                Write (S1, Sp);
                GotoXY (Cx + (Cp - Ld), Cy);
                If Im = True then
                   InsCursor
                else
                    NormCursor;
                Key := '';
                While MouseButton1 do;
                While Key = '' Do
                   begin
                      Key := Inkey;
                      If MouseButton1 then Key := Chr(27);
                   end;
                If Length(Key)= 2 then
                   Case Ord(Key[2]) of
                     82 : If Im  then
                             Im := False
                          else
                             Im := True;
                     71 : Rkey7;
                     79 : Rkey8;
                     75 : If Cp > 1 then
                             Cp := Cp - 1;
                     77 : If Cp < Length(Ss) + 1 then
                             Cp := Cp + 1;
                     83 : Rkey5
                   end;
                If (Key > Chr(31)) and (Key < Chr(127)) then
                   RKey3;
                Case ord(Key[1]) of
                     8 : rkey4;
                     27: Qt := True
                end
           end;
     NormCursor;
     If Not Qt then Stn := Ss
     end;

    type
       ScrPtr = ^Screen;
       Screen = Array [1..25,1..80] of word;

   var
       MonoScreen : Screen Absolute $B000:$0000;
      ColorScreen : Screen Absolute $B800:$0000;
       KeepScreen : array [1..2] of Screen;
     ActiveScreen : ScrPtr;

function GetText (Xpos, YPos : Byte) : Char;
begin
   if LastMode = Mono then
      ActiveScreen := @MonoScreen
   else
      ActiveScreen := @ColorScreen;
   GetText := chr(Lo(ActiveScreen^[ypos,xpos]));
end;

function GetSColor (Xpos, YPos : Byte) : Byte;
begin
   if LastMode = Mono then
      ActiveScreen := @MonoScreen
   else
      ActiveScreen := @ColorScreen;
   GetSColor := HI(ActiveScreen^[ypos,xpos]);
end;

function GetTColor (CValue : Byte) : Byte;
begin
     GetTColor := CValue - (CValue div 16) * 16;
end;

function GetBColor (CValue : Byte) : Byte;
begin
     GetBColor := CValue div 16;
end;

function SearchStr (StartPos : integer; MainStr, SubStr : String) : Integer;
   var
     i, SubSize : Integer;
   begin
      SearchStr := 0;
      SubSize   := Length( SubStr );
      if ( Length( MainStr ) >= SubSize ) and ( SubSize >= 1 ) then
         for i := StartPos to Length( MainStr ) - SubSize + 1 do
            if Copy( MainStr, i, SubSize ) = SubStr then
               begin
                  SearchStr := i;
                  i         := Length ( MainStr )- SubSize + 1;
               end;
   end;
procedure SetSColor (Xpos, YPos, Cl : Integer);
Var
   H, C1, C2, C3 : Integer;

begin
   if LastMode = Mono then
      ActiveScreen := @MonoScreen
   else
      ActiveScreen := @ColorScreen;
   H := Lo( ActiveScreen^[Ypos, XPos] );
   GotoXY (Xpos, YPos);
   If Cl > 127 then
      begin
         Cl := Cl - 128;
         C3 := 128;
      end
   else
      C3 := 0;
   C2 := Cl div 16;
   C1 := Cl - C2 * 16;
   Color (C1+ C3, C2);
   Write (Chr(H));
end;

end.
