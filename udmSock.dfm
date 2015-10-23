object dmSock: TdmSock
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object client: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 55
    Top = 22
  end
  object server: TIdTCPServer
    Bindings = <>
    DefaultPort = 3334
    MaxConnections = 1
    OnExecute = serverExecute
    Left = 24
    Top = 22
  end
  object udpS: TIdUDPServer
    Bindings = <>
    DefaultPort = 3456
    OnUDPRead = udpSUDPRead
    Left = 103
    Top = 22
  end
  object Timer1: TTimer
    Interval = 3000
    OnTimer = Timer1Timer
    Left = 144
    Top = 88
  end
end
