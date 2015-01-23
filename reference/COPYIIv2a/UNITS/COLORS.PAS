{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Colors;

{$G-}       (* 8086/8087 compatible *)
{$A+,B-}    (* Byte alignment, short-circut boolean *)
{$E+,N+}    (* Emulation, coprocessor *)
{$F+,O+}    (* Farcalls, and overlays *)
{$R-,Q-,S-} (* No range, overflow or stack checking *)
{$I-}       (* No I/O checking *)
{$D-,L-,Y-} (* No Debug, label or symbol information *)
{$P-,V+}    (* OpenString parameters, with strict type-checking *)
{$T-}       (* No type-checked pointers *)
{$X+}       (* Enable extended syntax *)

interface

  uses StrSize;

  const
    UseAnsi : boolean = True;
    clNormal = #0;
    clTitle  = #1;
    clFile = #2;
    clPath = #3;
    clOpt = #4;
    clOptOr = #5;
    clVerbose = #6;

    clError  = #7;

  function Color( AColor : String ) : String;
  function ColorOff : String;

implementation

  const
    aNormal    = '0';
    aBold      = '1';
    aUnderLine = '4';
    aBlink     = '5';
    aReverse   = '7';
    fBlack     = '30';
    fRed       = '31';
    fGreen     = '32';
    fYellow    = '33';
    fBlue      = '34';
    fMagenta   = '35';
    fCyan      = '36';
    fWhite     = '37';
    bBlack     = '40';
    bRed       = '41';
    bGreen     = '42';
    bYellow    = '43';
    bBlue      = '44';
    bMagenta   = '45';
    bCyan      = '46';
    bWhite     = '47';

  const
    AnsiColor : array[clNormal..clError] of Str20 =
      (
        { clNormal }    aNormal + ';' + bBlack + ';' + fWhite,
        { clTitle }     aBold + ';' + fCyan,
        { clFile }      aBold + ';' + fYellow,
        { clPath }      aBold + ';' + fYellow,
        { clOpt }       aBold + ';' + fGreen,
        { clOptOr }     aBold + ';' + fGreen,
        { clVerbose }   aBold + ';' + fMagenta,

        { clError }     aBold + ';' + fRed
      );

  function Color( AColor : String ) : String;
    var
      C : String;
      I : Byte;
    begin
      if UseAnsi then
        begin
          C := AnsiColor[clNormal] + ';';
          for I := 1 to Length(AColor) do
            C := C + AnsiColor[AColor[I]] + ';';
          Dec(Byte(C[0]));
          Color := #27 + '[' + C + 'm';
        end
      else
        Color := '';
    end;


  function ColorOff : String;
    begin
      ColorOff := Color('');
    end;


end.
