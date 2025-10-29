' ==============================================================================
' Minimalistic test framework library for QB64-PE
' Copyright (c) 2025, Samuel Gomes
' ------------------------------------------------------------------------------
' Usage:
'   TEST_BEGIN_ALL
'       TEST_CASE_BEGIN "Name"
'           ... assertions ...
'       TEST_CASE_END
'   TEST_END_ALL
'
' API:
'   TEST_REQUIRE(cond, "message")
'   TEST_REQUIRE2(cond)
'   TEST_REQUIRE_FALSE(cond, "message")
'   TEST_REQUIRE_FALSE2(cond)
'   TEST_CHECK(cond, "message")
'   TEST_CHECK2(cond)
'   TEST_CHECK_FALSE(cond, "message")
'   TEST_CHECK_FALSE2(cond)
'   TEST_ABORTED() ' returns _TRUE when current test has been marked to abort
'   TEST_ENABLE_COLOR(enable) ' _TRUE to enable (default), _FALSE to disable
'   TEST_ENABLE_EXIT_ON_END(enable) ' _TRUE to enable (default), _FALSE to disable
' ==============================================================================

$INCLUDEONCE

$CONSOLE

$IF TEST_STRICT = DEFINED AND TEST_STRICT = TRUE THEN
    _DEFINE A-Z AS LONG
    OPTION _EXPLICITARRAY
    OPTION _EXPLICIT
$END IF

CONST __TEST_COLOR_HEADER = 36 ' light cyan
CONST __TEST_COLOR_PASS = 32 ' light green
CONST __TEST_COLOR_FAIL = 31 ' light red
CONST __TEST_COLOR_SKIP = 33 ' yellow
CONST __TEST_COLOR_NOTE = 90 ' dark gray
CONST __TEST_COLOR_NAME = 97 ' white
CONST __TEST_COLOR_ARROW = 94 ' light blue
CONST __TEST_COLOR_KIND = 35 ' magenta
CONST __TEST_SEPARATOR_WIDTH = 79

TYPE __TestState
    testsRun AS LONG
    assertions AS LONG
    failures AS LONG
    currentTestName AS STRING
    currentTestChecks AS LONG
    currentTestFails AS LONG
    abortCurrentTest AS _BYTE
    skipCurrentTest AS _BYTE
    testStart AS _UNSIGNED _INTEGER64
    filter AS STRING
    errorHandlerEnabled AS _BYTE
    colorDisabled AS _BYTE
    exitOnEndDisabled AS _BYTE
END TYPE

DIM __TestState AS __TestState
