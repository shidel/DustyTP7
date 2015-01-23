{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Test_FileCopy;

  uses FileCopy;

  var
    Copy : TFileCopy;

begin
  WriteLn (#27'[2J' );
  with Copy do
    begin
      Init;
      if Copy ('CPY.EXE', 'TMP.EXE') then WriteLn ( 'FILE COPIED');
      Done;
    end;
end.
