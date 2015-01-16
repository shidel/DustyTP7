{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

    @AnsiFound:     DB False  { Becomes, True if ansi is present }
    @CRLF:          DB AnsiCode,1,13,10,0
    @Ident:         DB 'This ',AnsiCode,2,'program',AnsiCode,1,' does not do anything.',0

    @AnsiRef:       DW OFFSET @BackColor
                    DW OFFSET @Bold
    @BackColor:     DB 27,'[0m',0
    @Bold:          DB 27,'[1;37;41m',0

