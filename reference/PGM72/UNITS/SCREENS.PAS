{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Screens;

{$O+,F+}

interface

   uses Dos, CRT, ScrnUtil;

  Const
    ScreensVersion = 'Text Screen Driver Version #3.0';

   type
      XYRec       = record     X, Y : byte;      end;
      CO80Array   = array [1..50,1..80] of word;
      CO40Array   = array [1..50,1..40] of word;
      ScreenPtr   = ^ScreenRec;
      ScreenRec   = record
                       Min,  Max, Pos   : XYRec;
                       Cur              : word;
                       Attr, OverScan   : byte;
                       ShiftFill        : boolean;
                       case Mode : word of
                          BW80, BW80 + Font8x8,
                          CO80, CO80 + Font8x8 : ( C80 : CO80array);
                          BW40, BW40 + Font8x8,
                          CO40, CO40 + Font8x8 : ( C40 : CO40array);
                    end;
      WindowRec   = record
                       Min, Max, Pos : XYRec;
                       Attr          : byte;
                       Mode          : word;
                    end;

   var
      CO80Screen  : CO80Array absolute $B800:0000;
      BW80Screen  : CO80Array absolute $B000:0000;
      CO40Screen  : CO40Array absolute $B800:0000;
      BW40Screen  : CO40Array absolute $B000:0000;

{----------------------------------------------------------------------------}
   function  ScreenEnoughMemory : boolean;
   procedure ScreenAllocate    ( var S : ScreenPtr );
   procedure ScreenDeAllocate  ( var S : ScreenPtr );
   procedure ScreenSave        ( var S : ScreenPtr );
   procedure ScreenLoad        ( var S : ScreenPtr );
   procedure ScreenCopyWindow  ( var S1, S2 : ScreenPtr );
   procedure ScreenCopy        ( var S1, S2 : ScreenPtr );
   procedure ScreenHideCursor  ( var S : ScreenPtr );
   procedure ScreenNormCursor  ( var S : ScreenPtr );
   procedure ScreenInsCursor   ( var S : ScreenPtr );
   procedure ScreenSetColor    ( var S : ScreenPtr; C : byte );
   procedure ScreenChangeColor ( var S : ScreenPtr;   C, X1, Y1, X2, Y2 : byte );
   procedure ScreenInvert      ( var S : ScreenPtr;   X1, Y1, X2, Y2 : byte );
   function  ScreenUse80Column ( Mode : word ) : boolean;
   procedure ScreenFixXYCoor   ( var S : ScreenPtr; var X, Y : byte );
   procedure ScreenPut         ( var S : ScreenPtr; X, Y, O : byte);
   procedure ScreenMove        ( var S : ScreenPtr; X, Y : byte; var Mem; Size : word);
   procedure ScreenWrite       ( var S : ScreenPtr; Str : String );
   procedure ScreenWriteColor  ( var S : ScreenPtr; Str : String );
   procedure ScreenWriteTTL    ( var S : ScreenPtr; Str : String );
   procedure ScreenRead        ( var S : ScreenPtr; X, Y, L : byte; Var Str : String );
   procedure ScreenClr         ( var S : ScreenPtr );
   procedure ScreenFillWindow  ( var S : ScreenPtr; O : byte );
   procedure ScreenSetWindow   ( var S : ScreenPtr;   X1, Y1, X2, Y2 : byte );
   function  ScreenGetChar     ( var S : ScreenPtr;   X, Y : byte )        : Char;
   function  ScreenGetAttr     ( var S : ScreenPtr;   X, Y : byte )        : Byte;
   procedure ScreenSetMode     ( var S : ScreenPtr; M : Word);
   function  ScreenGetMode     ( var S : ScreenPtr)   : word;
   function  ScreenGetX        ( var S : ScreenPtr)   : byte;
   function  ScreenGetY        ( var S : ScreenPtr)   : byte;
   function  ScreenMaxX        ( var S : ScreenPtr)   : byte;
   function  ScreenMaxY        ( var S : ScreenPtr)   : byte;
   procedure ScreenGetWindow   ( var S : ScreenPtr;   var X1, Y1, X2, Y2 : byte);
   procedure ScreenSetXY       ( var S : ScreenPtr;   X, Y : byte );
   procedure ScreenMakeBox     ( var S : ScreenPtr;   X1, Y1, X2, Y2 : byte;
                                 Shadow : boolean; CharSet : String);
   procedure ScreenSingleBox   ( var S : ScreenPtr;   X1, Y1, X2, Y2 : byte;
                                 Shadow : boolean);
   procedure ScreenDoubleBox   ( var S : ScreenPtr;   X1, Y1, X2, Y2 : byte;
                                 Shadow : boolean);
   procedure ScreenSingleVertBar (var S : ScreenPtr; X1, Y1, Y2 : byte);
   procedure ScreenDoubleVertBar (var S : ScreenPtr; X1, Y1, Y2 : byte);
   procedure ScreenSingleHorzBar (var S : ScreenPtr; X1, Y1, X2 : byte);
   procedure ScreenDoubleHorzBar (var S : ScreenPtr; X1, Y1, X2 : byte);
   procedure ScreenShiftUp       (var S : ScreenPtr; A, O : byte );
   procedure ScreenShiftDown     (var S : ScreenPtr; A, O : byte );
   procedure ScreenShiftLeft     (var S : ScreenPtr; A, O : byte );
   procedure ScreenShiftRight    (var S : ScreenPtr; A, O : byte );
   procedure ScreenScrollUp      (var S1, S2 : ScreenPtr; A : byte);
   procedure ScreenScrollDown    (var S1, S2 : ScreenPtr; A : byte);
   procedure ScreenScrollLeft    (var S1, S2 : ScreenPtr; A : byte);
   procedure ScreenScrollRight   (var S1, S2 : ScreenPtr; A : byte);
   procedure ScreenSaveFile      (var S : ScreenPtr; N : String; var Result : integer );
   procedure ScreenLoadFile      (var S : ScreenPtr; N : String; var Result : integer );
   procedure ScreenLoadTSR       (var S : ScreenPtr; N : String; var Result : integer );
   procedure ScreenSaveWindow    (var S : ScreenPtr; N : String; Pos : longInt; var Result : integer );
   procedure ScreenLoadWindow    (var S : ScreenPtr; N : String; Pos : longInt; var Result : integer );
   procedure ScreenHorzBar       (var S : ScreenPtr; X1, Y1, X2 : byte;
                                  Lft, Mdl, Rgh  : String);
   procedure ScreenVertBar       (var S  : ScreenPtr; X1, Y1, Y2 : byte;
                                  Top, Mdl, Btm  : String);
   function Color                ( T, B : word) : word;
   function InvertColor          ( C : Word ) : word;


implementation

{----------------------------------------------------------------------------}
   var
      Util : ScreenUtilities;

   function Color (T, B : word) : word;
      begin
         Color := Util.Color (T, B);
      end;
   function InvertColor (C : word) : Word;
      begin
         InvertColor := Util.InvertColor (C);
      end;

   function ScreenEnoughMemory : boolean;
      begin
         ScreenEnoughMemory := MaxAvail > SizeOf ( ScreenRec );
      end;

   procedure ScreenAllocate ( var S : ScreenPtr );
      begin
         if MaxAvail > Sizeof (ScreenRec) then
            begin
               New (S);
               S^.ShiftFill := True;
            end
         else
            S := NIL;
      end;

   procedure ScreenDeAllocate ( var S : ScreenPtr );
      begin
         If S <> NIL then
            Dispose ( S );
         S := NIL;
      end;
{----------------------------------------------------------------------------}
   function ScreenUse80Column ( Mode : word ) : boolean;
      begin
         case Mode of
            BW80, BW80 + Font8x8,
            CO80, CO80 + Font8x8 : ScreenUse80Column := True;
            BW40, BW40 + Font8x8,
            CO40, CO40 + Font8x8 : ScreenUse80Column := False;
         end;
      end;

   procedure ScreenLoad ( var S : ScreenPtr );
      begin
         if S <> NIL then
            with S^ do
               begin
                  if LastMode <> Mode then
                     TextMode (Mode);
                  case Mode of
                     BW80, BW80 + Font8x8 : BW80Screen := C80;
                     CO80, CO80 + Font8x8 : CO80Screen := C80;
                     BW40, BW40 + Font8x8 : BW40Screen := C40;
                     CO40, CO40 + Font8x8 : CO40Screen := C40;
                  end;
                  Util.SetOverScan (OverScan);
                  Crt.Window (Min.X, Min.Y, Max.X, Max.Y);
                  Crt.GotoXY (Pos.X, Pos.Y);
                  TextAttr := Attr;
                  Util.SetCursor ( Cur );
               end;
      end;

   procedure ScreenSave ( var S : ScreenPtr );
      begin
         if S <> NIL then
            with S^ do
               begin
                  Min.X := Lo(WindMin) + 1;
                  Min.Y := Hi(WindMin) + 1;
                  Max.X := Lo(WindMax) + 1;
                  Max.Y := Hi(WindMax) + 1;
                  Pos.X := WhereX;
                  Pos.Y := WhereY;
                  Attr := TextAttr;
                  Mode := LastMode;
                  Cur  := Util.GetCursor;
                  OverScan := Util.GetOverScan;
                  case Mode of
                     BW80, BW80 + Font8x8 : C80 := BW80Screen;
                     CO80, CO80 + Font8x8 : C80 := CO80Screen;
                     BW40, BW40 + Font8x8 : C40 := BW40Screen;
                     CO40, CO40 + Font8x8 : C40 := CO40Screen;
                  end;
               end;
      end;
   procedure ScreenCopy ( var S1, S2 : ScreenPtr );
      begin
          if (S1 <> NIL) and (S2 <> NIL) then S2^ := S1^;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenFixXYCoor ( var S : ScreenPtr; var X, Y : byte );
      begin
         if X < 1 then X := 1;
         if Y < 1 then Y := 1;
         if ScreenUse80Column (S^.Mode) then
            begin If X > 80 then X := 80  end
         else
            begin If X > 40 then X := 40  end;
         if S^.Mode >= Font8x8 then
            begin If Y > 50 then Y := 50  end
         else
            begin If Y > 25 then Y := 25  end;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenSetColor ( var S : ScreenPtr; C : byte );
      begin
         if S <> NIL then
            S^.Attr := C;
      end;

   procedure ScreenChangeColor ( var S : ScreenPtr; C, X1, Y1, X2, Y2 : byte );
      var
        I, J  : byte;
        V     : Word;
        Use80 : boolean;
      begin
         if S <> NIL then
            begin
               V := C Shl 8;
               Use80 := ScreenUse80Column (S^.Mode);
               ScreenFixXYCoor ( S, X1, Y1 );
               ScreenFixXYCoor ( S, X2, Y2 );
               with S^ do
                  for J := Y1 to Y2 do
                     for I := X1 to X2 do
                        if Use80 then
                           C80[J, I] := Lo(C80[J, I]) + V
                        else
                           C40[J, I] := Lo(C40[J, I]) + V
            end;
      end;

   procedure ScreenInvert ( var S : ScreenPtr; X1, Y1, X2, Y2 : byte );
      var
        I, J  : byte;
        Use80 : boolean;
      begin
         if S <> NIL then
            begin
               Use80 := ScreenUse80Column (S^.Mode);
               ScreenFixXYCoor ( S, X1, Y1 );
               ScreenFixXYCoor ( S, X2, Y2 );
               with S^ do
                  for J := Y1 to Y2 do
                     for I := X1 to X2 do
                        if Use80 then
                           C80[J, I] := Lo(C80[J, I]) +
                           Util.InvertColor(Hi(C80[J, I])) Shl 8
                        else
                           C40[J, I] := Lo(C40[J, I]) +
                           Util.InvertColor(Hi(C80[J, I])) Shl 8;
            end;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenHideCursor ( var S : ScreenPtr );
      begin
         If S <> NIL then
            S^.Cur := $2000;
      end;

   procedure ScreenNormCursor ( var S : ScreenPtr );
      begin
         If S <> NIL then
            S^.Cur := $0D0E;
      end;

   procedure ScreenInsCursor ( var S : ScreenPtr );
      begin
         If S <> NIL then
            S^.Cur := $0D11;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenClr ( var S : ScreenPtr );
      var
        I, J  : byte;
        V     : Word;
        Use80 : boolean;
      begin
         if S <> NIL then
            begin
               V := S^.Attr Shl 8 + 32;
               Use80 := ScreenUse80Column (S^.Mode);
               with S^ do
                  begin
                     ScreenFixXYCoor ( S, Min.X, Min.Y );
                     ScreenFixXYCoor ( S, Max.X, Max.Y );
                     Pos.X := Min.X;
                     Pos.Y := Min.Y;
                     for J := Min.Y to Max.Y do
                        for I := Min.X to Max.X do
                           case Use80 of
                              True  : C80[J, I] := V;
                              False : C40[J, I] := V;
                           end;
                  end;
            end;
      end;

   procedure ScreenFillWindow ( var S : ScreenPtr; O : byte );
      var
        I, J  : byte;
        V     : Word;
        Use80 : boolean;
      begin
         if S <> NIL then
            begin
               V := S^.Attr Shl 8 + O;
               Use80 := ScreenUse80Column (S^.Mode);
               with S^ do
                  begin
                     ScreenFixXYCoor ( S, Min.X, Min.Y );
                     ScreenFixXYCoor ( S, Max.X, Max.Y );
                     for J := Min.Y to Max.Y do
                        for I := Min.X to Max.X do
                           case Use80 of
                              True  : C80[J, I] := V;
                              False : C40[J, I] := V;
                           end;
                  end;
            end;
      end;

   procedure ScreenSetWindow ( var S : ScreenPtr; X1, Y1, X2, Y2 : byte );
      begin
         if S <> NIL then
            begin
               ScreenFixXYCoor ( S, X1, Y1 );
               ScreenFixXYCoor ( S, X2, Y2 );
               with S^ do
                  begin
                     Min.X := X1; Min.Y := Y1;
                     Max.X := X2; Max.Y := Y2;
                     Pos.X := X1; Pos.Y := Y1;
                  end;
            end;
      end;

   procedure ScreenGetWindow ( var S : ScreenPtr; var X1, Y1, X2, Y2 : byte );
      begin
         if S <> NIL then
            begin
               with S^ do
                  begin
                     X1 := Min.X; Y1 := Min.Y;
                     X2 := Max.X; Y2 := Max.Y;
                  end;
            end;
      end;

   procedure ScreenSetMode ( var S : ScreenPtr; M : word );
      begin
         if S <> NIL then
            begin
               with S^ do
                  begin
                     Mode := M;
                     ScreenFixXYCoor (S, Min.X, Min.Y);
                     ScreenFixXYCoor (S, Max.X, Max.Y);
                     ScreenFixXYCoor (S, Pos.X, Pos.Y);
                  end;
            end;
      end;

   function ScreenGetMode ( var S : ScreenPtr) : word;
      begin
         if S <> NIL then
            ScreenGetMode := S^.Mode
         else
            ScreenGetMode := $FFFF;
      end;

   function ScreenGetX ( var S : ScreenPtr) : byte;
      begin
         if S <> NIL then
            ScreenGetX := S^.Pos.X - S^.Min.X + 1
         else
            ScreenGetX := $FF;
      end;

   function ScreenGetY ( var S : ScreenPtr) : byte;
      begin
         if S <> NIL then
            ScreenGetY := S^.Pos.Y - S^.Min.Y + 1
         else
            ScreenGetY := $FF;
      end;

   function ScreenMaxX ( var S : ScreenPtr) : byte;
      var
         X, Y : byte;
      begin
         X := 80; Y := 50;
         if S <> NIL then
            begin
               ScreenFixXYCoor (S, X, Y);
               ScreenMaxX := X
            end
         else
            ScreenMaxX := $FF;
      end;

   function ScreenMaxY ( var S : ScreenPtr) : byte;
      var
         X, Y : byte;
      begin
         X := 80; Y := 50;
         if S <> NIL then
            begin
               ScreenFixXYCoor (S, X, Y);
               ScreenMaxY := Y
            end
         else
            ScreenMaxY := $FF;
      end;

   procedure ScreenSetXY ( var S : ScreenPtr; X, Y : byte );
      begin
         if S <> NIL then
            with S^ do
               begin
                  X := X + Min.X - 1;
                  Y := Y + Min.Y - 1;
                  if X > Max.X then X := Max.X ;
                  if Y > Max.Y then Y := Max.Y ;
                  ScreenFixXYCoor ( S, X, Y );
                  Pos.X := X;
                  Pos.Y := Y;
               end;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenPut ( var S : ScreenPtr; X, Y, O : byte );
      begin
         if S <> NIL then
            begin
               ScreenFixXYCoor ( S, X, Y );
               With S^ do
                  if ScreenUse80Column ( S^.Mode ) then
                     C80[Y, X] := O + Attr Shl 8
                  else
                     C40[Y, X] := O + Attr Shl 8;
            end;
      end;

   procedure ScreenMove ( var S : ScreenPtr; X, Y : byte; var Mem; Size : word);
      begin
         if S <> NIL then
            begin
               With S^ do
                  if ScreenUse80Column ( S^.Mode ) then
                     Move (Mem, C80[Y, X], Size)
                  else
                     Move (Mem, C40[Y, X], Size);
            end;
      end;

   function ScreenGetChar ( var S : ScreenPtr; X, Y : byte ) : Char;
      var
         O : byte;
      begin
         O := 0;
         if S <> NIL then
            begin
               ScreenFixXYCoor ( S, X, Y );
               With S^ do
                  case ScreenUse80Column ( S^.Mode ) of
                     True  : O := Lo(C80[Y, X]);
                     False : O := Lo(C40[Y, X]);
                  end;
            end;
         ScreenGetChar := Chr(O);
      end;

   function ScreenGetAttr ( var S : ScreenPtr; X, Y : byte ) : Byte;
      var
         O : byte;
      begin
         O := 0;
         if S <> NIL then
            begin
               ScreenFixXYCoor ( S, X, Y );
               With S^ do
                  case ScreenUse80Column ( S^.Mode ) of
                     True  : O := Hi(C80[Y, X]);
                     False : O := Hi(C40[Y, X]);
                  end;
            end;
         ScreenGetAttr := O;
      end;

   procedure ScreenWrite ( var S : ScreenPtr; Str : String );
      var
         Use80 : boolean;
         I     : byte;
         V     : word;
      begin
         if S <> NIL then
         with S^ do
            begin
               Use80 := ScreenUse80Column (Mode);
               V     := Attr Shl 8;
               for I := 1 to length(Str) do
                  begin
                     case Use80 of
                        True  : C80[Pos.Y, Pos.X] := Ord(Str[I]) + V;
                        False : C40[Pos.Y, Pos.X] := Ord(Str[I]) + V;
                     end;
                     inc (Pos.X);
                     if Pos.X > Max.X then
                        begin
                           Pos.X := Min.X;
                           inc (Pos.Y);
                           if Pos.Y > Max.Y then
                              begin
                                 Pos.Y := Min.Y;
                              end;
                        end;
                  end;
            end;
      end;

   procedure ScreenWriteColor ( var S : ScreenPtr; Str : String );
      var
         Use80   : boolean;
         I, X, Y : byte;
      begin
         if S <> NIL then
         with S^ do
            begin
               X := Pos.X; Y := Pos.Y;
               Use80 := ScreenUse80Column (Mode);
               case Use80 of
                 True  : for I := 1 to length(Str) do
                            begin
                               C80[Y, X] := Lo(C80[Y, X]) + Ord(Str[I]) shl 8;
                               inc (X);
                               if X > Max.X then
                                 begin
                                   X := Min.X;
                                   Inc (Y);
                                   if Y > Max.Y then
                                     Y := Min.Y
                                 end;
                            end;
                 False : for I := 1 to length(Str) do
                            begin
                               C40[Y, X] := Lo(C40[Y, X]) + Ord(Str[I]) shl 8;
                               inc (X);
                               if X > Max.X then
                                 begin
                                   X := Min.X;
                                   Inc (Y);
                                   if Y > Max.Y then
                                     Y := Min.Y
                                 end;
                            end;
               end;
            end;
      end;

   procedure ScreenWriteTTL ( var S : ScreenPtr; Str : String );
      var
         Use80 : boolean;
         I     : byte;
      begin
         if S <> NIL then
         with S^ do
            begin
               Use80 := ScreenUse80Column (Mode);
               for I := 1 to length(Str) do
                  begin
                     case Use80 of
                        True  : C80[Pos.Y, Pos.X] := Hi(C80[Pos.Y, Pos.X])
                                                     shl 8 + Ord(Str[I]);
                        False : C40[Pos.Y, Pos.X] := Hi(C40[Pos.Y, Pos.X])
                                                     shl 8 + Ord(Str[I]);
                     end;
                     inc (Pos.X);
                     if Pos.X > Max.X then
                        begin
                           Pos.X := Min.X;
                           inc (Pos.Y);
                           if Pos.Y > Max.Y then
                              begin
                                 Pos.Y := Min.Y;
                              end;
                        end;
                  end;
            end;
      end;

   procedure ScreenRead ( var S : ScreenPtr; X, Y, L : byte; Var Str : String );
      var
         Use80 : boolean;
         I     : byte;
      begin
         if S <> NIL then
         with S^ do
            begin
               X := X + Min.X;
               Y := Y + Min.Y;
               Use80 := ScreenUse80Column (Mode);
               Str := '';
               for I := 1 to L do
                  begin
                     case Use80 of
                        True  : Str := Str + Chr(Lo(C80[Y, X]));
                        False : Str := Str + Chr(Lo(C40[Y, X]));
                     end;
                     inc (X);
                     if X > Max.X then
                        begin
                           X := Min.X;
                           inc (Y);
                           if Y > Max.Y then
                              begin
                                 Y := Min.Y;
                              end;
                        end;
                  end;
            end;
      end;
{----------------------------------------------------------------------------}
   procedure ScreenMakeShadow  ( S : ScreenPtr; Use80 : boolean;
                           X1, Y1, X2, Y2 : byte);
      const
         Exclude = '
