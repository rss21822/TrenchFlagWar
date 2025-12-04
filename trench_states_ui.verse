##########################################################################################################
#                                                                                                        #
#                                           Made by Oleszyk                                              #
#                                      Graphics were made by Yoppie                                      #
#                                                                                                        #
#                        You are not allowed to share this code or sell it                               #
#                                        Twitter  @Oleszykyt                                             #
#                              Discord  https://discord.gg/u44mbkXS                                      #
#                             YouTube  https://www.youtube.com/@Oleszyk                                  #
#                                                                                                        #
##########################################################################################################

using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { AllRanks }

# モジュールレベルでweak_mapを定義（持続データ用）
var PlayerStatsMap : weak_map(player, CustomPlayer) = map{}

CustomPlayer := class<persistable><final>():
    PlayerName : string = ""
    PlayerKills : int = 0
    PlayerDeaths : int = 0
    PlayerPoints : int = 0
    PlayerRank : int = 0


UpdatePlayerStats<constructor>(PlayerName : string, PlayerKills : int, PlayerDeaths:int, PlayerPoints:int, PlayerRank:int):= CustomPlayer:
    PlayerName := PlayerName
    PlayerKills := PlayerKills
    PlayerDeaths := PlayerDeaths
    PlayerPoints := PlayerPoints
    PlayerRank := PlayerRank

RankManager := class(creative_device):
    @editable PlayerSpawners : []player_spawner_device = array{}
    @editable GuardSpawner : guard_spawner_device = guard_spawner_device{}
    @editable PointsPerKill : int = 5
    @editable MinusPointsPerDeath : int = 3
    @editable Settings : RankSettings = RankSettings{}
    @editable StatsBoard : Stats = Stats{}

    var Players : []player = array{}

    OnBegin<override>()<suspends>:void=
        set Players = GetPlayspace().GetPlayers()
        InitPlayerStatsBoard()
        InitPlayerManager()
        for (PlayerSpawner : PlayerSpawners): 
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

        spawn{GuardLoop()}

        Update()

    InitPlayerStatsBoard():void=
        StatsBoard.PlayerRef.Clear()
        StatsBoard.NameBoard.HideText()
        StatsBoard.EliminationsBoard.HideText()
        StatsBoard.DeathBoard.HideText()
        StatsBoard.KillsPerDeathBoard.HideText()
        StatsBoard.RankBoard.HideText()
        StatsBoard.Button.InteractedWithEvent.Subscribe(OnButton)

    InitPlayerManager():void=
        for(Player:Players):
            InitPlayerStats(Player)

    InitPlayerStats(Player:player):void=
        if(ExistingStats := PlayerStatsMap[Player]):
            Print("Stats Exist - Loading persistent data")
            Print("Player Name • {ExistingStats.PlayerName}")
            Print("Eliminations • {ExistingStats.PlayerKills}")
            Print("Deaths • {ExistingStats.PlayerDeaths}")
            Print("Points • {ExistingStats.PlayerPoints}")
        else:
            # 新規プレイヤー: 空の名前で初期化（後で更新される）
            NewStats := UpdatePlayerStats("", 0, 0, 0, 0)
            if(set PlayerStatsMap[Player] = NewStats):
                Print("New Player stats were created")

    # 持続データの取得
    GetPlayerStats(Player:player):CustomPlayer =
        if(PlayerStats := PlayerStatsMap[Player]):
            PlayerStats
        else:
            # 新規プレイヤーの場合はデフォルト値を返す
            CustomPlayer{}

    # 持続データの保存
    SetPlayerStats(Player:player, PlayerStats:CustomPlayer):void=
        if(set PlayerStatsMap[Player] = PlayerStats):
            Print("Player stats saved for {PlayerStats.PlayerName}")

    UpdateStats(Player:player, PlayerName:string, NewKills:int, NewDeaths:int, NewPoints:int, NewRank:int):CustomPlayer=
        UpdatedStats := UpdatePlayerStats(PlayerName, NewKills, NewDeaths, NewPoints, NewRank)
        # SetPlayerStatsを使って明示的に保存
        SetPlayerStats(Player, UpdatedStats)
        Print("Updated player stats!")
        Print("Player Name • {UpdatedStats.PlayerName}")
        Print("Eliminations • {UpdatedStats.PlayerKills}")
        Print("Deaths • {UpdatedStats.PlayerDeaths}")
        Print("Points • {UpdatedStats.PlayerPoints}")
        Print("Rank • {UpdatedStats.PlayerRank}")
        return UpdatedStats
    
    GiveBackbling(Player : player, Custom_Player : CustomPlayer, Rank_Settings : RankSettings):void=
        RankIndex := Custom_Player.PlayerRank
        if(NewRank := Rank_Settings.RankTypes[RankIndex]):
            NewRank.Backbling.Pickup(Player)

    GuardLoop()<suspends> : void =
        loop:
            A := GuardSpawner.SpawnedEvent.Await()
            if ( F := A.GetFortCharacter[]):
                spawn{AwaitElimi(F)}

    OnButton(Agent : agent):void=
        if(Player := player[Agent]):
            spawn:
                OnStatsButtonInterect(Agent, GetPlayerStats(Player),Settings)

    OnPlayerSpawn(Agent:agent):void=
        Print("Player has been spawned")
        for(Player:Players):
            GiveBackbling(Player, GetPlayerStats(Player),Settings)
        if ( FortCharacter := Agent.GetFortCharacter[]):
            spawn{AwaitElimi(FortCharacter)}

    AwaitElimi(FortCharacter : fort_character)<suspends>: void=
        if(FortCharacter.GetAgent[]):
            loop:
                Result := FortCharacter.EliminatedEvent().Await()
                OnEliminaion(Result)

    Update()<suspends> : void=
        sync:
            loop:
                Player := GetPlayspace().PlayerAddedEvent().Await()
                if ( not Players.Find[Player]):
                    set Players += array{Player}
                    InitPlayerStats(Player)
                    InitPlayerUI(Player)
            loop:
                Player := GetPlayspace().PlayerRemovedEvent().Await()
                set Players = for (CurrentPlayer : Players, CurrentPlayer <> Player) {CurrentPlayer}


    OnEliminaion(ElimResult : elimination_result):void=
        EliminatedCharacter := ElimResult.EliminatedCharacter
        MaybeEliminatingCharacter := ElimResult.EliminatingCharacter
        if(Player := player[EliminatedCharacter.GetAgent[]]):
            UpdateEliminatedPlayerStats(Player)

        if:
            EliminatingCharacter := MaybeEliminatingCharacter?
            EliminatingCharacter <> EliminatedCharacter
            Agent := EliminatingCharacter.GetAgent[]
            Player := player[Agent]
        then:
            UpdateEliminatingPlayerStats(Player)

    UpdateEliminatingPlayerStats(Player:player):void=
        GiveBackbling(Player, GetPlayerStats(Player),Settings)
        PlayerStats := GetPlayerStats(Player)
        NewKills := PlayerStats.PlayerKills + 1
        NewDeaths := PlayerStats.PlayerDeaths
        NewPoints := PlayerStats.PlayerPoints + PointsPerKill
        NewRank := CountPlayerRankUp(PlayerStats, NewPoints)
        PlayerNameToSave := PlayerStats.PlayerName
        NewStats := UpdateStats(Player, PlayerNameToSave, NewKills, NewDeaths, NewPoints, NewRank)

    MaybeUpdateEliminatingPlayerStats(MaybeElimination : ?agent):void=
        for(Player:Players):
            GiveBackbling(Player, GetPlayerStats(Player),Settings)
        if(Player := player[MaybeElimination?]):
            PlayerStats := GetPlayerStats(Player)
            NewKills := PlayerStats.PlayerKills + 1
            NewDeaths := PlayerStats.PlayerDeaths
            NewPoints := PlayerStats.PlayerPoints + PointsPerKill
            NewRank := CountPlayerRankUp(PlayerStats, NewPoints)
            PlayerNameToSave := PlayerStats.PlayerName
            NewStats := UpdateStats(Player, PlayerNameToSave, NewKills, NewDeaths, NewPoints, NewRank)


    UpdateEliminatedPlayerStats(Agent : agent):void=
        for(Player:Players):
            GiveBackbling(Player, GetPlayerStats(Player),Settings)
        if(Player := player[Agent]):
            PlayerStats := GetPlayerStats(Player)
            NewPoints := if(PlayerStats.PlayerPoints - MinusPointsPerDeath >= 0) then PlayerStats.PlayerPoints - MinusPointsPerDeath else 0
            NewKills := PlayerStats.PlayerKills
            NewDeaths := PlayerStats.PlayerDeaths + 1
            NewRank := CountPlayerRankDown(PlayerStats, NewPoints)
            PlayerNameToSave := PlayerStats.PlayerName
            NewStats := UpdateStats(Player, PlayerNameToSave, NewKills, NewDeaths, NewPoints, NewRank)

    CountPlayerRankUp(OldStats : CustomPlayer, NewPoints : int):int=
        CurrentRankIndex := OldStats.PlayerRank
        if( NextRank := Settings.RankTypes[CurrentRankIndex + 1]):
            if( NewPoints >= NextRank.PointsForRank):
                return CurrentRankIndex + 1
        return CurrentRankIndex

    CountPlayerRankDown(OldStats : CustomPlayer, NewPoints : int):int=
        CurrentRankIndex := OldStats.PlayerRank
        if(CurrentRank := Settings.RankTypes[CurrentRankIndex]):
            if( NewPoints < CurrentRank.PointsForRank):
                return CurrentRankIndex - 1
        CurrentRankIndex
    
    var PlayerWidgetsMap : [player]PlayerWidget = map{}

    InitUI():void=
        for ( Player : Players):
            InitPlayerUI(Player)

    InitPlayerUI(Player : player):void=
        Canvas : canvas = canvas{}
        ProgressBar : CustomProgressBar = CustomProgressBar:
            Width := 175.0
            Heigth := 19.0

        CanvasSlot := canvas_slot:
            Widget := ProgressBar.GetRootWidget()
            Anchors := anchors{Minimum := vector2{X:= 0.0, Y:= 1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
            Offsets := margin{Left:=45.0, Top := -421.0}
        Canvas.AddWidget(CanvasSlot)
        PlayerWidgets := PlayerWidget:
            Canvas := Canvas
            ProgressBar := ProgressBar

        if( set PlayerWidgetsMap [Player] = PlayerWidgets, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Canvas)

    UpdateProgress(Player : player, Custom_Player : CustomPlayer, Rank_Settings : RankSettings): void = 
        RankIndex := Custom_Player.PlayerRank
        if(Widgets := PlayerWidgetsMap[Player], CurrentRank := Rank_Settings.RankTypes[RankIndex]):
            if( NextRank := Rank_Settings.RankTypes[RankIndex +1]):
                Progress := 1.0* (Custom_Player.PlayerPoints - CurrentRank.PointsForRank) / (1.0* (NextRank.PointsForRank - CurrentRank.PointsForRank))
                if(Rank_Settings.TextSettings = Text.Points):
                    ProgressText := "{Custom_Player.PlayerPoints}/{NextRank.PointsForRank}"
                    Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                else if(Rank_Settings.TextSettings = Text.Percent):
                    if(MyRank := Rank_Settings.RankTypes[RankIndex]):
                        Precent := ((Custom_Player.PlayerPoints - MyRank.PointsForRank) * 100.0)/(NextRank.PointsForRank*1.0)
                        if(PrecentCount := Round[Precent]):
                            ProgressText := "{PrecentCount}%"
                            Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                else if(Rank_Settings.TextSettings = Text.Nothing):
                    Widgets.ProgressBar.SetProgress(Progress , "")
            else:
                Progress := 1.0
                if(Rank_Settings.TextSettings = Text.Points):
                    ProgressText := "{Custom_Player.PlayerPoints}"
                    Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                else if(Rank_Settings.TextSettings = Text.Percent):
                    Precent := 100.0
                    if(PrecentCount := Round[Precent]):
                        ProgressText := "{PrecentCount}%"
                        Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                else:
                    Widgets.ProgressBar.SetProgress(Progress , "")

        #Stats board info
    OnStatsButtonInterect(Agent : agent, Custom_Player : CustomPlayer, Rank_Settings : RankSettings)<suspends>:void=
        StatsBoard.PlayerRef.Register(Agent)
        StatsBoard.NameBoard.SetText(AgentToMessage(Agent))
        StatsBoard.NameBoard.ShowText()
        StatsBoard.EliminationsBoard.SetText(IntToMessage("Eliminations • ", Custom_Player.PlayerKills))
        StatsBoard.EliminationsBoard.ShowText()
        StatsBoard.DeathBoard.SetText(IntToMessage("Deaths • ",Custom_Player.PlayerDeaths))
        StatsBoard.DeathBoard.ShowText()
        var PlayerStatsDeaths : float = 1.0*Custom_Player.PlayerDeaths
        if(PlayerStatsDeaths < 1.0):
            set PlayerStatsDeaths = 1.0
        KPerD := (1.0 *Custom_Player.PlayerKills)/(PlayerStatsDeaths)
        StatsBoard.KillsPerDeathBoard.SetText(FloatToMessage("K/D • ",KPerD))
        StatsBoard.KillsPerDeathBoard.ShowText()
        if(RankName :=Rank_Settings.RankTypes[Custom_Player.PlayerRank].Name):
            StatsBoard.RankBoard.SetText(StringsToMessage("Rank • ",RankName))
            StatsBoard.RankBoard.ShowText()

        <#
        StatsBoard.Button.Disable()
        Sleep(10.0)

        StatsBoard.PlayerRef.Clear()
        StatsBoard.NameBoard.HideText()
        StatsBoard.EliminationsBoard.HideText()
        StatsBoard.DeathBoard.HideText()
        StatsBoard.KillsPerDeathBoard.HideText()
        StatsBoard.RankBoard.HideText()
        StatsBoard.Button.Enable()
        #>

PlayerWidget := struct:
    Canvas : canvas
    ProgressBar : CustomProgressBar

CustomProgressBar := class:
    Width : float
    Heigth : float


    RankTextureBlock : texture_block = texture_block{DefaultImage := AllRanks.Elite}
    ColorBlockForeground : color_block = color_block{}
    ColorBlockBackground : color_block = color_block{}
    RankTextBlock : text_block = text_block{DefaultTextColor := NamedColors.White}
    ProgressTextBlock : text_block = text_block{DefaultTextColor := NamedColors.White}

    var RootWidget : widget = color_block{}

    SetProgress(InProgress : float, ProgressText : string) : void= 
        var NewProgress : float = 0.0
        if ( InProgress > 1.0) then set NewProgress = 1.0
        else if( InProgress < 0.0) then set NewProgress = 0.0
        else set NewProgress = InProgress

        NewWidth := NewProgress * Width
        ColorBlockForeground.SetDesiredSize(vector2{X:= NewWidth, Y := Heigth})
                                        
    GetRootWidget(): widget = RootWidget 
    SetForegroundColor(Color : color):void= ColorBlockForeground.SetColor(Color)
    SetBackgroundColor(Color : color):void= ColorBlockBackground.SetColor(Color)
    SetRankText(String : string):void = RankTextBlock.SetText(StringToMessage(String))

AgentToMessage<localizes>(Agent:agent):message="{Agent}"
FloatToMessage<localizes>(String : string,Float : float):message="{String}{Float}"
IntToMessage<localizes>(String : string, Integer : int):message="{String}{Integer}"
StringsToMessage<localizes>(String1 : string, String2 : string):message = "{String1}{String2}"
StringToMessage<localizes>(String : string):message= "{String}"

Stats := class<concrete>:
    @editable NameBoard : billboard_device = billboard_device{}
    @editable EliminationsBoard : billboard_device = billboard_device{}
    @editable DeathBoard : billboard_device = billboard_device{}
    @editable KillsPerDeathBoard : billboard_device = billboard_device{}
    @editable RankBoard : billboard_device = billboard_device{}
    @editable Button : button_device = button_device{}
    @editable PlayerRef : player_reference_device = player_reference_device{}

Text := enum{
    Nothing,
    Points,
    Percent
    }

Rank := class<concrete>:
    @editable Name : string = "Rank Name"
    @editable PointsForRank : int = 0
    @editable ForegroundColor : color = color{}
    @editable BackgroundColor : color = color{}
    @editable Backbling : visual_effect_powerup_device = visual_effect_powerup_device{}

RankSettings := class<concrete>:
    @editable var TextSettings : Text = Text.Nothing
    @editable RankTypes : []Rank = array{}
    Images :[]texture = array:
        # Change the names to your rank images names
        AllRanks.Unranked
        AllRanks.Bronze1
        AllRanks.Bronze2
        AllRanks.Bronze3
        AllRanks.Silver1
        AllRanks.Silver2
        AllRanks.Silver3
        AllRanks.Gold1
        AllRanks.Gold2
        AllRanks.Gold3
        AllRanks.Plat1
        AllRanks.Plat2
        AllRanks.Plat3
        AllRanks.Diamond1
        AllRanks.Diamond2
        AllRanks.Diamond3
        AllRanks.Elite
        AllRanks.Champion
        AllRanks.Unreal
AllRanks1<public> := module:

# 陣地状態を保持する構造体
trench_status := struct:
    ControllingTeam : int = 0  # 0=中立, 1=Axis, 2=Allied

# 陣地状態表示用のUIマネージャー
trench_states_ui_manager := class(creative_device):
    var PlayerUIMap : [player]canvas = map{}

    # シャドウオフセット（VERSE.txtと同じ設定）
    TextShadowOffset:?vector2 = option{vector2{X:=2.0, Y:=2.0}}

    # 全プレイヤーにUIを初期化
    InitializeUI<public>(Players : []player):void=
        for (Player : Players):
            InitPlayerUI(Player)

    # 個別プレイヤーのUI初期化
    InitPlayerUI(Player : player):void=
        UICanvas := CreateTrenchUI("", "")

        # プレイヤーUIに追加
        if (set PlayerUIMap[Player] = UICanvas, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(UICanvas, player_ui_slot{ZOrder:=10, InputMode := ui_input_mode.None})

    # 陣地UIを作成
    CreateTrenchUI(AxisTrenchList : string, AlliedTrenchList : string) : canvas =
        # Axisラベル（赤色、シャドウ付き）- VERSE.txtのRedTeamTextと同じスタイル
        AxisLabelText : text_block = text_block{DefaultTextColor := NamedColors.Red}
        AxisLabelText.SetText(StringToMessage("AXIS"))
        AxisLabelText.SetShadowOffset(TextShadowOffset)
        AxisLabelText.SetShadowOpacity(1.0)

        # Axis陣地リスト（白色、赤シャドウ）- VERSE.txtのTeamTwoScoreと同じスタイル
        AxisTrenchText : text_block = text_block{DefaultTextColor := NamedColors.White}
        AxisTrenchDisplayText := if (AxisTrenchList = "") then "-" else AxisTrenchList
        AxisTrenchText.SetText(StringToMessage("[{AxisTrenchDisplayText}]"))
        AxisTrenchText.SetShadowOffset(TextShadowOffset)
        AxisTrenchText.SetShadowOpacity(1.0)
        AxisTrenchText.SetShadowColor(NamedColors.Red)

        # VSテキスト（白色、シャドウ付き）
        VsText : text_block = text_block{DefaultTextColor := NamedColors.White}
        VsText.SetText(StringToMessage("VS"))
        VsText.SetShadowOffset(TextShadowOffset)
        VsText.SetShadowOpacity(1.0)

        # Alliedラベル（青色、シャドウ付き）- VERSE.txtのBlueTeamTextと同じスタイル
        AlliedLabelText : text_block = text_block{DefaultTextColor := NamedColors.Blue}
        AlliedLabelText.SetText(StringToMessage("ALLIES"))
        AlliedLabelText.SetShadowOffset(TextShadowOffset)
        AlliedLabelText.SetShadowOpacity(1.0)

        # Allied陣地リスト（白色、青シャドウ）- VERSE.txtのTeamOneScoreと同じスタイル
        AlliedTrenchText : text_block = text_block{DefaultTextColor := NamedColors.White}
        AlliedTrenchDisplayText := if (AlliedTrenchList = "") then "-" else AlliedTrenchList
        AlliedTrenchText.SetText(StringToMessage("[{AlliedTrenchDisplayText}]"))
        AlliedTrenchText.SetShadowOffset(TextShadowOffset)
        AlliedTrenchText.SetShadowOpacity(1.0)
        AlliedTrenchText.SetShadowColor(NamedColors.Blue)

        # VERSE.txtと同様のレイアウト構造
        NewCanvas := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.04}, Maximum := vector2{X:=0.5, Y:=0.04}}
                    Alignment := vector2{X:=0.5, Y:=0.0}
                    SizeToContent := true
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            # Axis側（左）
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=6.0, Bottom:=2.0}
                                            Widget := AxisLabelText
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=2.0, Left:=12.0, Right:=12.0, Bottom:=2.0}
                                            Widget := AxisTrenchText
                            # VS（中央）
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                Padding := margin{Top:=2.0, Left:=24.0, Right:=24.0, Bottom:=2.0}
                                Widget := VsText
                            # Allied側（右）
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Right
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=6.0, Bottom:=2.0}
                                            Widget := AlliedLabelText
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            Padding := margin{Top:=2.0, Left:=12.0, Right:=12.0, Bottom:=2.0}
                                            Widget := AlliedTrenchText
        return NewCanvas

    # 陣地状態を更新して表示
    UpdateTrenchStates<public>(Players : []player, TrenchAState : trench_state, TrenchBState : trench_state, TrenchCState : trench_state, TrenchXState : trench_state, TrenchYState : trench_state, TrenchZState : trench_state):void=
        # 各チームが占領している陣地名を収集
        var AxisTrenches : []string = array{}
        var AlliedTrenches : []string = array{}

        if (TrenchAState.ControllingTeam = 1):
            set AxisTrenches += array{"A"}
        else if (TrenchAState.ControllingTeam = 2):
            set AlliedTrenches += array{"A"}

        if (TrenchBState.ControllingTeam = 1):
            set AxisTrenches += array{"B"}
        else if (TrenchBState.ControllingTeam = 2):
            set AlliedTrenches += array{"B"}

        if (TrenchCState.ControllingTeam = 1):
            set AxisTrenches += array{"C"}
        else if (TrenchCState.ControllingTeam = 2):
            set AlliedTrenches += array{"C"}

        if (TrenchXState.ControllingTeam = 1):
            set AxisTrenches += array{"X"}
        else if (TrenchXState.ControllingTeam = 2):
            set AlliedTrenches += array{"X"}

        if (TrenchYState.ControllingTeam = 1):
            set AxisTrenches += array{"Y"}
        else if (TrenchYState.ControllingTeam = 2):
            set AlliedTrenches += array{"Y"}

        if (TrenchZState.ControllingTeam = 1):
            set AxisTrenches += array{"Z"}
        else if (TrenchZState.ControllingTeam = 2):
            set AlliedTrenches += array{"Z"}

        # 陣地名をカンマ区切りで結合
        AxisTrenchList := JoinStrings(AxisTrenches)
        AlliedTrenchList := JoinStrings(AlliedTrenches)

        for (Player : Players):
            UpdatePlayerUI(Player, AxisTrenchList, AlliedTrenchList)

    # 文字列配列をカンマ区切りで結合
    JoinStrings(Strings : []string) : string =
        var Result : string = ""
        for (Index -> Str : Strings):
            if (Index > 0):
                set Result = "{Result}, {Str}"
            else:
                set Result = Str
        Result

    # プレイヤーUIの更新
    UpdatePlayerUI(Player : player, AxisTrenchList : string, AlliedTrenchList : string):void=
        if (UICanvas := PlayerUIMap[Player]):
            # 既存のキャンバスを削除
            if (PlayerUI := GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(UICanvas)

            # 新しいキャンバスを作成
            NewCanvas := CreateTrenchUI(AxisTrenchList, AlliedTrenchList)

            if (set PlayerUIMap[Player] = NewCanvas, PlayerUIInstance := GetPlayerUI[Player]):
                PlayerUIInstance.AddWidget(NewCanvas, player_ui_slot{ZOrder:=10, InputMode := ui_input_mode.None})

TrenchStatusMessage<localizes>(StatusText : string):message = "{StatusText}"