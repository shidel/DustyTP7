{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Copier;

  uses StrSize, StrAsm, Colors, Errors, FileCopy;

  const
  { Strings }
    stTitle    : Str20 = 'Copier Version 2.00a';
    stReqParam : Str26 = 'Required parameter missing';
    stBadParam : Str21 = 'Invalid parameter - ';

  { Verbose Messages }
    vbVerify       = 'Verify is ;on;off';
    vbRecurse      = 'Recurse subdirs is ;on;off';
    vbConsolidate  = 'Consolidate subdirs is ;on;off';
    vbSortCopy     = 'Copy files ;alphabetically;in order';
    vbSizeCopy     = 'Copy files ;by size;in order';
    vbDiskCopy     = 'Duplicate disk is ;on;off';
    vbEraseFile    = 'Files will be ;moved(copied/erased);copied';
    vbEraseDir     = 'Empty dirs will be ;erased;kept';
    vbTimeStamp    = 'New Time stamps will be ;copied;made current';
    vbAttribute    = 'New file attributes will ;be copied;not be copied';
    vbClearAttr    = 'Old file attributes will ;cleared;preserved';
    vbVolumeLabel  = 'Disk volume label will be ;copied;preserved';
    vbOverWriteAll = 'Duplicate files will ;be overwritten;not be overwritten';
    vbOverWriteNew = 'Duplicate files will ;be overwritten only if newer source;not be overwritten';
    vbReplaceAll   = 'Files will be copied ;only if they exist; if they do not already exist';
    vbReplaceNew   = 'Files will be copied ;only if the already exist and are newer;if they do not exist';

  { Option switches }
    opVerbose      : Str3 = '/VB';
    opRecurse      : Str2 = '/R';
    opConsolidate  : Str2 = '/C';
    opSortCopy     : Str3 = '/SA';
    opSizeCopy     : Str3 = '/SO';
    opDiskCopy     : Str2 = '/D';
    opVerify       : Str2 = '/V';
    opEraseFile    : Str2 = '/M';
    opEraseDir     : Str2 = '/E';
    opTimeStamp    : Str2 = '/T';
    opAttribute    : Str2 = '/A';
    opClearAttr    : Str3 = '/CA';
    opVolumeLabel  : Str3 = '/ID';
    opOverWriteAll : Str3 = '/OA';
    opOverWriteNew : Str3 = '/ON';
    opReplaceAll   : Str3 = '/RA';
    opReplaceNew   : Str3 = '/RN';

  { Options }
    Verbose     : boolean = True;  { Verbose Execution }
    Recurse     : boolean = False; { Recurse all subdirectorys }
    Consolidate : boolean = False; { Copy all files to same directory }
    SortCopy    : boolean = False; { Copy sorted by name }
    SizeCopy    : boolean = False; { Copy sorted by size }
    DiskCopy    : boolean = False; { Duplicate floppy }
    Verify      : boolean = False; { Write Verify }

    EraseFile   : boolean = False; { Erase files when done }
    EraseDir    : boolean = False; { Erase empty directories }

    TimeStamp   : boolean = True;  { Copy Time stamp }
    Attribute   : boolean = True;  { Copy File Attribute }
    ClearAttr   : boolean = False; { Clears Archive Attribute }
    VolumeLabel : boolean = False; { Copies Volume ID }

    OverWriteAll : boolean = False; { Automatically overwrite existing files }
    OverWriteNew : boolean = False; { Automatically overwrite if newer }
    ReplaceAll   : boolean = False; { Only copy if duplicate file }
    ReplaceNew   : boolean = False; { Only copy if newer duplacate file }

    OptTerm : Str5 = '+-/\ ';
    Param   : String = '';

    Source : String = '';
    Destination : String = '';

  procedure Halt( AMessage : String; ACode : integer);
    begin
      WriteLn ( Color(clError), AMessage, ColorOff );
      System.Halt( ACode );
    end;

  procedure Help;
    function SwStr ( AStr : String ) : String;
      begin
        SwStr := '  ' + RSpace(AStr,3) + '  ';
      end;
    begin
      WriteLn ( ColorOff, 'Copies one or more files to another location.' );
      WriteLn;
      WriteLn ( 'COPY ', Color(clFile), 'source destination', ColorOff,
        ' [',  Color(clOpt), opVerbose, ColorOff, ']',
        ' [',  Color(clOpt), opVerify, ColorOff, ']',
        ' [',  Color(clOpt), opEraseFile, ColorOff, ']',
        ' [',  Color(clOpt), opEraseDir, ColorOff, ']',
        ' [',  Color(clOpt), opTimeStamp, ColorOff, ']',
        ' [',  Color(clOpt), opAttribute, ColorOff, ']',
        ' [',  Color(clOpt), opClearAttr, ColorOff, ']',
        ' [',  Color(clOpt), opVolumeLabel, ColorOff, ']',
        ' [',  Color(clOpt), opSortCopy, Color(clOptOr),
        ' | ', Color(clOpt), opSizeCopy, ColorOff, ']' );
      WriteLn (
        '  [', Color(clOpt), opOverWriteAll, Color(clOptOr),
        ' | ', Color(clOpt), opOverWriteNew, Color(clOptOr),
        ' | ', Color(clOpt), opReplaceAll, Color(clOptOr),
        ' | ', Color(clOpt), opReplaceNew, ColorOff, ']',
        ' [',  Color(clOpt), opRecurse, Color(clOptOr),
        ' | ', Color(clOpt), opConsolidate, Color(clOptOr),
        ' | ', Color(clOpt), opDiskCopy, ColorOff, ']'
        );
      WriteLn;
      WriteLn ( Color(clOpt), SwStr(opVerbose), ColorOff,
        'Verbose messages.');
      WriteLn ( Color(clOpt), SwStr(opVerify), ColorOff,
        'Verifies that new files are written correctly.');
      WriteLn ( Color(clOpt), SwStr(opEraseFIle), ColorOff,
        'Move files.');
      WriteLn ( Color(clOpt), SwStr(opEraseDir), ColorOff,
        'Erase empty directories.');
      WriteLn ( Color(clOpt), SwStr(opTimeStamp), ColorOff,
        'Copy time stamp to destination.');
      WriteLn ( Color(clOpt), SwStr(opAttribute), ColorOff,
        'Copy file attribute to destination.');
      WriteLn ( Color(clOpt), SwStr(opClearAttr), ColorOff,
        'Clear attribute on source.');
      WriteLn ( Color(clOpt), SwStr(opVolumeLabel), ColorOff,
        'Copy disk volume label to destination disk.');
      WriteLn ( Color(clOpt), SwStr(opSortCopy), ColorOff,
        'Copies files in alphabetical order.');
      WriteLn ( Color(clOpt), SwStr(opSizeCopy), ColorOff,
        'Copies files according to size for best fit.');
      WriteLn ( Color(clOpt), SwStr(opOverWriteAll), ColorOff,
        'Overwrite all duplicate files.');
      WriteLn ( Color(clOpt), SwStr(opOverWriteNew), ColorOff,
        'Overwrite all duplicate files if source is newer than destination.');
      WriteLn ( Color(clOpt), SwStr(opReplaceAll), ColorOff,
        'Update duplicate files only.');
      WriteLn ( Color(clOpt), SwStr(opReplaceNew), ColorOff,
        'Update duplicate files only if source is newer than destination.');
      WriteLn ( Color(clOpt), SwStr(opRecurse), ColorOff,
        'Recurse and copy files in subdirectories duplicating directories.');
      WriteLn ( Color(clOpt), SwStr(opConsolidate), ColorOff,
        'Recurse and copy files in subdirectories to the same directory.');
      WriteLn ( Color(clOpt), SwStr(opDiskCopy), ColorOff,
        'Duplicate entire floppy disk.');
      System.Halt(erNo_More_Files);
    end;

  function VerboseMessage ( AMessage : String; AWhich : byte ) : String;
    var
      Msg : String;
      Loc : byte;
      Cur : byte;
    begin
      if AMessage = '' then
        VerboseMessage := ''
      else
        begin
          Cur := 1;
          Loc := Pos(';', AMessage);
          if Loc = 0 then Loc := Length(AMessage) + 1;
          Msg := Copy(AMessage, 1, Loc - 1);
          While (Cur < AWhich) and (Loc <= Length(AMessage)) do
            begin
              Inc(Cur);
              Inc(Loc);
              While (Loc < Length(AMessage)) and (AMessage[Loc] <> ';') do
                Inc(Loc);
            end;
          Inc(Loc);
          if Cur = AWhich then
            While (Loc <= Length(AMessage)) and (AMessage[Loc] <> ';') do
              begin
                Inc(Byte(Msg[0]));
                Msg[Length(Msg)] := AMessage[Loc];
                Inc(Loc);
              end;
          VerboseMessage := Msg;
        end;
    end;

  function GetOpt( AOpt : String; ADefault : boolean; AMessage : String ) : boolean;
    var
      Found : boolean;
      Setting : boolean;
      Index : Byte;
      Loc   : byte;
    begin
      Setting := ADefault;
      Found := False;
      for Index := 1 to Length(OptTerm) do
        begin
          Loc := Pos(AOpt + OptTerm[Index], Param);
          if Loc <> 0 then
            Case OptTerm[Index] of
              '+', '-' : begin
                Found := True;
                Delete(Param, Loc, Length(AOpt) + 1);
                Setting := OptTerm[Index] = '+'
              end
            else
              Found := True;
              Delete(Param, Loc, Length(AOpt));
              Setting := True;
            end;
        end;
      if Verbose and Found and (AMessage <> '') then
        begin
          Write ( Color( clVerbose ) );
          if Setting then
            Write ( VerboseMessage( AMessage, 1 ) )
          else
            Write ( VerboseMessage( AMessage, 2 ) );
          WriteLn ( ColorOff );
        end;
      GetOpt := Setting;
    end;

  procedure ParseOptions;
    var
      Index : Byte;
    begin
      if (ParamCount = 0) then Halt ( stReqParam, erNo_More_Files );
      Param := '';
      for Index := 1 to ParamCount do
        Param := Param + UCase(ParamStr(Index)) + ' ';
      if GetOpt('/?', False, '') or GetOpt('/H', False, '') then Help;
      Verbose := GetOpt(opVerbose, Verbose, '');
      Verify := GetOpt(opVerify, Verify, vbVerify);
      EraseFile := GetOpt( opEraseFile, EraseFile, vbEraseFile );
      EraseDir := GetOpt( opEraseDir, EraseDir, vbEraseDir );
      TimeStamp := GetOpt( opTimeStamp, TimeStamp, vbTimeStamp );
      Attribute := GetOpt( opAttribute, Attribute, vbAttribute );
      ClearAttr := GetOpt( opClearAttr, ClearAttr, vbClearAttr );
      VolumeLabel := GetOpt( opVolumeLabel, VolumeLabel, vbVolumeLabel);
      OverWriteAll := GetOpt( opOverWriteAll, OverWriteAll, vbOverWriteAll);
      OverWriteNew := GetOpt( opOverWriteNew, OverWriteNew, vbOverWriteNew);
      ReplaceAll := GetOpt( opReplaceAll, ReplaceAll, vbReplaceAll );
      ReplaceNew:= GetOpt( opReplaceNew, ReplaceNew, vbReplaceNew );
      SortCopy := GetOpt( opSortCopy , SortCopy , vbSortCopy );
      SizeCopy := GetOpt( opSizeCopy , SizeCopy, vbSizeCopy );
      Recurse := GetOpt( opRecurse, Recurse, vbRecurse );
      Consolidate := GetOpt( opConsolidate, Consolidate, vbConsolidate );
      DiskCopy := GetOpt( opDiskCopy , DiskCopy , vbDiskCopy );
      if Verbose then WriteLn;
      if Trim(Param) <> '' then
        Halt(stBadParam + Trim(Param), erNo_More_Files );
    end;

begin
  WriteLn ( Color(clTitle), stTitle, ColorOff );
  WriteLn;
  ParseOptions;
end.
