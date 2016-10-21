'InForm - GUI system for QB64
'Fellippe Heitor, 2016 - fellippe@qb64.org - @fellippeheitor
'Beta version 1
SUB __UI_LoadForm
    DIM __UI_NewID AS LONG

    __UI_NewID = __UI_NewControl(__UI_Type_Form, "Form1", 598, 430, 0, 0, 0)
    __UI_SetCaption "Form1", "InForm Designer"
    __UI_Controls(__UI_NewID).Font = __UI_Font("Noto Mono", "InForm\NotoMono-Regular.ttf", 12, "MONOSPACE")

    __UI_NewID = __UI_NewControl(__UI_Type_MenuBar, "FileMenu", 56, 18, 14, 0, 0)
    __UI_SetCaption "FileMenu", "&File"

    __UI_NewID = __UI_NewControl(__UI_Type_MenuBar, "ViewMenu", 56, 18, 14, 0, 0)
    __UI_SetCaption "ViewMenu", "&View"

    __UI_NewID = __UI_NewControl(__UI_Type_MenuBar, "HelpMenu", 56, 18, 527, 0, 0)
    __UI_SetCaption "HelpMenu", "&Help"
    __UI_Controls(__UI_NewID).Align = __UI_Right

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "FileMenuLoad", 140, 18, 0, 4, __UI_GetID("FileMenu"))
    __UI_SetCaption "FileMenuLoad", "&Load form.frmbin"
    __UI_Controls(__UI_NewID).Disabled = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "FileMenuSave", 91, 18, 0, 22, __UI_GetID("FileMenu"))
    __UI_SetCaption "FileMenuSave", "&Save form"
    __UI_Controls(__UI_NewID).Disabled = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "FileMenuExit", 56, 18, 0, 40, __UI_GetID("FileMenu"))
    __UI_SetCaption "FileMenuExit", "E&xit"

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "ViewMenuPreview", 56, 18, 0, 40, __UI_GetID("ViewMenu"))
    __UI_SetCaption "ViewMenuPreview", "Open &preview window"

    $IF WIN THEN
        __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "ViewMenuPreviewDetach", 56, 18, 0, 40, __UI_GetID("ViewMenu"))
        __UI_Controls(__UI_NewID).Value = __UI_True
        __UI_SetCaption "ViewMenuPreviewDetach", "&Keep preview window attached"
    $END IF

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "HelpMenuHelp", 0, 0, 0, 0, __UI_GetID("HelpMenu"))
    __UI_SetCaption "HelpMenuHelp", "&What's all this?"

    __UI_NewID = __UI_NewControl(__UI_Type_MenuItem, "HelpMenuAbout", 0, 0, 0, 0, __UI_GetID("HelpMenu"))
    __UI_SetCaption "HelpMenuAbout", "&About..."

    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "ToolBox", 62, 376, 30, 40, 0)
    __UI_Controls(__UI_NewID).HasBorder = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddButton", 22, 22, 20, 20, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddLabel", 22, 22, 20, 50, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddTextBox", 22, 22, 20, 80, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddCheckBox", 22, 22, 20, 110, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddRadioButton", 22, 22, 20, 140, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddListBox", 22, 22, 20, 170, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddDropdownList", 22, 22, 20, 200, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddTrackBar", 22, 22, 20, 230, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddProgressBar", 22, 22, 20, 260, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddPictureBox", 22, 22, 20, 290, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "AddFrame", 22, 22, 20, 320, __UI_GetID("ToolBox"))
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "PropertiesFrame", 457, 186, 110, 40, 0)
    __UI_SetCaption "PropertiesFrame", "Control properties: Form1"
    __UI_Controls(__UI_NewID).HasBorder = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_DropdownList, "PropertiesList", 174, 23, 20, 20, __UI_GetID("PropertiesFrame"))
    __UI_AddListBoxItem "PropertiesList", "Name"
    __UI_AddListBoxItem "PropertiesList", "Caption"
    __UI_AddListBoxItem "PropertiesList", "Text"
    __UI_AddListBoxItem "PropertiesList", "Top"
    __UI_AddListBoxItem "PropertiesList", "Left"
    __UI_AddListBoxItem "PropertiesList", "Width"
    __UI_AddListBoxItem "PropertiesList", "Height"
    __UI_AddListBoxItem "PropertiesList", "Font"
    __UI_AddListBoxItem "PropertiesList", "BackStyle"
    __UI_AddListBoxItem "PropertiesList", "Value"
    __UI_AddListBoxItem "PropertiesList", "Min"
    __UI_AddListBoxItem "PropertiesList", "Max"
    __UI_AddListBoxItem "PropertiesList", "Interval"
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).Value = 1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "PropertyValue", 250, 23, 200, 20, __UI_GetID("PropertiesFrame"))
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "Stretch", 150, 17, 70, 59, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "Stretch", "Stretch"
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "HasBorder", 150, 17, 70, 79, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "HasBorder", "Has border"
    __UI_Controls(__UI_NewID).Value = -1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "ShowPercentage", 149, 17, 70, 99, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "ShowPercentage", "Show percentage"
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "WordWrap", 150, 17, 70, 119, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "WordWrap", "Word wrap"
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "CanHaveFocus", 150, 17, 230, 59, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "CanHaveFocus", "Can have focus"
    __UI_Controls(__UI_NewID).Value = -1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "Disabled", 150, 17, 230, 79, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "Disabled", "Disabled"
    __UI_Controls(__UI_NewID).Value = -1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "Hidden", 150, 17, 230, 99, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "Hidden", "Hidden"
    __UI_Controls(__UI_NewID).Value = -1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "CenteredWindow", 150, 17, 230, 119, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "CenteredWindow", "Centered window"
    __UI_Controls(__UI_NewID).Value = -1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "Label1", 83, 20, 70, 150, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "Label1", "Text align:"

    __UI_NewID = __UI_NewControl(__UI_Type_DropdownList, "AlignOptions", 155, 20, 160, 150, __UI_GetID("PropertiesFrame"))
    __UI_SetCaption "AlignOptions", "Left"
    __UI_AddListBoxItem "AlignOptions", "Left"
    __UI_AddListBoxItem "AlignOptions", "Center"
    __UI_AddListBoxItem "AlignOptions", "Right"
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).Value = 1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "ColorMixer", 457, 175, 110, 240, 0)
    __UI_SetCaption "ColorMixer", "Color mixer"
    __UI_Controls(__UI_NewID).HasBorder = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_DropdownList, "ColorPropertiesList", 161, 21, 10, 20, __UI_GetID("ColorMixer"))
    __UI_AddListBoxItem "ColorPropertiesList", "ForeColor"
    __UI_AddListBoxItem "ColorPropertiesList", "BackColor"
    __UI_AddListBoxItem "ColorPropertiesList", "SelectedForeColor"
    __UI_AddListBoxItem "ColorPropertiesList", "SelectedBackColor"
    __UI_AddListBoxItem "ColorPropertiesList", "BorderColor"
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).Value = 1
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "ColorPreview", 159, 115, 10, 51, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).HasBorder = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "Red", 198, 40, 191, 17, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).Max = 255
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True
    __UI_Controls(__UI_NewID).Interval = 25

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "RedValue", 36, 23, 400, 20, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).BorderColor = _RGB32(255, 0, 0)
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "Green", 198, 40, 191, 67, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).Max = 255
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True
    __UI_Controls(__UI_NewID).Interval = 25

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "GreenValue", 36, 23, 400, 70, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).BorderColor = _RGB32(0, 180, 0)
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "Blue", 198, 40, 191, 117, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).Max = 255
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True
    __UI_Controls(__UI_NewID).Interval = 25

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "BlueValue", 36, 23, 400, 120, __UI_GetID("ColorMixer"))
    __UI_Controls(__UI_NewID).BorderColor = _RGB32(0, 0, 255)
    __UI_Controls(__UI_NewID).HasBorder = __UI_True
    __UI_Controls(__UI_NewID).CanHaveFocus = __UI_True
END SUB