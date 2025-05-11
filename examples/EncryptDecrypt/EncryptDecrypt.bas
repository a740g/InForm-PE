': This program uses
': InForm - GUI library for QB64 - Beta version 7
': Fellippe Heitor, 2016-2018 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
REM NOTICE: THIS FORM HAS BEEN RECENTLY EDITED
'>> The controls in the list below may have been added or renamed,
'>> and previously existing controls may have been deleted since
'>> this program's structure was first generated.
'>> Make sure to check your code in the events SUBs so that
'>> you can take your recent edits into consideration.

': -------------------------------------USER'S Declaration CONST and VARIABLES--------------------------------------------
CONST MessageConst = "QB64 is the best evolution of QB4.5 and PDS 7.1 for multiplatform BASIC programming. Moreover Inform is a powerful tool to use hardly for our projects."
CONST StepConst = 1, JumpConst = 0, IncreaseConst = 3
CONST ALPHAbeta = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" '26 maiuscole + 26 minuscole + 10 cifre
DIM SHARED jump%, DecrMessage$
jump% = JumpConst

'------------------------- Inform Shared variables---------
DIM SHARED EncryptDecrypt AS LONG
DIM SHARED ChooseMethodOfCryptingLB AS LONG
DIM SHARED DropdownList1 AS LONG
DIM SHARED SettingValuesForCryptingLB AS LONG
DIM SHARED StepLB AS LONG
DIM SHARED TextBox1 AS LONG
DIM SHARED HowCharactersToJumpLB AS LONG
DIM SHARED TextBox2 AS LONG
DIM SHARED MessageToCryptLB AS LONG
DIM SHARED TextBox3 AS LONG
DIM SHARED MessageAtStartAsWrittenByUserLB AS LONG
DIM SHARED EncryptBT AS LONG
DIM SHARED EncryptedMessageLB AS LONG
DIM SHARED DecryptBT AS LONG
DIM SHARED DecryptedMessageLB AS LONG
DIM SHARED TextBox4 AS LONG
DIM SHARED IncreaseLB AS LONG
DIM SHARED SeedLB AS LONG
DIM SHARED TextBox5 AS LONG


'$INCLUDE:'../../InForm/InForm.bi'
'$INCLUDE:'EncryptDecrypt.frm'
'$INCLUDE:'../../InForm/InForm.ui'

'---------------USER'S PROCEDURES---------------------------------------------------

SUB encryptProg (Messag$, step1%, steps%, seed%, jump%)
    ' step1% chooses the method, step2% chooses the step of sequence to add to seed
    ' seed% is the starting value
    msg$ = Messag$
    MsgLen% = LEN(msg$)
    DecrMessage$ = ""
    step2% = steps%
    b% = 0
    c% = LEN(ALPHAbeta)
    st1% = seed%
    sign% = 1

    SELECT CASE step1%
        CASE 1 ' progressive linear method increasing (+) by 1-2-3-4 starting from seed%
            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + step2% 'increasing the added factor
                        step2% = step2% + 1 ' linear increasing sequence
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF (pos1% + st1%) > c% THEN pos1% = (pos1% + st1%) - c% ELSE pos1% = pos1% + st1%
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0

                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT

        CASE 2 ' progressive linear method decreasing (-) by 1-2-3-4 from seed%

            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + step2%
                        step2% = step2% + 1 'increasing the added factor
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF (pos1% - st1%) < 1 THEN pos1% = (pos1% - st1%) + c% ELSE pos1% = pos1% - st1%
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0
                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT

        CASE 3, 4 ' progressive linear method  alternating +/- vs -/+ by 1-2-3-4 from seed%
            IF step1% = 4 THEN sign% = -1
            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + step2%
                        step2% = step2% + 1 'increasing the added factor
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF sign% = 1 THEN
                            IF (pos1% + st1%) > c% THEN pos1% = (pos1% + st1%) - c% ELSE pos1% = pos1% + st1%
                        ELSE
                            IF (pos1% - st1%) < 1 THEN pos1% = (pos1% - st1%) + c% ELSE pos1% = pos1% - st1%
                        END IF
                        sign% = sign% * -1
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0
                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT

        CASE 5 ' progressive quadratic method increasing by 1^2 +seed%, 2^2 + seed%, 3^2+ seed%
            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + (step2% ^ 2) 'increasing the added factor
                        step2% = step2% + 1 ' linear increasing sequence
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF (pos1% + st1%) > c% THEN pos1% = (pos1% + st1%) - c% ELSE pos1% = pos1% + st1%
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0

                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT

        CASE 6 ' progressive quadratic method decreasing by 1^2 +seed%, 2^2 + seed%, 3^2+ seed%

            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + step2% ^ 2
                        step2% = step2% + 1 'increasing the added factor
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF (pos1% - st1%) < 1 THEN pos1% = (pos1% - st1%) + c% ELSE pos1% = pos1% - st1%
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0
                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT

        CASE 7, 8 ' progressive quadratic method alternating +/- vs -/+ by 1^2 +seed%, 2^2 + seed%, 3^2+ seed%

            IF step1% = 8 THEN sign% = -1
            FOR a% = 1 TO MsgLen% STEP 1
                ch$ = MID$(msg$, a%, 1)
                IF b% < jump% THEN
                    b% = b% + 1
                ELSE
                    IF INSTR(ALPHAbeta, ch$) > 0 THEN
                        pos1% = INSTR(ALPHAbeta, ch$)
                        st1% = st1% + step2%
                        step2% = step2% + 1 'increasing the added factor
                        IF st1% > c% THEN st1% = st1% MOD c%
                        IF sign% = 1 THEN
                            IF (pos1% + st1%) > c% THEN pos1% = (pos1% + st1%) - c% ELSE pos1% = pos1% + st1%
                        ELSE
                            IF (pos1% - st1%) < 1 THEN pos1% = (pos1% - st1%) + c% ELSE pos1% = pos1% - st1%
                        END IF
                        sign% = sign% * -1
                        ch$ = MID$(ALPHAbeta, pos1%, 1)
                    END IF
                    b% = 0
                END IF
                DecrMessage$ = DecrMessage$ + ch$
            NEXT
        CASE ELSE
    END SELECT

END SUB


SUB encryptFixF (Messag$, step2%)
    ' crypting fixed forward
    msg$ = Messag$
    IF step2% > 0 THEN step1% = step2% ELSE step1% = -step2% ' step2% is always positive
    MsgLen% = LEN(msg$)
    DecrMessage$ = ""

    b% = 0
    c% = LEN(ALPHAbeta)

    FOR a% = 1 TO MsgLen% STEP 1
        ch$ = MID$(msg$, a%, 1)
        IF b% < jump% THEN
            b% = b% + 1
        ELSE
            IF INSTR(ALPHAbeta, ch$) > 0 THEN
                pos1% = INSTR(ALPHAbeta, ch$)
                IF (pos1% + step1%) > c% THEN pos1% = (pos1% + step1%) - c% ELSE pos1% = pos1% + step1%
                ch$ = MID$(ALPHAbeta, pos1%, 1)
            END IF
            b% = 0
        END IF
        DecrMessage$ = DecrMessage$ + ch$
    NEXT

END SUB

SUB encryptFixB (Messag$, step2%)
    ' crypting fixed backward
    msg$ = Messag$
    IF step2% < 0 THEN step1% = step2% ELSE step1% = -step2%
    MsgLen% = LEN(msg$)
    DecrMessage$ = ""

    b% = 0
    c% = LEN(ALPHAbeta)

    FOR a% = 1 TO MsgLen% STEP 1
        ch$ = MID$(msg$, a%, 1)
        IF b% < jump% THEN
            b% = b% + 1
        ELSE

            IF INSTR(ALPHAbeta, ch$) > 0 THEN
                pos1% = INSTR(ALPHAbeta, ch$)
                IF (pos1% + step1%) < 1 THEN pos1% = (pos1% + step1%) + c% ELSE pos1% = pos1% + step1%
                ch$ = MID$(ALPHAbeta, pos1%, 1)
            END IF
            b% = 0
        END IF
        DecrMessage$ = DecrMessage$ + ch$
    NEXT
END SUB

SUB Decrypt
    IF DecrMessage$ = "" THEN EXIT SUB ' this fix bug to trigger always decrypting event
    msg$ = DecrMessage$
    DecrMessage$ = ""
    jump% = VAL(Text(TextBox2))
    move% = VAL(Text(TextBox1))
    seed% = VAL(Text(Texbox5))

    SELECT CASE Control(DropdownList1).Value
        CASE 1
            encryptFixB msg$, move%
        CASE 2
            encryptFixF msg$, move%
        CASE 3
            encryptProg msg$, 2, move%, seed%, jump%
        CASE 4
            encryptProg msg$, 1, move%, seed%, jump%
        CASE 5
            encryptProg msg$, 4, move%, seed%, jump%
        CASE 6
            encryptProg msg$, 3, move%, seed%, jump%
        CASE 7
            encryptProg msg$, 6, move%, seed%, jump%
        CASE 8
            encryptProg msg$, 5, move%, seed%, jump%
        CASE 9
            encryptProg msg$, 8, move%, seed%, jump%
        CASE 10
            encryptProg msg$, 7, move%, seed%, jump%
        CASE ELSE
    END SELECT
    Caption(DecryptedMessageLB) = DecrMessage$
    DecrMessage$ = "" ' flag to stop decryptying to infinite
END SUB

SUB Encrypt
    msg$ = Text(TextBox3)
    jump% = VAL(Text(TextBox2))
    move% = VAL(Text(TextBox1))
    seed% = VAL(Text(Texbox5))
    DecrMessage$ = ""

    SELECT CASE Control(DropdownList1).Value
        CASE 1
            encryptFixF msg$, move%
        CASE 2
            encryptFixB msg$, move%
        CASE 3
            encryptProg msg$, 1, move%, seed%, jump%
        CASE 4
            encryptProg msg$, 2, move%, seed%, jump%
        CASE 5
            encryptProg msg$, 3, move%, seed%, jump%
        CASE 6
            encryptProg msg$, 4, move%, seed%, jump%
        CASE 7
            encryptProg msg$, 5, move%, seed%, jump%
        CASE 8
            encryptProg msg$, 6, move%, seed%, jump%
        CASE 9
            encryptProg msg$, 7, move%, seed%, jump%
        CASE 10
            encryptProg msg$, 8, move%, seed%, jump%


        CASE ELSE
            DecrMessage$ = " NOT YET IMPLEMENTED"
    END SELECT
    Caption(EncryptedMessageLB) = DecrMessage$
END SUB


SUB activateItem
    'it enables items of method of crypting choosen
    Control(StepLB).Disabled = False
    Control(HowCharactersToJumpLB).Disabled = False
    Control(increasepLB).Disabled = False
    Control(TextBox1).Disabled = False
    Control(TextBox2).Disabled = False
    Control(TextBox3).Disabled = False
    Control(TextBox4).Disabled = False
    Control(MessageToCryptLB).Disabled = False
    Control(EncryptBT).Disabled = False
    Control(DecryptBT).Disabled = False
END SUB

SUB disableItem
    'it disables items of method of crypting waiting what to show
    Control(StepLB).Disabled = True
    Control(HowCharactersToJumpLB).Disabled = True
    Control(increasepLB).Disabled = True
    Control(TextBox1).Disabled = True
    Control(TextBox2).Disabled = True
    Control(TextBox3).Disabled = True
    Control(TextBox4).Disabled = True
    Control(MessageToCryptLB).Disabled = True
    Control(EncryptBT).Disabled = True
    Control(DecryptBT).Disabled = True
END SUB


SUB SetValues
    ' this runs when value of DropDownlist is changed
    'set to default if no setting by user
    IF Control(TextBox1).Disabled = True THEN activateItem
    IF VAL(Text(TextBox1)) = 0 THEN Text(TextBox1) = STR$(StepConst) 'step of traslation default 1 shifting value
    IF VAL(Text(TextBox2)) = 0 THEN Text(TextBox2) = STR$(JumpConst) 'number of characters to jump default none
    IF LEN(Text(TextBox3)) = 0 THEN
        Text(TextBox3) = MessageConst 'message to code default
        SetCaption MessageAtStartAsWrittenByUserLB, MessageConst
    END IF
    IF Control(DropdownList1).Value > 2 THEN
        IF VAL(Text(TextBox4)) = 0 THEN Text(TextBox4) = STR$(IncreaseConst)
    END IF
    SetCaption EncryptedMessageLB, CHR$(32)
    Caption(DecryptedMessageLB) = " " 'SetCaption DecryptedMessageLB, " "

END SUB


': Event procedures: ---------------------------------------------------------------



SUB __UI_BeforeInit
    ' enlarging label of results and textbox3 of message to crypt
    Control(MessageAtStartAsWrittenByUserLB).WordWrap = True

    Control(EncryptedMessageLB).WordWrap = True

    Control(DecryptedMessageLB).WordWrap = True

    Control(TextBox3).WordWrap = True

END SUB

SUB __UI_OnLoad
    disableItem

    ' list of cryptography's methods
    AddItem DropdownList1, "Traslation simple fixed forward" 'a->d = a+3, b->e = b+3, c->f = c+3...z->c z+3-(maxletters=26)
    AddItem DropdownList1, "Traslation simple fixed backward" 'a-3 b-3 c-3
    AddItem DropdownList1, "Traslation simple progressive forward" 'a->d = a+3, b->f = b+4, c->h = c+5...z->c z+29-(maxletters=26)
    AddItem DropdownList1, "Traslation simple progressive backward"
    AddItem DropdownList1, "Traslation alternate fixed forward" 'a->d = a+3, b->f = b+4, c->f = c+3,d->h= d+4...z->d z+4-(maxletters=26)
    AddItem DropdownList1, "Traslation alternate fixed backward"
    AddItem DropdownList1, "Traslation alternate progressive and fixed forward" 'a->d = a+3, b->f = b+4, c->f = c+3, d->i = i+5...z->d z+13-(maxletters=26)
    AddItem DropdownList1, "Traslation alternate progressive and fixed backward"
    AddItem DropdownList1, "Traslation alternate bidirectional fixed" ' a->d = a+3, b->y = b-3+26, c->f = c+3,d->a= d-3....z->w= z-3
    AddItem DropdownList1, "Traslation alternate bidirectional progressive"
    AddItem DropdownList1, "Traslation alternate bidirectional mixed fixed and progressive"
END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 30 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%


END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    SELECT CASE id
        CASE EncryptDecrypt

        CASE ChooseMethodOfCryptingLB

        CASE DropdownList1

        CASE SettingValuesForCryptingLB

        CASE StepLB

        CASE TextBox1

        CASE HowCharactersToJumpLB

        CASE TextBox2

        CASE MessageToCryptLB

        CASE TextBox3

        CASE MessageAtStartAsWrittenByUserLB

        CASE EncryptBT
            IF LEN(Caption(EncryptedMessageLB)) > 0 THEN SetCaption EncryptedMessageLB, " "
            IF LEN(Caption(DecryptedMessageLB)) > 0 THEN SetCaption DecryptedMessageLB, " "
            Encrypt

        CASE EncryptedMessageLB

        CASE DecryptBT
            Decrypt
        CASE DecryptedMessageLB

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE EncryptDecrypt

        CASE ChooseMethodOfCryptingLB

        CASE DropdownList1

        CASE SettingValuesForCryptingLB

        CASE StepLB

        CASE TextBox1

        CASE HowCharactersToJumpLB

        CASE TextBox2

        CASE MessageToCryptLB

        CASE TextBox3

        CASE MessageAtStartAsWrittenByUserLB

        CASE EncryptBT

        CASE EncryptedMessageLB

        CASE DecryptBT

        CASE DecryptedMessageLB

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE EncryptDecrypt

        CASE ChooseMethodOfCryptingLB

        CASE DropdownList1

        CASE SettingValuesForCryptingLB

        CASE StepLB

        CASE TextBox1

        CASE HowCharactersToJumpLB

        CASE TextBox2

        CASE MessageToCryptLB

        CASE TextBox3

        CASE MessageAtStartAsWrittenByUserLB

        CASE EncryptBT

        CASE EncryptedMessageLB

        CASE DecryptBT

        CASE DecryptedMessageLB

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE DropdownList1

        CASE TextBox1

        CASE TextBox2

        CASE TextBox3

        CASE EncryptBT

        CASE DecryptBT

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE DropdownList1

        CASE TextBox1

        CASE TextBox2

        CASE TextBox3

        CASE EncryptBT

        CASE DecryptBT

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE EncryptDecrypt

        CASE ChooseMethodOfCryptingLB

        CASE DropdownList1

        CASE SettingValuesForCryptingLB

        CASE StepLB

        CASE TextBox1

        CASE HowCharactersToJumpLB

        CASE TextBox2

        CASE MessageToCryptLB

        CASE TextBox3

        CASE MessageAtStartAsWrittenByUserLB

        CASE EncryptBT

        CASE EncryptedMessageLB

        CASE DecryptBT

        CASE DecryptedMessageLB

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE EncryptDecrypt

        CASE ChooseMethodOfCryptingLB

        CASE DropdownList1

        CASE SettingValuesForCryptingLB

        CASE StepLB

        CASE TextBox1

        CASE HowCharactersToJumpLB

        CASE TextBox2

        CASE MessageToCryptLB

        CASE TextBox3

        CASE MessageAtStartAsWrittenByUserLB

        CASE EncryptBT

        CASE EncryptedMessageLB

        CASE DecryptBT

        CASE DecryptedMessageLB

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        CASE DropdownList1

        CASE TextBox1

        CASE TextBox2

        CASE TextBox3

        CASE EncryptBT

        CASE DecryptBT

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE TextBox1

        CASE TextBox2

        CASE TextBox3
            Caption(MessageAtStartAsWrittenByUserLB) = Text(TextBox3)
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE DropdownList1
            SetValues
    END SELECT
END SUB

SUB __UI_FormResized

END SUB

