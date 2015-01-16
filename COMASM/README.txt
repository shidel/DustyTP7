This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

Copyright 1990-2015 Jerome Shidel.

The COM ASSEMBLER utility.

This pascal program is a program template for creating COM files (executable flat binary
image). Once it is compiled and executed, will strip out part of it's own code to make
one. It also contains several assembly language include files for common tasks.


Based on COM Assembler to generate smaller executables.

BOOTDRIV.PAS return the DOS boot drive letter.

DRIVE.PAS Returns type information about the current drive. Network, CD...

ENV.PAS Displays the current environment variable table.

FASTKEY.PAS Extremely simple pascal program that creates a COM file from machine language
that sets the keyboard repeat rate faster and reduces it's delay settings.

LARGE.PAS replaces text mode font with a custom larger font.

LASTDRIV.PAS Return the highest possible drive letter. 

MBLANKER.PAS TSR (Terminate and Stay Resident) DOS screen blanker.

MESSAGE.PAS Template to display a message. 

POST.PAS Simple program to initiate a Power On Self Test. Under DOS, this causes the 
system to reboot. Warning: If using disk caching software, changes not written to disk
will be lost.