{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit TxtMouse;

interface

   procedure ResetMouse;
   procedure ReadMouse (var OldXPos, OldYPos, OldColor : Integer;
                        var Data : String);
   procedure ReleaseButtons;
   procedure SplitButtons (Var Data : String;
                           Var Button1, Button2, Button3: boolean);

   function  MouseX       : integer;
   function  MouseY       : integer;
   function  MouseButton1 : boolean;
   function  MouseButton2 : boolean;
   function  MouseButton3 : boolean;

implementation

   uses QCrt;

type
  ScrPtr = ^Screen;
  Screen = Array [1..25,1..80] of word;

var
  MonoScreen : Screen Absolute $B000:$0000;
  ColorScreen : Screen Absolute $B800:$0000;
  KeepScreen : array [1..2] of Screen;
  ActiveScreen : ScrPtr;

procedure Color (Forg, Backg : Integer);
  begin
	 TextColor (Forg);
	 TextBackGround (Backg);
  end;

function GetText (Xpos, YPos : Byte) : Char;
  begin
	 if LastMode = Mono then
		ActiveScreen := @MonoScreen
	 else
		ActiveScreen := @ColorScreen;
	 GetText := chr(Lo(ActiveScreen^[ypos,xpos]));
  end;

function GetSColor (Xpos, YPos : Byte) : Integer;
  begin
	 if LastMode = Mono then
		ActiveScreen := @MonoScreen
	 else
		ActiveScreen := @ColorScreen;
	 GetSColor := HI(ActiveScreen^[ypos,xpos]);
end;

procedure SetSColor (Xpos, YPos, Cl : Integer);
  Var
	 H, C1, C2, C3 : Integer;
begin
 if LastMode = Mono then
	ActiveScreen := @MonoScreen
 else
	ActiveScreen := @ColorScreen;
 H := Lo( ActiveScreen^[Ypos, XPos] );
 GotoXY (Xpos, YPos);
 If Cl > 127 then
	begin
	   Cl := Cl - 128;
	   C3 := 128;
	end
 else
	C3 := 0;
 C2 := Cl div 16;
 C1 := Cl - C2 * 16;
 Color (C1+ C3, C2);
 Write (Chr(H));
end;

function GetTColor (CValue : Byte) : Byte;
begin
 GetTColor := CValue - (CValue div 16) * 16;
end;

function GetBColor (CValue : Byte) : Byte;
begin
 GetBColor := CValue div 16;
end;

procedure InvertColor (ColorVal : Integer);
  var
	C1, C2 : Integer;
begin
	If ColorVal > 127 then
	ColorVal := ColorVal - 128;
	C2 := ColorVal Div 16;
	C1 := ColorVal - C2 * 16;
	While C1 > 7 do     C1 := C1 - 8;
	While C2 > 7 do     C2 := C2 - 8;
	If C1 = C2 then
	begin
	   C1 := 7;
	   C2 := 0;
	end;
	Color (C2, C1);
end;

{-----------------------------------------------------------------------------}
procedure SplitButtons (Var Data : String;
                        Var Button1, Button2, Button3: boolean);
   var
     i : integer;
     D : String;
begin
   Button1 := False;
   Button2 := False;
   Button3 := False;
   D       := Data;
   Data    := '';
   if length(D)>0 then
      begin
         Data := D;
         I := ord(Data[1]);
         Delete (Data,1,1);
         If I >= 4 then
            begin
               Button2 := True;
               i := i - 4;
            end;
         If I >= 2 then
            begin
               Button3 := True;
               i := i - 2;
            end;
         If I >= 1 then
            begin
               Button1 := True;
               i := i - 1;
            end;
      end;
end;

procedure ReleaseButtons;
   var
     BtnStatus            : integer;
     X, Y                 : Integer;
begin
	BtnStatus := 1;
	While BtnStatus>0 do
	   GetMousePos (X, Y, BtnStatus);
end;


procedure ResetMouse;
begin
  SetMousePos (0,0);
  ReleaseButtons;
end;

procedure ReadMouse(Var OldXPos, OldYPos, OldColor : Integer; var Data : String);
   var
     mStatus              : boolean;
     Buttons              : integer;
     mButton              : integer;
     Xx, Yy, X1, Y1, Cl, OC, HoldX, HoldY,
     X2, Y2,  BtnStatus   : integer;

	procedure DumpCursor;
	   begin
		  SetSColor (OldXPos,OldYPos, OldColor);
		  OldXPos := 0;
		  OldYPos := 0;
	end;

	function ReadLeft (i, j : Integer) : String;
	var
	  Hold : String;
	begin
		Hold := '';
		if GetText(i,j)<>' ' then
		begin
		   while (GetText(i-1,j)<>' ') and (i>1) do
			  dec(i);
		   While (GetText(i,j)<>' ') and (i<80) do
		   begin
			  Hold := Hold + GetText(i,j);
			  Inc (I);
		   end;
		end;
		ReadLeft := Hold;
	end;

	function DMouse : String;
	begin
	  DMouse :='';
	  X2 := OldXPos;
	  Y2 := OldYPos;
	  OC := OldColor;

		GetMousePos(Xx, Yy, BtnStatus);
		{ X1 := Xx  div 8; }
		X1 := Xx;
			If X1<1  then X1 := 1;
			if X1>79 then X1 := 79;
		{ y1 := Yy  div 8; }
		Y1 := Yy;
			If Y1<1  then Y1 := 1;
			if Y1>79 then Y1 := 79;
		If (X2<>X1) or (Y2<>Y1) then
		begin
			 GotoXY (X1, Y1);
			 Cl := GetSColor(X1,Y1);
			 InvertColor (Cl);
			 Write (GetText(X1,Y1));
			 If X2>0 then
				DumpCursor;
			 OldXPos := X1;
			 OldYPos := Y1;
			 OldColor := cL;
		end;
		if BtnStatus >0 then
		   begin
			  DumpCursor;
			  DMouse := Chr(BTnStatus)+ReadLeft(X1,Y1);
		   end;

	end;

begin
     HoldX := WhereX;
     HoldY := WhereY;
     Data := Dmouse;
     GotoXY (HoldX, HoldY);
end;

function MouseX : Integer;
   var
      X, Y , B  : Integer;
begin
	GetMousePos (X,Y,B);
	MouseX := X
end;

function MouseY : Integer;
   var
      X, Y, B   : Integer;
begin
	GetMousePos (X,Y,B);
	MouseY := Y;
end;

function MouseButton1 : boolean;
   var
      X, Y, B   : Integer;
      B1, B2, B3: Boolean;
      D         : string;
begin
	GetMousePos (X,Y,B);
	D := Chr(B);
	SplitButtons (D,B1,B2,B3);
	MouseButton1 := B1;
end;

function MouseButton2 : boolean;
   var
      X, Y, B   : Integer;
      B1, B2, B3: Boolean;
      D         : string;
begin
	GetMousePos (X,Y,B);
	D := Chr(B);
	SplitButtons (D,B1,B2,B3);
	MouseButton2 := B2;
end;

function MouseButton3 : boolean;
   var
      X, Y, B   : Integer;
      B1, B2, B3: Boolean;
      D         : string;
begin
	GetMousePos (X,Y,B);
	D := Chr(B);
	SplitButtons (D,B1,B2,B3);
	MouseButton3 := B3;
end;

begin
	TurnMouseOff;
end.
