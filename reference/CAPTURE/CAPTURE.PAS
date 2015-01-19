{$A+,B-,D+,E+,F+,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 2048,0,0}
program Capture;

{$F+}
  uses Dos, XMS;

  Const
    REG_F  = 18;
    REG_AX = 16;
    REG_BX = 14;
    REG_CX = 12;
    REG_DX = 10;
    REG_SI = 08;
    REG_DI = 06;
    REG_DS = 04;
    REG_ES = 02;
    REG_BP = 00;

  type
    PIntrRegisters = ^TIntrRegisters;
    TIntrRegisters = record
      case Integer of
        0: (BP, ES, DS, DI, SI, DX, CX, BX, AX, Flags : word);
        1: (Reserved : array[1..5] of word;
            DL, DH, CL, CH, BL, BH, AL, AH : Byte);
    end;

  var
    Handle : word;
    OldVec : pointer;
    Loc    : LongInt;
    REGS   : PIntrRegisters;

  procedure Int17; interrupt;
    begin
      asm
        MOV  [OFFSET REGS], BP
        MOV  [OFFSET REGS + 2], SS
      end;
      if Regs^.AH = 0 then
        begin
          WriteEMB ( Handle, Loc, Regs^.AL, 1 );
          Regs^.AH := $80 or $10;
          if XMSResult <> 0 then Regs^.AH := Regs^.AH  or $01 else
            Inc(Loc);
        end
      else;
        Regs^.AH := $80 or $10;
    end;

  procedure Main( FileName : String );
    var
      F : Text;
      I : LongInt;
      C : Char;
    begin
      Loc := 0;
      GetIntVec ( $17, OldVec );
      SetIntVec ( $17, @Int17 );
      Exec(GetENV('COMSPEC'), '');
      SetIntVec ( $17, OldVec );
      Assign(F, FileName );
      {$I-}
      Append(F);
      {$I+}
      if IoResult <> 0 then ReWrite(F);
      For I := 0 to Loc do
        begin
          ReadEMB ( Handle, I, C, Sizeof(C) );
          Write ( F, C );
        end;
      Close(F);
      DisposeEMB ( Handle );
    end;


begin
  if ParamCount = 0 then
    WriteLn ( 'CAPTURE [filename]')
  else
  if Not XMSPresent then
    WriteLn ( 'XMS Memory not present.' )
  else
  if XMSMaxAvail = 0 then
    WriteLn ( 'NO XMS memory available')
  else
    begin
      Handle := NewEMB ( XMSMaxAvail );
      if XMSResult <> 0 then
        WriteLn('XMS error')
      else
        Main( FExpand(ParamStr(1)) );
    end;

end.