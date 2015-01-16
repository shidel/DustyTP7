{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
unit AnsiSys;

interface

  const
    Bold       : boolean = False;
    UnderScore : boolean = False;
    Blink      : boolean = False;
    Reverse    : boolean = False;
    Concealed  : boolean = False;
    BackGround : byte    = $00;
    ForeGround : byte    = $07;

  const
    { Escape sequence }
    ESC = #27'[';
    { Text attributes }
    Black      = 0;
    Red        = 1;
    Green      = 2;
    Yellow     = 3;
    Blue       = 4;
    Magenta    = 5;
    Cyan       = 6;
    White      = 7;
  { Modes }
    BW40       = 0;
    CO40       = 1;
    BW80       = 2;
    CO80       = 3;

  function  FStr ( B : byte ) : String;
  procedure WriteSTD ( S : String );
  procedure GotoXY   ( X, Y : byte );
  procedure CursorUp ( Count : byte );
  procedure CursorDown ( Count : byte );
  procedure CursorForward ( Count : byte );
  procedure CursorBackward ( Count : byte );
  procedure SavePosition;
  procedure RestorePosition;
  procedure ClrScr;
  procedure SetColor;
  procedure SetMode ( M : Byte );

implementation

  procedure WriteSTD ( S : String ); assembler;
    asm
      PUSH ES
      PUSH SI
      LES  SI, S
      MOV  CL, ES:[SI]
      MOV  CH, 0
      INC  SI
      CMP  CL, 0
      JE   @@Done
    @@WriteLoop:
      MOV  AH, $02
      MOV  DL, ES:[SI]
      INT  $21
      INC  SI
      LOOP @@WriteLoop
    @@Done:
      POP  SI
      POP  ES
    end;

  function FStr ( B : byte ) : String;
    var
      S : String;
    begin
      Str( B, S );
      FStr := S;
    end;

  procedure GotoXY ( X, Y : byte );
    begin
      WriteStd ( ESC + fStr(Y + 1) + ';' + fStr(X + 1) + 'H');
    end;

  procedure CursorUp ( Count : byte );
    begin
      WriteStd ( ESC + FStr( Count ) + 'A');
    end;

  procedure CursorDown ( Count : byte );
    begin
      WriteStd ( ESC + FStr( Count ) + 'B');
    end;

  procedure CursorForward ( Count : byte );
    begin
      WriteStd ( ESC + FStr( Count ) + 'C');
    end;

  procedure CursorBackward ( Count : byte );
    begin
      WriteStd ( ESC + FStr( Count ) + 'D');
    end;

  procedure SavePosition;
    begin
      WriteStd ( ESC + 's');
    end;


  procedure RestorePosition;
    begin
      WriteStd ( ESC + 'u');
    end;

  procedure ClrScr;
    begin
      WriteStd ( ESC + '2J');
    end;

  procedure SetColor;
    const
      LBold       : boolean = True;
      LUnderScore : boolean = True;
      LBlink      : boolean = True;
      LReverse    : boolean = True;
      LConcealed  : boolean = True;
      LFore       : Byte    = $FF;
      LBack       : Byte    = $FF;
    var
      Clear : boolean;
      S     : String;
    begin
      Clear       := (LBold       and (Not Bold))       or
                     (LUnderScore and (Not UnderScore)) or
                     (LBlink      and (Not Blink))      or
                     (LReverse    and (Not LReverse))   or
                     (LConcealed  and (Not Concealed))  or (LBack = $FF);
      S := '';
      if Clear then
        begin
          if Bold       then if S <> '' then S := S + ';1' else S := S + '1';
          if UnderScore then if S <> '' then S := S + ';4' else S := S + '4';
          if Blink      then if S <> '' then S := S + ';5' else S := S + '5';
          if Reverse    then if S <> '' then S := S + ';7' else S := S + '7';
          if Concealed  then if S <> '' then S := S + ';8' else S := S + '8';
          if S <> '' then S := '0;' + S else S := '0';
          LFore := $FF;
          LBack := $FF;
        end
      else
        begin
          if Bold       and (Bold       <> LBold)       then
            if S <> '' then S := S + ';1' else S := S + '1';
          if UnderScore and (UnderScore <> LUnderScore) then
            if S <> '' then S := S + ';4' else S := S + '4';
          if Blink      and (Blink      <> LBlink)      then
            if S <> '' then S := S + ';5' else S := S + '5';
          if Reverse    and (Reverse    <> LReverse)    then
            if S <> '' then S := S + ';7' else S := S + '7';
          if Concealed  and (Concealed  <> Concealed)   then
            if S <> '' then S := S + ';8' else S := S + '8';
        end;
      if LFore  <> ForeGround then
        begin
          if S <> '' then S := S + ';';
          S := S + fStr(30 + ForeGround);
        end;
      if LBack  <> BackGround then
        begin
          if S <> '' then S := S + ';';
          S := S + fStr(40 + BackGround);
        end;
      if S <> '' then WriteStd ( ESC + S + 'm');
      LBold       := Bold;
      LUnderScore := Underscore;
      LBlink      := Blink;
      LReverse    := Reverse;
      LConcealed  := Concealed;
      LFore       := ForeGround;
      LBack       := BackGround;
    end;

  procedure SetMode ( M : Byte );
    begin
      WriteStd ( ESC + fStr(M) + 'h' );
    end;

end.