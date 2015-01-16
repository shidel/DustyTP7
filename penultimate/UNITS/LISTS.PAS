{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Lists;

interface

  uses Files;

  const
    isUndefined = -3;
    isUnknown   = -2;
    isLess      = -1;
    isEqual     =  0;
    isMore      = +1;

  type
    PEntry = ^TEntry;
    TEntry = object
        Prior, Next : PEntry;
        Tag         : boolean;
      constructor Init;
      destructor  Done; virtual;
      function    NewSelf : PEntry; virtual;
      function    Load(var F : TFile) : boolean; virtual;
      function    Save(var F : TFile) : boolean; virtual;
      function    Compare (var WithEntry : PEntry ) : integer; virtual;
    end;

    PListOfEntry = ^TListOfEntry;
    TListOfEntry = object (TEntry)
        First, Current, Last : PEntry;
        Top, Bottom          : PEntry;
        PageHeight           : LongInt;
      constructor Init;
      destructor  Done; virtual;
      function    NewSelf : PEntry; virtual;
      function    NewItem : PEntry; virtual;
      function    Load(var F : TFile) : boolean; virtual;
      function    Save(var F : TFile) : boolean; virtual;
      procedure   Append(AEntry : PEntry); virtual;
      procedure   Insert(AEntry : PEntry); virtual;
      procedure   Add(AEntry : PEntry); virtual;
      procedure   Remove; virtual;
      function    WhereIndex : LongInt; virtual;
      procedure   GotoIndex( Location : LongInt ); virtual;
      function    WhereIndexOf(AEntry : PEntry) : LongInt; virtual;
      function    GetIndexOf( Location : LongInt ) : PEntry; virtual;
      function    Count : LongInt; virtual;
      procedure   Repaginate(APageHeight : LongInt); virtual;
      procedure   UntagAll; virtual;
      procedure   TagAll; virtual;
      procedure   ListHome; virtual;
      procedure   ListEnd; virtual;
      procedure   ListPageUp; virtual;
      procedure   ListPageDown; virtual;
      procedure   ListUp; virtual;
      procedure   ListDown; virtual;
    end;

implementation

  constructor TEntry.Init;
    begin
      Prior  := nil;
      Next   := nil;
      Tag    := False;
    end;

  destructor TEntry.Done;
    begin
      if Assigned(Prior) then
        begin
          Prior^.Next := nil;
          Dispose(Prior, Done);
          Prior := nil;
        end;
      if Assigned(Next) then
        begin
          Next^.Prior := nil;
          Dispose(Next, Done);
          Next := nil;
        end;
    end;

  function TEntry.Load(var F : TFile) : boolean;
    begin
      if F.IOResult = 0 then F.ReadBoolean(Tag);
      Load := F.IOResult = 0;
    end;

  function TEntry.Save(var F : TFile) : boolean;
    begin
      if F.IOResult = 0 then F.WriteBoolean(Tag);
      Save := F.IOResult = 0;
    end;

  function TEntry.NewSelf : PEntry;
    begin
      if MaxAvail > Sizeof(TEntry) then
        NewSelf := New(PEntry, Init)
      else
        NewSelf := nil;
    end;

  function TEntry.Compare (var WithEntry : PEntry ) : integer;
    begin
      if Assigned(WithEntry) then
        Compare := isUnknown
      else
        Compare := isUndefined;
    end;

  { ListOfEntry Controller }
  constructor TListOfEntry.Init;
    begin
      inherited Init;
      First      := nil;
      Current    := nil;
      Last       := nil;
      Top        := nil;
      Bottom     := nil;
      PageHeight := 10;
    end;

  destructor  TListOfEntry.Done;
    begin
      Last    := nil;
      Current := nil;
      if Assigned(First) then Dispose(First, Done);
      First   := nil;
      Top     := nil;
      Bottom  := nil;
    end;

  function TListOfEntry.NewSelf : PEntry;
    begin
      if MaxAvail > Sizeof(TEntry) then
        NewSelf := New(PListOfEntry, Init)
      else
        NewSelf := nil;
    end;

  function TListOfEntry.NewItem : PEntry;
    begin
      if MaxAvail > Sizeof(TEntry) then
        NewItem := New(PEntry, Init)
      else
        NewItem := nil;
    end;

  function TListOfEntry.Load(var F : TFile) : boolean;
    var
      Temp : PEntry;
      Flag : boolean;
      TIndex, CIndex, BIndex : LongInt;
    begin
      Load := False;
      inherited Load(F);
      if F.IOResult <> 0 then Exit;
      PageHeight := 0;
      repeat
        F.ReadBoolean(Flag);
        if (F.IOResult = 0) and Flag then
          begin
            Temp := NewItem;
            if Assigned(Temp) then
              begin
                if Temp^.Load(F) then
                  Append(Temp)
                else
                  Dispose(Temp, Done);
              end
            else
              F.SetIOResult(8); { Insufficient Memory }
          end;
      until (Flag = False) or (F.IOResult <> 0);
      if F.IOResult = 0 then F.ReadLongInt(TIndex);
      if F.IOResult = 0 then F.ReadLongInt(CIndex);
      if F.IOResult = 0 then F.ReadLongInt(BIndex);
      if F.IOResult <> 0 then Exit;
      F.ReadLongInt(PageHeight);
      if F.IOResult <> 0 then Exit;
      Top     := GetIndexOf(TIndex);
      Current := GetIndexOf(CIndex);
      Bottom  := GetIndexOf(BIndex);
      Repaginate(PageHeight);
      Load := True;
    end;

  function TListOfEntry.Save(var F : TFile) : boolean;
    var
      Index : LongInt;
      Temp : PEntry;
      Flag : Boolean;
    begin
      Save := False;
      inherited Save(F);
      if F.IOResult <> 0 then Exit;
      Temp := First;
      repeat
        Flag := Assigned(Temp);
        F.WriteBoolean(Flag);
        if (F.IOResult = 0) and Flag then Temp^.Save(F);
        if Assigned(Temp) then Temp := Temp^.Next;
      until (Flag = False) or (F.IOResult <> 0);
      if F.IOResult <> 0 then Exit;
      Index := WhereIndexOf(Top);
      F.WriteLongInt(Index);
      if F.IOResult <> 0 then Exit;
      Index := WhereIndexOf(Current);
      F.WriteLongInt(Index);
      if F.IOResult <> 0 then Exit;
      Index := WhereIndexOf(Bottom);
      F.WriteLongInt(Index);
      if F.IOResult <> 0 then Exit;
      F.WriteLongInt(PageHeight);
      if F.IOResult <> 0 then Exit;
      Save := True;
    end;

  procedure TListOfEntry.Append(AEntry : PEntry);
    begin
      if Not Assigned(AEntry) then Exit;
      AEntry^.Prior := nil;
      AEntry^.Next  := nil;
      if Current = nil then Current := Last;
      if First = nil then
        begin
          First   := AEntry;
          Last    := AEntry;
          Current := AEntry;
        end
      else
        begin
          AEntry^.Next  := Current^.Next;
          AEntry^.Prior := Current;
          Current^.Next := AEntry;
          if Assigned(AEntry^.Next) then
            AEntry^.Next^.Prior := AEntry
          else
            Last := AEntry;
        end;
      Current := AEntry;
      Repaginate(PageHeight);
    end;

  procedure TListOfEntry.Insert(AEntry : PEntry);
    begin
      if Not Assigned(AEntry) then Exit;
      AEntry^.Prior := nil;
      AEntry^.Next  := nil;
      if Current = nil then Current := First;
      if First = nil then
        Append(AEntry)
      else
        begin
          AEntry^.Next  := Current;
          AEntry^.Prior := Current^.Prior;
          Current^.Prior := AEntry;
          if Assigned(AEntry^.Prior) then
            AEntry^.Prior^.Next := AEntry
          else
            First := AEntry;
          Current := AEntry;
          Repaginate(PageHeight);
        end;
    end;

  procedure TListOfEntry.Add(AEntry : PEntry);
    begin
      if Not Assigned(AEntry) then Exit;
      if First = nil then
        Append(AEntry)
      else
      if (AEntry^.Compare(Last) > isLess) or (Current = nil) then
        begin
          Current := Last;
          Append(AEntry);
        end
      else
      if AEntry^.Compare(First) = isLess then
        begin
          Current := First;
          Insert(AEntry);
        end
      else
        begin
          While Assigned(Current) and (AEntry^.Compare(Current) = isLess) do
            Current := Current^.Prior;
          While Assigned(Current) and (AEntry^.Compare(Current) > isLess) do
            Current := Current^.Next;
          if Assigned(Current) then
            Insert(AEntry)
          else
            begin
              Current := Last;
              Append(AEntry)
            end;
        end;
    end;

  procedure TListOfEntry.Remove;
    var
      AEntry : PEntry;
    begin
      AEntry := Current;
      if Not Assigned(Current) then Exit;
      if Assigned(Current^.Prior) then
        Current^.Prior^.Next := Current^.Next
      else
        First := Current^.Next;
      if Assigned(Current^.Next) then
        begin
          Current^.Next^.Prior := Current^.Prior;
          Current := Current^.Next;
        end
      else
        begin
          Last := Current^.Prior;
          Current := Current^.Prior;
        end;
      if AEntry = Bottom then Bottom := Current;
      if AEntry = Top    then Top    := Current;
      AEntry^.Next := nil;
      AEntry^.Prior := nil;
      Repaginate(PageHeight);
    end;

    function TListOfEntry.WhereIndexOf(AEntry : PEntry) : LongInt;
      var
        Mark  : PEntry;
        Index : LongInt;
      begin
        Mark := First;
        if Assigned(Mark) then
          Index := 1
        else
          Index := 0;
        while Assigned(Mark) and (Mark <> AEntry) do
          begin
            Mark := Mark^.Next;
            Inc(Index);
          end;
        if Not Assigned(Mark) then Index := 0;
        WhereIndexOf := Index;
      end;

    function TListOfEntry.WhereIndex : LongInt;
      begin
        WhereIndex := WhereIndexOf(Current);
      end;

    procedure TListOfEntry.GotoIndex( Location : LongInt );
      var
        P : PEntry;
      begin
        P := GetIndexOf(Location);
        Current := P;
        Repaginate(PageHeight);
      end;

    function TListOfEntry.GetIndexOf( Location : LongInt ) : PEntry;
      var
        Mark  : PEntry;
        Index : LongInt;
      begin
        Mark := Current;
        Index := WhereIndexOf(Mark);
        while Assigned(Mark) and Assigned(Mark^.Next) and (Index < Location) do
          begin
            Mark := Mark^.Next;
            Inc(Index);
          end;
        while Assigned(Mark) and Assigned(Mark^.Prior) and (Index > Location) do
          begin
            Mark := Mark^.Prior;
            Dec(Index);
          end;
        GetIndexOf := Mark;
      end;

    function TListOfEntry.Count : LongInt;
      var
        Mark  : PEntry;
        Index : LongInt;
      begin
        Mark  := First;
        Index := 0;
        while Assigned(Mark) do
          begin
            Mark := Mark^.Next;
            Inc(Index);
          end;
        Count := Index;
      end;

  procedure TListOfEntry.Repaginate(APageHeight : LongInt);
    var
      Dist, TIndex, BIndex, CIndex : LongInt;
    begin
      if APageHeight = 0       then Exit;
      if Not Assigned(Top)     then Top    := First;
      if Not Assigned(Bottom)  then Bottom := First;
      if Not Assigned(Current) then Current := First;
      if Not Assigned(First)   then Exit;
      PageHeight := APageHeight;
      TIndex := WhereIndexOf(Top);
      BIndex := WhereIndexOf(Bottom);
      CIndex := WhereIndexOf(Current);
      Dist   := BIndex - TIndex + 1;
      { Decrease Page Size }
      while Dist > PageHeight do
        begin
          if Assigned(Bottom^.Prior) then
            begin
              Bottom := Bottom^.Prior;
              Dec(BIndex);
            end
          else
          if Assigned(Top^.Next) then
            begin
              Top := Top^.Next;
              Inc(TIndex);
            end;
          Dec(Dist);
        end;
      { Increase Page Size }
      while Dist < PageHeight do
        begin
          if Assigned(Bottom^.Next) then
            begin
              Bottom := Bottom^.Next;
              Inc(BIndex);
            end
          else
          if Assigned(Top^.Prior) then
            begin
              Top := Top^.Prior;
              Dec(TIndex);
            end;
          Inc(Dist);
        end;
      while Assigned(Top^.Prior) and (TIndex > CIndex) do
        begin
          Dec(TIndex);
          Dec(BIndex);
          Top := Top^.Prior;
          Bottom := Bottom^.Prior;
        end;
      while Assigned(Bottom^.Next) and (BIndex < CIndex) do
        begin
          Inc(TIndex);
          Inc(BIndex);
          Top := Top^.Next;
          Bottom := Bottom^.Next;
        end;
    end;

   procedure TListOfEntry.UntagAll;
     var
       Mark : PEntry;
     begin
       Mark := First;
       While Assigned(Mark) do
         begin
           Mark^.Tag := False;
           Mark := Mark^.Next;
         end;
     end;

   procedure TListOfEntry.TagAll;
     var
       Mark : PEntry;
     begin
       Mark := First;
       While Assigned(Mark) do
         begin
           Mark^.Tag := True;
           Mark := Mark^.Next;
         end;
     end;

   procedure TListOfEntry.ListHome;
     begin
        Current := First;
        Repaginate(PageHeight);
     end;

   procedure TListOfEntry.ListEnd;
     begin
        Current := Last;
        Repaginate(PageHeight);
     end;

   procedure TListOfEntry.ListPageUp;
     var
       I : LongInt;
     begin
       If Not Assigned(Current) then Current := First;
       If Assigned(Current) then
         for I := 1 to PageHeight - 1 do
           if Assigned(Current^.Prior) then
             Current := Current^.Prior;
       Repaginate(PageHeight);
     end;

   procedure TListOfEntry.ListPageDown;
     var
       I : LongInt;
     begin
       If Not Assigned(Current) then Current := First;
       If Assigned(Current) then
         for I := 1 to PageHeight - 1 do
           if Assigned(Current^.Next) then
             Current := Current^.Next;
       Repaginate(PageHeight);
     end;

   procedure TListOfEntry.ListUp;
     begin
       If Not Assigned(Current) then Current := First;
       If Assigned(Current) and Assigned(Current^.Prior) then
         Current := Current^.Prior;
       Repaginate(PageHeight);
     end;

   procedure TListOfEntry.ListDown;
     begin
       If Not Assigned(Current) then Current := First;
       If Assigned(Current) and Assigned(Current^.Next) then
         Current := Current^.Next;
       Repaginate(PageHeight);
     end;

end.