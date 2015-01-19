{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

  const
    MixerLoaded : boolean = False;
    MixerError  : integer = 0;
    MixerPtr    : pointer = nil;
    MixerName   : pointer = nil;

  const { Mixer Function Constants }
    GetVersion        = $00;
    GetBasePort       = $01;
    SetBasePort       = $02;
    ResetMixer        = $03;
    SetMasterVolume   = $04;
    SetVoiceVolume    = $05;
    SetFMVolume       = $06;
    SetCDVolume       = $07;
    SetMICVolume      = $08;
    SetFMChannel      = $09;
    SetStereo         = $0A;
    SetLineVolume     = $0B;
    SetADCChannel     = $0C;
    SetADCFilter      = $0D;
    SetANFIFilter     = $0E;
    SetDNFIFilter     = $0F;
    GetMasterVolume   = $10;
    GetVoiceVolume    = $11;
    GetFMVolume       = $12;
    GetCDVolume       = $13;
    GetMICVolume      = $14;
    GetFMChannel      = $15;
    GetStereo         = $16;
    GetLineVolume     = $17;
    GetADCChannel     = $18;
    GetADCFilter      = $19;
    GetANFIFilter     = $1A;
    GetDNFIFilter     = $1B;

  const
    { Const for SetFMChannel & GetFMChannel }
    NoSteering = 0;
    SteerLeft  = 1;
    SteerRight = 2;
    Mute       = 3;
    { Const for SetStereo & GetStereo }
    Mono       = 0;
    Stereo     = 1;
    { Const for SetADCChannel & GetADCChannel }
    MIC        = 0;
    CD         = 1;
    LINEIN     = 3;
    { Const for SetADCFilter & GetADCFilter }
    ADCLow     = 0;
    ADCHigh    = 1;
    { Const for ANFI & DNFI Filters }
    FilterOff  = 0;
    FilterOn   = 1;


  type
    CharCast = Array [0..$FFFE] of Char;

  procedure SBPMixer; external; {$L SBPMixer.obj}

{----------------------------------------------------------------------------}
{ Actual Driver Calls }
  procedure WriteMixer ( Func : word; Data : word ); Assembler;
    asm
      MOV  MixerError,  $45
      CMP  MixerLoaded, True
      JNE  @@1
      MOV  BX, Func
      MOV  CX, Data
      CALL MixerPtr
      MOV  MixerError, AX
    @@1:
    end;

  function ReadMixer ( Func : word ) : word; Assembler;
    asm
      MOV  AX, 0
      MOV  MixerError,  $45
      CMP  MixerLoaded, True
      JNE  @@1
      MOV  BX, Func
      CALL MixerPtr
      MOV  MixerError, AX
      MOV  AX, CX
    @@1:
    end;

  procedure MixerInit;
    begin
      MixerPtr := @SBPMixer;
      MixerLoaded := BlasterType >= 2;
      if MixerLoaded then WriteMixer ( SetBasePort, BlasterPort );
    end;
