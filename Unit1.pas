unit Unit1;

interface

uses
  Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Shell.ShellCtrls,
  XPMan, CleanReg, Registry, Math, Vcl.StdCtrls, Vcl.ExtCtrls, ShellApi,
  Vcl.Menus;

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
  private
  public
  Scan : TCleanThread;
  end;
var
  Form1: TForm1;
  UninstPath: String;

implementation

{$R *.dfm}

Procedure TForm1.RefreshApp;
begin
  Application.ProcessMessages;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Tag = 0 then begin
    ListView1.Clear;
    Scan := TCleanThread.Create(True);
    Scan.InvExt := True;
    Scan.InvFlp := True;
    Scan.FreeOnTerminate := True;
    Scan.Resume;
    TabSheet1.TabVisible := False;
    TabSheet2.TabVisible := False;
    Button1.Enabled := False;
    Button3.Enabled := False;
    Button2.Enabled := True;
    Button4.Enabled := False;
    Clear1.Enabled := false;
    Checkall1.Enabled := false;
    StatusBar1.Panels[6].Text := 'searching, please wait..';
  end;

  if Button1.Tag = 1 then begin
    RCl.TabVisible := False;
    TabSheet2.TabVisible := False;
    ListBox1.Clear;
    CleanWindows;
    Button1.Enabled := False;
  end;

  if Button1.Tag = 2 then ScanUNINST;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i, P : integer;
  Root : Cardinal;
  SavRC : Boolean;
  s : string;
begin
  if Button1.Tag = 0 then begin
  P := MessageDlg('Delete Reg keys?', mtInformation,mbOKCancel,0);

  if P = 1 then begin
    SavRC := True;
    SaveDialog1.Execute;
  end else
    SavRC := False;
    InitLog;

  For i := 0 to ListView1.Items.Count-1 do begin
    if ListView1.Items.Item[i].Checked = true then begin
    if ListView1.Items.Item[i].SubItems[1] = 'HKCU' then Root := HKEY_CURRENT_USER;
    if ListView1.Items.Item[i].SubItems[1] = 'HKLM' then Root := HKEY_LOCAL_MACHINE;
    if ListView1.Items.Item[i].SubItems[1] = 'HKCR' then Root := HKEY_CLASSES_ROOT;

    Application.ProcessMessages;
    Sleep(100);

    if Root = HKEY_CLASSES_ROOT then begin
    if clearkey(Root,ListView1.Items.Item[i].SubItems[2],'','',True,SavRC) then

      ListView1.Items.Item[i].Caption := 'HKEY_CLASSES_ROOT';
    end
    else begin
    if clearkey(Root,ListView1.Items.Item[i].SubItems[2],ListView1.Items.Item[i].SubItems[3],ListView1.Items.Item[i].SubItems[2],False,SavRC) then
      ListView1.Items.Item[i].Caption := 'HKEY_CLASSES_ROOT';
    end;
  end;
  end;
    ListView1.Clear;
    CleanReg.FreeLog(SavRC,SaveDialog1.FileName);
    Button3.Enabled := False;
  End;
  if Button1.Tag = 1 then begin
  If ListBox1.Count > 0 then if ListBox1.Count > 3 then begin

  For i := 0 to ListBox1.Count - 3 do begin
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

  if Button1.Tag = 2 then begin
  s:=Check;
  if ListBox2.Count>0 then
  if messagebox(Form1.Handle,'Delete Key?','Confirm', 4)=IDYes then
  begin
    reg:=TRegistry.Create;
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    if reg.DeleteKey(s) then
                 showmessage('Key deleted')
                 else
                 showmessage('failed');
    reg.Free;
    ScanUNINST;
    ListBox2Click(Sender);
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Button1.Tag = 0 then begin
    try
      Scan.scanning := False;
      Scan.Terminate;
    except
    end;
  end;

  if Button1.Tag = 2 then begin
    ShellExecute(Handle, 'open', PChar(Panel1.Caption), nil, nil, SW_SHOWNORMAL) ;
  end;
  Button4.Enabled := true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Checkall1Click(Sender: TObject);
var i : integer;
begin
  for i := 0 to ListView1.Items.Count-1 do begin
    if listview1.Items.Item[i].Checked = false then begin
    listview1.Items.Item[i].Checked := true;
    Checkall1.Caption := 'Uncheck all';
    end else begin
    listview1.Items.Item[i].Checked := false;
    Checkall1.Caption := 'Check all';
    end;
 end;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  ListView1.Clear;
end;

procedure TForm1.RClShow(Sender: TObject);
begin
  ListView1.Items.Clear;
  Button3.Caption := 'clear';
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
  ListBox1.Clear;
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

procedure TForm1.ListBox2Click(Sender: TObject);
var s:string;
begin
  s:=Check;
  reg:=TRegistry.Create;
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
  UninstPath := reg.ReadString('UninstallString');
  UninstPath := Copy(UninstPath, 2 ,length(UninstPath));
  UninstPath := Copy(UninstPath, 1 ,length(UninstPath)-1);

  Panel1.Caption := UninstPath;
  reg.Free;
end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  StatusBar1.Panels[1].Text :=  IntToStr(ListView1.Items.Count);
  ListView1.Items[ListView1.Items.Count-1].MakeVisible(false);
end;

end.

