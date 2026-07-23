Unit CleanReg;

interface

uses
  Windows, SysUtils, Classes, Dialogs, Controls, Forms, ShlObj, Registry;

Const
  // Windows environment variable
  PATH_DESKTOP                       = $0000;  
  PATH_INTERNET                      = $0001;
  PATH_PROGRAMS                      = $0002;  
  PATH_CONTROLS                      = $0003;  
  PATH_PRINTERS                      = $0004;
  PATH_PERSONAL                      = $0005;  
  PATH_FAVORITES                     = $0006;  
  PATH_STARTUP                       = $0007;  
  PATH_RECENT                        = $0008;  
  PATH_SENDTO                        = $0009;
  PATH_BITBUCKET                     = $000a;
  PATH_STARTMENU                     = $000b;  
  PATH_DESKTOPDIRECTORY              = $0010;  
  PATH_DRIVES                        = $0011;
  PATH_NETWORK                       = $0012;
  PATH_NETHOOD                       = $0013;
  PATH_FONTS                         = $0014;
  PATH_TEMPLATES                     = $0015;
  PATH_COMMON_STARTMENU              = $0016;
  PATH_COMMON_PROGRAMS               = $0017;
  PATH_COMMON_STARTUP                = $0018;
  PATH_COMMON_DESKTOPDIRECTORY       = $0019;
  PATH_APPDATA                       = $001a;
  PATH_PRINTHOOD                     = $001b;
  PATH_ALTSTARTUP                    = $001d;
  PATH_COMMON_ALTSTARTUP             = $001e;
  PATH_COMMON_FAVORITES              = $001f;
  PATH_INTERNET_CACHE                = $0020;
  PATH_COOKIES                       = $0021;
  PATH_HISTORY                       = $0022;
  PATH_TEMP                          = $0023; 
  PATH_MYMUSIC_XP                    = $000d;
  PATH_MYGRAPHICS_XP                 = $0027;
  PATH_WINDOWS                       = $0024; 
  PATH_SYSTEM                        = $0025; 
  PATH_PROGRAMFILES                  = $0026; 
  PATH_COMMONFILES                   = $002b; 
  PATH_RESOURCES_XP                  = $0038;
  PATH_CURRENTUSER_XP                = $0028;
  OS_Version                         = $0001;
  OS_Platform                        = $0002;
  OS_Name                            = $0003;
  OS_Organization                    = $0004;
  OS_Owner                           = $0005;
  OS_SerNumber                       = $0006;
  OS_WinPath                         = $0007;
  OS_SysPath                         = $0008;
  OS_TempPath                        = $0009;
  OS_ProgramFilesPath                = $000a;
  OS_IPName                          = $000b;

Type TSystemPath=(Desktop,StartMenu,Programs,Startup,Personal, winroot, winsys);
type
  TCleanThread = class(TThread)
  private
  { Private-Deklarationen}
    Procedure GetSub(Node,NodeKey: String; Root: Cardinal);
    Procedure RegRecurseScan(ANode: String; Key, OldKey: string; Level: Integer);
    Procedure ScanRegistry(Root: Cardinal; Metod: integer);
  protected
  { Declarations protected }
    procedure Execute; override;
  public
  { Declarations published }
    Root: Cardinal;
    Key: String;
    scanning: boolean;
    InvExt: Boolean;
    InvFlp: Boolean;
  end;

var
  FReg, reg: TRegistry;
  Log : TStringList;
  Ext: String;
  ScanMb : Real;
  FSize: integer;
  P: TStringList;i:byte;

Procedure InitLog;
Procedure FreeLog(Save: Boolean ;SavePath: String);
Function ClearKey(RootKey: Cardinal; Key: String; Value: String; Param: String ;DelKey: Boolean; ReservCopy: Boolean):Boolean;
Procedure CleanWindows;
procedure ScanUNINST;
function Check:string;
function SetPrivilege(const PrivilegeName: string; const Enable: Boolean): Boolean;

implementation

uses
  Unit1;

  // Activating or setting Windows privileges for the registry
function SetPrivilege(const PrivilegeName: string; const Enable: Boolean): Boolean;
var
  hToken: THandle;
  TokenPrivileges: TOKEN_PRIVILEGES;
  PreviousState: TOKEN_PRIVILEGES;
  ReturnLength: DWORD;
begin
  Result := False;
  // Open the process token with the necessary access rights.
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  try
    TokenPrivileges.PrivilegeCount := 1;
    // Determine the LUID (Locally Unique Identifier) ​​for the privilege name.
    if LookupPrivilegeValue(nil, PChar(PrivilegeName), TokenPrivileges.Privileges[0].Luid) then
    begin
      if Enable then
        TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
      else
        TokenPrivileges.Privileges[0].Attributes := 0;
      ReturnLength := SizeOf(PreviousState);
      // Adjust token privilege
      AdjustTokenPrivileges(
        hToken,
        False,
        TokenPrivileges,
        SizeOf(PreviousState),
        PreviousState,
        ReturnLength
      );
      // Check whether the action was successful (GetLastError = 0 or ERROR_SUCCESS)
      Result := (GetLastError = ERROR_SUCCESS);
    end;
  finally
    CloseHandle(hToken);
  end;
end;

// Determine the list of all uninstall entries.
procedure ScanUNINST;
begin
  Form1.ListBox2.Clear;
  reg := TRegistry.Create;
  p := TStringList.Create;
  // open root key
  reg.RootKey := HKEY_LOCAL_MACHINE;

  // open registry key
  if reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',false) then
     reg.GetKeyNames(p);
     reg.Free;

     // creating the entire list
     if p.Count>0 then
      for i := 0 to p.Count-1 do
      begin
        reg := TRegistry.Create;
        reg.RootKey := HKEY_LOCAL_MACHINE;
        // Read the entries.
        if  reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+p[i],false) then
          if reg.ValueExists('DisplayName') then
            if reg.ValueExists('UninstallString') then
            // Enter them into the box.
            Form1.ListBox2.Items.Add(reg.ReadString('DisplayName'));
        reg.Free;
      end;
  if Form1.ListBox2.Count > 0 then
    Form1.ListBox2.Selected[0] := true;
    Form1.StatusBar1.Panels[5].Text := IntToStr(Form1.ListBox2.Items.Count);
end;

// Checking the entries
function Check:string;
begin
  result:='';
  for i := 0 to p.Count-1 do
  begin
    reg:=TRegistry.Create;
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    if  reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+p[i],false) then
      if reg.ValueExists('UninstallString') then
        if Form1.ListBox2.Items.Strings[Form1.ListBox2.ItemIndex]=reg.ReadString('DisplayName') then
          begin
            result:='SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+p[i];
            reg.CloseKey;
            reg.Free;
            exit;
          end;
  end;
end;

// Determine the file size if necessary.
function Get_File_Size4(const S: string): Int64;
var
  FD: TWin32FindData;
  FH: THandle;
begin
  FH := FindFirstFile(PChar(S), FD);
  if FH = INVALID_HANDLE_VALUE then Result := 0
  else
    try
      Result := FD.nFileSizeHigh;
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    finally
      //CloseHandle(FH);
    end;
end;

{ System directories are retrieved using the Windows API function
  "SHGetSpecialFolderPath" or more modern equivalents, since a direct
  command named GetSystemPath is not a standard runtime library (RTL)
  function but is often implemented as a custom wrapper. }
function GetSystemPath(Handle: THandle; PATH_type: WORD): String;
var
  P:PItemIDList;
  C:array [0..1000] of char;
  PathArray:array [0..255] of char;
begin
  if PATH_type = PATH_TEMP then
  begin
    FillChar(PathArray,SizeOf(PathArray),0);
    ExpandEnvironmentStrings('%TEMP%', PathArray, 255);
    Result := Format('%s',[PathArray])+'\';
    Exit;
  end;
  if PATH_type = PATH_WINDOWS then
  begin
    FillChar(PathArray,SizeOf(PathArray),0);
    GetWindowsDirectory(PathArray,255);
    Result := Format('%s',[PathArray])+'\';
    Exit;
  end;
  if PATH_type = PATH_SYSTEM then
  begin
    FillChar(PathArray,SizeOf(PathArray),0);
    GetSystemDirectory(PathArray,255);
    Result := Format('%s',[PathArray])+'\';
    Exit;
  end;
  if (PATH_type = PATH_PROGRAMFILES) or(PATH_type = PATH_COMMONFILES) then
  begin
    FillChar(PathArray,SizeOf(PathArray),0);
    ExpandEnvironmentStrings('%ProgramFiles%', PathArray, 255);
    Result := Format('%s',[PathArray])+'\';
    if Result[1] = '%' then
    begin
      FillChar(PathArray,SizeOf(PathArray),0);
      GetSystemDirectory(PathArray,255);
      Result := Format('%s',[PathArray]);
      Result := Result[1]+':\Program Files\';
    end;
    if (PATH_type = PATH_COMMONFILES) then Result := Result+'Common Files\';
    Exit;
  end;
  if SHGetSpecialFolderLocation(Handle,PATH_type,p)=NOERROR then
  begin
    SHGetPathFromIDList(P,C);
    if   StrPas(C)<>'' then
      Result := StrPas(C)+'\'
    else
      Result:='';
  end;
end;

// standard way to search for files
Function FindFile(Dir:String): Boolean;
Var
  SR:TSearchRec;
  FindRes,i:Integer;
  EX,tmp : String;
  MDHash : String;
  c: cardinal;
  Four: integer;
begin
  Four := 0;
  // search for all existing files
  FindRes := FindFirst(Dir+'*.*',faAnyFile,SR);
  While FindRes=0 do
  begin
    // check is file or folder
    if ((SR.Attr and faDirectory)=faDirectory) and
    // file search loops (using FindFirst and FindNext) to ignore the
    // current and parent directory references that are returned
    // by the operating system.
    ((SR.Name='.')or(SR.Name='..')) then
      begin
        // copy content
        FindRes:=FindNext(SR);
        Continue;
      end;
    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
        FindFile(Dir+SR.Name+'\');
        FindRes:=FindNext(SR);
        Continue;
      end;
    Form1.RefreshApp;
    Ex := ExtractFileExt(Dir+SR.Name);
    if Ext <> '' then
    if LowerCase(Ex) = LowerCase(Ext) then
      begin
        FSize :=  Get_File_Size4(Dir+SR.Name);
        ScanMb := ScanMb + (FSize div 1024) / 1024;
        FSize := (FSize div 1024);
        Form1.ListBox1.Items.Add(Dir+SR.Name);
      end;
    if Ext = '' then
      begin
        FSize :=  Get_File_Size4(Dir+SR.Name);
        ScanMb := ScanMb + (FSize div 1024) / 1024;
        FSize := (FSize div 1024);
        Form1.ListBox1.Items.Add(Dir+SR.Name);
      end;
    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
  Form1.StatusBar1.Panels[3].Text := IntToStr(Form1.ListBox1.Items.Count-3);
end;

// Add the found files.
Procedure CleanWindows;
begin
  ScanMb := 0;
  if DirectoryExists(GetSystemPath(0,PATH_TEMP)) then
  begin
    Ext := '';
    FindFile(GetSystemPath(0,PATH_TEMP));
  end;

  if DirectoryExists(GetSystemPath(0,PATH_WINDOWS)+'Prefetch\') then
  begin
    Ext := '.pf';
    FindFile(GetSystemPath(0,PATH_WINDOWS)+'Prefetch\');
  end;

  Form1.ListBox1.Items.Add('');
  Form1.ListBox1.Items.Add('======================================================================');
  Form1.ListBox1.Items.Add(FormatFloat('0.00',ScanMb)+' ()');
  Form1.Button1.Enabled := True;
  Form1.Button3.Enabled := True;
  Form1.RCl.TabVisible := True;
  Form1.TabSheet2.TabVisible := True;
end;

// Additional entries in the *.reg file
Procedure InitLog;
begin
  Log := TStringList.Create;
  Log.Add('Windows Registry Editor');
  Log.Add('');
  Log.Add('');
end;

// Create a backup after deleting the entries, if desired.
Procedure FreeLog(Save: Boolean ;SavePath: String);
begin
  try
    if Save = true then
    begin
      Log.SaveToFile(SavePath);
    end;
    Log.Free;
  except
  end;
end;

// Gathering information to create the backup file
Procedure SaveReservCopy(RootKey: Cardinal; Key, Value, Param: String);
var
  RootStr: String;
  RG: TRegistry;
begin
  case RootKey of
    HKEY_CLASSES_ROOT: RootStr := 'HKEY_CLASSES_ROOT';
    HKEY_CURRENT_USER: RootStr := 'HKEY_CURRENT_USER';
    HKEY_LOCAL_MACHINE: RootStr := 'HKEY_LOCAL_MACHINE';
  end;

  try
    Rg := TRegistry.Create;
    Rg.RootKey := RootKey;
    if Rg.OpenKey(key,True) then
    begin
      Log.Add('['+RootStr+Key+']');
      if Value <> '' then
      begin
        Log.Add('"'+Value+'"="'+Param+'"');
      end;
    end;
  except
  end;
  RG.Free;
end;

// Deleting the selected registry entries
Function ClearKey(RootKey: Cardinal; Key: String; Value: String; Param: String ;
          DelKey: Boolean; ReservCopy: Boolean):Boolean;
var
  RG: TRegistry;
  RootStr: String;
begin
  case RootKey of
    HKEY_CLASSES_ROOT: RootStr := 'HKEY_CLASSES_ROOT';
    HKEY_CURRENT_USER: RootStr := 'HKEY_CURRENT_USER';
    HKEY_LOCAL_MACHINE: RootStr := 'HKEY_LOCAL_MACHINE';
  end;

  RG := TRegistry.Create;
  RG.RootKey := RootKey;
  if DelKey = True then
  begin
    Result := RG.DeleteKey(KEY);
      if ReservCopy = true then SaveReservCopy(RootKey, Key,'','');
  end else begin
    RG.OpenKey(Key,False);
    Result := RG.DeleteValue(Value);

    if ReservCopy = true then SaveReservCopy(RootKey, Key, Value, Param);
  end;
  RG.Free;
end;

{ to ensure that a file or folder path is correctly formatted – usually
  by adding a missing trailing path separator (such as \ or /) or by
  resolving relative paths. }
function FixupPath(Key: string): string;
begin
  if Key = '' then
    Result := '\'
  else
  // returns a pointer to the last character of a string (AnsiString)
  if AnsiLastChar(Key) <> '\' then
    Result := Key + '\'
  else
    Result := Key;
  if Length(Result) > 1 then
    if (Result[1] = '\') and (Result[2] = '\') then
      Result := Copy(Result, 2, Length(Result));
end;

// Method related to the processing of keyboard events
function GetPreviousKey(Key: string): string;
var
  I: Integer;
begin
  Result := Key;
  // check if a function's return value is either an empty string or
  // a path delimiter (backslash)
  if (Result = '') or (Result = '\') then Exit;
  for I := Length(Result) - 1 downto 1 do
    if Result[I] = '\' then
    begin
      Result := Copy(Result,1,I - 1);
      Exit;
    end;
end;

// Removing file formats
Function DelExt(Fname: String): String;
var
  TmpStr, Ext: String;
  Ps: integer;
begin
  // copy only the file extension
  Ext := ExtractFileExt(Fname);
  ps := pos(ext,Fname);
  tmpstr := Fname;

  if ps <> 0 then
  begin
    // removing the file extension
    Delete(TmpStr,ps,length(TmpStr)-ps+1);
  end;

  Result := TmpStr;
end;

// Retrieve information about the disk
function GetHDDSerial(ADisk : char): dword;
var
  SerialNum : dword;
  a, b : dword;
  VolumeName : array [0..255] of char;
begin
  try
    Result := 0;
    if GetVolumeInformation(PChar(ADisk + ':\'), VolumeName, SizeOf(VolumeName),
    @SerialNum, a, b, nil, 0) then
    Result := SerialNum;
  except
  end;
end;

// directory/file information from a string or check path structures
Function isPath(Param: string; var FormatPath: String): boolean;
var
  Fname, Str, Dir, Ext, Name, TempStr: String;
  Ps, Len, i: integer;
  Bol, ValidName: Boolean;
begin
  ValidName := true;
  Bol := False;
  Result := False;
  Fname := Param;
  Dir := '';
  Name := '';
  Ext := '';
  Dir := ExtractFileDrive(Fname);
  Name := ExtractFileName(Fname);
  Ext := ExtractFileExt(Fname);

  try
    // if found empty
    ps := Pos(' ',Ext);
    if ps <> 0 then
    begin
      Delete(Ext,ps,length(ext)-ps+1)
    end;
  except
  end;

  try
    // if an exclamation mark was found
    ps := Pos('!',Ext);
    if ps <> 0 then
    begin
      Delete(Ext,ps,length(Ext)-ps+1)
    end;
  except
  end;

  try
    // if a comma was found
    ps := Pos(',',Ext);
    if ps <> 0 then
    begin
      Delete(Ext,ps,length(Ext)-ps+1)
    end;
  except
  end;

  try
    // if a superscript character was found
    ps := Pos('^',Name);
    if ps <> 0 then
    begin
      Delete(Name,ps,length(Name)-ps+1)
    end;
  except
  end;

  try
    // if one percent was found
    ps := Pos('%',Name);
    if ps <> 0 then
    begin
      Delete(Name,ps,length(Name)-ps+1)
    end;
  except
  end;

  try
    tempstr := Param;
    if pos(':\',tempstr) <> 0 then
    Delete(tempstr,pos(':\',tempstr),2);
    if pos(':\',tempstr) <> 0 then ValidName := False;
  except
  end;

  if pos('|',Fname) <> 0 then ValidName := False;  // Vertical bar, Pipe
  if pos('=',Fname) <> 0 then ValidName := False;  // Equals sign
  if pos('*',Fname) <> 0 then ValidName := False;  // Asterisk sign
  if pos('/',Name) <> 0 then ValidName := False;   // slash sign
  if pos('\',Name) <> 0 then ValidName := False;   // backslash sign
  if pos('/',Name) <> 0 then ValidName := False;   // slash sign
  if pos('"',Name) <> 0 then ValidName := False;   // Quotation mark sign
  Ps := length(Fname);

  try
    if Fname[ps] = '.' then
      Bol := true;
  except
  end;

  if Length(Fname) > 3 then
  if Fname[2] = ':' then
    if Fname[3] = '\' then
      if ValidName = True then
        if (Dir <> '') and (Name <> '') and (Ext <> '') then
        begin
          Result := true;
          if Bol = False then
            FormatPath := ExtractFilePath(Fname)+DelExt(ExtractFileName(Name))+Ext
          else
            FormatPath := ExtractFilePath(Fname)+ExtractFileName(Name);
        end;
end;

// Output of the determined information
Procedure TCleanThread.GetSub(Node,NodeKey: String; Root: Cardinal);
var
  s,v,tmp: string;
  KeyInfo : TRegKeyInfo;
  ValueNames, Strtemp : TStringList;
  i,sn : Integer;
  DataType : TRegDataType;
  reg : TRegistry;
begin
  // go out wenn scanner stopped
  if scanning = False then Exit;

  s := Node;
  reg := TRegistry.Create;
  // Handover of the registry root key
  reg.RootKey := Root;

  // if no key was opened
  if not reg.OpenKeyReadOnly(s) then Exit;

  // Identify the key information.
  reg.GetKeyInfo(KeyInfo);

  // go out if no information is available
  if (KeyInfo.NumValues<=0) and (Root <> HKEY_CLASSES_ROOT) then Exit;

  // Set up access to the list.
  ValueNames := TStringList.Create;
  reg.GetValueNames(ValueNames);

  // search in HKEY_CLASSES_ROOT
  if reg.RootKey = HKEY_CLASSES_ROOT then
  begin
    Strtemp := TStringList.Create;
    reg.GetKeyNames(Strtemp);
    if NodeKey[1] = '.' then
    begin
      if ValueNames.Count-1 = -1 then
        if Strtemp.Count-1 = -1 then
          if '\'+NodeKey = Node then

          // Enter information into the list view.
          with Form1.ListView1.Items.Add do
          begin
            Caption := 'Found Key:';
            SubItems.Add(NodeKey);
            SubItems.Add('HKCR');
            SubItems.Add(Node);
            SubItems.Add(ValueNames[i]);
            Form1.Panel1.Caption := NodeKey;
            // causes the ListView to scroll to the found key
            Form1.ListView1.Items[Form1.ListView1.Items.Count-1].MakeVisible(false);
          end;
    end;
    Strtemp.Free;
    Exit;
  end;

   for i := 0 to ValueNames.Count-1 do
   begin
    if reg.GetDataType(ValueNames[i]) = rdString then
    begin
      s := reg.ReadString(ValueNames[i]);
      tmp := S;

      if (S <> '') and (S[1] <> 'A') and (S[1] <> 'a') then
       if GetHDDSerial(S[1]) <> 0 then
        if FileExists(S) = false then
          if IsPath(S,S) = true then
          begin
            V := ExtractFileExt(S);
            if V <> '' then
            begin
              if DirectoryExists(S) = False then
                if FileExists(S) = false then

            with Form1.ListView1.Items.Add do
              begin
                // search in HKEY_CURRENT_USER & HKEY_LOCAL_MACHINE
                if (reg.RootKey =HKEY_CURRENT_USER ) or (reg.RootKey = HKEY_LOCAL_MACHINE ) then
                  begin
                    Caption := 'Found Key:';
                    SubItems.Add(tmp);

                    // Determine which root key was found and enter it.
                    if Root = HKEY_CURRENT_USER then
                    begin
                      SubItems.Add('HKCU');
                    end else begin
                      if Root = HKEY_LOCAL_MACHINE then
                        SubItems.Add('HKLM');
                    end;

                    SubItems.Add(Node);
                    SubItems.Add(ValueNames[i]);

                    // causes the ListView to scroll to the found key
                    Form1.ListView1.Items[Form1.ListView1.Items.Count-1].MakeVisible(false);

                    // Display a short message in the panel.
                    if Root = HKEY_CURRENT_USER then
                    begin
                      Form1.Panel1.Caption := 'HKEY_CURRENT_USER : ' + tmp;
                    end else begin
                      if Root = HKEY_LOCAL_MACHINE then
                        Form1.Panel1.Caption := 'HKEY_LOCAL_MACHINE : ' + tmp;
                    end;

                  end;
              end;
            end;
          end;
    end;
   end;
  ValueNames.Free;
  reg.Free;
end;

{ It is used to search the Windows Registry recursively and read all
  subdirectories (keys) and their values, without requiring you to navigate
  to each path individually and manually. }
Procedure TCleanThread.RegRecurseScan(ANode: String; Key, OldKey: string; Level: Integer);
var
  AStrings: TStringList;
  I: Integer;
  AKey: string;
begin
if scanning = False then Exit;
  AKey := FixupPath(OldKey);
  if FReg.OpenKeyReadOnly(Key) and FReg.HasSubKeys then
  begin
    if Level = 1 then
    begin
      AStrings := TStringList.Create;
      try
        // Read immediate subkeys
        FReg.GetKeyNames(AStrings);
        for I := 0 to AStrings.Count - 1 do
        begin
        if scanning = False then Exit;
          if AStrings[I] = '' then
            AStrings[I] := Format('%.04d', [I]);

          // Drill down recursively into each subkey
          GetSub(ANode+'\'+AStrings[I],AStrings[I],FReg.RootKey);

          if Freg.RootKey <> HKEY_CLASSES_ROOT then
          RegRecurseScan(ANode+'\'+AStrings[I], AStrings[I], AKey + Key, Level);
        end;
      finally
        AStrings.Free;
      end;
    end;
  end;
  FReg.OpenKeyReadOnly(AKey);
end;

// Search the registry.
Procedure TCleanThread.ScanRegistry(Root: Cardinal; Metod: integer);
begin
  { You can use this procedure for the individual search.

    To scan and interact with the Windows Registry in Delphi, you will
    use the TRegistry class provided in the System.Win.Registry unit.
    By utilizing methods like

    "OpenKeyReadOnly"
    "GetKeyNames"
    "GetValueNames"

    you can recursively traverse the registry tree to find specific
    keys, subkeys, and data values. }
end;

// The search is started here.
Procedure TCleanThread.Execute;
begin
  Scanning := True;
  if InvExt = True then
  begin
    Form1.Panel1.Caption := 'key founds in HKEY_CLASSES_ROOT';
    try
      FReg := TRegistry.Create;
      FReg.RootKey := HKEY_CLASSES_ROOT;
      // search location
      RegRecurseScan('\SOFTWARE','','',1);
    finally
      FReg.Free;
    end;
  end;


  if InvFlp = True then
  begin
    Form1.Panel1.Caption := 'key founds in HKEY_CURRENT_USER';
    try
      FReg := TRegistry.Create;
      FReg.RootKey := HKEY_CURRENT_USER;
      // search location
      RegRecurseScan('\SOFTWARE','','',1);
    finally
      FReg.Free;
    end;
  end;

  if InvFlp = True then
  begin
    Form1.Panel1.Caption := 'Key founds in HKEY_LOCAL_MACHINE';
    try
      FReg := TRegistry.Create;
      FReg.RootKey := HKEY_LOCAL_MACHINE;
      // search location
      RegRecurseScan('\SOFTWARE','\SOFTWARE','',1);
    finally
      FReg.Free;
    end;
  end;

  // stop the scan
  Scanning := False;

  Form1.Panel1.Caption := 'Scanner stop.';
  Form1.Button1.Enabled := True;
  Form1.Button2.Enabled := False;
  Form1.Button3.Enabled := True;
  Form1.TabSheet1.TabVisible := True;
  Form1.TabSheet2.TabVisible := True;
  Form1.StatusBar1.Panels[6].Text := 'finish.';
  Form1.Clear1.Enabled := true;
  Form1.Checkall1.Enabled := true;
  Form1.JumptoKey1.Enabled := true;
  Form1.Remove1.Enabled := true;
  Form1.Properties1.Enabled := true;
  Form1.Browse1.Enabled := true;

  if Form1.ListView1.Items.Count > 0 then Form1.Button3.Enabled := True;

  Screen.Cursor := crDefault;
end;
end.

