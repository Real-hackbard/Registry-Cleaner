unit Unit1;

interface

uses
  WinApi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.Shell.ShellCtrls,CleanReg, System.Win.Registry,
  System.Math, Vcl.StdCtrls, Vcl.ExtCtrls, WinApi.ShellApi, Vcl.Menus;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    RCl: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ListView1: TListView;
    Bevel1: TBevel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    Checkall1: TMenuItem;
    Properties1: TMenuItem;
    N1: TMenuItem;
    Browse1: TMenuItem;
    Grid1: TMenuItem;
    N2: TMenuItem;
    Remove1: TMenuItem;
    JumptoKey1: TMenuItem;
    N3: TMenuItem;
    PopupMenu2: TPopupMenu;
    Browse2: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RClShow(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
    Procedure RefreshApp;
    procedure ListBox2Click(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Clear1Click(Sender: TObject);
    procedure Checkall1Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Browse1Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JumptoKey1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Browse2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
  { Private-Deklarationen}
  procedure JumpToKey(Key: string);

  public
  { Public-Deklarationen}
    Scan : TCleanThread;
  end;
var
  Form1: TForm1;
  UninstPath: String;

implementation

{$R *.dfm}

{ This is used here to determine whether the file still exists on the system.
  If not, an error message is displayed. }
procedure PropertiesDialog(const aFilename: string);
var
  sei: ShellExecuteInfo;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.lpFile := PChar(aFilename);
  sei.lpVerb := 'properties';
  sei.fMask  := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(@sei);
end;

// Automatic jump to the registry key
procedure TForm1.JumpToKey(Key: string);
var
  i, n: Integer;
  hWin: HWND;
  ExecInfo: ShellExecuteInfoA;
begin
  hWin := FindWindowA(PAnsiChar('RegEdit_RegEdit'), nil);
  if hWin = 0 then
  { if Regedit doesn't run then we launch it }
  begin
    FillChar(ExecInfo, 60, #0);
    with ExecInfo do
    begin
      cbSize := 60;
      fMask  := SEE_MASK_NOCLOSEPROCESS;
      lpVerb := PAnsiChar('open');
      lpFile := PAnsiChar('regedit.exe');
      nShow  := 1;
    end;
    ShellExecuteExA(@ExecInfo);
    WaitForInputIdle(ExecInfo.hProcess, 200);
    hWin := FindWindowA(PAnsiChar('RegEdit_RegEdit'), nil);
  end;

  ShowWindow(hWin, SW_SHOWNORMAL);
  hWin := FindWindowExA(hWin, 0, PAnsiChar('SysTreeView32'), nil);
  SetForegroundWindow(hWin);
  i := 30;

  repeat
    SendMessageA(hWin, WM_KEYDOWN, VK_LEFT, 0);
    Dec(i);
  until i = 0;

  Sleep(100);
  SendMessageA(hWin, WM_KEYDOWN, VK_RIGHT, 0);
  Sleep(100);
  i := 1;
  n := Length(Key);

  repeat
    if Key[i] = '\' then
    begin
      SendMessageA(hWin, WM_KEYDOWN, VK_RIGHT, 0);
      Sleep(100);
    end
    else
      SendMessageA(hWin, WM_CHAR, Integer(Key[i]), 0);
    i := i + 1;
  until i = n;
end;

// generating the jump to the key
procedure TForm1.JumptoKey1Click(Sender: TObject);
var
  RegRoot : string;
  i : Integer;
begin
  i := ListView1.ItemIndex;
    if i > -1 then
    begin
      if ListView1.Items.Item[i].SubItems[1] = 'HKCU' then RegRoot := 'HKEY_CURRENT_USER';
      if ListView1.Items.Item[i].SubItems[1] = 'HKLM' then RegRoot := 'HKEY_LOCAL_MACHINE';
      if ListView1.Items.Item[i].SubItems[1] = 'HKCR' then RegRoot := 'HKEY_CLASSES_ROOT';
      JumpToKey(RegRoot + ListView1.Items[ListView1.ItemIndex].SubItems[2]);
    end;
end;

// Update the form so that it doesn't freeze during the search.
Procedure TForm1.RefreshApp;
begin
  Application.ProcessMessages;
end;

// Remove one or more registry entries.
procedure TForm1.Remove1Click(Sender: TObject);
var
  i : integer;
begin
  with ListView1 do
    for i := Items.Count - 1 downto 0 do
    begin
      if Items[i].Selected then
      begin
        ListView1.Items[i].Delete;
      end;
    end;
  // after then count the new list
  StatusBar1.Panels[1].Text := IntToStr(ListView1.Items.Count);
end;

{ Open the folder containing the file, even if the file does not exist
  on the system. }
procedure TForm1.Browse1Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListView1.ItemIndex;
    if i > -1 then
    begin
      ShellExecute(handle,'explore',
               PChar(ExtractFileDir(ListView1.Items[ListView1.ItemIndex].SubItems[0])),
               nil,nil,SW_SHOWNORMAL);
    end;
end;

{ Open the folder containing the file, even if the file does not exist
  on the system. }
procedure TForm1.Browse2Click(Sender: TObject);
begin
  if ListBox1.Items.Count < 0 then Exit;
  ShellExecute(handle,'explore',
               PChar(ExtractFileDir(ListBox1.Items.Strings[ListBox1.ItemIndex])),
               nil,nil,SW_SHOWNORMAL);
end;

// Start the registry search.
procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Tag = 0 then
  begin
    ListView1.Clear;
    Scan := TCleanThread.Create(True);
    Scan.InvExt := True;
    Scan.InvFlp := True;
    Scan.FreeOnTerminate := True;
    Scan.Resume;

    JumptoKey1.Enabled := false;
    Remove1.Enabled := false;
    Properties1.Enabled := false;
    Browse1.Enabled := false;
    TabSheet1.TabVisible := False;
    TabSheet2.TabVisible := False;
    Button1.Enabled := False;
    Button3.Enabled := False;
    Button2.Enabled := True;
    Button4.Enabled := False;
    Clear1.Enabled := false;
    Checkall1.Enabled := false;
    StatusBar1.Panels[6].Text := 'searching, please wait..';
    Screen.Cursor := crHourGlass;
  end;

  if Button1.Tag = 1 then
  begin
    RCl.TabVisible := False;
    TabSheet2.TabVisible := False;
    ListBox1.Clear;
    CleanWindows;
    Button1.Enabled := False;
  end;

  if Button1.Tag = 2 then ScanUNINST;
end;

// deleting the registry entries
procedure TForm1.Button3Click(Sender: TObject);
var
  i, P : integer;
  Root : Cardinal;
  SavRC : Boolean;
  s : string;
begin
  if Button1.Tag = 0 then
  begin
    // query
    P := MessageDlg('Delete Reg keys?', mtInformation,mbOKCancel,0);

    if P = 1 then
    begin
      SavRC := True;
      SaveDialog1.Execute;
    end else
      SavRC := False;
      InitLog;

    For i := 0 to ListView1.Items.Count-1 do
    begin
      // Select clicked entries
      if ListView1.Items.Item[i].Checked = true then
      begin
        { Here, the "Root" sub-item is checked to determine which
          hotkey contains the key, in order to locate and delete it
          within the correct registry path. }
        if ListView1.Items.Item[i].SubItems[1] = 'HKCU' then Root := HKEY_CURRENT_USER;
        if ListView1.Items.Item[i].SubItems[1] = 'HKLM' then Root := HKEY_LOCAL_MACHINE;
        if ListView1.Items.Item[i].SubItems[1] = 'HKCR' then Root := HKEY_CLASSES_ROOT;

        Sleep(50); // It's not strictly necessary, but it's better.

        // delete in HKEY_LOCAL_MACHINE
        if Root = HKEY_LOCAL_MACHINE then
        begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],'','',True,SavRC) then
            ListView1.Items.Item[i].Caption := 'removed';
        end
        else begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],ListView1.Items.Item[i].SubItems[3],ListView1.Items.Item[i].SubItems[2],False,SavRC) then
            ListView1.Items.Item[i].Caption := 'not removed';
        end;

        { is deactivated and should be handled with caution.

        // delete in HKEY_CURRENT_USER
        if Root = HKEY_CURRENT_USER then
        begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],'','',True,SavRC) then
            ListView1.Items.Item[i].Caption := 'removed';
        end
        else begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],ListView1.Items.Item[i].SubItems[3],ListView1.Items.Item[i].SubItems[2],False,SavRC) then
            ListView1.Items.Item[i].Caption := 'not removed';
        end;

        // delete in HKEY_CLASSES_ROOT
        if Root = HKEY_CLASSES_ROOT then
        begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],'','',True,SavRC) then
            ListView1.Items.Item[i].Caption := 'removed';
        end
        else begin
          if clearkey(Root,ListView1.Items.Item[i].SubItems[2],ListView1.Items.Item[i].SubItems[3],ListView1.Items.Item[i].SubItems[2],False,SavRC) then
            ListView1.Items.Item[i].Caption := 'not removed';
        end;
        }

      Application.ProcessMessages;
    end;

    end;
      ListView1.Clear;
      // save *.reg backup
      CleanReg.FreeLog(SavRC,SaveDialog1.FileName);
      Button3.Enabled := False;
  end;

  // deleting temporary files
  if Button1.Tag = 1 then
  begin
    if ListBox1.Count > 0 then if ListBox1.Count > 3 then
    begin
      For i := 0 to ListBox1.Count - 3 do
      begin
        try
          DeleteFile(PChar(ListBox1.Items.Strings[i]));
        except
        end;
      end;
    end;

    ListBox1.Clear;
    Button3.Enabled := False;
    Button1.Enabled := True;
  end;

  // Uninstallation of the program and removal of the registry entries
  if Button1.Tag = 2 then
  begin
    s:=Check;
    if ListBox2.Count>0 then

    if messagebox(Form1.Handle,'Delete Key?','Confirm', 4)=IDYes then
    begin
      reg:=TRegistry.Create;
        try
          reg.RootKey:=HKEY_LOCAL_MACHINE;
          if reg.DeleteKey(s) then
                       showmessage('Key deleted')
                       else
                       showmessage('failed');
          reg.Free;
          ScanUNINST;
          ListBox2Click(Sender);
        except
        end;
      end;
    end;
end;

// stop the registry scan
procedure TForm1.Button2Click(Sender: TObject);
begin
  if Button1.Tag = 0 then
  begin
    try
      Scan.scanning := False;
      Scan.Terminate;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;

  // Execution of the uninstallation program
  if Button1.Tag = 2 then
  begin
    ShellExecute(Handle, 'open', PChar(Panel1.Caption), nil, nil, SW_SHOWNORMAL) ;
  end;

  Button4.Enabled := true;
  Screen.Cursor := crDefault;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Close;
end;

// Select or deselect all checkboxes
procedure TForm1.Checkall1Click(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to ListView1.Items.Count-1 do
  begin
    if listview1.Items.Item[i].Checked = false then
    begin
      ListView1.Items.Item[i].Checked := true;
      Checkall1.Caption := 'Uncheck all';
    end else begin
      ListView1.Items.Item[i].Checked := false;
      Checkall1.Caption := 'Check all';
    end;
  end;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  ListView1.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // prevent the ListView from flickering
  DoubleBuffered := true;
  // set privilegs for reading keys
  SetPrivilege('SeDebugPrivilege', True)
end;

procedure TForm1.Grid1Click(Sender: TObject);
begin
  ListView1.GridLines := Grid1.Checked;
end;

procedure TForm1.RClShow(Sender: TObject);
begin
  Button3.Caption := 'Clear';
  Button2.Caption := 'Stop';
  Button1.Caption := 'Scan';
  Button1.Enabled := True;
  Button2.Enabled := False;
  Button3.Enabled := False;
  Button2.Visible := True;
  Button1.Tag := 0;
  Panel1.Caption := '';
end;

procedure TForm1.TabSheet1Show(Sender: TObject);
begin
  Button3.Caption := 'Clear';
  Button1.Caption := 'Temp';
  Button1.Enabled := True;
  Button3.Enabled := False;
  Button2.Visible := False;
  Button1.Tag := 1;
  Panel1.Caption := '';
end;

procedure TForm1.TabSheet2Show(Sender: TObject);
begin
  Button3.Caption := 'Delete';
  Button2.Caption := 'Uninstall';
  Button1.Caption := 'Scan';
  Button2.Visible := True;
  Button1.Enabled := True;
  Button2.Enabled := True;
  Button3.Enabled := True;
  Button1.Tag := 2;
  Panel1.Caption := '';
  ScanUNINST;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  Panel1.Caption := ListBox1.Items.Strings[ListBox1.ItemIndex];
end;

// Determine the registry entries for the uninstallation program.
procedure TForm1.ListBox2Click(Sender: TObject);
var
  s:string;
begin
  s:=Check;
  reg:=TRegistry.Create;
  try
    reg.RootKey:=HKEY_LOCAL_MACHINE;

    if not reg.OpenKey(s,false) then
    begin
      Showmessage('Open Key fail');
      Exit;
    end else
      if not reg.ValueExists('UninstallString') then
      begin
            Showmessage('UninstallString ');
            Exit;
      end else

    // read reg uninstall entrie
    UninstPath := reg.ReadString('UninstallString');
    UninstPath := Copy(UninstPath, 2 ,length(UninstPath));
    UninstPath := Copy(UninstPath, 1 ,length(UninstPath)-1);
    // output
    Panel1.Caption := UninstPath;
  finally
    reg.Free;
  end;
end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  // count the listview entries
  StatusBar1.Panels[1].Text :=  IntToStr(ListView1.Items.Count);
end;

// Output the full registry path when clicking the ListView.
procedure TForm1.ListView1Click(Sender: TObject);
var
  RegRoot : string;
  i : Integer;
begin
  i := ListView1.ItemIndex;
    if i > -1 then
    begin
      // Here, the system checks which hotkey has been entered.
      if ListView1.Items.Item[i].SubItems[1] = 'HKCU' then
        Panel1.Caption := 'HKEY_CURRENT_USER'+
                           ListView1.Items[ListView1.ItemIndex].SubItems[2];
      if ListView1.Items.Item[i].SubItems[1] = 'HKLM' then
        Panel1.Caption := 'HKEY_LOCAL_MACHINE'+
                           ListView1.Items[ListView1.ItemIndex].SubItems[2];
      if ListView1.Items.Item[i].SubItems[1] = 'HKCR' then
        Panel1.Caption := 'HKEY_CLASSES_ROOT'+
                           ListView1.Items[ListView1.ItemIndex].SubItems[2];
    end;
end;

// After the search, you can automatically jump to the registry key by double-clicking.
procedure TForm1.ListView1DblClick(Sender: TObject);
var
  RegRoot : string;
  i : Integer;
begin
  i := ListView1.ItemIndex;
    if i > -1 then
    begin
      if ListView1.Items.Item[i].SubItems[1] = 'HKCU' then RegRoot := 'HKEY_CURRENT_USER';
      if ListView1.Items.Item[i].SubItems[1] = 'HKLM' then RegRoot := 'HKEY_LOCAL_MACHINE';
      if ListView1.Items.Item[i].SubItems[1] = 'HKCR' then RegRoot := 'HKEY_CLASSES_ROOT';
      JumpToKey(RegRoot + ListView1.Items[ListView1.ItemIndex].SubItems[2]);
    end;
end;

// Check if the file associated with the key still exists before deleting it.
procedure TForm1.Properties1Click(Sender: TObject);
var
  i : Integer;
begin
  i := ListView1.ItemIndex;
    if i > -1 then
    begin
      PropertiesDialog(ListView1.Items[ListView1.ItemIndex].SubItems[0]);
    end;
end;

end.

