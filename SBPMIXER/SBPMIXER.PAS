{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program SBPMixer_Data;

  procedure SBPMixerDriver; assembler;
    asm
      JMP @@SetOption
      DB 'JES', 0
    @@Version:
      DW $010A
      DB 'Sound Blaster Pro Mixer Chip Interface',0
      DB 'By J.E. Shidel',0
      DB '06/30/93',0
    @@BasePort:
      DW $0220

    @@SetReg: { CH := Register & CL := Value }
      PUSH AX
      PUSH DX
      MOV  DX,CS:[OFFSET @@BasePort]
      ADD  DX, $04                     { Add Offset to Mixer Chip Register}
      MOV  AL, CH
      OUT  DX, AL
      INC  DX
      MOV  AL, CL
      OUT  DX, AL
      POP  DX
      POP  AX
      RET

    @@GetReg: { CH := Register; CL = Value }
      PUSH AX
      PUSH DX
      MOV  DX,CS:[OFFSET @@BasePort]
      ADD  DX, $04                     { Add Offset to Mixer Chip Register}
      MOV  AL, CH
      OUT  DX, AL
      INC  DX
      IN   AL, DX
      MOV  CL, AL
      POP  DX
      POP  AX
      RET

    @@SetOption:
      PUSHF
      PUSH BX
      PUSH DX
      { Test for Functions >= $10 }
      CMP  BX, $10
      JNB  @@GetOption
      { Setting Functions < $10 }
      CMP  BX, $00      { Get Version }
      JE   @@GetVersion
      CMP  BX, $01
      JE   @@GetBasePort
      CMP  BX, $02      { Set BasePort }
      JE   @@SetBasePort
      CMP  BX, $03
      JE   @@ResetMixer
      CMP  BX, $08
      JNA  @@SetVolume
      CMP  BX, $09
      JE   @@SetFMChannel
      CMP  BX, $0A
      JE   @@SetStereoMode
      CMP  BX, $0B
      JE   @@SetLineVolume
      CMP  BX, $0C
      JE   @@SetADCSource
      CMP  BX, $0D
      JE   @@SetADCFilter
      CMP  BX, $0E
      JE   @@SetANFIFilter
      CMP  BX, $0F
      JE   @@SetDNFIFilter
      JMP  @@GetOption

    @@GetVersion:   { function 0 }
      MOV  CX,CS:[OFFSET @@Version]
      JMP  @@Done

    @@GetBasePort: { function 1 }
      MOV  CX,CS:[OFFSET @@BasePort]
      JMP  @@Done

    @@SetBasePort: { function 2 }
      MOV  CS:[OFFSET @@BasePort], CX
      JMP  @@Done

    @@ResetMixer: { function 3 }
      MOV  CX, $0000
      CALL @@SetReg
      JMP  @@Done

    @@SetVolume: { function 4 - 8 }
      AND  CL, $0F
      SHL  CH, 1
      SHL  CH, 1
      SHL  CH, 1
      SHL  CH, 1
      OR   CL, CH
      CMP  BX, $05 { VOC volume goes to first set for stereo }
      JE   @@SetVolume2
      CMP  BX, $07 { MIC volume goes to first set for mono }
      JA   @@SetVolume2
      OR   BX, $10 { add $10 which will become $20 for those that
                     need second set for stereo VOLUME CONTROL }
    @@SetVolume2:
      SUB  BX, 3
      SHL  BX, 1
      MOV  CH, BL
      CALL @@SetReg
      JMP  @@Done

    @@SetFMChannel: { Function 9; bits 4 - 7; reg 6 }
      PUSH CX
      MOV  CH, $26
      CALL @@GetReg  { get stereo fm volume }
      MOV  BL, CL
      MOV  CH, $06
      CALL @@GetReg { get mono fm volume; tries to prevent pop sound }
      MOV  BH, CL
      POP  CX
      MOV  CH, $06
      AND  CL, $03
      SHL  CL, 1
      INC  CL
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      AND  BH, $0F
      OR   CL, BH
      CALL @@SetReg  { set channel & fm mono volume }
      MOV  CH, $26
      MOV  CL, BL
      CALL @@SetReg { restore origanal fm volume }
      JMP  @@Done

    @@SetStereoMode: { function A; bits 0 - 1; reg E}
      MOV  CH, $0E
      PUSH CX
      CALL @@GetReg
      MOV  BL, CL
      POP  CX
      AND  BL, $FC
      AND  CL, $01
      SHL  CL, 1
      OR   CL, BL
      CALL @@SetReg
      JMP  @@Done

    @@SetLineVolume: { function B; reg 2E }
      MOV  BX, $1A
      JMP  @@SetVolume

    @@SetADCSource:  { function C; bits 0 - 2; reg C }
      MOV  CH, $0C
      PUSH CX
      CALL @@GetReg
      MOV  BL, CL
      POP  CX
      AND  BL, $F8
      AND  CL, $03
      SHL  CL, 1
      OR   CL, BL
      CALL @@SetReg
      JMP  @@Done

    @@SetADCFilter: { function D; Bit 3; reg C }
      MOV  CH, $0C
      PUSH CX
      CALL @@GetReg
      MOV  BL, CL
      POP  CX
      AND  BL, $F7
      AND  CL, $01
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      OR   CL, BL
      CALL @@SetReg
      JMP  @@Done

    @@SetANFIFilter: { function E; Bit 5; Reg C }
      MOV  CH, $0C
      PUSH CX
      CALL @@GetReg
      MOV  BL, CL
      POP  CX
      AND  BL, $DF
      AND  CL, $01
      XOR  CL, $01
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      OR   CL, BL
      CALL @@SetReg
      JMP  @@Done

    @@SetDNFIFilter: { function F; Bit 5; Reg E }
      MOV  CH, $0E
      PUSH CX
      CALL @@GetReg
      MOV  BL, CL
      POP  CX
      AND  BL, $DF
      AND  CL, $01
      XOR  CL, $01
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      SHL  CL, 1
      OR   CL, BL
      CALL @@SetReg
      JMP  @@Done

    @@GetOption:
      CMP  BX, $15
      JB   @@GetVolume
{     CMP  BX, $15 }
      JE   @@GetFMChannel
      CMP  BX, $16
      JE   @@GetStereo
      CMP  BX, $17
      JE   @@GetLineVolume
      CMP  BX, $18
      JE   @@GetADCSource
      CMP  BX, $19
      JE   @@GetADCFilter
      CMP  BX, $1B
      JNA  @@GetANFIDNFIFilter
      MOV  CX, 0
      MOV  AX, $45
      JMP  @@Done2

    @@GetVolume: { function $10 - $14 }
      SUB  BX, $0F
      CMP  BX, $02 { VOC volume goes to first set for stereo }
      JE   @@GetVolume2
      CMP  BX, $04 { MIC volume goes to first set for mono }
      JA   @@GetVolume2
      OR   BX, $10
    @@GetVolume2:
      SHL  BX, 1
      MOV  CH, BL
      CALL @@GetReg
      MOV  CH, CL
      AND  CL, $0F
      SHR  CH, 1
      SHR  CH, 1
      SHR  CH, 1
      SHR  CH, 1
      JMP  @@Done

    @@GetFMChannel:  { function $15 }
      MOV  CH, $26
      CALL @@GetReg
      MOV  BX, CX
      MOV  CH, $06
      CALL @@GetReg
      MOV  CH, $00
      AND  CL, $F0
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      PUSH CX
      MOV  CX, BX
      CALL @@SetReg
      POP  CX
      JMP  @@Done

    @@GetStereo: { function $16 }
      MOV  CH, $0E
      CALL @@GetReg
      MOV  CH, $00
      SHR  CL, 1
      AND  CL, $01
      JMP  @@Done

    @@GetLineVolume: { Function $17 }
      MOV  BX, $26
      JMP  @@GetVolume

    @@GetADCSource: { function $18 }
      MOV  CH, $0C
      CALL @@GetReg
      MOV  CH, $00
      SHR  CL, 1
      AND  CL, $03
      JMP  @@Done

    @@GetADCFilter: { function $19 }
      MOV  CH, $0C
      CALL @@GetReg
      MOV  CH, $00
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      AND  CL, $01
      JMP  @@Done

    @@GetANFIDNFIFilter: { function $1A & $1B }
      MOV  CH, BL
      SUB  CH, $19
      SHL  CH, 1
      ADD  CH, $0A
      CALL @@GetReg
      MOV  CH, $00
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      SHR  CL, 1
      AND  CL, $01
      XOR  CL, $01
      JMP @@Done

    @@Done:
      MOV  AX, 0
    @@Done2:
      POP  DX
      POP  BX
      POPF
      RETF
    end;
{---------------------------------------------------------------------------}
  var
    SBPMixer : Pointer;

  function MIXGetVersion : word; assembler;
    asm
      MOV  BX, $00
      CALL SBPMixer
      MOV  AX, CX
    end;

  function MIXGetBasePort : word; assembler;
    asm
      MOV  BX, $01
      CALL SBPMixer
      MOV  AX, CX
    end;

  procedure MIXSetBasePort ( Port : word ); assembler;
    asm
      MOV  BX, $02
      MOV  CX, Port
      CALL SBPMixer
    end;

  procedure MIXReset; assembler;
    asm
      MOV  BX, $03
      CALL SBPMixer
    end;

  procedure MIXSetMasterVolume ( Left, Right : byte ); assembler;
    asm
      MOV BX, $04
      MOV CH, Left
      MOV CL, Right
      CALL SBPMixer
    end;

  procedure MIXSetVoiceVolume ( Left, Right : byte ); assembler;
    asm
      MOV BX, $05
      MOV CH, Left
      MOV CL, Right
      CALL SBPMixer
    end;

  procedure MIXSetFMVolume ( Left, Right : byte ); assembler;
    asm
      MOV BX, $06
      MOV CH, Left
      MOV CL, Right
      CALL SBPMixer
    end;

  procedure MIXSetCDVolume ( Left, Right : byte ); assembler;
    asm
      MOV BX, $07
      MOV CH, Left
      MOV CL, Right
      CALL SBPMixer
    end;

  procedure MIXSetMICVolume ( Volume : byte ); assembler;
    asm
      MOV BX, $08
      MOV CH, Volume
      MOV CL, Volume
      CALL SBPMixer
    end;

  procedure MIXSetFMChannel ( Channel : byte ); assembler;
    { 0 : No Steering;
      1 : ST to Left;
      2 : ST to Right;
      3 : MUTE }
    asm
      MOV BX, $09
      MOV CH, 0
      MOV CL, Channel
      CALL SBPMixer
    end;

  procedure MIXSetStereo ( State : boolean ); assembler;
    { True  : Stereo Mode;
      False : MonoMode;    }
    asm
      MOV BX, $0A
      MOV CH, 0
      MOV CL, State
      CALL SBPMixer
    end;

  procedure MIXSetLineVolume ( Left, Right : byte ); assembler;
    asm
      MOV BX, $0B
      MOV CH, Left
      MOV CL, Right
      CALL SBPMixer
    end;

  procedure MIXSetADCSource ( Source : byte ); assembler;
    { 0 : MIC
      1 : CD Rom
      2 : Reserved
      3 : Line }
    asm
      MOV BX, $0C
      MOV CH, 0
      MOV CL, Source
      CALL SBPMixer
    end;

  procedure MIXSetADCFilter ( State : boolean ); assembler;
    { True  : High;
      False : Low;    }
    asm
      MOV BX, $0D
      MOV CH, 0
      MOV CL, State
      CALL SBPMixer
    end;

  procedure MIXSetANFIFilter ( State : boolean ); assembler;
    { True  : On;
      False : Off;    }
    asm
      MOV BX, $0E
      MOV CH, 0
      MOV CL, State
      CALL SBPMixer
    end;

  procedure MIXSetDNFIFilter ( State : boolean ); assembler;
    { True  : On;
      False : Off;    }
    asm
      MOV BX, $0F
      MOV CH, 0
      MOV CL, State
      CALL SBPMixer
    end;

  procedure MIXGetMasterVolume ( var Left, Right : byte ); assembler;
    asm
      MOV  BX, $10
      CALL SBPMixer
      PUSH ES
      LES  DI, Left
      MOV  ES:[DI], CH
      LES  DI, Right
      MOV  ES:[DI], CL
      POP  ES
    end;

  procedure MIXGetVoiceVolume ( var Left, Right : byte ); assembler;
    asm
      MOV  BX, $11
      CALL SBPMixer
      PUSH ES
      LES  DI, Left
      MOV  ES:[DI], CH
      LES  DI, Right
      MOV  ES:[DI], CL
      POP  ES
    end;

  procedure MIXGetFMVolume ( var Left, Right : byte ); assembler;
    asm
      MOV  BX, $12
      CALL SBPMixer
      PUSH ES
      LES  DI, Left
      MOV  ES:[DI], CH
      LES  DI, Right
      MOV  ES:[DI], CL
      POP  ES
    end;

  procedure MIXGetCDVolume ( var Left, Right : byte ); assembler;
    asm
      MOV  BX, $13
      CALL SBPMixer
      PUSH ES
      LES  DI, Left
      MOV  ES:[DI], CH
      LES  DI, Right
      MOV  ES:[DI], CL
      POP  ES
    end;

  function MIXGetMicVolume : byte; assembler;
    asm
      MOV  BX, $14
      CALL SBPMixer
      MOV  AL, CL
    end;

  function MIXGetFMChannel : byte; assembler;
    asm
      MOV  BX, $15
      CALL SBPMixer
      MOV  AL, CL
    end;

  function MIXGetStereo : boolean; assembler;
    asm
      MOV  BX, $16
      CALL SBPMixer
      MOV  AL, CL
    end;

  procedure MIXGetLineVolume ( var Left, Right : byte ); assembler;
    asm
      MOV  BX, $17
      CALL SBPMixer
      PUSH ES
      LES  DI, Left
      MOV  ES:[DI], CH
      LES  DI, Right
      MOV  ES:[DI], CL
      POP  ES
    end;

  function MIXGetADCSource : byte; assembler;
    asm
      MOV  BX, $18
      CALL SBPMixer
      MOV  AL, CL
    end;

  function MIXGetADCFilter : boolean; assembler;
    asm
      MOV  BX, $19
      CALL SBPMixer
      MOV  AL, CL
    end;

  function MIXGetANFIFilter : boolean; assembler;
    asm
      MOV  BX, $1A
      CALL SBPMixer
      MOV  AL, CL
    end;

  function MIXGetDNFIFilter : boolean; assembler;
    asm
      MOV  BX, $1B
      CALL SBPMixer
      MOV  AL, CL
    end;

  function InMIX ( Reg : Byte ) : byte; Assembler;
    asm
      MOV DX, $220
      ADD DX, $04
      MOV AL, Reg
      OUT DX, AL
      INC DX
      IN  AL, DX
    end;

  var
    L, R : Byte;
    
begin
  SBPMixer := @SBPMixerDriver;
  WriteLn;
  WriteLn ( '"SBPro Mixer Chip" driver version #',
             Hi(MIXGetVersion), '.', Lo(MIXGetVersion));
{  WriteLn ( 'Base port set at ', HEXWord( MIXGetBasePort ), 'h' );}
  WriteLn;
  MIXGetMasterVolume ( L, R );
  WriteLn ( 'Master Volume: L', L, ' / R', R );
  MIXGetVoiceVolume ( L, R );
  WriteLn ( 'Voice Volume:  L', L, ' / R', R );
  MIXGetFMVolume ( L, R );
  WriteLn ( 'FM Volume:     L', L, ' / R', R );
  MIXGetCDVolume ( L, R );
  WriteLn ( 'CD Volume:     ', (L + R) div 2 );
  WriteLn ( 'MIC Volume:    ', MIXGetMICVolume );
  MIXGetLineVolume ( L, R );
  WriteLn ( 'Line Volume:   L', L, ' / R', R );
  Write   ( 'FM Channel:    ' );
  Case MIXGetFMChannel of
    0 : WriteLn ( 'No steering');
    1 : WriteLn ( 'Steer to left' );
    2 : WriteLn ( 'Steer to right' );
    3 : WriteLn ( 'Mute' );
  else
    WriteLn ( 'Error' );
  end;
  Write   ( 'Stereo/Mono:   ');
  Case MIXGetStereo of
    True  : WriteLn ('Stereo');
    False : WriteLn ('Mono');
  else
    WriteLn ( 'Error' );
  end;
  Write  ('ADC Channel:   ');
  Case MIXGetADCSource of
    0 : WriteLn ('MIC');
    1 : WriteLn ('CD');
    2 : WriteLn ('Reserved/other');
    3 : WriteLn ('Line');
  else
    WriteLn ( 'Error' );
  end;
  Write  ('ADC Filter:    ');
  Case MIXGetADCFilter of
    True  : WriteLn ( 'High');
    False : WriteLn ( 'Low');
  else
    WriteLn ( 'Error' );
  end;
  Write  ('ANFI Filter:   ');
  Case MIXGetANFIFilter of
    True  : WriteLn ('On');
    False : WriteLn ('Off');
  else
    WriteLn ( 'Error' );
  end;
  Write  ('DNFI Filter:   ');
  Case MIXGetDNFIFilter of
    True  : WriteLn ('On');
    False : WriteLn ('Off');
  else
    WriteLn ( 'Error' );
  end;
end.
