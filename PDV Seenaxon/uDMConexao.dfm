object DMConexao: TDMConexao
  OldCreateOrder = False
  Height = 150
  Width = 215
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=pdv_seenaxon.db')
    LoginPrompt = False
    Left = 48
    Top = 48
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 48
    Top = 104
  end
end
