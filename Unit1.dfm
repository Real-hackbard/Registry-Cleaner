object Form1: TForm1
  Left = 1658
  Top = 166
  Caption = 'Registry Cleaner'
  ClientHeight = 409
  ClientWidth = 663
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 663
    Height = 2
    Align = alTop
    ExplicitWidth = 559
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 2
    Width = 663
    Height = 337
    ActivePage = RCl
    Align = alClient
    MultiLine = True
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 659
    ExplicitHeight = 336
    object RCl: TTabSheet
      Caption = 'Registry'
      OnShow = RClShow
      object ListView1: TListView
        Left = 0
        Top = 0
        Width = 655
        Height = 309
        Align = alClient
        Checkboxes = True
        Columns = <
          item
            Caption = 'Key :'
            Width = 100
          end
          item
            Caption = 'File:'
            Width = 300
          end
          item
            Caption = 'ROOT:'
            Width = 80
          end
          item
            Caption = 'Hotkey:'
            Width = 600
          end>
        ColumnClick = False
        GridLines = True
        ReadOnly = True
        RowSelect = True
        PopupMenu = PopupMenu1
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListView1Change
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Temporary Files'
      ImageIndex = 1
      OnShow = TabSheet1Show
      object ListBox1: TListBox
        Left = 0
        Top = 0
        Width = 655
        Height = 309
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Programs'
      ImageIndex = 2
      OnShow = TabSheet2Show
      object ListBox2: TListBox
        Left = 0
        Top = 0
        Width = 655
        Height = 309
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = ListBox2Click
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 339
    Width = 663
    Height = 18
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 338
    ExplicitWidth = 659
  end
  object Panel2: TPanel
    Left = 0
    Top = 357
    Width = 663
    Height = 33
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 356
    ExplicitWidth = 659
    DesignSize = (
      663
      33)
    object Button1: TButton
      Left = 7
      Top = 6
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
      Left = 579
      Top = 6
      Width = 80
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'close'
      TabOrder = 3
      TabStop = False
      OnClick = Button4Click
      ExplicitLeft = 575
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 390
    Width = 663
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
    ExplicitTop = 389
    ExplicitWidth = 659
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.reg'
    Filter = 'Registry files|*.reg'
    Left = 52
    Top = 80
  end
  object PopupMenu1: TPopupMenu
    Left = 148
    Top = 82
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object Checkall1: TMenuItem
      Caption = 'Check all'
      OnClick = Checkall1Click
    end
  end
end
