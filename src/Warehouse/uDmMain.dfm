object DmMain: TDmMain
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 200
  Top = 150
  Height = 150
  Width = 215
  object Connection: TADOConnection
    LoginPrompt = False
    Mode = cmReadWrite
    Provider = 'SQLOLEDB.1'
    Left = 40
    Top = 24
  end
end
