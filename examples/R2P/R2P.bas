' Program:      R2P
' Purpose:      Rectangular/Polar Coordinate Converter
' Created:      06/14/2024
' Edited:       09/02/2024
' Version:      1.0

': This program uses
': InForm - GUI library for QB64 - v1.5
': Fellippe Heitor, 2016-2023 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------

OPTION _EXPLICIT

'Controls' IDs: ------------------------------------------------------------------
DIM SHARED XCoordNB AS LONG
DIM SHARED YCoordNB AS LONG
DIM SHARED ConvertNowBT AS LONG
DIM SHARED RadiansTS AS LONG
DIM SHARED AnglesInRadiansLB AS LONG
DIM SHARED ConvertBT AS LONG
DIM SHARED ConvertedValueLB AS LONG
DIM SHARED AnswerLB AS LONG
DIM SHARED R2PRB AS LONG
DIM SHARED P2RRB AS LONG
DIM SHARED XCoordLB AS LONG
DIM SHARED YCoordLB AS LONG
DIM SHARED PictureBox1 AS LONG
DIM SHARED ExitBT AS LONG
DIM SHARED RectangularPolarCoordinateConverter AS LONG

'Variables: ----------------------------------------------------------------------
DIM SHARED AS LONG XCoord, YCoord
DIM SHARED AS SINGLE Mag, Angle
DIM SHARED AS INTEGER Polar 'flag to indicate conversion to/from polar coordinates
DIM SHARED AS INTEGER Radians 'flag to indicate that the angle is in radians
DIM SHARED AS INTEGER Changed 'flag to indicate a new conversion has taken place


'External modules: ---------------------------------------------------------------
'$INCLUDE:'../../InForm/InForm.bi'
'$INCLUDE:'../../InForm/xp.uitheme'
'$INCLUDE:'./R2P.frm'

'Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad
    _SCREENMOVE _MIDDLE
    SetRadioButtonValue R2PRB
    SetCaption XCoordLB, "X Coord"
    SetCaption YCoordLB, "Y Coord"
    SetFrameRate 30
    XCoord = 0: YCoord = 0: Mag = 0.0: Angle = 0.0: Polar = False: Changed = False
    Radians = Control(RadiansTS).Value

END SUB

SUB __UI_BeforeUpdateDisplay
    DIM AS LONG x, y, xp, yp
    DIM AS SINGLE PlotMag
    DIM AS INTEGER PlotRadius

    IF Changed = False THEN EXIT SUB
    BeginDraw PictureBox1

    'clear the picture box
    LINE (0, 0)-(400, 400), _RGB(255, 255, 255), BF

    'draw the axes
    COLOR _RGB(255, 0, 0), _RGB(255, 255, 255)
    LINE (200, 0)-(200, 400)
    LINE (0, 200)-(400, 200)

    'identify the axes
    _PRINTSTRING (2, 198 - _FONTHEIGHT), "180"
    _PRINTSTRING (202, 2), "90"
    _PRINTSTRING (202, 398 - _FONTHEIGHT), "270"
    _PRINTSTRING (398 - _PRINTWIDTH("0"), 198 - _FONTHEIGHT), "0"

    'plot the point if it's not at the origin
    IF (XCoord <> 0) AND (YCoord <> 0) THEN

        IF Polar = True THEN
            'polar plot

            PlotMag = Mag

            'convert angle to radians if conversion was to degrees
            'need radians for the trig functions
            IF Radians = False THEN Angle = _R2D(Angle)

            'if the magnitude runs off the picture box, calculate new plot points for a shorter plot mag
            IF PlotMag > 190 THEN
                PlotMag = 190
                x = FIX(PlotMag * COS(Angle))
                y = FIX(PlotMag * SIN(Angle))
            ELSE
                x = XCoord
                y = YCoord
            END IF

            'translate answer to plotting coords appropriate for the picture box
            xp = x + 200
            yp = 200 - y 'subtractive to reference yp to the X axis, which is at Y=200 in the picture box

            'plot it
            COLOR _RGB(0, 0, 255)
            CIRCLE (xp, yp), 5
            LINE (200, 200)-(xp, yp) 'magnitude

            'determine the radius of the arc plot, 3/4 of the magnitude
            PlotRadius = FIX(PlotMag * 0.75)


            'draw the arc
            IF Angle > 0 THEN
                'angle > 0
                CIRCLE (200, 200), PlotRadius, _RGB(0, 255, 0), 0, Angle, 1
            ELSE
                'angle < 0
                CIRCLE (200, 200), PlotRadius, _RGB(0, 255, 0), (2 * _PI) + Angle, 0, 1
            END IF
        ELSE
            'rectangular plot
            IF (XCoord > 200) OR (YCoord > 200) THEN
                'scale the coords to fit into the picture box
                x = FIX(190 * COS(Angle))
                y = FIX(190 * SIN(Angle))
            ELSE
                x = XCoord
                y = YCoord
            END IF

            'translate answer to plotting coords appropriate for the picture box
            xp = x + 200
            yp = 200 - y 'subtractive to reference yp to the X axis, which is at Y=200 in the picture box

            COLOR _RGB(0, 0, 255)
            CIRCLE (xp, yp), 5
        END IF

        Changed = False 'flag that the last conversion was plotted
    END IF

    EndDraw PictureBox1

END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    DIM x$ 'general purpose
    DIM xval#, yval# 'for the input coordinates

    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT
            xval# = Control(XCoordNB).Value
            yval# = Control(YCoordNB).Value
            Radians = Control(RadiansTS).Value

            'validate the input
            IF (xval# = 0.0) AND (yval# = 0.0) THEN
                _MESSAGEBOX "InputError", "Nothing to convert", "error"
                EXIT SUB
            END IF

            IF (xval# < 0.0) AND Control(P2RRB).Value = True THEN
                _MESSAGEBOX "InputError", "Can't convert a negative magnitude", "error"
                EXIT SUB
            END IF

            'do the conversion
            IF Control(R2PRB).Value = True THEN
                'rectangular to polar
                XCoord = xval#: YCoord = yval# 'save the coords for plotting
                Mag = SQR(xval# ^ 2 + yval# ^ 2)
                Angle = _ATAN2(yval#, xval#)
                IF Radians = False THEN Angle = _R2D(Angle) 'convert _ATAN2 output to degrees
                Polar = True
                x$ = Decimal$(STR$(Mag), 3) + "<" + Decimal$(STR$(Angle), 3)
                IF Radians = True THEN
                    x$ = x$ + "r"
                ELSE
                    x$ = x$ + "ø"
                END IF
            ELSE
                'polar to rectangular
                IF Radians = False THEN yval# = _R2D(yval#) 'need radians for the trig functions
                Mag = xval#: Angle = yval#
                XCoord = FIX(xval# * COS(yval#))
                YCoord = FIX(xval# * SIN(yval#))
                Polar = False
                x$ = Decimal$(STR$(XCoord), 3) + "," + Decimal$(STR$(YCoord), 3)
            END IF

            SetCaption AnswerLB, x$
            Changed = True

        CASE RadiansTS

        CASE AnglesInRadiansLB

        CASE ConvertBT

        CASE ConvertedValueLB

        CASE AnswerLB

        CASE R2PRB

        CASE P2RRB

        CASE XCoordLB

        CASE YCoordLB

        CASE PictureBox1

        CASE ExitBT
            SYSTEM

        CASE RectangularPolarCoordinateConverter

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE AnglesInRadiansLB

        CASE ConvertBT

        CASE ConvertedValueLB

        CASE AnswerLB

        CASE R2PRB

        CASE P2RRB

        CASE XCoordLB

        CASE YCoordLB

        CASE PictureBox1

        CASE ExitBT

        CASE RectangularPolarCoordinateConverter

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE AnglesInRadiansLB

        CASE ConvertBT

        CASE ConvertedValueLB

        CASE AnswerLB

        CASE R2PRB

        CASE P2RRB

        CASE XCoordLB

        CASE YCoordLB

        CASE PictureBox1

        CASE ExitBT

        CASE RectangularPolarCoordinateConverter

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE ConvertBT

        CASE R2PRB

        CASE P2RRB

        CASE ExitBT

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE ConvertBT

        CASE R2PRB

        CASE P2RRB

        CASE ExitBT

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE AnglesInRadiansLB

        CASE ConvertBT

        CASE ConvertedValueLB

        CASE AnswerLB

        CASE R2PRB

        CASE P2RRB

        CASE XCoordLB

        CASE YCoordLB

        CASE PictureBox1

        CASE ExitBT

        CASE RectangularPolarCoordinateConverter

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE AnglesInRadiansLB

        CASE ConvertBT

        CASE ConvertedValueLB

        CASE AnswerLB

        CASE R2PRB

        CASE P2RRB

        CASE XCoordLB

        CASE YCoordLB

        CASE PictureBox1

        CASE ExitBT

        CASE RectangularPolarCoordinateConverter

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

        CASE ConvertNowBT

        CASE RadiansTS

        CASE ConvertBT

        CASE R2PRB

        CASE P2RRB

        CASE ExitBT

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE XCoordNB

        CASE YCoordNB

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE RadiansTS
            Radians = Control(RadiansTS).Value

        CASE R2PRB
            SetCaption XCoordLB, "X Coord"
            SetCaption YCoordLB, "Y Coord"
            Polar = True
        CASE P2RRB
            SetCaption XCoordLB, "Magnitude"
            SetCaption YCoordLB, "Angle"
            Polar = False
    END SELECT
END SUB

SUB __UI_FormResized

END SUB


'------------------------------------------------------------------------------
'Helper functions
FUNCTION Decimal$ (a$, dp%)
    'function to trim a string representation of a number to dp% decimal places
    DIM x%, y%, z%, w$, t$

    'scan the string and find the DP if it exists
    x% = LEN(a$): t$ = "": z% = 1
    DO
        w$ = MID$(a$, z%, 1)
        IF w$ <> "." THEN 'not a dp
            SELECT CASE ASC(w$)
                CASE 32, 45 'leading space or minus sign?
                    IF z% = 1 THEN
                        t$ = t$ + w$
                        z% = z% + 1
                    ELSE
                        Decimal$ = "" 'space or minus sign not allowed past the first character
                        EXIT FUNCTION
                    END IF
                CASE 48 TO 57 'digits
                    t$ = t$ + w$
                    z% = z% + 1
                CASE ELSE
                    Decimal$ = "" 'not a valid input
                    EXIT FUNCTION
            END SELECT
        ELSE
            'dp found
            t$ = t$ + "."
            FOR y% = z% + 1 TO z% + dp%
                IF y% > x% THEN EXIT DO 'off the end of the string
                t$ = t$ + MID$(a$, y%, 1)
            NEXT y%
            EXIT DO
        END IF
    LOOP UNTIL z% > x% 'reached the end of the string
    Decimal$ = t$
END FUNCTION

'$INCLUDE:'../../InForm/InForm.ui'
