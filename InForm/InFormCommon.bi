'-----------------------------------------------------------------------------------------------------------------------
' Common InForm header. This is included by the main InForm header file
' Copyright (c) 2025 Samuel Gomes
' Copyright (c) 2022 Fellippe Heitor
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

' Do a complier check to ensure we have the minimum version needed
$IF VERSION < 4.1.0 THEN
    $ERROR 'This requires the latest version of QB64-PE from https://github.com/QB64-Phoenix-Edition/QB64pe/releases/latest'
$END IF

$LET INFORMCOMMON_BI = TRUE

'$INCLUDE:'InFormVersion.bi'
'$INCLUDE:'extensions/HashTable.bi'

CONST False%% = _FALSE, True%% = _TRUE

' InForm theme image IDs
CONST __INFORM_THEME_IMAGE_ARROWS~%% = 1~%%
CONST __INFORM_THEME_IMAGE_BUTTON~%% = 2~%%
CONST __INFORM_THEME_IMAGE_CHECKBOX~%% = 3~%%
CONST __INFORM_THEME_IMAGE_FRAME~%% = 4~%%
CONST __INFORM_THEME_IMAGE_MENUCHECKMARK~%% = 5~%%
CONST __INFORM_THEME_IMAGE_NOTFOUND~%% = 6~%%
CONST __INFORM_THEME_IMAGE_PROGRESSCHUNK~%% = 7~%%
CONST __INFORM_THEME_IMAGE_PROGRESSTRACK~%% = 8~%%
CONST __INFORM_THEME_IMAGE_RADIOBUTTON~%% = 9~%%
CONST __INFORM_THEME_IMAGE_SCROLLBUTTONS~%% = 10~%%
CONST __INFORM_THEME_IMAGE_SCROLLHBUTTONS~%% = 11~%%
CONST __INFORM_THEME_IMAGE_SCROLLHTHUMB~%% = 12~%%
CONST __INFORM_THEME_IMAGE_SCROLLHTRACK~%% = 13~%%
CONST __INFORM_THEME_IMAGE_SCROLLTHUMB~%% = 14~%%
CONST __INFORM_THEME_IMAGE_SCROLLTRACK~%% = 15~%%
CONST __INFORM_THEME_IMAGE_SLIDERDOWN~%% = 16~%%
CONST __INFORM_THEME_IMAGE_SLIDERTRACK~%% = 17~%%

' Default font list
CONST __INFORM_DEFAULT_FONTS = "segoeui.ttf?arial.ttf?Arial.ttf?Helvetica.ttc?Geneva.ttf?truetype/liberation/LiberationSans-Regular.ttf?TTF/arial.ttf?InForm/resources/NotoMono-Regular.ttf?cour.ttf?Courier.ttc"
CONST __INFORM_DEFAULT_FONTS_MONO = "cour.ttf?Courier New.ttf?truetype/liberation/LiberationMono-Regular.ttf?Monaco.ttf?Courier.ttc"

'Control types:
CONST __UI_Type_Form%% = 1%%
CONST __UI_Type_Frame%% = 2%%
CONST __UI_Type_Button%% = 3%%
CONST __UI_Type_Label%% = 4%%
CONST __UI_Type_CheckBox%% = 5%%
CONST __UI_Type_RadioButton%% = 6%%
CONST __UI_Type_TextBox%% = 7%%
CONST __UI_Type_ProgressBar%% = 8%%
CONST __UI_Type_ListBox%% = 9%%
CONST __UI_Type_DropdownList%% = 10%%
CONST __UI_Type_MenuBar%% = 11%%
CONST __UI_Type_MenuItem%% = 12%%
CONST __UI_Type_MenuPanel%% = 13%%
CONST __UI_Type_PictureBox%% = 14%%
CONST __UI_Type_TrackBar%% = 15%%
CONST __UI_Type_ContextMenu%% = 16%%
CONST __UI_Type_Font%% = 17%%
CONST __UI_Type_ToggleSwitch%% = 18%%

'Back styles:
CONST __UI_Opaque%% = 0%%
CONST __UI_Transparent%% = -1%%

'Text alignment
CONST __UI_Left%% = 0%%
CONST __UI_Center%% = 1%%
CONST __UI_Right%% = 2%%
CONST __UI_Top%% = 0%%
CONST __UI_Middle%% = 1%%
CONST __UI_Bottom%% = 2%%

'Textbox controls
CONST __UI_NumericWithoutBounds%% = -1%%
CONST __UI_NumericWithBounds%% = 2%%

'BulletStyle
CONST __UI_CheckMark%% = 0%%
CONST __UI_Bullet%% = 1%%

'General constants
CONST __UI_ToolTipTimeOut! = 0.8!
CONST __UI_CantResizeV%% = 1%%
CONST __UI_CantResizeH%% = 2%%
CONST __UI_CantResize%% = 3%%

'Messagebox constants
CONST MsgBox_OkOnly& = 1&
CONST MsgBox_OkCancel& = 2&
CONST MsgBox_AbortRetryIgnore& = 4&
CONST MsgBox_YesNoCancel& = 8&
CONST MsgBox_YesNo& = 16&
CONST MsgBox_RetryCancel& = 32&
CONST MsgBox_CancelTryAgainContinue& = 64&

CONST MsgBox_Critical& = 128&
CONST MsgBox_Question& = 256&
CONST MsgBox_Exclamation& = 512&
CONST MsgBox_Information& = 1024&

CONST MsgBox_DefaultButton1& = 2048&
CONST MsgBox_DefaultButton2& = 4096&
CONST MsgBox_DefaultButton3& = 8192&
CONST MsgBox_Defaultbutton4& = 16384&

CONST MsgBox_AppModal& = 32768&
CONST MsgBox_SystemModal& = 65536&
CONST MsgBox_SetForeground& = 131072&

CONST MsgBox_Ok& = 1&
CONST MsgBox_Yes& = 2&
CONST MsgBox_No& = 3&
CONST MsgBox_Cancel& = 4&
CONST MsgBox_Abort& = 5&
CONST MsgBox_Retry& = 6&
CONST MsgBox_Ignore& = 7&
CONST MsgBox_TryAgain& = 8&
CONST MsgBox_Continue& = 9&

DECLARE LIBRARY
    FUNCTION __UI_GetPID ALIAS getpid
END DECLARE

DECLARE CUSTOMTYPE LIBRARY
    SUB __UI_MemCopy ALIAS memcpy (BYVAL dest AS _OFFSET, BYVAL source AS _OFFSET, BYVAL bytes AS LONG)
END DECLARE

$IF WIN THEN
    DECLARE LIBRARY
        FUNCTION GetSystemMetrics& (BYVAL WhichMetric&)
    END DECLARE

    CONST __UI_SM_SWAPBUTTON = 23
$END IF

TYPE __UI_ControlTYPE
    ID AS LONG
    ParentID AS LONG
    PreviousParentID AS LONG
    ContextMenuID AS LONG
    Type AS INTEGER
    Name AS STRING * 40
    ParentName AS STRING * 40
    SubMenu AS _BYTE
    MenuPanelID AS LONG
    SourceControl AS LONG
    Top AS INTEGER
    Left AS INTEGER
    Width AS INTEGER
    Height AS INTEGER
    Canvas AS LONG
    HelperCanvas AS LONG
    TransparentColor AS _UNSIGNED LONG
    Stretch AS _BYTE
    PreviousStretch AS _BYTE
    Font AS INTEGER
    PreviousFont AS INTEGER
    BackColor AS _UNSIGNED LONG
    ForeColor AS _UNSIGNED LONG
    SelectedForeColor AS _UNSIGNED LONG
    SelectedBackColor AS _UNSIGNED LONG
    BackStyle AS _BYTE
    HasBorder AS _BYTE
    BorderSize AS INTEGER
    Padding AS INTEGER
    Encoding AS LONG
    Align AS _BYTE
    PrevAlign AS _BYTE
    VAlign AS _BYTE
    PrevVAlign AS _BYTE
    BorderColor AS _UNSIGNED LONG
    Value AS _FLOAT
    PreviousValue AS _FLOAT
    Min AS _FLOAT
    PrevMin AS _FLOAT
    Max AS _FLOAT
    PrevMax AS _FLOAT
    Interval AS _FLOAT
    PrevInterval AS _FLOAT
    MinInterval AS _FLOAT
    PrevMinInterval AS _FLOAT
    HotKey AS INTEGER
    HotKeyOffset AS INTEGER
    HotKeyPosition AS INTEGER
    ShowPercentage AS _BYTE
    AutoScroll AS _BYTE
    AutoSize AS _BYTE
    InputViewStart AS LONG
    PreviousInputViewStart AS LONG
    LastVisibleItem AS INTEGER
    ItemHeight AS INTEGER
    HasVScrollbar AS _BYTE
    VScrollbarButton2Top AS INTEGER
    HoveringVScrollbarButton AS _BYTE
    ThumbHeight AS INTEGER
    ThumbTop AS INTEGER
    VScrollbarRatio AS SINGLE
    Cursor AS LONG
    PasswordField AS _BYTE
    PrevCursor AS LONG
    FieldArea AS LONG
    PreviousFieldArea AS LONG
    TextIsSelected AS _BYTE
    BypassSelectOnFocus AS _BYTE
    Multiline AS _BYTE
    NumericOnly AS _BYTE
    FirstVisibleLine AS LONG
    PrevFirstVisibleLine AS LONG
    CurrentLine AS LONG
    PrevCurrentLine AS LONG
    VisibleCursor AS LONG
    PrevVisibleCursor AS LONG
    ControlIsSelected AS _BYTE
    LeftOffsetFromFirstSelected AS INTEGER
    TopOffsetFromFirstSelected AS INTEGER
    SelectionLength AS LONG
    SelectionStart AS LONG
    WordWrap AS _BYTE
    CanResize AS _BYTE
    CanHaveFocus AS _BYTE
    Disabled AS _BYTE
    Hidden AS _BYTE
    PreviouslyHidden AS _BYTE
    CenteredWindow AS _BYTE
    ControlState AS _BYTE
    ChildrenRedrawn AS _BYTE
    FocusState AS LONG
    LastChange AS SINGLE
    Redraw AS _BYTE
    BulletStyle AS _BYTE
    MenuItemGroup AS INTEGER
    KeyCombo AS LONG
    BoundTo AS LONG
    BoundProperty AS LONG
END TYPE

TYPE __UI_Types
    Name AS STRING * 16
    Count AS LONG
    TurnsInto AS INTEGER
    DefaultHeight AS INTEGER
    MinimumHeight AS INTEGER
    DefaultWidth AS INTEGER
    MinimumWidth AS INTEGER
    RestrictResize AS _BYTE
END TYPE

TYPE __UI_WordWrapHistoryType
    StringSlot AS LONG
    Width AS INTEGER
    LongestLine AS INTEGER
    Font AS LONG
    TotalLines AS INTEGER
END TYPE

TYPE __UI_KeyCombos
    Combo AS STRING * 14 '         "CTRL+SHIFT+F12"
    FriendlyCombo AS STRING * 14 ' "Ctrl+Shift+F12"
    ControlID AS LONG
END TYPE

REDIM SHARED Caption(0 TO 100) AS STRING
REDIM SHARED __UI_TempCaptions(0 TO 100) AS STRING
REDIM SHARED Text(0 TO 100) AS STRING
REDIM SHARED __UI_TempTexts(0 TO 100) AS STRING
REDIM SHARED Mask(0 TO 100) AS STRING
REDIM SHARED __UI_TempMask(0 TO 100) AS STRING
REDIM SHARED ToolTip(0 TO 100) AS STRING
REDIM SHARED __UI_TempTips(0 TO 100) AS STRING
REDIM SHARED Control(0 TO 100) AS __UI_ControlTYPE
REDIM SHARED ControlDrawOrder(0) AS LONG
REDIM __UI_ThemeImages(0 TO 0) AS HashTableType
REDIM SHARED __UI_WordWrapHistoryTexts(0 TO 100) AS STRING
REDIM SHARED __UI_WordWrapHistoryResults(0 TO 100) AS STRING
REDIM SHARED __UI_WordWrapHistory(0 TO 100) AS __UI_WordWrapHistoryType
REDIM SHARED __UI_ThisLineChars(0) AS LONG, __UI_FocusedTextBoxChars(0) AS LONG
REDIM SHARED __UI_ActiveMenu(0 TO 100) AS LONG, __UI_ParentMenu(0 TO 100) AS LONG
REDIM SHARED __UI_KeyCombo(0 TO 100) AS __UI_KeyCombos

DIM SHARED __UI_TotalKeyCombos AS LONG, __UI_BypassKeyCombos AS _BYTE
DIM SHARED table1252$(0 TO 255), table437$(0 TO 255)
DIM SHARED __UI_MouseLeft AS INTEGER, __UI_MouseTop AS INTEGER
DIM SHARED __UI_MouseWheel AS INTEGER, __UI_MouseButtonsSwap AS _BYTE
DIM SHARED __UI_PrevMouseLeft AS INTEGER, __UI_PrevMouseTop AS INTEGER
DIM SHARED __UI_MouseButton1 AS _BYTE, __UI_MouseButton2 AS _BYTE
DIM SHARED __UI_MouseIsDown AS _BYTE, __UI_MouseDownOnID AS LONG
DIM SHARED __UI_Mouse2IsDown AS _BYTE, __UI_Mouse2DownOnID AS LONG
DIM SHARED __UI_PreviousMouseDownOnID AS LONG
DIM SHARED __UI_KeyIsDown AS _BYTE, __UI_KeyDownOnID AS LONG
DIM SHARED __UI_ShiftIsDown AS _BYTE, __UI_CtrlIsDown AS _BYTE
DIM SHARED __UI_AltIsDown AS _BYTE, __UI_ShowHotKeys AS _BYTE, __UI_AltCombo$
DIM SHARED __UI_LastMouseClick AS SINGLE, __UI_MouseDownOnScrollbar AS SINGLE
DIM SHARED __UI_DragX AS INTEGER, __UI_DragY AS INTEGER
DIM SHARED __UI_DefaultButtonID AS LONG
DIM SHARED __UI_KeyHit AS LONG, __UI_KeepFocus AS _BYTE
DIM SHARED __UI_Focus AS LONG, __UI_PreviousFocus AS LONG, __UI_KeyboardFocus AS _BYTE
DIM SHARED __UI_HoveringID AS LONG, __UI_LastHoveringID AS LONG, __UI_BelowHoveringID AS LONG
DIM SHARED __UI_IsDragging AS _BYTE, __UI_DraggingID AS LONG
DIM SHARED __UI_IsResizing AS _BYTE, __UI_ResizingID AS LONG
DIM SHARED __UI_ResizeHandleHover AS _BYTE
DIM SHARED __UI_IsSelectingText AS _BYTE, __UI_IsSelectingTextOnID AS LONG
DIM SHARED __UI_SelectedText AS STRING, __UI_SelectionLength AS LONG
DIM SHARED __UI_StateHasChanged AS _BYTE
DIM SHARED __UI_DraggingThumb AS _BYTE, __UI_ThumbDragTop AS INTEGER
DIM SHARED __UI_DraggingThumbOnID AS LONG
DIM SHARED __UI_HasInput AS _BYTE, __UI_ProcessInputTimer AS SINGLE
DIM SHARED __UI_UnloadSignal AS _BYTE, __UI_HasResized AS _BYTE
DIM SHARED __UI_ExitTriggered AS _BYTE
DIM SHARED __UI_Loaded AS _BYTE
DIM SHARED __UI_EventsTimer AS INTEGER, __UI_RefreshTimer AS INTEGER
DIM SHARED __UI_ActiveDropdownList AS LONG, __UI_ParentDropdownList AS LONG
DIM SHARED __UI_TotalActiveMenus AS LONG, __UI_ActiveMenuIsContextMenu AS _BYTE
DIM SHARED __UI_SubMenuDelay AS SINGLE, __UI_HoveringSubMenu AS _BYTE
DIM SHARED __UI_TopMenuBarItem AS LONG
DIM SHARED __UI_ActiveTipID AS LONG, __UI_TipTimer AS SINGLE, __UI_PreviousTipID AS LONG
DIM SHARED __UI_ActiveTipTop AS INTEGER, __UI_ActiveTipLeft AS INTEGER
DIM SHARED __UI_FormID AS LONG, __UI_HasMenuBar AS LONG
DIM SHARED __UI_ScrollbarWidth AS INTEGER, __UI_ScrollbarButtonHeight AS INTEGER
DIM SHARED __UI_MenuBarOffset AS INTEGER, __UI_MenuItemOffset AS INTEGER
DIM SHARED __UI_NewMenuBarTextLeft AS INTEGER, __UI_DefaultCaptionIndent AS INTEGER
DIM SHARED __UI_ForceRedraw AS _BYTE, __UI_AutoRefresh AS _BYTE
DIM SHARED __UI_CurrentTitle AS STRING
DIM SHARED __UI_DesignMode AS _BYTE, __UI_FirstSelectedID AS LONG
DIM SHARED __UI_WaitMessage AS STRING, __UI_TotalSelectedControls AS LONG
DIM SHARED __UI_WaitMessageHandle AS LONG, __UI_EditorMode AS _BYTE
DIM SHARED __UI_LastRenderedCharCount AS LONG
DIM SHARED __UI_SelectionRectangleTop AS INTEGER, __UI_SelectionRectangleLeft AS INTEGER
DIM SHARED __UI_SelectionRectangle AS _BYTE
DIM SHARED __UI_CantShowContextMenu AS _BYTE, __UI_ShowPositionAndSize AS _BYTE
DIM SHARED __UI_ShowInvisibleControls AS _BYTE, __UI_Snapped AS _BYTE
DIM SHARED __UI_SnappedByProximityX AS _BYTE, __UI_SnappedByProximityY AS _BYTE
DIM SHARED __UI_SnappedX AS INTEGER, __UI_SnappedY AS INTEGER
DIM SHARED __UI_SnappedXID AS LONG, __UI_SnappedYID AS LONG
DIM SHARED __UI_SnapLines AS _BYTE, __UI_SnapDistance AS INTEGER, __UI_SnapDistanceFromForm AS INTEGER
DIM SHARED __UI_FrameRate AS SINGLE, __UI_Font8Offset AS INTEGER, __UI_Font16Offset AS INTEGER
DIM SHARED __UI_ClipboardCheck$, __UI_MenuBarOffsetV AS INTEGER
DIM SHARED __UI_KeepScreenHidden AS _BYTE, __UI_MaxBorderSize AS INTEGER
DIM SHARED __UI_InternalContextMenus AS LONG, __UI_DidClick AS _BYTE
DIM SHARED __UI_ContextMenuSourceID AS LONG
DIM SHARED __UI_FKey(1 TO 12) AS LONG

DIM SHARED __UI_Type(0 TO 18) AS __UI_Types
