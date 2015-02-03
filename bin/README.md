This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

Copyright 1990-2015 Jerome Shidel.

### Pre-compiled binary executables.

**_ATOM.EXE_** Simple Non-BGI Direct video graphics mode demo.

**_BOOTDRIV.COM_** Returns the drive letter system used for booting.

_BOOTME.BIN_ Experimental replacement boot sector for floppy disks. 

**_COMASM.COM_** Basic Pascal EXE to COM image demo.

**_D.EXE_** Advanced directory listing program v7.10.

**_DDF.EXE_** Directory Description File Editor. Works with **_D.EXE_**

**_DDFLINK.EXE_** Automatic Description File Editor Message Linker.

**_DS.EXE_** Smooth scrolling directory listing program, based on earlier version of D.EXE.

_DISCRIPT.DDF_ Directory description Data File. (So, I couldn't spell.) 

**_DTYPE.COM_** (Actually, DRIVE.COM but renamed to reduce conflict with DRIVE.EXE)
Returns type information about the current active drive.

**_DRIVE.EXE_** Returns some general information about all drives.

**_ENV.COM_** Returns current environment variable table.

**_ERROR.EXE_** Simple command line utility to return an error string based on standard
DOS program error numbers.

**_ERRORS.EXE_** Version 2 of the simple command line utility to return information regarding 
an error code and along with the type of that error. DOS, BIOS or PASCAL. 

**_FASTKEY.COM_** Sets keyboard delay to minimum and and repeat rate to maximum.

**_INFO.EXE_** Returns information about the computer system.

**_INSTALL.EXE_** Very simple installer for PGM 7.2. Basically, creates a directory and
copies PGM72.EXE there. The creates the launcher batch file for PGM.

**_LARGE.COM_** A **TSR** that installs my larger text mode font.

**_LASTDRIV.COM_** Returns the last assignable dos drive letter. (This used to matter when drive letters used precious memory.)

**_MBLANKER.COM_** A **TSR** screen blanking utility.

**_MESSAGE.COM_** Template to display a message. 

**_NULLDISK.EXE_** Utility to wipe boot sector of a floppy.

**_PGM72.EXE_** Multiple menu, text mode program launcher with mouse support for DOS. This version
of PGM was built for use in pre-Windows environments in early 1992. My PGM series was in active use 
up to about 1997. Please note, that PGM can do many things more than launch programs. PGM must always be
started from it's batch file launcher. It is automatically created by the **_INSTALL.EXE_**
program. Basically, It works like this. _PGM.BAT_ launches _PGM72.EXE_. _PGM72.EXE_ creates
a batch file called RN.BAT based on the program you want to run and any additional commands 
assigned to that menu entry. _PGM72.EXE_ quits returning to the _PGM.BAT_ file. _PGM.BAT_ runs 
_RN.BAT_. Created by _PGM72.EXE_ _RN.BAT_ performs all the tasks and then runs _PGM.BAT_ again.

**_PORTS.EXE_** Simple program to display COM and Printer port assignments.

**_POST.COM_** Simple program to initiate a Power On Self Test. Under DOS, this causes the 
system to reboot. Warning: If using disk caching software, changes not written to disk
will be lost.

**_READBOOT.EXE_** Utility to read and save a floppy boot sector.

**_SERIAL.EXE_** Experimental program to read and write the serial number of disk drives.

_SBPMIXER.DRV_ Binary device driver for controlling a SoundBlaster Pro Mixer chipset.

**_SLIVER.EXE_** Simple Non-BGI Direct video graphics mode demo.

**_TESTANSI.EXE_** Test program for the **_ANSISYS.PAS_** unit. 

**_TESTDOS.EXE_** Test program for **_DOSEXT.PAS_** unit.

**_VIDSPD.EXE_** Simple text mode screen speed test.

**_WRITBOOT.EXE_** Writes a specified file to a floppy boot sector.
