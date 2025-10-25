' ==============================================================================
' Minimalistic test framework library for QB64-PE
' Copyright (c) 2025, Samuel Gomes
' ==============================================================================

$INCLUDEONCE

ON ERROR GOTO __catch_error_handler

DIM __catchErrorHandlerInitialized AS _BYTE

__catch_error_handler:
IF __catchErrorHandlerInitialized THEN
    DIM __errorLine AS LONG: __errorLine = _INCLERRORLINE

    DIM __errorFile AS STRING

    IF __errorLine THEN
        __errorFile = _INCLERRORFILE$
    ELSE
        __errorLine = _ERRORLINE
        IF NOT __errorLine THEN __errorLine = ERL

        __errorFile = _INCLERRORFILE$
        IF NOT LEN(__errorFile) THEN __errorFile = "main module"
    END IF

    __TestSetColor __TEST_COLOR_FAIL: __TestPrintLn "Runtime error" + STR$(ERR) + " on line" + STR$(__errorLine) + " in " + __errorFile
    SYSTEM 1
ELSE
    __catchErrorHandlerInitialized = _TRUE
    RANDOMIZE TIMER
    __TestState.colorEnabled = _TRUE
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "OS: " + _OS$
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "Date: " + DATE$
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "Time: " + TIME$
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "Executable: " + COMMAND$(0)
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "Working directory: " + _CWD$
    __TestSetColor __TEST_COLOR_HEADER: __TestPrintLn "Catch error handler installed."
END IF
