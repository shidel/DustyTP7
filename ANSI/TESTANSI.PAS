{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program Hello;

  uses AnsiSys;

  procedure Return;
    var
      LFore, LBack : Byte;
    begin
      LFore := ForeGround;
      LBack := BackGround;
      Background := Black;
      ForeGround := White;
      SetColor;
      WriteSTD ( #13#10 );
      BackGround := LBack;
      ForeGround := LFore;
      SetColor;
    end;

  const
    Title : String = 'Environment lister version 2.00';

begin
  Foreground := Yellow;
  Background := Blue;
  Bold       := True;
  Return;
  WriteSTD ('ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป'); Return;
  WriteSTD ('บ                                                                             บ'); Return;
  WriteSTD ('ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ'); Return;
  CursorUp( 2 );
  CursorForward( 39 - Length(Title) div 2 );
  Foreground := White;
  SetColor;
  WriteStd (Title);
  Bold := False;
  BackGround := Black;
  Return;
  Return;
end.