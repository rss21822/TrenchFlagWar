
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 陣地の占領状態を管理する構造体
trench_state := class:
    var Team1PlayerCount : int = 0
    var Team2PlayerCount : int = 0
    var ControllingTeam : int = 0  # 0=中立, 1=Team1, 2=Team2

# A Verse-authored creative device that can be placed in a level
game_rule := class(creative_device):

    @editable
    TrenchA_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchB_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchC_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchD_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchE_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchF_Zone : mutator_zone_device = mutator_zone_device{}

    @editable
    TrenchA_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchB_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchC_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchD_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchE_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchF_Capture_Area : capture_area_device = capture_area_device{}

    @editable
    TrenchStatesUI : trench_states_ui_manager = trench_states_ui_manager{}

    # 各陣地の状態管理
    var TrenchA_State : trench_state = trench_state{}
    var TrenchB_State : trench_state = trench_state{}
    var TrenchC_State : trench_state = trench_state{}
    var TrenchD_State : trench_state = trench_state{}
    var TrenchE_State : trench_state = trench_state{}
    var TrenchF_State : trench_state = trench_state{}

    # 現在のスコア（0未満にならないように管理）
    var Team1Score : int = 0
    var Team2Score : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Print("TrenchFlagWar Game Started!")

        # UIの初期化
        AllPlayers := GetPlayspace().GetPlayers()
        TrenchStatesUI.InitializeUI(AllPlayers)


        # 全プレイヤーにスポーン選択UIを表示
        for (Player : AllPlayers):
            if (Agent := player[Player]):
                PlayerTeamID := GetPlayerTeam(Agent)
                TrenchStates := GetAllTrenchStates()

        # 定期チェックループを開始（0.5秒ごと）
        loop:
            CheckAllTrenches()
            # UI更新
            UpdateUI()
            Sleep(0.5)

    # 全陣地をチェック
    CheckAllTrenches():void=
        CheckTrenchOccupation(TrenchA_Zone, TrenchA_Capture_Area, TrenchA_State, "TrenchA")
        CheckTrenchOccupation(TrenchB_Zone, TrenchB_Capture_Area, TrenchB_State, "TrenchB")
        CheckTrenchOccupation(TrenchC_Zone, TrenchC_Capture_Area, TrenchC_State, "TrenchC")
        CheckTrenchOccupation(TrenchD_Zone, TrenchD_Capture_Area, TrenchD_State, "TrenchD")
        CheckTrenchOccupation(TrenchE_Zone, TrenchE_Capture_Area, TrenchE_State, "TrenchE")
        CheckTrenchOccupation(TrenchF_Zone, TrenchF_Capture_Area, TrenchF_State, "TrenchF")

    # 陣地の占領状態をIsInVolumeでチェック
    CheckTrenchOccupation(Zone : mutator_zone_device, CaptureArea : capture_area_device, State : trench_state, TrenchName : string):void=
        var Team1Count : int = 0
        var Team2Count : int = 0

        # 全プレイヤーを取得
        AllPlayers := GetPlayspace().GetPlayers()

        # 各プレイヤーがこの陣地にいるかチェック
        for (Player : AllPlayers):
            if (Zone.IsInVolume[Player]):
                TeamID := GetPlayerTeam(Player)
                if (TeamID = 1):
                    set Team1Count += 1
                else if (TeamID = 2):
                    set Team2Count += 1

        # カウントが変わった場合のみ更新
        if (Team1Count <> State.Team1PlayerCount or Team2Count <> State.Team2PlayerCount):
            set State.Team1PlayerCount = Team1Count
            set State.Team2PlayerCount = Team2Count

            Print("{TrenchName}: Team1={Team1Count}, Team2={Team2Count}")

            # 占領状態を判定
            CheckOccupation(State, CaptureArea, TrenchName)

    # プレイヤーのチームを取得（1=Team1, 2=Team2, 0=不明）
    GetPlayerTeam(Agent : agent) : int =
        if:
            TeamCollection := GetPlayspace().GetTeamCollection()
            PlayerTeam := TeamCollection.GetTeam[Agent]
            Teams := TeamCollection.GetTeams()
        then:
            # Team1 (Index 0) を1として、Team2 (Index 1) を2として返す
            if (PlayerTeam = Teams[0]) then 1
            else if (PlayerTeam = Teams[1]) then 2
            else 0
        else:
            0

    # 指定されたチームの最初のプレイヤーを取得
    GetFirstPlayerOfTeam(TeamID : int) : ?agent =
        AllPlayers := GetPlayspace().GetPlayers()

        for (Player : AllPlayers):
            PlayerTeamID := GetPlayerTeam(Player)
            if (PlayerTeamID = TeamID):
                return option{Player}

        # チームのプレイヤーが見つからない場合はfalseを返す
        return false

    # 占領判定とスコア更新
    CheckOccupation(State : trench_state, CaptureArea : capture_area_device, TrenchName : string) : void =
        PreviousController := State.ControllingTeam
        var NewController : int = 0

        # 占領判定
        if (State.Team1PlayerCount > 0 and State.Team2PlayerCount = 0):
            set NewController = 1
            # チーム1の最初のプレイヤーを取得してキャプチャーエリアに占領権を渡す
            GiveControlToTeam(CaptureArea, 1)
        else if (State.Team2PlayerCount > 0 and State.Team1PlayerCount = 0):
            set NewController = 2
            # チーム2の最初のプレイヤーを取得してキャプチャーエリアに占領権を渡す
            GiveControlToTeam(CaptureArea, 2)
        else:
            set NewController = 0
            CaptureArea.Neutralize()

        # 占領状態が変わった場合のみスコア更新
        if (NewController <> PreviousController):
            set State.ControllingTeam = NewController

        # 中立化の場合
        if (NewController = 0 and PreviousController > 0):
            Print("{TrenchName} is now neutral")

    # チームにキャプチャーエリアの占領権を渡す
    GiveControlToTeam(CaptureArea : capture_area_device, TeamID : int) : void =
        MaybePlayer := GetFirstPlayerOfTeam(TeamID)
        if (Player := MaybePlayer?):
            CaptureArea.GiveControl(Player)

    # UIを更新
    UpdateUI() : void =
        AllPlayers := GetPlayspace().GetPlayers()
        TrenchStatesUI.UpdateTrenchStates(AllPlayers, TrenchA_State, TrenchB_State, TrenchC_State, TrenchD_State, TrenchE_State, TrenchF_State)

    # 陣地状態を取得（spawn_ui用）
    GetTrenchState<public>(TrenchIndex : int) : trench_state =
        if (TrenchIndex = 0) then TrenchA_State
        else if (TrenchIndex = 1) then TrenchB_State
        else if (TrenchIndex = 2) then TrenchC_State
        else if (TrenchIndex = 3) then TrenchD_State
        else if (TrenchIndex = 4) then TrenchE_State
        else TrenchF_State

    # 全陣地状態を配列で取得（spawn_ui用）
    GetAllTrenchStates() : []trench_state =
        array{TrenchA_State, TrenchB_State, TrenchC_State, TrenchD_State, TrenchE_State, TrenchF_State}

    # プレイヤーのチームIDを取得（spawn_ui用）
    GetPlayerTeamID<public>(Agent : agent) : int =
        GetPlayerTeam(Agent)