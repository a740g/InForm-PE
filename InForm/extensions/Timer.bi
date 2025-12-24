'-----------------------------------------------------------------------------------------------------------------------
' User configurable timer library
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

'$INCLUDE:'Time.bi'

' Timer type and storage
TYPE __Timer
    intervalTicks AS _UNSIGNED _INTEGER64 ' interval length, in ticks
    lastTick AS _UNSIGNED _INTEGER64 ' last time we advanced this timer
END TYPE

REDIM __timer(0) AS __Timer
