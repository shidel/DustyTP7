{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit FileCopy;

interface

  uses Dos, Files, Errors;

  type
    PFileCopy = ^TFileCopy;
    TFileCopy = object
        Source       : TFile;   { Source File }
        Dest         : TFile;   { Destination File }
        SourceRec    : SearchRec;
        DestRec      : SearchRec;
        EraseFile    : boolean; { Erase Source file after copy }
        TimeStamp    : boolean; { Copy Time Stamp to destination file }
        Attribute    : boolean; { Copy file attribute to destination file }
        ClearAttr    : boolean; { Clear source file attribute }
        OverWriteAll : boolean; { Overwrite all duplicate files }
        OverWriteNew : boolean; { Overwrite all duplicate files if source is newer }
        ReplaceAll   : boolean; { Copy only if file exists }
        ReplaceNew   : boolean; { Copy only if file exists and source is newer }
      constructor Init;
      destructor  Done; virtual;
      function    Copy( SourceName, DestName : String ) : boolean; virtual;
      procedure   Error( AFile : TFile ); virtual;
      procedure   ErrorStr( AFile : TFile ); virtual;
      function    NewerFile : boolean; virtual;
    end;

implementation

  constructor TFileCopy.Init;
    begin
      Source.Init;
      Dest.Init;
      EraseFile    := False;
      TimeStamp    := True;
      Attribute    := True;
      ClearAttr    := False;
      OverWriteAll := False;
      OverWriteNew := False;
      ReplaceAll   := False;
      ReplaceNew   := False;
    end;

  destructor TFileCopy.Done;
    begin
      Dest.Done;
      Source.Done;
    end;

  function TFileCopy.Copy( SourceName, DestName : String ) : boolean;
    begin
      Copy := False;
      Source.Assign ( SourceName );
      Dest.Assign( DestName );
      if Not Source.GetSearchRec ( SourceRec ) then
        begin
          Error ( Source );
          Exit;
        end;
      case Dest.GetSearchRec ( DestRec ) of
        False : if (ReplaceAll or ReplaceNew) then
          begin
            Error( Dest );
            Exit;
          end;
        True : if ((not OverwriteAll) and ((Not OverwriteNew) or (Not NewerFile)))
        or (DestRec.Attr and (faHidden or faSystem or faReadOnly) <> 0) then
          begin
            Dest.SetIOResult ( erFile_Access_Denied );
            Error ( Dest );
            Exit;
          end;
      end;
      Copy := True;
    end;


  procedure TFileCopy.Error( AFile : TFile );
    begin
      ErrorStr ( AFile );
      Source.Close;
      Dest.Close;
    end;

  procedure TFileCopy.ErrorStr( AFile : TFile );
    begin
      WriteLn;
      WriteLn( 'FILE (', AFile.FileName, ') ERROR: ',
        Errors.ErrorStr( AFile.IOResult ) );
    end;

  function TFileCopy.NewerFile : boolean;
    var
      ST, DT : DateTime;
    begin
      NewerFile := True;
      UnpackTime ( SourceRec.Time, ST );
      UnpackTime ( DestRec.Time, DT );
      if ST.Year < DT.Year then Exit;
      if ST.Month < DT.Month then Exit;
      if ST.Day < DT.Day then Exit;
      if ST.Hour < DT.Hour then Exit;
      if ST.Min < DT.Min then Exit;
      NewerFile := ST.Sec < DT.Sec;
    end;


end.
