{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Files;  { version 5.12 }

{ This unit contains object style file handling routines for random access
  files. }

interface

  uses Dos;

  const
    { DOS file attributes constants }
    faReadOnly   = $01;
    faHidden     = $02;
    faSystem     = $04;
    faVolumeID   = $08;
    faDirectory  = $10;
    faArchive    = $20;
    faAnyFile    = $3F;

    { File mode constants }
    fmReadOnly   = $00;
    fmWriteOnly  = $01;
    fmReadWrite  = $02;

    { File error action constants }
    acAbort = $01;
    acIgnore = $02;
    acRetry = $04;

  type
    PFile = ^TFile;
    TFile = object
      constructor Init;
      destructor Done; virtual;
      function ErrorHandler ( ACode : word; AAction : byte ) : byte; virtual;
      function IOResult : integer; virtual;
      procedure SetIOResult ( AIOResult : integer ); virtual;
      function Assign ( AFIleName : OpenString ) : boolean; virtual;
      function FileName : string; virtual;
      function FileExist : boolean; virtual;
      function Reset : boolean; virtual;
      function ReWrite : boolean; virtual;
      function Close : boolean; virtual;
      function Truncate : boolean; virtual;
      function Flush : boolean; virtual;
      function FileSize : longint; virtual;
      function FilePos : longint; virtual;
      function Erase : boolean; virtual;
      function Rename ( AFileName : OpenString ) : boolean; virtual;
      function Seek ( APosition : LongInt ) : boolean; virtual;
      function BlockRead (const AAdr; ASize : word; var ACount : word ) : boolean; virtual;
      function BlockWrite (const AAdr; ASize : word; var ACount : word ) : boolean; virtual;
      function GetFAttr ( var AAttr : word ) : boolean; virtual;
      function SetFAttr ( AAttr : word ) : boolean; virtual;
      function GetFTime ( var ATime : LongInt ) : boolean; virtual;
      function SetFTime ( ATime : LongInt ) : boolean; virtual;
      function GetSearchRec ( var ASearchRec : SearchRec ) : boolean; virtual;

      { This procedures should rarely need overridden. }
      function Open : boolean; virtual;
      function Create : boolean; virtual;
      function EOF : boolean; virtual;
      function SeekEOF : boolean; virtual;

      { Record variable types }
      function ReadRecord    (const AAdr; ASize : word) : boolean; virtual;
      function WriteRecord   (const AAdr; ASize : word) : boolean; virtual;

      { Boolean variable types }
      function ReadBoolean   (const ABoolean)  : boolean; virtual;
      function WriteBoolean  (const ABoolean)  : boolean; virtual;
      function ReadByteBool  (const AByteBool) : boolean; virtual;
      function WriteByteBool (const AByteBool) : boolean; virtual;
      function ReadWordBool  (const AWordBool) : boolean; virtual;
      function WriteWordBool (const AWordBool) : boolean; virtual;
      function ReadLongBool  (const ALongBool) : boolean; virtual;
      function WriteLongBool (const ALongBool) : boolean; virtual;

      { Integer variable types }
      function ReadByte      (const AByte) : boolean; virtual;
      function WriteByte     (const AByte) : boolean; virtual;
      function ReadWord      (const AWord) : boolean; virtual;
      function WriteWord     (const AWord) : boolean; virtual;
      function ReadShortInt  (const AShortInt) : boolean; virtual;
      function WriteShortInt (const AShortInt) : boolean; virtual;
      function ReadInteger   (const AInteger) : boolean; virtual;
      function WriteInteger  (const AInteger) : boolean; virtual;
      function ReadLongInt   (const ALongInt) : boolean; virtual;
      function WriteLongInt  (const ALongInt) : boolean; virtual;

      { Real variable types }
      function ReadSingle    (const ASingle) : boolean; virtual;
      function WriteSingle   (const ASingle) : boolean; virtual;
      function ReadReal      (const AReal) : boolean; virtual;
      function WriteReal     (const AReal) : boolean; virtual;
      function ReadDouble    (const ADouble) : boolean; virtual;
      function WriteDouble   (const ADouble) : boolean; virtual;
      function ReadComp      (const AComp) : boolean; virtual;
      function WriteComp     (const AComp) : boolean; virtual;
      function ReadExtended  (const AExtended) : boolean; virtual;
      function WriteExtended (const AExtended) : boolean; virtual;

      { Character variable types }
      function ReadChar  (const AChar) : boolean; virtual;
      function WriteChar (const AChar) : boolean; virtual;

      { String variable types}
      function ReadString  (const AString; AStrSize : word) : boolean; virtual;
      function WriteString (const AString; AStrSize : word) : boolean; virtual;

      function GetString   : String; virtual;
      function PutString   (const AString) : boolean; virtual;

    private
      Handle : File;
      Name : String[127];
      Error : integer;
      ErrorCount : integer;
      OpenFlag : boolean;
      NeedFlush : boolean;
    end;

    PBufFile = ^TBufFile;
    TBufFile = object ( TFile )
      constructor Init ( ABufSize : word );
      destructor  Done; virtual;
      function GetBufSize : word; virtual;
      function Reset : boolean; virtual;
      function ReWrite : boolean; virtual;
      function Truncate : boolean; virtual;
      function Flush : boolean; virtual;
      function FileSize : longint; virtual;
      function FilePos : longint; virtual;
      function Seek ( APosition : LongInt ) : boolean; virtual;
      function BlockRead (const AAdr; ASize : word; var ACount : word ) : boolean; virtual;
      function BlockWrite (const AAdr; ASize : word; var ACount : word ) : boolean; virtual;
    private
      BufSize : word;
      BufPtr : pointer;
      FPos : LongInt;
      FLen : LongInt;
      BPos : LongInt;
      BLen : word;
      procedure DumbClose;
      function RelocateBuf( ASize : word ) : boolean;
    end;

implementation

{$I-}

  constructor TFile.Init;
    begin
      Name := '';
      OpenFlag := False;
      NeedFlush := False;
      System.Assign(Handle, Name);
      Error := System.IOResult;
      ErrorCount := 0;
    end;

  destructor TFile.Done;
    begin
      if OpenFlag then Close;
    end;

  function TFile.ErrorHandler ( ACode : Word; AAction : byte ) : byte;
    begin
      ErrorHandler := AAction;
      if (ACode <> 0) and (AAction <> acIgnore) then
        begin
{          if ErrorCount > 3 then
            System.RunError ( ACode )
          else                        }
          if ErrorCount <= 3 then
            begin
              Inc(ErrorCount);
              ErrorHandler := acRetry;
            end;
        end;
    end;

  function TFile.IOResult : integer;
    begin
      IOResult := Error;
    end;

  procedure TFile.SetIOResult ( AIOResult : integer );
    begin
      Error := AIOResult;
    end;

  function TFile.Assign ( AFIleName : OpenString ) : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            Assign := False;
            Exit;
          end;
      ErrorCount := 0;
      Name := AFileName;
      repeat
        System.Assign ( Handle, Name );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      Assign := Error = 0;
    end;

  function TFile.FileName : string;
    begin
      FileName := Name;
    end;

  function TFile.FileExist : boolean;
    var
      TRec : Dos.SearchRec;
    begin
      ErrorCount := 0;
      repeat
        Dos.FindFirst ( Name, $FF, TRec );
        While (Dos.DosError = 0) and (TRec.Attr and (faVolumeID or faDirectory) <> 0) do
          Dos.FindNext ( TRec );
        Error := Dos.DosError;
        if Error = 18 then Error := 0;
      until (Error = 0) or (ErrorHandler( Error, acIgnore ) <> acRetry);
      FileExist := Dos.DosError = 0;
    end;

  function TFile.Reset : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            Reset := False;
            Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Reset ( Handle, 1 );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      OpenFlag := Error = 0;
      Reset := OpenFlag;
    end;

  function TFile.Rewrite : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            ReWrite := False;
            Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Rewrite ( Handle, 1 );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      OpenFlag := Error = 0;
      ReWrite := OpenFlag;
    end;

  function TFile.Close : boolean;
    begin
      if NeedFlush and OpenFlag then
        if Not Flush then
          begin
             Close := False;
             Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Close ( Handle );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      if Error = 0 then OpenFlag := False;
      Close := Error <> 0;
    end;

  function TFile.Truncate : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            Truncate := False;
            Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Truncate ( Handle );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      Truncate := Error = 0;
    end;

  function TFile.Flush : boolean;
    begin
      ErrorCount := 0;
      Error := 0;
      NeedFlush := False;
      Flush := True;
    end;

  function TFile.FileSize : longint;
    begin
      ErrorCount := 0;
      repeat
        FileSize := System.FileSize ( Handle );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      if Error <> 0 then FileSize := 0;
    end;

  function TFile.FilePos : longint;
    begin
      ErrorCount := 0;
      repeat
        FilePos := System.FilePos ( Handle );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      if Error <> 0 then FilePos := 0;
    end;

  function TFile.Erase : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            Erase := False;
            Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Erase ( Handle );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      Erase := Error = 0;
    end;

  function TFile.Rename ( AFileName : OpenString ) : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            Rename := False;
            Exit;
          end;
      ErrorCount := 0;
      repeat
        System.Rename ( Handle, AFileName );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      if Error = 0 then
        Name := AFIleName;
      Rename := Error = 0;
    end;

  function TFile.Seek ( APosition : LongInt ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        System.Seek ( Handle, APosition );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      Seek := Error = 0;
    end;

  function TFile.BlockRead (const AAdr; ASize : word; var ACount : word ) : boolean;
    var
      TPtr : Pointer;
    begin
      TPtr := Addr(AAdr);
      ErrorCount := 0;
      repeat
        System.BlockRead ( Handle, TPtr^, ASize, ACount );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      BlockRead := Error = 0;
    end;

  function TFile.BlockWrite (const AAdr; ASize : word; var ACount : word ) : boolean;
    var
      TPtr : Pointer;
    begin
      TPtr := Addr(AAdr);
      ErrorCount := 0;
      repeat
        System.BlockWrite ( Handle, TPtr^, ASize, ACount );
        Error := System.IOResult;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      BlockWrite := Error = 0;
    end;

  function TFile.GetFAttr ( var AAttr : word ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        Dos.GetFAttr ( Handle, AAttr );
        Error := Dos.DosError;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      GetFAttr := Error = 0;
    end;

  function TFile.SetFAttr ( AAttr : word ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        Dos.SetFAttr ( Handle, AAttr );
        Error := Dos.DosError;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      SetFAttr := Error = 0;
    end;

  function TFile.GetFTime ( var ATime : LongInt ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        Dos.SetFTime ( Handle, ATime );
        Error := Dos.DosError;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      GetFTime := Error = 0;
    end;

  function TFile.SetFTime ( ATime : LongInt ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        Dos.SetFTime ( Handle, ATime );
        Error := Dos.DosError;
      until (Error = 0) or (ErrorHandler( Error, acAbort ) <> acRetry);
      SetFTime := Error = 0;
    end;

  function TFile.GetSearchRec ( var ASearchRec : SearchRec ) : boolean;
    begin
      ErrorCount := 0;
      repeat
        Dos.FindFirst ( Name, $FF, ASearchRec );
        Error := Dos.DosError;
        if Error = 18 then Error := 2;
      until (Error = 0) or (ErrorHandler( Error, acIgnore ) <> acRetry);
      GetSearchRec := Dos.DosError = 0;
    end;

  (* Functions that should rarely need modification. *)

  function TFile.Open : boolean;
    begin
      if FileExist then
        Open := Reset
      else
      if Error = 0 then
        Open := ReWrite
      else
        Open := False;
    end;

  function TFile.Create : boolean;
    begin
      if FileExist then
        begin
          ErrorCount := 0;
          repeat
            Error := 5; { file access denied }
          until (ErrorHandler ( Error, acAbort ) <> acRetry);
          Create := False;
        end
      else
      if Error = 0 then
        Create := ReWrite
      else
        Create := False;
    end;

  function TFile.EOF : boolean;
    var
      TSize : LongInt;
    begin
      TSize := FileSize;
      if Error <> 0 then
        EOF := False
      else
        EOF := (TSize = FilePos) and (Error = 0);
    end;

  function TFile.SeekEOF : boolean;
    var
      TSize : longInt;
    begin
      TSize := FileSize;
      if Error <> 0 then
        SeekEOF := False
      else
        SeekEOF := Seek(TSize);
    end;

  function TFIle.ReadRecord (const AAdr; ASize : word) : boolean;
    var
      TCount : word;
    begin
      BlockRead ( AAdr, ASize, TCount );
      if (Error = 0) and (ASize <> TCount) then
        begin
          ErrorCount := 0;
          repeat
            Error := 100; { Disk Read Error }
          until (ErrorHandler ( Error, acAbort ) <> acRetry);
        end;
      ReadRecord := Error = 0;
    end;

  (* Records *)

  function TFile.WriteRecord (const AAdr; ASize : word) : boolean;
    var
      TCount : word;
    begin
      BlockWrite ( AAdr, ASize, TCount );
      if (Error = 0) and (ASize <> TCount) then
        begin
          ErrorCount := 0;
          repeat
            Error := 101; { Disk Write Error }
          until (ErrorHandler ( Error, acAbort ) <> acRetry);
        end;
      WriteRecord := Error = 0;
    end;

  (* Boolean *)

  function TFile.ReadBoolean (const ABoolean) : boolean;
    begin
      ReadBoolean := ReadRecord ( ABoolean, SizeOf(Boolean) );
    end;

  function TFile.WriteBoolean (const ABoolean) : boolean;
    begin
      WriteBoolean := WriteRecord( ABoolean, SizeOf(Boolean) );
    end;

  function TFile.ReadByteBool (const AByteBool) : boolean;
    begin
      ReadByteBool := ReadRecord ( AByteBool, SizeOf(ByteBool) );
    end;

  function TFile.WriteByteBool (const AByteBool) : boolean;
    begin
      WriteByteBool := WriteRecord( AByteBool, SizeOf(ByteBool) );
    end;

  function TFile.ReadWordBool (const AWordBool) : boolean;
    begin
      ReadWordBool := ReadRecord ( AWordBool, SizeOf(WordBool) );
    end;

  function TFile.WriteWordBool (const AWordBool) : boolean;
    begin
      WriteWordBool := WriteRecord( AWordBool, SizeOf(WordBool) );
    end;

  function TFile.ReadLongBool (const ALongBool) : boolean;
    begin
      ReadLongBool := ReadRecord ( ALongBool, SizeOf(LongBool) );
    end;

  function TFile.WriteLongBool (const ALongBool) : boolean;
    begin
      WriteLongBool := WriteRecord( ALongBool, SizeOf(LongBool) );
    end;

  (* Integer *)

  function TFile.ReadByte (const AByte) : boolean;
    begin
      ReadByte := ReadRecord ( AByte, SizeOf(Byte) );
    end;

  function TFile.WriteByte (const AByte) : boolean;
    begin
      WriteByte := WriteRecord( AByte, SizeOf(Byte) );
    end;

  function TFile.ReadWord (const AWord) : boolean;
    begin
      ReadWord := ReadRecord ( AWord, SizeOf(Word) );
    end;

  function TFile.WriteWord (const AWord) : boolean;
    begin
      WriteWord := WriteRecord( AWord, SizeOf(Word) );
    end;

  function TFile.ReadShortInt (const AShortInt) : boolean;
    begin
      ReadShortInt := ReadRecord ( AShortInt, SizeOf(ShortInt) );
    end;

  function TFile.WriteShortInt (const AShortInt) : boolean;
    begin
      WriteShortInt := WriteRecord( AShortInt, SizeOf(ShortInt) );
    end;

  function TFile.ReadInteger (const AInteger) : boolean;
    begin
      ReadInteger := ReadRecord ( AInteger, SizeOf(Integer) );
    end;

  function TFile.WriteInteger (const AInteger) : boolean;
    begin
      WriteInteger := WriteRecord( AInteger, SizeOf(Integer) );
    end;

  function TFile.ReadLongInt (const ALongInt) : boolean;
    begin
      ReadLongInt := ReadRecord ( ALongInt, SizeOf(LongInt) );
    end;

  function TFile.WriteLongInt (const ALongInt) : boolean;
    begin
      WriteLongInt := WriteRecord( ALongInt, SizeOf(LongInt) );
    end;

  (* Real *)

  function TFile.ReadSingle (const ASingle) : boolean;
    begin
      ReadSingle := ReadRecord ( ASingle, SizeOf(Single) );
    end;

  function TFile.WriteSingle (const ASingle) : boolean;
    begin
      WriteSingle := WriteRecord( ASingle, SizeOf(Single) );
    end;

  function TFile.ReadReal (const AReal) : boolean;
    begin
      ReadReal := ReadRecord ( AReal, SizeOf(Real) );
    end;

  function TFile.WriteReal (const AReal) : boolean;
    begin
      WriteReal := WriteRecord( AReal, SizeOf(Real) );
    end;

  function TFile.ReadDouble (const ADouble) : boolean;
    begin
      ReadDouble := ReadRecord ( ADouble, SizeOf(Double) );
    end;

  function TFile.WriteDouble (const ADouble) : boolean;
    begin
      WriteDouble := WriteRecord( ADouble, SizeOf(Double) );
    end;

  function TFile.ReadComp (const AComp) : boolean;
    begin
      ReadComp := ReadRecord ( AComp, SizeOf(Comp) );
    end;

  function TFile.WriteComp (const AComp) : boolean;
    begin
      WriteComp := WriteRecord( AComp, SizeOf(Comp) );
    end;

  function TFile.ReadExtended (const AExtended) : boolean;
    begin
      ReadExtended := ReadRecord ( AExtended, SizeOf(Extended) );
    end;

  function TFile.WriteExtended (const AExtended) : boolean;
    begin
      WriteExtended := WriteRecord( AExtended, SizeOf(Extended) );
    end;

  (* Character *)

  function TFile.ReadChar (const AChar) : boolean;
    begin
      ReadChar := ReadRecord ( AChar, SizeOf(Char) );
    end;

  function TFile.WriteChar (const AChar) : boolean;
    begin
      WriteChar := WriteRecord( AChar, SizeOf(Char) );
    end;

  (* String *)

  function TFile.ReadString (const AString; AStrSize : word) : boolean;
    var
      TString : String;
      TPtr    : Pointer;
    begin
      TPtr := Addr(AString);
      if ReadByte(TString) then
        ReadString := ReadRecord (TString[1], Byte(TString[0]))
      else
        ReadString := False;
      Move ( TString, TPtr^, AStrSize );
    end;

  function TFile.WriteString (const AString; AStrSize : word) : boolean;
    begin
      WriteString := ReadRecord (AString, AStrSize);
    end;

  function TFile.GetString : String;
    var
      TString : String;
    begin
      if ReadByte(TString) then
        begin
          ReadRecord (TString[1], Byte(TString[0]));
          GetString := TString;
        end
      else
        GetString := '';
    end;

  function TFile.PutString (const AString) : boolean;
    begin
      PutString := WriteRecord ( AString, Byte(AString) + 1 );
    end;

(* BufFile ---------------------------------------------------------------- *)

  constructor TBufFile.Init ( ABufSize : word );
    begin
      inherited Init;
      BufSize := (ABufSize div 512) * 512;
      if (BufSize = 0) and (ABufSize > 0) then BufSize := ABufSize;
      if (MaxAvail < BufSize) and (MaxAvail > 1024) then
        BufSize := (MaxAvail div 1024) * 1024 - 1024
      else
      if MaxAvail <= 1024 then
        BufSize := 0;
      if BufSize > 0 then
        GetMem( BufPtr, BufSize )
      else
        BufPtr := nil;
    end;

  destructor TBufFile.Done;
    begin
      if OpenFlag and NeedFlush then Flush;
      if Assigned(BufPtr) then
        begin
          FreeMem ( BufPtr, BufSize );
          BufPtr := nil;
        end;
      inherited Done;
    end;

  function TBufFile.GetBufSize : word;
    begin
      if Assigned(BufPtr) then
        GetBufSize := BufSize
      else
        GetBufSize := 0;
    end;

  function TBufFile.Reset : boolean;
    begin
      Reset := False;
      if OpenFlag and NeedFlush then
        if Not Flush then
          Exit;
      if not inherited Reset then
        Exit;
      FPos := inherited FilePos;
      if Error = 0 then
      FLen := inherited FileSize;
      if Error <> 0 then
        begin
          DumbClose;
          Exit;
        end;
      BPos := FPos;
      BLen := 0;
      if inherited BlockRead ( BufPtr^, BufSize, BLen ) then
        Reset := True
      else
        DumbClose
    end;

  function TBufFile.ReWrite : boolean;
    begin
      ReWrite := False;
      if not inherited ReWrite then
        Exit;
      FPos := inherited FilePos;
      if Error = 0 then
      FLen := inherited FileSize;
      if Error <> 0 then
        begin
          DumbClose;
          Exit;
        end;
      BPos := FPos;
      BLen := 0;
    end;

  function TBufFile.Truncate : boolean;
    begin
      Truncate := False;
      if Not inherited Seek ( FPos ) then Exit;
      if Not inherited Truncate then Exit;
      FLen := FPos;
      if FPos <= BPos then
        BLen := 0
      else
      if BPos + LongInt(BLen) > FPos then
        BLen := FPos - BPos;
      Truncate := True;
    end;

  function TBufFile.Flush : boolean;
    var
      TLen : word;
    begin
      if OpenFlag and NeedFlush and Assigned(BufPtr) then
        begin
          if BLen > 0 then
            begin
              if not inherited Seek ( BPos ) then
                begin
                  Flush := False;
                  Exit;
                end;
              if (Not inherited BlockWrite ( BufPtr^, BLen, TLen )) or
               (TLen <> BLen) then
                begin
                  ErrorCount := 0;
                  repeat
                    Error := 101; { Disk Write Error }
                  until (ErrorHandler ( Error, acAbort ) <> acRetry);
                  Flush := False;
                  Exit;
                end;
            end;
          if not inherited Seek ( FPos ) then Exit;
          Flush := Inherited Flush;
        end
      else
        begin
          ErrorCount := 0;
          Error := 0;
          Flush := True;
        end;
    end;

  function TBufFile.FileSize : longint;
    begin
      ErrorCount := 0;
      Error := 0;
      FileSize := FLen;
    end;

  function TBufFile.FilePos : longint;
    begin
      ErrorCount := 0;
      Error := 0;
      FilePos := FPos;
    end;

  function TBufFile.Seek ( APosition : LongInt ) : boolean;
    begin
      ErrorCount := 0;
      Error := 0;
      FPos := APosition;
    end;

  function TBufFile.BlockRead (const AAdr; ASize : word; var ACount : word ) : boolean;
    type
      ByteCast = array[0..$FFFE] of byte;
    var
      TPtr : Pointer;
    begin
      if (ASize > BufSize) or (Not Assigned(BufPtr)) then
        begin
          if (Not Flush) or (Not inherited Seek(FPos)) then
            begin
              BlockRead := False;
              Exit;
            end;
          BlockRead := inherited BlockRead ( AAdr, ASize, ACount );
          Inc( FPos, ACount );
        end
      else
        begin
          TPtr := Addr(AAdr);
          if (FPos < BPos) or (BLen = 0) or ((FPos + LongInt(ASize) > BPos + LongInt(BLen)) and
          (FPos + LongInt(ASize) > BPos + LongInt(BufSize))) then
            if Not RelocateBuf( ASize ) then
              begin
                BlockRead := False;
                Exit;
              end;
          if ASize > BLen then
            ACount := BLen
          else
            ACount := ASize;
          Move ( ByteCast(BufPtr^)[FPos - BPos], TPtr^, ACount );
          Inc ( FPos, ACount );
          BlockRead := True;
        end;
    end;

  function TBufFile.BlockWrite (const AAdr; ASize : word; var ACount : word ) : boolean;
    type
      ByteCast = array[0..$FFFE] of byte;
    var
      TPtr : Pointer;
    begin
      if (ASize > BufSize) or (Not Assigned(BufPtr)) then
        begin
          if (Not Flush) or (Not inherited Seek(FPos)) then
            begin
              BlockWrite := False;
              Exit;
            end;
          BlockWrite := inherited BlockWrite ( AAdr, ASize, ACount );
          Inc ( FPos, ACount );
          if FPos + LongInt(ACount) > FLen then
            FLen := FPos + LongInt(ACount) - 1;
        end
      else
        begin
          TPtr := Addr(AAdr);
          if (FPos < BPos) or (BLen = 0) or ((FPos + LongInt(ASize) > BPos + LongInt(BLen)) and
          (FPos + LongInt(ASize) > BPos + LongInt(BufSize))) then
            if Not RelocateBuf( ASize ) then
              begin
                BlockWrite := False;
                Exit;
              end;
          ACount := ASize;
          if FPos + LongInt(ASize) > BPos + LongInt(BLen) then
            begin
              FLen := FPos + LongInt(ASize);
              BLen := FLen - BPos;
            end;
          Move ( TPtr^, ByteCast(BufPtr^)[FPos - BPos], ACount );
          Inc ( FPos, ACount );
          NeedFlush := True;
          BlockWrite := True;
        end;
    end;

  procedure TBufFile.DumbClose;
    var
      TError : integer;
    begin
      System.Close ( Handle );
      TError := System.IOResult;
      OpenFlag := False;
      NeedFlush := False;
    end;

  function TBufFile.RelocateBuf ( ASize : word ) : boolean;
    begin
      if OpenFlag and NeedFlush then
        if Not Flush then
          begin
            RelocateBuf := False;
            Exit;
          end;
      BPos := FPos;
      if (not inherited Seek(BPos)) or
      (not inherited BlockRead( BufPtr^, BufSize, BLen )) then
        begin
          RelocateBuf := False;
          BLen := 0;
          Exit;
        end;
      RelocateBuf := True;
    end;

end.