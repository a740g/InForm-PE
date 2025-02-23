'-----------------------------------------------------------------------------------------------------------------------
' File I/O like routines for memory loaded files
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

' Simplified QB64-only memory-file
TYPE StringFileType
    buffer AS STRING
    cursor AS _UNSIGNED LONG
END TYPE
