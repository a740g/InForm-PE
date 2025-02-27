'-----------------------------------------------------------------------------------------------------------------------
' A simple hash table for integers and QB64-PE handles
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

CONST __HASHTABLE_KEY_EXISTS& = -1&
CONST __HASHTABLE_KEY_UNAVAILABLE& = -2&

' Hash table entry type
' To extended supported data types, add other value types after V and then write
' wrappers around __HashTable_GetInsertIndex() & __HashTable_GetLookupIndex()
TYPE HashTableType
    U AS _BYTE ' used?
    K AS _UNSIGNED LONG ' key
    V AS LONG ' value
END TYPE
