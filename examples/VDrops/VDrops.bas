' Program:      VDrops
' Purpose:      Circuit voltage drop calculator/wire size optimizer
' Created:      05/06/2025
' Edited:       05/30/2025
' Version:      0.1

': This program uses
': InForm GUI engine for QB64-PE - v1.5.7
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2025) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

'$DYNAMIC
$EXEICON:'./litening.ico'
OPTION _EXPLICIT

'-- Storing study information --
'Two records are used.
'First record carries projnum in String1, projname in String2
'Second record carries CktName in String1, packed values in String2:
'       Voltage, 4 byte string representation of LONG
'       Min wire size, 4 byte string representation of LONG
'       Project Options, 7 byte string
'
'The project options are encoded as follows:
'Byte    Denotes
' 9      'S' for single phase, 'T' for three phase
' 10     wire type: 'C' for copper, 'A' for aluminum
' 11     conduit type: 'P' for PVC, 'S' for steel, 'A' for aluminum
'12-15   Throwaway to fill out the string length to 15 bytes

TYPE StudyInfo
    String1 AS STRING * 19
    String2 AS STRING * 15
END TYPE

TYPE SegData
    Name AS STRING * 10
    Load AS LONG
    Length AS LONG
    Amps AS SINGLE
    Wire AS LONG
    Volts AS SINGLE
    Drop AS SINGLE
END TYPE

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED SegmentCurrentAmpsLB AS LONG
DIM SHARED ConduitType AS LONG
DIM SHARED AddAt AS LONG
DIM SHARED SteelConduitRB AS LONG
DIM SHARED AluminumConduitRB AS LONG
DIM SHARED PVCConduitRB AS LONG
DIM SHARED AddAtEndOfCircuitRB AS LONG
DIM SHARED AddBeforeSelectedNodeRB AS LONG
DIM SHARED SelectSegmentClickToDeleteBT AS LONG
DIM SHARED frmVDrops AS LONG
DIM SHARED FileMenu AS LONG
DIM SHARED ProjInfo AS LONG
DIM SHARED NumberOfPhases AS LONG
DIM SHARED WireInformation AS LONG
DIM SHARED SegmentNodeInformation AS LONG
DIM SHARED CalculationsMenu AS LONG
DIM SHARED FilesMenuNew AS LONG
DIM SHARED FilesMenuOpen AS LONG
DIM SHARED FilesMenuSave AS LONG
DIM SHARED CircuitLB AS LONG
DIM SHARED NodeNameLB AS LONG
DIM SHARED FilesMenuSaveAs AS LONG
DIM SHARED FilesMenuPrint AS LONG
DIM SHARED FilesMenuExit AS LONG
DIM SHARED ProjectNumberLB AS LONG
DIM SHARED ProjectNameLB AS LONG
DIM SHARED CircuitNameLB AS LONG
DIM SHARED CircuitVoltageLB AS LONG
DIM SHARED ProjNumTB AS LONG
DIM SHARED ProjNameTB AS LONG
DIM SHARED CktNameTB AS LONG
DIM SHARED VoltageNT AS LONG
DIM SHARED SinglePhaseRB AS LONG
DIM SHARED ThreePhaseRB AS LONG
DIM SHARED CopperRB AS LONG
DIM SHARED AluminumRB AS LONG
DIM SHARED MinWireSizeDD AS LONG
DIM SHARED MinimumWireSizeLB AS LONG
DIM SHARED AddSegmentBT AS LONG
DIM SHARED AddANewSegmentBT AS LONG
DIM SHARED SegmentLengthNewLB AS LONG
DIM SHARED NodeNameNewLB AS LONG
DIM SHARED LoadVALB AS LONG
DIM SHARED NodeNameNewTB AS LONG
DIM SHARED SegLengthNT AS LONG
DIM SHARED NodeLoadNT AS LONG
DIM SHARED NodeLoadVALB AS LONG
DIM SHARED SegmentLengthFeetLB AS LONG
DIM SHARED VDVoltsLB AS LONG
DIM SHARED VDLB AS LONG
DIM SHARED CumVDLB AS LONG
DIM SHARED SelectSegmentClickToEditBT AS LONG
DIM SHARED FeetLB AS LONG
DIM SHARED CalculationsMenuCalculate AS LONG
DIM SHARED WireSizeLB AS LONG
DIM SHARED WireSizeLB2 AS LONG
DIM SHARED WireSizesDD AS LONG

'Variables
DIM SHARED AS _BIT dirty
DIM SHARED AS STRING wires(20), filename, segments(0)
DIM SHARED AS SINGLE impedance(6, 20), cumulative
DIM SHARED AS SegData segvalues(0)

'wire sizes
Sizes:
DATA "12 AWG","10 AWG","8 AWG","6 AWG","4 AWG","3 AWG","2 AWG","1 AWG"
DATA "1/0 AWG","2/0 AWG","3/0 AWG","4/0 AWG","250 kcmil","300 kcmil","350 kcmil"
DATA "400 kcmil","500 kcmil","600 kcmil","750 kcmil","1000 kcmil"

'impedance values
Zees:
'PVC copper
DATA 1.7,1.1,.69,.44,.29,.23,.19,.16,.13,.11,.088,.074,.066,.059,.053,.049,.043,.04,.036,.032
'Alum copper
DATA 1.7,1.1,.69,.45,.29,.23,.19,.16,.13,.11,.092,.078,.07,.063,.058,.053,.048,.044,.04,.036
'Steel copper
DATA 1.7,1.1,.7,.45,.3,.24,.2,.16,.13,.11,.094,.08,.073,.065,.06,.056,.05,.047,.043,.04
'PVC aluminum
DATA 2.8,1.8,1.1,.71,.46,.37,.3,.24,.19,.16,.13,.11,.094,.082,.073,.066,.057,.051,.045,.039
'Aluminum aluminum
DATA 2.8,1.8,1.1,.72,.46,.37,.3,.24,.2,.16,.13,.11,.098,.086,.077,.071,.061,.055,.049,.042
'Steel aluminum
DATA 2.8,1.8,1.1,.72,.46,.37,.3,.25,.2,.16,.14,.11,.1,.088,.08,.073,.064,.058,.052,.046

': External modules: ---------------------------------------------------------------
'$INCLUDE:'../../InForm/InForm.bi'
'$INCLUDE:'../../InForm/xp.uitheme'
'$INCLUDE:'./VDrops.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit
    _MESSAGEBOX "Using VD Calculator", "When entering the circuit data, start with the point closest to the source and build out.", "info"
END SUB

SUB __UI_OnLoad
    DIM AS INTEGER ix, iy
    DIM AS STRING sx

    _SCREENMOVE _MIDDLE
    _TITLE "Voltage Drop Calculator"

    '-- load up the wire size dropdown lists
    RESTORE Sizes
    FOR ix = 1 TO 20
        READ sx
        AddItem MinWireSizeDD, sx
        AddItem WireSizesDD, sx
        wires(ix) = sx
    NEXT ix
    Control(MinWireSizeDD).Value = 1
    Control(WireSizesDD).Value = 1

    '-- load up the circuit impedances
    RESTORE Zees
    FOR ix = 1 TO 6
        FOR iy = 1 TO 20
            READ impedance(ix, iy)
        NEXT iy
    NEXT ix

    SetRadioButtonValue SinglePhaseRB
    SetRadioButtonValue CopperRB
    SetRadioButtonValue AddAtEndOfCircuitRB
    SetRadioButtonValue PVCConduitRB
    ResetList CircuitLB
    DisableSegmentInfo
    dirty = False
    filename = ""
END SUB

SUB __UI_BeforeUpdateDisplay
END SUB

SUB __UI_BeforeUnload
    IF dirty = True THEN
        __UI_UnloadSignal = _MESSAGEBOX("Warning!", "Data not saved! Continue?", "yesno", "question", 0)
    END IF
END SUB

SUB __UI_Click (id AS LONG)
    DIM AS LONG ix, iy, iz
    DIM AS STRING sx, sy
    STATIC AS _BIT adding, updating

    SELECT CASE id

        CASE AddSegmentBT
            DIM AS SegData sd

            '-- Pick up the new data
            sd.Name = Text(NodeNameNewTB) '<-- "NodeNameTB" deleted from Form on 05-30-2025
            sd.Load = Control(NodeLoadNT).Value
            sd.Length = Control(SegLengthNT).Value
            sd.Wire = Control(WireSizesDD).Value


            IF adding THEN
                IF Control(AddBeforeSelectedNodeRB).Value THEN
                    ix = Control(CircuitLB).Value
                    IF ix = 0 THEN
                        _MESSAGEBOX "VDrops error", "Please select a node first.", "error"
                        EXIT SELECT
                    END IF

                    '-- expand the arrays
                    iy = UBOUND(segvalues) + 1
                    REDIM _PRESERVE AS SegData segvalues(iy)
                    REDIM _PRESERVE AS STRING segments(iy)

                    '-- shift the data in reverse order to make a hole and preserve the values
                    FOR iz = iy TO ix STEP -1
                        segvalues(iz) = segvalues(iz - 1)
                        segments(iz) = segments(iz - 1)
                    NEXT iz
                    segvalues(ix) = sd
                    MakeSegmentString (ix)
                ELSE
                    '-- expand the arrays
                    iy = UBOUND(segvalues) + 1
                    REDIM _PRESERVE AS SegData segvalues(iy)
                    REDIM _PRESERVE AS STRING segments(iy)
                    segvalues(iy) = sd
                    MakeSegmentString (iy)
                END IF
                adding = False
            END IF

            IF updating THEN
                ix = Control(CircuitLB).Value
                segvalues(ix) = sd
                MakeSegmentString (ix)
                updating = False
            END IF

            Caption(AddANewSegmentBT) = "Add A New Segment"
            Control(AddANewSegmentBT).ForeColor = _RGB(0, 0, 0)
            DisableSegmentInfo
            Text(NodeNameNewTB) = "": Control(NodeLoadNT).Value = 0: Control(SegLengthNT).Value = 0
            Control(WireSizesDD).Value = Control(MinWireSizeDD).Value

            UpdateListbox
            dirty = True

        CASE SelectSegmentClickToDeleteBT
            ix = Control(CircuitLB).Value
            IF _MESSAGEBOX("Delete Segment", "OK to delete segment?", "yesno", "question", 0) = 0 THEN EXIT SELECT

            iz = UBOUND(segvalues) - 1
            FOR iy = ix TO iz
                segvalues(iy) = segvalues(iy + 1)
                segments(iy) = segments(iy + 1)
            NEXT iy
            REDIM _PRESERVE AS SegData segvalues(iz)
            REDIM _PRESERVE AS STRING segments(iz)
            UpdateListbox
            dirty = True

        CASE FilesMenuNew

            IF dirty = True THEN
                ix = _MESSAGEBOX("Warning!", "Data not saved! Continue?", "yesno", "question")
                IF ix = 0 THEN EXIT SELECT
            END IF

            REDIM AS SegData segvalues(1)
            REDIM AS STRING segments(1)
            SetRadioButtonValue SinglePhaseRB
            SetRadioButtonValue AddAtEndOfCircuitRB
            SetRadioButtonValue PVCConduitRB
            Text(ProjNumTB) = "": Text(ProjNameTB) = "": Text(CktNameTB) = "": Control(VoltageNT).Value = 0
            Control(MinWireSizeDD).Value = 1
            ResetList CircuitLB
            ClearSegInfo
            DisableSegmentInfo
            dirty = False
            filename = ""

        CASE FilesMenuOpen
            DIM AS StudyInfo si

            sx = _OPENFILEDIALOG$("Open VDrops study", filename, "*.vdrops", "VDrops files")
            IF sx = "" THEN EXIT SELECT

            ix = FREEFILE
            OPEN filename FOR RANDOM AS ix LEN = LEN(segvalues(0))
            iy = LOF(ix): iz = iy \ LEN(segvalues(0))
            GET #ix, 1, si: Text(ProjNumTB) = si.String1: Text(ProjNameTB) = si.String2
            GET #ix, 2, si: Text(CktNameTB) = si.String1

            '-- Project options
            Control(VoltageNT).Value = VAL(MID$(si.String2, 1, 4))
            Control(MinWireSizeDD).Value = VAL(MID$(si.String2, 5, 4))
            sy = MID$(si.String2, 9, 1)
            IF sy = "S" THEN SetRadioButtonValue SinglePhaseRB ELSE SetRadioButtonValue ThreePhaseRB
            sy = MID$(si.String2, 10, 1)
            IF sy = "C" THEN SetRadioButtonValue CopperRB ELSE SetRadioButtonValue AluminumRB
            sy = MID$(si.String2, 11, 1)
            SELECT CASE sy
                CASE "P"
                    SetRadioButtonValue PVCConduitRB
                CASE "S"
                    SetRadioButtonValue SteelConduitRB
                CASE "A"
                    SetRadioButtonValue AluminumConduitRB
            END SELECT

            '-- Now pick up the segment data
            '-- With two records carrying project data, the number of segments is 2 records less
            '-- than the file length
            REDIM AS SegData segvalues(iz - 2)
            REDIM AS STRING segments(iz - 2)
            FOR iy = 1 TO iz - 2
                GET #ix, iy, segvalues(iy)
            NEXT iy
            CLOSE
            FOR iy = 1 TO iz - 2
                MakeSegmentString iy
            NEXT iy

            UpdateListbox
            dirty = False

        CASE FilesMenuSave
            IF filename = "" THEN
                _MESSAGEBOX "Filename missing", "Please use 'Save As' first.", "error"
                EXIT SELECT
            ELSE
                SaveFile
            END IF

        CASE FilesMenuSaveAs
            filename = _SAVEFILEDIALOG$("Save VDrops study as", filename, "*.vdrops", "VDrops files")
            IF filename = "" THEN EXIT SELECT
            SaveFile

        CASE FilesMenuPrint
            IF _MESSAGEBOX("Print Report", "Prepare your printer then click OK to begin, or CANCEL to leave",_
             "okcancel", "info", 0) = 0 THEN exit select

            LPRINT "Voltage Drop Calculation": LPRINT
            LPRINT "Project Number: "; Text(ProjNumTB)
            LPRINT "Project Name: "; Text(ProjNameTB)
            LPRINT "Circuit Name: "; Text(CktNameTB)
            LPRINT "Circuit Voltage "; Text(VoltageNT)
            LPRINT "Number of phases: ";
            IF Control(SinglePhaseRB).Value = True THEN LPRINT "1" ELSE LPRINT "3"
            IF Control(CopperRB).Value = True THEN LPRINT "Copper wire" ELSE LPRINT "Aluminum wire"
            LPRINT: LPRINT "Circuit Segments:"
            FOR ix = 1 TO UBOUND(segments)
                LPRINT segments(ix)
            NEXT ix
            _MESSAGEBOX "VDrops Message", "Printing is done."

        CASE FilesMenuExit

            IF dirty = True THEN
                IF _MESSAGEBOX("Warning!", "Data not saved! Exit anyway?", "yesno", "question") = 0 THEN EXIT SELECT
            END IF

            'not dirty or OK to exit
            SYSTEM

        CASE AddANewSegmentBT
            ClearSegInfo
            IF adding = False AND updating = False THEN
                'add a new segment
                Caption(AddSegmentBT) = "Add Segment"
                EnableSegmentInfo
                Caption(AddANewSegmentBT) = "Cancel"
                Control(AddANewSegmentBT).ForeColor = _RGB(255, 0, 0)
                Control(WireSizesDD).Value = Control(MinWireSizeDD).Value
                adding = True
                EXIT SELECT
            ELSE
                'cancelling the add or update operation
                DisableSegmentInfo
                Caption(AddANewSegmentBT) = "Add A New Segment"
                Control(AddANewSegmentBT).ForeColor = _RGB(0, 0, 0)
                adding = False: updating = False
            END IF

        CASE SelectSegmentClickToEditBT

            IF updating = False THEN
                Caption(AddSegmentBT) = "Update Segment"
                EnableSegmentInfo
                Control(AddAtEndOfCircuitRB).Disabled = True
                Control(AddBeforeSelectedNodeRB).Disabled = True
                Caption(AddANewSegmentBT) = "Cancel"
                Control(AddANewSegmentBT).ForeColor = _RGB(255, 0, 0)
                updating = True

                ix = Control(CircuitLB).Value
                Text(NodeNameNewTB) = segvalues(ix).Name '<-- "NodeNameTB" deleted from Form on 05-30-2025
                Control(NodeLoadNT).Value = segvalues(ix).Load
                Control(SegLengthNT).Value = segvalues(ix).Length
                Control(WireSizesDD).Value = segvalues(ix).Wire
            END IF

        CASE CalculationsMenuCalculate
            'VD = I x ((2 x L x Z) / 1000) single phase
            'VD = 1.732 x I x ((L x Z) / 1000) three phase
            '-- Calculate voltage drop and percentage for each segment
            '-- Assume the first node is the closest to the circuit supply
            DIM AS SINGLE totalload, segvolts, totalvolts
            DIM AS LONG sysvolts, cktmatl
            DIM AS _BIT onephase

            sysvolts = Control(VoltageNT).Value
            IF sysvolts = 0 THEN
                _MESSAGEBOX "VDrops error", "Please enter the circuit voltage first.", "error"
                EXIT SELECT
            END IF
            onephase = Control(SinglePhaseRB).Value
            cumulative = 0.0: totalvolts = 0.0

            '-- determine circuit material for selecting impedance
            cktmatl = 1 'default is PVC conduit, copper conductors
            IF Control(AluminumConduitRB).Value THEN cktmatl = 2
            IF Control(SteelConduitRB).Value THEN cktmatl = 3
            IF Control(AluminumRB).Value THEN cktmatl = cktmatl + 3 'aluminum conductors

            '-- calculate total load in the system
            ix = UBOUND(segvalues)
            totalload = 0.0
            FOR iy = 1 TO ix
                totalload = totalload + segvalues(iy).Load
            NEXT iy

            segvolts = sysvolts 'first run through the segment volts equals the system volts

            '-- calculate the voltage drops for each segment
            IF onephase THEN
                FOR iy = 1 TO ix
                    segvalues(iy).Amps = (totalload / segvolts)
                    segvalues(iy).Volts = segvalues(iy).Amps * ((2 * segvalues(iy).Length * impedance(cktmatl, segvalues(iy).Wire)) / 1000)
                    segvalues(iy).Drop = (segvalues(iy).Volts / segvolts) * 100
                    totalvolts = totalvolts + segvalues(iy).Volts
                    cumulative = (totalvolts / sysvolts) * 100
                    MakeSegmentString (iy)
                    segvolts = segvolts - segvalues(iy).Volts 'reduce the circuit volts for the next segment
                    totalload = totalload - segvalues(iy).Load 'reduce the circuit load for the next segment
                NEXT iy
            ELSE
                FOR iy = 1 TO ix
                    segvalues(iy).Amps = (totalload * 1.732 / segvolts)
                    segvalues(iy).Volts = segvalues(iy).Amps * ((segvalues(iy).Length * impedance(cktmatl, segvalues(iy).Wire)) / 1000)
                    segvalues(iy).Drop = (segvalues(iy).Volts / segvolts) * 100
                    totalvolts = totalvolts + segvalues(iy).Volts
                    cumulative = (totalvolts / sysvolts) * 100
                    MakeSegmentString (iy)
                    segvolts = segvolts - segvalues(iy).Volts 'reduce the circuit volts for the next segment
                    totalload = totalload - segvalues(iy).Load 'reduce the circuit load for the next segment
                NEXT iy
            END IF
            UpdateListbox
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

SUB __UI_KeyPress (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE ELSE
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE WireSizesDD
            if control(wiresizesDD).value<control(minwiresizedd).value then_
                control(wiresizesdd).value=control(minwiresizedd).value
    END SELECT
END SUB

SUB __UI_FormResized
END SUB

SUB SaveFile
    DIM AS INTEGER ix, iy
    DIM AS StudyInfo si

    IF _MESSAGEBOX("Save File", "Study will be saved to file: " + filename, "okcancel", "info") = 0 THEN EXIT SUB
    ix = FREEFILE
    OPEN filename FOR RANDOM AS ix LEN = LEN(segvalues(0))

    '-- project info
    si.String1 = Text(ProjNumTB): si.String2 = Text(ProjNameTB): PUT #ix, 1, si
    si.String1 = Text(CktNameTB)
    MID$(si.String2, 1, 4) = MKL$(Control(VoltageNT).Value)
    MID$(si.String2, 5, 4) = MKL$(Control(MinWireSizeDD).Value)
    IF Control(SinglePhaseRB).Value = True THEN MID$(si.String2, 9, 1) = "S" ELSE MID$(si.String2, 9, 1) = "T"
    IF Control(CopperRB).Value = True THEN MID$(si.String2, 10, 1) = "C" ELSE MID$(si.String2, 10, 1) = "A"
    IF Control(PVCConduitRB).Value = True THEN MID$(si.String2, 11, 1) = "P"
    IF Control(SteelConduitRB).Value = True THEN MID$(si.String2, 11, 1) = "S"
    IF Control(AluminumConduitRB).Value = True THEN MID$(si.String2, 11, 1) = "A"
    PUT #ix, 2, si

    '-- segment data
    FOR iy = 1 TO UBOUND(segvalues)
        PUT #ix, iy + 2, segvalues(iy)
    NEXT iy

    CLOSE
    dirty = False
END SUB

SUB DisableSegmentInfo
    Control(SegmentNodeInformation).Disabled = True
    Control(NodeNameNewTB).Disabled = True
    Control(NodeNameNewLB).Disabled = True
    Control(SegmentLengthNewLB).Disabled = True
    Control(SegLengthNT).Disabled = True
    Control(LoadVALB).Disabled = True
    Control(NodeLoadNT).Disabled = True
    Control(FeetLB).Disabled = True
    Control(WireSizeLB2).Disabled = True
    Control(WireSizesDD).Disabled = True
    Control(AddAtEndOfCircuitRB).Disabled = True
    Control(AddBeforeSelectedNodeRB).Disabled = True
    Control(AddSegmentBT).Disabled = True
END SUB

SUB EnableSegmentInfo
    Control(SegmentNodeInformation).Disabled = False
    Control(NodeNameNewTB).Disabled = False '<-- "NodeNameTB" deleted from Form on 05-30-2025
    Control(NodeNameNewLB).Disabled = False
    Control(SegmentLengthNewLB).Disabled = False
    Control(SegLengthNT).Disabled = False
    Control(LoadVALB).Disabled = False
    Control(NodeLoadNT).Disabled = False
    Control(FeetLB).Disabled = False
    Control(WireSizeLB2).Disabled = False
    Control(WireSizesDD).Disabled = False
    Control(AddAtEndOfCircuitRB).Disabled = False
    Control(AddBeforeSelectedNodeRB).Disabled = False
    Control(AddSegmentBT).Disabled = False
END SUB

SUB MakeSegmentString (ix AS LONG)
    'ix points to the index of the segments array where the string will live

    DIM AS STRING sx

    'initialize the string
    sx = SPACE$(69)

    MID$(sx, 1) = segvalues(ix).Name
    MID$(sx, 9) = _TOSTR$(segvalues(ix).Load, 1)
    MID$(sx, 18) = _TOSTR$(segvalues(ix).Length, 1)
    MID$(sx, 27) = _TOSTR$(segvalues(ix).Amps, 2)
    MID$(sx, 36) = wires(segvalues(ix).Wire)
    MID$(sx, 47) = _TOSTR$(segvalues(ix).Volts, 2)
    MID$(sx, 54) = _TOSTR$(segvalues(ix).Drop, 2)
    MID$(sx, 64) = _TOSTR$(cumulative, 2)

    segments(ix) = sx
    dirty = True
END SUB

SUB ClearSegInfo
    Text(NodeNameNewTB) = "" '<-- "NodeNameTB" deleted from Form on 05-30-2025
    Control(NodeLoadNT).Value = 0
    Control(SegLengthNT).Value = 0
END SUB

SUB UpdateListbox
    DIM AS INTEGER ix

    ResetList CircuitLB
    FOR ix = 1 TO UBOUND(segments)
        AddItem CircuitLB, segments(ix)
    NEXT ix
END SUB

'$INCLUDE:'../../InForm/InForm.ui'
