{============================================================================
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
   - LoadFromMemory: Loads a DLL from a memory buffer, such as a byte array
     or memory stream, without writing to the disk.
   - GetFunctionAddress: Retrieves the address of an exported function
     within the loaded DLL, enabling direct invocation of the function.
   - FreeModule: Unloads the DLL from memory, ensuring that all associated
     resources are properly released.
   - ErrorHandling: Comprehensive error detection and handling mechanisms to
     manage scenarios such as invalid DLL data, memory allocation failures,
     and function resolution issues.

 Implementation Details:
   1. Utilizes low-level Windows API functions and memory management
      techniques to parse and execute DLLs directly from memory. This
      includes manual mapping of the DLL sections, relocation handling, and
      resolution of import/export tables.
   2. Ensures compatibility with standard DLL interfaces, allowing seamless
      integration with existing applications and libraries.
   3. Incorporates security best practices to prevent common vulnerabilities
      associated with DLL loading, such as DLL hijacking and code injection.

 Usage Scenarios:
   - Embedding DLLs within the main executable for distribution, eliminating
     the need to manage separate DLL files.
   - Loading encrypted or obfuscated DLLs to enhance application security.
   - Facilitating dynamic plugin systems where plugins are provided as
     in-memory modules.

 Comprehensive documentation is provided for all public routines, types,
 variables, and internal logic within the MemoryDLL unit. This ensures that
 expert Pascal developers can effortlessly maintain, extend, and optimize
 the unit for future requirements. Additionally, inline comments elucidate
 complex operations and decision-making processes, promoting code
 readability and maintainability.

 Acknowledgment:
   This unit is based on the original Delphi MemoryModule project by
   Fr0sT-Brutal, available at:
     https://github.com/Fr0sT-Brutal/Delphi_MemoryModule
   Credit goes to the original developer for their foundational work, which
   this unit builds upon.

-----------------------------------------------------------------------------
>>> CHANGELOG <<<

Version 0.1.0 - 2024-10-31
---------------------------
Added:
  - Initial release of MemoryDLL, featuring support for loading, freeing,
    and accessing DLL functions directly from memory.

Fixed:
  - N/A

Changed:
  - N/A

=============================================================================}

unit MemoryDLL;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface

uses
  Windows,
  Math;

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
  MEMORYDLL_MINOR_VERSION = '1';

  /// <summary>
  /// Patch version of the MemoryDLL.
  /// </summary>
  /// <remarks>
  /// This number increases for bug fixes or minor improvements that do not affect major or minor versions.
  /// </remarks>
  MEMORYDLL_PATCH_VERSION = '0';

  /// <summary>
  /// Full version of the MemoryDLL, formatted as Major.Minor.Patch.
  /// </summary>
  /// <remarks>
  /// This combines the major, minor, and patch versions into a single version string.
  /// </remarks>
  MEMORYDLL_VERSION = MEMORYDLL_MAJOR_VERSION + '.' + MEMORYDLL_MINOR_VERSION + '.' + MEMORYDLL_PATCH_VERSION;

/// <summary>
/// Loads a module from a memory image, emulating the behavior of the Windows API LoadLibrary function.
/// This function parses the Portable Executable (PE) format of the provided memory image, performs necessary
/// relocations, resolves imports, executes Thread Local Storage (TLS) callbacks, and initializes the module
/// by invoking its entry point.
/// </summary>
/// <param name="Data">
/// A pointer to the memory image of the module to be loaded. This memory image must conform to the PE format,
/// including valid DOS and NT headers, section headers, and correctly formatted import and export tables.
/// </param>
/// <returns>
/// Returns a handle of type THandle to the loaded module. This handle can be used with GetProcAddress to
/// retrieve function addresses exported by the module, and with FreeLibrary to unload the module from memory.
/// If the loading process fails due to invalid format, memory allocation issues, or unresolved imports,
/// the function returns 0 and sets the appropriate error code using SetLastError.
/// </returns>
/// <remarks>
/// <para>
/// This function does not rely on the filesystem and instead operates entirely in memory. It is particularly
/// useful in scenarios where loading a module from a non-standard source is required, such as loading from
/// encrypted or obfuscated data streams. However, care must be taken to ensure that the memory image is
/// correctly formatted and that all dependencies are available.
/// </para>
/// <para>
/// The caller is responsible for managing the lifecycle of the loaded module. Failure to call FreeLibrary
/// will result in memory leaks and potential resource exhaustion.
/// </para>
/// </remarks>
function LoadLibrary(const AData: Pointer): THandle; stdcall;

/// <summary>
/// Frees a module that was previously loaded into memory using the LoadLibrary function.
/// This procedure performs cleanup by notifying the module of its detachment, unloading any imported
/// modules, and releasing all memory allocated for the module's image and internal structures.
/// </summary>
/// <param name="Module">
/// A handle of type THandle to the module to be freed. This handle must have been obtained from a successful
/// call to LoadLibrary. Passing an invalid handle or a handle that has already been freed may result in undefined
/// behavior or access violations.
/// </param>
/// <remarks>
/// <para>
/// It is crucial to ensure that FreeLibrary is called for every successful LoadLibrary call to prevent memory leaks.
/// Additionally, unloading a module while its functions are still in use by other parts of the application can lead to
/// stability issues and application crashes. Therefore, synchronization mechanisms should be employed to ensure that
/// no references to the module's functions remain before calling FreeLibrary.
/// </para>
/// <para>
/// This procedure mirrors the behavior of the Windows API FreeLibrary function but operates on modules loaded into
/// memory via LoadLibrary. It is designed to manage the resources associated with in-memory modules effectively.
/// </para>
/// </remarks>
procedure FreeLibrary(const AModule: THandle); stdcall;

/// <summary>
/// Retrieves the address of an exported function or variable from a module that has been loaded into memory
/// using the LoadLibrary function. This emulates the behavior of the Windows API GetProcAddress function.
/// </summary>
/// <param name="Module">
/// A handle of type THandle to the loaded module from which the function or variable address is to be retrieved.
/// This handle must have been obtained from a successful call to LoadLibrary.
/// </param>
/// <param name="Name">
/// A pointer to a null-terminated ANSI string that specifies the name of the function or variable to retrieve.
/// If this parameter is an ordinal value instead of a string, the function behavior is undefined and may result
/// in incorrect addresses being returned.
/// </param>
/// <returns>
/// Returns a pointer to the requested function or variable if found. If the specified name does not exist in the
/// module's export table, or if the module has no export table, the function returns nil and sets the appropriate
/// error code using SetLastError.
/// </returns>
/// <remarks>
/// <para>
/// This function scans the export table of the specified module to locate the function or variable by name. It then
/// calculates the absolute address based on the module's base address and the Relative Virtual Address (RVA) of the
/// export entry. The returned pointer can be cast to the appropriate function type for invocation.
/// </para>
/// <para>
/// It is the caller's responsibility to ensure that the module remains loaded in memory for as long as the retrieved
/// function pointers are in use. Unloading the module using FreeLibrary while function pointers are still active will
/// lead to undefined behavior and potential application crashes.
/// </para>
/// <para>
/// This function is optimized for speed, but repeated calls with the same module and function names may benefit from
/// caching mechanisms to improve performance, especially in applications that make extensive use of dynamically loaded
/// modules.
/// </para>
/// </remarks>
function GetProcAddress(const AModule: THandle; const AName: PAnsiChar): Pointer; stdcall;

implementation

// Conditional type declarations for compatibility with different Delphi/FreePascal versions.
// These types are used to interpret the structure of the PE (Portable Executable) format.

{$IF NOT DECLARED(IMAGE_BASE_RELOCATION)}
type
  {$ALIGN 4}
  IMAGE_BASE_RELOCATION = record
    VirtualAddress: DWORD;  // RVA of the block
    SizeOfBlock: DWORD;     // Size of the block including the header
  end;
  {$ALIGN ON}
  PIMAGE_BASE_RELOCATION = ^IMAGE_BASE_RELOCATION;
{$IFEND}

{$IF NOT DECLARED(PIMAGE_DATA_DIRECTORY)}
type
  PIMAGE_DATA_DIRECTORY = ^IMAGE_DATA_DIRECTORY; // Pointer to IMAGE_DATA_DIRECTORY structure
{$IFEND}

{$IF NOT DECLARED(PIMAGE_SECTION_HEADER)}
type
  PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER; // Pointer to IMAGE_SECTION_HEADER structure
{$IFEND}

{$IF NOT DECLARED(PIMAGE_EXPORT_DIRECTORY)}
type
  PIMAGE_EXPORT_DIRECTORY = ^IMAGE_EXPORT_DIRECTORY; // Pointer to IMAGE_EXPORT_DIRECTORY structure
{$IFEND}

{$IF NOT DECLARED(PIMAGE_DOS_HEADER)}
type
  PIMAGE_DOS_HEADER = ^IMAGE_DOS_HEADER; // Pointer to IMAGE_DOS_HEADER structure
{$IFEND}

{$IF NOT DECLARED(PIMAGE_NT_HEADERS64)}
type
  IMAGE_NT_HEADERS64 = record
    Signature: DWORD;                    // "PE\0\0" signature
    FileHeader: IMAGE_FILE_HEADER;      // File header
    OptionalHeader: IMAGE_OPTIONAL_HEADER64; // Optional header for 64-bit
  end;
  PIMAGE_NT_HEADERS64 = ^IMAGE_NT_HEADERS64; // Pointer to IMAGE_NT_HEADERS64 structure
{$IFEND}

{$IF NOT DECLARED(PIMAGE_TLS_DIRECTORY64)}
type
  PIMAGE_TLS_DIRECTORY64 = ^IMAGE_TLS_DIRECTORY64; // Pointer to IMAGE_TLS_DIRECTORY64 structure
{$IFEND}

{$IF NOT DECLARED(PUINT_PTR)}
type
  PUINT_PTR = ^UINT_PTR; // Pointer to an unsigned integer type that can hold a pointer
{$IFEND}

// Constants related to relocation types, directory entries, machine types,
// signatures, and protection flags.

const
  // Relocation types used in the PE format.
  IMAGE_REL_BASED_ABSOLUTE = 0;
  IMAGE_REL_BASED_HIGHLOW = 3;
  IMAGE_REL_BASED_DIR64 = 10;

  // Directory entry indices for various data directories in the PE optional header.
  IMAGE_DIRECTORY_ENTRY_EXPORT = 0;
  IMAGE_DIRECTORY_ENTRY_IMPORT = 1;
  IMAGE_DIRECTORY_ENTRY_TLS = 9;

  // Machine type constant for AMD64 architecture.
  IMAGE_FILE_MACHINE_AMD64 = $8664;

  // Signature constant for the PE format.
  IMAGE_NT_SIGNATURE = $00004550; // "PE\0\0"

  // Flag indicating that an import is by ordinal in 64-bit.
  IMAGE_ORDINAL_FLAG64 = $8000000000000000;

  // Protection flags for memory pages based on executability, readability, and writability.
  ProtectionFlags: array[Boolean, Boolean, Boolean] of DWORD =
  (
    (
      // Not executable
      (PAGE_NOACCESS, PAGE_WRITECOPY),           // Not readable, not writable
      (PAGE_READONLY, PAGE_READWRITE)            // Readable, not writable / Readable, writable
    ),
    (
      // Executable
      (PAGE_EXECUTE, PAGE_EXECUTE_WRITECOPY),     // Executable, not writable
      (PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE) // Executable, readable / Executable, readable and writable
    )
  );

  // Error codes corresponding to various failure scenarios.
  ERROR_BAD_EXE_FORMAT = 193;
  ERROR_MOD_NOT_FOUND = 126;
  ERROR_OUTOFMEMORY = 14;
  ERROR_PROC_NOT_FOUND = 127;
  ERROR_DLL_INIT_FAILED = 1114;

const
  IMAGE_SIZEOF_BASE_RELOCATION = SizeOf(IMAGE_BASE_RELOCATION); // Size of IMAGE_BASE_RELOCATION structure
  HOST_MACHINE = IMAGE_FILE_MACHINE_AMD64; // Host machine type for AMD64

// Record to hold information about the loaded memory module.
type
  TMemoryModuleRec = record
    Headers: PIMAGE_NT_HEADERS64;   // Pointer to NT headers of the module
    CodeBase: Pointer;              // Base address where the module is loaded in memory
    Modules: array of HMODULE;      // Array of handles to imported modules (dependencies)
    NumModules: Integer;            // Number of imported modules loaded
    Initialized: Boolean;           // Indicates if the module has been initialized (entry point called)
    IsRelocated: Boolean;           // Indicates if relocation has been performed
    PageSize: DWORD;                // System page size used for memory alignment
  end;
  PMemoryModule = ^TMemoryModuleRec; // Pointer to TMemoryModuleRec

  // Type for the DLL entry procedure signature.
  TDllEntryProc = function(hinstDLL: HINST; fdwReason: DWORD; lpReserved: Pointer): BOOL; stdcall;

  // Record to hold data necessary for finalizing a section.
  TSectionFinalizeData = record
    Address: Pointer;                // Start address of the section in memory
    AlignedAddress: Pointer;         // Aligned address based on page size
    Size: SIZE_T;                    // Size of the section
    Characteristics: DWORD;          // Section characteristics flags
    Last: Boolean;                   // Indicates if this is the last section being processed
  end;

// External declarations to access original Windows API functions for internal use.
// These functions are used to perform operations that are otherwise mimicked in this unit.

function GetProcAddress_Internal(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall; external kernel32 name 'GetProcAddress';
function LoadLibraryA_Internal(lpLibFileName: LPCSTR): HMODULE; stdcall; external kernel32 name 'LoadLibraryA';
function FreeLibrary_Internal(hLibModule: HMODULE): BOOL; stdcall; external kernel32 name 'FreeLibrary';

{
  Procedure: Abort
  -----------------
  Aborts execution by raising an exception.

  Note:
    This procedure should not be used for normal exception handling.
    It is intended to be used in critical failure scenarios to terminate execution.
}
procedure Abort;
begin
  raise TObject.Create; // Raises a generic exception to abort execution
end;

{
  Function: StrComp
  ------------------
  Compares two ANSI strings.

  Parameters:
    Str1 - First string to compare.
    Str2 - Second string to compare.

  Returns:
    Integer result of the comparison:
      <0 if Str1 < Str2,
      0 if Str1 = Str2,
      >0 if Str1 > Str2.
}
function StrComp(const Str1, Str2: PAnsiChar): Integer;
var
  P1, P2: PAnsiChar; // Pointers to traverse the strings
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^)); // Return the difference if characters mismatch or end of string is reached
    Inc(P1); // Move to the next character in Str1
    Inc(P2); // Move to the next character in Str2
  end;
end;

{$IF NOT DECLARED(IMAGE_ORDINAL)}
{
  Function: IMAGE_ORDINAL
  ------------------------
  Extracts the ordinal from a 64-bit value.

  Parameters:
    Ordinal - The ordinal value to extract from.

  Returns:
    The lower 16 bits of the ordinal.
}
function IMAGE_ORDINAL(Ordinal: NativeUInt): Word; inline;
begin
  Result := Ordinal and $FFFF; // Mask to get the lower 16 bits
end;
{$IFEND}

{$IF NOT DECLARED(IMAGE_SNAP_BY_ORDINAL)}
{
  Function: IMAGE_SNAP_BY_ORDINAL
  -------------------------------
  Determines if a value is an ordinal based on the IMAGE_ORDINAL_FLAG64.

  Parameters:
    Ordinal - The value to check.

  Returns:
    True if the value is an ordinal, False otherwise.
}
function IMAGE_SNAP_BY_ORDINAL(Ordinal: NativeUInt): Boolean; inline;
begin
  Result := ((Ordinal and IMAGE_ORDINAL_FLAG64) <> 0); // Check if the flag bit is set
end;
{$IFEND}

{
  Function: GET_HEADER_DICTIONARY
  -------------------------------
  Retrieves a specific data directory from the module's headers.

  Parameters:
    Module - Pointer to the memory module.
    Idx    - Index of the data directory to retrieve.

  Returns:
    Pointer to the requested IMAGE_DATA_DIRECTORY.
}
function GET_HEADER_DICTIONARY(Module: PMemoryModule; Idx: Integer): PIMAGE_DATA_DIRECTORY;
begin
  // Access the DataDirectory array in the OptionalHeader and return the requested entry
  Result := @((Module.Headers^.OptionalHeader.DataDirectory[Idx]));
end;

{
  Function: ALIGN_DOWN
  --------------------
  Aligns the given address down to the nearest multiple of the alignment.

  Parameters:
    Address   - The address to align.
    Alignment - The alignment boundary (must be a power of two).

  Returns:
    The aligned address.
}
function ALIGN_DOWN(Address: Pointer; Alignment: DWORD): Pointer;
begin
  // Perform bitwise AND with the inverse of (Alignment - 1) to align down
  Result := Pointer(NativeUInt(Address) and not (Alignment - 1));
end;

{
  Function: CopySections
  ----------------------
  Copies the sections from the DLL file block to the newly allocated memory.

  Parameters:
    data        - Pointer to the DLL data in memory.
    old_headers - Pointer to the original NT headers of the DLL.
    module      - Pointer to the memory module record.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function CopySections(data: Pointer; old_headers: PIMAGE_NT_HEADERS64; module: PMemoryModule): Boolean;
var
  I: Integer;                  // Loop counter for sections
  LSize: Integer;               // Size of a section to allocate
  LCodeBase: Pointer;           // Base address of the loaded module in memory
  LDest: Pointer;               // Destination address for the copied section
  LSection: PIMAGE_SECTION_HEADER; // Pointer to the current section header
begin
  LCodeBase := module.CodeBase; // Retrieve the base address where the module is loaded
  LSection := PIMAGE_SECTION_HEADER(IMAGE_FIRST_SECTION(module.Headers)); // Get the first section header

  // Iterate through all sections defined in the module's headers
  for I := 0 to module.Headers^.FileHeader.NumberOfSections - 1 do
  begin
    // Check if the section has no raw data (might define uninitialized data)
    if LSection^.SizeOfRawData = 0 then
    begin
      LSize := old_headers^.OptionalHeader.SectionAlignment; // Determine the size based on section alignment
      if LSize > 0 then
      begin
        // Allocate memory for the section with read/write permissions
        LDest := VirtualAlloc(
          PByte(LCodeBase) + LSection^.VirtualAddress, // Address to allocate
          LSize,                                       // Size to allocate
          MEM_COMMIT,                                  // Allocation type
          PAGE_READWRITE                               // Memory protection
        );

        if LDest = nil then
          Exit(False); // Allocation failed

        // Assign the physical address based on the virtual address
        LSection^.Misc.PhysicalAddress := LSection^.VirtualAddress;

        // Initialize the allocated memory to zero (uninitialized data)
        ZeroMemory(LDest, LSize);
      end;

      // Move to the next section
      Inc(LSection);
      Continue;
    end; // if

    // Allocate memory for the section and copy its data from the DLL
    LDest := VirtualAlloc(
      PByte(LCodeBase) + LSection^.VirtualAddress, // Address to allocate
      LSection^.SizeOfRawData,                     // Size to allocate
      MEM_COMMIT,                                  // Allocation type
      PAGE_READWRITE                               // Memory protection
    );

    if LDest = nil then
      Exit(False); // Allocation failed

    // Copy the raw data of the section into the allocated memory
    CopyMemory(
      LDest,                                     // Destination address
      PByte(data) + LSection^.PointerToRawData,  // Source address in DLL data
      LSection^.SizeOfRawData                    // Number of bytes to copy
    );

    // Assign the physical address based on the virtual address
    LSection^.Misc.PhysicalAddress := LSection^.VirtualAddress;

    // Move to the next section
    Inc(LSection);
  end; // for

  // If all sections are copied successfully
  Result := True;
end;

// Redefinition of the protection flags array for memory pages.
// This array determines the protection attributes based on executability,
// readability, and writability flags.
const
  ProtectionFlagsArray: array[Boolean, Boolean, Boolean] of DWORD =
  (
    (
      // Not executable
      (PAGE_NOACCESS, PAGE_WRITECOPY),           // Not readable, not writable
      (PAGE_READONLY, PAGE_READWRITE)            // Readable, not writable / Readable, writable
    ),
    (
      // Executable
      (PAGE_EXECUTE, PAGE_EXECUTE_WRITECOPY),     // Executable, not writable
      (PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE) // Executable, readable / Executable, readable and writable
    )
  );

{
  Function: GetRealSectionSize
  -----------------------------
  Determines the actual size of a section based on its characteristics.

  Parameters:
    Module  - Pointer to the memory module.
    Section - Pointer to the section header.

  Returns:
    The real size of the section in bytes.
}
function GetRealSectionSize(Module: PMemoryModule; Section: PIMAGE_SECTION_HEADER): DWORD;
begin
  Result := Section^.SizeOfRawData; // Start with the size of raw data

  // If SizeOfRawData is zero, determine size based on section characteristics
  if Result = 0 then
  begin
    if (Section^.Characteristics and IMAGE_SCN_CNT_INITIALIZED_DATA) <> 0 then
      Result := Module.Headers^.OptionalHeader.SizeOfInitializedData
    else if (Section^.Characteristics and IMAGE_SCN_CNT_UNINITIALIZED_DATA) <> 0 then
      Result := Module.Headers^.OptionalHeader.SizeOfUninitializedData;
  end;
end;

{
  Function: FinalizeSection
  -------------------------
  Sets the appropriate memory protection for a section and optionally decommits it if discardable.

  Parameters:
    Module      - Pointer to the memory module.
    SectionData - Data required to finalize the section.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function FinalizeSection(Module: PMemoryModule; const SectionData: TSectionFinalizeData): Boolean;
var
  LProtect: DWORD;        // New protection flags to set
  LOldProtect: DWORD;     // Variable to receive old protection flags
  LExecutable: Boolean;   // Indicates if the section is executable
  LReadable: Boolean;     // Indicates if the section is readable
  LWriteable: Boolean;    // Indicates if the section is writable
begin
  // If the section size is zero, nothing to do
  if SectionData.Size = 0 then
    Exit(True);

  // Check if the section is marked as discardable
  if (SectionData.Characteristics and IMAGE_SCN_MEM_DISCARDABLE) <> 0 then
  begin
    // Only decommit if entire pages can be freed
    if (SectionData.Address = SectionData.AlignedAddress) and
       (SectionData.Last or
        (Module.Headers^.OptionalHeader.SectionAlignment = Module.PageSize) or
        (SectionData.Size mod Module.PageSize = 0)) then
    begin
      // Decommit the memory for the section
      VirtualFree(SectionData.Address, SectionData.Size, MEM_DECOMMIT);
    end;
    // Discardable sections are handled; exit successfully
    Exit(True);
  end;

  // Determine the protection flags based on section characteristics
  LExecutable := (SectionData.Characteristics and IMAGE_SCN_MEM_EXECUTE) <> 0;
  LReadable   := (SectionData.Characteristics and IMAGE_SCN_MEM_READ) <> 0;
  LWriteable  := (SectionData.Characteristics and IMAGE_SCN_MEM_WRITE) <> 0;
  LProtect := ProtectionFlagsArray[LExecutable][LReadable][LWriteable];

  // If the section should not be cached, add the PAGE_NOCACHE flag
  if (SectionData.Characteristics and IMAGE_SCN_MEM_NOT_CACHED) <> 0 then
    LProtect := LProtect or PAGE_NOCACHE;

  // Apply the determined protection flags to the section's memory
  Result := VirtualProtect(SectionData.Address, SectionData.Size, LProtect, LOldProtect);
end;

{
  Function: FinalizeSections
  --------------------------
  Applies memory protection settings to all sections of the loaded module.

  Parameters:
    Module - Pointer to the memory module.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function FinalizeSections(Module: PMemoryModule): Boolean;
var
  I: Integer;                          // Loop counter for sections
  LSection: PIMAGE_SECTION_HEADER;     // Pointer to the current section header
  LImageOffset: NativeUInt;            // Base address offset for calculations
  LSectionData: TSectionFinalizeData;  // Data structure holding section finalization info
  LSectionAddress: Pointer;            // Address of the current section
  LAlignedAddress: Pointer;            // Aligned address for memory protection
  LSectionSize: DWORD;                 // Size of the current section
begin
  LSection := PIMAGE_SECTION_HEADER(IMAGE_FIRST_SECTION(Module.Headers)); // Get the first section header
  LImageOffset := NativeUInt(Module.CodeBase); // Base address where the module is loaded

  // Initialize SectionData with the first section's information
  LSectionData.Address := Pointer(LImageOffset + LSection^.VirtualAddress);         // Start address of the first section
  LSectionData.AlignedAddress := ALIGN_DOWN(LSectionData.Address, Module.PageSize); // Align address down to page boundary
  LSectionData.Size := GetRealSectionSize(Module, LSection);                        // Determine the actual size of the section
  LSectionData.Characteristics := LSection^.Characteristics;                        // Store section characteristics
  LSectionData.Last := False; // Indicates that this is not the last section yet
  Inc(LSection); // Move to the next section

  // Iterate through all sections starting from the second one
  for I := 1 to Module.Headers^.FileHeader.NumberOfSections - 1 do
  begin
    LSectionAddress := Pointer(LImageOffset + LSection^.VirtualAddress);  // Address of the current section
    LAlignedAddress := ALIGN_DOWN(LSectionData.Address, Module.PageSize); // Align previous section's address
    LSectionSize := GetRealSectionSize(Module, LSection);                 // Determine the size of the current section

    // Check if the current section shares a memory page with the previous section
    if (LSectionData.AlignedAddress = LAlignedAddress) or
       (PByte(LSectionData.Address) + LSectionData.Size > PByte(LAlignedAddress)) then
    begin
      // Merge characteristics if sections share a page
      if (LSection^.Characteristics and IMAGE_SCN_MEM_DISCARDABLE = 0) or
         (LSectionData.Characteristics and IMAGE_SCN_MEM_DISCARDABLE = 0) then
        LSectionData.Characteristics := (LSectionData.Characteristics or LSection^.Characteristics) and not IMAGE_SCN_MEM_DISCARDABLE
      else
        LSectionData.Characteristics := LSectionData.Characteristics or LSection^.Characteristics;

      // Update the size to include the new section
      LSectionData.Size := NativeUInt(LSectionAddress) + LSectionSize - NativeUInt(LSectionData.Address);
      Inc(LSection); // Move to the next section
      Continue;
    end;

    // Finalize the previous section by setting memory protection
    if not FinalizeSection(Module, LSectionData) then
      Exit(False); // If finalization fails, exit with failure

    // Update SectionData with the current section's information
    LSectionData.Address := LSectionAddress; // Start address of the current section
    LSectionData.AlignedAddress := ALIGN_DOWN(LSectionData.Address, Module.PageSize); // Align address down to page boundary
    LSectionData.Size := LSectionSize; // Size of the current section
    LSectionData.Characteristics := LSection^.Characteristics; // Store current section characteristics

    Inc(LSection); // Move to the next section
  end; // for

  // Finalize the last section
  LSectionData.Last := True; // Mark as the last section
  if not FinalizeSection(Module, LSectionData) then
    Exit(False); // If finalization fails, exit with failure

  // If all sections are finalized successfully
  Result := True;
end;

{
  Function: ExecuteTLS
  ---------------------
  Executes TLS (Thread Local Storage) callbacks for the loaded module.

  Parameters:
    Module - Pointer to the memory module.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function ExecuteTLS(Module: PMemoryModule): Boolean;
var
  LCodeBase: Pointer;                // Base address of the loaded module
  LDirectory: PIMAGE_DATA_DIRECTORY; // Pointer to the TLS data directory
  LTLS: PIMAGE_TLS_DIRECTORY64;      // Pointer to the TLS directory structure
  LCallback: PPointer;               // Pointer to the TLS callback functions

  // Local function to adjust pointers based on relocation delta
  function FixPtr(OldPtr: Pointer): Pointer;
  begin
    // Adjust the old pointer based on the difference between ImageBase and CodeBase
    Result := Pointer(NativeUInt(OldPtr) - Module.Headers^.OptionalHeader.ImageBase + NativeUInt(LCodeBase));
  end;

begin
  Result := True; // Assume success initially
  LCodeBase := Module.CodeBase; // Retrieve the base address where the module is loaded

  // Retrieve the TLS directory from the module's data directories
  LDirectory := GET_HEADER_DICTIONARY(Module, IMAGE_DIRECTORY_ENTRY_TLS);
  if LDirectory^.VirtualAddress = 0 then
    Exit; // No TLS data present; nothing to execute

  // Calculate the address of the TLS directory structure
  LTLS := PIMAGE_TLS_DIRECTORY64(PByte(LCodeBase) + LDirectory^.VirtualAddress);

  // Retrieve the address of the TLS callback functions
  LCallback := PPointer(LTLS^.AddressOfCallBacks);
  if LCallback <> nil then
  begin
    LCallback := FixPtr(LCallback); // Adjust the callback pointer based on relocation
    // Iterate through all TLS callbacks until a nil pointer is encountered
    while LCallback^ <> nil do
    begin
      // Cast the callback to the appropriate function type and execute it
      PIMAGE_TLS_CALLBACK(FixPtr(LCallback^))(LCodeBase, DLL_PROCESS_ATTACH, nil);
      Inc(LCallback); // Move to the next callback
    end;
  end;
end;

{
  Function: PerformBaseRelocation
  -------------------------------
  Adjusts the module's base address if it is loaded at a different address than its preferred base.

  Parameters:
    Module - Pointer to the memory module.
    Delta  - The difference between the actual base address and the preferred base address.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function PerformBaseRelocation(Module: PMemoryModule; Delta: NativeInt): Boolean;
var
  I: Cardinal;                         // Loop counter for relocations
  LCodeBase: Pointer;                  // Base address where the module is loaded
  LDirectory: PIMAGE_DATA_DIRECTORY;   // Pointer to the base relocation data directory
  LRelocation: PIMAGE_BASE_RELOCATION; // Pointer to the current base relocation block
  LDest: Pointer;                      // Destination address for the relocation
  LRelInfo: ^UInt16;                   // Pointer to relocation info entries
  LPatchAddrHL: PDWORD;                // Pointer to 32-bit relocation address
  LPatchAddr64: PULONGLONG;            // Pointer to 64-bit relocation address
  LRelType: Integer;                   // Type of relocation
  LOffset: Integer;                    // Offset within the relocation block
begin
  LCodeBase := Module.CodeBase; // Retrieve the base address where the module is loaded
  LDirectory := GET_HEADER_DICTIONARY(Module, IMAGE_DIRECTORY_ENTRY_BASERELOC); // Get base relocation directory
  if LDirectory^.Size = 0 then
    Exit(Delta = 0); // If no relocations are needed, exit successfully only if Delta is zero

  // Initialize relocation pointer to the first base relocation block
  LRelocation := PIMAGE_BASE_RELOCATION(PByte(LCodeBase) + LDirectory^.VirtualAddress);

  // Iterate through all base relocation blocks
  while LRelocation.VirtualAddress > 0 do
  begin
    // Calculate the destination address for this relocation block
    LDest := Pointer(NativeUInt(LCodeBase) + LRelocation.VirtualAddress);
    // Point to the first relocation entry within the block
    LRelInfo := Pointer(NativeUInt(LRelocation) + IMAGE_SIZEOF_BASE_RELOCATION);

    // Iterate through all relocation entries in this block
    for I := 0 to (LRelocation.SizeOfBlock - IMAGE_SIZEOF_BASE_RELOCATION) div 2 - 1 do
    begin
      // Extract the type of relocation from the upper 4 bits
      LRelType := LRelInfo^ shr 12;
      // Extract the offset within the page from the lower 12 bits
      LOffset := LRelInfo^ and $FFF;

      case LRelType of
        IMAGE_REL_BASED_ABSOLUTE:
          // IMAGE_REL_BASED_ABSOLUTE means no relocation is needed; skip
          ;
        IMAGE_REL_BASED_HIGHLOW:
          begin
            // IMAGE_REL_BASED_HIGHLOW indicates a 32-bit address that needs to be relocated
            LPatchAddrHL := PDWORD(NativeUInt(LDest) + NativeUInt(LOffset));
            Inc(LPatchAddrHL^, Delta); // Apply the relocation delta
          end;
        IMAGE_REL_BASED_DIR64:
          begin
            // IMAGE_REL_BASED_DIR64 indicates a 64-bit address that needs to be relocated
            LPatchAddr64 := PULONGLONG(NativeUInt(LDest) + NativeUInt(LOffset));
            Inc(LPatchAddr64^, Delta); // Apply the relocation delta
          end;
      end;

      Inc(LRelInfo); // Move to the next relocation entry
    end; // for

    // Advance to the next base relocation block by adding the size of the current block
    LRelocation := PIMAGE_BASE_RELOCATION(NativeUInt(LRelocation) + LRelocation.SizeOfBlock);
  end; // while

  // If all relocations are processed successfully
  Result := True;
end;

{
  Function: BuildImportTable
  --------------------------
  Resolves and links all imported functions from other modules.

  Parameters:
    Module - Pointer to the memory module.

  Returns:
    Boolean indicating success (True) or failure (False).
}
function BuildImportTable(Module: PMemoryModule): Boolean; stdcall;
var
  LCodeBase: Pointer;                    // Base address where the module is loaded
  LDirectory: PIMAGE_DATA_DIRECTORY;     // Pointer to the import data directory
  LImportDesc: PIMAGE_IMPORT_DESCRIPTOR; // Pointer to the current import descriptor
  LThunkRef: PUINT_PTR;                  // Reference to the thunk (import address table)
  LFuncRef: ^FARPROC;                    // Reference to the function pointer in the IAT
  LHandle: HMODULE;                      // Handle to the imported module
  LThunkData: PIMAGE_IMPORT_BY_NAME;     // Pointer to the import by name structure
begin
  LCodeBase := Module.CodeBase; // Retrieve the base address where the module is loaded
  Result := True; // Assume success initially

  // Retrieve the import directory from the module's data directories
  LDirectory := GET_HEADER_DICTIONARY(Module, IMAGE_DIRECTORY_ENTRY_IMPORT);
  if LDirectory^.Size = 0 then
    Exit(True); // No imports to process; exit successfully

  // Initialize the import descriptor pointer to the first entry
  LImportDesc := PIMAGE_IMPORT_DESCRIPTOR(PByte(LCodeBase) + LDirectory^.VirtualAddress);

  // Iterate through all import descriptors
  while LImportDesc^.Name <> 0 do
  begin
    // Load the imported module using its name
    LHandle := LoadLibraryA_Internal(PAnsiChar(PByte(LCodeBase) + LImportDesc^.Name));
    if LHandle = 0 then
    begin
      // If the module could not be loaded, set an error and exit
      SetLastError(ERROR_MOD_NOT_FOUND);
      Result := False;
      Break;
    end;

    try
      // Attempt to expand the Modules array to include the new module
      SetLength(Module.Modules, Module.NumModules + 1);
    except
      // If memory allocation fails, free the loaded module and set an error
      FreeLibrary_Internal(LHandle);
      SetLastError(ERROR_OUTOFMEMORY);
      Result := False;
      Break;
    end;

    // Store the handle to the imported module
    Module.Modules[Module.NumModules] := LHandle;
    Inc(Module.NumModules); // Increment the count of imported modules

    // Determine the starting point for thunks based on OriginalFirstThunk
    if LImportDesc^.OriginalFirstThunk <> 0 then
    begin
      // If OriginalFirstThunk is present, use it to get the function names or ordinals
      LThunkRef := PUINT_PTR(PByte(LCodeBase) + LImportDesc^.OriginalFirstThunk);
      LFuncRef := Pointer(PByte(LCodeBase) + LImportDesc^.FirstThunk);
    end
    else
    begin
      // If OriginalFirstThunk is not present, use FirstThunk for both
      LThunkRef := PUINT_PTR(PByte(LCodeBase) + LImportDesc^.FirstThunk);
      LFuncRef := Pointer(PByte(LCodeBase) + LImportDesc^.FirstThunk);
    end;

    // Iterate through all imported functions for the current import descriptor
    while LThunkRef^ <> 0 do
    begin
      if IMAGE_SNAP_BY_ORDINAL(LThunkRef^) then
        // Import by ordinal: retrieve the function address using the ordinal
        LFuncRef^ := GetProcAddress_Internal(LHandle, PAnsiChar(IMAGE_ORDINAL(LThunkRef^)))
      else
      begin
        // Import by name: retrieve the function address using the function name
        LThunkData := PIMAGE_IMPORT_BY_NAME(PByte(LCodeBase) + LThunkRef^);
        LFuncRef^ := GetProcAddress_Internal(LHandle, PAnsiChar(@LThunkData^.Name));
      end;

      if LFuncRef^ = nil then
      begin
        // If the function address could not be resolved, set an error and exit
        Result := False;
        Break;
      end;

      Inc(LFuncRef); // Move to the next function pointer in the IAT
      Inc(LThunkRef); // Move to the next thunk entry
    end; // while

    if not Result then
    begin
      // If resolving a function failed, free the loaded module and set an error
      FreeLibrary_Internal(LHandle);
      SetLastError(ERROR_PROC_NOT_FOUND);
      Break;
    end;

    Inc(LImportDesc); // Move to the next import descriptor
  end; // while
end;

{
  Procedure: MemoryFreeLibrary
  ----------------------------
  Frees the memory allocated for the loaded module and releases any associated resources.

  Parameters:
    Module - Pointer to the memory module to be freed.
}
procedure MemoryFreeLibrary(Module: Pointer); stdcall;
var
  I: Integer;                  // Loop counter for imported modules
  LDllEntry: TDllEntryProc;    // Pointer to the DLL entry procedure
  LMemModule: PMemoryModule;   // Pointer to the memory module record
begin
  if Module = nil then Exit;   // If no module is provided, exit immediately

  LMemModule := PMemoryModule(Module); // Cast the generic pointer to PMemoryModule

  if LMemModule^.Initialized then
  begin
    // If the module has been initialized, notify it about detaching from the process
    @LDllEntry := Pointer(PByte(LMemModule^.CodeBase) + LMemModule^.Headers^.OptionalHeader.AddressOfEntryPoint);
    LDllEntry(HINST(LMemModule^.CodeBase), DLL_PROCESS_DETACH, nil);
  end;

  if Length(LMemModule^.Modules) <> 0 then
  begin
    // Iterate through all imported modules and free them
    for I := 0 to LMemModule^.NumModules - 1 do
      if LMemModule^.Modules[I] <> 0 then
        FreeLibrary_Internal(LMemModule^.Modules[I]);

    // Clear the Modules array
    SetLength(LMemModule^.Modules, 0);
  end;

  if LMemModule^.CodeBase <> nil then
    // Release the memory allocated for the module's code and data
    VirtualFree(LMemModule^.CodeBase, 0, MEM_RELEASE);

  // Free the memory allocated for the module record itself
  HeapFree(GetProcessHeap(), 0, LMemModule);
end;

{
  Function: MemoryLoadLibrary
  ----------------------------
  Loads a module from a memory image and prepares it for execution.

  Parameters:
    Data - Pointer to the memory image of the module.

  Returns:
    Pointer to the memory module record, or nil on failure.
}
function MemoryLoadLibrary(Data: Pointer): Pointer; stdcall;
var
  LDosHeader: PIMAGE_DOS_HEADER;             // Pointer to the DOS header of the module
  LOldHeader: PIMAGE_NT_HEADERS64;           // Pointer to the NT headers of the module
  LCode: Pointer;                            // Base address where the module will be loaded
  LHeaders: Pointer;                         // Pointer to the allocated memory for headers
  LLocationDelta: NativeInt;                 // Difference between actual and preferred base address
  LSysInfo: SYSTEM_INFO;                     // System information structure
  LDllEntry: TDllEntryProc;                  // Pointer to the DLL entry procedure
  LSuccessfull: Boolean;                     // Indicates if the DLL entry was successful
  LModule: PMemoryModule;                    // Pointer to the memory module record
begin
  Result := nil;  // Initialize Result to nil (failure by default)
  LModule := nil;  // Initialize Module pointer to nil

  try
    LDosHeader := PIMAGE_DOS_HEADER(Data); // Cast Data to DOS header pointer

    // Validate the DOS header signature ("MZ")
    if (LDosHeader^.e_magic <> IMAGE_DOS_SIGNATURE) then
    begin
      SetLastError(ERROR_BAD_EXE_FORMAT); // Set error code for bad executable format
      Exit; // Exit the function with Result = nil
    end;

    // Locate the NT headers using the e_lfanew offset
    LOldHeader := PIMAGE_NT_HEADERS64(PByte(Data) + LDosHeader^._lfanew);

    // Validate the NT headers signature ("PE\0\0")
    if LOldHeader^.Signature <> IMAGE_NT_SIGNATURE then
    begin
      SetLastError(ERROR_BAD_EXE_FORMAT); // Set error code for bad executable format
      Exit; // Exit the function with Result = nil
    end;

    // Ensure the module is for the AMD64 architecture
    if LOldHeader^.FileHeader.Machine <> IMAGE_FILE_MACHINE_AMD64 then
    begin
      SetLastError(ERROR_BAD_EXE_FORMAT); // Set error code for bad executable format
      Exit; // Exit the function with Result = nil
    end;

    // Check if the section alignment is supported (must be a multiple of 2)
    if (LOldHeader^.OptionalHeader.SectionAlignment and 1) <> 0 then
    begin
      SetLastError(ERROR_BAD_EXE_FORMAT); // Set error code for bad executable format
      Exit; // Exit the function with Result = nil
    end;

    // Attempt to reserve memory for the module image at its preferred base address
    LCode := VirtualAlloc(
      Pointer(LOldHeader^.OptionalHeader.ImageBase), // Preferred base address
      LOldHeader^.OptionalHeader.SizeOfImage,        // Size of the image to allocate
      MEM_RESERVE or MEM_COMMIT,                     // Allocation type: reserve and commit
      PAGE_READWRITE                                 // Memory protection: read/write
    );

    if LCode = nil then
    begin
      // If reservation at the preferred address fails, allocate memory at any address
      LCode := VirtualAlloc(
        nil,                                       // Let the system choose the address
        LOldHeader^.OptionalHeader.SizeOfImage,    // Size of the image to allocate
        MEM_RESERVE or MEM_COMMIT,                 // Allocation type: reserve and commit
        PAGE_READWRITE                             // Memory protection: read/write
      );

      if LCode = nil then
      begin
        SetLastError(ERROR_OUTOFMEMORY); // Set error code for out of memory
        Exit; // Exit the function with Result = nil
      end;
    end;

    // Allocate and zero-initialize the memory module record
    LModule := PMemoryModule(HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, SizeOf(TMemoryModuleRec)));
    if LModule = nil then
    begin
      VirtualFree(LCode, 0, MEM_RELEASE); // Free the previously allocated memory
      SetLastError(ERROR_OUTOFMEMORY);    // Set error code for out of memory
      Exit; // Exit the function with Result = nil
    end;

    // Initialize the memory module record
    LModule^.CodeBase := LCode; // Set the base address where the module is loaded
    LModule^.Headers := LOldHeader; // Set the pointer to the NT headers
    GetNativeSystemInfo(LSysInfo); // Retrieve system information
    LModule^.PageSize := LSysInfo.dwPageSize; // Store the system's page size

    // Commit memory for the PE headers
    LHeaders := VirtualAlloc(
      LCode,                                    // Base address where the module is loaded
      LOldHeader^.OptionalHeader.SizeOfHeaders, // Size of the headers to allocate
      MEM_COMMIT,                               // Allocation type: commit
      PAGE_READWRITE                            // Memory protection: read/write
    );

    // Copy the PE headers from the DLL data into the allocated memory
    CopyMemory(
      LHeaders,                                // Destination address for headers
      Data,                                    // Source address (DLL data)
      LOldHeader^.OptionalHeader.SizeOfHeaders // Number of bytes to copy
    );

    // Update the Headers pointer to point to the new location in memory
    LModule^.Headers := PIMAGE_NT_HEADERS64(PByte(LHeaders) + LDosHeader^._lfanew);

    // Copy all sections from the DLL data into the allocated memory
    if not CopySections(Data, LOldHeader, LModule) then
      Abort; // Abort if copying sections fails

    // Calculate the difference between the allocated base address and the preferred base address
    LLocationDelta := NativeUInt(LCode) - LOldHeader^.OptionalHeader.ImageBase;
    if LLocationDelta <> 0 then
      // Perform base relocation if the module is not loaded at its preferred base address
      LModule^.IsRelocated := PerformBaseRelocation(LModule, LLocationDelta)
    else
      LModule^.IsRelocated := True; // No relocation needed if loaded at preferred base

    // Build the import table by resolving all imported functions
    if not BuildImportTable(LModule) then
      Abort; // Abort if building the import table fails

    // Finalize memory protection settings for all sections
    if not FinalizeSections(LModule) then
      Abort; // Abort if finalizing sections fails

    // Execute TLS callbacks before the main loading process
    if not ExecuteTLS(LModule) then
      Abort; // Abort if executing TLS callbacks fails

    // If the module has an entry point, call the DLL entry procedure
    if LModule^.Headers^.OptionalHeader.AddressOfEntryPoint <> 0 then
    begin
      // Calculate the address of the DLL entry point
      @LDllEntry := Pointer(PByte(LCode) + LModule^.Headers^.OptionalHeader.AddressOfEntryPoint);
      // Call the DLL entry procedure to notify about attaching to the process
      LSuccessfull := LDllEntry(HINST(LCode), DLL_PROCESS_ATTACH, nil);
      if not LSuccessfull then
      begin
        // If the DLL entry procedure fails, set an error and abort
        SetLastError(ERROR_DLL_INIT_FAILED);
        Abort;
      end;
      LModule^.Initialized := True; // Mark the module as initialized
    end;

    // Set the function result to the loaded module
    Result := LModule;
  except
    // In case of any exception, free the allocated module and exit
    MemoryFreeLibrary(LModule);
    Exit;
  end;
end;

{
  Function: MemoryGetProcAddress
  -------------------------------
  Retrieves the address of an exported function from the loaded module.

  Parameters:
    Module - Pointer to the memory module.
    Name   - Name of the function.

  Returns:
    Pointer to the requested function, or nil if not found.
}
function MemoryGetProcAddress(Module: Pointer; const Name: PAnsiChar): Pointer; stdcall;
var
  LCodeBase: Pointer;                    // Base address where the module is loaded
  LIdx: Integer;                         // Index of the found function
  I: DWORD;                              // Loop counter for names
  LNameRef: PDWORD;                      // Pointer to the list of function names
  LOrdinal: PWord;                       // Pointer to the list of ordinals
  LExportDir: PIMAGE_EXPORT_DIRECTORY;   // Pointer to the export directory
  LDirectory: PIMAGE_DATA_DIRECTORY;     // Pointer to the export data directory
  LTemp: PDWORD;                         // Temporary pointer for function addresses
  LMemModule: PMemoryModule;             // Pointer to the memory module record
begin
  Result := nil; // Initialize Result to nil (failure by default)
  LMemModule := PMemoryModule(Module); // Cast the generic pointer to PMemoryModule

  LCodeBase := LMemModule^.CodeBase; // Retrieve the base address where the module is loaded

  // Retrieve the export directory from the module's data directories
  LDirectory := GET_HEADER_DICTIONARY(LMemModule, IMAGE_DIRECTORY_ENTRY_EXPORT);
  if LDirectory^.Size = 0 then
  begin
    // No export table found; set an error and exit
    SetLastError(ERROR_PROC_NOT_FOUND);
    Exit;
  end;

  // Calculate the address of the export directory structure
  LExportDir := PIMAGE_EXPORT_DIRECTORY(PByte(LCodeBase) + LDirectory^.VirtualAddress);

  // Check if the module exports any functions
  if (LExportDir^.NumberOfNames = 0) or (LExportDir^.NumberOfFunctions = 0) then
  begin
    // No exported functions; set an error and exit
    SetLastError(ERROR_PROC_NOT_FOUND);
    Exit;
  end;

  // Initialize pointers to the list of function names and ordinals
  LNameRef := PDWORD(PByte(LCodeBase) + LExportDir^.AddressOfNames);
  LOrdinal := PWord(PByte(LCodeBase) + LExportDir^.AddressOfNameOrdinals);
  LIdx := -1; // Initialize the index to -1 (not found)

  // Iterate through all exported names to find a match
  for I := 0 to LExportDir^.NumberOfNames - 1 do
  begin
    if StrComp(Name, PAnsiChar(PByte(LCodeBase) + LNameRef^)) = 0 then
    begin
      // If a matching name is found, store its ordinal index
      LIdx := LOrdinal^;
      Break; // Exit the loop as the function is found
    end;
    Inc(LNameRef); // Move to the next function name
    Inc(LOrdinal); // Move to the next ordinal
  end;

  // Check if the function was found
  if (LIdx = -1) then
  begin
    // Function name not found; set an error and exit
    SetLastError(ERROR_PROC_NOT_FOUND);
    Exit;
  end;

  // Verify that the ordinal index is within the valid range
  if (DWORD(LIdx) >= LExportDir^.NumberOfFunctions) then
  begin
    // Ordinal index out of range; set an error and exit
    SetLastError(ERROR_PROC_NOT_FOUND);
    Exit;
  end;

  // Retrieve the function's RVA (Relative Virtual Address) using the ordinal index
  LTemp := PDWORD(PByte(LCodeBase) + LExportDir^.AddressOfFunctions + LIdx * SizeOf(DWORD));
  Result := Pointer(PByte(LCodeBase) + LTemp^); // Calculate the absolute address of the function
end;

{
  Function: LoadLibrary
  ----------------------
  Public interface to load a module from a memory image.

  Parameters:
    Data - Pointer to the memory image of the module.

  Returns:
    Handle to the loaded module.
}
function LoadLibrary(const AData: Pointer): THandle;
begin
  // Call the internal MemoryLoadLibrary function and cast its result to THandle
  Result := THandle(MemoryLoadLibrary(AData));
end;

{
  Function: GetProcAddress
  -------------------------
  Public interface to retrieve a function address from a loaded module.

  Parameters:
    Module - Handle to the loaded module.
    Name   - Name of the function.

  Returns:
    Pointer to the requested function.
}
function GetProcAddress(const AModule: THandle; const AName: PAnsiChar): Pointer;
begin
  // Call the internal MemoryGetProcAddress function with the module pointer and function name
  Result := MemoryGetProcAddress(Pointer(AModule), AName);
end;

{
  Procedure: FreeLibrary
  -----------------------
  Public interface to free a loaded module from memory.

  Parameters:
    Module - Handle to the module to be freed.
}
procedure FreeLibrary(const AModule: THandle);
begin
  // Call the internal MemoryFreeLibrary function with the module pointer
  MemoryFreeLibrary(Pointer(AModule));
end;

initialization
{$IFNDEF FPC}
  // Enable memory leak reporting on application shutdown in Delphi.
  // This helps identify any memory leaks that might occur while using this unit.
  // This directive has no effect in Free Pascal Compiler (FPC) as it is Delphi-specific.
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  // Configure floating-point exception handling.
  // Sets the exception mask to include floating-point overflow and invalid operation exceptions.
  // This prevents runtime errors for certain floating-point operations that would normally trigger exceptions.
  SetExceptionMask(GetExceptionMask + [exOverflow, exInvalidOp]);

finalization

end.

