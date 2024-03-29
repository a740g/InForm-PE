': This program was generated by
': InForm - GUI system for QB64 - Beta version 7
': Fellippe Heitor, 2016-2018 - fellippe@qb64.org - @fellippeheitor
'-----------------------------------------------------------

OPTION _EXPLICIT

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED ClickTheVoid AS LONG
DIM SHARED PictureBox1 AS LONG
DIM SHARED Button1 AS LONG
DIM SHARED TrackBar1 AS LONG
DIM SHARED fpsLB AS LONG

DIM SHARED start!, totalFrames AS _UNSIGNED LONG, fps AS INTEGER
DIM AS SINGLE CenterX, CenterY, Radius, MaxRadius

': External modules: ---------------------------------------------------------------
'$INCLUDE:'../../InForm/InForm.bi'
'$INCLUDE:'ClickTheVoid.frm'
'$INCLUDE:'../../InForm/InForm.ui'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit
END SUB

SUB __UI_OnLoad
    Caption(Button1) = "Clear"
    SetFrameRate 120
    start! = TIMER
END SUB

SUB __UI_BeforeUpdateDisplay
    SHARED CenterX, CenterY, Radius, MaxRadius

    BeginDraw PictureBox1
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, 10), BF

    totalFrames = totalFrames + 1
    fps% = totalFrames / (TIMER - start!)
    _PRINTSTRING (0, 0), STR$(fps%)
    EndDraw PictureBox1

    Radius = Radius + 1
    IF Radius <= MaxRadius THEN
        BeginDraw PictureBox1
        CIRCLE (CenterX, CenterY), Radius, _RGBA32(RND * 255, RND * 255, RND * 255, RND * 255)
        EndDraw PictureBox1
    END IF
END SUB

SUB __UI_BeforeUnload
END SUB

SUB __UI_Click (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE fpsLB

        CASE ClickTheVoid

        CASE PictureBox1
            SHARED MaxRadius, CenterX, CenterY, Radius
            Radius = 0
            MaxRadius = RND * 100 + 30
            CenterX = __UI_MouseLeft - Control(id).Left
            CenterY = __UI_MouseTop - Control(id).Top
        CASE Button1
            BeginDraw PictureBox1
            CLS
            MaxRadius = 0
            start! = TIMER
            totalFrames = 0
            EndDraw PictureBox1
    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE fpsLB

        CASE ClickTheVoid

        CASE PictureBox1

        CASE Button1

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE fpsLB

        CASE ClickTheVoid

        CASE PictureBox1

        CASE Button1

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE Button1

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE Button1

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE fpsLB

        CASE ClickTheVoid

        CASE PictureBox1

        CASE Button1

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE fpsLB

        CASE ClickTheVoid

        CASE PictureBox1

        CASE Button1

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    SELECT CASE id
        CASE TrackBar1

        CASE Button1

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE TrackBar1
            Caption(fpsLB) = LTRIM$(STR$(Control(id).Value)) + "fps"
            SetFrameRate Control(id).Value
    END SELECT
END SUB

SUB __UI_FormResized
END SUB
