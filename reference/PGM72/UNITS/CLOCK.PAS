{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit clock;

{$O+,F+}
interface

  function Time : String;
  function Date ( Style : byte ) : String;

implementation

  uses Dos;

  function fStr ( I : word; P : byte ) : String;
    var
      T : String[5];
    begin
      Str ( I:P, T );
      fStr := T;
    end;

  function fStrPad ( I : word; P : byte ) : String;
    var
      T : String[5];
    begin
      Str ( I, T );
      While Length(T) < P do T := '0' + T;
      fStrPad := T;
    end;

  function fPad ( T : String; S : Byte ) : String;
    var
      J : String;
    begin
      J := '';
      While Length(T) + Length(J) < S do J := J + ' ';
      fPad := J + T;
    end;

  function Time : String;
    var
      H, M, S, N : word;
      PM : string[2];
    begin
      GetTime ( H, M, S, N );
      if H > 11 then
        begin
          PM := 'pm';
          if H > 12 then Dec ( H, 12 );
        end
      else
        PM := 'am';
      if H = 0 then H := 12;
      Time := fStr(H,2) + ':' + fStrPad(M,2) + ':' + fStrPad(S, 2) + ' ' + PM;
    end;

  const
    Days : array[0..6] of record S : String[3]; L : String[9] end =
      ((S:'Sun'; L:'Sunday'),   (S:'Mon'; L:'Monday'),
       (S:'Tue'; L:'Tuesday'),  (S:'Wed'; L:'Wednesday'),
       (S:'Thu'; L:'Thursday'), (S:'Fri'; L:'Friday'),
       (S:'Sat'; L:'Saturday'));
    Months : array[1..12] of record S : String[3]; L:String[9] end =
      ((S:'Jan'; L:'January'),   (S:'Feb'; L:'February'),
       (S:'Mar'; L:'March'),     (S:'Apr'; L:'April'),
       (S:'May'; L:'May'),       (S:'Jun'; L:'June'),
       (S:'Jul'; L:'July'),      (S:'Aug'; L:'August'),
       (S:'Sep'; L:'September'), (S:'Oct'; L:'October'),
       (S:'Nov'; L:'November'),  (S:'Dec'; L:'December'));

    function Date ( Style : Byte ) : String;
      var
        M, D, Y, W : word;
      begin
        GetDate ( Y, M, D, W );
        case Style of
          1 : Date := fStr(M,2) + '/' + fStrPad(D,2) + '/' + fStrPad(Y,4);
          2 : Date := fPad(Months[M].S + ' ' + fStr(D,1) + ', ' + fStr(Y,4), 12);
          3 : Date := fPad(Months[M].L + ' ' + fStr(D,1) + ', ' + fStr(Y,4), 18);
          4 : Date := fPad(Days[W].S + ' ' + Months[M].S + ' ' + fStr(D,1) + ', ' + fStr(Y,4), 16);
          5 : Date := fPad(Days[W].L + ' ' + Months[M].L + ' ' + fStr(D,1) + ', ' + fStr(Y,4), 28);
        else
          Date := fStr(M,2) + '/' + fStrPad(D,2) + '/' + fStrPad(Y mod 100,2);
        end;
      end;

end.
