{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit BIOS;

interface

  const
  { Change-Line Support Constants }
    clNotPresent   = 0; { No Drive Present }
    clNotSupported = 1; { Floppy without Change-Line Support }
    clSupported    = 2; { Floppy with Change-Line Support }
    clFixed        = 3; { Fixed Disk }

  type
    TFloppyDiscriptor = record
      Cylinder, Head, Sector, Size : byte;
    end;
    TFloppyFormatBuf = array[1..128] of TFloppyDiscriptor;

  const
    BIOSError : integer = 0;

  function GetBiosDriveID(Drive:Byte) : byte;
  function Diskettes : byte;                                     { ROM-BIOS  }
  function ResetDrive(Drive : Byte) : boolean;
  function ReadSectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean;
  function WriteSectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean;
  function VerifySectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean;
  function FormatTrack(Drive : Byte; Head, Track, Interleave : word; var Buf) : boolean;
  procedure FillFloppyFormatBuf(Head, Track, Size : word; var Buf : TFloppyFormatBuf);
  procedure GetDriveParams(Drive : Byte; var Heads, Tracks, Sectors : word);
  function ChangeLineSupport(Drive : Byte) : byte;
  procedure SetFloppyFormatDASD(Drive : byte; DiskType : byte);
  function  SetFloppyFormatMedia(Drive : byte; Tracks, Sectors : byte) : Pointer;

implementation

  function GetBiosDriveID(Drive:Byte) : byte; assembler;
    asm
      MOV  AL, Drive
      CMP  AL, 0
      JNE  @ComputeIt
      MOV  AH, 19h
      INT  21h
      INC  AL
    @ComputeIt:
      DEC  AL
      CMP  AL, 1
      JG   @NotFloppy
      JMP  @Done
    @NotFloppy:
      ADD  AL, $7E
    @Done:
      MOV  BIOSError, 0
    end;

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
      MOV  BIOSError, 0
    end;

  function SetBIOSError(Drive : byte) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DL, AL
      MOV  AH, 01h
      INT  13h
      XOR  AH, AH
      MOV  BIOSError, AX
      CMP  AX, 0
      JE   @NoError
      MOV  AL, FALSE
      JMP  @Done
    @NoError:
      MOV  AL, True
    @Done:
    end;

  function ResetDrive(Drive : Byte) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DL, AL
      MOV  AH, 00h
      INT  13h
      MOV  AL, Drive
      PUSH AX
      CALL SetBIOSError
    end;

  function ReadSectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DX, Head
      MOV  DH, DL
      MOV  DL, AL
      MOV  CX, Sector
      MOV  AX, Track
      MOV  CH, AL
      MOV  AX, Count
      MOV  AH, 02h
      LES  BX, Buf
      INT  13h
      JNC  @NoError
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AL, False
      JMP  @Done
    @NoError:
      XOR  AL, True
      MOV  BIOSError, 0
    @Done:
    end;

  function WriteSectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DX, Head
      MOV  DH, DL
      MOV  DL, AL
      MOV  CX, Sector
      MOV  AX, Track
      MOV  CH, AL
      MOV  AX, Count
      MOV  AH, 03h
      LES  BX, Buf
      INT  13h
      JNC  @NoError
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AL, False
      JMP  @Done
    @NoError:
      XOR  AL, True
      MOV  BIOSError, 0
    @Done:
    end;

  function VerifySectors(Drive : Byte; Head, Track, Sector, Count : word; var Buf) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DX, Head
      MOV  DH, DL
      MOV  DL, AL
      MOV  CX, Sector
      MOV  AX, Track
      MOV  CH, AL
      MOV  AX, Count
      MOV  AH, 04h
      LES  BX, Buf
      INT  13h
      JNC  @NoError
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AL, False
      JMP  @Done
    @NoError:
      XOR  AL, True
      MOV  BIOSError, 0
    @Done:
    end;

  function FormatTrack(Drive : Byte; Head, Track, Interleave : word; var Buf) : boolean; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DX, Head
      MOV  DH, DL
      MOV  DL, AL
      MOV  CX, 0 { Sector }
      MOV  AX, Track
      MOV  CH, AL
      MOV  AX, Interleave
      MOV  AH, 05h
      LES  BX, Buf
      INT  13h
      JNC  @NoError
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AL, False
      JMP  @Done
    @NoError:
      XOR  AL, True
      MOV  BIOSError, 0
    @Done:
    end;

  procedure FillFloppyFormatBuf(Head, Track, Size : word; var Buf : TFloppyFormatBuf);
    var
      I : word;
    begin
      for I := 1 to 128 do
        begin
          Buf[I].Head := Head;
          Buf[I].Cylinder := Track;
          Buf[I].Sector := I;
          case Size of
            128  : Buf[I].Size := 0;
            256  : Buf[I].Size := 1;
            512  : Buf[I].Size := 2;
            1024 : Buf[I].Size := 3;
          else
            Buf[I].Size := 2;
          end;
        end;
    end;

  procedure GetDriveParams(Drive : Byte; var Heads, Tracks, Sectors : word); assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DL, AL
      MOV  AH, 08h
      INT  13h
      XOR  AX, AX
      MOV  AL, DH
      LES  DI, Heads
      MOV  ES:[DI], AX
      MOV  AL, CH
      LES  DI, Tracks
      MOV  ES:[DI], AX
      MOV  AL, CL
      LES  DI, Sectors
      MOV  ES:[DI], AX
      MOV  BIOSError, 0
    end;

  function ChangeLineSupport(Drive : Byte) : byte; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBIOSDriveID
      MOV  DL, AL
      MOV  AH, 15h
      INT  13h
      JNC  @NoError
    @Error:
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AL, 0
      JMP  @Done
    @NoError:
      CMP  AH, 3
      JG   @Error
      MOV  BIOSError, 0
      MOV  AL, AH
    @Done:
    end;

  function ChangeLine(Drive : Byte) : byte; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBiosDriveID
      MOV  DL, AL
      MOV  AH, 16h
      INT  13h
      MOV  AL, False
      JC   @Done
    @NoError:
      CMP  AH, 6
      JNE  @Done
      CMP  DL, Drive
      JNE  @Done
      MOV  AL, True
    @Done:
      MOV  BIOSError, 0
    end;

  procedure SetFloppyFormatDASD(Drive : byte; DiskType : byte); assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBiosDriveID
      MOV  DL, AL
      MOV  AH, 17h
      MOV  AL, DiskType
      INT  13h
      JC   @Error
      MOV  AH, 0
    @Error:
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
    end;

  function SetFloppyFormatMedia(Drive : byte; Tracks, Sectors : byte) : pointer; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL GetBiosDriveID
      MOV  DL, AL
      MOV  AH, 17h
      MOV  CH, Tracks
      MOV  CL, Sectors
      INT  13h
      JC   @Error
      MOV  AH, 0
      JMP  @Done
    @Error:
      XOR  DI, DI
      MOV  ES, DI
    @Done:
      MOV  AL, AH
      XOR  AH, AH
      MOV  BIOSError, AX
      MOV  AX, DI
      MOV  DX, ES
    end;

end.