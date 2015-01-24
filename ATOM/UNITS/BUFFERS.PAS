{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Buffers;

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$O+,F+}

interface

  type
    ByteCast = array[1..$FFFF] of byte;
    PCircularBuffer = ^CircularBuffer;
    CircularBuffer = Object
      constructor  Init ( Size : word );
      destructor   Done;
      function     Result : integer;
      procedure    Clear;
      function     FreeSpace        : word;
      function     Empty            : boolean;
      function     Put ( B : Byte ) : boolean;
      function     Get              : Byte;
      function     PreviewStr ( Len : byte ) : String;
    private
      BufferPtr  : Pointer;
      ErrorValue : integer;
      BufferSize,
      Count,
      Head,
      Tail       : word;
    end;

implementation

  constructor CircularBuffer.Init;
    begin
      BufferPtr  := Nil;
      ErrorValue := 0;
      if MaxAvail > 1024 then
        begin
          if MaxAvail < Size then Size := MaxAvail - 512;
          BufferSize := Size;
          GetMem ( BufferPtr, BufferSize );
        end
      else
        begin
          BufferSize := 0;
          ErrorValue := 8;
        end;
      Clear;
    end;

  destructor CircularBuffer.Done;
    begin
      ErrorValue := 0;
      if BufferPtr <> nil then FreeMem( BufferPtr, BufferSize );
      BufferPtr := nil;
    end;

  function CircularBuffer.Result : integer;
    begin
      Result := ErrorValue;
    end;

  procedure CircularBuffer.Clear;
    begin
      Count := 0;
      if BufferPtr <> nil then
        begin
          ErrorValue := 0;
          FillChar ( BufferPtr^, BufferSize, #0 );
          Head  := 1;
          Tail  := 1;
        end
      else
        ErrorValue := 204;
    end;

  function CircularBuffer.FreeSpace : word;
    begin
      ErrorValue := 0;
      FreeSpace := BufferSize - Count;
    end;

  function CircularBuffer.Empty : Boolean;
    begin
      Empty := Count = 0;
    end;

  function CircularBuffer.Put ( B : Byte ) : boolean;
    begin
      if BufferPtr = nil then
        begin
          ErrorValue := 204;
          Put := False;
          Exit;
        end;
      ErrorValue := 0;
      if Count < BufferSize then
        begin
          ByteCast(BufferPtr^)[Tail] := B;
          if Tail < BufferSize then
            Inc( Tail )
          else
            Tail := 1;
          Inc ( Count );
        end
      else
        ErrorValue := 57;
      Put := ErrorValue = 0;
    end;

  function CircularBuffer.Get : Byte;
    begin
      if BufferPtr = nil then
        begin
          ErrorValue := 204;
          Get        := 0;
          Exit;
        end;
      ErrorValue := 0;
      if Count > 0 then
        begin
          Get := ByteCast(BufferPtr^)[Head];
          if Head < BufferSize then
            Inc( Head )
          else
            Head := 1;
          Dec ( Count );
        end
      else
        begin
          ErrorValue := 58;
          Get := 0;
        end;
    end;

  function CircularBuffer.PreViewStr( Len : Byte ) : String;
    var
      S             : String;
      THead, TCount : word;
    begin
      S := '';
      if BufferPtr = nil then
        begin
          ErrorValue := 204;
          Exit;
        end;
      ErrorValue := 0;
      THead := Head;
      TCount := Count;
      While ( TCount > 0 ) and ( Len > 0 ) do
        begin
          S := S + Char(ByteCast(BufferPtr^)[THead]);
          if THead < BufferSize then
            Inc( THead )
          else
            THead := 1;
          Dec ( TCount );
          Dec ( Len );
        end;
      PreviewStr := S;
    end;

end.
