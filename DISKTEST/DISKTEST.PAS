program DiskTest;

  uses QCrt, Dos, Timers;

  type
    PBuf = ^TBuf;
    TBuf = array[0..$FFF0] of byte;

  var
    Buf : PBuf;
    F : File;
    Name : String;

procedure WriteTest;
  var
    Size, Free : LongInt;
    Speed : Real;
    Elps : TTimeRec;
  begin
    Free := ((DiskFree(Ord(Name[1]) - 64) - 10240) div Sizeof(TBuf) ) * Sizeof(TBuf);
    Size := Free;
    Write ('Writing ');
    StartWatch(1);
    while Free >= Sizeof(TBuf) do
      begin
        GotoXY (9, WhereY);
        Write ((Size - Free) / Size * 100:1:0, '%');
        BlockWrite(F, Buf^, Sizeof(TBuf));
        Dec(Free, Sizeof(TBuf));
      end;
    StopWatch ( 1 );
    ReadWatch (1, Elps);
    with Elps do
      Speed := (Size/1024) / (MilliSec / 100 + Second + Minute * 60 + Hour * 360);
    GotoXY ( 1, WhereY );
    with Elps do
      WriteLn ('Wrote ', Size div 1024, 'kb, in ', (MilliSec div 100 + Second + Minute * 60 + Hour * 360),
       ' seconds, at ', Speed:1:1, 'kb per second');
  end;


procedure ReadTest;
  var
    Size, Free : LongInt;
    Speed : Real;
    Elps : TTimeRec;
  begin
    Seek(F, 0);
    Free := FileSize(F);
    Size := Free;
    Write ('Reading ');
    StartWatch(1);
    while Free >= Sizeof(TBuf) do
      begin
        GotoXY (9, WhereY);
        Write ((Size - Free) / Size * 100:1:0, '%');
        Blockread(F, Buf^, Sizeof(TBuf));
        Dec(Free, Sizeof(TBuf));
      end;
    StopWatch ( 1 );
    ReadWatch (1, Elps);
    with Elps do
      Speed := (Size/1024) / (MilliSec / 100 + Second + Minute * 60 + Hour * 360);
    GotoXY ( 1, WhereY );
    with Elps do
      WriteLn ('Read ', Size div 1024, 'kb, in ', (MilliSec div 100 + Second + Minute * 60 + Hour * 360),
       ' seconds, at ', Speed:1:1, 'kb per second');
  end;

begin
  GetMem(Buf, Sizeof(TBuf));
  FillChar(Buf^, Sizeof(TBuf), 0);
  Name := FExpand(ParamStr(1) + 'DISKTEST.$$$');
  WriteLn ( 'Testing file ', Name);
  Assign(F, Name);
  ReWrite(F,1);
  WriteTest;
  ReadTest;
  Close(F);
  Erase(F);
end.