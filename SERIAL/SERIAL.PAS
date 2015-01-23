{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Serial;

  uses QCrtNM, Dos, DosExt, StrAsm;

  procedure Done(Code:integer);
    begin
      NormalCursor;
      CheckCursor := True;
      FWriteLn('');
      if Code <> 0 then Halt(Code);
    end;

  function ConvertHex(S : String; var Hex : longint) : boolean;
    const
      HexStr : String[20] = '0123456789ABCDEF';
    var
      I : byte;
      L1, L2 : LongInt;
      P : LongInt;
    begin
      ConvertHex := False;
      S := UCase(Trim(S));
      L1 := 0;
      L2 := 0;
      while Pos('-', S) <> 0 do Delete(S, Pos('-', S), 1);
      while Length(S) < 8 do S := '0' + S;
      if Length(S) > 8 then Exit;
      for I := 1 to 4 do
        if Pos(S[I], HexStr) <> 0 then
          begin
            P := LongInt(1) shl LongInt(16 - I * 4);
            Inc(L1, LongInt(LongInt(Pos(S[I], HexStr) - 1) * P))
          end
        else
          Exit;
      for I := 1 to 4 do
        if Pos(S[I + 4], HexStr) <> 0 then
          begin
            P := LongInt(1) shl LongInt(16 - I * 4);
            Inc(L2, LongInt(LongInt(Pos(S[I + 4], HexStr) - 1) * P))
          end
        else
          Exit;
      Hex := LongInt(Ptr(L1, L2));
      ConvertHex := True;
    end;

  procedure ChangeSerial(Drive : byte; Number : String);
    var
      Hex : LongInt;
      S   : String;
      Drv : String;
    begin
      if Drive = 0 then
        Drv := 'current disk'
      else
        Drv := 'disk in drive ' + Chr(Drive + 64);
      SetLogicalDrive(Drive);
      Hex := GetSerialNumber(Drive);
      if DosError <> 0 then
        begin
          FWriteLn('Could not read serial number from ' + Drv + '.');
          NormalCursor;
          Done(1);
        end;
      S := HexLong(Hex);
      Insert('-', S, 5);
      FWriteLn('Serial number for ' + Drv + ' is ' + S + '.');
      if Number = '' then
        begin
          FWrite('Enter new serial number:');
          ReadLn(Number);
        end;
      if Number = '' then
        begin
          FWriteLn('No serial number specified.');
          Done(1);
        end;
      if ConvertHex(Number, Hex) then
        begin
          Number := HexLong(Hex);
          Insert('-', Number, 5);
          SetSerialNumber(Drive, Hex);
          if DosError <> 0 then
            begin
              FWriteLn('Error changing serial number.');
              Done(1);
            end;
          FWriteLn('Serial number changed to ' + Number + '.');
        end
      else
        begin
          FWriteLn('Invalid serial number.');
          NormalCursor;
          Done(1);
        end;
    end;

  procedure Process;
    var
      Drive  : byte;
      Number : String;
      Param  : String;
    begin
      Drive  := 0;
      Number := '';
      if ParamCount = 1 then
        begin
          Param := UCase(ParamStr(1));
          if (Length(Param) > 1) and (Param[2] = ':') then
            begin
              Drive := Byte(Param[1]) - 64;
              if Length(Param) > 2 then
                Number := Copy(Param, 3, Length(Param));
            end
          else
            Number := Param;
        end
      else
        begin
          Param := UCase(ParamStr(1));
          Drive := Byte(Param[1]) - 64;
          Number := ParamStr(2);
        end;
      ChangeSerial(Drive, Number);
    end;


begin
  CheckCursor := False;
  HideCursor;
  if ParamCount = 0 then
    ChangeSerial(0, '')
  else
  if ParamCount > 2 then
    begin
      FWriteLn('Invalid parameter count.');
      Done(1);
    end
  else
    Process;
  Done(0);
end.
