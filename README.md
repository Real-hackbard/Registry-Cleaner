# Registry-Cleaner:

</br>

```ruby
Compiler    : Delphi10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athens
Components  : CleanReg.pas
Discription : Registry Cleaner
Last Update : 08/2025
License     : Freeware
```

</br>

[Registry](https://en.wikipedia.org/wiki/Windows_Registry) cleaners seem to no longer be supported by Microsoft, despite originally having made and distributed their own registry cleaner under the name of RegClean. Currently, vendors of registry cleaners claim that they are useful to repair inconsistencies arising from manual changes to applications, especially [COM-based](https://en.wikipedia.org/wiki/Component_Object_Model) programs.

The effectiveness of Registry cleaners is a controversial topic. The issue is further clouded by the fact that [malware](https://en.wikipedia.org/wiki/Malware) and [scareware](https://en.wikipedia.org/wiki/Scareware) are often associated with utilities of this type.

Due to the sheer size and complexity of the Registry database, manually cleaning up redundant and invalid entries may be impractical, so Registry cleaners try to automate the process of looking for invalid entries, missing file references or broken links within the Registry and resolving or removing them.

The correction of an invalid Registry key (such as one or more that remain after uninstallation of a program application) can provide some benefits; but the most voluminous will usually be quite harmless, obsolete records linked with COM-based applications whose associated files are no longer present.

This is an example of how to search for such entries in the registry and remove them. The prerequisite is that the program has administrator privileges to remove all found entries.

### The master keys are searched:
* HKEY_CLASSES_ROOT
* HKEY_CURRENT_USER
* HKEY_LOCAL_MACHINE
### Features:
* Clear Temp Files
* Uninstall Programs

</br>

![Registry Cleaner](https://github.com/user-attachments/assets/1e49aa9a-2242-4009-ab86-f8b9657c1b91)

</br>

### Registry damage:
Some Registry cleaners make no distinction as to the severity of the errors, and many that do may erroneously categorize errors as "critical" with little basis to support it. Removing or changing certain Registry data can prevent the system from starting, or cause application errors and crashes.

It is not always possible for a third-party program to know whether any particular key is invalid or redundant. A poorly designed Registry cleaner may not be equipped to know for sure whether a key is still being used by Windows or what detrimental effects removing it may have. This may lead to loss of functionality and/or system instability, As well as [application compatibility updates](https://en.wikipedia.org/wiki/Shim_(computing)) from Microsoft to block problematic Registry cleaners. The [Windows Installer](https://en.wikipedia.org/wiki/Windows_Installer) CleanUp Utility was a Microsoft-supported utility for addressing Windows Installer related issues.

The use of any registry cleaner can be detrimental to a machine, and there is never a good reason to ‘clean’ a registry. It is not a source of load or lag on a system in any way and can lead to additional problems such as software not working or even Windows failing to work, if a [registry backup](https://en.wikipedia.org/wiki/Backup) has not been performed.

### Malware payloads:
Registry cleaners have been used as a vehicle by a number of [trojan](https://en.wikipedia.org/wiki/Trojan_horse_(computing)) applications to install malware, typically through [social engineering](https://en.wikipedia.org/wiki/Social_engineering_(security)) attacks that use website [pop-up ads](https://en.wikipedia.org/wiki/Pop-up_ad) or free downloads that falsely report problems that can be "rectified" by purchasing or downloading a Registry cleaner. The worst of the breed are products that advertise and encourage a "free" Registry scan; however, the user typically finds the product has to be purchased for a substantial sum, before it will effect any of the anticipated "repairs". The [rogue security software](https://en.wikipedia.org/wiki/Rogue_security_software) "[WinFixer](https://en.wikipedia.org/wiki/WinFixer)" including Registry cleaners has been ranked as one of the most prevalent pieces of malware currently in circulation.

### Scanners as scareware:
Rogue Registry cleaners are often marketed with alarmist advertisements that falsely claim to have reanalysed your PC, displaying bogus warnings to take "corrective" action; hence the descriptive label "[scareware](https://en.wikipedia.org/wiki/Scareware)". In October 2008, Microsoft and the Washington attorney general filed a lawsuit against two Texas firms, Branch Software and Alpha Red, producers of the "Registry Cleaner XP" scareware. The lawsuit alleges that the company sent incessant pop-ups resembling system warnings to consumers' personal computers stating "CRITICAL ERROR MESSAGE! - REGISTRY DAMAGED AND CORRUPTED", before instructing users to visit a web site to download Registry Cleaner XP at a cost of $39.95.

### Undeletable registry keys:
Most Registry cleaners cannot repair scenarios such as undeletable Registry keys caused by embedded null characters in their names; only specialized tools such as the RegDelNull utility (part of the free [Sysinternals software](https://en.wikipedia.org/wiki/Sysinternals)) are able to do this.

### Set Token Privilege:
Example of setting privileges: to have specific keys removed.

```pascal
function SetTokenPrivilege(const APrivilege: string; const AEnable: Boolean): Boolean;
var
  LToken: THandle;
  LTokenPriv: TOKEN_PRIVILEGES;
  LPrevTokenPriv: TOKEN_PRIVILEGES;
  LLength: Cardinal;
  LErrval: Cardinal;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, LToken) then
  try
    // Get the locally unique identifier (LUID) .
    if LookupPrivilegeValue(nil, PChar(APrivilege), LTokenPriv.Privileges[0].Luid) then
    begin
      LTokenPriv.PrivilegeCount := 1; // one privilege to set
      case AEnable of
        True: LTokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        False: LTokenPriv.Privileges[0].Attributes := 0;
      end;
      LPrevTokenPriv := LTokenPriv;
      // Enable or disable the privilege
      Result := AdjustTokenPrivileges(LToken, False, LTokenPriv, SizeOf(LPrevTokenPriv), LPrevTokenPriv, LLength);
    end;
  finally
    CloseHandle(LToken);
  end;
end;
```

</br>

### Temporary files:
Temporary files are data files created by programs or operating systems to hold information temporarily while a process runs, such as during software installations or updates, or for functions like undo/redo. While most are deleted automatically when no longer needed, some may accumulate and take up disk space. Deleting these unneeded temporary files can free up disk space and improve computer performance. 

### Why temporary files are created:
* Intermediate storage: Programs use them to hold data that is being processed or moved to a permanent file. 
* Caching: They can store frequently accessed data for faster retrieval. 
* State preservation: Temporary files can preserve the state of a software application. 
* Data recovery: Some temporary files contain data that helps recover lost information. 

### Uninstaller:
To uninstall a program using a registry key, locate the UninstallString within the Uninstall key for the specific program in the registry editor. The UninstallString contains the command (usually msiexec.exe) and parameters needed to uninstall the program. Running this command will initiate the program's uninstallation process. 

* Locate the Registry Key:
Open the Registry Editor (regedit.exe) and navigate to:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall for 64-bit programs on 64-bit Windows.
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall for 32-bit programs on 64-bit Windows. 
```
* Find the Program: Look for a subkey within Uninstall that corresponds to the program you want to uninstall. You can often identify it by its DisplayName value. 
* Find the UninstallString: Inside the subkey, locate the UninstallString value. 
* Run the Command:
* The UninstallString value contains the command to uninstall the program. It might look like MsiExec.exe /X{GUID} or C:\Program Files\...\uninstall.exe. Execute this command using cmd.exe or by double-clicking it in the registry editor.
* Backup the Registry: Before making any changes to the registry, it's recommended to back it up. Incorrect registry modifications can cause system instability. 
* Use with Caution: Be extremely careful when working with the registry. Only modify or delete entries if you are instructed to do so by a trusted source. 
* Alternative Uninstall Methods: If you can't find the UninstallString or if the command doesn't work, consider using the built-in Windows Programs and Features (Add/Remove Programs) or the program's own uninstaller. 
