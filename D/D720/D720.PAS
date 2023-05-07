{
Copyright 1990-2023, Jerome Shidel.

This project and related files are subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
{$G-}
program Directory_Lister_Version_7_10;

  uses Dos;

  const
    EnvVar       = 'D700CMD';
    Version      = '7.20';

{$I DUNIT.INC}
{$I D.INC}

begin
  Init;
  Run;
  Done;
end.
