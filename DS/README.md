This project and related files are subject to the terms of the **_Mozilla Public License_**, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

Copyright 1990-2015 Jerome Shidel.

### Directory Scroller

**_DS.PAS_** Was an experimental smooth scrolling text mode directory listing program. It 
was built on an earlier version of D.PAS (I think version 5.00). It was utilizing a cool
trick I had learned to smoothly scroll text onto the screen. Like watching movie credits. 
Only not in graphics, but in text mode. It cannot smooth scroll if running in a terminal
window. It requires a real DOS environment to work correctly. I don't know if it will function
inside a virtual machine either. Anyhow, It originally used Borland's CRT unit. Which no longer
works on fast computers. I swapped out the references for my QCRT unit. It now compiles and
runs. But, I don't know if it still works or not.  