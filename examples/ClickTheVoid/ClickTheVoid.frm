': This form was generated by
': InForm - GUI library for QB64 - v1.5
': Fellippe Heitor, 2016-2023 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------
SUB __UI_LoadForm

    DIM __UI_NewID AS LONG, __UI_RegisterResult AS LONG

    __UI_NewID = __UI_NewControl(__UI_Type_Form, "ClickTheVoid", 300, 322, 0, 0, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "Click the void"
    Control(__UI_NewID).Font = SetFont("segoeui.ttf?arial.ttf?/Library/Fonts/Arial.ttf?InForm/resources/NotoMono-Regular.ttf?cour.ttf", 12)
    Control(__UI_NewID).HasBorder = False

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "PictureBox1", 280, 258, 10, 10, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = True
    Control(__UI_NewID).BackColor = _RGB32(0, 0, 0)
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "Button1", 80, 23, 210, 280, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "Button1"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "TrackBar1", 143, 40, 16, 272, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Value = 30
    Control(__UI_NewID).Min = 30
    Control(__UI_NewID).Max = 1000
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Interval = 50

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "fpsLB", 38, 41, 164, 272, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "30fps"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

END SUB

SUB __UI_AssignIDs
    ClickTheVoid = __UI_GetID("ClickTheVoid")
    PictureBox1 = __UI_GetID("PictureBox1")
    Button1 = __UI_GetID("Button1")
    TrackBar1 = __UI_GetID("TrackBar1")
    fpsLB = __UI_GetID("fpsLB")
END SUB