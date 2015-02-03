{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

   const
     Version  = ' Program Manager #7.2 ';
     Escape   =  Chr(175)+'Quit'   +Chr(174);
     Enter    =  Chr(175)+'Execute'+Chr(174);
     Edit     =  Chr(175)+'Edit'   +Chr(174);
     Help     =  Chr(175)+'Help'   +Chr(174);
     Search   =  Chr(175)+'Search' +Chr(174);
     Spc      = '                                                      ';
     MaxList  = 200;
     BlankOut = 300;

   type
     ColorArray = array [0..20,1..2] of Integer;
     Screen     = array [1..25,1..80] of word;
     MenuRec    = record
                     Discription : String[45];
                     Location    : LongInt;
                  end;
     MenuList   = Array [0..MaxList] of MenuRec;
     MenuFile   = File of MenuRec;
     MenuData   = File of Char;

   var
      Colors          : ColorArray;
      ColorScreen     : Screen absolute $B800:$0000;
      KeepScreen      : Array[1..2] of Screen;
      ScrPtr          : ^Screen;
      OpPath          : DirStr;
      Menus           : Array [1..126] of String[8];
      TotMenus        : Integer;
      CurrentMnu      : Integer;
      MenuPag         : Integer;
      DisNum, DisPag  : Integer;
      MenuDis         : MenuList; {Menu Discriptions array}
      TotDis, TotWait : Integer;
      Title           : String;
      MouseSpeed      : Integer;
      AutoReLoad      : Boolean;
      Tag             : array [1..MaxList] of boolean;
      Data, SrchStr   : String;
      OldX, OldY,
      OldColor        : integer;
      LoadAllIsOn     : Boolean;
      Qt              : boolean;

procedure DefaultSetup;
   begin
      Colors[0,1]  :=  1; Colors[0,2] := 7; {Version color         }
      Colors[1, 1] :=  7; Colors[1, 2] := 0; {MainScreen BackDrop   }
      Colors[2, 1] :=  6; Colors[2, 2] := 0; {MainScreen Border     }
      Colors[3, 1] :=  7; Colors[3, 2] := 1; {MainScreen Time       }
      Colors[4, 1] :=  2; Colors[4, 2] := 0; {MainScreen Title      }
      Colors[5, 1] := 14; Colors[5, 2] := 1; {Quit & Execute        }
      Colors[6, 1] :=  4; Colors[6, 2] := 0; {Scroll Bar Number 1   }
      Colors[7, 1] :=  2; Colors[7, 2] := 0; {Scroll Bar Number 2   }
      Colors[8, 1] :=  0; Colors[8, 2] := 7; {Menus Availiable      }
      Colors[9, 1] :=  4; Colors[9, 2] := 0; {Menus List            }
      Colors[10,1] :=  3; Colors[10,2] := 0; {Menus' Discriptions   }
      Colors[11,1] := 11; Colors[11,2] := 0; {Menus' Discriptions   }
      Colors[12,1] := 12; Colors[12,2] := 1; {Menu Options          }
      Colors[13,1] := 12; Colors[13,2] := 0; {Tag Color             }
      Colors[14,1] := 15; Colors[14,2] := 1; {Help Window Color     }
      Colors[15,1] := 15; Colors[15,2] := 0; {Edit Window Color     }
      CurrentMnu   :=  0;
      MenuPag      :=  0;
      TotMenus     :=  0;
      DisNum       :=  0;
      DisPag       :=  0;
      TotDis       :=  0;
      Title        := 'No Name';
      TotWait      :=  0;
      MouseSpeed   :=  30;
      AutoReLoad   := True;
      SrchStr      := '';
      MenuDis[0].Discription := '';
      LoadAllIsOn  := False;
   end; {DefaultSetup}


