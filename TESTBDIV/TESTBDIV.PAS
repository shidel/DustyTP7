{ Copyright 2022, Jerome Shidel }
program TestBigDivision;

{ Scalable integer division using bitwise operations }

function bigdiv(a, b : longint) : longint;

var
   n : boolean;
   r, v : longint;
   i : integer;

begin
	n := (a < 0) xor (b < 0); { either (not both) are neg, result is neg }
	WriteLn(a, '/', b);
	a := abs(a);
	b := abs(b);
	r := 0;
	for i := 31 downto 0 do begin { high bit is +/-, so skip it }
		v := b shl i;
		{ Write(a, ' ? ', v, ' = '); }

		if (v < 0) then begin
			{ Write(' ~ ') }
		end else if (v <= a) then begin
			{ Write(' ! '); }
			a := a - v;
			r := r + (1 shl i);
		end else begin
			{ Write(' _ ') }
		end;
		{ WriteLn; }
	end;
	if n then r := -r;
	WriteLn('result= ', r, ' (', a, ' remainder)');
	bigdiv := r;
end;

var
	i : longint;
begin
	for i := 1 to 10 do
		bigdiv(-1449859, 75321 * i);
end.