using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }

SpawnSelector := class():

    var MainCanvas : canvas = canvas{}
    var LeftBaseButton : button_regular = button_regular{}
    var LeftBaseBackground : color_block = color_block{}
    var TrenchAButton : button_regular = button_regular{}
    var TrenchBButton : button_regular = button_regular{}
    var TrenchCButton : button_regular = button_regular{}
    var TrenchDButton : button_regular = button_regular{}
    var TrenchEButton : button_regular = button_regular{}
    var TrenchFButton : button_regular = button_regular{}
    var RightBaseButton : button_regular = button_regular{}
    var RightBaseBackground : color_block = color_block{}
    var ExitButton : button_regular = button_regular{}
    var ExitButtonBackground : color_block = color_block{}

    # 黄色背景用color_block（占領状態表示用、6つのTrench分）
    var YellowBgA : color_block = color_block{}
    var YellowBgB : color_block = color_block{}
    var YellowBgC : color_block = color_block{}
    var YellowBgD : color_block = color_block{}
    var YellowBgE : color_block = color_block{}
    var YellowBgF : color_block = color_block{}

    AddUI(Agent : agent, GameRule : game_rule) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            # プレイヤーのチーム情報を取得
            PlayerTeamID := GameRule.GetPlayerTeamID(Agent)

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
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchA(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchB(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchC(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchD(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchE(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectTrenchF(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    SelectRightBase(Message : widget_message) : void =
        Player := Message.Player
        RemoveUI(Player)
        # TODO: Implement spawn logic here

    CreateUI(OccupiedTrenches : []logic) : canvas =
        # Set button text
        LeftBaseButton.SetText(StringToMessage("Base"))
        TrenchAButton.SetText(StringToMessage("A"))
        TrenchBButton.SetText(StringToMessage("B"))
        TrenchCButton.SetText(StringToMessage("C"))
        TrenchDButton.SetText(StringToMessage("D"))
        TrenchEButton.SetText(StringToMessage("E"))
        TrenchFButton.SetText(StringToMessage("F"))
        RightBaseButton.SetText(StringToMessage("Base"))
        ExitButton.SetText(StringToMessage("Exit"))

        # Set background colors for base buttons
        set LeftBaseBackground = color_block{DefaultColor := NamedColors.Blue, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set RightBaseBackground = color_block{DefaultColor := NamedColors.Red, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set ExitButtonBackground = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 300.0, Y := 100.0}}

        # Set yellow backgrounds for occupied trenches（占領状態表示）
        set YellowBgA = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgB = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgC = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgD = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgE = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
        set YellowBgF = color_block{DefaultColor := NamedColors.Yellow, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}

        # Subscribe button events
        LeftBaseButton.OnClick().Subscribe(SelectLeftBase)
        TrenchAButton.OnClick().Subscribe(SelectTrenchA)
        TrenchBButton.OnClick().Subscribe(SelectTrenchB)
        TrenchCButton.OnClick().Subscribe(SelectTrenchC)
        TrenchDButton.OnClick().Subscribe(SelectTrenchD)
        TrenchEButton.OnClick().Subscribe(SelectTrenchE)
        TrenchFButton.OnClick().Subscribe(SelectTrenchF)
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
            IsOccupiedD := OccupiedTrenches[3]
            IsOccupiedE := OccupiedTrenches[4]
            IsOccupiedF := OccupiedTrenches[5]
        then:
            # 占領状態に応じて黄色背景の色を設定（占領していない場合はグレー）
            YellowColorA := if (IsOccupiedA = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorB := if (IsOccupiedB = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorC := if (IsOccupiedC = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorD := if (IsOccupiedD = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorE := if (IsOccupiedE = true) then NamedColors.Yellow else NamedColors.Gray
            YellowColorF := if (IsOccupiedF = true) then NamedColors.Yellow else NamedColors.Gray

            # color_blockを再設定
            set YellowBgA = color_block{DefaultColor := YellowColorA, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgB = color_block{DefaultColor := YellowColorB, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgC = color_block{DefaultColor := YellowColorC, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgD = color_block{DefaultColor := YellowColorD, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgE = color_block{DefaultColor := YellowColorE, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}
            set YellowBgF = color_block{DefaultColor := YellowColorF, DefaultDesiredSize := vector2{X := 200.0, Y := 240.0}}

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

                # Trench D Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 4.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgD

                # Trench D Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 4.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchDButton

                # Trench E Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 5.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgE

                # Trench E Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 5.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchEButton

                # Trench F Yellow Background
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 6.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := YellowBgF

                # Trench F Button
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= StartX + (ButtonWidth + ButtonSpacing) * 6.0, Top:= -120.0, Right := ButtonWidth, Bottom := ButtonHeight}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TrenchFButton

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
    @editable PlayerSpawner : button_device = button_device{}
    @editable PlayerSpawner2 : button_device = button_device{}
    @editable PlayerSpawner3 : button_device = button_device{}
    @editable GameRule : game_rule = game_rule{}

    OnBegin<override>()<suspends>:void =
        PlayerSpawner.InteractedWithEvent.Subscribe(OnPlayerSpawned)
        PlayerSpawner2.InteractedWithEvent.Subscribe(OnPlayerSpawned)
        PlayerSpawner3.InteractedWithEvent.Subscribe(OnPlayerSpawned)
        Print("SpawnSelectorManager initialized and listening for spawn events")

    OnPlayerSpawned(Agent: agent) : void =
        Print("Player spawned, showing spawn selector UI")
        var NewSpawnSelector : SpawnSelector = SpawnSelector{}
        NewSpawnSelector.AddUI(Agent, GameRule)
