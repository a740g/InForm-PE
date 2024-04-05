': This a port of Paul Dunn's (ZXDunny) "Bubble Universe" demo by a740g
': https://github.com/ZXDunny/SpecBAS-Demos/blob/master/Graphics/bubble_universe
':
': This program uses
': InForm GUI engine for QB64-PE - v1.5.4
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

OPTION _EXPLICIT

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED iTB AS LONG
DIM SHARED cTB AS LONG
DIM SHARED tTB AS LONG
DIM SHARED bTB AS LONG
DIM SHARED ILB AS LONG
DIM SHARED CLB AS LONG
DIM SHARED TLB AS LONG
DIM SHARED BLB AS LONG
DIM SHARED Options AS LONG
DIM SHARED Frame1 AS LONG
DIM SHARED BubbleUniverse AS LONG
DIM SHARED Canvas AS LONG

DIM SHARED t AS SINGLE

': External modules: ---------------------------------------------------------------
'$INCLUDE:'../../InForm/InForm.bi'
'$INCLUDE:'../../InForm/xp.uitheme'
'$INCLUDE:'Bubble-Universe.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad

END SUB

SUB __UI_BeforeUpdateDisplay
    CONST TAU! = _PI(2!)
    CONST SCALE! = 0.48!
    CONST DIVISOR! = 1000!

    'This event occurs at approximately 60 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%

    BeginDraw Canvas

    DIM hW AS SINGLE: hW = _WIDTH / 2!
    DIM hH AS SINGLE: hH = _HEIGHT / 2!
    DIM a AS SINGLE: a = TAU / (Control(cTB).Value / DIVISOR!)
    DIM tI AS SINGLE: tI = Control(tTB).Value / DIVISOR!
    DIM n AS SINGLE: n = Control(iTB).Value
    DIM b AS SINGLE: b = Control(bTB).Value

    CLS

    DIM AS SINGLE i, j, u, v, x

    FOR i = 0! TO n
        FOR j = 0! TO n

            u = SIN(i + v) + SIN(a * i + x)
            v = COS(i + v) + COS(a * i + x)
            x = u + t

            PSET (hW + u * hW * SCALE, hH + v * hH * SCALE), _RGB32(i, j, b - t)
        NEXT
    NEXT

    t = t + tI

    EndDraw Canvas

END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

        CASE ILB

        CASE CLB

        CASE TLB

        CASE BLB

        CASE Options

        CASE Frame1

        CASE BubbleUniverse

        CASE Canvas

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

        CASE ILB

        CASE CLB

        CASE TLB

        CASE BLB

        CASE Options

        CASE Frame1

        CASE BubbleUniverse

        CASE Canvas

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

        CASE ILB

        CASE CLB

        CASE TLB

        CASE BLB

        CASE Options

        CASE Frame1

        CASE BubbleUniverse

        CASE Canvas

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

        CASE ILB

        CASE CLB

        CASE TLB

        CASE BLB

        CASE Options

        CASE Frame1

        CASE BubbleUniverse

        CASE Canvas

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

        CASE ILB

        CASE CLB

        CASE TLB

        CASE BLB

        CASE Options

        CASE Frame1

        CASE BubbleUniverse

        CASE Canvas

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id

        CASE ELSE

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE iTB

        CASE cTB

        CASE tTB

        CASE bTB
            t = 0!

    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'../../InForm/InForm.ui'
