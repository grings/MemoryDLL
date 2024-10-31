![MemoryDLL](media/memorydll.png)  
[![Chat on Discord](https://img.shields.io/discord/754884471324672040?style=for-the-badge)](https://discord.gg/tPWjMwK) [![Twitter Follow](https://img.shields.io/twitter/follow/tinyBigGAMES?style=for-the-badge)](https://twitter.com/tinyBigGAMES)
  
<div align="center">

### In-Memory Win64 DLL Loading & Execution for Pascal 💻🔄

</div>

### Overview 📝

The **MemoryDLL** unit provides advanced functionality for loading dynamic-link libraries (DLLs) directly from memory in Win64 environments. Unlike traditional methods that involve loading DLLs from the file system, **MemoryDLL** allows you to load DLLs from byte arrays 📂 or memory streams 💾, retrieve function addresses, and unload them—all in-memory. This library is ideal for Delphi/FreePascal developers who need to manage DLLs without relying on the filesystem, enhancing both performance ⚡ and security 🔒.

### Features ✨

- **LoadFromMemory**: Loads a DLL from a memory buffer without writing to the disk 💽.
- **GetFunctionAddress**: Retrieves the address of an exported function within the loaded DLL, enabling direct function calls 📞.
- **FreeModule**: Unloads the DLL from memory, ensuring all associated resources are properly released 🔄.
- **Comprehensive Error Handling**: Manages issues such as invalid DLL data 🚫, memory allocation failures 🚨, and function resolution issues 🔧.

### Key Benefits 🌟

- **Increased Security 🔒**: By eliminating the need to store DLLs on disk, **MemoryDLL** reduces the risk of DLL hijacking and unauthorized access.
- **Performance Improvement ⚡**: Since DLLs are handled in-memory, the overhead of disk I/O operations is avoided, resulting in faster execution 🚀.
- **Flexibility 🤹**: Suitable for embedding DLLs in the main executable, loading encrypted 🔐 or obfuscated DLLs, and supporting dynamic plugin systems where plugins are provided as in-memory modules.

### Implementation Details 🔍

**MemoryDLL** uses low-level Windows API functions to manage DLLs entirely from memory:

1. **Manual Mapping 🗺️**: The unit manually parses the DLL's Portable Executable (PE) format, maps its sections, and relocates addresses.
2. **Relocation Handling 🔄**: Handles relocation entries to ensure the DLL functions correctly at its loaded memory address.
3. **Import Table Resolution 📋**: Resolves all imported symbols, making the DLL fully functional once loaded.

**Compatibility 🤝**: This unit is designed to be compatible with standard DLL interfaces, making it easy to integrate with existing applications. Additionally, security best practices are incorporated to prevent vulnerabilities like code injection 💉.

### Usage Scenarios 🎯

#### Embedding DLLs 📦

- Embed DLLs directly within your executable. **MemoryDLL** allows you to store DLLs as resources or encrypted data and load them into memory at runtime, removing the need to distribute them as separate files.

#### Encrypted DLL Loading 🔐

- Enhance application security by storing DLLs in an encrypted form, which can then be decrypted into memory before loading with **MemoryDLL**. This reduces the risk of reverse engineering.

#### Dynamic Plugin Systems 🔌

- Load plugins dynamically as in-memory DLLs. This approach provides a clean and secure method of extending application functionality without relying on the filesystem.

### Public Functions 📖

#### LoadLibrary 📜

Loads a module from a memory image, mimicking the behavior of the Windows API `LoadLibrary` function. It parses the PE format, performs necessary relocations, resolves imports, and initializes the module.

- **Parameters**: `Data: Pointer` – A pointer to the memory image conforming to the PE format.
- **Returns**: `THandle` representing the loaded module or `0` on failure.

#### FreeLibrary 🚫

Frees a module loaded with `LoadLibrary`. It releases all memory and resources associated with the DLL, ensuring clean detachment.

- **Parameters**: `Module: THandle` – Handle of the module to be freed.

#### GetProcAddress 🔍

Retrieves the address of an exported function from a loaded DLL, similar to the Windows API `GetProcAddress` function.

- **Parameters**:
  - `Module: THandle` – Handle to the loaded module.
  - `Name: PAnsiChar` – Name of the function to retrieve.
- **Returns**: `Pointer` to the function, or `nil` if not found.

### Installation 🛠️

To successfully integrate **MemoryDLL** into your project, please follow these steps:

1. **Download the Latest Version 📥**
   - Visit the official **MemoryDLL** repository and download the latest release.

2. **Unzip the Package 📂**
   - Once the download is complete, extract the contents of the zip file to a convenient location on your device's filesystem. The extracted folder should contain the MemoryDLL source code, documentation, and any necessary dependencies.

3. **Add MemoryDLL to Your Project ➕**
   - Add **MemoryDLL** to your project's `uses` section. This inclusion will make the **MemoryDLL** unit available for use in your application. Ensure that the path to the **MemoryDLL** source file is correctly configured in your project settings to avoid compilation errors.

4. **Integration as a Drop-in Replacement 🔄**
   - The **MemoryDLL** unit is designed to serve as a drop-in replacement for the Windows API functions `LoadLibrary`, `FreeLibrary`, and `GetProcAddress`. Simply replace existing calls to these API functions with their **MemoryDLL** counterparts (`LoadFromMemory`, `FreeModule`, `GetFunctionAddress`). This seamless substitution allows you to benefit from in-memory DLL management without major code modifications.

5. **Test the Integration ✅**
   - It is recommended to thoroughly test your project after integrating **MemoryDLL** to ensure that all DLLs are being correctly loaded, utilized, and unloaded from memory. Given the in-memory nature of this library, testing will help identify any potential issues related to memory management or function resolution.
   - Created/tested with Delphi 12.2, on Windows 11, 64-bit (latest version)

### Acknowledgments 🙏

This project is based on the original **Delphi MemoryModule** project by [Fr0sT-Brutal](https://github.com/Fr0sT-Brutal/Delphi_MemoryModule). We gratefully acknowledge the foundational work that this unit builds upon.

### License 📜

This project is licensed under the **BSD-3-Clause License** 📃, which allows for redistribution and use in source and binary forms, with or without modification, provided that certain conditions are met. It strikes a balance between permissiveness and protecting the rights of contributors.

### How to Contribute 🤝

Contributions to **MemoryDLL** are highly encouraged. Please feel free to submit issues, suggest new features, or create pull requests to expand its capabilities and robustness.

### Support 📧

- <a href="https://github.com/tinyBigGAMES/MemoryDLL/issues" target="_blank">Issues</a>
- <a href="https://github.com/tinyBigGAMES/MemoryDLL/discussions" target="_blank">Discussions</a>
- <a href="https://learndelphi.org/" target="_blank">Learn Delphi</a>
- <a href="https://wiki.freepascal.org/" target="_blank">FreePascal Wiki</a>

<p align="center">
<img src="media/delphi.png" alt="Delphi">
</p>
<h5 align="center">

Made with :heart: in Delphi
</h5>


