{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Clock;


interface
         function  Time                            : String;
         function  Date      (Tp : Integer)        : String;

         procedure WriteTime (X, Y     : Integer);
         procedure WriteDate (X, Y, Tp : Integer);

implementation

    uses QCrt, Dos;

function Time : String;
    procedure TimeComp;
        Var
           Hour, Minute, Second, Sec100 : Word;
           H, M, S, N : String[2];
           Pm : Boolean;
           T : String[15];

        begin
             Pm := False;
             GetTime (Hour, Minute, Second, Sec100);
             If Hour > 11  then Pm    := True;
             If Hour > 12  then Hour  := Hour - 12;
             If Hour =  0  then Hour  := 12;
             Str (Hour  :2, H);
             Str (Minute:2, M); If M[1] = ' ' then M[1] := '0';
             Str (Second:2, S); If S[1] = ' ' then S[1] := '0';
             Str (Sec100:2, N); If N[1] = ' ' then N[1] := '0';
             T := H + ':' + M + ':' + S + ' ';
             If Pm then
                T := T + 'pm'
             else
                T := T + 'am';
             Time := T;
        end;
    begin
         TimeComp;
    end;


function Date(Tp : Integer) : String;
         procedure DateComp;
                   const
                      ADays : array [0..6] of string[3] =
                        ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri' , 'Sat');
                      Days  : array [0..6] of string[9] =
                        ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                         'Thursday', 'Friday', 'Saturday');
                      AMon  : array [1..12] of string[3] =
                        ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                         'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
                      Month : array [1..12] of string[9] =
                        ('January', 'February', 'March', 'April', 'May',
                         'June', 'July', 'August', 'September', 'October',
                         'November', 'December');
                   var
                      Mon, Day, Year, WeekDay : Word;
                      H, S                    : String;

                   begin
                        GetDate (Year, Mon, Day, WeekDay);
                        Case Tp of
                             0 : begin
                                      Str (Mon, H);
                                      While Length(H)<2 do
                                            H := ' ' + H;
                                      S := H + '-';
                                      Str (Day, H);
                                      While Length(H)<2 do
                                            H := '0' + H;
                                      S := S + H + '-';
                                      Str(Year,H);
                                      S := S + H[3]+ H[4];
                                 end;
                             1 : begin
                                      S := ADays[WeekDay];
                                      S := S + ' ' + AMon[Mon];
                                      Str (Day, H);
                                      While Length(H)<3 do
                                            H := ' ' + H;
                                      S := S + H;
                                      Str (Year, H);
                                      S := S + ', '+ H;
                                 end;
                             2 : begin
                                      S := Days[WeekDay];
                                      S := S + ' ' + Month[Mon];
                                      Str (Day, H);
                                      S := S + ' ' + H;
                                      Str (Year, H);
                                      S := S + ', '+ H;
                                      While Length(S)<28 do
                                            S := ' ' + S;
                                 end;
                             else
                                 Date := '';
                        end;
                        Date := S;
                   end;
         begin
              Date := '';
              DateComp;
         end;
Procedure WriteTime(X, Y : Integer);
    Var
       HX, HY : Integer;
    begin
         HX := WhereX;
         HY := WhereY;
         GotoXY (X, Y);
         Write (' ', Time, ' ');
         GotoXY (HX,HY);
    end;
Procedure WriteDate(X, Y, Tp : Integer);
    Var
       HX, HY : Integer;
    begin
         HX := WhereX;
         HY := WhereY;
         GotoXY (X, Y);
         Write (' ', Date(Tp), ' ');
         GotoXY (HX,HY);
    end;
end.
