{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Macros;

interface

  uses Dos, StrSize, StrAsm;

  const
    AppTitle   : String = 'application';
    TimeFormat : byte = 1;
    DateFormat : byte = 1;
{

MACROS:

  Strings Surrounded by % char are swapped with there environment variable.

  Strings Surrounded by $ char are swapped with application strings:

     App_Title   = Application Title;
     App_Dir     = Application Directory;
     App_Name    = Application File Name;
     App_Ext     = Application File Extention;
     Start_Dir   = Directory program was run from;
     Current_Dir = Current Directory;
     Temp_Dir    = Dos Temporary Path;
     Time        = Current Time;
     Date        = Current Date;
     MAXAVAIL    = Largest free memory block available to program
     MEMAVAIL    = Total free memory available to program

FORMATED STRINGS:

  A String passed as format data is a pascal string of pascal strings.  The
  strings are subsituted for there string reference in the source string.
  String references are &s0 &s1 ... &s9. Example:

  const
    S : String = #5'there'#5'Hello'#3'you';

  begin
    S := FormatStr('&s1, &s0 my friend. How are &s2 today?', S);
  end.

  String "S" would become:
    'Hello, there my friend. How are you today?'

}
  function ExpandDir(Path : PathStr) : String;
  function ExpandStr(Macro : String) : String;

  function FormatTimeStr(Hour, Min, Sec, Hun : word; Format : byte) : String;
  function FormatDateStr(Month, Day, Year, DayOfWeek : word; Format : byte) : String;
  function FormatStr(S : String; Adr : String) : String;
  function BuildStr(Append : String) : String;

implementation

  var
    AppDir    : DirStr;
    AppName   : NameStr;
    AppExt    : ExtStr;
    FirstDir  : PathStr;

  function ExpandDir(Path : PathStr) : String;
    begin
      if (Length(Path) > 3) and (Path[Length(Path)] <> '\') then
        ExpandDir := Path + '\'
      else
        ExpandDir := Path
    end;

  function FormatTimeStr(Hour, Min, Sec, Hun : word; Format : byte) : String;
    var
      PM : boolean;
      S : String;
    begin
      case Format of
        1 : begin
          if Hour > 11 then PM := True else PM := False;
          if Hour > 12 then Dec(Hour, 12);
          if Hour = 0  then Hour := 12;
          S := IntStr(Hour) + ':' +
              ZeroPad(IntStr(Min), 2) + ':' +
              ZeroPad(IntStr(Sec), 2) + ' ';
          if PM then
            AddStr(S, 'pm')
          else
            AddStr(S, 'am');
        end;
      else
        S := IntStr(Hour) + ':' +
          ZeroPad(IntStr(Min), 2) + ':' +
          ZeroPad(IntStr(Sec), 2);
      end;
      FormatTimeStr := S;
    end;

  function FormatDateStr(Month, Day, Year, DayOfWeek : word; Format : byte) : String;
    const
      Data : array[1..2] of record
        Month : Array[1..12] of Str9;
        Day   : Array[1..7] of Str9;
      end = (
      ( Month:('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
                'Oct', 'Nov', 'Dec');
        Day:('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')),
      ( Month:('January', 'February', 'March', 'April', 'May', 'June',
               'July', 'August', 'September', 'October', 'November', 'December');
        Day:('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
             'Saturday')));
    var
      S : String;
    begin
      case Format of
        1, 2 : begin
          if DayOfWeek <> 0 then
            S := Data[Format].Day[DayOfWeek] + ' '
          else
            S := '';
          AddStr(S, Data[Format].Month[Month] + ' ');
          AddStr(S, IntStr(Day) + ', ');
          AddStr(S, IntStr(Year));
        end;
        3 : begin
          if DayOfWeek <> 0 then
            S := Data[1].Day[DayOfWeek] + ' '
          else
            S := '';
          AddStr(S, Data[2].Month[Month] + ' ');
          AddStr(S, IntStr(Day) + ', ');
          AddStr(S, IntStr(Year));
        end;
        4 : begin
          if DayOfWeek <> 0 then
            S := Data[2].Day[DayOfWeek] + ' '
          else
            S := '';
          AddStr(S, Data[1].Month[Month] + ' ');
          AddStr(S, IntStr(Day) + ', ');
          AddStr(S, IntStr(Year));
        end;
      else
        S := IntStr(Month) + '/' +
          ZeroPad(IntStr(Day),2) + '/' +
          ZeroPad(IntStr(Year mod 100), 2);
      end;
      FormatDateStr := S;
    end;

  function TimeStr(Format : byte) : String;
    var
      Hour, Min, Sec, Hun : word;
    begin
      GetTime(Hour, Min, Sec, Hun);
      TimeStr := FormatTimeStr(Hour, Min, Sec, Hun, Format);
    end;

  function DateStr(Format : byte) : String;
    var
      Year, Month, Day, DayofWeek : word;
    begin
      GetDate(Year, Month, Day, DayOfWeek);
      DateStr := FormatDateStr(Month,Day,Year,DayOfWeek + 1,Format);
    end;

  function ExpandStr(Macro : String) : String;
    var
      S, T, P : String;
      I, J    : integer;
    begin
      I := 0;
      S := '';
      while I < Length(Macro) do
        begin
          Inc(I);
          if Macro[I] = '%' then
            begin
              J := NextPos('%', Macro, I + 1);
              if J > I then
                begin
                  T := Copy(Macro, I + 1, J - I - 1);
                  AddStr(S, GetEnv(T));
                  I := J;
                end
              else
                AddChr(S, '%');
            end
          else
          if Macro[I] = '$' then
            begin
              J := NextPos('$', Macro, I + 1);
              if J > I then
                begin
                  T := UCase(Copy(Macro, I + 1, J - I - 1));
                  if T = 'APP_TITLE'   then AddStr(S, AppTitle) else
                  if T = 'APP_DIR'     then AddStr(S, ExpandDir(AppDir)) else
                  if T = 'APP_NAME'    then AddStr(S, AppName) else
                  if T = 'APP_EXT'     then AddStr(S, AppExt) else
                  if T = 'START_DIR'   then AddStr(S, ExpandDir(FirstDir)) else
                  if T = 'CURRENT_DIR' then
                    begin
                      GetDir(0, P);
                      AddStr(S, ExpandDir(P));
                    end
                  else
                  if T = 'TEMP_DIR' then
                    begin
                      P := GetEnv('TEMP');
                      if P = '' then P := GetEnv('TMP');
                      if P = '' then P := FirstDir;
                      AddStr(S, ExpandDir(P));
                    end
                  else
                  if T = 'TIME' then AddStr(S, TimeStr(TimeFormat)) else
                  if T = 'DATE' then AddStr(S, DateStr(DateFormat)) else
                  if T = 'MAXAVAIL' then AddStr(S, IntStr(MaxAvail)) else
                  if T = 'MEMAVAIL' then AddStr(S, IntStr(MemAvail)) else
                    AddStr(S, '$' + T + '$');
                  I := J;
                end
            end
          else
            AddChr(S, Macro[I]);
        end;
      ExpandStr := S;
    end;

  function FormatStr(S : String; Adr : String) : String;
    var
      P : Pointer;
      I : byte;
      J : byte;
      C : byte;
      T : Byte;

    function Replace(S1 : String) : boolean;
      begin
        I := Pos(S1, S);
        if I <> 0 then
          begin
            Delete(S, I, Length(S1));
            if (J < C) and (C <> 0) then Insert(String(P^), S, I);
          end;
        Replace := I <> 0;
      end;

    begin
      C := 0;
      I := 1;
      P := Ptr(Seg(Adr), Ofs(Adr) + 1);
      while I <= Length(String(Adr)) do
        begin
          Inc(C);
          Inc(I, Length(String(P^)) + 1);
          P := Ptr(Seg(Adr), Ofs(Adr) + I);
        end;
      P := Ptr(Seg(Adr), Ofs(Adr) + 1);
      for J := 0 to 9 do
        begin
          while Replace('&s' + IntStr(J)) do;
          P := Ptr(Seg(P^), Ofs(P^) + Length(String(P^)) + 1);
        end;
      FormatStr := S;
    end;

  function BuildStr(Append : String) : String;
    begin
      BuildStr := Chr(Length(Append)) + Append;
    end;

  procedure InitUnit;
    begin
      FSplit(ParamStr(0), AppDir, AppName, AppExt);
      GetDir(0, FirstDir);
    end;

begin
  InitUnit;
end.