{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
{$F+,O-}
unit ExitMsg; { version 2.00 }

interface

  uses QCrt, Errors, Macros;

  const
    exExitMsg    = $01;
    exErrorMsg   = $02;
    exErrorCode  = $04;
    exErrorAdr   = $08;
    exKeepError  = $10;
    exHaltCode   = $20;
    {$IFOPT D+}
    ExitMsgMode  : byte = $FF;
    {$ELSE}
    ExitMsgMode  : byte = $0F;
    {$ENDIF}

    procedure SetExitMsg(Message : String);
    procedure AppExitMsg;

implementation

  const
    ExitMessage  : String = 'initializing $APP_TITLE$';

  procedure SetExitMsg(Message : String);
     begin
       if ExitCode = 0 then
         ExitMessage := Message;
     end;

  procedure AppExitMsg;
    begin
      SetExitMsg('executing $APP_TITLE$');
    end;

  var
    OldExitProc : Pointer;

  function HEXbyte ( B : byte ) : String; assembler;
    asm
      LES DI, @RESULT
      MOV AL, $02
      MOV ES:[DI], AL
      MOV AL, B
      MOV AH, B
      AND AH, $0F
      AND AL, $F0
      MOV CL, $04
      SHR AL, CL
      CMP AL, $9
      JNA @@1
      ADD AL, $07
    @@1:
      ADD AL, $30
      CMP AH, $9
      JNA @@2
      ADD AH, $07
    @@2:
      ADD AH, $30
      MOV ES:[DI + 1], AX
    end;

  function HEXWord ( W : Word ) : String;
    begin
      HEXWord := HEXByte(Hi(W)) + HEXByte(Lo(W));
    end;

  procedure ExitErrMsg;
    begin
      ExitProc := OldExitProc;
      if ((ErrorAddr <> nil) or ((ExitCode <> 0) and (ExitMsgMode and exHaltCode = exHaltCode))) then
        begin
          CheckCursor := True;
          CheckBreak  := True;
          CheckScroll := True;
          CheckChar   := True;
          GotoXY ( 1, Hi(ScreenMax) + 1);
          TextAttr := $07;
          NormalCursor;
          TurnMouseOff;
          WriteLn;
          WriteLn;

          Write ( 'Runtime error');
          if ExitMsgMode and exErrorCode = exErrorCode then
            Write ( ' code #', ExitCode );
          if ExitMsgMode and exErrorMsg = exErrorMsg then
            Write ( '; ', ExpandStr(ErrorStr( ExitCode )) );
          WriteLn('.');

          if (ExitMsgMode and exExitMsg = exExitMsg) and (ExitMessage <> '') then
            WriteLn ( ExpandStr('While ' + ExitMessage + '.') );

          if ExitMsgMode and exErrorAdr = exErrorAdr then
            WriteLn ('At address [', HexWord(Seg(ErrorAddr^)), ':', HexWord(Ofs(ErrorAddr^)), '].' );

          if ExitMsgMode and exKeepError <> exKeepError then
            ErrorAddr := nil
          else
            WriteLn;
        end
    end;

begin
  OldExitProc := ExitProc;
  ExitProc := @ExitErrMsg;
end.