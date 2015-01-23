{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$I TURBO.DEF}
{$DEFINE Dos400}
unit DosVer; { version 1.00 }

{$IFDEF Dos400}
  {$DEFINE Dos330}
  {$DEFINE Dos310}
  {$DEFINE Dos320}
  {$DEFINE Dos300}
  {$DEFINE Dos200}
{$ELSE} {$IFDEF Dos330}
  {$DEFINE Dos320}
  {$DEFINE Dos310}
  {$DEFINE Dos300}
  {$DEFINE Dos200}
{$ELSE} {$IFDEF Dos320}
  {$DEFINE Dos310}
  {$DEFINE Dos300}
  {$DEFINE Dos200}
{$ELSE} {$IFDEF Dos310}
  {$DEFINE Dos300}
  {$DEFINE Dos200}
{$ELSE} {$IFDEF Dos300}
  {$DEFINE Dos200}
{$ELSE}
  {$DEFINE DosXXX}
{$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}

interface

  uses Errors;

  const
  { Dos version required for unit functions }
    Dos200 = $0002;
    Dos300 = $0003;
    Dos310 = $0A03;
    Dos320 = $1403;
    Dos330 = $1E03;
    Dos400 = $0004;
    DosXXX = $FFFF;
    ReqDosVersion =
      {$IFDEF Dos400} Dos400; {$ELSE}
      {$IFDEF Dos330} Dos330; {$ELSE}
      {$IFDEF Dos320} Dos320; {$ELSE}
      {$IFDEF Dos310} Dos310; {$ELSE}
      {$IFDEF Dos300} Dos300; {$ELSE}
      {$IFDEF Dos200} Dos200; {$ELSE}
      DosXXX;
      {$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}

  { Disk drive constants }
    drDefault = 0;
    drCurrent = drDefault;
    drA = 1;  drB = 2;  drC = 3;  drD = 4;  drE = 5;  drF = 6;  drG = 7;

  { File attributes constants }
    faReadOnly   = $01;
    faHidden     = $02;
    faSystem     = $04;
    faVolumeID   = $08;
    faDirectory  = $10;
    faArchive    = $20;
    faAnyFile    = $3F;

  type
    {Typed and untyped files}
    TFileRec = record
      Handle: Word;
      Mode: Word;
      RecSize: Word;
      Private: array[1..26] of Byte;
      UserData: array[1..16] of Byte;
      Name: array[0..79] of Char;
    end;


  {Textfile record}
    PTextBuf = ^TTextBuf;
    TTextBuf = array[0..127] of Char;
    TTextRec = record
      Handle: Word;
      Mode: Word;
      BufSize: Word;
      Private: Word;
      BufPos: Word;
      BufEnd: Word;
      BufPtr: PTextBuf;
      OpenFunc: Pointer;
      InOutFunc: Pointer;
      FlushFunc: Pointer;
      CloseFunc: Pointer;
      UserData: array[1..16] of Byte;
      Name: array[0..79] of Char;
      Buffer: TTextBuf;
    end;

  var
    DosError : integer;

  function  DosVersion : word;
  function  DosVersionStr ( AVersion : word ) : string;

  { Character I/O }
  function StdInReady : boolean;
  function StdInChr : char;
  procedure StdOutChr( AChr : char );
  function StdInOutChr : char;
  procedure StdOutStr( const Adr );
  function StdAuxInChar : char;
  procedure StdAuxOutChr( AChr : char );
  procedure StdPrnOutChr( AChr : char );

  { Handle oriented I/O }
  procedure GetFAttr(var F; var Attr: Word);
  procedure SetFAttr(var F; Attr: Word);

  { Date/Time }
  procedure GetDate(var Year, Month, Day{$IFDEF DOS300}, DayOfWeek{$ENDIF}: Word);
  function SetDate(Year, Month, Day: Word) : boolean;
  procedure GetTime(var Hour, Minute, Second, Sec100: Word);
  function SetTime(Hour, Minute, Second, Sec100: Word) : boolean;

  { Disk functions }
  { If a files size has changed it should be closed before flush. }
  procedure FlushAllFileBuffers;
  function GetCurDisk : byte;
  procedure SetCurDisk ( ADrive: byte );
{$IFDEF Dos400}
  function BootDrive : byte;
{$ENDIF}
{$IFDEF Dos300}
  function LastDrive : byte;
{$ENDIF}
  function Diskettes : byte; { BiosFn }
{$IFDEF Dos300}
  function IsValidDrive ( ADrive : byte ) : boolean;
  function IsRemovable ( ADrive : byte ) : boolean;
{$ENDIF}
{$IFDEF Dos310}
  function IsRemote ( ADrive : byte ) : boolean;
{$ENDIF}
  function IsCDROM ( ADrive : byte ) : boolean;
{$IFDEF Dos320}
  function GetLogical ( ADrive : byte ) : byte;
  function SetLogical ( ADrive : byte ) : byte;
{$ENDIF}
{$IFDEF Dos400}
  function GetDiskSerial(ADrive: byte) : longInt;
  procedure SetDiskSerial(ADrive: byte; ASerial : longInt);
{$ENDIF}
  function DiskFatID( ADrive: byte ) : byte;
  function DiskClusters( ADrive: byte ) : word;
  function DiskSectors( ADrive: byte ) : byte;
  function DiskSectorSize( ADrive: byte ) : word;
  function DiskSize( ADrive: byte ) : longint;
  function DiskFree( ADrive: byte ) : longint;
  procedure SetVerify(Verify: Boolean);

  { Dos Ctrl-Break checking level }
  function GetBreak : boolean;
  procedure SetBreak ( Break : boolean );

  { Interrupts }
  procedure GetIntVec(IntNo: Byte; var Vector: Pointer);
  procedure SetIntVec(IntNo: Byte; Vector: Pointer);

implementation

  function DosVersion : word; assembler;
    asm
      MOV  AH, 30h
      INT  21h
    end;

  function DosVersionStr ( AVersion : word ) : String;
    var
      Major, Minor : String[2];
      OEM : String;
    begin
      OEM := 'DOS';
      case Hi(AVersion) of
        2..99 : begin
          Str ( Lo(AVersion), Major );
          Str ( Hi(AVersion), Minor );
          while Length(Minor) < 2 do Minor := '0' + Minor;
        end;
      else
        Major := 'X';
        Minor := 'xx';
      end;
      DosVersionStr := OEM + ' ' + Major + '.' + Minor;
    end;

  { Character I/O }
  function StdInReady : boolean; assembler;
  { Returns True if character is ready }
    asm
      MOV  AH, 0Bh
      INT  21h
      MOV  CL, False
      CMP  AL, 0
      JE   @1
      MOV  CL, True
    @1:
      MOV  AL, CL
    end;

  function StdInChr : char; assembler;
  { Reads (waits for) character }
    asm
      MOV  AH, 08h
      INT  21h
    end;

  procedure StdOutChr( AChr : char ); assembler;
    asm
      MOV  AH, 02h
      MOV  DL, AChr
      INT  21h
    end;

  function StdInOutChr : char; assembler;
  { Reads (waits for) character }
    asm
      MOV  AH, 01h
      INT  21h
    end;

  procedure StdOutStr( const Adr ); assembler;
  { String must end with '$' }
    asm
      PUSH DS
      MOV  AH, 09h
      LDS  DX, Adr
      INT  21h
      POP  DS
    end;

  function StdAuxInChar : char; assembler;
  { Reads (waits for) character }
    asm
      MOV  AH, 03h
      INT  21h
    end;

  procedure StdAuxOutChr( AChr : char ); assembler;
    asm
      MOV  AH, 04h
      MOV  DL, AChr
      INT  21h
    end;

  procedure StdPrnOutChr( AChr : char ); assembler;
    asm
      MOV  AH, 05h
      MOV  DL, AChr
      INT  21h
    end;

  { Handle oriented I/O }
  procedure GetFAttr(var F; var Attr: Word); assembler;
    asm
      PUSH DS
      MOV  AX, 4300h
      LDS  DX, F
      ADD  DX, OFFSET TFileRec.Name
      INT  21h
      POP  DS
      JC   @1
      XOR  AX, AX
    @1:
      MOV  DosError, AX
      LES  DI, Attr
      MOV  ES:[DI], CX
    end;

  procedure SetFAttr(var F; Attr: Word); assembler;
    asm
      PUSH DS
      MOV  AX, 4301h
      MOV  CX, Attr
      LDS  DX, F
      ADD  DX, OFFSET TFileRec.Name
      INT  21h
      POP  DS
      JC   @1
      XOR  AX, AX
    @1:
      MOV  DosError, AX
    end;

  { Date/Time }
  procedure GetDate(var Year, Month, Day {$IFDEF Dos300}, DayOfWeek {$ENDIF}: Word); assembler;
    asm
      MOV  AH, 2Ah
      INT  21h
      LES  DI, Year
      MOV  ES:[DI], CX
      XOR  AH, AH
      {$IFDEF Dos300}
      LES  DI, DayOfWeek
      STOSW
      {$ENDIF}
      LES  DI, Month
      MOV  AL, DH
      STOSW
      LES  DI, Day
      MOV  AL, DL
      STOSW
    end;

  function SetDate(Year, Month, Day: Word) : boolean; assembler;
    asm
      MOV  CX, Year
      MOV  AX, Month
      MOV  DX, Day
      MOV  DH, AL
      MOV  AH, 2Bh
      INT  21h
      MOV  CL, True
      CMP  AL, 0
      JE   @1
      MOV  CL, False
    @1:
      MOV  AL, CL
    end;

  procedure GetTime(var Hour, Minute, Second, Sec100: Word); assembler;
    asm
      MOV  AH, 2Ch
      INT  21h
      XOR  AH, AH
      MOV  AL, CH
      LES  DI, Hour
      STOSW
      MOV  AL, CL
      LES  DI, Minute
      STOSW
      MOV  AL, DH
      LES  DI, Second
      STOSW
      MOV  AL, DL
      LES  DI, Sec100
      STOSW
    end;

  function SetTime(Hour, Minute, Second, Sec100: Word) : boolean; assembler;
    asm
      MOV  AX, Hour
      MOV  CH, AL
      MOV  AX, Minute
      MOV  CL, AL
      MOV  AX, Second
      MOV  DH, AL
      MOV  AX, Sec100
      MOV  DL, AL
      MOV  AH, 2Dh
      INT  21h
      MOV  CL, True
      CMP  AL, 0
      JE   @1
      MOV  CL, False
    @1:
      MOV  AL, CL
    end;


  { Disk functions }
  procedure FlushAllFileBuffers; assembler;
  { if a files size has changed it should be closed first }
    asm
      MOV  AH, 0Dh
      INT  21h
    end;

  function GetCurDisk : byte; assembler;
    asm
      MOV  AH, 19h
      INT  21h
      INC  AL
    end;

  procedure SetCurDisk ( ADrive : byte ); assembler;
    asm
      MOV  DL, ADrive
      CMP  DL, drDefault
      JNE  @1
      MOV  AH, 0Eh
      DEC  DL
      INT  21h
    @1:
    end;

{$IFDEF Dos400}
  function BootDrive : byte; assembler;
    asm
      MOV  AX, 3305h
      INT  21h
      MOV  AL, DL
    end;
{$ENDIF}
{$IFDEF Dos300}
  function LastDrive : byte; assembler;
    asm
      MOV  AH, 19h
      INT  21h
      MOV  DL, AL
      MOV  AH, 0Eh
      INT  21h
    end;
{$ENDIF}
  function Diskettes : byte; assembler;
    asm
      INT  11h
      TEST AL, 01h
      JZ   @@NoDrives
      XOR  AH, AH
      AND  AL, 0C0h
      MOV  CL, 06h
      SHR  AX, CL
      INC  AX
      JMP  @@Done
    @@NoDrives:
      XOR  AX, AX
    @@Done:
    end;


{$IFDEF Dos300}
  function IsValidDrive ( ADrive : byte ) : boolean; assembler;
    asm
      MOV  DosError, erInvalid_Drive_Number
      MOV  AX, 4408h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      CMP  AX, 01h
      JG   @@NotValid
      MOV  DosError, erNone
      MOV  CL, True
    @@NotValid:
      MOV  AL, CL
    end;

  function IsRemovable ( ADrive : byte ) : boolean; assembler;
    asm
      MOV  AX, 4408h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      CMP  AX, 0
      JNE  @@SetRemovable
      MOV  CL, True
    @@SetRemovable:
      CMP  AX, 1
      JG   @@Error
      XOR  AX, AX
    @@Error:
      MOV  DosError, AX
      MOV  AL, CL
    end;
{$ENDIF}
{$IFDEF Dos310}
  function IsRemote ( ADrive : byte ) : Boolean; assembler;
    asm
      MOV  AX, 4409h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      TEST DX, 1000h
      JZ   @@SetRemote
      MOV  CL, True
    @@SetRemote:
      MOV  AL, CL
      MOV  DosError, erNone
    end;
{$ENDIF}

  function IsCDROM ( ADrive : byte ) : boolean; assembler;
    asm
      MOV  DosError, erNone
      MOV  AX, 1500h
      XOR  BX, BX
      INT  2Fh
      MOV  DL, False
      CMP  BX, 0
      JE   @@Done { CDROM Multiplex not installed }
      XOR  AH, AH
      MOV  AL, ADrive
      INC  CX
      DEC  BX
      CMP  AX, CX
      JL   @@Done { Less then first CD }
      ADD  CX, BX
      CMP  AX, CX
      JG   @@Done { Greater then Last CD }
      MOV  DL, True
    @@Done:
      MOV  AL, DL
    end;

{$IFDEF Dos320}
  function GetLogical ( ADrive : byte ) : byte; assembler;
    asm
      MOV  AX, 440Eh
      MOV  BL, ADrive
      INT  21h
      JC   @@Error
      CMP  AL, 00h
      JNE  @@ReturnDrive
      MOV  AX, 000Fh { invalid drive number }
    @@Error:
      XOR  CL, CL
      JMP  @@Done
    @@ReturnDrive:
      MOV  CL, AL
      XOR  AX, AX
    @@Done:
      MOV  DosError, AX
      MOV  AL, CL
    end;

  function SetLogical ( ADrive : byte ) : byte; assembler;
    asm
      MOV  AX, 440Fh
      MOV  BL, ADrive
      INT  21h
      JC   @@Error
      CMP  AL, 00h
      JNE  @@ReturnDrive
      MOV  AX, 000Fh { invalid drive number }
    @@Error:
      XOR  CL, CL
      JMP  @@Done
    @@ReturnDrive:
      MOV  CL, AL
      XOR  AX, AX
    @@Done:
      MOV  DosError, AX
      MOV  AL, CL
    end;
{$ENDIF}
  type
    InfoBuffer = record
      InfoLevel  : word; {should be zero}
      Serial     : LongInt;
      VolLabel   : array [0..10] of char;
      FileSystem : array [0..7] of char;
    end;

  function GetInfoBuffer(ADrive: Byte; var Buf : InfoBuffer ): integer; assembler;
    asm
      MOV  AH, 69h
      MOV  AL, 00h
      MOV  BL, ADrive
      PUSH DS
      LDS  DX, Buf
      INT  21h
      POP  DS
      JC   @@Error
      XOR  AX, AX
    @@Error:
    end;

  function SetInfoBuffer(ADrive: Byte; var Buf : InfoBuffer) : integer; assembler;
    asm
      MOV  AH, 69h
      MOV  AL, 01h
      MOV  BL, ADrive
      PUSH DS
      LDS  DX, Buf
      INT  21h
      POP  DS
      JC   @@Error
      XOR  AX, AX
    @@Error:
    end;

  function GetDiskSerial(ADrive: byte) : longInt;
    var
      TBuf : InfoBuffer;
    begin
      DosError := GetInfoBuffer( ADrive, TBuf );
      GetDiskSerial := TBuf.Serial;
    end;

  procedure SetDiskSerial(ADrive: byte; ASerial : LongInt);
    var
      TBuf   : InfoBuffer;
    begin
      GetInfoBuffer( ADrive, TBuf );
      TBuf.Serial := ASerial;
      if DosError = erNone then
        DosError := SetInfoBuffer ( ADrive, TBuf );
    end;

  function DiskFatID( ADrive: byte ) : byte; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      MOV  AL, [BX]
      POP  DS
    end;

  function DiskClusters( ADrive: byte ) : word; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      MOV  AX, DX
      POP  DS
    end;

  function DiskSectors( ADrive: byte ) : byte; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      POP  DS
    end;


  function DiskSectorSize( ADrive: byte ) : word; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      MOV  AX, CX
      POP  DS
    end;

  function DiskSize( ADrive: byte ) : longint; assembler;
    asm
      PUSH DS
      MOV  AH, 36h
      MOV  DL, ADrive
      INT  21h
      CMP  AX, 0FFFFh
      JE   @1
      MOV  BX, DX
      MUL  CX
      MUL  BX
      JMP  @2
    @1:
      MOV  DX, -1
    @2:
      POP  DS
    end;

  function DiskFree( ADrive: byte ) : longint; assembler;
    asm
      PUSH DS
      MOV  AH, 36h
      MOV  DL, ADrive
      INT  21h
      CMP  AX, 0FFFFh
      JE   @1
      MUL  CX
      MUL  BX
      JMP  @2
    @1:
      MOV  DX, -1
    @2:
      POP  DS
    end;

  procedure SetVerify(Verify: Boolean); assembler;
    asm
      MOV  AH, 2Eh
      MOV  AL, 0
      MOV  CL, Verify
      CMP  CL, False
      JE   @1
      MOV  AL, 1
    @1:
      INT  21h
    end;

  function GetBreak : boolean; assembler;
    asm
      MOV  AX, 3300h
      INT  21h
      MOV  AL, True
      CMP  DL, 1
      JE   @1
      MOV  AL, False
    @1:
    end;

  procedure SetBreak ( Break : boolean ); assembler;
    asm
      MOV  AX, 3301h
      MOV  DL, 1
      MOV  CL, Break
      CMP  CL, True
      JE   @1
      MOV  DL, 0
    @1:
      INT  21h
    end;
  { Interrupts }
  procedure SetIntVec(IntNo: Byte; Vector: Pointer); assembler;
    asm
      PUSH DS
      MOV  AH, 25h
      MOV  AL, IntNo
      LDS  DX, Vector
      INT  21h
      POP  DS
    end;

  procedure GetIntVec(IntNo: Byte; var Vector: Pointer); assembler;
    asm
      MOV  AH, 35h
      MOV  AL, IntNo
      INT  21h
      MOV  AX, ES
      LES  DI, Vector
      MOV  ES:[DI], BX
      MOV  ES:[DI + 2], AX
    end;

{Dos FCB Fn 0F,10,11,12,13,14,15,16,17,1A,21,22,23,24,27,28,29,2F }
{Dos Country Fn 38 }
{Dos DIR Fn 39, 3A, 3B }
{Dos File I/O Fn 3C,3D,3E,3F,40,41,42,45,46,47 }
{Dos Memory Fn 48,49,4A }
{Dos Fn 06,07,0A,0C,1B,26,31,32,34,37,44(00,01,02,03,04,05,06,07,0A,0B,0C,0D),
  4B,4C,4D,4E,4F,54,56,57,59,5A,5B,5C,5E,5F,62,65,66,67,68,6C ommitted. }

  procedure InitUnit;
    begin
      DosVersion;
      if (Lo(DosVersion) < Lo(ReqDosVersion)) or
      ((Lo(DosVersion) = Lo(ReqDosVersion)) and
      (Hi(DosVersion) < Hi(ReqDosVersion))) then
        begin
          WriteLn ( 'This program requires ', DosVersionStr(ReqDosVersion), '+.' );
          Halt(erInvalid_Function_Number);
        end;
    end;

begin
  InitUnit;
end.
