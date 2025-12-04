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

    # UIが表示中かどうかのフラグ（更新ループ制御用）
    var IsUIActive : logic = false

    # 現在のプレイヤー参照（更新ループ用）
    var CurrentPlayer : ?player = false

    # 更新間隔（秒）
    UpdateInterval : float = 0.3

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

            # 現在のプレイヤーを保存
            set CurrentPlayer = option{Player}

            # プレイヤーのチームが占領中のTrenchを取得
            OccupiedTrenches := GameRule.GetOccupiedTrenchesByTeam(PlayerTeamID)

            # UIを作成（占領状態を反映）
            set MainCanvas = CreateUI(OccupiedTrenches)
            PlayerUI.AddWidget(MainCanvas, player_ui_slot{InputMode := ui_input_mode.All})

            # UIアクティブフラグを設定
            set IsUIActive = true

            # リアルタイム更新ループを開始
            spawn{ UpdateLoop() }

    # リアルタイム更新ループ
    UpdateLoop()<suspends> : void =
        loop:
            # UIが非アクティブになったらループを終了
            if (IsUIActive = false):
                break

            # 占領状態を更新
            UpdateOccupationColors()

            # 更新間隔待機
            Sleep(UpdateInterval)

    # 占領状態に応じて背景色を更新
    UpdateOccupationColors() : void =
        # 最新の占領状態を取得
        OccupiedTrenches := GameRuleRef.GetOccupiedTrenchesByTeam(PlayerTeamID)

        # 各Trenchの占領状態をチェックして色を更新
        if:
            IsOccupiedA := OccupiedTrenches[0]
            IsOccupiedB := OccupiedTrenches[1]
            IsOccupiedC := OccupiedTrenches[2]
            IsOccupiedX := OccupiedTrenches[3]
            IsOccupiedY := OccupiedTrenches[4]
            IsOccupiedZ := OccupiedTrenches[5]
        then:
            # 占領状態に応じて背景色を動的に変更
            ColorA := if (IsOccupiedA = true) then NamedColors.Yellow else NamedColors.Gray
            ColorB := if (IsOccupiedB = true) then NamedColors.Yellow else NamedColors.Gray
            ColorC := if (IsOccupiedC = true) then NamedColors.Yellow else NamedColors.Gray
            ColorX := if (IsOccupiedX = true) then NamedColors.Yellow else NamedColors.Gray
            ColorY := if (IsOccupiedY = true) then NamedColors.Yellow else NamedColors.Gray
            ColorZ := if (IsOccupiedZ = true) then NamedColors.Yellow else NamedColors.Gray

            # SetColorで動的に色を更新
            YellowBgA.SetColor(ColorA)
            YellowBgB.SetColor(ColorB)
            YellowBgC.SetColor(ColorC)
            YellowBgX.SetColor(ColorX)
            YellowBgY.SetColor(ColorY)
            YellowBgZ.SetColor(ColorZ)

    RemoveUI(Agent : agent) : void =
        # 更新ループを停止
        set IsUIActive = false

        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    HandleExit(Message : widget_message) : void =
        # 更新ループを停止
        set IsUIActive = false

        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    SelectLeftBase(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチーム情報を確認
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        if (TeamID = 1):
            # Team1のみBlue Baseにテレポート可能
            set IsUIActive = false  # 更新ループを停止
            RemoveUI(Player)
            TeleportToRandomLocation(Player, Blue_Base_Teleporters)
        else:
            Print("Cannot teleport to Blue Base - Team1 only")

    SelectTrenchA(Message : widget_message) : void =
        Player := Message.Player
        # プレイヤーのチームがTrenchAを占領しているかチェック（リアルタイムで確認）
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(0)  # TrenchA = index 0
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchA_Teleporters)
        else:
            Print("Cannot teleport to Trench A - not controlled by your team")

    SelectTrenchB(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(1)  # TrenchB = index 1
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchB_Teleporters)
        else:
            Print("Cannot teleport to Trench B - not controlled by your team")

    SelectTrenchC(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(2)  # TrenchC = index 2
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchC_Teleporters)
        else:
            Print("Cannot teleport to Trench C - not controlled by your team")

    SelectTrenchX(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(3)  # TrenchX = index 3
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchX_Teleporters)
        else:
            Print("Cannot teleport to Trench X - not controlled by your team")

    SelectTrenchY(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(4)  # TrenchY = index 4
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchY_Teleporters)
        else:
            Print("Cannot teleport to Trench Y - not controlled by your team")

    SelectTrenchZ(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        TrenchState := GameRuleRef.GetTrenchState(5)  # TrenchZ = index 5
        if (TrenchState.ControllingTeam = TeamID):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, TrenchZ_Teleporters)
        else:
            Print("Cannot teleport to Trench Z - not controlled by your team")

    SelectRightBase(Message : widget_message) : void =
        Player := Message.Player
        TeamID := GameRuleRef.GetPlayerTeamID(Player)
        if (TeamID = 2):
            set IsUIActive = false
            RemoveUI(Player)
            TeleportToRandomLocation(Player, Red_Base_Teleporters)
        else:
            Print("Cannot teleport to Red Base - Team2 only")

    # テレポーター配列からランダムに1つ選択してプレイヤーをテレポート
    TeleportToRandomLocation(Player : agent, Teleporters : []teleporter_device) : void =
        if (Teleporters.Length > 0):
            RandomIndex := GetRandomInt(0, Teleporters.Length - 1)
            if:
                SelectedTeleporter := Teleporters[RandomIndex]
            then:
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

        # Set background colors for base buttons
        LeftBaseColor := if (PlayerTeamID = 2) then NamedColors.Gray else NamedColors.Blue
        RightBaseColor := if (PlayerTeamID = 1) then NamedColors.Gray else NamedColors.Red

        set LeftBaseBackground = color_block{DefaultColor := LeftBaseColor, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set RightBaseBackground = color_block{DefaultColor := RightBaseColor, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set ExitButtonBackground = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 300.0, Y := 100.0}}

        # 初期の占領状態で背景色を設定（後でUpdateOccupationColorsで動的更新される）
        set YellowBgA = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgB = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgC = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgX = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgY = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgZ = color_block{DefaultColor := NamedColors.Gray, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}

        # 初期状態で色を設定
        if:
            IsOccupiedA := OccupiedTrenches[0]
            IsOccupiedB := OccupiedTrenches[1]
            IsOccupiedC := OccupiedTrenches[2]
            IsOccupiedX := OccupiedTrenches[3]
            IsOccupiedY := OccupiedTrenches[4]
            IsOccupiedZ := OccupiedTrenches[5]
        then:
            if (IsOccupiedA = true):
                YellowBgA.SetColor(NamedColors.Yellow)
            if (IsOccupiedB = true):
                YellowBgB.SetColor(NamedColors.Yellow)
            if (IsOccupiedC = true):
                YellowBgC.SetColor(NamedColors.Yellow)
            if (IsOccupiedX = true):
                YellowBgX.SetColor(NamedColors.Yellow)
            if (IsOccupiedY = true):
                YellowBgY.SetColor(NamedColors.Yellow)
            if (IsOccupiedZ = true):
                YellowBgZ.SetColor(NamedColors.Yellow)

        # Subscribe button events
        LeftBaseButton.OnClick().Subscribe(SelectLeftBase)
        TrenchAButton.OnClick().Subscribe(SelectTrenchA)
        TrenchBButton.OnClick().Subscribe(SelectTrenchB)
        TrenchCButton.OnClick().Subscribe(SelectTrenchC)
        TrenchXButton.OnClick().Subscribe(SelectTrenchX)
        TrenchYButton.OnClick().Subscribe(SelectTrenchY)
        TrenchZButton.OnClick().Subscribe(SelectTrenchZ)
        RightBaseButton.OnClick().Subscribe(SelectRightBase)
        ExitButton.OnClick().Subscribe(HandleExit)

        # ボタンの幅と高さ
        ButtonWidth : float = 200.0
        ButtonHeight : float = 240.0
        ButtonSpacing : float = 10.0

        # 8つのボタンの総幅を計算
        TotalWidth : float = (ButtonWidth * 8.0) + (ButtonSpacing * 7.0)
        StartX : float = TotalWidth / -2.0

        # canvas_slotリストを構築
        var CanvasSlots : []canvas_slot = BuildCanvasSlots(ButtonWidth, ButtonHeight, ButtonSpacing, StartX)

        NewUI : canvas = canvas{
            Slots := CanvasSlots
        }
        return NewUI

    # canvas_slotリストを構築（占領状態パラメータ不要に変更）
    BuildCanvasSlots(ButtonWidth : float, ButtonHeight : float, ButtonSpacing : float, StartX : float) : []canvas_slot =
        array:
            # Left Base Background
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= StartX, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 0
                SizeToContent := false
                Widget := LeftBaseBackground

            # Left Base Button
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

            # Trench Y Yellow Background
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 5.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 0
                SizeToContent := false
                Widget := YellowBgY

            # Trench Y Button
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

            # Right Base Background
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 7.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 0
                SizeToContent := false
                Widget := RightBaseBackground

            # Right Base Button
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 7.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 1
                SizeToContent := false
                Widget := RightBaseButton

            # Exit Button Background
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= -150.0, Top:= 250.0, Right := 300.0, Bottom := 100.0}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 0
                SizeToContent := false
                Widget := ExitButtonBackground

            # Exit Button
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                Offsets := margin{Left:= -150.0, Top:= 250.0, Right := 300.0, Bottom := 100.0}
                Alignment := vector2{X:= 0.0, Y:= 0.0}
                ZOrder := 1
                SizeToContent := false
                Widget := ExitButton

SpawnSelectorManager := class(creative_device):
    @editable Team1_PlayerSpawner : []player_spawner_device = array{}
    @editable Team2_PlayerSpawner : []player_spawner_device = array{}
    @editable Display_Vutton : button_device = button_device{}
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

    # プレイヤーごとのSpawnSelector管理用マップ
    var PlayerSpawnSelectors : [player]SpawnSelector = map{}

    OnBegin<override>()<suspends>:void =
        Print("SpawnSelectorManager initialized and listening for spawn events")

        # Team1のすべてのPlayerSpawnerにSubscribe
        for (Spawner : Team1_PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        # Team2のすべてのPlayerSpawnerにSubscribe
        for (Spawner : Team2_PlayerSpawner):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        Display_Vutton.InteractedWithEvent.Subscribe(OnPlayerSpawned)

        Print("All player spawners subscribed successfully")

    OnPlayerSpawned(Agent: agent) : void =
        Print("Player spawned, showing spawn selector UI")

        if (Player := player[Agent]):
            # 既存のUIがあれば先に削除（重複防止）
            if (ExistingSelector := PlayerSpawnSelectors[Player]):
                ExistingSelector.RemoveUI(Agent)

            # 新しいSpawnSelectorを作成
            var NewSpawnSelector : SpawnSelector = SpawnSelector{}
            NewSpawnSelector.AddUI(Agent, GameRule, Blue_Base_Teleporters, TrenchA_Teleporters, TrenchB_Teleporters, TrenchC_Teleporters, TrenchX_Teleporters, TrenchY_Teleporters, TrenchZ_Teleporters, Red_Base_Teleporters)

            # マップに保存
            if (set PlayerSpawnSelectors[Player] = NewSpawnSelector):
                Print("SpawnSelector registered for player")