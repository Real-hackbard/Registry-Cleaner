object Form1: TForm1
  Left = 1658
  Top = 166
  Caption = 'Registry Cleaner'
  ClientHeight = 531
  ClientWidth = 795
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 795
    Height = 2
    Align = alTop
    ExplicitWidth = 559
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 2
    Width = 795
    Height = 459
    ActivePage = RCl
    Align = alClient
    MultiLine = True
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 791
    ExplicitHeight = 458
    object RCl: TTabSheet
      Caption = 'Registry'
      OnShow = RClShow
      object ListView1: TListView
        Left = 0
        Top = 0
        Width = 787
        Height = 431
        Align = alClient
        Checkboxes = True
        Columns = <
          item
            Caption = 'Key :'
            Width = 100
          end
          item
            Caption = 'File:'
            Width = 250
          end
          item
            Caption = 'ROOT:'
            Width = 80
          end
          item
            Caption = 'Hotkey:'
            Width = 270
          end
          item
            Caption = 'File type :'
            Width = 150
          end>
        ColumnClick = False
        GridLines = True
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = PopupMenu1
        ShowHint = True
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListView1Change
        OnClick = ListView1Click
        OnDblClick = ListView1DblClick
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Temporary Files'
      ImageIndex = 1
      OnShow = TabSheet1Show
      object ListBox1: TListBox
        Left = 0
        Top = 0
        Width = 787
        Height = 431
        Align = alClient
        ItemHeight = 13
        PopupMenu = PopupMenu2
        TabOrder = 0
        OnClick = ListBox1Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Programs'
      ImageIndex = 2
      OnShow = TabSheet2Show
      object ListBox2: TListBox
        Left = 0
        Top = 0
        Width = 787
        Height = 431
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = ListBox2Click
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 461
    Width = 795
    Height = 18
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 460
    ExplicitWidth = 791
  end
  object Panel2: TPanel
    Left = 0
    Top = 479
    Width = 795
    Height = 33
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 478
    ExplicitWidth = 791
    DesignSize = (
      795
      33)
    object Button1: TButton
      Left = 7
      Top = 7
      Width = 78
      Height = 20
      Caption = 'Scan'
      TabOrder = 0
      TabStop = False
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 91
      Top = 6
      Width = 79
      Height = 20
      Caption = 'Stop'
      Enabled = False
      TabOrder = 1
      TabStop = False
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 176
      Top = 5
      Width = 78
      Height = 20
      Caption = 'Delete'
      Enabled = False
      TabOrder = 2
      TabStop = False
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 711
      Top = 6
      Width = 80
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'close'
      TabOrder = 3
      TabStop = False
      OnClick = Button4Click
      ExplicitLeft = 707
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 512
    Width = 795
    Height = 19
    Panels = <
      item
        Text = 'Reg Count :'
        Width = 70
      end
      item
        Text = '0'
        Width = 80
      end
      item
        Text = 'Temp Count :'
        Width = 90
      end
      item
        Text = '0'
        Width = 80
      end
      item
        Text = 'Uninstall Count :'
        Width = 100
      end
      item
        Text = '0'
        Width = 80
      end
      item
        Text = 'ready.'
        Width = 50
      end>
    ExplicitTop = 511
    ExplicitWidth = 791
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.reg'
    Filter = 'Registry files|*.reg'
    Left = 340
    Top = 96
  end
  object PopupMenu1: TPopupMenu
    Left = 436
    Top = 98
    object JumptoKey1: TMenuItem
      Caption = 'Jump to Key'
      OnClick = JumptoKey1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object Remove1: TMenuItem
      Caption = 'Remove'
      OnClick = Remove1Click
    end
    object Checkall1: TMenuItem
      Caption = 'Check all'
      OnClick = Checkall1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Properties1: TMenuItem
      Caption = 'Check file exists'
      OnClick = Properties1Click
    end
    object Browse1: TMenuItem
      Caption = 'Browse'
      OnClick = Browse1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Grid1: TMenuItem
      AutoCheck = True
      Caption = 'Grid'
      Checked = True
      OnClick = Grid1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 532
    Top = 98
    object Browse2: TMenuItem
      Caption = 'Browse'
      OnClick = Browse2Click
    end
  end
end
