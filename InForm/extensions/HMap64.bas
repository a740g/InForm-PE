'-----------------------------------------------------------------------------------------------------------------------
' A simple hash table library
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

'$INCLUDE:'HMap64.bi'

''' @brief Compute a simple integer hash and reduce it to an index.
''' @param k The integer to hash.
''' @param tableSize The hash map size (must be a power of 2).
''' @return The computed hash index in the range 1 to tableSize.
FUNCTION __HMap64_Hash~& (k AS _UNSIGNED _OFFSET, tableSize AS _UNSIGNED _OFFSET)
    __HMap64_Hash = 1 + (k AND (tableSize - 1))
END FUNCTION

''' @brief Check whether the hash map has been initialized.
''' @param map The dynamic HMap64 array to check.
''' @return _TRUE if initialized, otherwise _FALSE.
FUNCTION HMap64_IsInitialized%% (map() AS HMap64)
    HMap64_IsInitialized = LBOUND(map) = 0 _ANDALSO UBOUND(map) > 0 _ANDALSO map(0).T = HMAP_TYPE_RESERVED
END FUNCTION

''' @brief Initialize a hash map (allocate initial table and reset metadata).
''' @param map The dynamic HMap64 array to initialize.
SUB HMap64_Initialize (map() AS HMap64)
    REDIM map(0 TO 16) AS HMap64 ' power of 2 initial size
    map(0).T = HMAP_TYPE_RESERVED ' mark as initialized
END SUB

''' @brief Clear the hash map, but do not change the capacity.
''' @param map The hash map to clear.
SUB HMap64_Clear (map() AS HMap64)
    REDIM map(0 TO UBOUND(map)) AS HMap64

    map(0).T = HMAP_TYPE_RESERVED ' set to reserved
END SUB

''' @brief Delete the hash map and free all associated memory.
''' @param map The hash map to clear.
SUB HMap64_Free (map() AS HMap64)
    REDIM map(0) AS HMap64
END SUB

''' @brief Return the current capacity of the hash map.
''' @param map The hash map to query.
''' @return The total number of slots in the map.
FUNCTION HMap64_GetCapacity~%& (map() AS HMap64)
    HMap64_GetCapacity = UBOUND(map)
END FUNCTION

''' @brief Return the number of user entries currently stored in the map.
''' @param map The hash map to query.
''' @return The number of unique items.
FUNCTION HMap64_GetCount~%& (map() AS HMap64)
    HMap64_GetCount = map(0).K
END FUNCTION

''' @brief Resize the hash table and rehash all user entries.
''' @param map The dynamic HMap64 array to resize.
SUB __HMap64_ResizeAndRehash (map() AS HMap64)
    DIM oldSize AS _UNSIGNED _OFFSET: oldSize = UBOUND(map)

    ' Resize the array to double its size while preserving contents
    DIM newSize AS _UNSIGNED _OFFSET: newSize = _SHL(oldSize, 1) ' grow by power of 2
    REDIM _PRESERVE map(0 TO newSize) AS HMap64

    ' Rehash and swap all the elements
    DIM i AS _UNSIGNED _OFFSET: i = 1
    WHILE i <= oldSize
        IF map(i).T > HMAP_TYPE_DELETED THEN
            DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(map(i).K, newSize)
            SWAP map(i).T, map(idx).T
            SWAP map(i).V, map(idx).V
            SWAP map(i).K, map(idx).K
        END IF

        i = i + 1
    WEND
END SUB

''' @brief Delete a key-value pair by key and return whether it existed.
''' @param map The hash map to modify.
''' @param k The key to remove.
''' @return _TRUE if the key was removed, otherwise _FALSE.
FUNCTION HMap64_Delete%% (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(k, UBOUND(map))

    IF map(idx).T > HMAP_TYPE_DELETED _ANDALSO map(idx).K = k THEN
        map(idx).T = HMAP_TYPE_DELETED
        map(0).K = map(0).K - 1
        HMap64_Delete = _TRUE
    END IF
END FUNCTION

''' @brief Removes a key-value pair by key.
''' @param map The hash map to modify.
''' @param k The key to remove.
''' @return _TRUE if removed, _FALSE if not found.
SUB HMap64_Delete (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    DIM ignored AS _BYTE: ignored = HMap64_Delete%%(map(), k)
END SUB

''' @brief Checks if a key exists in the table.
''' @param table The hash table to search.
''' @param k The key to check.
''' @return _TRUE if present, _FALSE otherwise.
FUNCTION HMap64_Exists%% (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(k, UBOUND(map))
    HMap64_Exists = map(idx).T > HMAP_TYPE_DELETED _ANDALSO map(idx).K = k
END FUNCTION

''' @brief Return the stored data type for a key.
''' @param map The hash map to search.
''' @param k The key string to look up.
''' @return The associated data type constant (HMAP_TYPE_*), or 0 if not found.
FUNCTION HMap64_GetDataType~%% (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(k, UBOUND(map))
    IF map(idx).T > HMAP_TYPE_DELETED _ANDALSO map(idx).K = k THEN
        HMap64_GetDataType = map(idx).T
    END IF
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value string.
''' @param dataType The data type constant for the value being stored.
SUB __HMap64_Set (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS STRING, dataType AS _UNSIGNED _BYTE)
    DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(k, UBOUND(map))

    IF map(idx).T > HMAP_TYPE_DELETED THEN
        IF map(idx).K = k THEN
            ' Key found, update value and exit
            map(idx).V = v
            map(idx).T = dataType
            EXIT SUB
        ELSE
            __HMap64_ResizeAndRehash map()
            __HMap64_Set map(), k, v, dataType
            EXIT SUB
        END IF
    ELSE
        map(idx).K = k
        map(idx).V = v
        map(idx).T = dataType
        map(0).K = map(0).K + 1
    END IF
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated value string, or an empty string if not found.
FUNCTION HMap64_GetString$ (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    DIM idx AS _UNSIGNED _OFFSET: idx = __HMap64_Hash(k, UBOUND(map))
    IF map(idx).T > HMAP_TYPE_DELETED _ANDALSO map(idx).K = k THEN HMap64_GetString = map(idx).V
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value string.
SUB HMap64_SetString (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS STRING)
    __HMap64_Set map(), k, v, HMAP_TYPE_STRING
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated _BYTE value.
FUNCTION HMap64_GetByte%% (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetByte = _CV(_BYTE, HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value _BYTE.
SUB HMap64_SetByte (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS _BYTE)
    __HMap64_Set map(), k, _MK$(_BYTE, v), HMAP_TYPE_BYTE
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated INTEGER value.
FUNCTION HMap64_GetInteger% (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetInteger = CVI(HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value INTEGER.
SUB HMap64_SetInteger (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS INTEGER)
    __HMap64_Set map(), k, MKI$(v), HMAP_TYPE_INTEGER
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated LONG value.
FUNCTION HMap64_GetLong& (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetLong = CVL(HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value LONG.
SUB HMap64_SetLong (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS LONG)
    __HMap64_Set map(), k, MKL$(v), HMAP_TYPE_LONG
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated _INTEGER64 value.
FUNCTION HMap64_GetInteger64&& (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetInteger64 = _CV(_INTEGER64, HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value _INTEGER64.
SUB HMap64_SetInteger64 (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS _INTEGER64)
    __HMap64_Set map(), k, _MK$(_INTEGER64, v), HMAP_TYPE_INTEGER64
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated SINGLE value.
FUNCTION HMap64_GetSingle! (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetSingle = CVS(HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value SINGLE.
SUB HMap64_SetSingle (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS SINGLE)
    __HMap64_Set map(), k, MKS$(v), HMAP_TYPE_SINGLE
END SUB

''' @brief Retrieves the value for a given key.
''' @param table The hash table to search.
''' @param k The key to look up.
''' @return The associated DOUBLE value.
FUNCTION HMap64_GetDouble# (map() AS HMap64, k AS _UNSIGNED _OFFSET)
    HMap64_GetDouble = CVD(HMap64_GetString(map(), k))
END FUNCTION

''' @brief Updates an existing key or inserts it if not present.
''' @param table The hash table to update.
''' @param k The key.
''' @param v The value DOUBLE.
SUB HMap64_SetDouble (map() AS HMap64, k AS _UNSIGNED _OFFSET, v AS DOUBLE)
    __HMap64_Set map(), k, MKD$(v), HMAP_TYPE_DOUBLE
END SUB
