'-----------------------------------------------------------------------------------------------------------------------
' A simple hash table library
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

'$INCLUDE:'HashTable.bi'

'-------------------------------------------------------------------------------------------------------------------
' Test code for debugging the library
'-------------------------------------------------------------------------------------------------------------------
'DEFLNG A-Z
'OPTION _EXPLICIT

'CONST TEST_LB = 1
'CONST TEST_UB = 9999999

'REDIM MyHashTable(0 TO 0) AS HashTableType

'WIDTH , 60
'_FONT 14

'RANDOMIZE TIMER

'DIM myarray(TEST_LB TO TEST_UB) AS LONG, t AS DOUBLE
'DIM AS _UNSIGNED LONG k, i, x

'FOR k = 1 TO 4
'    PRINT "Add element to array..."
'    t = TIMER
'    FOR i = TEST_UB TO TEST_LB STEP -1
'        myarray(i) = x
'        x = x + 1
'    NEXT
'    PRINT USING "#####.##### seconds"; TIMER - t

'    PRINT "Add element to hash table..."
'    t = TIMER
'    FOR i = TEST_UB TO TEST_LB STEP -1
'        HashTable_InsertLong MyHashTable(), i, myarray(i)
'    NEXT
'    PRINT USING "#####.##### seconds"; TIMER - t

'    PRINT "Read element from array..."
'    t = TIMER
'    FOR i = TEST_UB TO TEST_LB STEP -1
'        x = myarray(i)
'    NEXT
'    PRINT USING "#####.##### seconds"; TIMER - t

'    PRINT "Read element from hash table..."
'    t = TIMER
'    FOR i = TEST_UB TO TEST_LB STEP -1
'        x = HashTable_LookupLong(MyHashTable(), i)
'    NEXT
'    PRINT USING "#####.##### seconds"; TIMER - t

'    PRINT "Remove element from hash table..."
'    t = TIMER
'    FOR i = TEST_UB TO TEST_LB STEP -1
'        HashTable_Remove MyHashTable(), i
'    NEXT
'    PRINT USING "#####.##### seconds"; TIMER - t
'NEXT

'REDIM MyHashTable(0 TO 0) AS HashTableType

'FOR i = TEST_LB TO TEST_UB
'    LOCATE , 1: PRINT "Adding key"; i; "Size:"; UBOUND(MyHashTable) + 1;
'    HashTable_InsertLong MyHashTable(), i, myarray(i)
'NEXT
'PRINT

'FOR i = TEST_LB TO TEST_UB
'    LOCATE , 1: PRINT "Verifying key: "; i;
'    IF HashTable_LookupLong(MyHashTable(), i) <> myarray(i) THEN
'        PRINT "[fail] ";
'        SLEEP 1
'    ELSE
'        PRINT "[pass] ";
'    END IF
'NEXT
'PRINT

'FOR i = TEST_UB TO TEST_LB STEP -1
'    LOCATE , 1: PRINT "Removing key"; i; "Size:"; UBOUND(MyHashTable) + 1;
'    HashTable_Remove MyHashTable(), i
'NEXT
'PRINT

'HashTable_InsertLong MyHashTable(), 42, 666
'HashTable_InsertLong MyHashTable(), 7, 123454321
'HashTable_InsertLong MyHashTable(), 21, 69

'PRINT "Value for key 42:"; HashTable_LookupLong(MyHashTable(), 42)
'PRINT "Value for key 7:"; HashTable_LookupLong(MyHashTable(), 7)
'PRINT "Value for key 21:"; HashTable_LookupLong(MyHashTable(), 21)

'PRINT HashTable_IsKeyPresent(MyHashTable(), 100)

'HashTable_Insert MyHashTable(), 43, "grape"
'HashTable_Insert MyHashTable(), 8, "carrot"
'HashTable_Insert MyHashTable(), 22, "apple"

'PRINT "Value for key 22: "; HashTable_Lookup(MyHashTable(), 22)
'PRINT "Value for key 8: "; HashTable_Lookup(MyHashTable(), 8)
'PRINT "Value for key 43: "; HashTable_Lookup(MyHashTable(), 43)

'IF HashTable_IsKeyPresent(MyHashTable(), 43) THEN
'    PRINT "key for grape is in the table."
'END IF

'HashTable_Remove MyHashTable(), 8
'IF NOT HashTable_IsKeyPresent(MyHashTable(), 8) THEN
'    PRINT "key for carrot has been removed."
'END IF

'END
'-------------------------------------------------------------------------------------------------------------------

' Simple hash function: k is the 32-bit key and l is the upper bound of the array
FUNCTION __HashTable_Hash~& (k AS _UNSIGNED LONG, l AS _UNSIGNED LONG)
    $CHECKING:OFF
    ' Actually this should be k MOD (l + 1)
    ' However, we can get away using AND because our arrays size always doubles in multiples of 2
    ' So, if l = 255, then (k MOD (l + 1)) = (k AND l)
    ' Another nice thing here is that we do not need to do the addition :)
    __HashTable_Hash = k AND l
    $CHECKING:ON
END FUNCTION


' Subroutine to resize and rehash the elements in a hash table
SUB __HashTable_ResizeAndRehash (hashTable() AS HashTableType)
    DIM uB AS _UNSIGNED LONG: uB = UBOUND(hashTable)

    ' Resize the array to double its size while preserving contents
    DIM newUB AS _UNSIGNED LONG: newUB = _SHL(uB + 1, 1) - 1
    REDIM _PRESERVE hashTable(0 TO newUB) AS HashTableType

    ' Rehash and swap all the elements
    DIM i AS _UNSIGNED LONG
    FOR i = 0 TO uB
        IF hashTable(i).U THEN SWAP hashTable(i), hashTable(__HashTable_Hash(hashTable(i).K, newUB))
    NEXT i
END SUB


' Resets and sets up the hash table to a default state
SUB HashTable_Initialize (hashTable() AS HashTableType)
    REDIM hashTable(0 TO 0) AS HashTableType
END SUB


' Return TRUE if k is available in the hash table
FUNCTION HashTable_IsKeyPresent%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    HashTable_IsKeyPresent = (hashTable(idx).U _ANDALSO hashTable(idx).K = k)
END FUNCTION


' Remove an element from the hash table
SUB HashTable_Remove (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U _ANDALSO hashTable(idx).K = k THEN hashTable(idx).U = _FALSE
END SUB


' Remove an element from the hash table
' Returns true if successful
FUNCTION HashTable_Remove%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U _ANDALSO hashTable(idx).K = k THEN
        hashTable(idx).U = _FALSE
        HashTable_Remove = _TRUE
    ELSE
        HashTable_Remove = _FALSE
    END IF
END FUNCTION


' Returns the value from the table using a key
' If the key is not valid, it return an empty string
FUNCTION HashTable_Lookup$ (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U _ANDALSO hashTable(idx).K = k THEN HashTable_Lookup = hashTable(idx).V
END FUNCTION


' Returns a _BYTE value from the table using a key
FUNCTION HashTable_LookupByte%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupByte = _CV(_BYTE, HashTable_Lookup(hashTable(), k))
END FUNCTION


' Returns an INTEGER value from the table using a key
FUNCTION HashTable_LookupInteger% (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupInteger = CVI(HashTable_Lookup(hashTable(), k))
END FUNCTION

' Returns a LONG value from the table using a key
FUNCTION HashTable_LookupLong& (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupLong = CVL(HashTable_Lookup(hashTable(), k))
END FUNCTION


' Returns a SINGLE value from the table using a key
FUNCTION HashTable_LookupSingle! (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupSingle = CVS(HashTable_Lookup(hashTable(), k))
END FUNCTION


' Returns a DOUBLE value from the table using a key
FUNCTION HashTable_LookupDouble# (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupDouble = CVD(HashTable_Lookup(hashTable(), k))
END FUNCTION


' Returns an INTEGER64 value from the table using a key
FUNCTION HashTable_LookupInteger64&& (hashTable() AS HashTableType, k AS _UNSIGNED LONG)
    HashTable_LookupInteger64 = _CV(_INTEGER64, HashTable_Lookup(hashTable(), k))
END FUNCTION


' Inserts a value in the table using a key
SUB HashTable_Insert (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS STRING)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U THEN
        IF hashTable(idx).K = k THEN
            ' Key already exists
            EXIT SUB
        ELSE
            __HashTable_ResizeAndRehash hashTable()
            HashTable_Insert hashTable(), k, v
            EXIT SUB
        END IF
    ELSE
        hashTable(idx).U = _TRUE
        hashTable(idx).K = k
        hashTable(idx).V = v
    END IF
END SUB


' Inserts a value in the table using a key
' Returns true if key is unique and insert was successful
FUNCTION HashTable_Insert%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS STRING)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U THEN
        IF hashTable(idx).K = k THEN
            ' Key already exists
            HashTable_Insert = _FALSE
            EXIT FUNCTION
        ELSE
            __HashTable_ResizeAndRehash hashTable()
            HashTable_Insert = HashTable_Insert(hashTable(), k, v)
            EXIT FUNCTION
        END IF
    ELSE
        hashTable(idx).U = _TRUE
        hashTable(idx).K = k
        hashTable(idx).V = v
    END IF

    HashTable_Insert = _TRUE
END FUNCTION


' Inserts a BYTE value in the table using a key
SUB HashTable_InsertByte (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _BYTE)
    HashTable_Insert hashTable(), k, _MK$(_BYTE, v)
END SUB


' Inserts an INTEGER value in the table using a key
SUB HashTable_InsertInteger (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS INTEGER)
    HashTable_Insert hashTable(), k, MKI$(v)
END SUB


' Inserts a LONG value in the table using a key
SUB HashTable_InsertLong (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS LONG)
    HashTable_Insert hashTable(), k, MKL$(v)
END SUB


' Inserts a SINGLE value in the table using a key
SUB HashTable_InsertSingle (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS SINGLE)
    HashTable_Insert hashTable(), k, MKS$(v)
END SUB


' Inserts a DOUBLE value in the table using a key
SUB HashTable_InsertDouble (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS DOUBLE)
    HashTable_Insert hashTable(), k, MKD$(v)
END SUB


' Inserts an INTEGER64 value in the table using a key
SUB HashTable_InsertInteger64 (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _INTEGER64)
    HashTable_Insert hashTable(), k, _MK$(_INTEGER64, v)
END SUB


' Inserts a BYTE value in the table using a key
FUNCTION HashTable_InsertByte%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _BYTE)
    HashTable_InsertByte = HashTable_Insert(hashTable(), k, _MK$(_BYTE, v))
END FUNCTION


' Inserts an INTEGER value in the table using a key
FUNCTION HashTable_InsertInteger%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS INTEGER)
    HashTable_InsertInteger = HashTable_Insert(hashTable(), k, MKI$(v))
END FUNCTION


' Inserts a LONG value in the table using a key
FUNCTION HashTable_InsertLong%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS LONG)
    HashTable_InsertLong = HashTable_Insert(hashTable(), k, MKL$(v))
END FUNCTION


' Inserts a SINGLE value in the table using a key
FUNCTION HashTable_InsertSingle%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS SINGLE)
    HashTable_InsertSingle = HashTable_Insert(hashTable(), k, MKS$(v))
END FUNCTION


' Inserts a DOUBLE value in the table using a key
FUNCTION HashTable_InsertDouble%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS DOUBLE)
    HashTable_InsertDouble = HashTable_Insert(hashTable(), k, MKD$(v))
END FUNCTION


' Inserts an INTEGER64 value in the table using a key
FUNCTION HashTable_InsertInteger64%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _INTEGER64)
    HashTable_InsertInteger64 = HashTable_Insert(hashTable(), k, _MK$(_INTEGER64, v))
END FUNCTION


' Updates or inserts a value in the table using a key
' Returns true if operation was succesful
SUB HashTable_Update (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS STRING)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U THEN
        IF hashTable(idx).K = k THEN
            ' Key already exists
            hashTable(idx).V = v ' allow overwrite
            EXIT SUB
        ELSE
            __HashTable_ResizeAndRehash hashTable()
            HashTable_Update hashTable(), k, v
            EXIT SUB
        END IF
    ELSE
        hashTable(idx).U = _TRUE
        hashTable(idx).K = k
        hashTable(idx).V = v
    END IF
END SUB


' Updates or inserts a value in the table using a key
' Returns true if operation was succesful
FUNCTION HashTable_Update%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS STRING)
    DIM idx AS _UNSIGNED LONG: idx = __HashTable_Hash(k, UBOUND(hashTable))

    IF hashTable(idx).U THEN
        IF hashTable(idx).K = k THEN
            ' Key already exists
            hashTable(idx).V = v ' allow overwrite
            HashTable_Update = _TRUE
            EXIT FUNCTION
        ELSE
            __HashTable_ResizeAndRehash hashTable()
            HashTable_Update = HashTable_Update(hashTable(), k, v)
            EXIT FUNCTION
        END IF
    ELSE
        hashTable(idx).U = _TRUE
        hashTable(idx).K = k
        hashTable(idx).V = v
    END IF

    HashTable_Update = _TRUE
END FUNCTION


' Updates or inserts a BYTE value in the table using a key
SUB HashTable_UpdateByte (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _BYTE)
    HashTable_Update hashTable(), k, _MK$(_BYTE, v)
END SUB


' Updates or inserts an INTEGER value in the table using a key
SUB HashTable_UpdateInteger (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS INTEGER)
    HashTable_Update hashTable(), k, MKI$(v)
END SUB


' Updates or inserts a LONG value in the table using a key
SUB HashTable_UpdateLong (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS LONG)
    HashTable_Update hashTable(), k, MKL$(v)
END SUB


' Updates or inserts a SINGLE value in the table using a key
SUB HashTable_UpdateSingle (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS SINGLE)
    HashTable_Update hashTable(), k, MKS$(v)
END SUB


' Updates or inserts a DOUBLE value in the table using a key
SUB HashTable_UpdateDouble (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS DOUBLE)
    HashTable_Update hashTable(), k, MKD$(v)
END SUB


' Updates or inserts an INTEGER64 value in the table using a key
SUB HashTable_UpdateInteger64 (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _INTEGER64)
    HashTable_Update hashTable(), k, _MK$(_INTEGER64, v)
END SUB


' Updates or inserts a BYTE value in the table using a key
FUNCTION HashTable_UpdateByte%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _BYTE)
    HashTable_UpdateByte = HashTable_Update(hashTable(), k, _MK$(_BYTE, v))
END FUNCTION


' Updates or inserts an INTEGER value in the table using a key
FUNCTION HashTable_UpdateInteger%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS INTEGER)
    HashTable_UpdateInteger = HashTable_Update(hashTable(), k, MKI$(v))
END FUNCTION


' Updates or inserts a LONG value in the table using a key
FUNCTION HashTable_UpdateLong%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS LONG)
    HashTable_UpdateLong = HashTable_Update(hashTable(), k, MKL$(v))
END FUNCTION


' Updates or inserts a SINGLE value in the table using a key
FUNCTION HashTable_UpdateSingle%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS SINGLE)
    HashTable_UpdateSingle = HashTable_Update(hashTable(), k, MKS$(v))
END FUNCTION


' Updates or inserts a DOUBLE value in the table using a key
FUNCTION HashTable_UpdateDouble%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS DOUBLE)
    HashTable_UpdateDouble = HashTable_Update(hashTable(), k, MKD$(v))
END FUNCTION


' Updates or inserts an INTEGER64 value in the table using a key
FUNCTION HashTable_UpdateInteger64%% (hashTable() AS HashTableType, k AS _UNSIGNED LONG, v AS _INTEGER64)
    HashTable_UpdateInteger64 = HashTable_Update(hashTable(), k, _MK$(_INTEGER64, v))
END FUNCTION
