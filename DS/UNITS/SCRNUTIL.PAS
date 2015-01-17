{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

unit ScrnUtil;

{$O+,F+}

interface

  Const
    ScrnUtilVersion = 'VGA BOIS Interface Version #1.0';

   type
      RGBRec      = record
                       Red, Green, Blue : byte;
                    end;
      PaletteType = array[0..16] of byte;
      ColorType   = array[0..63] of RGBRec;
      Cursor = object
               procedure SetCursor   ( NewCursor : Word  );
               function  GetCursor : Word;
               procedure HideCursor;
               procedure NormCursor;
               procedure InsCursor;
            end;
      Colors = object ( Cursor )
               procedure SetOverScan ( C : byte );
               function  GetOverScan : byte;
               function  Color       ( T, B : byte ) : word;
               function  InvertColor ( C : word )    : word;
            end;
      Palette = object ( Colors )
               procedure GetRGBValue     ( R, G, B : byte; var RGB : RGBRec );
               procedure SetRGBColor     ( C : word; RGB : RGBRec );
               procedure SetPalette      ( Pal : byte; Val : word );
               function  GetPalette      ( Pal : byte ) : word;
               procedure SetBlink        ( On    : boolean );
               procedure GetAllPalettes  ( var P : PaletteType );
               procedure SetAllPalettes  ( var P : PaletteType );
               procedure SetAllRGBColors ( var C : ColorType );
               procedure SumToGray;
            end;
      ScreenUtilities = object ( Palette )
        procedure Init;
        procedure ShutDown;
      end;

   const
      DefaultPalettes : PaletteType =
         (0, 1, 2, 3, 4, 5, 20, 7, 56, 57, 58, 59, 60, 61, 62, 63, 0);
      DefaultColors   : ColorType = ( (Red:0;  Green:0;  Blue:0 ),
         (Red:0;  Green:0;  Blue:42), (Red:0;  Green:42; Blue:0 ), (Red:0;  Green:42; Blue:42),
         (Red:42; Green:0;  Blue:0 ), (Red:42; Green:0;  Blue:42), (Red:42; Green:42; Blue:0 ),
         (Red:42; Green:42; Blue:42), (Red:0;  Green:0;  Blue:21), (Red:0;  Green:0;  Blue:63),
         (Red:0;  Green:42; Blue:21), (Red:0;  Green:42; Blue:63), (Red:42; Green:0;  Blue:21),
         (Red:42; Green:0;  Blue:63), (Red:42; Green:42; Blue:21), (Red:42; Green:42; Blue:63),
         (Red:0;  Green:21; Blue:0 ), (Red:0;  Green:21; Blue:42), (Red:0;  Green:63; Blue:0 ),
         (Red:0;  Green:63; Blue:42), (Red:42; Green:21; Blue:0 ), (Red:42; Green:21; Blue:42),
         (Red:42; Green:63; Blue:0 ), (Red:42; Green:63; Blue:42), (Red:0;  Green:21; Blue:21),
         (Red:0;  Green:21; Blue:63), (Red:0;  Green:63; Blue:21), (Red:21; Green:63; Blue:63),
         (Red:42; Green:21; Blue:21), (Red:42; Green:21; Blue:63), (Red:42; Green:63; Blue:21),
         (Red:42; Green:63; Blue:63), (Red:21; Green:0;  Blue:0 ), (Red:21; Green:0;  Blue:42),
         (Red:21; Green:42; Blue:0 ), (Red:21; Green:42; Blue:42), (Red:63; Green:0;  Blue:0 ),
         (Red:63; Green:0;  Blue:42), (Red:63; Green:42; Blue:0 ), (Red:63; Green:42; Blue:42),
         (Red:21; Green:0;  Blue:21), (Red:21; Green:0;  Blue:63), (Red:21; Green:42; Blue:21),
         (Red:21; Green:42; Blue:63), (Red:63; Green:0;  Blue:21), (Red:63; Green:0;  Blue:63),
         (Red:63; Green:42; Blue:21), (Red:63; Green:42; Blue:63), (Red:21; Green:21; Blue:0 ),
         (Red:21; Green:21; Blue:42), (Red:21; Green:63; Blue:0 ), (Red:21; Green:63; Blue:42),
         (Red:63; Green:21; Blue:0 ), (Red:63; Green:21; Blue:42), (Red:63; Green:63; Blue:0 ),
         (Red:63; Green:63; Blue:42), (Red:21; Green:21; Blue:21), (Red:21; Green:21; Blue:63),
         (Red:21; Green:63; Blue:21), (Red:21; Green:63; Blue:63), (Red:63; Green:21; Blue:21),
         (Red:63; Green:21; Blue:63), (Red:63; Green:63; Blue:21), (Red:63; Green:63; Blue:63));
implementation

   uses Dos, QCRT;
{-----------------------------------------------------------------------------}
   procedure Cursor.SetCursor(NewCursor : Word);
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

   function Cursor.GetCursor : Word;
      var
         Reg : Registers;
      begin
         with Reg do
            begin
               AH := 3;
               BH := 0;
               Intr($10, Reg);
               GetCursor := CX;
            end;
      end;

   procedure Cursor.HideCursor;
      begin
         SetCursor ($2000);
      end;

   procedure Cursor.NormCursor;
      begin
         SetCursor ($0D0E);
      end;

   procedure Cursor.InsCursor;
      begin
         SetCursor ($0D11);
      end;
{-----------------------------------------------------------------------------}
   function Colors.Color ( T, B : byte ) : word;
      begin
         Color := T + B Shl 4;
      end;

   function Colors.InvertColor ( C : word ) : word;
      var
         T, B : byte;
      begin
         B := C Shr 4;
         T := C - B Shl 4;
         if T > 7 then Dec (T, 8);
         InvertColor := B + T Shl 4;
      end;

   function Colors.GetOverScan : byte;
      var
         Reg : Registers;
      begin
         with Reg do
            begin
               AH := $10;
               AL := $08;
               Intr ($10, Reg);
               GetOverScan := BH;
            end;
      end;

   procedure Colors.SetOverScan ( C : byte );
      var
         Reg : Registers;
      begin
         with Reg do
            begin
               AH := $10;
               AL := $01;
               BH := C;
               Intr ($10, Reg);
            end;
      end;
{-----------------------------------------------------------------------------}
   procedure Palette.GetRGBValue ( R, G, B : byte; var RGB : RGBRec );
      begin
         RGB.Red := R; RGB.Green := G; RGB.Blue := B;
      end;

   procedure Palette.SetRGBColor ( C : word; RGB : RGBRec );
      var
         Regs : Registers;
      begin
         With Regs, RGB do
            begin
               AH := $10;       AL := $10;
               BX := C;
               DH := Red;
               CH := Green;
               CL := Blue;
            end;
         Intr ($10, Regs);
      end;

   procedure Palette.SetPalette ( Pal : byte; Val : word );
      var
         Regs : Registers;
      begin
         With Regs do
            begin
               AH := $10;      AL := $0;
               BH := VAL;
               BL := Pal;
            end;
         Intr ($10, Regs);
      end;

   function Palette.GetPalette ( Pal : byte ) : word;
      var
         Regs : Registers;
      begin
         With Regs do
            begin
               AH := $10;      AL := $7;
               BL := Pal;
            end;
         Intr ($10, Regs);
         GetPalette := Regs.BH;
      end;

   procedure Palette.SetBlink ( On : boolean );
      var
         Regs : registers;
      begin
         with Regs do
            begin
               AH := $10; AL := $03;
               if On then BL := 1  else  BL := 0;
            end;
         intr ($10, regs);
      end;

   procedure Palette.GetAllPalettes ( var P : PaletteType );
      var
         Regs : Registers;
         Pnt  : Pointer;
      begin
         Pnt := @P;
         with Regs do
            begin
               AH := $10;  AL := $09;
               ES := Seg ( Pnt^ );  DX := Ofs ( Pnt^ );
            end;
         Intr ($10, Regs);
      end;
   procedure Palette.SetAllPalettes ( var P : PaletteType );
      var
         Regs : Registers;
         Pnt  : Pointer;
      begin
         Pnt := @P;
         with Regs do
            begin
               AH := $10;  Al := $02;
               ES := Seg ( Pnt^ );  DX := Ofs ( Pnt^ );
            end;
         Intr ($10, Regs);
      end;

   procedure Palette.SetAllRGBColors ( var C : ColorType );
      var
         Regs : Registers;
         P    : Pointer;
      begin
         P := @C;
         with Regs do
            begin
               AH := $10; AL := $12;
               BX := $00; CX := $3F;
               ES := Seg ( P^ ); DX := Ofs ( P^ );
            end;
         Intr ($10, Regs);
      end;

   procedure Palette.SumToGray;
      var
         Regs : Registers;
      begin
         with Regs do
            begin
               AH := $10; AL := $1B;
               BX := $00; CX := $3F;
            end;
         Intr ($10, Regs);
      end;

   procedure ScreenUtilities.Init;
     begin
     end;

   procedure ScreenUtilities.ShutDown;
     begin
     end;

end.