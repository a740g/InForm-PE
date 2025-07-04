': This form was generated by
': InForm - GUI library for QB64 - Beta version 7
': Fellippe Heitor, 2016-2018 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------
SUB __UI_LoadForm

    DIM __UI_NewID AS LONG

    __UI_NewID = __UI_NewControl(__UI_Type_Form, "EncryptDecrypt", 500, 600, 0, 0, 0)
    SetCaption __UI_NewID, "Encrypt/Decrypt"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).Font = SetFont("segoeui.ttf", 12)
    Control(__UI_NewID).BackColor = _RGB32(235, 232, 237)
    Control(__UI_NewID).CenteredWindow = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "ChooseMethodOfCryptingLB", 160, 21, 170, 40, 0)
    SetCaption __UI_NewID, "1. Choose method of crypting"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).BackColor = _RGB32(255, 120, 120)
    Control(__UI_NewID).BorderColor = _RGB32(253, 255, 0)
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_DropdownList, "DropdownList1", 400, 23, 50, 76, 0)
    ToolTip(__UI_NewID) = "here you choose method to use for crypting"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SettingValuesForCryptingLB", 156, 21, 172, 125, 0)
    SetCaption __UI_NewID, "2. Setting values for crypting"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).BackColor = _RGB32(6, 210, 19)
    Control(__UI_NewID).BorderColor = _RGB32(4, 80, 215)
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "StepLB", 26, 21, 60, 151, 0)
    SetCaption __UI_NewID, "Step:"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "TextBox1", 50, 23, 91, 151, 0)
    SetCaption __UI_NewID, "TextBox1"
    ToolTip(__UI_NewID) = "commutation seed"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "HowManyCharsToJumpLB", 137, 21, 60, 177, 0)
    SetCaption __UI_NewID, "How many chars to jump:"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "TextBox2", 30, 25, 195, 177, 0)
    SetCaption __UI_NewID, "TextBox2"
    ToolTip(__UI_NewID) = "jumping character in encrytping (0 = noone)"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "MessageToCryptLB", 90, 21, 60, 203, 0)
    SetCaption __UI_NewID, "Message to crypt"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "TextBox3", 312, 45, 155, 203, 0)
    SetCaption __UI_NewID, "TextBox3"
    ToolTip(__UI_NewID) = "write Message to encrypt/decrypt"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "MessageAtStartAsWrittenByUserLB", 450, 80, 25, 260, 0)
    SetCaption __UI_NewID, "Message at start as written by user"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).WordWrap = True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "EncryptBT", 80, 23, 210, 352, 0)
    SetCaption __UI_NewID, "Encrypt"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "EncryptedMessageLB", 450, 80, 25, 380, 0)
    SetCaption __UI_NewID, "Encrypted Message"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).WordWrap = True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "DecryptBT", 80, 23, 210, 470, 0)
    SetCaption __UI_NewID, "Decrypt"
    ToolTip(__UI_NewID) = "this decrypts/takes back message"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "DecryptedMessageLB", 450, 80, 25, 500, 0)
    SetCaption __UI_NewID, "Decrypted Message"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).WordWrap = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "IncreaseLB", 43, 21, 225, 151, 0)
    SetCaption __UI_NewID, "Increase"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "TextBox4", 120, 23, 273, 151, 0)
    SetCaption __UI_NewID, "TextBox4"
    ToolTip(__UI_NewID) = "increase of step in progressive method "
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SeedLB", 39, 21, 234, 177, 0)
    SetCaption __UI_NewID, "Seed"
    ToolTip(__UI_NewID) = "Starting value of calculation"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "TextBox5", 120, 23, 273, 177, 0)
    SetCaption __UI_NewID, "TextBox5"
    ToolTip(__UI_NewID) = "input here starting value to calculate"
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True

END SUB

SUB __UI_AssignIDs
    EncryptDecrypt = __UI_GetID("EncryptDecrypt")
    ChooseMethodOfCryptingLB = __UI_GetID("ChooseMethodOfCryptingLB")
    DropdownList1 = __UI_GetID("DropdownList1")
    SettingValuesForCryptingLB = __UI_GetID("SettingValuesForCryptingLB")
    StepLB = __UI_GetID("StepLB")
    TextBox1 = __UI_GetID("TextBox1")
    HowManyCharsToJumpLB = __UI_GetID("HowManyCharsToJumpLB")
    TextBox2 = __UI_GetID("TextBox2")
    MessageToCryptLB = __UI_GetID("MessageToCryptLB")
    TextBox3 = __UI_GetID("TextBox3")
    MessageAtStartAsWrittenByUserLB = __UI_GetID("MessageAtStartAsWrittenByUserLB")
    EncryptBT = __UI_GetID("EncryptBT")
    EncryptedMessageLB = __UI_GetID("EncryptedMessageLB")
    DecryptBT = __UI_GetID("DecryptBT")
    DecryptedMessageLB = __UI_GetID("DecryptedMessageLB")
    IncreaseLB = __UI_GetID("IncreaseLB")
    TextBox4 = __UI_GetID("TextBox4")
    SeedLB = __UI_GetID("SeedLB")
    TextBox5 = __UI_GetID("TextBox5")
END SUB
