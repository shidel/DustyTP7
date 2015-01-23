{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$A+,B-,D-,E+,F-,G-,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
program Compute_Intrest;

  type
    Real = Extended;

  function RoundDollar ( var R : Real ) : boolean;
    var
      DR, FR : Real;
      S      : String;
      E      : Integer;
    begin
      RoundDollar := False;
      DR := R;
      Str ( R:1:0, S ); Val( S, DR, E );
      if E <> 0 then Exit;
      FR := R - DR;
      Str ( FR:1:2, S ); Val( S, FR, E );
      if E <> 0 then Exit;
      R := DR + FR;
      RoundDollar := True;
    end;

  procedure ReadDollar ( S : String; var R : Real );
    var
      E : Integer;
      T : String;
    begin
      repeat
        Write ( S );
        E := 1;
        ReadLn ( T );
        if T <> '' then
          begin
            Val(T, R, E);
            RoundDollar ( R );
          end;
      until (E = 0) and (R <> 0.0);
    end;

  procedure ReadReal ( S : String; var R : Real );
    var
      E : Integer;
      T : String;
    begin
      repeat
        Write ( S );
        E := 1;
        ReadLn ( T );
        if T <> '' then Val(T, R, E);
      until (E = 0) and (R <> 0.0);
    end;

  procedure ReadInteger ( S : String; var I : Integer );
    var
      E : Integer;
      T : String;
    begin
      repeat
        Write ( S );
        E := 1;
        ReadLn ( T );
        if T <> '' then Val(T, I, E);
      until (E = 0) and (I <> 0);
    end;

  function DollarStr ( R : Real; W : Byte ) : String;
    var
      S : String;
    begin
      Str ( R:W:2, S );
      DollarStr := S;
    end;

  function IntStr ( I : Integer; W : Byte) : String;
    var
      S : String;
    begin
      Str ( I:W, S );
      IntStr := S;
    end;

  procedure Compute;
    var
      Deposit      : Real;
      Balance      : Real;
      YearIntrest  : Real;
      IntrestRate  : Real;
      CompoundRate : Integer;
      TDays        : integer;
      Intrest      : Real;
      Year         : Integer;
      Days         : integer;
      WeekDay      : integer;
      I, J         : Integer;
    begin
      ReadDollar ( 'Weekly Deposit: ', Deposit );
      ReadReal   ( 'Annual Intrest Rate: ', IntrestRate );
      ReadInteger( 'Times Compounded Anually: ', CompoundRate );
      WriteLn;
      Year := 0;
      Balance := 0.0;
      Days    := 365 div CompoundRate;
      Intrest := (IntrestRate /100) / (365 / Days);
      WeekDay := 0;
      repeat
        YearIntrest := 0.0;
        if Year mod 4 = 0 then
          TDays := Days + 1
        else
          TDays := Days;
        for I := 1 to CompoundRate do
          begin
            For J := 1 to TDays do
              begin
                Inc(WeekDay);
                if WeekDay = 7 then
                  begin
                    Balance := Balance + Deposit;
                    WeekDay := 0;
                  end;
              end;
            YearIntrest := YearIntrest + (Balance * Intrest);
            RoundDollar ( YearIntrest );
            Balance := Balance + (Balance * Intrest);
            RoundDollar ( Balance );
          end;
        Inc(Year);
        Write ( 'Year', IntStr(Year, 3), ',  Balance: ', DollarStr(Balance, 12), ',  ' );
        Write ( 'Total Intrest: ', DollarStr ( YearIntrest, 10 ), ',  ');
        Write ( 'Weekly: ', DollarStr((Balance * (IntrestRate / 100))/ 52, 8) );
        WriteLn;
      until Year = 22;
    end;

begin
  Compute;
end.
