This project and related files are subject to the terms of the **_Mozilla Public License_**, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

Copyright 1990-2015 Jerome Shidel.

### UNITS 

**_BIOS.PAS_** Mostly _BIOS_ function calls for preforming low level disk I/O.

**_DOSEXT.PAS_** Expanded _DOS_ functionality from what was provided in _Borland's DOS_ unit.

**_ERRORS.PAS_** Simple unit to return a text string for _DOS_ error codes.

**_EXITMSG.PAS_** A drop in unit that provides more detailed information when program crashes.

**_FILES.PAS_** Object Oriented Random Access Block File objects. Also, includes a caching 
Object to greatly increase speed when processing files a couple bytes at a time.

**_LISTS.PAS_** A page based linked list object.

**_MACROS.PAS_** A really poorly named unit. Should have called it FMTSTR.PAS. Because,
basically thats all it ever did. Format strings and insert data.

**_QCRT.PAS_** Drop in replacement for _Borland's CRT_ unit. But, much, much more.
Many times faster, Mouse support, Windowing, Off screen buffered writing, etc...

**_QCRTNM.PAS_** Just QCRT.PAS with mouse support ripped out. I had a couple programs that
would get really flakey on computers that didn't have mice. So instead of fixing those 
programs, it turned out to be easier just gut the QCRT mouse support.

**_STRASM.PAS_** Super fast, pascal inline assembler code for manipulating pascal strings.

**_STRSIZE.PAS_** Just a unit wrapper for STRSIZE.INC.
