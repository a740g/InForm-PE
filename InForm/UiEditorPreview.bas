'-----------------------------------------------------------------------------------------------------------------------
' InForm-PE GUI engine for QB64-PE
' Copyright (c) 2025 Samuel Gomes
' Copyright (c) 2023 George McGinn
' Copyright (c) 2022 Fellippe Heitor
'-----------------------------------------------------------------------------------------------------------------------

OPTION _EXPLICIT

DIM SHARED UiEditorPID AS LONG, ExeIcon AS LONG
DIM SHARED AutoNameControls AS _BYTE
DIM SHARED UndoPointer AS INTEGER, TotalUndoImages AS INTEGER
REDIM SHARED UndoImage(100) AS STRING
DIM SHARED IsCreating AS _BYTE
DIM SHARED Host AS LONG, HostPort AS STRING
DIM SHARED Stream$, RestoreCrashData$
DIM SHARED LastPreviewDataSent$
DIM SHARED ContextMenuIcon AS LONG
REDIM SHARED LockedControls(0) AS LONG, TotalLockedControls AS LONG
REDIM SHARED AutoPlayGif(0) AS _BYTE

REDIM SHARED QB64KEYWORDS(0) AS STRING
READ_KEYWORDS

CHDIR ".."

CONST EMPTY_FORM = "SW5Gb3JtAcgAAAD//3cAAAABAAUARm9ybTEsASwBAAAAAAAA/v8FAAAARm9ybTH7/2EAc2Vnb2V1aS50dGY/YXJpYWwudHRmPy9MaWJyYXJ5L0ZvbnRzL0FyaWFsLnR0Zj9JbkZvcm0vcmVzb3VyY2VzL05vdG9Nb25vLVJlZ3VsYXIudHRmP2NvdXIudHRmKioxMgD8"

'Signals sent from Editor to Preview:
'   201 = Align Left
'   202 = Align Right
'   203 = Align Tops
'   204 = Align Bottoms
'   205 = Align Centers Vertically
'   206 = Align Centers Horizontally
'   207 = Align Center Vertically (to form)
'   208 = Align Center Horizontally (to form)
'   209 = Align Distribute Vertically
'   210 = Align Distribute Horizontally
'   211 = Move control up (z-ordering)
'   212 = Move control down (z-ordering)
'   213 = Select specific control
'   214 = Undo
'   215 = Redo
'   216 = Save state for undo
'   217 = Copy selected controls to clipboard
'   218 = Paste selected controls from clipboard
'   219 = Cut to clipboard
'   220 = Delete selected controls
'   221 = Select all controls
'   222 = Add new textbox with the .NumericOnly property set to true
'   223 = Switch .NumericOnly between True/__UI_NumericWithBounds
'   224 = Add new MenuBar control
'   225 = Convert control type to alternative type
'   226 = Add new ContextMenu control
'   227 = Toggle __UI_ShowInvisibleControls
'   228 = Bind/Unbind selected controls

'SavePreview parameters:
CONST InDisk = 1
CONST InClipboard = 2
CONST ToEditor = 3
CONST ToUndoBuffer = 4
CONST FromEditor = 5

DECLARE LIBRARY
    FUNCTION Numeric& ALIAS isdigit (BYVAL ch AS LONG)
END DECLARE

$IF WIN THEN
    DECLARE DYNAMIC LIBRARY "kernel32"
        FUNCTION OpenProcess& (BYVAL dwDesiredAccess AS LONG, BYVAL bInheritHandle AS LONG, BYVAL dwProcessId AS LONG)
        FUNCTION CloseHandle& (BYVAL hObject AS LONG)
        FUNCTION GetExitCodeProcess& (BYVAL hProcess AS LONG, lpExitCode AS LONG)
    END DECLARE
    CONST PathSep$ = "\"
$ELSE
    DECLARE LIBRARY
        FUNCTION PROCESS_CLOSED& ALIAS kill (BYVAL pid AS INTEGER, BYVAL signal AS INTEGER)
    END DECLARE
    CONST PathSep$ = "/"
$END IF

CONST EDITOR_IMAGE_CONTEXTMENU = 1

'Load context menu icon image:
ContextMenuIcon = LoadEditorImage(EDITOR_IMAGE_CONTEXTMENU)
__UI_ClearColor ContextMenuIcon, 0, 0

'$INCLUDE:'extensions/GIFPlay.bi'
'$INCLUDE:'InForm.bi'
'$INCLUDE:'UiEditorPreview.frm'
'$INCLUDE:'InForm.ui'
'$INCLUDE:'extensions/GIFPlay.bas'

'Event procedures: ---------------------------------------------------------------
SUB __UI_Click (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

FUNCTION AddNewMenuBarControl&
    DIM i AS LONG, TempValue AS LONG

    'Before adding a menu bar item, reset all other menu bar items' alignment
    FOR i = 1 TO UBOUND(Control)
        IF Control(i).Type = __UI_Type_MenuBar THEN
            Control(i).Align = __UI_Left
        END IF
    NEXT
    TempValue = __UI_NewControl(__UI_Type_MenuBar, "", 0, 0, 0, 0, 0)
    SetCaption TempValue, RTRIM$(Control(TempValue).Name)
    __UI_RefreshMenuBar
    __UI_ActivateMenu Control(TempValue), False
    AddNewMenuBarControl& = TempValue
END FUNCTION

SUB SelectNewControl (id AS LONG)
    DIM i AS LONG
    FOR i = 1 TO UBOUND(Control)
        Control(i).ControlIsSelected = False
    NEXT
    Control(id).ControlIsSelected = True
    __UI_TotalSelectedControls = 1
    __UI_FirstSelectedID = id
    __UI_ForceRedraw = True
END SUB

SUB __UI_BeforeUpdateDisplay
    DIM a$, b$, TempValue AS LONG, i AS LONG, j AS LONG
    DIM FileNameToLoad$
    $IF WIN THEN
        STATIC EditorWasActive AS _BYTE
    $END IF
    STATIC WasDragging AS _BYTE, WasResizing AS _BYTE
    STATIC NewWindowTop AS INTEGER, NewWindowLeft AS INTEGER

    IF __UI_TotalSelectedControls < 0 THEN __UI_TotalSelectedControls = 0

    SavePreview ToEditor

    IF UBOUND(LockedControls) <> UBOUND(Control) THEN
        REDIM _PRESERVE LockedControls(UBOUND(Control)) AS LONG
    END IF

    IF UBOUND(AutoPlayGif) <> UBOUND(Control) THEN
        REDIM _PRESERVE AutoPlayGif(UBOUND(Control)) AS _BYTE
    END IF

    FOR i = 1 TO UBOUND(AutoPlayGif)
        IF AutoPlayGif(i) AND GIF_IsLoaded(i) THEN GIF_Draw i
    NEXT

    STATIC prevDefaultButton AS LONG, prevMenuPanelActive AS INTEGER
    STATIC prevSelectionRectangle AS INTEGER, prevUndoPointer AS INTEGER
    STATIC prevTotalUndoImages AS INTEGER, prevShowInvisibleControls AS _BYTE

    IF __UI_DefaultButtonID <> prevDefaultButton THEN
        prevDefaultButton = __UI_DefaultButtonID
        b$ = MKL$(__UI_DefaultButtonID)
        SendData b$, "DEFAULTBUTTONID"
    END IF

    IF prevShowInvisibleControls <> __UI_ShowInvisibleControls THEN
        prevShowInvisibleControls = __UI_ShowInvisibleControls
        b$ = MKI$(__UI_ShowInvisibleControls)
        SendData b$, "SHOWINVISIBLECONTROLS"
    END IF

    IF prevMenuPanelActive <> (__UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) <> "__UI_") THEN
        prevMenuPanelActive = (__UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) <> "__UI_")
        b$ = MKI$(prevMenuPanelActive)
        SendData b$, "MENUPANELACTIVE"
    END IF

    IF prevSelectionRectangle <> (__UI_SelectionRectangle) THEN
        prevSelectionRectangle = (__UI_SelectionRectangle)
        b$ = MKI$(prevSelectionRectangle)
        SendData b$, "SELECTIONRECTANGLE"
    END IF

    IF prevUndoPointer <> UndoPointer THEN
        prevUndoPointer = UndoPointer
        b$ = MKI$(UndoPointer)
        SendData b$, "UNDOPOINTER"
    END IF

    IF prevTotalUndoImages <> TotalUndoImages THEN
        prevTotalUndoImages = TotalUndoImages
        b$ = MKI$(TotalUndoImages)
        SendData b$, "TOTALUNDOIMAGES"
    END IF

    DIM incomingData$, Signal$, Property$

    GET #Host, , incomingData$
    Stream$ = Stream$ + incomingData$

    DIM ThisContainer AS LONG, TempWidth AS INTEGER, TempHeight AS INTEGER
    DIM TempTop AS INTEGER
    IF Control(Control(__UI_FirstSelectedID).ParentID).Type = __UI_Type_Frame THEN
        ThisContainer = Control(__UI_FirstSelectedID).ParentID
        TempWidth = Control(Control(__UI_FirstSelectedID).ParentID).Width
        TempHeight = Control(Control(__UI_FirstSelectedID).ParentID).Height
        TempTop = TempHeight \ 2
    ELSEIF Control(__UI_FirstSelectedID).Type = __UI_Type_Frame THEN
        ThisContainer = Control(__UI_FirstSelectedID).ID
        TempWidth = Control(__UI_FirstSelectedID).Width
        TempHeight = Control(__UI_FirstSelectedID).Height
        TempTop = TempHeight \ 2
    ELSE
        TempWidth = Control(__UI_FormID).Width
        TempHeight = Control(__UI_FormID).Height
        TempTop = (TempHeight - __UI_MenuBarOffsetV) \ 2 + __UI_MenuBarOffsetV
    END IF

    DIM thisData$, thisCommand$
    DO WHILE INSTR(Stream$, "<END>") > 0
        thisData$ = LEFT$(Stream$, INSTR(Stream$, "<END>") - 1)
        Stream$ = MID$(Stream$, INSTR(Stream$, "<END>") + 5)
        thisCommand$ = LEFT$(thisData$, INSTR(thisData$, ">") - 1)
        thisData$ = MID$(thisData$, LEN(thisCommand$) + 2)
        SELECT CASE UCASE$(thisCommand$)
            CASE "RESTORECRASH"
                RestoreCrashData$ = thisData$
                LoadPreview FromEditor
                EXIT SUB
            CASE "WINDOWPOSITION"
                NewWindowLeft = CVI(LEFT$(thisData$, 2))
                NewWindowTop = CVI(MID$(thisData$, 3, 2))
            CASE "AUTONAME"
                AutoNameControls = CVI(thisData$)
            CASE "MOUSESWAP"
                __UI_MouseButtonsSwap = CVI(thisData$)
            CASE "SHOWPOSSIZE"
                __UI_ShowPositionAndSize = CVI(thisData$)
            CASE "SHOWINVISIBLECONTROLS"
                __UI_ShowInvisibleControls = CVI(thisData$)
            CASE "SNAPLINES"
                __UI_SnapLines = CVI(thisData$)
            CASE "SIGNAL"
                Signal$ = Signal$ + thisData$
            CASE "PROPERTY"
                Property$ = Property$ + thisData$
            CASE "OPENFILE"
                FileNameToLoad$ = thisData$
            CASE "NEWCONTROL"
                TempValue = CVI(thisData$)

                IF TempValue > 0 THEN
                    DIM defW AS INTEGER, defH AS INTEGER
                    DIM tempType AS LONG
                    defW = __UI_Type(TempValue).DefaultWidth
                    defH = __UI_Type(TempValue).DefaultHeight
                    tempType = TempValue
                    SaveUndoImage

                    'Enforce no frame inside frame:
                    IF tempType = __UI_Type_Frame THEN
                        ThisContainer = 0
                        TempWidth = Control(__UI_FormID).Width
                        TempHeight = Control(__UI_FormID).Height
                        TempTop = (TempHeight - __UI_MenuBarOffsetV) \ 2 + __UI_MenuBarOffsetV
                    END IF

                    IF tempType = __UI_Type_MenuBar THEN
                        TempValue = AddNewMenuBarControl
                    ELSEIF tempType = __UI_Type_MenuItem THEN
                        IF __UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) <> "__UI_" THEN
                            TempValue = __UI_NewControl(tempType, "", 0, 0, 0, 0, __UI_ParentMenu(__UI_TotalActiveMenus))
                            SetCaption TempValue, RTRIM$(Control(TempValue).Name)
                            ThisContainer = __UI_ParentMenu(__UI_TotalActiveMenus)
                            __UI_CloseAllMenus
                            __UI_ActivateMenu Control(ThisContainer), False
                        END IF
                    ELSE
                        TempValue = __UI_NewControl(TempValue, "", defW, defH, TempWidth \ 2 - defW \ 2, TempTop - defH \ 2, ThisContainer)
                        SetCaption TempValue, RTRIM$(Control(TempValue).Name)
                    END IF

                    SELECT CASE tempType
                        CASE __UI_Type_ProgressBar
                            SetCaption TempValue, "\#"
                        CASE __UI_Type_ContextMenu
                            Control(TempValue).HelperCanvas = _COPYIMAGE(ContextMenuIcon, 32)
                            RefreshContextMenus
                            __UI_ActivateMenu Control(TempValue), False
                    END SELECT

                    IF __UI_TotalActiveMenus > 0 AND (Control(TempValue).Type <> __UI_Type_ContextMenu AND Control(TempValue).Type <> __UI_Type_MenuBar AND Control(TempValue).Type <> __UI_Type_MenuItem) THEN
                        __UI_CloseAllMenus
                    END IF
                    SelectNewControl TempValue
                END IF
            CASE "LOCKCONTROLS"
                'When the user starts editing a property in UiEditor,
                'a list of the currently selected controls is built so
                'that the property can be applied to the same controls
                'later; allows for"
                '    "click control, change property, click another control"
                TotalLockedControls = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        TotalLockedControls = TotalLockedControls + 1
                        LockedControls(TotalLockedControls) = i
                    END IF
                NEXT
            CASE "PAUSEALLGIF"
                FOR i = 1 TO UBOUND(Control)
                    IF AutoPlayGif(i) THEN
                        AutoPlayGif(i) = False
                        GIF_Stop i
                    END IF
                NEXT
            CASE "BINDCONTROLS"
                DIM BindInfo$(1 TO 4)

                FOR i = 1 TO 4
                    TempValue = CVL(LEFT$(thisData$, 4))
                    thisData$ = MID$(thisData$, 5)
                    BindInfo$(i) = LEFT$(thisData$, TempValue)
                    thisData$ = MID$(thisData$, TempValue + 1)
                NEXT

                __UI_Bind __UI_GetID(BindInfo$(1)), __UI_GetID(BindInfo$(2)), BindInfo$(3), BindInfo$(4)
            CASE "UNBINDCONTROLS"
                __UI_UnBind __UI_GetID(thisData$)
        END SELECT
    LOOP

    FOR i = 1 TO _TOTALDROPPEDFILES
        DIM tempImage&
        tempImage& = _LOADIMAGE(_DROPPEDFILE(i), 32)
        IF tempImage& < -1 THEN
            defW = _WIDTH(tempImage&)
            defH = _HEIGHT(tempImage&)
            _FREEIMAGE tempImage&
            tempType = __UI_Type_PictureBox

            SaveUndoImage

            TempValue = __UI_NewControl(tempType, "", defW, defH, _MOUSEX - defW \ 2, _MOUSEY - defH \ 2, ThisContainer)
            IF ThisContainer > 0 THEN
                Control(TempValue).Left = 0
                Control(TempValue).Top = 0
            END IF

            IF __UI_TotalActiveMenus > 0 THEN
                __UI_CloseAllMenus
            END IF
            SelectNewControl TempValue

            PreviewLoadImage Control(TempValue), _DROPPEDFILE(i)

            b$ = MID$(_DROPPEDFILE(i), _INSTRREV(_DROPPEDFILE(i), PathSep$) + 1)
            SWAP i, TempValue
            GOSUB AutoName
            SWAP i, TempValue
        END IF
        IF i = _TOTALDROPPEDFILES THEN _FINISHDROP
    NEXT

    $IF WIN THEN
        IF NewWindowLeft <> -32001 AND NewWindowTop <> -32001 AND (NewWindowLeft <> _SCREENX OR NewWindowTop <> _SCREENY) THEN
            _SCREENMOVE NewWindowLeft + 612, NewWindowTop
        END IF
    $END IF

    'Check if the editor is still alive
    $IF WIN THEN
        DIM hnd&, b&, ExitCode&
        hnd& = OpenProcess(&H400, 0, UiEditorPID)
        b& = GetExitCodeProcess(hnd&, ExitCode&)
        IF b& = 1 AND ExitCode& = 259 THEN
            'Editor is active.
            EditorWasActive = True
        ELSE
            'Editor was closed.
            IF EditorWasActive = False THEN
                'Preview was launched by user
                _SCREENHIDE
                MessageBox "__UI_BeforeUpdateDisplay: InForm Designer is not running. Please run the main program.", _TITLE$, MsgBox_Critical
            END IF
            IF _FILEEXISTS("InForm/UiEditorPreview.frmbin") THEN KILL "InForm/UiEditorPreview.frmbin"
            SYSTEM
        END IF
        b& = CloseHandle(hnd&)
    $ELSE
        IF PROCESS_CLOSED(UiEditorPID, 0) THEN
            IF _FILEEXISTS("InForm/UiEditorPreview.frmbin") THEN KILL "InForm/UiEditorPreview.frmbin"
            SYSTEM
        END IF
    $END IF

    IF __UI_IsDragging THEN
        IF NOT WasDragging THEN
            WasDragging = True
        END IF
    ELSE
        IF WasDragging THEN
            SaveUndoImage
            WasDragging = False
        END IF
    END IF

    IF __UI_IsResizing THEN
        IF NOT WasResizing THEN
            WasResizing = True
        END IF
    ELSE
        IF WasResizing THEN
            SaveUndoImage
            WasResizing = False
        END IF
    END IF

    STATIC prevImgWidthSent AS INTEGER, prevImgHeightSent AS INTEGER
    STATIC prevTurnsInto AS INTEGER
    IF __UI_FirstSelectedID > 0 THEN
        IF Control(__UI_FirstSelectedID).Type = __UI_Type_PictureBox AND LEN(Text(__UI_FirstSelectedID)) > 0 THEN
            IF prevImgWidthSent <> _WIDTH(Control(__UI_FirstSelectedID).HelperCanvas) OR _
               prevImgHeightSent <> _HEIGHT(Control(__UI_FirstSelectedID).HelperCanvas) THEN
                prevImgWidthSent = _WIDTH(Control(__UI_FirstSelectedID).HelperCanvas)
                prevImgHeightSent = _HEIGHT(Control(__UI_FirstSelectedID).HelperCanvas)
                b$ = MKI$(_WIDTH(Control(__UI_FirstSelectedID).HelperCanvas))
                SendData b$, "ORIGINALIMAGEWIDTH"

                b$ = MKI$(_HEIGHT(Control(__UI_FirstSelectedID).HelperCanvas))
                SendData b$, "ORIGINALIMAGEHEIGHT"
            END IF
        ELSE
            IF prevImgWidthSent <> 0 OR _
               prevImgHeightSent <> 0 THEN
                prevImgWidthSent = 0
                prevImgHeightSent = 0
                b$ = MKI$(0)
                SendData b$, "ORIGINALIMAGEWIDTH"
                SendData b$, "ORIGINALIMAGEHEIGHT"
            END IF
        END IF

        IF __UI_TotalSelectedControls = 1 THEN
            IF prevTurnsInto <> __UI_Type(Control(__UI_FirstSelectedID).Type).TurnsInto OR Control(__UI_FirstSelectedID).Type = __UI_Type_TextBox THEN
                prevTurnsInto = __UI_Type(Control(__UI_FirstSelectedID).Type).TurnsInto
                IF Control(__UI_FirstSelectedID).Type = __UI_Type_TextBox THEN
                    'Offer to turn text to numeric-only TextBox and vice-versa
                    IF Control(__UI_FirstSelectedID).NumericOnly = False THEN
                        prevTurnsInto = -1
                    ELSE
                        prevTurnsInto = -2
                    END IF
                END IF
                b$ = MKI$(prevTurnsInto)
                SendData b$, "TURNSINTO"
            END IF

            IF __UI_DesignMode = True AND __UI_ShowInvisibleControls = True THEN
                'Check if this control has a ContextMenu attached to it
                'and indicate that
                IF Control(__UI_FirstSelectedID).Type = __UI_Type_ContextMenu THEN
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).Type = __UI_Type_ContextMenu THEN
                            IF __UI_FirstSelectedID = Control(i).ID THEN
                                Control(i).ControlState = 2
                            ELSE
                                Control(i).ControlState = 1
                            END IF
                            Control(i).Redraw = True
                        END IF
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).Type = __UI_Type_ContextMenu THEN
                            IF Control(__UI_FirstSelectedID).ContextMenuID = Control(i).ID THEN
                                Control(i).ControlState = 2
                            ELSE
                                Control(i).ControlState = 1
                            END IF
                            Control(i).Redraw = True
                        END IF
                    NEXT
                END IF
            END IF
        ELSEIF __UI_TotalSelectedControls > 1 THEN
            DIM SearchType AS INTEGER, AllControlsTurnInto AS _BYTE
            SearchType = Control(__UI_FirstSelectedID).Type
            AllControlsTurnInto = True
            FOR i = 1 TO UBOUND(Control)
                IF Control(i).ControlIsSelected THEN
                    IF SearchType = __UI_Type_TextBox THEN
                        IF Control(i).NumericOnly <> Control(__UI_FirstSelectedID).NumericOnly THEN
                            AllControlsTurnInto = False
                            EXIT FOR
                        END IF
                    ELSE
                        IF Control(i).Type <> SearchType THEN
                            AllControlsTurnInto = False
                            EXIT FOR
                        END IF
                    END IF
                END IF
            NEXT
            SearchType = __UI_Type(SearchType).TurnsInto
            IF SearchType = 0 AND Control(__UI_FirstSelectedID).Type = __UI_Type_TextBox THEN
                IF Control(__UI_FirstSelectedID).NumericOnly = False THEN
                    SearchType = -1
                ELSE
                    SearchType = -2
                END IF
            END IF
            IF NOT AllControlsTurnInto THEN SearchType = 0
            IF prevTurnsInto <> SearchType THEN
                prevTurnsInto = SearchType
                b$ = MKI$(prevTurnsInto)
                SendData b$, "TURNSINTO"
            END IF

            IF __UI_DesignMode = True AND __UI_ShowInvisibleControls = True THEN
                'Check if all selected controls have the same ContextMenu
                'attached to them and indicate that
                DIM SelectionContextMenu AS LONG, AllControlsHaveTheSameContextMenu AS _BYTE
                AllControlsHaveTheSameContextMenu = True
                SelectionContextMenu = Control(__UI_FirstSelectedID).ContextMenuID
                IF SelectionContextMenu > 0 THEN
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            IF Control(i).ContextMenuID <> SelectionContextMenu THEN
                                AllControlsHaveTheSameContextMenu = False
                                EXIT FOR
                            END IF
                        END IF
                    NEXT
                ELSE
                    AllControlsHaveTheSameContextMenu = False
                END IF

                IF AllControlsHaveTheSameContextMenu THEN
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).Type = __UI_Type_ContextMenu THEN
                            IF SelectionContextMenu = Control(i).ID THEN
                                Control(i).ControlState = 2
                            ELSE
                                Control(i).ControlState = 1
                            END IF
                            Control(i).Redraw = True
                        END IF
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).Type = __UI_Type_ContextMenu THEN
                            Control(i).ControlState = 1
                            Control(i).Redraw = True
                        END IF
                    NEXT
                END IF
            END IF
        END IF
    ELSE
        FOR i = 1 TO UBOUND(Control)
            IF Control(i).Type = __UI_Type_ContextMenu THEN
                Control(i).ControlState = 1 'normal state
                Control(i).Redraw = True
            END IF
        NEXT
    END IF

    DO WHILE LEN(Signal$)
        b$ = LEFT$(Signal$, 2)
        Signal$ = MID$(Signal$, 3)
        TempValue = CVI(b$)
        IF TempValue = -2 THEN
            'Hide the preview
            _SCREENHIDE
        ELSEIF TempValue = -3 THEN
            'Show the preview
            _SCREENSHOW
        ELSEIF TempValue = -4 THEN
            'Load an existing file
            IsCreating = True
            DIM FileToLoad AS INTEGER
            FileToLoad = FREEFILE
            OPEN FileNameToLoad$ FOR BINARY AS #FileToLoad
            a$ = SPACE$(LOF(FileToLoad))
            GET #FileToLoad, 1, a$
            CLOSE #FileToLoad

            FileToLoad = FREEFILE
            OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #FileToLoad
            PUT #FileToLoad, 1, a$
            CLOSE #FileToLoad

            __UI_DefaultButtonID = 0
            _SCREENSHOW
            IF INSTR(a$, "SUB __UI_LoadForm") > 0 THEN
                LoadPreviewText
            ELSE
                LoadPreview InDisk
            END IF
            UndoPointer = 0
            TotalUndoImages = 0
            SendSignal -7 'Form just loaded
        ELSEIF TempValue = -5 THEN
            'Reset request (new form)
            IsCreating = True
            a$ = _BASE64DECODE$(EMPTY_FORM)

            FileToLoad = FREEFILE
            OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #FileToLoad
            PUT #FileToLoad, 1, a$
            CLOSE #FileToLoad

            LoadPreview InDisk
            LoadDefaultFonts

            LastPreviewDataSent$ = ""
            UndoPointer = 0
            TotalUndoImages = 0
            __UI_DefaultButtonID = 0
            _ICON
            SendSignal -7 'New form created
        ELSEIF TempValue = -6 THEN
            'Set current button as default
            IF __UI_DefaultButtonID = __UI_FirstSelectedID THEN
                __UI_DefaultButtonID = 0
            ELSE
                __UI_DefaultButtonID = __UI_FirstSelectedID
            END IF
        ELSEIF TempValue = -7 THEN
            __UI_RestoreImageOriginalSize
        ELSEIF TempValue = -8 THEN
            'Editor is manipulated, preview menus must be closed.
            IF __UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) = "__UI_" THEN
                __UI_CloseAllMenus
            END IF
        ELSEIF TempValue = 214 THEN
            RestoreUndoImage
        ELSEIF TempValue = 215 THEN
            RestoreRedoImage
        END IF
    LOOP

    DIM PropertyApplied AS _BYTE, LockedControlsGOSUB AS _BYTE
    PropertyApplied = False
    IF TotalLockedControls THEN LockedControlsGOSUB = True ELSE LockedControlsGOSUB = False
    DO WHILE LEN(Property$)
        DIM FloatValue AS _FLOAT, temp$, temp2$
        'Editor sent property value
        b$ = ReadSequential$(Property$, 2)
        TempValue = CVI(b$)
        SaveUndoImage
        PropertyApplied = True
        SELECT CASE TempValue
            CASE 1 'Name
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))
                IF TotalLockedControls = 1 THEN
                    temp$ = AdaptName$(b$, LockedControls(1))
                    temp2$ = RTRIM$(Control(LockedControls(1)).Name) + CHR$(10) + temp$
                    SendData temp2$, "CONTROLRENAMED"
                    Control(LockedControls(1)).Name = temp$
                ELSE
                    IF __UI_TotalSelectedControls = 1 THEN
                        temp$ = AdaptName$(b$, __UI_FirstSelectedID)
                        temp2$ = RTRIM$(Control(__UI_FirstSelectedID).Name) + CHR$(10) + temp$
                        SendData temp2$, "CONTROLRENAMED"
                        Control(__UI_FirstSelectedID).Name = temp$
                    ELSEIF __UI_TotalSelectedControls = 0 THEN
                        temp$ = AdaptName$(b$, __UI_FormID)
                        temp2$ = RTRIM$(Control(__UI_FormID).Name) + CHR$(10) + temp$
                        SendData temp2$, "CONTROLRENAMED"
                        Control(__UI_FormID).Name = temp$
                    END IF
                END IF
            CASE 2 'Caption
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeCaption
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                ChangeCaption:
                                IF Control(i).Type = __UI_Type_Label THEN
                                    DIM TotalReplacements AS LONG
                                    b$ = Replace(b$, "\n", CHR$(10), False, TotalReplacements)
                                END IF
                                SetCaption i, b$
                                IF Control(i).Type = __UI_Type_Label THEN AutoSizeLabel Control(i)
                                IF LEN(b$) > 0 AND b$ <> "&" THEN GOSUB AutoName
                                IF Control(i).Type = __UI_Type_MenuItem THEN
                                    __UI_ActivateMenu Control(Control(i).ParentID), False
                                END IF
                                IF LockedControlsGOSUB THEN RETURN
                            END IF
                        NEXT
                    ELSE
                        Caption(__UI_FormID) = b$
                        i = __UI_FormID
                        IF LEN(b$) > 0 AND b$ <> "&" THEN GOSUB AutoName
                    END IF
                END IF

                GOTO SkipAutoName

                AutoName:
                IF AutoNameControls THEN
                    DIM NewName$

                    NewName$ = RTRIM$(b$)

                    IF Control(i).Type = __UI_Type_MenuBar THEN
                        IF LEN(NewName$) > 36 THEN NewName$ = LEFT$(NewName$, 36)
                    ELSEIF Control(i).Type <> __UI_Type_Form AND Control(i).Type <> __UI_Type_MenuItem AND Control(i).Type <> __UI_Type_ListBox AND Control(i).Type <> __UI_Type_TrackBar AND Control(i).Type <> __UI_Type_DropdownList THEN
                        IF LEN(NewName$) > 38 THEN NewName$ = LEFT$(NewName$, 38)
                    END IF
                    SELECT CASE Control(i).Type
                        CASE __UI_Type_Button: NewName$ = NewName$ + "BT"
                        CASE __UI_Type_Label: NewName$ = NewName$ + "LB"
                        CASE __UI_Type_CheckBox: NewName$ = NewName$ + "CB"
                        CASE __UI_Type_RadioButton: NewName$ = NewName$ + "RB"
                        CASE __UI_Type_TextBox: NewName$ = NewName$ + "TB"
                        CASE __UI_Type_ProgressBar: NewName$ = NewName$ + "PB"
                        CASE __UI_Type_MenuBar: NewName$ = NewName$ + "Menu"
                        CASE __UI_Type_MenuItem
                            NewName$ = RTRIM$(Control(Control(i).ParentID).Name) + NewName$
                        CASE __UI_Type_PictureBox: NewName$ = NewName$ + "PX"
                    END SELECT

                    temp$ = AdaptName$(NewName$, i)
                    temp2$ = RTRIM$(Control(i).Name) + CHR$(10) + temp$
                    SendData temp2$, "CONTROLRENAMED"
                    Control(i).Name = temp$
                END IF
                RETURN

                SkipAutoName:
            CASE 3 'Text
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeText
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                ChangeText:
                                Text(i) = b$
                                IF Control(i).Type = __UI_Type_TextBox AND Control(i).NumericOnly THEN
                                    Text(i) = b$
                                    Control(i).Value = VAL(b$)
                                ELSEIF Control(i).Type = __UI_Type_TextBox AND Control(i).Max > 0 THEN
                                    Text(i) = LEFT$(b$, Control(i).Max)
                                END IF
                                IF Control(i).Type = __UI_Type_Button OR Control(i).Type = __UI_Type_MenuItem THEN
                                    LoadImage Control(i), b$
                                ELSEIF Control(i).Type = __UI_Type_PictureBox THEN
                                    PreviewLoadImage Control(i), b$
                                    IF LEN(Text(i)) > 0 THEN 'Load successful
                                        'Keep aspect ratio at load
                                        Control(i).Height = (_HEIGHT(Control(i).HelperCanvas) / _WIDTH(Control(i).HelperCanvas)) * Control(i).Width
                                        IF LEN(b$) > 0 AND b$ <> "&" THEN GOSUB AutoName
                                    END IF
                                ELSEIF Control(i).Type = __UI_Type_ListBox OR Control(i).Type = __UI_Type_DropdownList THEN
                                    Text(i) = Replace(b$, "\n", CHR$(10), False, TotalReplacements)
                                    IF Control(i).Max < TotalReplacements + 1 THEN Control(i).Max = TotalReplacements + 1
                                    Control(i).LastVisibleItem = 0 'Reset it so it's recalculated
                                END IF
                                IF LockedControlsGOSUB THEN RETURN
                            END IF
                        NEXT
                    ELSE
                        IF ExeIcon <> 0 THEN _FREEIMAGE ExeIcon: ExeIcon = 0
                        ExeIcon = IconPreview&(b$)
                        IF ExeIcon < -1 THEN
                            _ICON ExeIcon
                            Text(__UI_FormID) = b$
                        ELSE
                            _ICON
                            IF _FILEEXISTS(b$) THEN
                                IF LCASE$(RIGHT$(b$, 4)) <> ".ico" THEN
                                    SendSignal -6
                                    Text(__UI_FormID) = ""
                                ELSE
                                    SendSignal -4
                                    Text(__UI_FormID) = b$
                                END IF
                            ELSE
                                Text(__UI_FormID) = ""
                            END IF
                        END IF
                    END IF
                END IF
            CASE 4 'Top
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls > 0 THEN
                    FOR i = 1 TO TotalLockedControls
                        Control(LockedControls(i)).Top = TempValue
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Top = TempValue
                        END IF
                    NEXT
                END IF
            CASE 5 'Left
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls > 0 THEN
                    FOR i = 1 TO TotalLockedControls
                        Control(LockedControls(i)).Left = TempValue
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Left = TempValue
                        END IF
                    NEXT
                END IF
            CASE 6 'Width
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TempValue < 1 THEN TempValue = 1
                IF TotalLockedControls > 0 THEN
                    FOR i = 1 TO TotalLockedControls
                        IF __UI_Type(Control(LockedControls(i)).Type).RestrictResize <> __UI_CantResizeH AND _
                           __UI_Type(Control(LockedControls(i)).Type).RestrictResize <> __UI_CantResize THEN
                            Control(LockedControls(i)).Width = TempValue
                        END IF
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                IF __UI_Type(Control(i).Type).RestrictResize <> __UI_CantResizeH AND _
                                   __UI_Type(Control(i).Type).RestrictResize <> __UI_CantResize THEN
                                    Control(i).Width = TempValue
                                END IF
                            END IF
                        NEXT
                    ELSE
                        IF TempValue < 20 THEN TempValue = 20
                        Control(__UI_FormID).Width = TempValue
                    END IF
                END IF
            CASE 7 'Height
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TempValue < 1 THEN TempValue = 1
                IF TotalLockedControls > 0 THEN
                    FOR i = 1 TO TotalLockedControls
                        IF __UI_Type(Control(LockedControls(i)).Type).RestrictResize <> __UI_CantResizeV AND _
                           __UI_Type(Control(LockedControls(i)).Type).RestrictResize <> __UI_CantResize THEN
                            Control(LockedControls(i)).Height = TempValue
                        END IF
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                IF __UI_Type(Control(i).Type).RestrictResize <> __UI_CantResizeV AND _
                                   __UI_Type(Control(i).Type).RestrictResize <> __UI_CantResize THEN
                                    Control(i).Height = TempValue
                                END IF
                            END IF
                        NEXT
                    ELSE
                        IF TempValue < 20 THEN TempValue = 20
                        Control(__UI_FormID).Height = TempValue
                    END IF
                END IF
            CASE 8 'Font
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))
                DIM NewFontFile AS STRING
                DIM NewFontSize AS INTEGER
                DIM FindSep AS INTEGER, TotalSep AS INTEGER

                'Parse b$ into Font data
                FindSep = INSTR(b$, ",")
                IF FindSep THEN TotalSep = TotalSep + 1
                NewFontFile = LEFT$(b$, FindSep - 1)
                b$ = MID$(b$, FindSep + 1)

                NewFontSize = VAL(b$)

                IF TotalSep = 1 AND NewFontSize > 0 THEN
                    IF TotalLockedControls THEN
                        FOR j = 1 TO TotalLockedControls
                            i = LockedControls(j)
                            GOSUB ChangeFont
                        NEXT
                    ELSE
                        IF __UI_TotalSelectedControls > 0 THEN
                            FOR i = 1 TO UBOUND(Control)
                                IF Control(i).ControlIsSelected THEN
                                    ChangeFont:
                                    Control(i).Font = SetFont(NewFontFile, NewFontSize)
                                    DIM tempFont AS LONG
                                    tempFont = _FONT
                                    _FONT Control(i).Font
                                    SELECT CASE Control(i).Type
                                        CASE __UI_Type_Label
                                            IF Control(i).WordWrap = False THEN
                                                Control(i).Height = uspacing + 6 + (ABS(Control(i).HasBorder) * Control(i).BorderSize)
                                                AutoSizeLabel Control(i)
                                            END IF
                                        CASE __UI_Type_TextBox
                                            IF Control(i).Multiline = False THEN
                                                Control(i).Height = uspacing + 6 + (ABS(Control(i).HasBorder) * Control(i).BorderSize)
                                            END IF
                                        CASE __UI_Type_CheckBox, __UI_Type_RadioButton
                                            Control(i).Height = uspacing + 6
                                        CASE __UI_Type_ProgressBar
                                            IF INSTR(Caption(i), CHR$(10)) = 0 THEN
                                                Control(i).Height = uspacing + 6
                                            END IF
                                    END SELECT
                                    IF Control(i).HotKey > 0 THEN
                                        IF Control(i).HotKeyPosition = 1 THEN
                                            Control(i).HotKeyOffset = 0
                                        ELSE
                                            Control(i).HotKeyOffset = __UI_PrintWidth(LEFT$(Caption(i), Control(i).HotKeyPosition - 1))
                                        END IF
                                    END IF
                                    _FONT tempFont
                                    IF LockedControlsGOSUB THEN RETURN
                                END IF
                            NEXT
                        ELSE
                            Control(__UI_FormID).Font = SetFont(NewFontFile, NewFontSize)
                            DIM MustRedrawMenus AS _BYTE
                            FOR i = 1 TO UBOUND(Control)
                                IF Control(i).Type = __UI_Type_MenuBar OR Control(i).Type = __UI_Type_MenuItem OR Control(i).Type = __UI_Type_MenuPanel OR Control(i).Type = __UI_Type_ContextMenu THEN
                                    Control(i).Font = SetFont(NewFontFile, NewFontSize)
                                    MustRedrawMenus = True
                                END IF
                            NEXT
                            IF MustRedrawMenus THEN __UI_RefreshMenuBar
                        END IF
                    END IF
                END IF
            CASE 9 'Tooltip
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))

                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeTooltip
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeTooltip:
                            ToolTip(i) = Replace(b$, "\n", CHR$(10), False, 0)
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 10 'Value
                b$ = ReadSequential$(Property$, LEN(FloatValue))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeValue
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeValue:
                            IF Control(i).Type = __UI_Type_CheckBox OR (Control(i).Type = __UI_Type_MenuItem AND Control(i).BulletStyle = __UI_CheckMark) OR Control(i).Type = __UI_Type_ToggleSwitch THEN
                                IF _CV(_FLOAT, b$) <> 0 THEN
                                    Control(i).Value = True
                                ELSE
                                    Control(i).Value = False
                                END IF
                            ELSEIF Control(i).Type = __UI_Type_RadioButton OR (Control(i).Type = __UI_Type_MenuItem AND Control(i).BulletStyle = __UI_Bullet) THEN
                                IF _CV(_FLOAT, b$) <> 0 THEN
                                    SetRadioButtonValue i
                                ELSE
                                    Control(i).Value = False
                                END IF
                            ELSE
                                Control(i).Value = _CV(_FLOAT, b$)
                            END IF
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 11 'Min
                b$ = ReadSequential$(Property$, LEN(FloatValue))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).Min = _CV(_FLOAT, b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Min = _CV(_FLOAT, b$)
                        END IF
                    NEXT
                END IF
            CASE 12 'Max
                b$ = ReadSequential$(Property$, LEN(FloatValue))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeMax
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeMax:
                            Control(i).Max = _CV(_FLOAT, b$)
                            IF Control(i).Type = __UI_Type_TextBox THEN
                                Text(i) = LEFT$(Text(i), INT(Control(i).Max))
                                IF LEN(Mask(i)) > 0 THEN Mask(i) = ""
                            END IF
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 13 'Interval
                b$ = ReadSequential$(Property$, LEN(FloatValue))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).Interval = _CV(_FLOAT, b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Interval = _CV(_FLOAT, b$)
                        END IF
                    NEXT
                END IF
            CASE 14 'Stretch
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).Stretch = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Stretch = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 15 'Has border
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).HasBorder = CVI(b$)
                        IF CVI(b$) THEN
                            IF Control(LockedControls(j)).BorderSize = 0 THEN
                                Control(LockedControls(j)).BorderSize = 1
                            END IF
                        END IF
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).HasBorder = CVI(b$)
                            IF CVI(b$) THEN
                                IF Control(i).BorderSize = 0 THEN
                                    Control(i).BorderSize = 1
                                END IF
                            END IF
                        END IF
                    NEXT
                END IF
            CASE 16 'Show percentage
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).ShowPercentage = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).ShowPercentage = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 17 'Word wrap
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).WordWrap = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).WordWrap = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 18 'Can have focus
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).CanHaveFocus = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).CanHaveFocus = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 19 'Disabled
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).Disabled = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Disabled = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 20 'Hidden
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeHidden
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeHidden:
                            Control(i).Hidden = CVI(b$)
                            IF Control(i).Type = __UI_Type_MenuItem AND __UI_ParentMenu(__UI_TotalActiveMenus) = Control(i).ParentID THEN
                                __UI_ActivateMenu Control(Control(i).ParentID), False
                            END IF
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 21 'CenteredWindow - Form only
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls = 0 AND __UI_TotalSelectedControls = 0 THEN
                    Control(__UI_FormID).CenteredWindow = TempValue
                END IF
            CASE 22 'Alignment
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeAlignment
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeAlignment:
                            Control(i).Align = CVI(b$)
                            IF Control(i).Type = __UI_Type_MenuBar THEN
                                IF Control(i).Align <> __UI_Left THEN Control(i).Align = __UI_Right
                                IF __UI_TotalActiveMenus > 0 THEN __UI_CloseAllMenus
                                __UI_RefreshMenuBar
                            END IF
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 23 'ForeColor
                b$ = ReadSequential$(Property$, 4)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).ForeColor = _CV(_UNSIGNED LONG, b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).ForeColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).ForeColor = _CV(_UNSIGNED LONG, b$)
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).Type = __UI_Type_MenuBar THEN
                                Control(i).ForeColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    END IF
                END IF
            CASE 24 'BackColor
                b$ = ReadSequential$(Property$, 4)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).BackColor = _CV(_UNSIGNED LONG, b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).BackColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).BackColor = _CV(_UNSIGNED LONG, b$)
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).Type = __UI_Type_MenuBar THEN
                                Control(i).BackColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    END IF
                END IF
            CASE 25 'SelectedForeColor
                b$ = ReadSequential$(Property$, 4)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).SelectedForeColor = _CV(_UNSIGNED LONG, b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).SelectedForeColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).SelectedForeColor = _CV(_UNSIGNED LONG, b$)
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).Type = __UI_Type_MenuBar OR Control(i).Type = __UI_Type_MenuItem OR Control(i).Type = __UI_Type_MenuPanel OR Control(i).Type = __UI_Type_ContextMenu THEN
                                Control(i).SelectedForeColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    END IF
                END IF
            CASE 26 'SelectedBackColor
                b$ = ReadSequential$(Property$, 4)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).SelectedBackColor = _CV(_UNSIGNED LONG, b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).SelectedBackColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).SelectedBackColor = _CV(_UNSIGNED LONG, b$)
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).Type = __UI_Type_MenuBar OR Control(i).Type = __UI_Type_MenuItem OR Control(i).Type = __UI_Type_MenuPanel OR Control(i).Type = __UI_Type_ContextMenu THEN
                                Control(i).SelectedBackColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    END IF
                END IF
            CASE 27 'BorderColor
                b$ = ReadSequential$(Property$, 4)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).BorderColor = _CV(_UNSIGNED LONG, b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).BorderColor = _CV(_UNSIGNED LONG, b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).BorderColor = _CV(_UNSIGNED LONG, b$)
                    END IF
                END IF
            CASE 28 'BackStyle
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).BackStyle = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).BackStyle = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 29 'CanResize - Form only
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls = 0 AND __UI_TotalSelectedControls = 0 THEN
                    Control(__UI_FormID).CanResize = TempValue
                END IF
            CASE 31 'Padding
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).Padding = TempValue
                    NEXT
                ELSEIF __UI_TotalSelectedControls > 0 THEN
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).Padding = TempValue
                        END IF
                    NEXT
                END IF
            CASE 32 'Vertical Alignment
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).VAlign = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).VAlign = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 33 'Password field
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).PasswordField = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).PasswordField = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 34 'Encoding - Form only
                b$ = ReadSequential$(Property$, 4)
                Control(__UI_FormID).Encoding = CVL(b$)
            CASE 35 'Mask
                b$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, CVL(b$))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        GOSUB ChangeMask
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            ChangeMask:
                            Mask(i) = b$
                            Text(i) = ""
                            IF LEN(Mask(i)) THEN Control(i).Max = 0
                            IF LockedControlsGOSUB THEN RETURN
                        END IF
                    NEXT
                END IF
            CASE 36 'MinInterval
                b$ = ReadSequential$(Property$, LEN(FloatValue))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).MinInterval = _CV(_FLOAT, b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).MinInterval = _CV(_FLOAT, b$)
                        END IF
                    NEXT
                END IF
            CASE 37 'BulletStyle
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).BulletStyle = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).BulletStyle = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 38 'AutoScroll
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).AutoScroll = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).AutoScroll = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 39 'AutoSize
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        Control(LockedControls(j)).AutoSize = CVI(b$)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            Control(i).AutoSize = CVI(b$)
                        END IF
                    NEXT
                END IF
            CASE 40 'BorderSize
                b$ = ReadSequential$(Property$, 2)
                TempValue = CVI(b$)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        IF Control(LockedControls(j)).Type <> __UI_Type_Frame THEN
                            Control(LockedControls(j)).BorderSize = TempValue
                            IF Control(LockedControls(j)).Type = __UI_Type_TextBox THEN
                                tempFont = _FONT
                                _FONT Control(LockedControls(j)).Font
                                IF Control(LockedControls(j)).Multiline = False THEN Control(LockedControls(j)).Height = uspacing + 6 + (ABS(Control(LockedControls(j)).HasBorder) * Control(LockedControls(j)).BorderSize)
                                _FONT tempFont
                            END IF
                        END IF
                    NEXT
                ELSEIF __UI_TotalSelectedControls > 0 THEN
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            IF Control(i).Type <> __UI_Type_Frame THEN
                                Control(i).BorderSize = TempValue
                                IF Control(i).Type = __UI_Type_TextBox THEN
                                    tempFont = _FONT
                                    _FONT Control(i).Font
                                    IF Control(i).Multiline = False THEN Control(i).Height = uspacing + 6 + (ABS(Control(i).HasBorder) * Control(i).BorderSize)
                                    _FONT tempFont
                                END IF
                            END IF
                        END IF
                    NEXT
                END IF
            CASE 41 'ContextMenuID
                b$ = ReadSequential$(Property$, 2)
                b$ = ReadSequential$(Property$, CVI(b$))
                Control(__UI_GetID(b$)).ControlState = 2 'highlight ContextMenu handle
                Control(__UI_GetID(b$)).Redraw = True 'highlight ContextMenu handle
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = LockedControls(j)
                        Control(i).ContextMenuID = __UI_GetID(b$)
                    NEXT
                ELSE
                    IF __UI_TotalSelectedControls > 0 THEN
                        FOR i = 1 TO UBOUND(Control)
                            IF Control(i).ControlIsSelected THEN
                                Control(i).ContextMenuID = __UI_GetID(b$)
                            END IF
                        NEXT
                    ELSE
                        Control(__UI_FormID).ContextMenuID = __UI_GetID(b$)
                    END IF
                END IF
            CASE 42 'HideTicks
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        IF CVI(b$) THEN
                            Control(LockedControls(j)).Height = __UI_Type(__UI_Type_TrackBar).MinimumHeight
                        ELSE
                            Control(LockedControls(j)).Height = __UI_Type(__UI_Type_TrackBar).DefaultHeight
                        END IF
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            IF CVI(b$) THEN
                                Control(i).Height = __UI_Type(__UI_Type_TrackBar).MinimumHeight
                            ELSE
                                Control(i).Height = __UI_Type(__UI_Type_TrackBar).DefaultHeight
                            END IF
                        END IF
                    NEXT
                END IF
            CASE 43 'Key combo
                b$ = ReadSequential$(Property$, 2)
                b$ = ReadSequential$(Property$, CVI(b$))
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        i = RegisterKeyCombo(b$, LockedControls(j))
                        IF Control(LockedControls(j)).Type = __UI_Type_MenuItem THEN
                            __UI_ActivateMenu Control(Control(LockedControls(j)).ParentID), False
                            EXIT FOR
                        END IF
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            j = RegisterKeyCombo(b$, Control(i).ID)
                            IF Control(i).Type = __UI_Type_MenuItem THEN
                                __UI_ActivateMenu Control(Control(i).ParentID), False
                                EXIT FOR
                            END IF
                        END IF
                    NEXT
                END IF
            CASE 44 'Auto-play (GIF extension)
                b$ = ReadSequential$(Property$, 2)
                IF TotalLockedControls THEN
                    FOR j = 1 TO TotalLockedControls
                        AutoPlayGif(LockedControls(j)) = CVI(b$)
                        IF AutoPlayGif(LockedControls(j)) THEN GIF_Play LockedControls(j) ELSE GIF_Stop LockedControls(j)
                    NEXT
                ELSE
                    FOR i = 1 TO UBOUND(Control)
                        IF Control(i).ControlIsSelected THEN
                            AutoPlayGif(i) = CVI(b$)
                            IF AutoPlayGif(i) THEN GIF_Play i ELSE GIF_Stop i
                        END IF
                    NEXT
                END IF
            CASE 201 TO 210
                'Alignment commands
                b$ = ReadSequential$(Property$, 2)
                DoAlign TempValue
            CASE 211, 212 'Z-Ordering -> Move up/down
                DIM tID1 AS LONG, tID2 AS LONG
                a$ = ReadSequential$(Property$, 4)
                b$ = ReadSequential$(Property$, 4)
                tID1 = Control(CVL(a$)).ID
                tID2 = Control(CVL(b$)).ID
                SWAP Control(CVL(b$)), Control(CVL(a$))
                SWAP Caption(CVL(b$)), Caption(CVL(a$))
                SWAP Text(CVL(b$)), Text(CVL(a$))
                SWAP ToolTip(CVL(b$)), ToolTip(CVL(a$))
                Control(CVL(a$)).ID = tID1
                Control(CVL(b$)).ID = tID2

                'Restore ParentIDs based on ParentName
                FOR i = 1 TO UBOUND(Control)
                    Control(i).ParentID = __UI_GetID(Control(i).ParentName)
                NEXT

                IF __UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) <> "__UI_" THEN
                    IF Control(CVL(a$)).Type = __UI_Type_MenuItem THEN
                        __UI_ActivateMenu Control(Control(CVL(a$)).ParentID), False
                    ELSEIF Control(CVL(b$)).Type = __UI_Type_MenuItem THEN
                        __UI_ActivateMenu Control(Control(CVL(b$)).ParentID), False
                    ELSE
                        __UI_CloseAllMenus
                    END IF
                END IF
            CASE 213
                'Select control
                b$ = ReadSequential$(Property$, 4)

                'Desselect all first:
                FOR i = 1 TO UBOUND(Control)
                    Control(i).ControlIsSelected = False
                NEXT

                IF CVL(b$) > 0 THEN Control(CVL(b$)).ControlIsSelected = True
            CASE 216 TO 221
                __UI_KeyPress TempValue
            CASE 222 'New textbox control with the NumericOnly property set to true
                b$ = ReadSequential$(Property$, 2)
                TempValue = __UI_NewControl(__UI_Type_TextBox, "", 120, 23, TempWidth \ 2 - 60, TempTop - 12, ThisContainer)
                Control(TempValue).Name = "Numeric" + Control(TempValue).Name
                SetCaption TempValue, RTRIM$(Control(TempValue).Name)
                Control(TempValue).NumericOnly = __UI_NumericWithBounds
                Control(TempValue).Min = -32768
                Control(TempValue).Max = 32767

                IF __UI_TotalActiveMenus > 0 THEN
                    __UI_CloseAllMenus
                END IF

                FOR i = 1 TO UBOUND(Control)
                    Control(i).ControlIsSelected = False
                NEXT
                Control(TempValue).ControlIsSelected = True
                __UI_TotalSelectedControls = 1
                __UI_FirstSelectedID = TempValue
                __UI_ForceRedraw = True
            CASE 223
                b$ = ReadSequential$(Property$, 2)
                AlternateNumericOnlyProperty
            CASE 225
                ConvertControlToAlternativeType
        END SELECT
        __UI_ForceRedraw = True
    LOOP
    IF PropertyApplied THEN TotalLockedControls = 0

    IF __UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) = "__UI_" AND __UI_CantShowContextMenu THEN
        __UI_CloseAllMenus
        b$ = "SIGNAL>" + MKI$(-2) + "<END>" 'Signal to the editor that the preview can't show the context menu
        PUT #Host, , b$
    ELSEIF __UI_TotalActiveMenus > 0 AND LEFT$(Control(__UI_ParentMenu(__UI_TotalActiveMenus)).Name, 5) = "__UI_" THEN
        STATIC LocalMenuShown AS _BYTE, LocalMenuShownSignalSent AS _BYTE
        LocalMenuShown = True
    ELSE
        LocalMenuShown = False
        LocalMenuShownSignalSent = False
    END IF

    IF LocalMenuShown AND NOT LocalMenuShownSignalSent THEN
        b$ = "SIGNAL>" + MKI$(-5) + "<END>" 'Signal to the editor that a context menu is successfully shown
        PUT #Host, , b$
        LocalMenuShownSignalSent = True
    END IF

    STATIC prevTotalSelected AS LONG, prevFirstSelected AS LONG
    STATIC prevFormID AS LONG

    IF __UI_TotalSelectedControls <> prevTotalSelected THEN
        prevTotalSelected = __UI_TotalSelectedControls
        b$ = "TOTALSELECTEDCONTROLS>" + MKL$(__UI_TotalSelectedControls) + "<END>"
        PUT #Host, , b$
    END IF

    IF Control(__UI_FirstSelectedID).ID = 0 THEN __UI_FirstSelectedID = 0
    IF __UI_FirstSelectedID <> prevFirstSelected THEN
        prevFirstSelected = __UI_FirstSelectedID
        b$ = "FIRSTSELECTED>" + MKL$(__UI_FirstSelectedID) + "<END>"
        PUT #Host, , b$
    END IF

    IF __UI_FormID <> prevFormID THEN
        prevFormID = __UI_FormID
        b$ = "FORMID>" + MKL$(__UI_FormID) + "<END>"
        PUT #Host, , b$
    END IF
END SUB

SUB __UI_BeforeUnload
    __UI_UnloadSignal = False
    SendSignal -9
END SUB

SUB __UI_BeforeInit
    __UI_DesignMode = True

    IF _FILEEXISTS("InForm/UiEditorPreview.frmbin") THEN
        DIM FileToLoad AS INTEGER, a$
        FileToLoad = FREEFILE
        OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #FileToLoad
        a$ = SPACE$(LOF(FileToLoad))
        GET #FileToLoad, 1, a$
        CLOSE #FileToLoad

        IF INSTR(a$, "SUB __UI_LoadForm") > 0 THEN
            LoadPreviewText
        ELSE
            LoadPreview InDisk
        END IF
    END IF
END SUB

SUB __UI_FormResized
    STATIC TimesResized AS INTEGER

    IF IsCreating THEN TimesResized = 0: IsCreating = False

    TimesResized = TimesResized + 1

    IF TimesResized > 5 THEN
        'Manually resizing a form triggers this event a few times;
        'Loading a form triggers it 2 or three times usually.
        TimesResized = 0
        SendSignal -8
    END IF
END SUB

SUB __UI_OnLoad
    DIM b$, start!
    LoadDefaultFonts

    b$ = "Connecting to InForm Designer..."
    GOSUB ShowMessage

    HostPort = COMMAND$(1)
    IF VAL(HostPort) < 60000 THEN
        ForceQuit:
        _SCREENHIDE
        MessageBox "__UI_OnLoad: InForm Designer is not running. Please run the main program.", _TITLE$, MsgBox_Critical
        SYSTEM
    END IF

    $IF WIN THEN
        CONST TIMEOUT = 10
    $ELSE
        CONST TIMEOUT = 120
    $END IF

    start! = TIMER
    DO
        Host = _OPENCLIENT("TCP/IP:" + HostPort + ":localhost")
        _DISPLAY
    LOOP UNTIL Host < 0 OR TIMER - start! > TIMEOUT

    IF Host = 0 THEN GOTO ForceQuit

    b$ = "Connected! Handshaking..."
    GOSUB ShowMessage

    'Handshake: each module sends the other their PID:
    DIM incomingData$, thisData$
    start! = TIMER
    DO
        incomingData$ = ""
        GET #Host, , incomingData$
        Stream$ = Stream$ + incomingData$
        IF INSTR(Stream$, "<END>") THEN
            thisData$ = LEFT$(Stream$, INSTR(Stream$, "<END>") - 1)
            Stream$ = MID$(Stream$, LEN(thisData$) + 6)
            IF LEFT$(thisData$, 10) = "EDITORPID>" THEN
                UiEditorPID = CVL(MID$(thisData$, 11))
            END IF
            EXIT DO
        END IF
    LOOP UNTIL TIMER - start! > TIMEOUT

    IF UiEditorPID = 0 THEN GOTO ForceQuit

    b$ = "PREVIEWPID>" + MKL$(__UI_GetPID) + "<END>"
    PUT #Host, , b$

    _ACCEPTFILEDROP

    EXIT SUB
    ShowMessage:
    DIM PreserveDestMessage AS LONG
    PreserveDestMessage = _DEST
    _DEST 0
    _FONT Control(__UI_FormID).Font
    CLS , __UI_DefaultColor(__UI_Type_Form, 2)
    COLOR __UI_DefaultColor(__UI_Type_Form, 1), _RGBA32(0, 0, 0, 0)
    __UI_PrintString _WIDTH \ 2 - _PRINTWIDTH(b$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2, b$
    _DISPLAY
    _DEST PreserveDestMessage
    RETURN
END SUB

SUB __UI_KeyPress (id AS LONG)
    SELECT CASE id
        CASE 201 TO 210
            DoAlign id
        CASE 214
            RestoreUndoImage
        CASE 215
            RestoreRedoImage
        CASE 216
            SaveUndoImage
        CASE 217 'Copy selected controls to clipboard
            SavePreview InClipboard
        CASE 218 'Restore selected controls from clipboard
            LoadPreview InClipboard
        CASE 219 'Cut selected controls to clipboard
            SavePreview InClipboard
            DeleteSelectedControls
        CASE 220 'Delete selected controls
            DeleteSelectedControls
        CASE 221 'Select all controls
            SelectAllControls
        CASE 223
            AlternateNumericOnlyProperty
        CASE 224
            DIM TempValue AS LONG
            TempValue = AddNewMenuBarControl
            SelectNewControl TempValue
        CASE 225
            ConvertControlToAlternativeType
        CASE 226 'Add new ContextMenu control
            TempValue = __UI_NewControl(__UI_Type_ContextMenu, "", 22, 22, 0, 0, 0)
            Control(TempValue).HelperCanvas = _COPYIMAGE(ContextMenuIcon, 32)
            RefreshContextMenus
            __UI_ActivateMenu Control(TempValue), False
            SelectNewControl TempValue
        CASE 227 'Toggle __UI_ShowInvisibleControls
            __UI_ShowInvisibleControls = NOT __UI_ShowInvisibleControls
        CASE 228 'Bind/unbind controls
            'DIM a$, b$, c$, found AS _BYTE
            'DIM i AS LONG, j AS LONG
            'FOR i = 1 TO UBOUND(Control)
            '    IF Control(i).ControlIsSelected THEN
            '        j = j + 1
            '        IF j = 1 THEN
            '            found = __UI_PropertyEnum(a$, Control(i).BoundProperty)
            '            IF __UI_TotalSelectedControls = 1 THEN EXIT FOR
            '        ELSEIF j = 2 THEN
            '            found = __UI_PropertyEnum(b$, Control(i).BoundProperty)
            '            EXIT FOR
            '        END IF
            '    END IF
            'NEXT
            'c$ = MKL$(LEN(a$)) + a$ + MKL$(LEN(b$)) + b$
            SendData "", "SHOWBINDCONTROLDIALOG"
    END SELECT
END SUB

SUB AlternateNumericOnlyProperty
    IF Control(__UI_FirstSelectedID).NumericOnly = True THEN
        Control(__UI_FirstSelectedID).NumericOnly = __UI_NumericWithBounds
        IF VAL(Text(__UI_FirstSelectedID)) > Control(__UI_FirstSelectedID).Max THEN
            Text(__UI_FirstSelectedID) = LTRIM$(STR$(Control(__UI_FirstSelectedID).Max))
        ELSEIF VAL(Text(__UI_FirstSelectedID)) < Control(__UI_FirstSelectedID).Min THEN
            Text(__UI_FirstSelectedID) = LTRIM$(STR$(Control(__UI_FirstSelectedID).Min))
        END IF
    ELSEIF Control(__UI_FirstSelectedID).NumericOnly = __UI_NumericWithBounds THEN
        Control(__UI_FirstSelectedID).NumericOnly = True
    END IF
END SUB

SUB DoAlign (AlignMode AS INTEGER)
    DIM i AS LONG
    DIM LeftMost AS INTEGER
    DIM RightMost AS INTEGER
    DIM TopMost AS INTEGER, BottomMost AS INTEGER, SelectionHeight AS INTEGER
    DIM TopDifference AS INTEGER, NewTopMost AS INTEGER
    DIM SelectionWidth AS INTEGER
    DIM LeftDifference AS INTEGER, NewLeftMost AS INTEGER
    DIM FindTops AS INTEGER
    DIM FindLefts AS INTEGER, NextControlToDistribute AS LONG
    DIM TotalSpace AS INTEGER, BinSize AS INTEGER

    SELECT CASE AlignMode
        CASE 201 'Lefts
            IF __UI_TotalSelectedControls > 1 THEN
                LeftMost = Control(__UI_FormID).Width
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Left < LeftMost THEN LeftMost = Control(i).Left
                    END IF
                NEXT
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Left = LeftMost
                    END IF
                NEXT
            END IF
        CASE 202 'Rights
            IF __UI_TotalSelectedControls > 1 THEN
                RightMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Left + Control(i).Width - 1 > RightMost THEN RightMost = Control(i).Left + Control(i).Width - 1
                    END IF
                NEXT
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Left = RightMost - (Control(i).Width - 1)
                    END IF
                NEXT
            END IF
        CASE 203 'Tops
            IF __UI_TotalSelectedControls > 1 THEN
                TopMost = Control(__UI_FormID).Height
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Top < TopMost THEN TopMost = Control(i).Top
                    END IF
                NEXT
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Top = TopMost
                    END IF
                NEXT
            END IF
        CASE 204 'Bottoms
            IF __UI_TotalSelectedControls > 1 THEN
                BottomMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Top + Control(i).Height - 1 > BottomMost THEN BottomMost = Control(i).Top + Control(i).Height - 1
                    END IF
                NEXT
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Top = BottomMost - (Control(i).Height - 1)
                    END IF
                NEXT
            END IF
        CASE 205 'Centers vertically
            IF __UI_TotalSelectedControls > 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    TopMost = Control(__UI_FormID).Height
                ELSE
                    TopMost = Control(Control(__UI_FirstSelectedID).ParentID).Height
                END IF
                BottomMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Top < TopMost THEN TopMost = Control(i).Top
                        IF Control(i).Top + Control(i).Height - 1 > BottomMost THEN BottomMost = Control(i).Top + Control(i).Height - 1
                    END IF
                NEXT
                SelectionHeight = BottomMost - TopMost
                NewTopMost = TopMost + SelectionHeight / 2
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Top = NewTopMost - Control(i).Height / 2
                    END IF
                NEXT
            END IF
        CASE 206 'Centers horizontally
            IF __UI_TotalSelectedControls > 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    LeftMost = Control(__UI_FormID).Width
                ELSE
                    LeftMost = Control(Control(__UI_FirstSelectedID).ParentID).Width
                END IF
                RightMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Left < LeftMost THEN LeftMost = Control(i).Left
                        IF Control(i).Left + Control(i).Width - 1 > RightMost THEN RightMost = Control(i).Left + Control(i).Width - 1
                    END IF
                NEXT
                SelectionWidth = RightMost - LeftMost
                NewLeftMost = LeftMost + SelectionWidth / 2
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Left = NewLeftMost - Control(i).Width / 2
                    END IF
                NEXT
            END IF
        CASE 207 'Center vertically to form
            IF __UI_TotalSelectedControls = 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    Control(__UI_FirstSelectedID).Top = (Control(__UI_FormID).Height - __UI_MenuBarOffsetV) / 2 - Control(__UI_FirstSelectedID).Height / 2 + __UI_MenuBarOffsetV
                ELSE
                    Control(__UI_FirstSelectedID).Top = Control(Control(__UI_FirstSelectedID).ParentID).Height / 2 - Control(__UI_FirstSelectedID).Height / 2
                END IF
            ELSEIF __UI_TotalSelectedControls > 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    TopMost = Control(__UI_FormID).Height
                ELSE
                    TopMost = Control(Control(__UI_FirstSelectedID).ParentID).Height
                END IF
                BottomMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Top < TopMost THEN TopMost = Control(i).Top
                        IF Control(i).Top + Control(i).Height - 1 > BottomMost THEN BottomMost = Control(i).Top + Control(i).Height - 1
                    END IF
                NEXT
                SelectionHeight = BottomMost - TopMost
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    NewTopMost = (Control(__UI_FormID).Height - __UI_MenuBarOffsetV) / 2 - SelectionHeight / 2
                ELSE
                    NewTopMost = Control(Control(__UI_FirstSelectedID).ParentID).Height / 2 - SelectionHeight / 2
                END IF
                TopDifference = TopMost - NewTopMost
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Top = Control(i).Top - TopDifference + __UI_MenuBarOffsetV
                    END IF
                NEXT
            END IF
        CASE 208 'Center horizontally to form
            IF __UI_TotalSelectedControls = 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    Control(__UI_FirstSelectedID).Left = Control(__UI_FormID).Width / 2 - Control(__UI_FirstSelectedID).Width / 2
                ELSE
                    Control(__UI_FirstSelectedID).Left = Control(Control(__UI_FirstSelectedID).ParentID).Width / 2 - Control(__UI_FirstSelectedID).Width / 2
                END IF
            ELSEIF __UI_TotalSelectedControls > 1 THEN
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    LeftMost = Control(__UI_FormID).Width
                ELSE
                    LeftMost = Control(Control(__UI_FirstSelectedID).ParentID).Width
                END IF
                RightMost = 0
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        IF Control(i).Left < LeftMost THEN LeftMost = Control(i).Left
                        IF Control(i).Left + Control(i).Width - 1 > RightMost THEN RightMost = Control(i).Left + Control(i).Width - 1
                    END IF
                NEXT
                SelectionWidth = RightMost - LeftMost
                IF Control(__UI_FirstSelectedID).ParentID = 0 THEN
                    NewLeftMost = Control(__UI_FormID).Width / 2 - SelectionWidth / 2
                ELSE
                    NewLeftMost = Control(Control(__UI_FirstSelectedID).ParentID).Width / 2 - SelectionWidth / 2
                END IF
                LeftDifference = LeftMost - NewLeftMost
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected THEN
                        Control(i).Left = Control(i).Left - LeftDifference
                    END IF
                NEXT
            END IF
        CASE 209 'Distribute vertically
            'Build a sublist containing the selected controls in the order they
            'are currently placed vertically:

            REDIM SubList(1 TO __UI_TotalSelectedControls) AS LONG
            __UI_AutoRefresh = False
            FOR FindTops = 0 TO Control(__UI_FormID).Height - 1
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected AND Control(i).Top = FindTops THEN
                        IF NextControlToDistribute > 0 THEN
                            IF SubList(NextControlToDistribute) <> i THEN
                                NextControlToDistribute = NextControlToDistribute + 1
                                SubList(NextControlToDistribute) = i
                                EXIT FOR
                            END IF
                        ELSE
                            NextControlToDistribute = NextControlToDistribute + 1
                            SubList(NextControlToDistribute) = i
                            EXIT FOR
                        END IF
                    END IF
                NEXT
                IF NextControlToDistribute = __UI_TotalSelectedControls THEN EXIT FOR
            NEXT

            TotalSpace = (Control(SubList(__UI_TotalSelectedControls)).Top + Control(SubList(__UI_TotalSelectedControls)).Height) - Control(SubList(1)).Top
            FOR i = 1 TO __UI_TotalSelectedControls
                TotalSpace = TotalSpace - Control(SubList(i)).Height
            NEXT

            BinSize = TotalSpace \ (__UI_TotalSelectedControls - 1)
            FindTops = Control(SubList(1)).Top - BinSize
            FOR i = 1 TO __UI_TotalSelectedControls
                FindTops = FindTops + BinSize
                Control(SubList(i)).Top = FindTops
                FindTops = FindTops + Control(SubList(i)).Height
            NEXT

            __UI_AutoRefresh = True
            __UI_ForceRedraw = True
        CASE 210 'Distribute horizontally
            'Build a sublist containing the selected controls in the order they
            'are currently placed horizontally:

            REDIM SubList(1 TO __UI_TotalSelectedControls) AS LONG
            __UI_AutoRefresh = False
            FOR FindLefts = 0 TO Control(__UI_FormID).Width - 1
                FOR i = 1 TO UBOUND(Control)
                    IF Control(i).ControlIsSelected AND Control(i).Left = FindLefts THEN
                        IF NextControlToDistribute > 0 THEN
                            IF SubList(NextControlToDistribute) <> i THEN
                                NextControlToDistribute = NextControlToDistribute + 1
                                SubList(NextControlToDistribute) = i
                                EXIT FOR
                            END IF
                        ELSE
                            NextControlToDistribute = NextControlToDistribute + 1
                            SubList(NextControlToDistribute) = i
                            EXIT FOR
                        END IF
                    END IF
                NEXT
                IF NextControlToDistribute = __UI_TotalSelectedControls THEN EXIT FOR
            NEXT

            TotalSpace = (Control(SubList(__UI_TotalSelectedControls)).Left + Control(SubList(__UI_TotalSelectedControls)).Width) - Control(SubList(1)).Left
            FOR i = 1 TO __UI_TotalSelectedControls
                TotalSpace = TotalSpace - Control(SubList(i)).Width
            NEXT

            BinSize = TotalSpace \ (__UI_TotalSelectedControls - 1)
            FindLefts = Control(SubList(1)).Left - BinSize
            FOR i = 1 TO __UI_TotalSelectedControls
                FindLefts = FindLefts + BinSize
                Control(SubList(i)).Left = FindLefts
                FindLefts = FindLefts + Control(SubList(i)).Width
            NEXT

            __UI_AutoRefresh = True
            __UI_ForceRedraw = True
    END SELECT
END SUB

SUB ConvertControlToAlternativeType
    DIM i AS LONG
    DIM NewType AS INTEGER

    NewType = __UI_Type(Control(__UI_FirstSelectedID).Type).TurnsInto
    IF NewType = 0 THEN NewType = __UI_Type_TextBox

    FOR i = 1 TO UBOUND(Control)
        IF Control(i).ControlIsSelected THEN

            Control(i).Type = NewType
            Control(i).Width = __UI_Type(NewType).DefaultWidth
            Control(i).Height = __UI_Type(NewType).DefaultHeight

            IF NewType = __UI_Type_MenuBar THEN
                Caption(i) = RTRIM$(Control(i).Name)
                __UI_AdjustNewMenuBarTopHeight i
            ELSEIF NewType = __UI_Type_ContextMenu THEN
                IF Control(i).HelperCanvas = 0 THEN
                    Control(i).HelperCanvas = _COPYIMAGE(ContextMenuIcon, 32)
                END IF
            ELSEIF NewType = __UI_Type_TextBox THEN
                IF Control(i).NumericOnly = False THEN
                    Control(i).NumericOnly = __UI_NumericWithBounds
                    IF Control(i).Min = 0 AND Control(i).Max = 0 THEN
                        Control(i).Min = -32768
                        Control(i).Max = 32767
                    END IF
                ELSE
                    Control(i).NumericOnly = False
                    IF Control(i).Min = -32768 AND Control(i).Max = 32767 THEN
                        Control(i).Min = 0
                        Control(i).Max = 0
                    END IF
                END IF
            END IF
        END IF
    NEXT

    IF NewType = __UI_Type_MenuBar OR NewType = __UI_Type_ContextMenu THEN
        __UI_RefreshMenuBar
        __UI_HasMenuBar = (__UI_FirstMenuBarControl > 0)
        RefreshContextMenus
        __UI_ActivateMenu Control(__UI_FirstSelectedID), False
    END IF

    __UI_ForceRedraw = True
END SUB

SUB SelectAllControls
    DIM i AS LONG
    IF __UI_TotalSelectedControls = 1 AND Control(__UI_FirstSelectedID).Type = __UI_Type_Frame THEN
        DIM ThisContainer AS LONG
        ThisContainer = Control(__UI_FirstSelectedID).ID
        Control(__UI_FirstSelectedID).ControlIsSelected = False
        __UI_TotalSelectedControls = 0
        FOR i = 1 TO UBOUND(Control)
            IF Control(i).Type <> __UI_Type_Frame AND Control(i).Type <> __UI_Type_Form AND Control(i).Type <> __UI_Type_Font AND Control(i).Type <> __UI_Type_MenuBar AND Control(i).Type <> __UI_Type_MenuItem AND Control(i).Type <> __UI_Type_MenuPanel AND Control(i).Type <> __UI_Type_ContextMenu AND Control(i).Type <> __UI_Type_MenuItem THEN
                IF Control(i).ID > 0 AND Control(i).ParentID = ThisContainer THEN
                    Control(i).ControlIsSelected = True
                    __UI_TotalSelectedControls = __UI_TotalSelectedControls + 1
                    IF __UI_TotalSelectedControls = 1 THEN __UI_FirstSelectedID = Control(i).ID
                END IF
            END IF
        NEXT
    ELSE
        __UI_TotalSelectedControls = 0
        FOR i = 1 TO UBOUND(Control)
            IF Control(i).Type <> __UI_Type_Frame AND Control(i).Type <> __UI_Type_Form AND Control(i).Type <> __UI_Type_Font AND Control(i).Type <> __UI_Type_MenuBar AND Control(i).Type <> __UI_Type_MenuItem AND Control(i).Type <> __UI_Type_MenuPanel AND Control(i).Type <> __UI_Type_ContextMenu AND Control(i).Type <> __UI_Type_MenuItem THEN
                IF Control(i).ID > 0 AND Control(i).ParentID = 0 THEN
                    Control(i).ControlIsSelected = True
                    __UI_TotalSelectedControls = __UI_TotalSelectedControls + 1
                    IF __UI_TotalSelectedControls = 1 THEN __UI_FirstSelectedID = Control(i).ID
                END IF
            END IF
        NEXT
    END IF
END SUB

SUB SelectChildrenControls (id AS LONG)
    DIM i AS LONG
    FOR i = 1 TO UBOUND(Control)
        IF Control(i).ParentID = id THEN
            IF Control(i).ControlIsSelected = False THEN
                Control(i).ControlIsSelected = True
                __UI_TotalSelectedControls = __UI_TotalSelectedControls + 1
                IF Control(i).Type = __UI_Type_MenuItem THEN
                    'Recursively select children's children too:
                    SelectChildrenControls Control(i).ID
                END IF
            END IF
        END IF
    NEXT
END SUB

SUB DeleteSelectedControls
    DIM i AS LONG, didDelete AS _BYTE

    'A container's contents will be deleted with it if it's
    'the only selected control.
    IF __UI_TotalSelectedControls = 1 AND _
       (Control(__UI_FirstSelectedID).Type = __UI_Type_Frame OR _
        Control(__UI_FirstSelectedID).Type = __UI_Type_MenuBar OR _
        Control(__UI_FirstSelectedID).Type = __UI_Type_MenuItem OR _
        Control(__UI_FirstSelectedID).Type = __UI_Type_ContextMenu) THEN
        SelectChildrenControls __UI_FirstSelectedID
    END IF

    'Iterate over control list and delete selected controls.
    FOR i = UBOUND(Control) TO 1 STEP -1
        IF Control(i).Type = __UI_Type_Form THEN _CONTINUE
        IF Control(i).ControlIsSelected THEN
            IF Control(i).Type = __UI_Type_MenuBar OR Control(i).Type = __UI_Type_ContextMenu THEN
                DIM MustRefreshMenuBar AS _BYTE, MustRefreshContextMenus AS _BYTE
                IF Control(i).Type = __UI_Type_MenuBar THEN
                    MustRefreshMenuBar = True
                ELSE
                    MustRefreshContextMenus = True
                END IF
            END IF
            IF __UI_TotalActiveMenus > 0 AND __UI_ParentMenu(__UI_TotalActiveMenus) = Control(i).ID THEN
                __UI_CloseAllMenus
            END IF
            GIF_Free i
            __UI_DestroyControl Control(i)
            IF MustRefreshMenuBar THEN __UI_RefreshMenuBar
            IF MustRefreshContextMenus THEN RefreshContextMenus
            __UI_ForceRedraw = True
            didDelete = True
        END IF
    NEXT
    IF didDelete THEN __UI_TotalSelectedControls = 0
END SUB

SUB RefreshContextMenus
    DIM i AS LONG
    DIM ctxMenuCount AS LONG

    FOR i = 1 TO UBOUND(Control)
        IF Control(i).Type = __UI_Type_ContextMenu AND LEFT$(Control(i).Name, 5) <> "__UI_" THEN
            ctxMenuCount = ctxMenuCount + 1
            Control(i).Left = __UI_SnapDistanceFromForm + ((ctxMenuCount - 1) * Control(i).Width)
            Control(i).Left = Control(i).Left + ((ctxMenuCount - 1) * __UI_SnapDistance)
            Control(i).Top = Control(__UI_FormID).Height - Control(i).Height - __UI_SnapDistanceFromForm
        END IF
    NEXT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

FUNCTION ReadSequential$ (Txt$, Bytes%)
    ReadSequential$ = LEFT$(Txt$, Bytes%)
    Txt$ = MID$(Txt$, Bytes% + 1)
END FUNCTION

SUB LoadPreview (Destination AS _BYTE)
    DIM a$, b$, i AS LONG, __UI_EOF AS _BYTE
    DIM NewType AS INTEGER, NewWidth AS INTEGER, NewHeight AS INTEGER
    DIM NewLeft AS INTEGER, NewTop AS INTEGER, NewName AS STRING
    DIM NewParentID AS STRING, FloatValue AS _FLOAT, TempValue AS LONG
    DIM Dummy AS LONG, Disk AS _BYTE, Clip$, FirstToBeSelected AS LONG
    DIM BinaryFileNum AS INTEGER, LogFileNum AS INTEGER
    DIM CorruptedData AS _BYTE, UndoBuffer AS _BYTE

    CONST LogFileLoad = False

    IF _FILEEXISTS("InForm/UiEditorPreview.frmbin") = 0 AND Destination = InDisk THEN
        EXIT SUB
    END IF

    IF Destination = InDisk THEN
        Disk = True
        BinaryFileNum = FREEFILE
        OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #BinaryFileNum
    ELSEIF Destination = ToUndoBuffer THEN
        UndoBuffer = True
    END IF

    LogFileNum = FREEFILE
    IF LogFileLoad THEN OPEN "ui_log.txt" FOR OUTPUT AS #LogFileNum

    IF Disk THEN
        b$ = SPACE$(7): GET #BinaryFileNum, 1, b$
        IF b$ <> "InForm" + CHR$(1) THEN
            GOTO LoadError
            EXIT SUB
        END IF
    ELSEIF UndoBuffer THEN
        IF UndoPointer = TotalUndoImages THEN EXIT SUB
        Clip$ = UndoImage$(UndoPointer)
    ELSEIF Destination = FromEditor THEN
        Clip$ = RestoreCrashData$
        UndoBuffer = True
    ELSE
        Clip$ = _CLIPBOARD$
        b$ = ReadSequential$(Clip$, LEN(__UI_ClipboardCheck$))
        IF b$ <> __UI_ClipboardCheck$ THEN
            GOTO LoadError
            EXIT SUB
        END IF
    END IF

    IF LogFileLoad THEN PRINT #LogFileNum, "FOUND INFORM+1"

    __UI_AutoRefresh = False

    IF Disk THEN
        FOR i = UBOUND(Control) TO 1 STEP -1
            IF LEFT$(Control(i).Name, 5) <> "__UI_" THEN
                GIF_Free i
                __UI_DestroyControl Control(i)
            END IF
        NEXT
        IF LogFileLoad THEN PRINT #LogFileNum, "DESTROYED CONTROLS"

        b$ = SPACE$(4): GET #BinaryFileNum, , b$
        IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW ARRAYS:" + STR$(CVL(b$))

        REDIM _PRESERVE Caption(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempCaptions(1 TO CVL(b$)) AS STRING
        REDIM Text(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempTexts(1 TO CVL(b$)) AS STRING
        REDIM ToolTip(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempTips(1 TO CVL(b$)) AS STRING
        REDIM _PRESERVE Control(0 TO CVL(b$)) AS __UI_ControlTYPE
    ELSEIF UndoBuffer THEN
        FOR i = UBOUND(Control) TO 1 STEP -1
            IF LEFT$(Control(i).Name, 5) <> "__UI_" THEN
                GIF_Free i
                __UI_DestroyControl Control(i)
            END IF
        NEXT
        IF LogFileLoad THEN PRINT #LogFileNum, "DESTROYED CONTROLS"

        b$ = ReadSequential$(Clip$, 4)
        IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW ARRAYS:" + STR$(CVL(b$))

        REDIM _PRESERVE Caption(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempCaptions(1 TO CVL(b$)) AS STRING
        REDIM Text(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempTexts(1 TO CVL(b$)) AS STRING
        REDIM ToolTip(1 TO CVL(b$)) AS STRING
        REDIM __UI_TempTips(1 TO CVL(b$)) AS STRING
        REDIM _PRESERVE Control(0 TO CVL(b$)) AS __UI_ControlTYPE
    ELSE
        DIM ShiftPosition AS _BYTE
        FOR i = 1 TO UBOUND(Control)
            IF Control(i).ControlIsSelected THEN ShiftPosition = True
            Control(i).ControlIsSelected = False
        NEXT

        __UI_TotalSelectedControls = 0

        'Clip$ = "InForm" + CHR$(10) + CHR$(10)
        'Clip$ = Clip$ + "BEGIN CONTROL DATA" + CHR$(10)
        'Clip$ = Clip$ + STRING$(60, "-") + CHR$(10)
        'Clip$ = Clip$ + HEX$(LEN(b$)) + CHR$(10)
        'Clip$ = Clip$ + b$ + CHR$(10)
        'Clip$ = Clip$ + STRING$(60, "-") + CHR$(10)
        'Clip$ = Clip$ + "END CONTROL DATA"

        DIM ClipLen$
        DO
            a$ = ReadSequential$(Clip$, 1)
            IF a$ = CHR$(10) THEN EXIT DO
            IF a$ = "" THEN GOTO LoadError
            ClipLen$ = ClipLen$ + a$
        LOOP

        b$ = ReadSequential$(Clip$, VAL("&H" + ClipLen$))
        b$ = Replace$(b$, CHR$(10), "", False, 0)
        Clip$ = _BASE64DECODE$(b$)
    END IF

    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
    IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW CONTROL:" + STR$(CVI(b$))
    IF CVI(b$) <> -1 THEN GOTO LoadError
    DO
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
        Dummy = CVL(b$)
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        NewType = CVI(b$)
        IF LogFileLoad THEN PRINT #LogFileNum, "TYPE:" + STR$(CVI(b$))
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, CVI(b$)) ELSE b$ = SPACE$(CVI(b$)): GET #BinaryFileNum, , b$
        NewName = b$
        IF LogFileLoad THEN PRINT #LogFileNum, "NAME:" + NewName
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        NewWidth = CVI(b$)
        IF LogFileLoad THEN PRINT #LogFileNum, "WIDTH:" + STR$(CVI(b$))
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        NewHeight = CVI(b$)
        IF LogFileLoad THEN PRINT #LogFileNum, "HEIGHT:" + STR$(CVI(b$))
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        NewLeft = CVI(b$)
        IF LogFileLoad THEN PRINT #LogFileNum, "LEFT:" + STR$(CVI(b$))
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        NewTop = CVI(b$)
        IF NOT Disk THEN
            IF ShiftPosition THEN
                NewLeft = NewLeft + 20
                NewTop = NewTop + 20
            END IF
        END IF
        IF LogFileLoad THEN PRINT #LogFileNum, "TOP:" + STR$(CVI(b$))
        IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
        IF CVI(b$) > 0 THEN
            IF NOT Disk THEN NewParentID = ReadSequential$(Clip$, CVI(b$)) ELSE NewParentID = SPACE$(CVI(b$)): GET #BinaryFileNum, , NewParentID
            IF LogFileLoad THEN PRINT #LogFileNum, "PARENT:" + NewParentID
        ELSE
            NewParentID = ""
            IF LogFileLoad THEN PRINT #LogFileNum, "PARENT: ORPHAN/CONTAINER"
        END IF

        IF NOT Disk THEN
            'Change control's name in case this form already has one with the same name
            DIM TempName$, c$, OriginalIndex$, NameChanges$
            DIM OriginalName$, DidRename AS _BYTE

            OriginalName$ = RTRIM$(NewName)
            DidRename = False
            DO WHILE __UI_GetID(NewName) > 0
                DidRename = True
                IF INSTR(NameChanges$, OriginalName$ + "=") = 0 THEN
                    NameChanges$ = NameChanges$ + OriginalName$ + "="
                END IF
                TempName$ = RTRIM$(NewName)
                c$ = RIGHT$(TempName$, 1)
                IF ASC(c$) >= 48 AND ASC(c$) <= 57 THEN
                    'Update this control's name by the ID # assigned to it, if any
                    OriginalIndex$ = c$
                    TempName$ = LEFT$(TempName$, LEN(TempName$) - 1)
                    DO
                        c$ = RIGHT$(TempName$, 1)
                        IF ASC(c$) >= 48 AND ASC(c$) <= 57 THEN
                            OriginalIndex$ = c$ + OriginalIndex$
                            TempName$ = LEFT$(TempName$, LEN(TempName$) - 1)
                            IF LEN(TempName$) = 0 THEN EXIT DO
                        ELSE
                            EXIT DO
                        END IF
                    LOOP
                ELSE
                    OriginalIndex$ = "1"
                END IF
                NewName = TempName$ + LTRIM$(STR$(VAL(OriginalIndex$) + 1))
            LOOP
            IF DidRename THEN
                NameChanges$ = NameChanges$ + NewName + ";"
            END IF
        END IF

        IF LEN(NewParentID) > 0 AND INSTR(NameChanges$, NewParentID + "=") THEN
            'This control's container had a name change when it was
            'pasted, so we'll reassign it to its new cloned parent:
            DIM NewID AS LONG, EndNewID AS LONG
            NewID = INSTR(NameChanges$, NewParentID + "=") + LEN(NewParentID + "=")
            EndNewID = INSTR(NewID, NameChanges$, ";")
            NewParentID = MID$(NameChanges$, NewID, EndNewID - NewID)
        END IF

        TempValue = __UI_NewControl(NewType, NewName, NewWidth, NewHeight, NewLeft, NewTop, __UI_GetID(NewParentID))

        IF NOT Disk AND NOT UndoBuffer THEN
            Control(TempValue).ControlIsSelected = True
            __UI_TotalSelectedControls = __UI_TotalSelectedControls + 1
            IF __UI_TotalSelectedControls = 1 THEN FirstToBeSelected = TempValue
        END IF
        IF NewType = __UI_Type_PictureBox THEN
            Control(TempValue).HasBorder = False
            Control(TempValue).Stretch = False
        ELSEIF NewType = __UI_Type_ContextMenu THEN
            Control(TempValue).HelperCanvas = _COPYIMAGE(ContextMenuIcon, 32)
            Control(TempValue).Width = 22
            Control(TempValue).Height = 22
            RefreshContextMenus
        END IF

        DO 'read properties
            IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
            IF LogFileLoad THEN PRINT #LogFileNum, "PROPERTY:" + STR$(CVI(b$)) + " :";
            SELECT CASE CVI(b$)
                CASE -2 'Caption
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, CVL(b$)) ELSE b$ = SPACE$(CVL(b$)): GET #BinaryFileNum, , b$
                    SetCaption TempValue, b$
                    IF LogFileLoad THEN PRINT #LogFileNum, "CAPTION:" + Caption(TempValue)
                CASE -3 'Text
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, CVL(b$)) ELSE b$ = SPACE$(CVL(b$)): GET #BinaryFileNum, , b$
                    Text(TempValue) = b$
                    IF Control(TempValue).Type = __UI_Type_PictureBox THEN
                        PreviewLoadImage Control(TempValue), Text(TempValue)
                    ELSEIF Control(TempValue).Type = __UI_Type_Button OR Control(TempValue).Type = __UI_Type_MenuItem THEN
                        LoadImage Control(TempValue), Text(TempValue)
                    ELSEIF Control(TempValue).Type = __UI_Type_Form THEN
                        IF ExeIcon <> 0 THEN _FREEIMAGE ExeIcon: ExeIcon = 0
                        ExeIcon = IconPreview&(Text(TempValue))
                        IF ExeIcon < -1 THEN
                            _ICON ExeIcon
                        END IF
                    END IF
                    IF LogFileLoad THEN PRINT #LogFileNum, "TEXT:" + Text(TempValue)
                CASE -4 'Stretch
                    Control(TempValue).Stretch = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "STRETCH"
                CASE -5 'Font
                    IF LogFileLoad THEN PRINT #LogFileNum, "FONT:";
                    DIM FontSetup$, FindSep AS INTEGER
                    DIM NewFontFile AS STRING
                    DIM NewFontSize AS INTEGER
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN FontSetup$ = ReadSequential$(Clip$, CVI(b$)) ELSE FontSetup$ = SPACE$(CVI(b$)): GET #BinaryFileNum, , FontSetup$
                    IF LogFileLoad THEN PRINT #LogFileNum, FontSetup$

                    FindSep = INSTR(FontSetup$, ",")
                    NewFontFile = LEFT$(FontSetup$, FindSep - 1)
                    FontSetup$ = MID$(FontSetup$, FindSep + 1)

                    NewFontSize = VAL(FontSetup$)

                    Control(TempValue).Font = SetFont(NewFontFile, NewFontSize)

                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN FontSetup$ = ReadSequential$(Clip$, CVI(b$)) ELSE FontSetup$ = SPACE$(CVI(b$)): GET #BinaryFileNum, , FontSetup$
                CASE -6 'ForeColor
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).ForeColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "FORECOLOR"
                CASE -7 'BackColor
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).BackColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "BACKCOLOR"
                CASE -8 'SelectedForeColor
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).SelectedForeColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "SELECTEDFORECOLOR"
                CASE -9 'SelectedBackColor
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).SelectedBackColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "SELECTEDBACKCOLOR"
                CASE -10 'BorderColor
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).BorderColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "BORDERCOLOR"
                CASE -11
                    Control(TempValue).BackStyle = __UI_Transparent
                    IF LogFileLoad THEN PRINT #LogFileNum, "BACKSTYLE:TRANSPARENT"
                CASE -12
                    Control(TempValue).HasBorder = True
                    IF Control(TempValue).BorderSize = 0 THEN
                        Control(TempValue).BorderSize = 1
                    END IF
                    IF LogFileLoad THEN PRINT #LogFileNum, "HASBORDER"
                CASE -13
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 1) ELSE b$ = SPACE$(1): GET #BinaryFileNum, , b$
                    Control(TempValue).Align = _CV(_BYTE, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "ALIGN="; Control(TempValue).Align
                CASE -14
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, LEN(FloatValue)) ELSE b$ = SPACE$(LEN(FloatValue)): GET #BinaryFileNum, , b$
                    Control(TempValue).Value = _CV(_FLOAT, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "VALUE="; Control(TempValue).Value
                CASE -15
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, LEN(FloatValue)) ELSE b$ = SPACE$(LEN(FloatValue)): GET #BinaryFileNum, , b$
                    Control(TempValue).Min = _CV(_FLOAT, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "MIN="; Control(TempValue).Min
                CASE -16
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, LEN(FloatValue)) ELSE b$ = SPACE$(LEN(FloatValue)): GET #BinaryFileNum, , b$
                    Control(TempValue).Max = _CV(_FLOAT, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "MAX="; Control(TempValue).Max
                CASE -19
                    Control(TempValue).ShowPercentage = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "SHOWPERCENTAGE"
                CASE -20
                    Control(TempValue).CanHaveFocus = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "CANHAVEFOCUS"
                CASE -21
                    Control(TempValue).Disabled = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "DISABLED"
                CASE -22
                    Control(TempValue).Hidden = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "HIDDEN"
                CASE -23
                    Control(TempValue).CenteredWindow = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "CENTEREDWINDOW"
                CASE -24 'Tips
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, CVL(b$)) ELSE b$ = SPACE$(CVL(b$)): GET #BinaryFileNum, , b$
                    ToolTip(TempValue) = b$
                    IF LogFileLoad THEN PRINT #LogFileNum, "TIP: "; ToolTip(TempValue)
                CASE -25
                    DIM ContextMenuName AS STRING
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN ContextMenuName = ReadSequential$(Clip$, CVI(b$)) ELSE ContextMenuName = SPACE$(CVI(b$)): GET #BinaryFileNum, , ContextMenuName
                    Control(TempValue).ContextMenuID = __UI_GetID(ContextMenuName)
                    IF LogFileLoad THEN PRINT #LogFileNum, "CONTEXTMENU:"; ContextMenuName
                CASE -26
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, LEN(FloatValue)) ELSE b$ = SPACE$(LEN(FloatValue)): GET #BinaryFileNum, , b$
                    Control(TempValue).Interval = _CV(_FLOAT, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "INTERVAL="; Control(TempValue).Interval
                CASE -27
                    Control(TempValue).WordWrap = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "WORDWRAP"
                CASE -28
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).TransparentColor = _CV(_UNSIGNED LONG, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "TRANSPARENTCOLOR"
                    __UI_ClearColor Control(TempValue).HelperCanvas, Control(TempValue).TransparentColor, -1
                CASE -29
                    Control(TempValue).CanResize = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "CANRESIZE"
                CASE -31
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    Control(TempValue).Padding = CVI(b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "PADDING" + STR$(CVI(b$))
                CASE -32
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 1) ELSE b$ = SPACE$(1): GET #BinaryFileNum, , b$
                    Control(TempValue).VAlign = _CV(_BYTE, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "VALIGN="; Control(TempValue).VAlign
                CASE -33
                    Control(TempValue).PasswordField = True
                    IF LogFileLoad THEN PRINT #LogFileNum, "PASSWORDFIELD"
                CASE -34
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    Control(TempValue).Encoding = CVL(b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "ENCODING="; Control(TempValue).Encoding
                CASE -35
                    __UI_DefaultButtonID = TempValue
                    IF LogFileLoad THEN PRINT #LogFileNum, "DEFAULT BUTTON"
                CASE -36
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 4) ELSE b$ = SPACE$(4): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, CVL(b$)) ELSE b$ = SPACE$(CVL(b$)): GET #BinaryFileNum, , b$
                    Mask(TempValue) = b$
                    IF LogFileLoad THEN PRINT #LogFileNum, "MASK:" + Mask(TempValue)
                CASE -37
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, LEN(FloatValue)) ELSE b$ = SPACE$(LEN(FloatValue)): GET #BinaryFileNum, , b$
                    Control(TempValue).MinInterval = _CV(_FLOAT, b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "MININTERVAL="; Control(TempValue).MinInterval
                CASE -38
                    Control(TempValue).NumericOnly = True
                CASE -39
                    Control(TempValue).NumericOnly = __UI_NumericWithBounds
                CASE -40
                    Control(TempValue).BulletStyle = __UI_Bullet
                CASE -41
                    Control(TempValue).AutoScroll = True
                CASE -42
                    Control(TempValue).AutoSize = True
                CASE -43
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    Control(TempValue).BorderSize = CVI(b$)
                    IF LogFileLoad THEN PRINT #LogFileNum, "BORDER SIZE" + STR$(CVI(b$))
                CASE -44
                    DIM RegisterResult AS _BYTE, Combo AS STRING
                    IF NOT Disk THEN b$ = ReadSequential$(Clip$, 2) ELSE b$ = SPACE$(2): GET #BinaryFileNum, , b$
                    IF NOT Disk THEN Combo = ReadSequential$(Clip$, CVI(b$)) ELSE Combo = SPACE$(CVI(b$)): GET #BinaryFileNum, , ContextMenuName
                    RegisterResult = RegisterKeyCombo(Combo, TempValue)
                    IF LogFileLoad THEN PRINT #LogFileNum, "KEY COMBO:"; Combo
                CASE -46
                    IF TempValue <= UBOUND(AutoPlayGif) THEN
                        AutoPlayGif(i) = True
                    END IF
                CASE -47
                    Control(TempValue).ControlIsSelected = True
                CASE -1 'new control
                    IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW CONTROL: -1"
                    EXIT DO
                CASE -1024
                    IF LogFileLoad THEN PRINT #LogFileNum, "READ END OF FILE: -1024"
                    __UI_EOF = True
                    EXIT DO
                CASE ELSE
                    IF LogFileLoad THEN PRINT #LogFileNum, "UNKNOWN PROPERTY ="; CVI(b$)
                    __UI_EOF = True 'Stop reading if corrupted data is found
                    CorruptedData = True
                    EXIT DO
            END SELECT
        LOOP
    LOOP UNTIL __UI_EOF
    IF Disk THEN CLOSE #BinaryFileNum
    IF LogFileLoad THEN CLOSE #LogFileNum
    IF NOT Disk AND NOT UndoBuffer THEN
        IF NOT CorruptedData THEN
            __UI_FirstSelectedID = FirstToBeSelected
        ELSE
            GIF_Free TempValue
            __UI_DestroyControl Control(TempValue)
            __UI_TotalSelectedControls = __UI_TotalSelectedControls - 1
        END IF
        __UI_ForceRedraw = True
    END IF
    __UI_AutoRefresh = True
    EXIT SUB

    LoadError:
    IF Disk THEN
        CLOSE #BinaryFileNum
        KILL "InForm/UiEditorPreview.frmbin"
    END IF
    IF LogFileLoad THEN CLOSE #LogFileNum
    __UI_AutoRefresh = True
END SUB

SUB LoadPreviewText
    DIM b$, i AS LONG, __UI_EOF AS _BYTE
    DIM NewType AS INTEGER, NewWidth AS INTEGER, NewHeight AS INTEGER
    DIM NewLeft AS INTEGER, NewTop AS INTEGER, NewName AS STRING
    DIM NewParentID AS STRING, TempValue AS LONG
    DIM DummyText$
    DIM BinaryFileNum AS INTEGER, LogFileNum AS INTEGER
    DIM NewRed AS _UNSIGNED _BYTE, NewGreen AS _UNSIGNED _BYTE, NewBlue AS _UNSIGNED _BYTE

    CONST LogFileLoad = False

    IF _FILEEXISTS("InForm/UiEditorPreview.frmbin") = 0 THEN
        EXIT SUB
    ELSE
        BinaryFileNum = FREEFILE
        OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #BinaryFileNum

        LogFileNum = FREEFILE
        IF LogFileLoad THEN OPEN "ui_log.txt" FOR OUTPUT AS #LogFileNum
        DO
            IF EOF(BinaryFileNum) THEN GOTO LoadError
            LINE INPUT #BinaryFileNum, b$
        LOOP UNTIL b$ = "SUB __UI_LoadForm"
        IF LogFileLoad THEN PRINT #LogFileNum, "FOUND SUB __UI_LOADFORM"

        __UI_AutoRefresh = False
        FOR i = UBOUND(Control) TO 1 STEP -1
            IF LEFT$(Control(i).Name, 5) <> "__UI_" THEN
                GIF_Free i
                __UI_DestroyControl Control(i)
            END IF
        NEXT
        IF LogFileLoad THEN PRINT #LogFileNum, "DESTROYED CONTROLS"

        DO
            LINE INPUT #BinaryFileNum, b$
        LOOP UNTIL INSTR(b$, "__UI_NewControl") > 0
        IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW CONTROL"
        DO
            DummyText$ = nextParameter(b$)
            SELECT CASE DummyText$
                CASE "__UI_Type_Form": NewType = 1
                CASE "__UI_Type_Frame": NewType = 2
                CASE "__UI_Type_Button": NewType = 3
                CASE "__UI_Type_Label": NewType = 4
                CASE "__UI_Type_CheckBox": NewType = 5
                CASE "__UI_Type_RadioButton": NewType = 6
                CASE "__UI_Type_TextBox": NewType = 7
                CASE "__UI_Type_ProgressBar": NewType = 8
                CASE "__UI_Type_ListBox": NewType = 9
                CASE "__UI_Type_DropdownList": NewType = 10
                CASE "__UI_Type_MenuBar": NewType = 11
                CASE "__UI_Type_MenuItem": NewType = 12
                CASE "__UI_Type_MenuPanel": NewType = 13
                CASE "__UI_Type_PictureBox": NewType = 14
                CASE "__UI_Type_TrackBar": NewType = 15
                CASE "__UI_Type_ContextMenu": NewType = 16
                CASE "__UI_Type_Font": NewType = 17
                CASE "__UI_Type_ToggleSwitch": NewType = 18
            END SELECT
            IF LogFileLoad THEN PRINT #LogFileNum, "TYPE:" + DummyText$

            NewName = nextParameter(b$)
            IF LogFileLoad THEN PRINT #LogFileNum, "NAME:" + NewName

            NewWidth = VAL(nextParameter(b$))
            IF LogFileLoad THEN PRINT #LogFileNum, "WIDTH:" + STR$(NewWidth)

            NewHeight = VAL(nextParameter(b$))
            IF LogFileLoad THEN PRINT #LogFileNum, "HEIGHT:" + STR$(NewHeight)

            NewLeft = VAL(nextParameter(b$))
            IF LogFileLoad THEN PRINT #LogFileNum, "LEFT:" + STR$(NewLeft)

            NewTop = VAL(nextParameter(b$))
            IF LogFileLoad THEN PRINT #LogFileNum, "TOP:" + STR$(NewTop)

            DummyText$ = nextParameter(b$)
            IF DummyText$ = "0" THEN
                NewParentID = ""
                IF LogFileLoad THEN PRINT #LogFileNum, "PARENT: ORPHAN/CONTAINER"
            ELSE
                NewParentID = DummyText$
                IF LogFileLoad THEN PRINT #LogFileNum, "PARENT:" + NewParentID
            END IF

            TempValue = __UI_NewControl(NewType, NewName, NewWidth, NewHeight, NewLeft, NewTop, __UI_GetID(NewParentID))

            IF UBOUND(AutoPlayGif) <> UBOUND(Control) THEN
                REDIM _PRESERVE AutoPlayGif(UBOUND(Control)) AS _BYTE
            END IF

            IF NewType = __UI_Type_PictureBox THEN
                Control(TempValue).HasBorder = False
                Control(TempValue).Stretch = False
            ELSEIF NewType = __UI_Type_ContextMenu THEN
                Control(TempValue).HelperCanvas = _COPYIMAGE(ContextMenuIcon, 32)
                Control(TempValue).Width = 22
                Control(TempValue).Height = 22
                RefreshContextMenus
            END IF
            IF NewType = __UI_Type_Label THEN Control(TempValue).VAlign = __UI_Top

            DO 'read properties
                DO
                    LINE INPUT #BinaryFileNum, b$
                    b$ = _TRIM$(b$)
                    IF LEN(b$) > 0 THEN EXIT DO
                LOOP
                IF LEFT$(b$, 20) = "Control(__UI_NewID)." THEN
                    'Property
                    DummyText$ = MID$(b$, INSTR(21, b$, " = ") + 3)
                    IF LogFileLoad THEN PRINT #LogFileNum, "PROPERTY: "; MID$(b$, 21, INSTR(21, b$, " =") - 21)
                    SELECT CASE MID$(b$, 21, INSTR(21, b$, " =") - 21)
                        CASE "Stretch"
                            Control(TempValue).Stretch = (DummyText$ = "True")
                        CASE "Font"
                            DIM NewFontFile AS STRING
                            DIM NewFontSize AS INTEGER

                            IF LEFT$(DummyText$, 8) = "SetFont(" THEN
                                NewFontFile = nextParameter(DummyText$)
                                NewFontSize = VAL(nextParameter(DummyText$))
                                Control(TempValue).Font = SetFont(NewFontFile, NewFontSize)
                            END IF
                        CASE "ForeColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).ForeColor = _RGB32(NewRed, NewGreen, NewBlue)
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).ForeColor = VAL(DummyText$)
                            END IF
                        CASE "BackColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).BackColor = _RGB32(NewRed, NewGreen, NewBlue)
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).BackColor = VAL(DummyText$)
                            END IF
                        CASE "SelectedForeColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).SelectedForeColor = _RGB32(NewRed, NewGreen, NewBlue)
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).SelectedForeColor = VAL(DummyText$)
                            END IF
                        CASE "SelectedBackColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).SelectedBackColor = _RGB32(NewRed, NewGreen, NewBlue)
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).SelectedBackColor = VAL(DummyText$)
                            END IF
                        CASE "BorderColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).BorderColor = _RGB32(NewRed, NewGreen, NewBlue)
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).BorderColor = VAL(DummyText$)
                            END IF
                        CASE "BackStyle"
                            IF DummyText$ = "__UI_Transparent" THEN
                                Control(TempValue).BackStyle = __UI_Transparent
                            END IF
                        CASE "HasBorder"
                            IF DummyText$ = "True" THEN
                                Control(TempValue).HasBorder = True
                                IF Control(TempValue).BorderSize = 0 THEN
                                    Control(TempValue).BorderSize = 1
                                END IF
                            END IF
                        CASE "Align"
                            SELECT CASE DummyText$
                                CASE "__UI_Center": Control(TempValue).Align = __UI_Center
                                CASE "__UI_Right": Control(TempValue).Align = __UI_Right
                            END SELECT
                        CASE "Value"
                            Control(TempValue).Value = VAL(DummyText$)
                        CASE "Min"
                            Control(TempValue).Min = VAL(DummyText$)
                        CASE "Max"
                            Control(TempValue).Max = VAL(DummyText$)
                        CASE "ShowPercentage"
                            Control(TempValue).ShowPercentage = (DummyText$ = "True")
                        CASE "CanHaveFocus"
                            Control(TempValue).CanHaveFocus = (DummyText$ = "True")
                        CASE "Disabled"
                            Control(TempValue).Disabled = (DummyText$ = "True")
                        CASE "Hidden"
                            Control(TempValue).Hidden = (DummyText$ = "True")
                        CASE "CenteredWindow"
                            Control(TempValue).CenteredWindow = (DummyText$ = "True")
                        CASE "ContextMenuID"
                            Control(TempValue).ContextMenuID = __UI_GetID(nextParameter(DummyText$))
                        CASE "Interval"
                            Control(TempValue).Interval = VAL(DummyText$)
                        CASE "MinInterval"
                            Control(TempValue).MinInterval = VAL(DummyText$)
                        CASE "WordWrap"
                            Control(TempValue).WordWrap = (DummyText$ = "True")
                        CASE "TransparentColor"
                            IF LEFT$(DummyText$, 6) = "_RGB32" THEN
                                NewRed = VAL(nextParameter(DummyText$))
                                NewGreen = VAL(nextParameter(DummyText$))
                                NewBlue = VAL(nextParameter(DummyText$))
                                Control(TempValue).TransparentColor = _RGB32(NewRed, NewGreen, NewBlue)
                                __UI_ClearColor Control(TempValue).HelperCanvas, Control(TempValue).TransparentColor, -1
                            ELSEIF LEFT$(DummyText$, 2) = "&H" THEN
                                Control(TempValue).TransparentColor = VAL(DummyText$)
                                __UI_ClearColor Control(TempValue).HelperCanvas, Control(TempValue).TransparentColor, -1
                            END IF
                        CASE "CanResize"
                            Control(TempValue).CanResize = (DummyText$ = "True")
                        CASE "Padding"
                            Control(TempValue).Padding = VAL(DummyText$)
                        CASE "BorderSize"
                            Control(TempValue).BorderSize = VAL(DummyText$)
                        CASE "VAlign"
                            SELECT CASE DummyText$
                                CASE "__UI_Middle": Control(TempValue).VAlign = __UI_Middle
                                CASE "__UI_Bottom": Control(TempValue).VAlign = __UI_Bottom
                            END SELECT
                        CASE "PasswordField"
                            Control(TempValue).PasswordField = (DummyText$ = "True")
                        CASE "Encoding"
                            Control(TempValue).Encoding = VAL(DummyText$)
                        CASE "NumericOnly"
                            IF DummyText$ = "True" THEN
                                Control(TempValue).NumericOnly = True
                            ELSEIF DummyText$ = "__UI_NumericWithBounds" THEN
                                Control(TempValue).NumericOnly = __UI_NumericWithBounds
                            END IF
                        CASE "BulletStyle"
                            IF DummyText$ = "__UI_CheckMark" THEN
                                Control(TempValue).BulletStyle = __UI_CheckMark
                            ELSEIF DummyText$ = "__UI_Bullet" THEN
                                Control(TempValue).BulletStyle = __UI_Bullet
                            END IF
                        CASE "AutoScroll"
                            Control(TempValue).AutoScroll = (DummyText$ = "True")
                        CASE "AutoSize"
                            Control(TempValue).AutoSize = (DummyText$ = "True")
                    END SELECT
                ELSEIF b$ = "__UI_DefaultButtonID = __UI_NewID" THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "DEFAULT BUTTON"
                    __UI_DefaultButtonID = TempValue
                ELSEIF LEFT$(b$, 11) = "SetCaption " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "SETCAPTION"
                    'Caption
                    DummyText$ = nextParameter(b$) 'discard first parameter
                    DummyText$ = nextParameter(b$)
                    SetCaption TempValue, DummyText$
                ELSEIF LEFT$(b$, 8) = "AddItem " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "ADD ITEM"
                    'Caption
                    DummyText$ = nextParameter(b$) 'discard first parameter
                    DummyText$ = nextParameter(b$)
                    AddItem TempValue, DummyText$
                ELSEIF LEFT$(b$, 10) = "LoadImage " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "LOADIMAGE"
                    'Image
                    DummyText$ = nextParameter(b$) 'discard first parameter
                    DummyText$ = nextParameter(b$)
                    LoadImage Control(TempValue), DummyText$
                ELSEIF LEFT$(b$, 30) = "__UI_RegisterResult = GIF_LoadFromFile(" THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "GIF_LOADFROMFILE"
                    'Gif extension
                    DIM RegisterResult AS _BYTE
                    DummyText$ = nextParameter(b$) 'discard first parameter
                    DummyText$ = nextParameter(b$)
                    RegisterResult = GIF_LoadFromFile(TempValue, DummyText$)
                    IF RegisterResult THEN
                        IF LogFileLoad THEN PRINT #LogFileNum, "LOAD SUCCESSFUL"
                        Text(TempValue) = DummyText$ 'indicates image loaded successfully
                        IF Control(TempValue).HelperCanvas < -1 THEN
                            _FREEIMAGE Control(TempValue).HelperCanvas
                        END IF
                        Control(TempValue).HelperCanvas = _NEWIMAGE(GIF_GetWidth(TempValue), GIF_GetHeight(TempValue), 32)
                        GIF_Draw TempValue
                    ELSE
                        MessageBox DummyText$ + " is not a GIF file!", _TITLE$, MsgBox_Exclamation
                    END IF
                ELSEIF b$ = "IF __UI_RegisterResult THEN GIF_Play __UI_NewID" OR LEFT$(b$, 9) = "GIF_Play " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "AUTOPLAY GIF"
                    'Auto-play gif
                    AutoPlayGif(TempValue) = True
                    GIF_Play TempValue
                ELSEIF LEFT$(b$, 22) = "ToolTip(__UI_NewID) = " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "TOOLTIP"
                    'Tooltip
                    DummyText$ = MID$(b$, INSTR(b$, " = ") + 3)
                    DummyText$ = RestoreCHR$(DummyText$)
                    ToolTip(TempValue) = RemoveQuotation$(DummyText$)
                ELSEIF LEFT$(b$, 19) = "Text(__UI_NewID) = " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "TEXT"
                    'Text
                    DummyText$ = MID$(b$, INSTR(b$, " = ") + 3)
                    DummyText$ = RestoreCHR$(DummyText$)
                    Text(TempValue) = RemoveQuotation$(DummyText$)

                    IF Control(TempValue).Type = __UI_Type_Form THEN
                        IF ExeIcon <> 0 THEN _FREEIMAGE ExeIcon: ExeIcon = 0
                        ExeIcon = IconPreview&(Text(TempValue))
                        IF ExeIcon < -1 THEN
                            _ICON ExeIcon
                        END IF
                    END IF
                ELSEIF LEFT$(b$, 19) = "Mask(__UI_NewID) = " THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "MASK"
                    'Mask
                    DummyText$ = MID$(b$, INSTR(b$, " = ") + 3)
                    DummyText$ = RestoreCHR$(DummyText$)
                    Mask(TempValue) = RemoveQuotation$(DummyText$)
                ELSEIF LEFT$(b$, 38) = "__UI_RegisterResult = RegisterKeyCombo" THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "KEYCOMBO"
                    DummyText$ = nextParameter(b$)
                    RegisterResult = RegisterKeyCombo(DummyText$, TempValue)
                ELSEIF INSTR(b$, "__UI_NewControl") > 0 THEN
                    'New Control
                    IF LogFileLoad THEN PRINT #LogFileNum, "READ NEW CONTROL"
                    EXIT DO
                ELSEIF LEFT$(b$, 10) = "__UI_Bind " THEN
                    ASC(b$, 10) = 40 'Changes first space into "(" for parsing
                    DIM SourceControl$, TargetControl$
                    DIM SourceProperty$, TargetProperty$
                    DIM SourceSet AS _BYTE, TargetSet AS _BYTE

                    SourceControl$ = nextParameter$(b$)
                    TargetControl$ = nextParameter$(b$)
                    SourceProperty$ = nextParameter$(b$)
                    TargetProperty$ = nextParameter$(b$)

                    SourceSet = False: TargetSet = False
                    FOR i = 1 TO UBOUND(Control)
                        IF RTRIM$(Control(i).Name) = SourceControl$ THEN
                            Control(i).BoundTo = __UI_GetID(TargetControl$)
                            Control(i).BoundProperty = __UI_PropertyEnum(SourceProperty$, 0)
                            SourceSet = True
                        ELSEIF RTRIM$(Control(i).Name) = TargetControl$ THEN
                            Control(i).BoundTo = __UI_GetID(SourceControl$)
                            Control(i).BoundProperty = __UI_PropertyEnum(TargetProperty$, 0)
                            TargetSet = True
                        END IF
                        IF SourceSet AND TargetSet THEN EXIT FOR
                    NEXT
                ELSEIF b$ = "END SUB" THEN
                    IF LogFileLoad THEN PRINT #LogFileNum, "END OF FILE"
                    __UI_EOF = True
                    EXIT DO
                END IF
            LOOP
        LOOP UNTIL __UI_EOF
        CLOSE #BinaryFileNum
        IF LogFileLoad THEN CLOSE #LogFileNum
        __UI_AutoRefresh = True
        EXIT SUB

        LoadError:
        CLOSE #BinaryFileNum
        KILL "InForm/UiEditorPreview.frmbin"
        __UI_AutoRefresh = True
        EXIT SUB
    END IF
    EXIT SUB
END SUB

SUB PreviewLoadImage (This AS __UI_ControlTYPE, fileName$)
    IF LCASE$(RIGHT$(fileName$, 4)) = ".gif" THEN
        GIF_Free This.ID
        IF GIF_LoadFromFile(This.ID, fileName$) THEN
            IF GIF_GetTotalFrames(This.ID) = 1 THEN
                GIF_Free This.ID
            ELSE
                Text(This.ID) = fileName$ 'indicates image loaded successfully
                IF This.HelperCanvas < -1 THEN
                    _FREEIMAGE This.HelperCanvas
                END IF
                This.HelperCanvas = _NEWIMAGE(GIF_GetWidth(This.ID), GIF_GetHeight(This.ID), 32)
                AutoPlayGif(This.ID) = False
                GIF_Draw This.ID
                EXIT SUB
            END IF
        ELSE
            MessageBox fileName$ + " is not a GIF file!", _TITLE$, MsgBox_Exclamation
        END IF
    END IF
    GIF_Free This.ID
    LoadImage This, fileName$
END SUB

FUNCTION nextParameter$ (__text$)
    STATIC lastText$
    STATIC position1 AS LONG, position2 AS LONG
    DIM text$, thisParameter$

    text$ = _TRIM$(__text$)
    IF text$ <> lastText$ THEN
        lastText$ = text$
        position1 = INSTR(text$, "(")
        IF position1 > 0 THEN
            'check that this bracket is outside quotation marks
            DIM quote AS _BYTE, i AS LONG
            FOR i = 1 TO position1
                IF ASC(text$, i) = 34 THEN quote = NOT quote
            NEXT
            IF quote THEN position1 = 0
        END IF

        IF position1 = 0 THEN
            'no opening bracket; must be a sub call
            position1 = INSTR(text$, " ")
            IF position1 = 0 THEN EXIT FUNCTION
            position1 = position1 + 1 'skip space
        ELSE
            position1 = position1 + 1 'skip bracket
        END IF
    END IF

    position2 = INSTR(position1, text$, ",")
    IF position2 = 0 THEN position2 = INSTR(position1, text$, ")")
    IF position2 > 0 THEN
        'check that this bracket is outside quotation marks
        quote = False
        FOR i = 1 TO position2
            IF ASC(text$, i) = 34 THEN quote = NOT quote
        NEXT
        IF quote THEN position2 = 0
    END IF
    IF position2 = 0 THEN position2 = LEN(text$) + 1
    thisParameter$ = _TRIM$(MID$(text$, position1, position2 - position1))
    nextParameter$ = RemoveQuotation$(thisParameter$)
    position1 = position2 + 1
END FUNCTION

FUNCTION RemoveQuotation$ (__text$)
    DIM text$, firstQ AS LONG, nextQ AS LONG
    text$ = __text$

    firstQ = INSTR(text$, CHR$(34))
    IF firstQ = 0 THEN RemoveQuotation$ = text$: EXIT FUNCTION

    nextQ = INSTR(firstQ + 1, text$, CHR$(34))
    IF nextQ = 0 THEN RemoveQuotation$ = MID$(text$, firstQ + 1): EXIT FUNCTION

    RemoveQuotation$ = MID$(text$, firstQ + 1, nextQ - firstQ - 1)
END FUNCTION

SUB SavePreview (Destination AS _BYTE)
    DIM b$, i AS LONG, a$, FontSetup$
    DIM BinFileNum AS INTEGER, TxtFileNum AS INTEGER
    DIM Clip$, Disk AS _BYTE, TCP AS _BYTE, UndoBuffer AS _BYTE
    DIM PreviewData$, Dummy AS LONG

    CONST Debug = False

    IF Destination = InDisk THEN
        Disk = True
        BinFileNum = FREEFILE
        OPEN "InForm/UiEditorPreview.frmbin" FOR BINARY AS #BinFileNum
    ELSEIF Destination = ToEditor THEN
        TCP = True
    ELSEIF Destination = ToUndoBuffer THEN
        UndoBuffer = True
    ELSE
        IF __UI_TotalSelectedControls = 0 THEN EXIT SUB

        DIM SelectedFrames$
        FOR i = 1 TO UBOUND(Control)
            IF Control(i).ControlIsSelected AND Control(i).Type = __UI_Type_Frame THEN
                SelectedFrames$ = SelectedFrames$ + ";" + RTRIM$(Control(i).Name) + ";"
            END IF
        NEXT
    END IF

    IF Debug THEN
        TxtFileNum = FREEFILE
        OPEN "UiEditorPreview.txt" FOR OUTPUT AS #TxtFileNum
    END IF

    b$ = "InForm" + CHR$(1)
    IF Disk THEN
        PUT #BinFileNum, 1, b$
        b$ = MKL$(UBOUND(Control))
        PUT #BinFileNum, , b$
    ELSEIF TCP THEN
        PreviewData$ = "FORMDATA>" + MKL$(UBOUND(Control))
    ELSEIF UndoBuffer THEN
        Clip$ = MKL$(UBOUND(Control))
    END IF

    DIM ThisPass AS _BYTE
    FOR ThisPass = 1 TO 2
        FOR i = 1 TO UBOUND(Control)
            IF Destination = InClipboard THEN
                IF Control(i).Type = __UI_Type_Form OR Control(i).Type = __UI_Type_MenuBar THEN _CONTINUE
                IF Control(i).ControlIsSelected = False THEN
                    IF INSTR(SelectedFrames$, ";" + RTRIM$(Control(Control(i).ParentID).Name) + ";") = 0 THEN
                        _CONTINUE
                    END IF
                END IF
            END IF

            IF Control(i).ID > 0 AND Control(i).Type <> __UI_Type_MenuPanel AND Control(i).Type <> __UI_Type_Font AND LEN(RTRIM$(Control(i).Name)) > 0 AND LEFT$(RTRIM$(Control(i).Name), 5) <> "__UI_" THEN
                IF ThisPass = 1 THEN
                    IF Control(i).Type <> __UI_Type_Form AND _
                       Control(i).Type <> __UI_Type_Frame AND _
                       Control(i).Type <> __UI_Type_MenuBar THEN
                        _CONTINUE
                    END IF
                ELSEIF ThisPass = 2 THEN
                    IF Control(i).Type = __UI_Type_Form OR _
                       Control(i).Type = __UI_Type_Frame OR _
                       Control(i).Type = __UI_Type_MenuBar THEN
                        _CONTINUE
                    END IF
                END IF
                IF Debug THEN
                    PRINT #TxtFileNum, Control(i).ID,
                    PRINT #TxtFileNum, RTRIM$(Control(i).Name)
                END IF
                DIM tempList$
                tempList$ = tempList$ + RTRIM$(Control(i).Name) + ";"
                b$ = MKI$(-1) + MKL$(i) + MKI$(Control(i).Type) '-1 indicates a new control
                b$ = b$ + MKI$(LEN(RTRIM$(Control(i).Name)))
                b$ = b$ + RTRIM$(Control(i).Name)
                b$ = b$ + MKI$(Control(i).Width) + MKI$(Control(i).Height) + MKI$(Control(i).Left) + MKI$(Control(i).Top)
                IF Control(i).ParentID > 0 THEN
                    b$ = b$ + MKI$(LEN(RTRIM$(Control(Control(i).ParentID).Name))) + RTRIM$(Control(Control(i).ParentID).Name)
                ELSE
                    b$ = b$ + MKI$(0)
                END IF

                IF Disk THEN
                    PUT #BinFileNum, , b$
                ELSE
                    Clip$ = Clip$ + b$
                END IF

                IF LEN(Caption(i)) > 0 THEN
                    IF Control(i).HotKeyPosition > 0 THEN
                        a$ = LEFT$(Caption(i), Control(i).HotKeyPosition - 1) + "&" + MID$(Caption(i), Control(i).HotKeyPosition)
                    ELSE
                        a$ = Caption(i)
                    END IF
                    b$ = MKI$(-2) + MKL$(LEN(a$)) '-2 indicates a caption
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                        PUT #BinFileNum, , a$
                    ELSE
                        Clip$ = Clip$ + b$ + a$
                    END IF
                END IF

                IF LEN(ToolTip(i)) > 0 THEN
                    b$ = MKI$(-24) + MKL$(LEN(ToolTip(i))) '-24 indicates a tip
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                        PUT #BinFileNum, , ToolTip(i)
                    ELSE
                        Clip$ = Clip$ + b$ + ToolTip(i)
                    END IF
                END IF

                IF LEN(Text(i)) > 0 THEN
                    b$ = MKI$(-3) + MKL$(LEN(Text(i))) '-3 indicates a text
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                        PUT #BinFileNum, , Text(i)
                    ELSE
                        Clip$ = Clip$ + b$ + Text(i)
                    END IF
                END IF

                IF LEN(Mask(i)) > 0 THEN
                    b$ = MKI$(-36) + MKL$(LEN(Mask(i))) '-36 indicates a mask
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                        PUT #BinFileNum, , Mask(i)
                    ELSE
                        Clip$ = Clip$ + b$ + Mask(i)
                    END IF
                END IF

                IF Control(i).TransparentColor > 0 THEN
                    b$ = MKI$(-28) + _MK$(_UNSIGNED LONG, Control(i).TransparentColor)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF

                IF Control(i).Stretch THEN
                    b$ = MKI$(-4)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                'Inheritable properties won't be saved if they are the same as the parent's
                IF Control(i).Type = __UI_Type_Form OR Destination = InClipboard THEN
                    IF Control(i).Font = 8 OR Control(i).Font = 16 THEN
                        'Internal fonts
                        SaveInternalFont:
                        FontSetup$ = "," + LTRIM$(STR$(Control(__UI_GetFontID(Control(i).Font)).Max))
                        b$ = MKI$(-5) + MKI$(LEN(FontSetup$)) + FontSetup$ + MKI$(0)
                        IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                    ELSE
                        SaveExternalFont:
                        FontSetup$ = ToolTip(__UI_GetFontID(Control(i).Font)) + "," + LTRIM$(STR$(Control(__UI_GetFontID(Control(i).Font)).Max))
                        b$ = MKI$(-5) + MKI$(LEN(FontSetup$)) + FontSetup$
                        b$ = b$ + MKI$(LEN(Text(__UI_GetFontID(Control(i).Font)))) + Text(__UI_GetFontID(Control(i).Font))
                        IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                    END IF
                ELSE
                    IF Control(i).ParentID > 0 THEN
                        IF Control(i).Font > 0 AND Control(i).Font <> Control(Control(i).ParentID).Font THEN
                            IF Control(i).Font = 8 OR Control(i).Font = 16 THEN
                                GOTO SaveInternalFont
                            ELSE
                                GOTO SaveExternalFont
                            END IF
                        END IF
                    ELSE
                        IF Control(i).Font > 0 AND Control(i).Font <> Control(__UI_FormID).Font THEN
                            IF Control(i).Font = 8 OR Control(i).Font = 16 THEN
                                GOTO SaveInternalFont
                            ELSE
                                GOTO SaveExternalFont
                            END IF
                        END IF
                    END IF
                END IF
                'Colors are saved only if they differ from the theme's defaults
                IF Control(i).ForeColor <> __UI_DefaultColor(Control(i).Type, 1) THEN
                    b$ = MKI$(-6) + _MK$(_UNSIGNED LONG, Control(i).ForeColor)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).BackColor <> __UI_DefaultColor(Control(i).Type, 2) THEN
                    b$ = MKI$(-7) + _MK$(_UNSIGNED LONG, Control(i).BackColor)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).SelectedForeColor <> __UI_DefaultColor(Control(i).Type, 3) THEN
                    b$ = MKI$(-8) + _MK$(_UNSIGNED LONG, Control(i).SelectedForeColor)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).SelectedBackColor <> __UI_DefaultColor(Control(i).Type, 4) THEN
                    b$ = MKI$(-9) + _MK$(_UNSIGNED LONG, Control(i).SelectedBackColor)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).BorderColor <> __UI_DefaultColor(Control(i).Type, 5) THEN
                    b$ = MKI$(-10) + _MK$(_UNSIGNED LONG, Control(i).BorderColor)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).BackStyle = __UI_Transparent THEN
                    b$ = MKI$(-11)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).HasBorder THEN
                    b$ = MKI$(-12)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Align = __UI_Center THEN
                    b$ = MKI$(-13) + _MK$(_BYTE, Control(i).Align)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                ELSEIF Control(i).Align = __UI_Right THEN
                    b$ = MKI$(-13) + _MK$(_BYTE, Control(i).Align)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).VAlign = __UI_Middle THEN
                    b$ = MKI$(-32) + _MK$(_BYTE, Control(i).VAlign)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                ELSEIF Control(i).VAlign = __UI_Bottom THEN
                    b$ = MKI$(-32) + _MK$(_BYTE, Control(i).VAlign)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).PasswordField = True THEN
                    b$ = MKI$(-33)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Encoding > 0 THEN
                    b$ = MKI$(-34) + MKL$(Control(i).Encoding)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Value <> 0 THEN
                    b$ = MKI$(-14) + _MK$(_FLOAT, Control(i).Value)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Min <> 0 THEN
                    b$ = MKI$(-15) + _MK$(_FLOAT, Control(i).Min)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Max <> 0 THEN
                    b$ = MKI$(-16) + _MK$(_FLOAT, Control(i).Max)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).ShowPercentage THEN
                    b$ = MKI$(-19)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).CanHaveFocus THEN
                    b$ = MKI$(-20)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Disabled THEN
                    b$ = MKI$(-21)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Hidden THEN
                    b$ = MKI$(-22)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).CenteredWindow THEN
                    b$ = MKI$(-23)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).ContextMenuID THEN
                    IF LEFT$(Control(Control(i).ContextMenuID).Name, 9) <> "__UI_Text" AND LEFT$(Control(Control(i).ContextMenuID).Name, 16) <> "__UI_PreviewMenu" THEN
                        b$ = MKI$(-25) + MKI$(LEN(RTRIM$(Control(Control(i).ContextMenuID).Name))) + RTRIM$(Control(Control(i).ContextMenuID).Name)
                        IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).Interval THEN
                    b$ = MKI$(-26) + _MK$(_FLOAT, Control(i).Interval)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).MinInterval THEN
                    b$ = MKI$(-37) + _MK$(_FLOAT, Control(i).MinInterval)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).WordWrap THEN
                    b$ = MKI$(-27)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).CanResize AND Control(i).Type = __UI_Type_Form THEN
                    b$ = MKI$(-29)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).Padding > 0 THEN
                    b$ = MKI$(-31) + MKI$(Control(i).Padding)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).NumericOnly = True THEN
                    b$ = MKI$(-38)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).NumericOnly = __UI_NumericWithBounds THEN
                    b$ = MKI$(-39)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).BulletStyle = __UI_Bullet THEN
                    b$ = MKI$(-40)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).AutoScroll = True THEN
                    b$ = MKI$(-41)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).AutoSize = True THEN
                    b$ = MKI$(-42)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).BorderSize > 0 THEN
                    b$ = MKI$(-43) + MKI$(Control(i).BorderSize)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF Control(i).KeyCombo > 0 THEN
                    b$ = MKI$(-44) + MKI$(LEN(RTRIM$(__UI_KeyCombo(Control(i).KeyCombo).FriendlyCombo))) + RTRIM$(__UI_KeyCombo(Control(i).KeyCombo).FriendlyCombo)
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
                IF GIF_IsLoaded(i) THEN
                    'PictureBox has an animated GIF loaded
                    b$ = MKI$(-45)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF i <= UBOUND(AutoPlayGif) THEN
                    IF AutoPlayGif(i) THEN
                        b$ = MKI$(-46)
                        IF Disk THEN
                            PUT #BinFileNum, , b$
                        ELSE
                            Clip$ = Clip$ + b$
                        END IF
                    END IF
                END IF
                IF Control(i).ControlIsSelected THEN
                    b$ = MKI$(-47)
                    IF Disk THEN
                        PUT #BinFileNum, , b$
                    ELSE
                        Clip$ = Clip$ + b$
                    END IF
                END IF
                IF Control(i).BoundTo > 0 THEN
                    b$ = MKI$(-48) + MKI$(LEN(RTRIM$(Control(Control(i).BoundTo).Name))) + RTRIM$(Control(Control(i).BoundTo).Name)
                    Dummy = __UI_PropertyEnum&(a$, Control(i).BoundProperty)
                    b$ = b$ + MKI$(LEN(a$)) + a$
                    IF Disk THEN PUT #BinFileNum, , b$ ELSE Clip$ = Clip$ + b$
                END IF
            END IF
        NEXT
    NEXT
    b$ = MKI$(-1024) 'end of file
    IF Disk THEN
        PUT #BinFileNum, , b$
        CLOSE #BinFileNum
    ELSEIF TCP THEN
        PreviewData$ = PreviewData$ + Clip$ + b$ + "<END>"
        IF LastPreviewDataSent$ <> PreviewData$ AND __UI_IsDragging = False AND __UI_IsResizing = False THEN
            LastPreviewDataSent$ = PreviewData$
            PUT #Host, , PreviewData$
        END IF
    ELSEIF UndoBuffer THEN
        Clip$ = Clip$ + b$
        IF UndoPointer > 0 THEN
            IF UndoImage(UndoPointer - 1) = Clip$ THEN EXIT SUB
        END IF
        UndoImage(UndoPointer) = Clip$
        UndoPointer = UndoPointer + 1
        IF UndoPointer > TotalUndoImages THEN
            TotalUndoImages = TotalUndoImages + 1
        ELSEIF UndoPointer < TotalUndoImages THEN
            TotalUndoImages = UndoPointer
        END IF
        IF TotalUndoImages > UBOUND(UndoImage) THEN
            REDIM _PRESERVE UndoImage(UBOUND(UndoImage) + 99) AS STRING
        END IF
    ELSE
        Clip$ = Clip$ + b$
        b$ = _BASE64ENCODE$(Clip$)

        IF LEN(b$) > 60 THEN
            a$ = ""
            DO
                a$ = a$ + LEFT$(b$, 60) + CHR$(10)
                b$ = MID$(b$, 61)
                IF LEN(b$) <= 60 THEN
                    a$ = a$ + b$
                    b$ = a$
                    EXIT DO
                END IF
            LOOP
        END IF

        Clip$ = __UI_ClipboardCheck$
        Clip$ = Clip$ + HEX$(LEN(b$)) + CHR$(10)
        Clip$ = Clip$ + b$ + CHR$(10)
        Clip$ = Clip$ + STRING$(60, "-") + CHR$(10)
        Clip$ = Clip$ + "END CONTROL DATA"
        _CLIPBOARD$ = Clip$ + CHR$(10) + "Controls in this block: " + tempList$
    END IF
    IF Debug THEN CLOSE #TxtFileNum
END SUB

SUB SendData (b$, thisCommand$)
    b$ = UCASE$(thisCommand$) + ">" + b$ + "<END>"
    PUT #Host, , b$
END SUB

SUB SendSignal (Value AS INTEGER)
    DIM b$
    b$ = "SIGNAL>" + MKI$(Value) + "<END>"
    PUT #Host, , b$
END SUB

FUNCTION Alpha%% (ch AS _UNSIGNED _BYTE)
    DECLARE LIBRARY
        FUNCTION __Alpha& ALIAS isalpha (BYVAL ch AS LONG)
    END DECLARE

    Alpha = __Alpha(ch) <> 0 OR ch = 95
END FUNCTION

FUNCTION AlphaNumeric%% (ch AS _UNSIGNED _BYTE)
    DECLARE LIBRARY
        FUNCTION __AlphaNumeric& ALIAS isalnum (BYVAL ch AS LONG)
    END DECLARE

    AlphaNumeric = __AlphaNumeric(ch) <> 0 OR ch = 95
END FUNCTION

FUNCTION AdaptName$ (tName$, TargetID AS LONG)
    DIM Name$, NewName$, i AS LONG, c$, NextIsCapital AS _BYTE, CheckID AS LONG
    Name$ = RTRIM$(tName$)

    '"__UI_" is reserved:
    IF UCASE$(LEFT$(Name$, 5)) = "__UI_" THEN Name$ = MID$(Name$, 6)

    IF LEN(Name$) > 0 THEN
        'First valid character must be a letter or "_":
        DO WHILE NOT Alpha(ASC(Name$, 1))
            Name$ = MID$(Name$, 2)
            IF LEN(Name$) = 0 THEN Name$ = Control(TargetID).Name: GOTO CheckDuplicates
        LOOP

        'Single "_" to start a variable name is reserved;
        'Double "_" is valid:
        IF LEFT$(Name$, 1) = "_" AND MID$(Name$, 2, 1) <> "_" THEN
            Name$ = "_" + Name$
        END IF

        'Other valid characters must be alphanumeric:
        FOR i = 1 TO LEN(Name$)
            IF AlphaNumeric(ASC(Name$, i)) THEN
                IF NextIsCapital THEN
                    NewName$ = NewName$ + UCASE$(MID$(Name$, i, 1))
                    IF ASC(RIGHT$(NewName$, 1)) >= 65 AND ASC(RIGHT$(NewName$, 1)) <= 90 THEN NextIsCapital = False
                ELSE
                    NewName$ = NewName$ + MID$(Name$, i, 1)
                END IF
            ELSE
                IF ASC(Name$, i) = 32 THEN NextIsCapital = True
            END IF
        NEXT
    ELSE
        Name$ = Control(TargetID).Name
    END IF

    IF LEN(NewName$) > 40 THEN NewName$ = LEFT$(NewName$, 40)
    Name$ = NewName$

    CheckDuplicates:
    i = 1
    DO
        CheckID = __UI_GetID(NewName$)
        IF CheckID = 0 THEN EXIT DO
        IF CheckID = TargetID THEN EXIT DO
        i = i + 1
        c$ = LTRIM$(STR$(i))
        IF LEN(Name$) + LEN(c$) <= 40 THEN
            NewName$ = Name$ + c$
        ELSE
            Name$ = MID$(Name$, 1, 40 - LEN(c$))
            NewName$ = Name$ + c$
        END IF
    LOOP

    IF IS_KEYWORD(NewName$) THEN NewName$ = "__" + NewName$

    AdaptName$ = NewName$
END FUNCTION

'READ_KEYWORDS and IS_KEYWORD come from vWATCH64:
SUB READ_KEYWORDS
    DIM ThisKeyword$, TotalKeywords AS LONG

    RESTORE QB64KeywordsDATA
    'Populate QB64KEYWORDS():
    DO
        READ ThisKeyword$
        IF ThisKeyword$ = "**END**" THEN
            EXIT DO
        END IF
        TotalKeywords = TotalKeywords + 1
        REDIM _PRESERVE QB64KEYWORDS(1 TO TotalKeywords) AS STRING
        QB64KEYWORDS(TotalKeywords) = UCASE$(ThisKeyword$)
    LOOP

    QB64KeywordsDATA:
    DATA $CHECKING,$CONSOLE,$DYNAMIC,$ELSE,$ELSEIF,$END,$ENDIF,$EXEICON,$IF,$INCLUDE
    DATA $LET,$RESIZE,$SCREENHIDE,$SCREENSHOW,$STATIC,$VERSIONINFO,$VIRTUALKEYBOARD,ABS
    DATA ABSOLUTE,ACCESS,ALIAS,AND,APPEND,AS,ASC,ATN,BASE,BEEP,BINARY,BLOAD,BSAVE,BYVAL
    DATA CALL,CALLS,CASE,IS,CDBL,CDECL,CHAIN,CHDIR,CHR$,CINT,CIRCLE,CLEAR,CLNG,CLOSE
    DATA CLS,COLOR,COM,COMMAND$,COMMON,CONST,COS,CSNG,CSRLIN,CUSTOMTYPE,CVD,CVDMBF,CVI
    DATA CVL,CVS,CVSMBF,DATA,DATE$,DECLARE,DEF,DEFDBL,DEFINT,DEFLNG,DEFSNG,DEFSTR,DIM
    DATA DO,DOUBLE,DRAW,DYNAMIC,ELSE,ELSEIF,END,ENDIF,ENVIRON,ENVIRON$,EOF,EQV,ERASE
    DATA ERDEV,ERDEV$,ERL,ERR,ERROR,EVERYCASE,EXIT,EXP,FIELD,FILEATTR,FILES,FIX,FN,FOR
    DATA FRE,FREE,FREEFILE,FUNCTION,GET,GOSUB,GOTO,HEX$,IF,IMP,INKEY$,INP,INPUT,INPUT$
    DATA INSTR,INT,INTEGER,INTERRUPT,INTERRUPTX,IOCTL,IOCTL$,KEY,KILL,LBOUND,LCASE$,LEFT$
    DATA LEN,LET,LIBRARY,LINE,LIST,LOC,LOCATE,LOCK,LOF,LOG,LONG,LOOP,LPOS,LPRINT,LSET
    DATA LTRIM$,MID$,MKD$,MKDIR,MKDMBF$,MKI$,MKL$,MKS$,MKSMBF$,MOD,NAME,NEXT,NOT,OCT$
    DATA OFF,ON,OPEN,OPTION,OR,OUT,OUTPUT,PAINT,PALETTE,PCOPY,PEEK,PEN,PLAY,PMAP,POINT
    DATA POKE,POS,PRESET,PRINT,PSET,PUT,RANDOM,RANDOMIZE,READ,REDIM,REM,RESET,RESTORE
    DATA RESUME,RETURN,RIGHT$,RMDIR,RND,RSET,RTRIM$,RUN,SADD,SCREEN,SEEK,SEG,SELECT,SETMEM
    DATA SGN,SHARED,SHELL,SIGNAL,SIN,SINGLE,SLEEP,SOUND,SPACE$,SPC,SQR,STATIC,STEP,STICK
    DATA STOP,STR$,STRIG,STRING,STRING$,SUB,SWAP,SYSTEM,TAB,TAN,THEN,TIME$,TIMER,TO,TROFF
    DATA TRON,TYPE,UBOUND,UCASE$,UEVENT,UNLOCK,UNTIL,USING,VAL,VARPTR,VARPTR$,VARSEG
    DATA VIEW,WAIT,WEND,WHILE,WIDTH,WINDOW,WRITE,XOR,_ACOS,_ACOSH,_ALPHA,_ALPHA32,_ARCCOT
    DATA _ARCCSC,_ARCSEC,_ASIN,_ASINH,_ATAN2,_ATANH,_AUTODISPLAY,_AXIS,_BACKGROUNDCOLOR
    DATA _BIT,_BLEND,_BLINK,_BLUE,_BLUE32,_BUTTON,_BUTTONCHANGE,_BYTE,_CEIL,_CLEARCOLOR
    DATA _CLIP,_CLIPBOARD$,_CLIPBOARDIMAGE,_COMMANDCOUNT,_CONNECTED,_CONNECTIONADDRESS$
    DATA _CONSOLE,_CONSOLETITLE,_CONTINUE,_CONTROLCHR,_COPYIMAGE,_COPYPALETTE,_COSH,_COT
    DATA _COTH,_CSC,_CSCH,_CV,_CWD$,_D2G,_D2R,_DEFAULTCOLOR,_DEFINE,_DELAY,_DEPTHBUFFER
    DATA _DESKTOPHEIGHT,_DESKTOPWIDTH,_DEST,_DEVICE$,_DEVICEINPUT,_DEVICES,_DIR$,_DIREXISTS
    DATA _DISPLAY,_DISPLAYORDER,_DONTBLEND,_DONTWAIT,_ERRORLINE,_EXIT,_EXPLICIT,_FILEEXISTS
    DATA _FLOAT,_FONT,_FONTHEIGHT,_FONTWIDTH,_FREEFONT,_FREEIMAGE,_FREETIMER,_FULLSCREEN
    DATA _G2D,_G2R,_GLRENDER,_GREEN,_GREEN32,_HEIGHT,_HIDE,_HYPOT,_ICON,_INCLERRORFILE$
    DATA _INCLERRORLINE,_INTEGER64,_KEYCLEAR,_KEYDOWN,_KEYHIT,_LASTAXIS,_LASTBUTTON,_LASTWHEEL
    DATA _LIMIT,_LOADFONT,_LOADIMAGE,_MAPTRIANGLE,_MAPUNICODE,_MEM,_MEMCOPY,_MEMELEMENT
    DATA _MEMEXISTS,_MEMFILL,_MEMFREE,_MEMGET,_MEMIMAGE,_MEMNEW,_MEMPUT,_MIDDLE,_MK$
    DATA _MOUSEBUTTON,_MOUSEHIDE,_MOUSEINPUT,_MOUSEMOVE,_MOUSEMOVEMENTX,_MOUSEMOVEMENTY
    DATA _MOUSEPIPEOPEN,_MOUSESHOW,_MOUSEWHEEL,_MOUSEX,_MOUSEY,_NEWIMAGE,_OFFSET,_OPENCLIENT
    DATA _OPENCONNECTION,_OPENHOST,_OS$,_PALETTECOLOR,_PI,_PIXELSIZE,_PRESERVE,_PRINTIMAGE
    DATA _PRINTMODE,_PRINTSTRING,_PRINTWIDTH,_PUTIMAGE,_R2D,_R2G,_RED,_RED32,_RESIZE
    DATA _RESIZEHEIGHT,_RESIZEWIDTH,_RGB,_RGB32,_RGBA,_RGBA32,_ROUND,_SCREENCLICK,_SCREENEXISTS
    DATA _SCREENHIDE,_SCREENICON,_SCREENIMAGE,_SCREENMOVE,_SCREENPRINT,_SCREENSHOW,_SCREENX
    DATA _SCREENY,_SEC,_SECH,_SETALPHA,_SHELLHIDE,_SINH,_SNDBAL,_SNDCLOSE,_SNDCOPY,_SNDGETPOS
    DATA _SNDLEN,_SNDLIMIT,_SNDLOOP,_SNDOPEN,_SNDOPENRAW,_SNDPAUSE,_SNDPAUSED,_SNDPLAY
    DATA _SNDPLAYCOPY,_SNDPLAYFILE,_SNDPLAYING,_SNDRATE,_SNDRAW,_SNDRAWDONE,_SNDRAWLEN
    DATA _SNDSETPOS,_SNDSTOP,_SNDVOL,_SOURCE,_STARTDIR$,_STRCMP,_STRICMP,_TANH,_TITLE
    DATA _TITLE$,_UNSIGNED,_WHEEL,_WIDTH,_WINDOWHANDLE,_WINDOWHASFOCUS,_GLACCUM,_GLALPHAFUNC
    DATA _GLARETEXTURESRESIDENT,_GLARRAYELEMENT,_GLBEGIN,_GLBINDTEXTURE,_GLBITMAP,_GLBLENDFUNC
    DATA _GLCALLLIST,_GLCALLLISTS,_GLCLEAR,_GLCLEARACCUM,_GLCLEARCOLOR,_GLCLEARDEPTH
    DATA _GLCLEARINDEX,_GLCLEARSTENCIL,_GLCLIPPLANE,_GLCOLOR3B,_GLCOLOR3BV,_GLCOLOR3D
    DATA _GLCOLOR3DV,_GLCOLOR3F,_GLCOLOR3FV,_GLCOLOR3I,_GLCOLOR3IV,_GLCOLOR3S,_GLCOLOR3SV
    DATA _GLCOLOR3UB,_GLCOLOR3UBV,_GLCOLOR3UI,_GLCOLOR3UIV,_GLCOLOR3US,_GLCOLOR3USV,_GLCOLOR4B
    DATA _GLCOLOR4BV,_GLCOLOR4D,_GLCOLOR4DV,_GLCOLOR4F,_GLCOLOR4FV,_GLCOLOR4I,_GLCOLOR4IV
    DATA _GLCOLOR4S,_GLCOLOR4SV,_GLCOLOR4UB,_GLCOLOR4UBV,_GLCOLOR4UI,_GLCOLOR4UIV,_GLCOLOR4US
    DATA _GLCOLOR4USV,_GLCOLORMASK,_GLCOLORMATERIAL,_GLCOLORPOINTER,_GLCOPYPIXELS,_GLCOPYTEXIMAGE1D
    DATA _GLCOPYTEXIMAGE2D,_GLCOPYTEXSUBIMAGE1D,_GLCOPYTEXSUBIMAGE2D,_GLCULLFACE,_GLDELETELISTS
    DATA _GLDELETETEXTURES,_GLDEPTHFUNC,_GLDEPTHMASK,_GLDEPTHRANGE,_GLDISABLE,_GLDISABLECLIENTSTATE
    DATA _GLDRAWARRAYS,_GLDRAWBUFFER,_GLDRAWELEMENTS,_GLDRAWPIXELS,_GLEDGEFLAG,_GLEDGEFLAGPOINTER
    DATA _GLEDGEFLAGV,_GLENABLE,_GLENABLECLIENTSTATE,_GLEND,_GLENDLIST,_GLEVALCOORD1D
    DATA _GLEVALCOORD1DV,_GLEVALCOORD1F,_GLEVALCOORD1FV,_GLEVALCOORD2D,_GLEVALCOORD2DV
    DATA _GLEVALCOORD2F,_GLEVALCOORD2FV,_GLEVALMESH1,_GLEVALMESH2,_GLEVALPOINT1,_GLEVALPOINT2
    DATA _GLFEEDBACKBUFFER,_GLFINISH,_GLFLUSH,_GLFOGF,_GLFOGFV,_GLFOGI,_GLFOGIV,_GLFRONTFACE
    DATA _GLFRUSTUM,_GLGENLISTS,_GLGENTEXTURES,_GLGETBOOLEANV,_GLGETCLIPPLANE,_GLGETDOUBLEV
    DATA _GLGETERROR,_GLGETFLOATV,_GLGETINTEGERV,_GLGETLIGHTFV,_GLGETLIGHTIV,_GLGETMAPDV
    DATA _GLGETMAPFV,_GLGETMAPIV,_GLGETMATERIALFV,_GLGETMATERIALIV,_GLGETPIXELMAPFV,_GLGETPIXELMAPUIV
    DATA _GLGETPIXELMAPUSV,_GLGETPOINTERV,_GLGETPOLYGONSTIPPLE,_GLGETSTRING,_GLGETTEXENVFV
    DATA _GLGETTEXENVIV,_GLGETTEXGENDV,_GLGETTEXGENFV,_GLGETTEXGENIV,_GLGETTEXIMAGE,_GLGETTEXLEVELPARAMETERFV
    DATA _GLGETTEXLEVELPARAMETERIV,_GLGETTEXPARAMETERFV,_GLGETTEXPARAMETERIV,_GLHINT
    DATA _GLINDEXMASK,_GLINDEXPOINTER,_GLINDEXD,_GLINDEXDV,_GLINDEXF,_GLINDEXFV,_GLINDEXI
    DATA _GLINDEXIV,_GLINDEXS,_GLINDEXSV,_GLINDEXUB,_GLINDEXUBV,_GLINITNAMES,_GLINTERLEAVEDARRAYS
    DATA _GLISENABLED,_GLISLIST,_GLISTEXTURE,_GLLIGHTMODELF,_GLLIGHTMODELFV,_GLLIGHTMODELI
    DATA _GLLIGHTMODELIV,_GLLIGHTF,_GLLIGHTFV,_GLLIGHTI,_GLLIGHTIV,_GLLINESTIPPLE,_GLLINEWIDTH
    DATA _GLLISTBASE,_GLLOADIDENTITY,_GLLOADMATRIXD,_GLLOADMATRIXF,_GLLOADNAME,_GLLOGICOP
    DATA _GLMAP1D,_GLMAP1F,_GLMAP2D,_GLMAP2F,_GLMAPGRID1D,_GLMAPGRID1F,_GLMAPGRID2D,_GLMAPGRID2F
    DATA _GLMATERIALF,_GLMATERIALFV,_GLMATERIALI,_GLMATERIALIV,_GLMATRIXMODE,_GLMULTMATRIXD
    DATA _GLMULTMATRIXF,_GLNEWLIST,_GLNORMAL3B,_GLNORMAL3BV,_GLNORMAL3D,_GLNORMAL3DV
    DATA _GLNORMAL3F,_GLNORMAL3FV,_GLNORMAL3I,_GLNORMAL3IV,_GLNORMAL3S,_GLNORMAL3SV,_GLNORMALPOINTER
    DATA _GLORTHO,_GLPASSTHROUGH,_GLPIXELMAPFV,_GLPIXELMAPUIV,_GLPIXELMAPUSV,_GLPIXELSTOREF
    DATA _GLPIXELSTOREI,_GLPIXELTRANSFERF,_GLPIXELTRANSFERI,_GLPIXELZOOM,_GLPOINTSIZE
    DATA _GLPOLYGONMODE,_GLPOLYGONOFFSET,_GLPOLYGONSTIPPLE,_GLPOPATTRIB,_GLPOPCLIENTATTRIB
    DATA _GLPOPMATRIX,_GLPOPNAME,_GLPRIORITIZETEXTURES,_GLPUSHATTRIB,_GLPUSHCLIENTATTRIB
    DATA _GLPUSHMATRIX,_GLPUSHNAME,_GLRASTERPOS2D,_GLRASTERPOS2DV,_GLRASTERPOS2F,_GLRASTERPOS2FV
    DATA _GLRASTERPOS2I,_GLRASTERPOS2IV,_GLRASTERPOS2S,_GLRASTERPOS2SV,_GLRASTERPOS3D
    DATA _GLRASTERPOS3DV,_GLRASTERPOS3F,_GLRASTERPOS3FV,_GLRASTERPOS3I,_GLRASTERPOS3IV
    DATA _GLRASTERPOS3S,_GLRASTERPOS3SV,_GLRASTERPOS4D,_GLRASTERPOS4DV,_GLRASTERPOS4F
    DATA _GLRASTERPOS4FV,_GLRASTERPOS4I,_GLRASTERPOS4IV,_GLRASTERPOS4S,_GLRASTERPOS4SV
    DATA _GLREADBUFFER,_GLREADPIXELS,_GLRECTD,_GLRECTDV,_GLRECTF,_GLRECTFV,_GLRECTI,_GLRECTIV
    DATA _GLRECTS,_GLRECTSV,_GLRENDERMODE,_GLROTATED,_GLROTATEF,_GLSCALED,_GLSCALEF,_GLSCISSOR
    DATA _GLSELECTBUFFER,_GLSHADEMODEL,_GLSTENCILFUNC,_GLSTENCILMASK,_GLSTENCILOP,_GLTEXCOORD1D
    DATA _GLTEXCOORD1DV,_GLTEXCOORD1F,_GLTEXCOORD1FV,_GLTEXCOORD1I,_GLTEXCOORD1IV,_GLTEXCOORD1S
    DATA _GLTEXCOORD1SV,_GLTEXCOORD2D,_GLTEXCOORD2DV,_GLTEXCOORD2F,_GLTEXCOORD2FV,_GLTEXCOORD2I
    DATA _GLTEXCOORD2IV,_GLTEXCOORD2S,_GLTEXCOORD2SV,_GLTEXCOORD3D,_GLTEXCOORD3DV,_GLTEXCOORD3F
    DATA _GLTEXCOORD3FV,_GLTEXCOORD3I,_GLTEXCOORD3IV,_GLTEXCOORD3S,_GLTEXCOORD3SV,_GLTEXCOORD4D
    DATA _GLTEXCOORD4DV,_GLTEXCOORD4F,_GLTEXCOORD4FV,_GLTEXCOORD4I,_GLTEXCOORD4IV,_GLTEXCOORD4S
    DATA _GLTEXCOORD4SV,_GLTEXCOORDPOINTER,_GLTEXENVF,_GLTEXENVFV,_GLTEXENVI,_GLTEXENVIV
    DATA _GLTEXGEND,_GLTEXGENDV,_GLTEXGENF,_GLTEXGENFV,_GLTEXGENI,_GLTEXGENIV,_GLTEXIMAGE1D
    DATA _GLTEXIMAGE2D,_GLTEXPARAMETERF,_GLTEXPARAMETERFV,_GLTEXPARAMETERI,_GLTEXPARAMETERIV
    DATA _GLTEXSUBIMAGE1D,_GLTEXSUBIMAGE2D,_GLTRANSLATED,_GLTRANSLATEF,_GLVERTEX2D,_GLVERTEX2DV
    DATA _GLVERTEX2F,_GLVERTEX2FV,_GLVERTEX2I,_GLVERTEX2IV,_GLVERTEX2S,_GLVERTEX2SV,_GLVERTEX3D
    DATA _GLVERTEX3DV,_GLVERTEX3F,_GLVERTEX3FV,_GLVERTEX3I,_GLVERTEX3IV,_GLVERTEX3S,_GLVERTEX3SV
    DATA _GLVERTEX4D,_GLVERTEX4DV,_GLVERTEX4F,_GLVERTEX4FV,_GLVERTEX4I,_GLVERTEX4IV,_GLVERTEX4S
    DATA _GLVERTEX4SV,_GLVERTEXPOINTER,_GLVIEWPORT,_ANTICLOCKWISE,_BEHIND,_CLEAR,_FILLBACKGROUND
    DATA _GLUPERSPECTIVE,_HARDWARE,_HARDWARE1,_KEEPBACKGROUND,_NONE,_OFF,_ONLY,_ONLYBACKGROUND
    DATA _ONTOP,_SEAMLESS,_SMOOTH,_SMOOTHSHRUNK,_SMOOTHSTRETCHED,_SOFTWARE,_SQUAREPIXELS
    DATA _STRETCH
    DATA uprint_extra,uprint,uprintwidth,uheight&,uheight,falcon_uspacing&
    DATA falcon_uspacing,uascension&,uascension,GetSystemMetrics&
    DATA GetSystemMetrics,uspacing&,uspacing,SetFrameRate,SetFocus
    DATA AutoSizeLabel,Darken~&,Darken,isNumber%%,isNumber,RawText$,RawText
    DATA SetFont&,SetFont,SetCaption,BeginDraw,EndDraw,LoadImage
    DATA SetRadioButtonValue,Replace$,Replace,AddItem,RemoveItem,ResetList
    DATA ReplaceItem,SelectItem%%,SelectItem,GetItem$,GetItem,MessageBox&
    DATA MessageBox,FromCP437$,FromCP437,FromCP1252$,FromCP1252,UTF8$,UTF8
    DATA GetControlDrawOrder&,GetControlDrawOrder,IconPreview&,IconPreview
    DATA RestoreCHR$,RestoreCHR,MsgBox_OkOnly%%,MsgBox_OkOnly
    DATA MsgBox_OkCancel%%,MsgBox_OkCancel,MsgBox_AbortRetryIgnore%%
    DATA MsgBox_AbortRetryIgnore,MsgBox_YesNoCancel%%,MsgBox_YesNoCancel
    DATA MsgBox_YesNo%%,MsgBox_YesNo,MsgBox_RetryCancel%%,MsgBox_RetryCancel
    DATA MsgBox_CancelTryagainContinue%%,MsgBox_CancelTryagainContinue
    DATA MsgBox_Critical%,MsgBox_Critical,MsgBox_Question%,MsgBox_Question
    DATA MsgBox_Exclamation%,MsgBox_Exclamation,MsgBox_Information%
    DATA MsgBox_Information,MsgBox_DefaultButton1%,MsgBox_DefaultButton1
    DATA MsgBox_DefaultButton2%,MsgBox_DefaultButton2,MsgBox_DefaultButton3%
    DATA MsgBox_DefaultButton3,MsgBox_Defaultbutton4%,MsgBox_Defaultbutton4
    DATA MsgBox_AppModal%%,MsgBox_AppModal,MsgBox_SystemModal%
    DATA MsgBox_SystemModal,MsgBox_SetForeground&,MsgBox_SetForeground
    DATA MsgBox_Ok%%,MsgBox_Ok,MsgBox_Cancel%%,MsgBox_Cancel,MsgBox_Abort%%
    DATA MsgBox_Abort,MsgBox_Retry%%,MsgBox_Retry,MsgBox_Ignore%%
    DATA MsgBox_Ignore,MsgBox_Yes%%,MsgBox_Yes,MsgBox_No%%,MsgBox_No
    DATA MsgBox_Tryagain%%,MsgBox_Tryagain,MsgBox_Continue%%,MsgBox_Continue
    DATA **END**
END SUB

FUNCTION IS_KEYWORD (Text$)
    DIM uText$, i AS LONG
    uText$ = UCASE$(_TRIM$(Text$))
    FOR i = 1 TO UBOUND(QB64KEYWORDS)
        IF QB64KEYWORDS(i) = uText$ THEN IS_KEYWORD = True: EXIT FUNCTION
    NEXT i
END FUNCTION

SUB SaveUndoImage
    SavePreview ToUndoBuffer
END SUB

SUB RestoreUndoImage
    IF UndoPointer = 0 THEN EXIT SUB
    UndoPointer = UndoPointer - 1
    LoadPreview ToUndoBuffer
END SUB

SUB RestoreRedoImage
    IF UndoPointer = TotalUndoImages THEN EXIT SUB
    UndoPointer = UndoPointer + 1
    LoadPreview ToUndoBuffer
END SUB

SUB LoadDefaultFonts
    IF Control(__UI_FormID).Font = 8 OR Control(__UI_FormID).Font = 16 THEN
        Control(__UI_FormID).Font = SetFont(__INFORM_DEFAULT_FONTS, 12)
    END IF
END SUB

' Use this to store editor images and bitmaps
' Take care not to call multiple times for the same image as it will create a new _IMAGE everytime it is called!
FUNCTION LoadEditorImage& (id AS _UNSIGNED _BYTE)
    SELECT CASE id
        CASE EDITOR_IMAGE_CONTEXTMENU
            CONST SIZE_CONTEXTMENU_BMP_1146~& = 1146~&
            CONST COMP_CONTEXTMENU_BMP_1146%% = -1%%
            CONST DATA_CONTEXTMENU_BMP_1146 = _
                "eNpy8q1iYQCDKiDOAWIBKGZkUGBgZsAF/kMQjEMGADRLhkwBAkEU9qcZjUaamDQpCYy2uyQmPJNQ4CCAFKtG0vFrAKA8zx1mx1FHOcdgeLPp49vH" + _
                "Hg6Av8hDXiPJcyRFY1Mg1Q3utIbSj1Bliaxsad5XrU31kSd2GAaM40jpug5939NcloWzrit94zNfM2+enxBH53irp26vcXV6hOD4kPmv/KEQzMeR" + _
                "j2maiN/rvwnPYIyhiEvmoaT1e9bvfe8XFyfYbkg72OnQn/y8/8Zz2kz90J/873nef57nX/tfGg0ZeNTfwU+s9VNc/Zal+6cyojcgA3/P/fn/c393" + _
                "v/v7/wd5BeeEEdg="

            LoadEditorImage = _LOADIMAGE(Base64_LoadResourceString(DATA_CONTEXTMENU_BMP_1146, SIZE_CONTEXTMENU_BMP_1146, COMP_CONTEXTMENU_BMP_1146), 32, "memory")

        CASE ELSE
            ERROR 51
    END SELECT
END FUNCTION
