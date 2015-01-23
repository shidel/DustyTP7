{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$I TURBO.DEF}
program CopyII;

uses BIOS, Dos, DosExt, AnsiCrt, StrAsm;

  const
    TitleStr        = ' CopyII Version 2.0 ';
    xNothing        = 0;
    xOutOfMemory    = 8;
    xNoMoreFiles    = 18;
    xBreak          = $1000;
    xMissingParam   = $1001;
    xInvalidSwitch  = $1002;

  procedure Terminate(S : String; Code : integer);
    var
      FAttr, BAttr : byte;
    procedure SetStr(S1, S2 : String; ACode : integer; FA, BA : byte);
      {
      ACode:
         0 = Normal;
         1 = CTRL-C;
         2 = Device Error;
         3 = Keep Procedure;
      }
      begin
        if S  = '' then S := S1 else
        if S2 = '' then S := S1 + ' ' + S else
          S := S2 + ' ' + S;
        Code := ACode;
        FAttr := FA;
        BAttr := BA;
      end;

    begin
      case Code of
        xOutOfMemory    : SetStr('Out of memory', '', 2, White, Red);
        xNoMoreFiles    : SetStr('No more matching files', '', 2, White, Red);
        xBreak          : SetStr('User terminated', '', 1, White, Red);
        xMissingParam   : SetStr('Required parameter missing', '', 1, White, Red);
        xInvalidSwitch  : SetStr('Invaild switch', '', 1, White, Red);
      end;
      TextColor(FAttr);
      TextBackground(BAttr);
      if CheckAnsi then
        GotoXY(1,WhereY)
      else
        WriteLn;
      if S <> '' then Write(ClipStr(' ' + S + '.', Lo(WindMax)));
      NormVideo;
      WriteLn;
      Halt(Code);
    end;

 procedure Help;
   begin
     WriteLn('Copies one or more files to another location.');
     WriteLn;
     WriteLn('CPY [/A | /B] source [/A | /B] [+ source [/A | /B] [+ ...]] [destination');
     WriteLn('  [/A | /B]] [/V] [/Y | /N] [/R | /C] [/D | /S]');
     WriteLn;
     WriteLn('  source       Specifies the file or files to be copied.');
     WriteLn('  /A           Indicates an ASCII text file.');
     WriteLn('  /B           Indicates a binary file.');
     WriteLn('  destination  Specifies the directory and/or filename for the new file(s).');
     WriteLn('  /V           Verifies that new files are written correctly.');
     WriteLn('  /Y           Suppresses prompting to confirm you want to overwrite an');
     WriteLn('               existing destination file.');
     WriteLn('  /N           Causes prompting to confirm you want to overwrite an');
     WriteLn('               existing destination file.');
     WriteLn('  /R           Copies matching subdirectories and files.');
     WriteLn('  /C           Copies matching files in subdirectories but not the.');
     WriteLn('               subdirectory.');
     WriteLn('  /D           Specifies floppy disk duplication mode.');
     WriteLn('  /S           Specifies boot sector duplication mode.');
{
     WriteLn;
     WriteLn('The switch /Y may be preset in the CPYCMD environment variable.');
     WriteLn('To append files, specify a single file for destination, but multiple files');
     WriteLn('for source (using wildcards or file1+file2+file3 format).');
}
     Terminate('',xNothing);
   end;

  procedure Init;
    const
      cmBinary            = $0001;
      cmMove              = $0002;
      cmVerify            = $0004;
      cmRecurse           = $0008;
      cmCollect           = $0010;
      cmDefaultToYes      = $0020;
      cmDefaulttoNo       = $0040;

      cmDiskMode          = $0100;
      cmBootSectMode      = $0200;
      cmDefault           = cmBinary;

    var
      Index  : Byte;
      Params : ^String;
      Str    : String;
      CMode  : Longint;

    procedure ProcessSwitch;
      begin
        if Ucase(Str) = '/B' then
          CMode := CMode or cmBinary
        else
        if Ucase(Str) = '/A' then
          CMode := CMode and (not cmBinary)
        else
        if Ucase(Str) = '/M' then
          CMode := CMode or cmMove
        else
        if Ucase(Str) = '/R' then
          CMode := CMode or cmRecurse and (Not cmCollect)
        else
        if Ucase(Str) = '/C' then
          CMode := CMode or cmCollect and (Not cmRecurse)
        else
        if Ucase(Str) = '/Y' then
          CMode := CMode or cmDefaultToYes and (Not cmDefaultToNo)
        else
        if Ucase(Str) = '/N' then
          CMode := CMode or cmDefaultToNo and (Not cmDefaultToYes)
        else
        if Ucase(Str) = '/D' then
          CMode := CMode or cmDiskMode and (Not cmBootSectMode)
        else
        if Ucase(Str) = '/S' then
          CMode := CMode or cmBootSectMode and (Not cmDiskMode)
        else
        if (Ucase(Str) = '/HELP') or (Ucase(Str) = '/H') or (Ucase(Str) = '/?') then
          Help
        else
          Terminate(Str, xInvalidSwitch);
      end;

    begin
      Params   := Ptr(PrefixSeg, $80);
      CMode    := cmDefault;
      Index    := 1;
      if Trim(Params^) = '' then
        Terminate('',xMissingParam);
      repeat
        Str := '';
        repeat
          AddChr(Str, Params^[Index]);
          Inc(Index);
        until (Index > Length(Params^)) or (Pos(Params^[Index], ' /+') <> 0);
        Str := Trim(Str);
        if Str <> '' then
          begin
            if Str[1] = '/' then
              ProcessSwitch;
          end;
      until (Index > Length(Params^));
      NormVideo;
      if Not RedirectedOutput then
        begin
          Write(ChrStr(#8, Length(TitleStr)));
          Write(ChrStr(#32, Length(TitleStr)));
          Write(ChrStr(#8, Length(TitleStr)));
        end;
    end;

  procedure Run;
    begin
    end;

  procedure Done;
    begin
    end;

begin
  TextColor(Yellow);
  TextBackground(Blue);
  if Not RedirectedOutput then Write(TitleStr);
  Init;
  Run;
  Done;
end.
