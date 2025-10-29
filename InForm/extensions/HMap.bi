'-----------------------------------------------------------------------------------------------------------------------
' Generic hash map library for QB64-PE with support for multiple data types and dynamic resizing
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

' Data type constants
CONST HMAP_TYPE_NONE~%% = 0~%% ' unused
CONST HMAP_TYPE_RESERVED~%% = 1~%% ' metadata
CONST HMAP_TYPE_DELETED~%% = 2~%% ' tombstone
CONST HMAP_TYPE_STRING~%% = 3~%%
CONST HMAP_TYPE_BYTE~%% = 4~%%
CONST HMAP_TYPE_INTEGER~%% = 5~%%
CONST HMAP_TYPE_LONG~%% = 6~%%
CONST HMAP_TYPE_INTEGER64~%% = 7~%%
CONST HMAP_TYPE_SINGLE~%% = 8~%%
CONST HMAP_TYPE_DOUBLE~%% = 9~%%
CONST HMAP_TYPE_UDT~%% = 10~%% ' user-define data types (HMAP_TYPE_UDT .. 255)

''' @brief Primary data structure used by the HMap library.
''' The user declares a dynamic array of this type and passes it to the HMap_* functions.
''' The library stores internal metadata at array index 0; user entries begin at index 1.
''' Metadata (stored in element 0):
'''     - K: unused
'''     - V: count of items (_MK$(_UNSIGNED _OFFSET, count))
'''     - T: set to HMAP_TYPE_RESERVED
TYPE HMap
    K AS STRING ' key or metadata (unused)
    V AS STRING ' value or metadata (count)
    T AS _UNSIGNED _BYTE ' data type of the value (0 = unused) or metadata (HMAP_TYPE_RESERVED)
END TYPE
