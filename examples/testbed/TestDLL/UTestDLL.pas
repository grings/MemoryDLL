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

unit UTestDLL;

interface

uses
  WinApi.Windows;

procedure Test01(); exports Test01;

implementation

procedure Test01();
begin
  MessageBox(0, 'This is exported routine Test01()', 'TestDLL', MB_OK);
end;

end.
