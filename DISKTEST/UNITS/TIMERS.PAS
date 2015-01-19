{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Timers; { version 4.22a }
{$A+,E+,F+,N+,O-,R-,S-}

interface

  type
    TTimeRec = record
      MilliSec  : word;
      Second    : byte;
      Minute    : byte;
      Hour      : byte;
    end;

  const
    MaxWatch = 4;

  procedure StartWatch  ( Number : word );
  procedure StopWatch   ( Number : word );
  procedure ResumeWatch ( Number : word );
  procedure ResetWatch  ( Number : word );
  procedure ClearWatch  ( Number : word );
  procedure ReadWatch   ( Number : word; var Elapsed : TTimeRec );

  function InitEvent ( Proc : Pointer; Multiple : boolean; Wait : LongInt ) : boolean;
  function AlterEvent ( Proc : Pointer; Wait : LongInt ) : boolean;
  function DoneEvent ( Proc : Pointer ) : boolean;

implementation

  uses Dos;

  type
    TWatch = record
      Active   : Boolean;
      Reserved : byte;
      D1, D2   : word;
    end;
    PEvent = ^TEvent;
    TEvent = record
      Multiple : Boolean;
      Reserved : byte;
      Data     : LongInt;
      Count    : longInt;
      Proc     : procedure;
      Prior    : PEvent;
      Next     : PEvent;
    end;

  const
    TWatchSize  = SizeOf(TWatch);
    TEventSize  = Sizeof(TEvent);
    OldTimerVec : procedure = nil;
    OldExitProc : pointer = nil;
    Remaining   : word = 1;
    TimerSlice  : word = 10;

  var
    Watches   : array[0..MaxWatch] of TWatch;
    FEvent,
    LEvent    : PEvent;
    EventHold : word;

  procedure StartWatch ( Number : word );
    begin
      ResetWatch(Number);
      ResumeWatch(Number);
    end;

  procedure StopWatch ( Number : word );
    begin
      if Number <= MaxWatch then
        Watches[Number].Active := False
    end;

  procedure ResumeWatch ( Number : word );
    begin
      if Number <= MaxWatch then
        Watches[Number].Active := True
    end;

  procedure ResetWatch  ( Number : word );
    begin
      StopWatch( Number );
      ClearWatch( Number );
    end;

  procedure ClearWatch  ( Number : word );
    begin
      if Number > MaxWatch then Exit;
      Watches[Number].D1 := 0;
      Watches[Number].D2 := 0;
    end;

  procedure ReadWatch ( Number : word; var Elapsed : TTimeRec );
    var
      R : Real;
    begin
      if Number > MaxWatch then Exit;
      R := Int(LongInt((@Watches[Number].D1)^) * ( 55 / TimerSlice )) * 0.001;
      with Elapsed do
        begin
          MilliSec := Trunc(Frac(R) * 1000);
          R := Int(R) / 60;
          Second := Trunc(Frac(R) * 60);
          R := Int(R) / 60;
          Minute := Trunc(Frac(R) * 60);
          Hour := Trunc(Int(R));
        end;
    end;

  function InitEvent ( Proc : Pointer; Multiple : boolean; Wait : LongInt ) : boolean;
    var
      Event : PEvent;
    begin
      InitEvent := False;
      if MaxAvail < TEventSize * 2 then Exit;
      Wait := Round(Wait * (1 / 0.055 / TimerSlice));
      Inc(EventHold);
      GetMem(Event, TEventSize);
      Event^.Multiple := Multiple;
      Event^.Data  := Wait;
      Event^.Count := Wait;
      @Event^.Proc := Proc;
      Event^.Next := nil;
      Event^.Prior := LEvent;
      if Assigned(Event^.Prior) then
        Event^.Prior^.Next := Event;
      LEvent := Event;
      if FEvent = nil then FEvent := LEvent;
      Dec(EventHold);
      InitEvent := True;
    end;

  function AlterEvent ( Proc : Pointer; Wait : LongInt ) : boolean;
    var
      Event : PEvent;
    begin
      AlterEvent := False;
      Event := FEvent;
      Inc(EventHold);
      While Assigned(Event) and (@Event^.Proc <> Proc) do
        Event := Event^.Next;
      Dec(EventHold);
      if Not Assigned(Event) then Exit;
      Inc(EventHold);
      Event^.Count := Round(Wait * (1 / 0.055 / TimerSlice));
      Dec(EventHold);
      AlterEvent := True;
    end;

  function DoneEvent ( Proc : Pointer ) : boolean;
    var
      Event : PEvent;
    begin
      DoneEvent := False;
      Event := FEvent;
      Inc(Event);
      While Assigned(Event) and (@Event^.Proc <> Proc) do
        Event := Event^.Next;
      Dec(Event);
      if Not Assigned(Event) then Exit;
      Inc(EventHold);
      if Assigned(Event^.Prior) then
        Event^.Prior^.Next := Event^.Next
      else
        FEvent := Event^.Next;
      if Assigned(Event^.Next) then
         Event^.Next^.Prior := Event^.Prior
      else
         LEvent := Event^.Prior;
      FreeMem(Event, TEventSize);
      Dec(EventHold);
      DoneEvent := True;
    end;

  procedure CheckEvents;
    var
      Event, MEvent : PEvent;
    begin
      Event := FEvent;
      While Event <> nil do
        With Event^ do
          begin
            MEvent := Next;
            Dec(Data);
            if Data = 0 then
              begin
                Proc;
                if Multiple then
                  Data := Count
                else
                  DoneEvent(@Proc);
              end;
            Event := MEvent;
          end;
    end;
{ ************************************************************************* }
{$F+}
  procedure TimerVec; interrupt; assembler;
    asm
      CLI
      MOV  CX, MaxWatch
      MOV  DI, OFFSET Watches
    @@Watch1:
      CMP  TWatch([DI]).Active, False
      JE   @@Watch2
      INC  TWatch([DI]).D1
      JNZ  @@Watch2
      INC  TWatch([DI]).D2
    @@Watch2:
      ADD  DI, TWatchSize
      DEC  CX
      JNZ  @@Watch1

      INC  EventHold
      CMP  EventHold, 1
      JNE  @@Check
      CALL CheckEvents
    @@Check:
      DEC  EventHold
      DEC  Remaining
      JZ   @@CallOldVec
      MOV  AL, 20h
      OUT  20h, AL
      JMP  @@Done
    @@CallOldVec:
      MOV  AX, TimerSlice
      MOV  Remaining, AX
      PUSHF
      CALL OldTimerVec
    @@Done:
      STI
    end;
{$F-}

  procedure SetTimerRate ( Rate : word ); assembler;
    asm
      MOV  DX, 43h
      MOV  AL, 00110110b
      OUT  DX, AL
      MOV  AX, Rate
      MOV  DX, 40h
      OUT  DX, AL
      MOV  AL, AH
      OUT  DX, AL
    end;

  procedure DoneTimers; far;
    begin
      SetIntVec ( $08, @OldTimerVec );
      ExitProc := OldExitProc;
      SetTimerRate ( $FFFF );
    end;

  procedure InitTimers;
    var
      I : Byte;
    begin
      EventHold := 0;
      FEvent    := nil;
      LEvent    := nil;
      for I := 0 to MaxWatch do ResetWatch ( I );
      GetIntVec ( $08, @OldTimerVec );
      OldExitProc := ExitProc;
      ExitProc := @DoneTimers;
      SetIntVec ( $08, @TimerVec );
      SetTimerRate(($10000 div TimerSlice) - 1);
    end;

begin
  InitTimers;
end.