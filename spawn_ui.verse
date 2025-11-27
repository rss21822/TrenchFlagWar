using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Random }

SpawnSelector := class():

    var MainCanvas : canvas = canvas{}
    var LeftBaseButton : button_regular = button_regular{}
    var LeftBaseBackground : color_block = color_block{}
    var TrenchAButton : button_regular = button_regular{}
    var TrenchBButton : button_regular = button_regular{}
    var TrenchCButton : button_regular = button_regular{}
    var TrenchXButton : button_regular = button_regular{}
    var TrenchYButton : button_regular = button_regular{}
    var TrenchZButton : button_regular = button_regular{}
    var RightBaseButton : button_regular = button_regular{}
    var RightBaseBackground : color_block = color_block{}
    var ExitButton : button_regular = button_regular{}
    var ExitButtonBackground : color_block = color_block{}

    # テレポーター配列（SpawnSelectorManagerから渡される）
    var Blue_Base_Teleporters : []teleporter_device = array{}
    var TrenchA_Teleporters : []teleporter_device = array{}
    var TrenchB_Teleporters : []teleporter_device = array{}
    var TrenchC_Teleporters : []teleporter_device = array{}
    var TrenchX_Teleporters : []teleporter_device = array{}
    var TrenchY_Teleporters : []teleporter_device = array{}
    var TrenchZ_Teleporters : []teleporter_device = array{}
    var Red_Base_Teleporters : []teleporter_device = array{}

    # 黄色背景用color_block（占領状態表示用、6つのTrench分）
    var YellowBgA : color_block = color_block{}
    var YellowBgB : color_block = color_block{}
    var YellowBgC : color_block = color_block{}
    var YellowBgX : color_block = color_block{}
    var YellowBgY : color_block = color_block{}
    var YellowBgZ : color_block = color_block{}

    # GameRuleへの参照（占領状態チェック用）
    var GameRuleRef : game_rule = game_rule{}

    # プレイヤーのチームID（UI表示カラー変更用）
    var PlayerTeamID : int = 0

    AddUI(Agent : agent, GameRule : game_rule, BlueBaseTeleporters : []teleporter_device, TrenchATeleporters : []teleporter_device, TrenchBTeleporters : []teleporter_device, TrenchCTeleporters : []teleporter_device, TrenchXTeleporters : []teleporter_device, TrenchYTeleporters : []teleporter_device, TrenchZTeleporters : []teleporter_device, RedBaseTeleporters : []teleporter_device) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            # GameRuleへの参照を保存
            set GameRuleRef = GameRule

            # テレポーター配列を設定
            set Blue_Base_Teleporters = BlueBaseTeleporters
            set TrenchA_Teleporters = TrenchATeleporters
            set TrenchB_Teleporters = TrenchBTeleporters
            set TrenchC_Teleporters = TrenchCTeleporters
            set TrenchX_Teleporters = TrenchXTeleporters
            set TrenchY_Teleporters = TrenchYTeleporters
            set TrenchZ_Teleporters = TrenchZTeleporters
            set Red_Base_Teleporters = RedBaseTeleporters

            # プレイヤーのチーム情報を取得して保存（クラス変数）
            set PlayerTeamID = GameRule.GetPlayerTeamID(Agent)

            # プレイヤーのチームが占領中のTrenchを取得
            OccupiedTrenches := GameRule.GetOccupiedTrenchesByTeam(PlayerTeamID)

            # UIを作成（占領状態を反映）
            set MainCanvas = CreateUI(OccupiedTrenches)
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})

    RemoveUI(Agent : agent) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    HandleExit(Message : widget_message) : void =
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    SelectLeftBase(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチーム情報を確認
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        if (TeamID = 1):
            # Team1のみBlue Baseにテレポート可能
            RemoveUI(Player)
            TeleportToRandomLocation(Player, Blue_Base_Teleporters)
        else:
            Print("Cannot teleport to Blue Base - Team1 only")

    SelectTrenchA(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchAを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(0)  # TrenchA = index 0
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchA_Teleporters)
        else:
            Print("Cannot teleport to Trench A - not controlled by your team")

    SelectTrenchB(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchBを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(1)  # TrenchB = index 1
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchB_Teleporters)
        else:
            Print("Cannot teleport to Trench B - not controlled by your team")

    SelectTrenchC(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchCを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(2)  # TrenchC = index 2
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchC_Teleporters)
        else:
            Print("Cannot teleport to Trench C - not controlled by your team")

    SelectTrenchX(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchXを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(3)  # TrenchX = index 3
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchX_Teleporters)
        else:
            Print("Cannot teleport to Trench X - not controlled by your team")

    SelectTrenchY(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchFを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(4)  # TrenchF = index 4
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchY_Teleporters)
        else:
            Print("Cannot teleport to Trench F - not controlled by your team")

    SelectTrenchZ(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchZを占領しているかチェック
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(5)  # TrenchZ = index 5
        if (TrenchState.ControllingTeam = TeamID):
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchZ_Teleporters)
        else:
            Print("Cannot teleport to Trench Z - not controlled by your team")

    SelectRightBase(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチーム情報を確認
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        if (TeamID = 2):
            # Team2のみRed Baseにテレポート可能
            RemoveUI(Player)
            TeleportToRandomLocation(Player, Red_Base_Teleporters)
        else:
            Print("Cannot teleport to Red Base - Team2 only")

    # テレポーター配列からランダムに1つ選択してプレイヤーをテレポート
    TeleportToRandomLocation(Player : agent, Teleporters : []teleporter_device) : void =
        if (Teleporters.Length > 0):
            # ランダムにインデックスを選択
            RandomIndex := GetRandomInt(0, Teleporters.Length - 1)
            if:
                SelectedTeleporter := Teleporters[RandomIndex]
            then:
                # テレポート実行
                SelectedTeleporter.Teleport(Player)
                Print("Player teleported to random location")
            else:
                Print("Failed to select teleporter")
        else:
            Print("No teleporters available")

    CreateUI(OccupiedTrenches : []logic) : canvas =
        # Set button text
        LeftBaseButton.SetText(StringToMessage("Base"))
        TrenchAButton.SetText(StringToMessage("A"))
        TrenchBButton.SetText(StringToMessage("B"))
        TrenchCButton.SetText(StringToMessage("C"))
        TrenchXButton.SetText(StringToMessage("X"))
        TrenchYButton.SetText(StringToMessage("Y"))
        TrenchZButton.SetText(StringToMessage("Z"))
        RightBaseButton.SetText(StringToMessage("Base"))
        ExitButton.SetText(StringToMessage("Exit"))

        # Set background colors for base buttons (チームに応じて色を変更)
        # Team1の場合: LeftBase = Blue, RightBase = Gray
        # Team2の場合: LeftBase = Gray, RightBase = Red
        LeftBaseColor := if (PlayerTeamID = 2) then NamedColors.Gray else NamedColors.Blue
        RightBaseColor := if (PlayerTeamID = 1) then NamedColors.Gray else NamedColors.Red

        set LeftBaseBackground = color_block{DefaultColor := LeftBaseColor, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set RightBaseBackground = color_block{DefaultColor := RightBaseColor, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set ExitButtonBackground = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 300.0, Y := 100.0}}

        # Set yellow backgrounds for occupied trenches（占領状態表示）
        set YellowBgA = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgB = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgC = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgX = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgY = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgZ = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}

        # Subscribe button events
        LeftBaseButton.OnClick().Subscribe(SelectLeftBase)
        TrenchAButton.OnClick().Subscribe(SelectTrenchA)
        TrenchBButton.OnClick().Subscribe(SelectTrenchB)
        TrenchCButton.OnClick().Subscribe(SelectTrenchC)
        TrenchXButton.OnClick().Subscribe(SelectTrenchX)
        TrenchYButton.OnClick().Subscribe(SelectTrenchY)
        TrenchYButton.OnClick().Subscribe(SelectTrenchZ)
        RightBaseButton.OnClick().Subscribe(SelectRightBase)
        ExitButton.OnClick().Subscribe(HandleExit)

        # ボタンの幅と高さ（縦長・2倍サイズ）
        ButtonWidth : float = 200.0
        ButtonHeight : float = 240.0
        ButtonSpacing : float = 10.0  # ボタン間の隙間（2倍）

        # 8つのボタンの総幅を計算
        TotalWidth : float = (ButtonWidth * 8.0) + (ButtonSpacing * 7.0)
        StartX : float = TotalWidth / -2.0

        # 占領状態に応じたcanvas_slotリストを動的に構築
        var CanvasSlots : []canvas_slot = BuildCanvasSlots(OccupiedTrenches, ButtonWidth, ButtonHeight, ButtonSpacing, StartX)

        NewUI : canvas = canvas{
            Slots := CanvasSlots
        }
        return NewUI

    # 占領状態に応じたcanvas_slotリストを構築
    BuildCanvasSlots(OccupiedTrenches : []logic, ButtonWidth : float, ButtonHeight : float, ButtonSpacing : float, StartX : float) : []canvas_slot =
        # 占領状態を取得（配列アクセスのエラーハンドリング）
        if:
            IsOccupiedA := OccupiedTrenches[0]
            IsOccupiedB := OccupiedTrenches[1]
            IsOccupiedC := OccupiedTrenches[2]
            IsOccupiedX := OccupiedTrenches[3]
            IsOccupiedY := OccupiedTrenches[4]
            IsOccupiedZ := OccupiedTrenches[5]
        then:
            # 占領状態に応じて黄色背景の色を設定（占領していない場合はグレー）
            YellowColorA := if (IsOccupiedA = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorB := if (IsOccupiedB = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorC := if (IsOccupiedC = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorX := if (IsOccupiedX = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorY := if (IsOccupiedY = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorZ := if (IsOccupiedZ = true) then NamedColors.Yellow else NamedColors.Gray

            # color_blockを再設定
            set YellowBgA = color_block{DefaultColor := YellowColorA, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgB = color_block{DefaultColor := YellowColorB, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgC = color_block{DefaultColor := YellowColorC, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgX = color_block{DefaultColor := YellowColorX, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgY = color_block{DefaultColor := YellowColorY, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgZ = color_block{DefaultColor := YellowColorZ, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}

            array:
                # Left Base Background（青背景）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := LeftBaseBackground

                # Left Base Button（一番左）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := LeftBaseButton

                # Trench A Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 1.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgA

                # Trench A Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 1.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchAButton

                # Trench B Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 2.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgB

                # Trench B Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 2.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchBButton

                # Trench C Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 3.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgC

                # Trench C Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 3.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchCButton

                # Trench X Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 4.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgX

                # Trench X Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 4.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchXButton

                # Trench F Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 5.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgY

                # Trench F Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 5.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchYButton

                # Trench Z Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 6.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgZ

                # Trench Z Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 6.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchZButton

                # Right Base Background（赤背景）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 7.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := RightBaseBackground

                # Right Base Button（一番右）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 7.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := RightBaseButton

                # Exit Button Background（黄色背景）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -150.0, Top:= 250.0, Right := 300.0, Bottom := 100.0}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := ExitButtonBackground

                # Exit Button（ボタン群の下、中央）
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -150.0, Top:= 250.0, Right := 300.0, Bottom := 100.0}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ExitButton
        else:
            array{}

SpawnSelectorManager := class(creative_device):
    @editable Team1_PlayerSpawner : []player_spawner_device = array{}
    @editable Team2_PlayerSpawner : []player_spawner_device = array{}
    @editable GameRule : game_rule = game_rule{}

    # テレポーター配列（UEFNエディタで設定可能）
    @editable Blue_Base_Teleporters : []teleporter_device = array{}
    @editable TrenchA_Teleporters : []teleporter_device = array{}
    @editable TrenchB_Teleporters : []teleporter_device = array{}
    @editable TrenchC_Teleporters : []teleporter_device = array{}
    @editable TrenchX_Teleporters : []teleporter_device = array{}
    @editable TrenchY_Teleporters : []teleporter_device = array{}
    @editable TrenchZ_Teleporters : []teleporter_device = array{}
    @editable Red_Base_Teleporters : []teleporter_device = array{}

    OnBegin<override>()<suspends>:void =
        Print("SpawnSelectorManager initialized and listening for spawn events")

        # Team1のすべてのPlayerSpawnerにSubscribe
        for (Spawner : Team1_PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        # Team2のすべてのPlayerSpawnerにSubscribe
        for (Spawner : Team2_PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        Print("All player spawners subscribed successfully")

    OnPlayerSpawned(Agent: agent) : void =
        Print("Player spawned, showing spawn selector UI")
        var NewSpawnSelector : SpawnSelector = SpawnSelector{}
        NewSpawnSelector.AddUI(Agent, GameRule, Blue_Base_Teleporters, TrenchA_Teleporters, TrenchB_Teleporters, TrenchC_Teleporters, TrenchX_Teleporters, TrenchY_Teleporters, TrenchZ_Teleporters, Red_Base_Teleporters)
