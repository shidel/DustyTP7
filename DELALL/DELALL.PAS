{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M $FFF0,0,0}
program DelAll;

uses Dos;

  const
    faReadOnly   = $01;
    faHidden     = $02;
    faSysFile    = $04;
    faVolumeID   = $08;
    faDirectory  = $10;
    faArchive    = $20;
    faAnyFile    = $3F;
    { FileModes }

  procedure DoDelete( Spec : String );
     var
       TDir  : DirStr;
       TName : NameStr;
       TExt  : ExtStr;
       TFile : File;
       TErr  : integer;
     procedure Wipe ( Dir : DirStr );
       var
         SRec : SearchRec;
       begin
         FindFirst ( Dir + TName + TExt, faAnyFile, SRec );
         while DosError = 0 do
           begin
             WriteLn ( Dir + SRec.Name );
             Assign ( TFile, Dir + SRec.Name );
             {$I-}
             Erase ( TFile );
             {$I+}
             TErr := IOResult;
             FindNext ( SRec );
           end;
       end;
     procedure Recurse ( Dir : DirStr );
       var
         SRec : SearchRec;
       begin
         FindFirst ( Dir + '*.*', faAnyFile, SRec );
         while DosError = 0 do
           begin
             if (SRec.Name <> '.') and (SRec.Name <> '..') and
             ( SRec.Attr and faDirectory = faDirectory) then
               Recurse( Dir + SRec.Name + '\' );
             FindNext ( SRec );
           end;
         Wipe ( Dir );
       end;
     begin
       FSPlit ( FExpand(Spec), TDir, TName, TExt );
       Recurse ( TDir );
     end;


  var
    I : Byte;

begin
  if ParamCount = 0 then
    begin
      WriteLn ( 'DELALL [[drive:]path\]filespec');
    end
  else
    for I := 1 to ParamCount do
      DoDelete ( ParamStr(I) );
end.