{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Files; { version 6.01 }
{$D-,Y-,L-,I-}
{ This unit contains objects for reading/writing disk files. }

interface

  uses ErConst, DosVer;

  const
    { File status flags }
    flInvalid  = $0000; { Is Not Valid }
    flAssigned = $0001; { IsAssigned }
    flOpened   = $0002; { IsOpen }
    flFlush    = $0004; { Needs Flushed }
    flErase    = $0008; { Erase when disposed (not advised) }
    flError    = $0010; { Is Error Code }
    flRead     = $0020; { File can be read }
    flWrite    = $0040; { File can be written }
    flRandom   = $0060; { File can be read or written }

    { SetIOResult return commands }
    fcOK       = $00;
    fcIgnore   = $01;
    fcRetry    = $02;
    fcAbort    = $03;

  type
    PFile = ^TFile;
    TFile = object
        Ptr    : LongInt;
        Mode   : word;
        Flags  : word;
        Name   : String;
        Result : integer;
      constructor Init;
      destructor  Done; virtual;
      procedure Assign( AFileName : String ); virtual;
      procedure BlockRead(const ABuf; ACount: Word; var AResult: Word); virtual;
      procedure BlockWrite(const ABuf; ACount: Word; var AResult: Word); virtual;
      procedure Close; virtual;
      procedure Erase; virtual;
      function  FileSize: Longint; virtual;
      procedure Flush; virtual;
      procedure Rename( ANewName : String ); virtual;
      procedure Reset; virtual;
      procedure Rewrite; virtual;
      procedure Seek(AFilePos: Longint); virtual;
      procedure Truncate; virtual;
      function  SetIOResult ( AIOResult : integer ) : byte; virtual;
    { the following procedures/functions should not need to be overridden }
      procedure Append;
      procedure Copy(var AFile : PFile; ACount: LongInt);
      function  Sof: Boolean;
      function  Eof: Boolean;
      function  FilePos: Longint;
      function  IOResult: Integer;
      function  SeekSof: Boolean;
      function  SeekEof: Boolean;
      procedure SetFileMode ( AMode : word );
    { Should never, ever need overridden (they all call BlockRead) }
      procedure Insert(ACount : longint);
      procedure Delete(ACount : longint);
      procedure ReadRecord    (const AAdr; ASize : word);
      procedure WriteRecord   (const AAdr; ASize : word);
      procedure ReadChar      (const AChr );
      procedure WriteChar     (const AChr );
      procedure ReadBoolean   (const ABoolean);
      procedure WriteBoolean  (const ABoolean);
      procedure ReadByteBool  (const AByteBool);
      procedure WriteByteBool (const AByteBool);
      procedure ReadWordBool  (const AWordBool);
      procedure WriteWordBool (const AWordBool);
      procedure ReadLongBool  (const ALongBool);
      procedure WriteLongBool (const ALongBool);
      procedure ReadByte      (const AByte);
      procedure WriteByte     (const AByte);
      procedure ReadWord      (const AWord);
      procedure WriteWord     (const AWord);
      procedure ReadShortInt  (const AShortInt);
      procedure WriteShortInt (const AShortInt);
      procedure ReadInteger   (const AInteger);
      procedure WriteInteger  (const AInteger);
      procedure ReadLongInt   (const ALongInt);
      procedure WriteLongInt  (const ALongInt);
      procedure ReadReal      (const AReal);
      procedure WriteReal     (const AReal);
      procedure ReadSingle    (const ASingle);
      procedure WriteSingle   (const ASingle);
      procedure ReadDouble    (const ADouble);
      procedure WriteDouble   (const ADouble);
      procedure ReadComp      (const AComp);
      procedure WriteComp     (const AComp);
      procedure ReadExtended  (const AExtended);
      procedure WriteExtended (const AExtended);
      procedure ReadString  (const AString; AStrSize : word);
      procedure WriteString (const AString; AStrSize : word);
      function  GetString   : String;
      procedure PutString   (const AString);
    { Text files }
      function  Soln: boolean;
      function  Eoln: Boolean;
      function  SeekSoln: boolean;
      function  SeekEoln: Boolean;
      function  SeekLn ( ANumber : LongInt ) : boolean;
      procedure Read  ( const AStr; AMax : word );
      procedure Write ( const AStr );
      procedure ReadLn  ( const AStr; AMax : word );
      procedure WriteLn ( const AStr );
      function  LengthLn : word;
      procedure InsertLn ( ALen : word );
      procedure DeleteLn;
      procedure ResizeLn ( ALen : word );
    end;

    PDosFile = ^TDosFile;
    TDosFile = object( TFile )
        FRec : File;
      constructor Init;
      destructor  Done; virtual;
      procedure Assign( AFileName : String ); virtual;
      procedure BlockRead(const ABuf; ACount: Word; var AResult: Word); virtual;
      procedure BlockWrite(const ABuf; ACount: Word; var AResult: Word); virtual;
      procedure Close; virtual;
      procedure Erase; virtual;
      function FileSize: Longint; virtual;
      procedure Flush; virtual;
      procedure Rename( ANewName : String ); virtual;
      procedure Reset; virtual;
      procedure Rewrite; virtual;
      procedure Seek(AFilePos: Longint); virtual;
      procedure Truncate; virtual;
    end;

implementation

  const
    CRLF : String[2] = #13#10;

  var
    Buf : array[0..511] of byte;

  constructor TFile.Init;
    begin
      Ptr := 0;
      Mode := 0;
      Name := '';
      Flags := flInvalid;
      SetIOResult(erNone);
    end;

  destructor TFile.Done;
    begin
      if Flags and flOpened = flOpened then Close;
      if Flags and flErase = flErase then Erase;
    end;

  procedure TFile.Assign( AFileName : String );
    begin
      if (Flags and flOpened = flOpened) then
        SetIOResult(erFile_access_denied)
      else
        begin
          SetIOResult ( erNone );
          Name := AFileName;
        end;
    end;

  procedure TFile.BlockRead(const ABuf; ACount: Word; var AResult: Word);
    begin
      AResult := 0;
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened ) then
        SetIOResult(erFile_not_open)
      else
      if (Flags and flRead <> flRead) then
        SetIOResult(erFile_not_open_for_input)
      else
        SetIOResult ( erNone );
    end;

  procedure TFile.BlockWrite(const ABuf; ACount: Word; var AResult: Word);
    begin
      AResult := 0;
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
      if (Flags and flWrite <> flWrite) then
        SetIOResult(erFile_not_open_for_output)
      else
        SetIOResult ( erNone );
    end;

  procedure TFile.Close;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
        begin
          SetIOResult ( erNone );
          if Flags and flFlush = flFlush then Flush;
        end;
    end;

  procedure TFile.Erase;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened = flOpened) then
        SetIOResult(erFile_access_denied)
      else
        SetIOResult ( erNone );
    end;

  function TFile.FilePos: Longint;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
        begin
          SetIOResult( erNone );
          FilePos := Ptr;
        end;
    end;

  function TFile.FileSize: Longint;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
        begin
          SetIOResult ( erNone );
          FileSize := 0;
        end;
    end;

  procedure TFile.Flush;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
      if (Flags and flWrite <> flWrite) then
        SetIOResult(erFile_not_open_for_output)
      else
        SetIOResult ( erNone );
    end;

  function TFile.IOResult: Integer;
    begin
      IOResult := Result;
      SetIOResult(erNone);
    end;

  function TFile.SetIOResult ( AIOResult : integer ) : byte;
    begin
      if AIOResult <> erNone then
        Flags := Flags or flError
      else
        Flags := Flags and (not flError);
      Result := AIOResult;
      case AIOResult of
        erNone : SetIOResult := fcOK;
      else
        SetIOResult := fcAbort;
        {$IFOPT I+}
        RunError(AIOResult);
        {$ENDIF}
      end;
    end;

  procedure TFile.Rename;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
        SetIOResult ( erNone );
    end;

  procedure TFile.Reset;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
        begin
          SetIOResult ( erNone );
          if (Flags and flOpened = flOpened) then
            Close;
          if (Flags and flError <> flError) then
            SetFileMode ( FileMode );
        end;
    end;

  procedure TFile.Rewrite;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
        begin
          SetIOResult ( erNone );
          if (Flags and flOpened = flOpened) then
            Close;
          if (Flags and flError <> flError) then
            SetFileMode ( (FileMode and (not 3)) or 2 );
        end;
    end;

  procedure TFile.Seek(AFilePos: Longint);
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
        SetIOResult ( erNone );
    end;

  procedure TFile.Truncate;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
      if (Flags and flOpened <> flOpened) then
        SetIOResult(erFile_not_open)
      else
        SetIOResult ( erNone );
    end;

  procedure TFile.Append;
    begin
      if (Flags and flAssigned <> flAssigned) then
        SetIOResult(erFile_not_assigned)
      else
        begin
          SetIOResult ( erNone );
          if (Flags and flOpened = flOpened) then
            Close;
          if (Flags and flError <> flError) then
            SetFileMode ( (FileMode and (not 3)) or 1 );
        end;
    end;

  procedure TFile.Copy(var AFile : PFile; ACount: LongInt);
    var
      RCount, WCount : word;
    begin
      repeat
        BlockRead(Buf, Sizeof(Buf), RCount);
        if (Flags and flError <> flError) then
          AFile^.BlockWrite(Buf, RCount, WCount);
      until Eof or (Flags and flError = flError) or
        (AFile^.Flags and flError = flError) or (RCount <> Sizeof(Buf)) or
        (RCount <> WCount);
    end;

  function TFile.Sof: Boolean;
    begin
      Sof := (Ptr = 0 );
    end;

  function TFile.Eof: Boolean;
    begin
      Eof := (FileSize <= Ptr );
    end;

  function TFile.SeekSof: Boolean;
    begin
      Seek( 0 );
      SeekSof := Flags and flError <> flError;
    end;

  function TFile.SeekEof: Boolean;
    var
      Size : LongInt;
    begin
      Size := FileSize;
      if (Flags and flError <> flError) then
        Seek( Size );
      SeekEof := Flags and flError <> flError;
    end;

  procedure TFile.SetFileMode ( AMode : word );
    begin
      Mode := AMode;
      Flags := Flags and (Not flRandom);
      case Mode and 2 of
        0 : Flags := Flags or flRead;
        1 : Flags := Flags or flWrite;
        2 : Flags := Flags or flRandom;
      end;
    end;

  procedure TFile.Insert(ACount : longint);
    var
      Size,
      Count  : word;
      OldPtr : LongInt;
      CurPtr : LongInt;
    begin
      OldPtr := FilePos;
      if (Flags and flError = flError) or (ACount < 1) then Exit;
      CurPtr := FileSize;
      if (Flags and flError <> flError) then
        repeat
          Size := Sizeof(Buf);
          if CurPtr - Size < OldPtr then
            Size := CurPtr - OldPtr;
          Dec(CurPtr, Size);
          Seek(CurPtr);
          if (Flags and flError <> flError) then BlockRead(Buf, Size, Count);
          if (Flags and flError <> flError) then Seek(CurPtr + ACount);
          if (Flags and flError <> flError) then BlockWrite(Buf, Size, Count);
        until (CurPtr = OldPtr) or (Flags and flError = flError);
      if (Flags and flError <> flError) then Seek(OldPtr);
    end;

  procedure TFIle.Delete(ACount : longint);
    var
      Size,
      Count  : word;
      OldPtr : LongInt;
      CurPtr : LongInt;
      FSize  : LongInt;
    begin
      OldPtr := FilePos;
      if (Flags and flError = flError) or (ACount < 1) then Exit;
      FSize := FileSize;
      CurPtr := OldPtr + ACount;
      if (Flags and flError <> flError) then
        repeat
          Size := Sizeof(Buf);
          if CurPtr + Size > FSize then
            Size := FSize - CurPtr;
          Seek(CurPtr);
          if (Flags and flError <> flError) then BlockRead(Buf, Size, Count);
          if (Flags and flError <> flError) then Seek(CurPtr - ACount);
          if (Flags and flError <> flError) then BlockWrite(Buf, Size, Count);
          Inc(CurPtr, Size);
        until (CurPtr >= FSize) or (Flags and flError = flError);
      if (Flags and flError <> flError) then Truncate;
      if (Flags and flError <> flError) then Seek(OldPtr);
    end;

  procedure TFile.ReadRecord (const AAdr; ASize : word);
    var
      Count : word;
    begin
      BlockRead ( AAdr, ASize, Count );
      if (Flags and flError <> flError) and (Count <> ASize) then
        SetIOResult(erDevice_Read_Fault);
    end;

  procedure TFile.WriteRecord (const AAdr; ASize : word);
    var
      Count : word;
    begin
      BlockWrite ( AAdr, ASize, Count );
      if (Flags and flError <> flError) and (Count <> ASize) then
        SetIOResult(erDevice_Write_Fault);
    end;

  procedure TFile.ReadChar ( const AChr );
    begin
      ReadRecord(AChr, Sizeof(Char));
    end;

  procedure TFile.WriteChar ( const AChr );
    begin
      WriteRecord(AChr, Sizeof(Char));
    end;

  procedure TFile.ReadBoolean   (const ABoolean);
    begin
      ReadRecord(ABoolean, Sizeof(Boolean));
    end;

  procedure TFile.WriteBoolean  (const ABoolean);
    begin
      WriteRecord(ABoolean, Sizeof(Boolean));
    end;

  procedure TFile.ReadByteBool  (const AByteBool);
    begin
      ReadRecord(AByteBool, Sizeof(ByteBool));
    end;

  procedure TFile.WriteByteBool (const AByteBool);
    begin
      WriteRecord(AByteBool, Sizeof(ByteBool));
    end;

  procedure TFile.ReadWordBool  (const AWordBool);
    begin
      ReadRecord(AWordBool, Sizeof(WordBool));
    end;

  procedure TFile.WriteWordBool (const AWordBool);
    begin
      WriteRecord(AWordBool, Sizeof(WordBool));
    end;

  procedure TFile.ReadLongBool  (const ALongBool);
    begin
      ReadRecord(ALongBool, Sizeof(LongBool));
    end;

  procedure TFile.WriteLongBool (const ALongBool);
    begin
      WriteRecord(ALongBool, Sizeof(LongBool));
    end;

  procedure TFile.ReadByte      (const AByte);
    begin
      ReadRecord(AByte, Sizeof(Byte));
    end;

  procedure TFile.WriteByte     (const AByte);
    begin
      WriteRecord(AByte, Sizeof(Byte));
    end;

  procedure TFile.ReadWord      (const AWord);
    begin
      ReadRecord(AWord, Sizeof(Word));
    end;

  procedure TFile.WriteWord     (const AWord);
    begin
      WriteRecord(AWord, Sizeof(Word));
    end;

  procedure TFile.ReadShortInt  (const AShortInt);
    begin
      ReadRecord(AShortInt, Sizeof(ShortInt));
    end;

  procedure TFile.WriteShortInt (const AShortInt);
    begin
      WriteRecord(AShortInt, Sizeof(ShortInt));
    end;

  procedure TFile.ReadInteger   (const AInteger);
    begin
      ReadRecord(AInteger, Sizeof(Integer));
    end;

  procedure TFile.WriteInteger  (const AInteger);
    begin
      WriteRecord(AInteger, Sizeof(Integer));
    end;

  procedure TFile.ReadLongInt   (const ALongInt);
    begin
      ReadRecord(ALongInt, Sizeof(LongInt));
    end;

  procedure TFile.WriteLongInt  (const ALongInt);
    begin
      WriteRecord(ALongInt, Sizeof(LongInt));
    end;

  procedure TFile.ReadReal      (const AReal);
    begin
      ReadRecord(AReal, Sizeof(Real));
    end;

  procedure TFile.WriteReal     (const AReal);
    begin
      WriteRecord(AReal, Sizeof(Real));
    end;

  procedure TFile.ReadSingle    (const ASingle);
    begin
      ReadRecord(ASingle, Sizeof(Single));
    end;

  procedure TFile.WriteSingle   (const ASingle);
    begin
      WriteRecord(ASingle, Sizeof(Single));
    end;

  procedure TFile.ReadDouble    (const ADouble);
    begin
      ReadRecord(ADouble, Sizeof(Double));
    end;

  procedure TFile.WriteDouble   (const ADouble);
    begin
      WriteRecord(ADouble, Sizeof(Double));
    end;

  procedure TFile.ReadComp      (const AComp);
    begin
      ReadRecord(AComp, Sizeof(Comp));
    end;

  procedure TFile.WriteComp     (const AComp);
    begin
      WriteRecord(AComp, Sizeof(Comp));
    end;

  procedure TFile.ReadExtended  (const AExtended);
    begin
      ReadRecord(AExtended, Sizeof(Extended));
    end;

  procedure TFile.WriteExtended (const AExtended);
    begin
      WriteRecord(AExtended, Sizeof(Extended));
    end;

  procedure TFile.ReadString  (const AString; AStrSize : word);
    begin
      ReadRecord(AString, Sizeof(String));
    end;

  procedure TFile.WriteString (const AString; AStrSize : word);
    begin
      WriteRecord(AString, Sizeof(String));
    end;

  function TFile.GetString : String;
    var
      Str : String;
    begin
      ReadByte(Str[0]);
      if (Flags and flError <> flError) then
        ReadRecord(Str[1], Byte(Str[0]));
      if (Flags and flError <> flError) then
        GetString := Str
      else
        GetString := '';
    end;

  procedure TFile.PutString (const AString);
    begin
      WriteRecord(AString, Length(String(AString)) + 1);
    end;

  { Text files }
  function TFile.Soln: Boolean;
    var
      Test  : word;
      Count : word;
      P     : LongInt;
    begin
      Soln := False;
      P := FilePos;
      if (Flags and flError = flError) then Exit;
      case P of
        1 : Exit;
        0 : Soln := True;
      else
        Seek(P - 2);
        if (Flags and flError <> flError) then
          BlockRead ( Test, Sizeof(Test), Count );
        Soln := (Count = 2) and (Test = $0A0D) and
        (Flags and flError <> flError);
      end;
    end;

  function TFile.EoLn: Boolean;
    var
      Test  : word;
      Count : word;
      P     : LongInt;
    begin
      EoLn := False;
      P := FilePos;
      if (Flags and flError = flError) then Exit;
      BlockRead ( Test, Sizeof(Test), Count );
      Eoln := (Count = 2) and (Test = $0A0D) and
        (Flags and flError <> flError);
      Seek(P);
    end;

  function TFIle.SeekSoln: Boolean;
    var
      SLn : boolean;
    begin
      SetIOResult ( erNone );
      repeat
        SLn := Soln;
        if (Flags and flError <> flError) and (Not SLn) then
          Seek(Ptr - 1);
      until SLn or (Flags and flError = flError);
      SeekSoln := Soln;
    end;

  function TFIle.SeekEoln: Boolean;
    var
      EndLn, EndF : boolean;
    begin
      SetIOResult ( erNone );
      repeat
        EndLn := Eoln;
        if (Flags and flError <> flError) then EndF  := Eof;
        if (Flags and flError <> flError) and (Not EndLn) and (Not EndF) then
          Seek(Ptr + 1);
      until EndLn or EndF or (Flags and flError = flError);
      SeekEoln := Eoln;
    end;

  procedure TFile.Read ( const AStr; AMax : word );
    var
      P : ^String;
      I : word;
      C : Char;
    begin
      P := @AStr;
      I := 0;
      P^[0] := #0;
      while (Not EOF) and (Not Eoln) and (Flags and flError <> flError) and (I < AMax) do
        begin
          ReadRecord(C, Sizeof(C));
          if (Flags and flError <> flError) then
            begin
              Inc(I);
              if I <= 255 then
                begin
                  P^[0] := Char(I);
                  P^[I] := C;
                end;
            end;
        end;
    end;

  procedure TFile.Write ( const AStr );
    begin
      WriteRecord(String(AStr)[1], Length(String(AStr)));
    end;

  procedure TFile.ReadLn ( const AStr; AMax : word );
    var
      P : ^String;
      I : word;
      C : Char;
    begin
      P := @AStr;
      I := 0;
      P^[0] := #0;
      while (Not EOF) and (Not Eoln) and (Flags and flError <> flError) do
        begin
          ReadRecord(C, Sizeof(C));
          if (Flags and flError <> flError) and (I < AMax) then
            begin
              Inc(I);
              if I <= 255 then
                begin
                  P^[0] := Char(I);
                  P^[I] := C;
                end;
            end;
        end;
      if (Flags and flError <> flError) and (Not EOF) then ReadRecord ( I, Sizeof(I) );
    end;

  procedure TFile.WriteLn ( const AStr );
    const
      CRLF : word = $0A0D;
    begin
      WriteRecord(String(AStr)[1], Length(String(AStr)));
      if Flags and flError <> flError then WriteWord ( CRLF );
    end;

  function TFile.LengthLn : word;
    var
      OPtr : longInt;
      SPtr : longInt;
      EPtr : longInt;
    begin
      LengthLn := 0;
      OPtr := FilePos;
      if (Flags and flError <> flError) then SeekSoln;
      if (Flags and flError <> flError) then SPtr := FilePos;
      if (Flags and flError <> flError) then SeekEoln;
      if (Flags and flError <> flError) then EPtr := FilePos;
      if (Flags and flError <> flError) then Seek(OPtr);
      if (Flags and flError <> flError) then LengthLn := EPtr - SPtr;
    end;

  procedure TFile.InsertLn ( ALen : word );
    var
      OPtr : longInt;
    begin
      SeekSoln;
      if (Flags and flError <> flError) then OPtr := FilePos;
      if (Flags and flError <> flError) then Insert(ALen + 2);
      if (Flags and flError <> flError) then Seek(OPtr + ALen);
      if (Flags and flError <> flError) then Write(CRLF);
      if (Flags and flError <> flError) then Seek(OPtr);
    end;

  procedure TFile.DeleteLn;
    var
      OLen : word;
      OPtr : LongInt;
    begin
      SeekSoln;
      if (Flags and flError <> flError) then OPtr := FilePos;
      if (Flags and flError <> flError) then OLen := LengthLn;
      if (Flags and flError <> flError) then Delete(OLen + 2);
      if (Flags and flError <> flError) then Seek(OPtr);
    end;

  procedure TFile.ResizeLn ( ALen : word );
    var
      OLen : word;
      OPtr : LongInt;
    begin
      OLen := LengthLn;
      if (Flags and flError <> flError) then
        begin
          if OLen < ALen then
            begin
              SeekSoln;
              if (Flags and flError <> flError) then OPtr := FilePos;
              if (Flags and flError <> flError) then Seek(OPtr + OLen);
              if (Flags and flError <> flError) then Insert(ALen - OLen);
              if (Flags and flError <> flError) then SeekSoln;
            end
          else
          if OLen > ALen then
            begin
              SeekSoln;
              if (Flags and flError <> flError) then OPtr := FilePos;
              if (Flags and flError <> flError) then Seek(OPtr + ALen);
              if (Flags and flError <> flError) then Delete(OLen - ALen);
              if (Flags and flError <> flError) then Seek(OPtr);
            end
          else
            SeekSoln;
        end;
    end;

  function TFile.SeekLn ( ANumber : LongInt ) : boolean;
    var
      I : LongInt;
      S : String[1];
    begin
      SeekSof;
      for I := 1 to ANumber - 1 do
        if (Flags and flError <> flError) then
          ReadLn ( S, 0 );
      SeekLn := (Flags and flError <> flError);
    end;
{ *** TDosFile *** }
  constructor TDosFile.Init;
    begin
      inherited Init;
    end;

  destructor  TDosFile.Done;
    begin
      inherited Done;
    end;

  procedure TDosFile.Assign( AFileName : String );
    var
      Action : byte;
    begin
      inherited Assign(AFileName);
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Assign(FRec, AFileName);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags or flAssigned;
        end;
    end;

  procedure TDosFile.BlockRead(const ABuf; ACount: Word; var AResult: Word);
    var
      P : Pointer;
      Action : byte;
    begin
      inherited BlockRead(ABuf, ACount, AResult);
      if (Flags and flError <> flError) then
        begin
          repeat
            P := @ABuf;
            System.BlockRead(FRec, P^, ACount, AResult);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then Inc(Ptr, AResult)
        end;
    end;

  procedure TDosFile.BlockWrite(const ABuf; ACount: Word; var AResult: Word);
    var
      P : Pointer;
      Action : byte;
    begin
      inherited BlockWrite(ABuf, ACount, AResult);
      if (Flags and flError <> flError) then
        begin
          repeat
            P := @ABuf;
            System.BlockWrite(FRec, P^, ACount, AResult);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then Inc(Ptr, AResult);
        end;
    end;


  procedure TDosFile.Close;
    var
      Action : byte;
    begin
      inherited Close;
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Close(FRec);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags and (Not flOpened);
          if (Action <> fcAbort) then Ptr := 0;
        end;
    end;

  procedure TDosFile.Erase;
    var
      Action : byte;
    begin
      inherited Erase;
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Erase(FRec);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
        end;
    end;

  function TDosFile.FileSize: Longint;
    var
      Action : byte;
    begin
      inherited FileSize;
      if (Flags and flError <> flError) then
        begin
          repeat
            FileSize := System.FileSize(FRec);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
        end;
    end;

  procedure TDosFile.Flush;
    begin
      inherited Flush;
      if (Flags and flError <> flError) then
        begin
          Flags := Flags and (Not flFlush);
        end;
    end;


  procedure TDosFile.Rename( ANewName : String );
    var
      Action : byte;
    begin
      inherited Rename(ANewName);
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Rename(FRec, ANewName);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Name := ANewName;
        end;
    end;

  procedure TDosFile.Reset;
    var
      Action : byte;
    begin
      inherited Reset;
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Reset(FRec, 1);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags or flOpened;
          if (Action <> fcAbort) then Ptr := 0;
        end;
    end;

  procedure TDosFile.Rewrite;
    var
      Action : byte;
    begin
      inherited Rewrite;
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Rewrite(FRec, 1);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags or flOpened;
          if (Action <> fcAbort) then Ptr := 0;
        end;
    end;

  procedure TDosFile.Seek(AFilePos: Longint);
    var
      Action : byte;
    begin
      inherited Seek(AFilePos);
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Seek(FRec, AFilePos);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags or flOpened;
          if (Action <> fcAbort) then Ptr := AFilePos;
        end;
    end;

  procedure TDosFile.Truncate;
    var
      Action : byte;
    begin
      inherited Truncate;
      if (Flags and flError <> flError) then
        begin
          repeat
            System.Truncate(FRec);
            Action := SetIOResult(System.IOResult);
          until (Action <> fcRetry);
          if (Action <> fcAbort) then
            Flags := Flags or flOpened;
        end;
    end;

end.

