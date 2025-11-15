
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 陣地の占領状態を管琁E��る構造佁E
trench_state := class:
    var Team1PlayerCount : int = 0
    var Team2PlayerCount : int = 0
    var ControllingTeam : int = 0  # 0=中竁E 1=Team1, 2=Team2

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

    # 吁E��地の状態管琁E
    var TrenchA_State : trench_state = trench_state{}
    var TrenchB_State : trench_state = trench_state{}
    var TrenchC_State : trench_state = trench_state{}
    var TrenchD_State : trench_state = trench_state{}
    var TrenchE_State : trench_state = trench_state{}
    var TrenchF_State : trench_state = trench_state{}

    # 現在のスコア�E�E未満にならなぁE��ぁE��管琁E��E
    var Team1Score : int = 0
    var Team2Score : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Print("TrenchFlagWar Game Started!")

        # UIの初期匁E
        AllPlayers := GetPlayspace().GetPlayers()
        TrenchStatesUI.InitializeUI(AllPlayers)


        # 全プレイヤーにスポ�Eン選択UIを表示
        for (Player : AllPlayers):
            if (Agent := player[Player]):
                PlayerTeamID := GetPlayerTeam(Agent)
                TrenchStates := GetAllTrenchStates()

        # 定期チェチE��ループを開始！E.5秒ごと�E�E
        loop:
            CheckAllTrenches()
            # UI更新
            UpdateUI()
            Sleep(0.5)

    # 全陣地をチェチE��
    CheckAllTrenches():void=
        CheckTrenchOccupation(TrenchA_Zone, TrenchA_Capture_Area, TrenchA_State, "TrenchA")
        CheckTrenchOccupation(TrenchB_Zone, TrenchB_Capture_Area, TrenchB_State, "TrenchB")
        CheckTrenchOccupation(TrenchC_Zone, TrenchC_Capture_Area, TrenchC_State, "TrenchC")
        CheckTrenchOccupation(TrenchD_Zone, TrenchD_Capture_Area, TrenchD_State, "TrenchD")
        CheckTrenchOccupation(TrenchE_Zone, TrenchE_Capture_Area, TrenchE_State, "TrenchE")
        CheckTrenchOccupation(TrenchF_Zone, TrenchF_Capture_Area, TrenchF_State, "TrenchF")

    # 陣地の占領状態をIsInVolumeでチェチE��
    CheckTrenchOccupation(Zone : mutator_zone_device, CaptureArea : capture_area_device, State : trench_state, TrenchName : string):void=
        var Team1Count : int = 0
        var Team2Count : int = 0

        # 全プレイヤーを取征E
        AllPlayers := GetPlayspace().GetPlayers()

        # 吁E�Eレイヤーがこの陣地にぁE��かチェチE��
        for (Player : AllPlayers):
            if (Zone.IsInVolume[Player]):
                TeamID := GetPlayerTeam(Player)
                if (TeamID = 1):
                    set Team1Count += 1
                else if (TeamID = 2):
                    set Team2Count += 1

        # カウントが変わった場合�Eみ更新
        if (Team1Count <> State.Team1PlayerCount or Team2Count <> State.Team2PlayerCount):
            set State.Team1PlayerCount = Team1Count
            set State.Team2PlayerCount = Team2Count

            Print("{TrenchName}: Team1={Team1Count}, Team2={Team2Count}")

            # 占領状態を判宁E
            CheckOccupation(State, CaptureArea, TrenchName)

    # プレイヤーのチ�Eムを取得！E=Team1, 2=Team2, 0=不�E�E�E
    GetPlayerTeam(Agent : agent) : int =
        if:
            TeamCollection := GetPlayspace().GetTeamCollection()
            PlayerTeam := TeamCollection.GetTeam[Agent]
            Teams := TeamCollection.GetTeams()
        then:
            # Team1 (Index 0) めEとして、Team2 (Index 1) めEとして返す
            if (PlayerTeam = Teams[0]) then 1
            else if (PlayerTeam = Teams[1]) then 2
            else 0
        else:
            0

    # 持E��されたチ�Eムの最初�Eプレイヤーを取征E
    GetFirstPlayerOfTeam(TeamID : int) : ?agent =
        AllPlayers := GetPlayspace().GetPlayers()

        for (Player : AllPlayers):
            PlayerTeamID := GetPlayerTeam(Player)
            if (PlayerTeamID = TeamID):
                return option{Player}

        # チ�Eムのプレイヤーが見つからなぁE��合�Efalseを返す
        return false

    # チ�Eムが指定された陣地を占領可能かチェチE��
    CanOccupyTrench(TrenchName : string, TeamID : int) : logic =
        if (TeamID = 1):
            # Team 1: A→B→C→D→E→F の頁E��E
            if (TrenchName = "TrenchA"):
                true
            else if (TrenchName = "TrenchB"):
                if (TrenchA_State.ControllingTeam = 1) then true else false
            else if (TrenchName = "TrenchC"):
                if (TrenchA_State.ControllingTeam = 1 and TrenchB_State.ControllingTeam = 1) then true else false
            else if (TrenchName = "TrenchD"):
                if (TrenchA_State.ControllingTeam = 1 and TrenchB_State.ControllingTeam = 1 and TrenchC_State.ControllingTeam = 1) then true else false
            else if (TrenchName = "TrenchE"):
                if (TrenchA_State.ControllingTeam = 1 and TrenchB_State.ControllingTeam = 1 and TrenchC_State.ControllingTeam = 1 and TrenchD_State.ControllingTeam = 1) then true else false
            else if (TrenchName = "TrenchF"):
                if (TrenchA_State.ControllingTeam = 1 and TrenchB_State.ControllingTeam = 1 and TrenchC_State.ControllingTeam = 1 and TrenchD_State.ControllingTeam = 1 and TrenchE_State.ControllingTeam = 1) then true else false
            else:
                false
        else if (TeamID = 2):
            # Team 2: F→E→D→C→B→A の頁E��E
            if (TrenchName = "TrenchF"):
                true
            else if (TrenchName = "TrenchE"):
                if (TrenchF_State.ControllingTeam = 2) then true else false
            else if (TrenchName = "TrenchD"):
                if (TrenchF_State.ControllingTeam = 2 and TrenchE_State.ControllingTeam = 2) then true else false
            else if (TrenchName = "TrenchC"):
                if (TrenchF_State.ControllingTeam = 2 and TrenchE_State.ControllingTeam = 2 and TrenchD_State.ControllingTeam = 2) then true else false
            else if (TrenchName = "TrenchB"):
                if (TrenchF_State.ControllingTeam = 2 and TrenchE_State.ControllingTeam = 2 and TrenchD_State.ControllingTeam = 2 and TrenchC_State.ControllingTeam = 2) then true else false
            else if (TrenchName = "TrenchA"):
                if (TrenchF_State.ControllingTeam = 2 and TrenchE_State.ControllingTeam = 2 and TrenchD_State.ControllingTeam = 2 and TrenchC_State.ControllingTeam = 2 and TrenchB_State.ControllingTeam = 2) then true else false
            else:
                false
        else:
            false

    # 占領判定とスコア更新
    CheckOccupation(State : trench_state, CaptureArea : capture_area_device, TrenchName : string) : void =
        PreviousController := State.ControllingTeam
        var NewController : int = PreviousController  # チE��ォルトで現在の占領状態を保持

        # 占領判定（前提条件チェチE��付き�E�E
        if (State.Team1PlayerCount > 0 and State.Team2PlayerCount = 0):
            # Team1のみがいる場吁E
            CanTeam1Occupy := CanOccupyTrench(TrenchName, 1)
            if (CanTeam1Occupy = true):
                # Team1が占領可能
                if (PreviousController <> 1):
                    # 新規占領また�E奪叁E
                    set NewController = 1
                    GiveControlToTeam(CaptureArea, 1)
                    Print("{TrenchName}: Team1 occupied")
                # else: すでにTeam1が占領中なので状態維持E
            else:
                # Team1は占領できなぁE��、すでにTeam1が占領してぁE��場合�E保持
                set NewController = if (PreviousController = 1) then 1 else PreviousController
                Print("{TrenchName}: Team1 cannot occupy - prerequisites not met")
        else if (State.Team2PlayerCount > 0 and State.Team1PlayerCount = 0):
            # Team2のみがいる場吁E
            CanTeam2Occupy := CanOccupyTrench(TrenchName, 2)
            if (CanTeam2Occupy = true):
                # Team2が占領可能
                if (PreviousController <> 2):
                    # 新規占領また�E奪叁E
                    set NewController = 2
                    GiveControlToTeam(CaptureArea, 2)
                    Print("{TrenchName}: Team2 occupied")
                # else: すでにTeam2が占領中なので状態維持E
            else:
                # Team2は占領できなぁE��、すでにTeam2が占領してぁE��場合�E保持
                set NewController = if (PreviousController = 2) then 2 else PreviousController
                Print("{TrenchName}: Team2 cannot occupy - prerequisites not met")
        # else: 両チ�Eムがいるか誰もいなぁE��合�E現在の占領状態を保持�E�EewController = PreviousController�E�E

        # 占領状態が変わった場合�Eみ更新
        if (NewController <> PreviousController):
            set State.ControllingTeam = NewController
            # キャプチャーエリアのビジュアルを更新
            if (NewController = 1):
                GiveControlToTeam(CaptureArea, 1)
            else if (NewController = 2):
                GiveControlToTeam(CaptureArea, 2)
            else:
                CaptureArea.Neutralize()

    # チ�Eムにキャプチャーエリアの占領権を渡ぁE
    GiveControlToTeam(CaptureArea : capture_area_device, TeamID : int) : void =
        MaybePlayer := GetFirstPlayerOfTeam(TeamID)
        if (Player := MaybePlayer?):
            CaptureArea.GiveControl(Player)

    # UIを更新
    UpdateUI() : void =
        AllPlayers := GetPlayspace().GetPlayers()
        TrenchStatesUI.UpdateTrenchStates(AllPlayers, TrenchA_State, TrenchB_State, TrenchC_State, TrenchD_State, TrenchE_State, TrenchF_State)

    # 陣地状態を取得！Epawn_ui用�E�E
    GetTrenchState<public>(TrenchIndex : int) : trench_state =
        if (TrenchIndex = 0) then TrenchA_State
        else if (TrenchIndex = 1) then TrenchB_State
        else if (TrenchIndex = 2) then TrenchC_State
        else if (TrenchIndex = 3) then TrenchD_State
        else if (TrenchIndex = 4) then TrenchE_State
        else TrenchF_State

    # 全陣地状態を配�Eで取得！Epawn_ui用�E�E
    GetAllTrenchStates() : []trench_state =
        array{TrenchA_State, TrenchB_State, TrenchC_State, TrenchD_State, TrenchE_State, TrenchF_State}

    # プレイヤーのチ�EムIDを取得！Epawn_ui用�E�E
    GetPlayerTeamID<public>(Agent : agent) : int =
        GetPlayerTeam(Agent)

    # プレイヤーのチームが占領中のTrenchをbool配列で取得（spawn_ui用）
    # 戻り値: [TrenchA, TrenchB, TrenchC, TrenchD, TrenchE, TrenchF]の占領状態（true=占領中）
    GetOccupiedTrenchesByTeam<public>(TeamID : int) : []logic =
        array{
            if (TrenchA_State.ControllingTeam = TeamID) then true else false,
            if (TrenchB_State.ControllingTeam = TeamID) then true else false,
            if (TrenchC_State.ControllingTeam = TeamID) then true else false,
            if (TrenchD_State.ControllingTeam = TeamID) then true else false,
            if (TrenchE_State.ControllingTeam = TeamID) then true else false,
            if (TrenchF_State.ControllingTeam = TeamID) then true else false
        }

