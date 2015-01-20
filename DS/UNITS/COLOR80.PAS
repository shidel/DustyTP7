{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

unit Color80;

{$O+,F+}

interface

   uses QCRTNM, ScrnUtil;

  Const
    Color80Version = '80 Column Color, Direct Video Driver Version #1.2';
    ColorBasePointer : Pointer = Ptr( $B800, $0000 );
    MonoBasePointer  : Pointer = Ptr( $B000, $0000 );

   type
      ScreenSet   = ( Asc, Atr );
      CO80Array   = array [1..50,1..80,ScreenSet] of byte;

   var
     CO80Screen        : ^CO80Array;
     UseColor80        : boolean;
{----------------------------------------------------------------------------}
   type
     BasicType = object ( ScreenUtilities )
       procedure GetWindow     ( var X1, Y1, X2, Y2 : byte );
       procedure FixXY         ( var X,  Y : byte );
       procedure SetRGBColor   (     C     : Word; Red, Green, Blue : Byte );
       procedure NormCursor;
       procedure HideCursor;
       procedure InsCursor;
       procedure FadeInColors  ( Colors : ColorType; Speed : byte );
       procedure FadeOutColors ( Colors : ColorType; Speed : byte );
       procedure WaitForSyncPulse;
     end;
     CO80Type = object ( BasicType )
         CurrentActivePage,
         CurrentVisualPage  : byte;
       procedure Init;
       procedure ShutDown;
       procedure PutABS        (  X,  Y : Byte; C : Char );
       procedure PutChr        (  X,  Y : Byte; C : Char );
       procedure PutAttr       (  X,  Y : Byte; A : Byte );
       function  GetABS        (  X,  Y : Byte) : word;
       function  GetChr        (  X,  Y : Byte) : Char;
       function  GetAttr       (  X,  Y : Byte) : Byte;
       procedure WriteABS      (  X,  Y : Byte; S : String );
       procedure WriteXY       (  X,  Y : Byte; S : String );
       procedure WriteTTL      (  X,  Y : Byte; S : String );
       procedure WriteAttr     (  X,  Y : Byte; A, L : byte );
       procedure MakeBox       ( X1, Y1, X2, Y2 : byte; Shadow : boolean; CharSet : String);
       procedure SingleBox     ( X1, Y1, X2, Y2 : byte; Shadow : boolean);
       procedure DoubleBox     ( X1, Y1, X2, Y2 : byte; Shadow : boolean);
       procedure HorzBar       ( X1, Y1, X2 : byte; Lft, Mdl, Rgh  : String);
       procedure VertBar       ( X1, Y1, Y2 : byte; Top, Mdl, Btm  : String);
       procedure SingleVertBar ( X1, Y1, Y2 : byte);
       procedure DoubleVertBar ( X1, Y1, Y2 : byte);
       procedure SingleHorzBar ( X1, Y1, X2 : byte);
       procedure DoubleHorzBar ( X1, Y1, X2 : byte);

       procedure SetVisualPage ( Visual : byte );
       procedure SetActivePage ( Active : byte );
       function  GetVisualPage : byte;
       function  GetActivePage : byte;
       function  ScreenSize : word;
       function  GetPagePointer ( Number : byte ) : Pointer;
       procedure CopyPage       ( FromPage, ToPage : Byte );

     end;

implementation

  uses DOS;
{----------------------------------------------------------------------------}
  procedure MaxWindow;
    begin
      QCRTNM.Window ( 1, 1, 80, 25 );
      QCRTNM.Window ( 1, 1, 80, 43 );
      QCRTNM.Window ( 1, 1, 80, 50 );
    end;

  procedure BasicType.GetWindow ( var X1, Y1, X2, Y2 : byte );
    begin
      X1 := Lo(QCRTNM.WindMin) + 1;
      Y1 := Hi(QCRTNM.WindMin) + 1;
      X2 := Lo(QCRTNM.WindMax) + 1;
      Y2 := Hi(QCRTNM.WindMax) + 1;
    end;

  procedure BasicType.FixXY ( var X, Y : byte );
     var
       X1, Y1, X2, Y2 : Byte;
     begin
       GetWindow ( X1, Y1, X2, Y2 );
       X := X + X1 - 1;
       Y := Y + Y1 - 1;
       if X < X1 then X := X1 else
       If X > X2 then X := X2;
       if Y < Y1 then Y := Y1 else
       if Y > Y2 then Y := Y2;
     end;

  procedure BasicType.SetRGBColor (C : Word; Red, Green, Blue : Byte );
    var
      RGB : RGBRec;
    begin
      RGB.Red   := Red;
      RGB.Green := Green;
      RGB.Blue  := Blue;
      ScreenUtilities.SetRGBColor (C, RGB );
    end;

  procedure BasicType.NormCursor;  begin SetCursor ($0D0E) end;
  procedure BasicType.HideCursor;  begin SetCursor ($2000) end;
  procedure BasicType.InsCursor;   begin SetCursor ($0D11) end;

  procedure BasicType.WaitForSyncPulse;
    begin
      While Not (Port[$3da] and $08 = $08) do;
    end;

  procedure BasicType.FadeInColors ( Colors : ColorType; Speed : byte );
    var
      Temp : ColorType;
      I, J : Integer;
      V    : Real;
    begin
      for I := 0 to Speed do
        begin
          V := I / Speed ;
          for J := 0 to 63 do
            with Temp[J] do
              begin
                Red   := Round( Colors[J].Red   * V );
                Green := Round( Colors[J].Green * V );
                Blue  := Round( Colors[J].Blue  * V );
              end;
          WaitForSyncPulse;
          SetAllRGBColors ( Temp );
        end;
    end;

  procedure BasicType.FadeOutColors;
    var
      Temp : ColorType;
      I, J : Integer;
      V    : Real;
    begin
      for I := Speed downto 0 do
        begin
          V := I / Speed ;
          for J := 0 to 63 do
            with Temp[J] do
              begin
                Red   := Round( Colors[J].Red   * V );
                Green := Round( Colors[J].Green * V );
                Blue  := Round( Colors[J].Blue  * V );
              end;
          WaitForSyncPulse;
          SetAllRGBColors ( Temp );
        end;
    end;
{----------------------------------------------------------------------------}
  procedure CO80Type.PutABS;
    begin
      CO80Screen^[Y, X, ASC ] := Ord(C);
      CO80Screen^[Y, X, Atr]  := TextAttr;
    end;

  procedure CO80Type.PutChr;
    begin
      FixXY ( X, Y );
      CO80Screen^[Y, X, ASC ] := Ord(C);
    end;

  procedure CO80Type.PutAttr;
    begin
      FixXY ( X, Y );
      CO80Screen^[Y, X, Atr ] := A;
    end;
{----------------------------------------------------------------------------}
   function CO80Type.GetABS;
    begin
      GetABS := CO80Screen^[Y, X, ASC ] + CO80Screen^[Y, X, Atr] Shl 8;
    end;

  function CO80Type.GetChr;
    begin
      FixXY ( X, Y );
      GetCHR := System.Chr(CO80Screen^[Y, X, ASC]);
    end;

  function CO80Type.GetAttr;
    begin
      FixXY ( X, Y );
      GetAttr := CO80Screen^[Y, X, Atr];
    end;
{----------------------------------------------------------------------------}
  procedure CO80Type.WriteABS;
    var
      I, MaxX, MinX, MaxY, MinY : Byte;
    begin
      MaxX := 80; MinX := 1;
      MinY := 1;
      if LastMode >= Font8x8 then
        MaxX := 50 else MaxY := 25;
      for I := 1 to Length(S) do
        begin
          CO80Screen^[Y, X, ASC ] := ord(S[I]);
          CO80Screen^[Y, X, Atr]  := TextAttr;
          inc(X);
          if X > MaxX then
            begin
              X := MinX;
              Inc ( Y );
              if Y > MaxY then Y := MinY;
            end;
        end
    end;

  procedure CO80Type.WriteXY;
    var
      I, MaxX, MinX, MaxY, MinY : Byte;
    begin
      MaxX := 80; MaxY := 50;
      FixXY ( MaxX, MaxY );
      MinX := 1;  MinY := 1;
      FixXY ( MinX, MinY );
      FixXY ( X, Y );
      for I := 1 to Length(S) do
        begin
          CO80Screen^[Y, X, ASC ] := ord(S[I]);
          CO80Screen^[Y, X, Atr]  := TextAttr;
          inc(X);
          if X > MaxX then
            begin
              X := MinX;
              Inc ( Y );
              if Y > MaxY then Y := MinY;
            end;
        end;
    end;

  procedure CO80Type.WriteTTL;
    var
      I, MaxX, MinX, MaxY, MinY : Byte;
    begin
      MaxX := 80; MaxY := 50;
      FixXY ( MaxX, MaxY );
      MinX := 1;  MinY := 1;
      FixXY ( MinX, MinY );
      FixXY ( X, Y );
      for I := 1 to Length(S) do
        begin
          CO80Screen^[Y, X, ASC ] := ord(S[I]);
          inc(X);
          if X > MaxX then
            begin
              X := MinX;
              Inc ( Y );
              if Y > MaxY then Y := MinY;
            end;
        end;
    end;

  procedure CO80Type.WriteAttr;
    var
      I, MaxX, MinX, MaxY, MinY : Byte;
    begin
      MaxX := 80; MaxY := 50;
      FixXY ( MaxX, MaxY );
      MinX := 1;  MinY := 1;
      FixXY ( MinX, MinY );
      FixXY ( X, Y );
      for I := 1 to L do
        begin
          CO80Screen^[Y, X, Atr]  := A;
          inc(X);
          if X > MaxX then
            begin
              X := MinX;
              Inc ( Y );
              if Y > MaxY then Y := MinY;
            end;
        end;
    end;

   procedure MakeShadow  ( X1, Y1, X2, Y2 : byte);
      const
         Exclude = '∞±≤€‹›ﬁﬂ';
      var
         I, J, O : byte;
      begin
         Inc (X1, 2); inc (X2); Inc (Y1, 1); Inc (Y2, 1);
         I := X1;
         while (I < X2 + 2) and (I < 81) do
            begin
               CO80Screen^[Y2, I, Atr] := 8;
               if System.Pos(Chr(CO80Screen^[Y2, I, Asc]), Exclude) > 0 then
                  CO80Screen^[Y2, I, Asc] := 32;
               inc (I);
            end;
         for J := 1 to 2 do
            begin
               I := Y1;
               while (I < Y2) and  (I < 50) and (X2 < 81) do
                  begin
                    CO80Screen^[I, X2, Atr] := 8;
                    if System.Pos(Chr(CO80Screen^[I, X2, Asc]), Exclude) > 0 then
                      CO80Screen^[I, X2, Asc] := 32;
                    inc (I);
                  end;
               Inc (X2);
            end;
         end;
{----------------------------------------------------------------------------}
   procedure Co80Type.MakeBox ( X1, Y1, X2, Y2 : byte; Shadow : boolean; CharSet : String);
      var
        I, J : byte;
      begin
        MaxWindow;
        FixXY (X1, Y1);
        FixXY (X2, Y2);
        For J := Y1 to Y2 do
          For I := X1 to X2 do
            begin
              CO80Screen^[J, I, Atr] := TextAttr;
              CO80Screen^[J, I, ASC] := 32;
            end;
        J := Ord(CharSet[5]);
        For I := X1 + 1 to X2 - 1 do
          begin
            CO80Screen^[Y1, I, ASC] := J;
            CO80Screen^[Y2, I, ASC] := J;
          end;
        J := Ord(CharSet[6]);
        For I := Y1 + 1 to Y2 - 1 do
          begin
            CO80Screen^[I, X1, ASC] := J;
            CO80Screen^[I, X2, ASC] := J;
          end;
        CO80Screen^[Y1, X1, ASC] := Ord(CharSet[1]);
        CO80Screen^[Y1, X2, ASC] := Ord(CharSet[2]);
        CO80Screen^[Y2, X1, ASC] := Ord(CharSet[3]);
        CO80Screen^[Y2, X2, ASC] := Ord(CharSet[4]);
        if Shadow then MakeShadow ( X1, Y1, X2, Y2);
        Window ( X1 + 1, Y1 + 1, X2 - 1, Y2 - 1);
      end;

   procedure CO80Type.SingleBox ( X1, Y1, X2, Y2 : byte; Shadow : boolean);
      const
         CharSet = '⁄ø¿Ÿƒ≥';
      begin
         MakeBox ( X1, Y1, X2, Y2, Shadow, CharSet );
      end;

   procedure CO80Type.DoubleBox ( X1, Y1, X2, Y2 : byte; Shadow : boolean);
      const
         CharSet = '…ª»ºÕ∫';
      begin
         MakeBox ( X1, Y1, X2, Y2, Shadow, CharSet );
      end;
{----------------------------------------------------------------------------}
const
   Current = 'Õƒ∫≥…ÀªÃŒπ» º÷“∑«◊∂”–Ω’—∏∆ÿµ‘œæ⁄¬ø√≈¥¿¡Ÿ';
   BarTop1 = '—¬≥≥’—∏∆ÿµ∆ÿµ⁄¬ø√≈¥√≈¥’—∏∆ÿµ∆ÿµ⁄¬ø√≈¥√≈¥≥';
   BarUp1  = 'ÿ≈≥≥∆ÿµ∆ÿµ∆ÿµ√≈¥√≈¥√≈¥∆ÿµ∆ÿµ∆ÿµ√≈¥√≈¥√≈¥≥';
   BarBtm1 = 'œ¡≥≥∆ÿµ∆ÿµ‘œæ√≈¥√≈¥¿¡Ÿ∆ÿµ∆ÿµ‘œæ√≈¥√≈¥¿¡Ÿ≥';
   BarLft1 = 'ƒƒ«√÷““«◊◊”––÷““«◊◊”––⁄¬¬√≈≈¿¡¡⁄¬¬√≈≈¿¡¡ƒ';
   BarAcs1 = 'ƒƒ◊≈“““◊◊◊–––“““◊◊◊–––¬¬¬≈≈≈¡¡¡¬¬¬≈≈≈¡¡¡ƒ';
   BarRgh1 = 'ƒƒ∂¥““∑◊◊∂––Ω““∑◊◊∂––Ω¬¬ø≈≈¥¡¡Ÿ¬¬ø≈≈¥¡¡Ÿƒ';
   BarTop2 = 'À“∫∫…ÀªÃŒπÃŒπ÷“∑«◊∂«◊∂…ÀªÃŒπÃŒπ÷“∑«◊∂«◊∂∫';
   BarUp2  = 'Œ◊∫∫ÃŒπÃŒπÃŒπ«◊∂«◊∂«◊∂ÃŒπÃŒπÃŒπ«◊∂«◊∂«◊∂∫';
   BarBtm2 = ' –∫∫ÃŒπÃŒπ» º«◊∂«◊∂”–ΩÃŒπÃŒπ» º«◊∂«◊∂”–Ω∫';
   BarLft2 = 'ÕÕÃ∆…ÀÀÃŒŒ»  …ÀÀÃŒŒ»  ’——∆ÿÿ‘œœ’——∆ÿÿ‘œœÕ';
   BarAcs2 = 'ÕÕŒÿÀÀÀŒŒŒ   ÀÀÀŒŒŒ   ———ÿÿÿœœœ———ÿÿÿœœœÕ';
   BarRgh2 = 'ÕÕπµÀÀªŒŒπ  ºÀÀªŒŒπ  º——∏ÿÿµœœæ——∏ÿÿµœœæÕ';

  procedure CO80Type.HorzBar ( X1, Y1, X2 : byte; Lft, Mdl, Rgh  : String);
    var
      i, P  : Byte;
    begin
      FixXY ( X1, Y1 );
      FixXY ( X2, Y1 );
      for I := X1 to X2 do
        CO80Screen^[Y1, I, Atr] := TextAttr;

      P := Pos(Chr(CO80Screen^[Y1, X1, Asc]), Current);
      If P = 0 then P := Length(Lft);
      CO80Screen^[Y1, X1, Asc] :=  Ord(Lft[P]);

      P := Pos(Chr(Co80Screen^[Y1, X2, Asc]), Current);
      If P = 0 then P := Length(Rgh);
      Co80Screen^[Y1, X2, Asc] :=  Ord(Rgh[P]);

      For I := X1 + 1 to X2 - 1 do
        begin
          P := Pos(Chr(Co80Screen^[Y1, I, Asc]), Current);
          If P = 0 then P := Length(Mdl);
          Co80Screen^[Y1, I, Asc] :=  Ord(Mdl[P]);
        end;
    end;

   procedure CO80Type.VertBar ( X1, Y1, Y2 : byte; Top, Mdl, Btm  : String);
     var
       i, P  : Byte;
     begin
       FixXY ( X1, Y1 );
       FixXY ( X1, Y2 );
       for I := Y1 to Y2 do
         Co80Screen^[ I, X1, Atr] := TextAttr;

       P := Pos(Chr(Co80Screen^[Y1, X1, Asc]), Current);
       If P = 0 then P := Length(Top);
       Co80Screen^[Y1, X1, Asc] :=  Ord(Top[P]);

       P := Pos(Chr(Co80Screen^[Y2, X1, Asc]), Current);
       If P = 0 then P := Length(Btm);
       Co80Screen^[Y2, X1, Asc] :=  Ord(Btm[P]);

       For I := Y1 + 1 to Y2 - 1 do
         begin
           P := Pos(Chr(Co80Screen^[I, X1, Asc]), Current);
           If P = 0 then P := Length(Mdl);
           Co80Screen^[I, X1, Asc] :=  Ord(Mdl[P]);
         end;
    end;

   procedure CO80Type.SingleVertBar ( X1, Y1, Y2 : byte);
      var
        X3, Y3, X4, Y4 : byte;
      begin
        GetWindow ( X3, Y3, X4, Y4 );
        MaxWindow;
        VertBar ( X1, Y1, Y2, BarTop1, BarUp1, BarBtm1 );
        Window ( X3, Y3, X4, Y4 );
      end;

   procedure CO80Type.DoubleVertBar ( X1, Y1, Y2 : byte);
      var
        X3, Y3, X4, Y4 : byte;
      begin
        GetWindow ( X3, Y3, X4, Y4 );
        MaxWindow;
        VertBar ( X1, Y1, Y2, BarTop2, BarUp2, BarBtm2 );
        Window ( X3, Y3, X4, Y4 );
      end;

   procedure CO80Type.SingleHorzBar ( X1, Y1, X2 : byte);
      var
        X3, Y3, X4, Y4 : byte;
      begin
        GetWindow ( X3, Y3, X4, Y4 );
        MaxWindow;
        HorzBar ( X1, Y1, X2, BarLft1, BarAcs1, BarRgh1);
        Window ( X3, Y3, X4, Y4 );
      end;

   procedure CO80Type.DoubleHorzBar ( X1, Y1, X2 : byte);
      var
        X3, Y3, X4, Y4 : byte;
      begin
        GetWindow ( X3, Y3, X4, Y4 );
        MaxWindow;
        HorzBar ( X1, Y1, X2, BarLft2, BarAcs2, BarRgh2);
        Window ( X3, Y3, X4, Y4 );
      end;

   procedure CO80Type.Init;
     begin
       ScreenUtilities.Init;
       SetVisualPage ( 0 );
       SetActivePage ( 0 );
     end;

   procedure CO80Type.ShutDown;
     begin
       SetVisualPage ( 0 );
       SetActivePage ( 0 );
       ScreenUtilities.ShutDown;
     end;

   procedure CO80Type.SetVisualPage ( Visual : Byte );
     var
       Regs : Registers;
     begin
       if UseColor80 then
         begin
           CurrentVisualPage := Visual;
           with Regs do
             begin
               AH := $05;
               AL := Visual;
               Intr ( $10, Regs );
             end;
         end;
     end;

   procedure CO80Type.SetActivePage ( Active : Byte );
     begin
       if UseColor80 then
         begin
           CurrentActivePage := Active;
           CO80Screen := Ptr( $B800, ScreenSize * Active );
         end;
     end;

   function CO80Type.GetVisualPage : byte;
     begin
       GetVisualPage := CurrentVisualPage;
     end;

   function CO80Type.GetActivePage : byte;
     begin
       GetActivePage := CurrentActivePage;
     end;

   function CO80Type.GetPagePointer;
     begin
       if UseColor80 then
         GetPagePointer := Ptr ( $B800, ScreenSize * Number )
       else
         GetPagePointer := MonoBasePointer;
     end;

   function CO80Type.ScreenSize : word;
     var
       X, Y,
       X1, Y1, X2, Y2,
       X3, Y3, X4, Y4 : byte;
     begin
       GetWindow  ( X1, Y1, X2, Y2 );
       X := WhereX;
       Y := WhereY;
       MaxWindow;
       GetWindow  ( X3, Y3, X4, Y4 );
       Window     ( X1, Y1, X2, Y2 );
       GotoXY     ( X, Y );
       if Y4 = 25 then
         ScreenSize := 4096
       else
         ScreenSize := 8256;
     end;

   procedure CO80Type.CopyPage ( FromPage, ToPage : Byte );
     var
       FPage, TPage : Pointer;
       PSize        : Word;
     begin
       if UseColor80 then
         begin
           FPage := GetPagePointer ( FromPage );
           TPage := GetPagePointer ( ToPage   );
           PSize := ScreenSize;
           Move ( FPage^, TPage^, PSize );
         end;
     end;

begin
  UseColor80 := LastMode <> 7;
  if UseColor80 then
    CO80Screen := ColorBasePointer
  else
    CO80Screen := MonoBasePointer;
end.
