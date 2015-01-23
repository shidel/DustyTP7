{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 16384,0,655360}
program Error;

  uses Errors;

  var
    I : Integer;
    E : integer;


begin
  if ParamCount = 0 then
    WriteLn ('ERROR errornumber')
  else
    begin
      Val ( ParamStr(1), I, E );
      if E <> 0 then
        WriteLn ('invalid number, cannot display error message.')
      else
      if ErrorStr(I) <> 'unknown error code' then
        WriteLn ('Error #', I, ' means ', '"', ErrorStr(I), '"' )
      else
        WriteLn ('Error #', I, ' has not been defined.' )
    end;
end.
