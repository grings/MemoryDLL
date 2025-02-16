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

 BSD 3-Clause License

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 -----------------------------------------------------------------------------

 Summary:
   The MemoryDLL unit provides advanced functionality for loading dynamic-link
   libraries (win64 DLLs) directly from memory. This unit facilitates the
   loading of DLLs from byte arrays or memory streams, retrieval of function
   addresses within the loaded DLL, and proper unloading of the DLL module.
   Unlike traditional methods that rely on filesystem operations, MemoryDLL
   operates entirely in memory, offering a secure and efficient alternative
   for DLL management.

 Remarks:
   The MemoryDLL unit is meticulously crafted to cater to expert Pascal
   developers who require low-level control over DLL operations. By
   eliminating the dependency on the filesystem, this unit enhances security
   by preventing unauthorized access to DLL files and reduces I/O overhead,
   thereby improving application performance.

 Key Features:
   - MemoryLoadLibrary: Loads a DLL from a memory buffer, such as a byte
     array or memory stream, without writing to the disk.
   - You can then use standard win32 GetProcAddress and FreeLibrary as normal

 -----------------------------------------------------------------------------
 This project uses the following open-source libraries:
  * perfect-loader - https://github.com/EvanMcBroom/perfect-loader

 -----------------------------------------------------------------------------
 >>> CHANGELOG <<<

 Version 0.2.1
 -------------
  - Added a basic usage example
  - Fixed issue with failing to work on Windows 10
  - Updated to latest version of perfect-loader

 Version 0.2.0
 -------------
  - Now works on Windows 11 24H2

 Version 0.1.0
 -------------
  - Initial release

===============================================================================}

unit MemoryDLL;

{$IFNDEF WIN64}
  // Generates a compile-time error if the target platform is not Win64
  {$MESSAGE Error 'Unsupported platform'}
{$ENDIF}

{$Z4}  // Sets the enumeration size to 4 bytes
{$A8}  // Sets the alignment for record fields to 8 bytes

interface

const
  /// <summary>
  /// Major version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This represents the main version number, typically updated for significant changes or milestones.
  /// </remarks>
  MEMORYDLL_MAJOR_VERSION = '0';

  /// <summary>
  /// Minor version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This is incremented for smaller, incremental improvements or updates.
  /// </remarks>
  MEMORYDLL_MINOR_VERSION = '2';

  /// <summary>
  /// Patch version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This number increases for bug fixes or minor improvements that do not affect major or minor versions.
  /// </remarks>
  MEMORYDLL_PATCH_VERSION = '1';

  /// <summary>
  /// Full version of the MemoryDLL, formatted as Major.Minor.Patch.
  /// </summary>
  /// <remarks>
  /// This combines the major, minor, and patch versions into a single version string.
  /// </remarks>
  MEMORYDLL_VERSION = MEMORYDLL_MAJOR_VERSION + '.' + MEMORYDLL_MINOR_VERSION + '.' + MEMORYDLL_PATCH_VERSION;

/// <summary>
///   Loads a DLL directly from memory into the current process's address space.
/// </summary>
/// <param name="AData">
///   Pointer to the memory block containing the DLL binary data. This memory block must contain
///   the complete and valid DLL image.
/// </param>
/// <param name="ASize">
///   The size, in bytes, of the DLL binary data stored in the memory block.
/// </param>
/// <returns>
///   Returns a handle to the loaded DLL if successful, or <c>0</c> if the operation fails.
/// </returns>
/// <remarks>
///   This function is designed to load a dynamic-link library (DLL) directly from memory,
///   bypassing the need for the DLL to exist on the file system. It is particularly useful
///   in scenarios where DLLs are embedded as resources or transmitted over a network.
/// </remarks>
/// <exception>
///   If the function fails, the Windows error code can be retrieved using <c>GetLastError</c>.
///   Common failure reasons include invalid or corrupted DLL data, insufficient memory, or
///   security restrictions.
/// </exception>
/// <preconditions>
///   <list type="bullet">
///     <item><description>The memory block pointed to by <c>AData</c> must be valid.</description></item>
///     <item><description>The size of the memory block in <c>ASize</c> must match the DLL binary size.</description></item>
///   </list>
/// </preconditions>
/// <postconditions>
///   <list type="bullet">
///     <item><description>If successful, the DLL is loaded into the process's address space.</description></item>
///     <item><description>The returned handle can be used in subsequent API calls, such as <c>GetProcAddress</c>.</description></item>
///   </list>
/// </postconditions>
/// <seealso>
///   <c>FreeLibrary</c>, <c>GetProcAddress</c>
/// </seealso>
function LoadMemoryDLL(const AData: Pointer; const ASize: NativeUInt): THandle;

implementation

{$R MemoryDLL.res}

uses
  Windows,
  SysUtils,
  Classes,
  IOUtils;

// Pprovides functionality for dynamically loading a DLL from memory,
// managing its lifecycle, and cleaning up resources upon application shutdown.
var
  // perfect-loader export
  LoadDllFromMemory: function(DllBase: LPVOID; DllSize: SIZE_T; Flags: DWORD; FileName: LPCWSTR; PlFlags: DWORD; ModListName: LPCWSTR): HMODULE; stdcall;

  // Handle to the loaded DLL. Initially 0;
  LDllHandle: THandle = 0;

  // Temporary filename for extracted DLL.
  LDLLFilename: string = '';

  // Temporary file name used related to the DLL loading process.
  LTempFilename: string = '';

// Loads a DLL from memory.
// @param AData Pointer to the memory block containing the DLL data.
// @param ASize Size of the memory block in bytes.
// @return Handle to the loaded DLL on success; 0 on failure.
function LoadMemoryDLL(const AData: Pointer; const ASize: NativeUInt): THandle;
begin
  // Calls an external function to load the DLL from memory.
  Result := LoadDllFromMemory(AData, ASize, 0, PChar(LTempFilename), $40, nil);
end;

// Loads the custom DLL and initializes its exported function.
// @param AError Output parameter that stores the error message, if any.
// @return True if the DLL is loaded successfully; False otherwise.
function LoadDLL(var AError: string): Boolean;
var
  LResStream: TResourceStream;

  function f5fbdcfb9c824df69029be93745a88c4(): string;
  const
    CValue = '9955eeb3e3bd438bb358c5f08185699d';
  begin
    Result := CValue;
  end;

begin
  Result := False;

  // Check if the DLL is already loaded.
  if LDllHandle <> 0 then
  begin
    Result := True;
    Exit;
  end;

  try
    // Check if DLL resource exists
    if not Boolean((FindResource(HInstance, PChar(f5fbdcfb9c824df69029be93745a88c4()), RT_RCDATA) <> 0)) then
    begin
      AError := 'Failed to find perfect-loader DLL resource';
      Exit;
    end;

    // Load the perfect-loader dll into memory
    LResStream := TResourceStream.Create(HInstance, f5fbdcfb9c824df69029be93745a88c4(), RT_RCDATA);

    try
      // Create a temporary GUID based filename for the perfect-loader DLL
      LDLLFilename := TPath.Combine(TPath.GetTempPath, TPath.ChangeExtension(TPath.GetGUIDFileName.ToLower, '.'));

      // save to OS filesystem
      LResStream.SaveToFile(LDLLFilename);

      // Check if exists
      if not TFile.Exists(LDLLFilename) then
      begin
        AError := 'Failed to save perfect-loader DLL';
        Exit;
      end;

      // Load the DLL into memory using a custom loader function.
      LDllHandle := LoadLibrary(PChar(LDLLFilename));
      if LDllHandle = 0 then
      begin
        AError := 'Unable to load extracted perfect-loader DLL';
        Exit;
      end;
    finally
      LResStream.Free();
    end;

    // Retrieve the address of the `LoadDllFromMemory` function from the loaded DLL.
    LoadDllFromMemory := GetProcAddress(LDllHandle, 'LoadDllFromMemory');
    if not Assigned(LoadDllFromMemory) then
    begin
      AError := 'Unable to get perfect-loader DLL exports';
      Exit;
    end;

    // Generate a temporary file name for auxiliary operations.
    LTempFilename := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName + '.txt');

    // Write a dummy text to the temporary file to verify file system access.
    TFile.WriteAllText(LTempFilename, 'MemoryDLL');

    // Verify that the temporary file exists.
    Result := TFile.Exists(LTempFilename);
  except
    on E: Exception do
    begin
      AError := E.Message;
      Result := False;
    end;
  end;
end;

// Unloads the DLL and releases allocated resources.
procedure UnloadDLL();
begin
  // Check if the DLL handle is valid.
  if LDllHandle = 0 then Exit;

  // Free the loaded DLL from memory.
  FreeLibrary(LDllHandle);
  LDllHandle := 0;

  // Delete the temporary extracted DLL
  if TFile.Exists(LDLLFilename) then
  begin
    TFile.Delete(LDLLFilename);
    LDLLFilename := '';
  end;

  // Delete the temporary file, if it exists.
  if TFile.Exists(LTempFilename) then
  begin
    TFile.Delete(LTempFilename);
    LTempFilename := '';
  end;
end;

// Initialization block to load the DLL during application startup.
initialization
var
  LError: string;
begin
  // Enable memory leak reporting for debugging purposes.
  ReportMemoryLeaksOnShutdown := True;

  try
    // Attempt to load the DLL. Terminate the application on failure.
    if not LoadDLL(LError) then
    begin
      MessageBox(0, PChar(LError), 'Critical Initialization Error', MB_ICONERROR);
      Halt(1);
    end;
  except
    on E: Exception do
    begin
      // Display any exceptions encountered during initialization.
      MessageBox(0, PChar(E.Message), 'Critical Initialization Error', MB_ICONERROR);
    end;
  end;
end;

// Finalization block to clean up resources during application shutdown.
finalization
begin
  try
    // Unload the DLL and delete temporary files.
    UnloadDLL();
  except
    on E: Exception do
    begin
      // Display any exceptions encountered during finalization.
      MessageBox(0, PChar(E.Message), 'Critical Shutdown Error', MB_ICONERROR);
    end;
  end;
end;

end.
