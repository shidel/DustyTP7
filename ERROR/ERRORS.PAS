{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program ErrorCodes;

  function HEXbyte ( B : byte ) : String; assembler;
    asm
      LES DI, @RESULT
      MOV AL, $02
      MOV ES:[DI], AL
      MOV AL, B
      MOV AH, B
      AND AH, $0F
      AND AL, $F0
      MOV CL, $04
      SHR AL, CL
      CMP AL, $9
      JNA @@1
      ADD AL, $07
    @@1:
      ADD AL, $30
      CMP AH, $9
      JNA @@2
      ADD AH, $07
    @@2:
      ADD AH, $30
      MOV ES:[DI + 1], AX
    end;

  function HEXWord ( W : Word ) : String;
    begin
      HEXWord := HEXByte(Hi(W)) + HEXByte(Lo(W));
    end;

  function HEXLong ( L : LongInt ) : String;
    type
      WordCast = array[0..1] of word;
    begin
      HEXLong := HEXWord(WordCast(L)[1]) + HEXWord(WordCast(L)[0]);
    end;

  function HexPtr  ( P : Pointer ) : String;
    begin
      HexPtr := HexWord(Seg(P^)) + ':' + HexWord(Ofs(P^));
    end;


  function Error(Code : integer) : pointer; assembler;
    asm
        MOV  AX, Code
        JMP  @@FindError
        JMP  @@Done
      @@FindError:  { Searchs for errorcode AX }
        MOV  DI, OFFSET @@ErrorData
      @@FindError2:
        MOV  CX, CS:[DI]
        ADD  DI, 2
        CMP  CX, AX
        JE   @@FoundError
        CMP  CX, 0
        JE   @@FoundError
      @@FindError3:
        MOV  DL, CS:[DI]
        INC  DI
        CMP  DL, 0
        JE   @@FindError2
        JMP  @@FindError3
      @@FoundError:
        CMP   CX, AX
        JNE   @@NotFound
        MOV   DX, CS
        MOV   AX, DI
        JE    @@Done
      @@NotFound:
        XOR  DX, DX
        XOR  AX, AX
        JMP  @@Done
      @@ErrorData:
        DW   01h; DB 0f0h,'Invalid function number.',1
                  DB 0f1h,'Bad command: Invalid request to controller.',0
        DW   02h; DB 0f0h,'File not found.',1
                  DB 0f1h,'Bad address mark.',0
        DW   03h; DB 0f0h,'Path not found.',1
                  DB 0f1h,'Write protect: Attempted to write on write-protected diskette.',0
        DW   04h; DB 0f0h,'Too many files open.',1
                  DB 0f1h,'Sector ID bad or not found.',0
        DW   05h; DB 0f0h,'File access denied.',1
                  DB 0f1h,'Reset failed ÝATÞ.',0
        DW   06h; DB 0f0h,'Invalid file handle.',0
        DW   07h; DB 0f0h,'Memory control blocks destroyed.',0
        DW   08h; DB 0f0h,'Insufficient memory.',1
                  DB 0f1h,'DMA failure.',0
        DW   09h; DB 0f0h,'Invalid memory block address.',1
                  DB 0f1h,'DMA overrun: Attempted to write across a 64K-byte boundary.',0
        DW   0Ah; DB 0f0h,'Invalid environment.',0
        DW   0Bh; DB 0f0h,'Invalid format.',1
                  DB 0f1h,'Bad track flag encountered ÝATÞ.',0
        DW   0Ch; DB 0f0h,'Invalid file access code.',0
        DW   0Dh; DB 0f0h,'Invalid data.',0
        DW   0Eh; DB 0f0h,'(not used)',0
        DW   0Fh; DB 0f0h,'Invalid drive specified.',0
        DW   10h; DB 0f0h,'Can''t remove current directory.',1
                  DB 0f1h,'Bad CRC: Invalid CRC when data checked.',0
        DW   11h; DB 0f0h,'Not same device, cannot rename across drives.',0
                  DB 0f1h,'Data corrected: Recoverable error found/corrected by ECC algorithm ÝATÞ.',0
        DW   12h; DB 0f0h,'No more matching files.',0
        { DOS 3.x error codes }
        DW   13H; DB 0f0h,'Attempted write on write-protected disk.',0
        DW   14H; DB 0f0h,'Unknown unit ID.',0
        DW   15H; DB 0f0h,'Disk drive not ready.',0
        DW   16H; DB 0f0h,'Unknown command.',0
        DW   17H; DB 0f0h,'Disk data error (CRC error).',0
        DW   18H; DB 0f0h,'Bad request structure length.',0
        DW   19H; DB 0f0h,'Disk seek error.',0
        DW   1aH; DB 0f0h,'Unknown disk media type.',0
        DW   1bH; DB 0f0h,'Disk sector not found.',0
        DW   1cH; DB 0f0h,'Printer out of paper.',0
        DW   1dH; DB 0f0h,'Write fault error.',0
        DW   1eH; DB 0f0h,'Read fault error.',0
        DW   1fH; DB 0f0h,'General failure.',0
        DW   20H; DB 0f0h,'File sharing violation.',1
                  DB 0f1h,'Controller failure.',0
        DW   21H; DB 0f0h,'File locking violation.',0
        DW   22H; DB 0f0h,'Invalid disk change.',0
        DW   23H; DB 0f0h,'FCB unavailable (too many FCBs).',0
        DW   24H; DB 0f0h,'Sharing buffer overflow.',0
        DW   25H; DB 0f0h,'(reserved)',0
        DW   26H; DB 0f0h,'Unable to complete file operation.',0
        DW   27H; DB 0f0h,'(reserved)',0
        DW   28H; DB 0f0h,'(reserved)',0
        DW   29H; DB 0f0h,'(reserved)',0
        DW   2AH; DB 0f0h,'(reserved)',0
        DW   2BH; DB 0f0h,'(reserved)',0
        DW   2CH; DB 0f0h,'(reserved)',0
        DW   2DH; DB 0f0h,'(reserved)',0
        DW   2EH; DB 0f0h,'(reserved)',0
        DW   2FH; DB 0f0h,'(reserved)',0
        DW   30H; DB 0f0h,'(reserved)',0
        DW   31H; DB 0f0h,'(reserved)',0
        DW   32H; DB 0f0h,'Network request not supported.',0
        DW   33H; DB 0f0h,'Remote computer not listening.',0
        DW   34H; DB 0f0h,'Duplicate name on network.',0
        DW   35H; DB 0f0h,'Network name not found.',0
        DW   36H; DB 0f0h,'Network busy.',0
        DW   37H; DB 0f0h,'Network device no longer exists.',0
        DW   38H; DB 0f0h,'Net BIOS command limit exceeded.',0
        DW   39H; DB 0f0h,'Network adapter hardware error.',0
        DW   3aH; DB 0f0h,'Incorrect response from network.',0
        DW   3bH; DB 0f0h,'Unexpected network error.',0
        DW   3cH; DB 0f0h,'Incompatible remote adapter.',0
        DW   3dH; DB 0f0h,'Print queue full.',0
        DW   3eH; DB 0f0h,'Not enough space for print file.',0
        DW   3fH; DB 0f0h,'Print file was deleted.',0
        DW   40H; DB 0f0h,'Network name was deleted.',1
                  DB 0f1h,'Bad seek.  Requested track not found.',0
        DW   41H; DB 0f0h,'Access denied.',0
        DW   42H; DB 0f0h,'Incorrect network device type.',0
        DW   43H; DB 0f0h,'Network name not found.',0
        DW   44H; DB 0f0h,'Network name limit exceeded.',0
        DW   45H; DB 0f0h,'Net BIOS session limit exceeded.',0
        DW   46H; DB 0f0h,'Temporarily paused.',0
        DW   47H; DB 0f0h,'Network request not accepted.',0
        DW   48H; DB 0f0h,'Print or disk redirection is paused.',0
        DW   49H; DB 0f0h,'(reserved)',0
        DW   4AH; DB 0f0h,'(reserved)',0
        DW   4BH; DB 0f0h,'(reserved)',0
        DW   4CH; DB 0f0h,'(reserved)',0
        DW   4DH; DB 0f0h,'(reserved)',0
        DW   4EH; DB 0f0h,'(reserved)',0
        DW   4FH; DB 0f0h,'(reserved)',0
        DW   50H; DB 0f0h,'File already exists.',0
        DW   51H; DB 0f0h,'(reserved)',0
        DW   52H; DB 0f0h,'Cannot make directory entry.',0
        DW   53H; DB 0f0h,'"Fail" error from INT 24H Critical Error handler.',0
        DW   54H; DB 0f0h,'Too many redirections.',0
        DW   55H; DB 0f0h,'Duplicate redirection.',0
        DW   56H; DB 0f0h,'Invalid password.',0
        DW   57H; DB 0f0h,'Invalid parameter.',0
        DW   58H; DB 0f0h,'Network data fault.',0
        DW   59H; DB 0f0h,'Function not supported by the network.',0
        DW   5AH; DB 0f0h,'Required system component not installed.',0
        DW   64h; DB 0f2h,'Disk read error.',0
        DW   65h; DB 0f2h,'Disk write error.',0
        DW   66h; DB 0f2h,'File not assigned.',0
        DW   67h; DB 0f2h,'File not open.',0
        DW   68h; DB 0f2h,'File not open for input.',0
        DW   69h; DB 0f2h,'File not open for output.',0
        DW   6Ah; DB 0f2h,'Invalid numeric format.',0
        DW   80H; DB 0f1h,'Time out.  Drive did not respond.',0
        DW   96h; DB 0f2h,'Disk is write-protected.',0
        DW   97h; DB 0f2h,'Bad drive request struct length.',0
        DW   98h; DB 0f2h,'Drive not ready.',0
        DW   9Ah; DB 0f2h,'CRC error in data.',0
        DW   9Ch; DB 0f2h,'Disk seek error.',0
        DW   9Dh; DB 0f2h,'Unknown media type.',0
        DW   9Eh; DB 0f2h,'Sector Not Found.',0
        DW   9Fh; DB 0f2h,'Printer out of paper.',0
        DW  0A0h; DB 0f2h,'Device write fault.',0
        DW  0A1h; DB 0f2h,'Device read fault.',0
        DW  0A2h; DB 0f2h,'Hardware failure.',0
        DW  0aaH; DB 0f1h,'Drive not ready ÝATÞ.',0
        DW  0bbH; DB 0f1h,'Undefined error ÝATÞ.',0
        DW  0C8h; DB 0f2h,'Division by zero.',0
        DW  0C9h; DB 0f2h,'Range check error.',0
        DW  0CAh; DB 0f2h,'Stack overflow error.',0
        DW  0CBh; DB 0f2h,'Heap overflow error.',0
        DW  0CCh; DB 0f2h,'Invalid pointer operation.',0
        DW  0CDh; DB 0f2h,'Floating point overflow.',0
        DW  0CEh; DB 0f2h,'Floating point underflow.',0
        DW  0CFh; DB 0f2h,'Invalid floating point operation.',0
        DW  0D0h; DB 0f2h,'Overlay manager not installed.',0
        DW  0D1h; DB 0f2h,'Overlay file read error.',0
        DW  0D2h; DB 0f2h,'Object not initialized.',0
        DW  0D3h; DB 0f2h,'Call to abstract method.',0
        DW  0D4h; DB 0f2h,'Stream registration error.',0
        DW  0D5h; DB 0f2h,'Collection index out of range.',0
        DW  0D6h; DB 0f2h,'Collection overflow error.',0
        DW  0D7h; DB 0f2h,'Arithmetic overflow error.',0
        DW  0D8h; DB 0f2h,'General Protection fault.',0
        DW  0ffH; DB 0f1h,'Sense operation failed ÝATÞ.',0
        DW   00h; DB 0f0h,'No error.',1
                  DB 0f1h,'No error on last operation.',0
      @@ErrorHeader:
        DB 'I''ve found error code ',0
        DB ', and it means:',13,10,0
      @@NoHeader:
        DB '           -- ',0
      @@DosHeader:
        DB '   MS-DOS  -- ',0
      @@BIOSHeader:
        DB '   BIOS    -- ',0
      @@TPHeader:
        DB '   PASCAL  -- ',0
      @@Instruct:
        DB 13,10,'You didn''t give me an error code, please provide one.',0
      @@CannotFind:
        DB 13,10,'I can''t find error code ',0,' anywhere.',0
      @@InvalidNumber:
        DB 13,10,'is not a valid number, and I don''t know what to do with it.',0
      @@Intro:
        DB 'Error codes version #2.0.',0
      @@CRLF:
        DB 13,10,0
      @@Done:
(*
        MOV  AX, 4C00h  { AL = Exit Code }
        INT  21h
*)
  end;

  var
    S : String;
    I : integer;
    J : integer;
    E : integer;
    P : Pointer;

begin
  WriteLn('Error codes version #2.0.');
  if ParamCount = 0 then
    WriteLn(#13#10'I can''t tell you what an error code means unless you give me one.')
  else
    for I := 1 to ParamCount do
      begin
        WriteLn;
        S := ParamStr(I);
        if UpCase(S[Length(S)]) <> 'H' then
          Val (S, J, E)
        else
          Val('$' + Copy(S, 1, Length(S) - 1), J, E);
        if E <> 0 then
          begin
            WriteLn('Sorry, but "', S, '" is not a valid number.');
          end
        else
          begin
            Str(J, S);
            S := S + ', (' + HexWord(J) + 'h)';
            P := Error ( J );
            if Assigned(P) then
              begin
                WriteLn('I''ve found error code "', S, '", and it means:');
                WriteLn;
                repeat
                  Case Byte(P^) of
                    $F0 : Write('  DOS    -- ');
                    $F1 : Write('  BIOS   -- ');
                    $F2 : Write('  PASCAL -- ');
                    $F3 : Write('            ');
                  else
                          Write('         -- ');
                  end;
                  INC(LongInt(P));
                  while (Byte(P^) <> 0) and (Byte(P^) <> 1) do
                    begin
                      Write (Char(P^));
                      Inc(LongInt(P));
                    end;
                  if Byte(P^) = 1 then
                    begin
                      Inc(LongInt(P));
                    end;
                  WriteLn;
                until Byte(P^) = 0;
              end
            else
              WriteLn('Sorry, but I couldn''t find error code "',S,'" anywhere.');
          end;
      end;
end.