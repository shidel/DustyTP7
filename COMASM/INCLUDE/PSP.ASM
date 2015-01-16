{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

      @@Interrupt20:         NOP; NOP;
      @@MemTop:              NOP; NOP;
      @@DosReservedArea01:   NOP;
      @@DosDispatcher:       NOP;     {if not com then Segavail and #2 belong}
      @@SegAvail:            NOP; NOP;{to DosDispatcher }
      @@DosDispatcher2:      NOP; NOP;
      @@TerminateAddress:    NOP; NOP; NOP; NOP;
      @@ControlBreak:        NOP; NOP; NOP; NOP;
      @@CriticalError:       NOP; NOP; NOP; NOP;
      @@DosReservedArea02:   NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP;
      @@EnvSeg:              NOP; NOP;
      @@DosReservedArea03:   NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP;
      @@FormatedParamArea01: NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP;
      @@FormatedParamArea02: NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
      @@ParamString:         NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
      @@EndOfPSP:
