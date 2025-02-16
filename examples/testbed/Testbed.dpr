{===============================================================================
  __  __                              ___   _     _ ™
 |  \/  | ___  _ __   ___  _ _  _  _ |   \ | |   | |
 | |\/| |/ -_)| '  \ / _ \| '_|| || || |) || |__ | |__
 |_|  |_|\___||_|_|_|\___/|_|   \_, ||___/ |____||____|
                                |__/
 In-Memory Win64 DLL Loading & Execution for Pascal

 Copyright © 2024-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/MemoryDLL
===============================================================================}

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

{$R *.dres}

uses
  System.SysUtils,
  UTestbed in 'UTestbed.pas',
  MemoryDLL in '..\..\src\MemoryDLL.pas';

begin
  try
    // Run imported routine from TestDLL memory DLL.
    Test01();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
