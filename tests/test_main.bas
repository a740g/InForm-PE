' InForm-PE test suite

$LET TEST_STRICT = TRUE
'$INCLUDE:'../InForm/extensions/Catch.bi'
$CONSOLE:ONLY

'$INCLUDE:'../InForm/extensions/HashTable.bi'
'$INCLUDE:'../InForm/extensions/Pathname.bi'
'$INCLUDE:'../InForm/extensions/StringFile.bi'

'$INCLUDE:'../InForm/extensions/CatchError.bi'

'$INCLUDE:'../InForm/InForm.bi'

SUB __UI_BeforeInit
    TEST_BEGIN_ALL

    Test_Catch
    Test_Algo
    Test_Hash
    Test_Pathname
    Test_StringFile
    Test_InFormUIUtils
    Test_InFormUIHelpers
    Test_InFormUIUnicodeUtils

    TEST_END_ALL
END SUB

SUB Test_Catch
    TEST_CASE_BEGIN "Catch"

    TEST_REQUIRE 2 * 3 = 6, "2 * 3 = 6"
    TEST_CHECK 1 + 1 = 2, "1 + 1 = 2"
    TEST_REQUIRE_FALSE 1 = 2, "1 = 2"
    TEST_CHECK_FALSE 3 = 4, "3 = 4"
    TEST_REQUIRE2 2 * 3 = 6
    TEST_CHECK2 10 / 2 = 5
    TEST_REQUIRE_FALSE2 1 = 2
    TEST_CHECK_FALSE2 3 = 4

    TEST_CASE_END
END SUB

SUB Test_Algo
    TEST_CASE_BEGIN "Algo: Basic Sort"
    DIM strArr(0 TO 4) AS STRING
    strArr(0) = "banana"
    strArr(1) = "apple"
    strArr(2) = "orange"
    strArr(3) = "pear"
    strArr(4) = "kiwi"
    TEST_REQUIRE Algo_SortStringArray(strArr()), "Algo_SortStringArray should return TRUE for an unsorted array"
    TEST_CHECK strArr(0) = "apple", "Sorted array element 0 should be 'apple'"
    TEST_CHECK strArr(1) = "banana", "Sorted array element 1 should be 'banana'"
    TEST_CHECK strArr(2) = "kiwi", "Sorted array element 2 should be 'kiwi'"
    TEST_CHECK strArr(3) = "orange", "Sorted array element 3 should be 'orange'"
    TEST_CHECK strArr(4) = "pear", "Sorted array element 4 should be 'pear'"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Already Sorted"
    DIM sortedArr(0 TO 2) AS STRING
    sortedArr(0) = "a"
    sortedArr(1) = "b"
    sortedArr(2) = "c"
    TEST_REQUIRE_FALSE Algo_SortStringArray(sortedArr()), "Algo_SortStringArray should return FALSE for a sorted array"
    TEST_CHECK sortedArr(0) = "a", "Array should remain unchanged"
    TEST_CHECK sortedArr(1) = "b", "Array should remain unchanged"
    TEST_CHECK sortedArr(2) = "c", "Array should remain unchanged"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Reverse Sorted"
    DIM reverseArr(0 TO 3) AS STRING
    reverseArr(0) = "zulu"
    reverseArr(1) = "yankee"
    reverseArr(2) = "x-ray"
    reverseArr(3) = "whiskey"
    TEST_REQUIRE Algo_SortStringArray(reverseArr()), "Algo_SortStringArray should return TRUE for a reverse-sorted array"
    TEST_CHECK reverseArr(0) = "whiskey", "Sorted array element 0 should be 'whiskey'"
    TEST_CHECK reverseArr(1) = "x-ray", "Sorted array element 1 should be 'x-ray'"
    TEST_CHECK reverseArr(2) = "yankee", "Sorted array element 2 should be 'yankee'"
    TEST_CHECK reverseArr(3) = "zulu", "Sorted array element 3 should be 'zulu'"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: With Duplicates"
    DIM dupArr(0 TO 5) AS STRING
    dupArr(0) = "b"
    dupArr(1) = "a"
    dupArr(2) = "c"
    dupArr(3) = "b"
    dupArr(4) = "a"
    dupArr(5) = "c"
    TEST_REQUIRE Algo_SortStringArray(dupArr()), "Algo_SortStringArray should return TRUE for an array with duplicates"
    TEST_CHECK dupArr(0) = "a", "Sorted array with duplicates element 0"
    TEST_CHECK dupArr(1) = "a", "Sorted array with duplicates element 1"
    TEST_CHECK dupArr(2) = "b", "Sorted array with duplicates element 2"
    TEST_CHECK dupArr(3) = "b", "Sorted array with duplicates element 3"
    TEST_CHECK dupArr(4) = "c", "Sorted array with duplicates element 4"
    TEST_CHECK dupArr(5) = "c", "Sorted array with duplicates element 5"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: With Empty Strings"
    DIM emptyArr(0 TO 3) AS STRING
    emptyArr(0) = "beta"
    emptyArr(1) = ""
    emptyArr(2) = "alpha"
    emptyArr(3) = ""
    TEST_REQUIRE Algo_SortStringArray(emptyArr()), "Algo_SortStringArray should return TRUE for an array with empty strings"
    TEST_CHECK emptyArr(0) = "", "Sorted array with empty strings element 0"
    TEST_CHECK emptyArr(1) = "", "Sorted array with empty strings element 1"
    TEST_CHECK emptyArr(2) = "alpha", "Sorted array with empty strings element 2"
    TEST_CHECK emptyArr(3) = "beta", "Sorted array with empty strings element 3"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Single Element"
    DIM singleArr(0 TO 0) AS STRING
    singleArr(0) = "lonely"
    TEST_REQUIRE_FALSE Algo_SortStringArray(singleArr()), "Algo_SortStringArray should return FALSE for a single-element array"
    TEST_CHECK singleArr(0) = "lonely", "Single element array should remain unchanged"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Empty Array"
    DIM zeroArr(0) AS STRING
    TEST_REQUIRE_FALSE Algo_SortStringArray(zeroArr()), "Algo_SortStringArray should return FALSE for an empty array"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Sort Range"
    DIM rangeArr(0 TO 5) AS STRING
    rangeArr(0) = "z"
    rangeArr(1) = "e"
    rangeArr(2) = "d"
    rangeArr(3) = "c"
    rangeArr(4) = "b"
    rangeArr(5) = "a"
    TEST_REQUIRE Algo_SortStringArrayRange(rangeArr(), 1, 4, _TRUE, _TRUE), "Algo_SortStringArrayRange should return TRUE for an unsorted range"
    TEST_CHECK rangeArr(0) = "z", "Element before range should be untouched"
    TEST_CHECK rangeArr(1) = "b", "Range should be sorted"
    TEST_CHECK rangeArr(2) = "c", "Range should be sorted"
    TEST_CHECK rangeArr(3) = "d", "Range should be sorted"
    TEST_CHECK rangeArr(4) = "e", "Range should be sorted"
    TEST_CHECK rangeArr(5) = "a", "Element after range should be untouched"
    TEST_CASE_END

    TEST_CASE_BEGIN "Algo: Sort Range (already sorted)"
    DIM sortedRangeArr(0 TO 3) AS STRING
    sortedRangeArr(0) = "a"
    sortedRangeArr(1) = "b"
    sortedRangeArr(2) = "c"
    sortedRangeArr(3) = "d"
    TEST_REQUIRE_FALSE Algo_SortStringArrayRange(sortedRangeArr(), 1, 2, _TRUE, _TRUE), "Algo_SortStringArrayRange should return FALSE for a sorted range"
    TEST_CHECK sortedRangeArr(0) = "a", "Array should remain unchanged"
    TEST_CHECK sortedRangeArr(1) = "b", "Array should remain unchanged"
    TEST_CHECK sortedRangeArr(2) = "c", "Array should remain unchanged"
    TEST_CHECK sortedRangeArr(3) = "d", "Array should remain unchanged"
    TEST_CASE_END
END SUB

SUB Test_Hash
    CONST TEST_LB = 0
    CONST TEST_UB = 9999999

    REDIM MyHashTable(0) AS HashTableType: HashTable_Initialize MyHashTable()

    DIM myarray(TEST_LB TO TEST_UB) AS LONG
    DIM AS _UNSIGNED LONG k, i, x

    FOR k = 1 TO 2
        TEST_CASE_BEGIN "HashTable: Add element to array performance"
        FOR i = TEST_LB TO TEST_UB
            myarray(i) = x
            x = x + 1
        NEXT
        TEST_CASE_END

        TEST_CASE_BEGIN "HashTable: Add element to hash table performance"
        FOR i = TEST_LB TO TEST_UB
            HashTable_InsertLong MyHashTable(), i, myarray(i)
        NEXT
        TEST_CASE_END

        TEST_CASE_BEGIN "HashTable: Read element from array performance"
        FOR i = TEST_LB TO TEST_UB
            x = myarray(i)
        NEXT
        TEST_CASE_END

        TEST_CASE_BEGIN "HashTable: Read element from hash table performance"
        FOR i = TEST_LB TO TEST_UB
            x = HashTable_LookupLong(MyHashTable(), i)
        NEXT
        TEST_CASE_END

        TEST_CASE_BEGIN "HashTable: Remove element from hash table performance"
        FOR i = TEST_LB TO TEST_UB
            HashTable_Remove MyHashTable(), i
        NEXT
        TEST_CASE_END
    NEXT

    HashTable_Initialize MyHashTable()

    FOR i = TEST_LB TO TEST_UB
        HashTable_InsertLong MyHashTable(), i, myarray(i)
    NEXT

    TEST_CASE_BEGIN "HashTable: Lookup test"
    DIM lookupFailed AS _BYTE
    FOR i = TEST_LB TO TEST_UB
        IF HashTable_LookupLong(MyHashTable(), i) <> myarray(i) THEN
            lookupFailed = _TRUE
            EXIT FOR
        END IF
    NEXT
    TEST_REQUIRE NOT lookupFailed, "NOT lookupFailed"
    TEST_CASE_END

    TEST_CASE_BEGIN "HashTable: Remove and insert test"
    FOR i = TEST_UB TO TEST_LB STEP -1
        HashTable_Remove MyHashTable(), i
    NEXT

    HashTable_InsertLong MyHashTable(), 42, 666
    HashTable_InsertLong MyHashTable(), 7, 123454321
    HashTable_InsertLong MyHashTable(), 21, 69

    TEST_CHECK HashTable_LookupLong(MyHashTable(), 42) = 666, "HashTable_LookupLong(MyHashTable(), 42) = 666"
    TEST_CHECK HashTable_LookupLong(MyHashTable(), 7) = 123454321, "HashTable_LookupLong(MyHashTable(), 7) = 123454321"
    TEST_CHECK HashTable_LookupLong(MyHashTable(), 21) = 69, "HashTable_LookupLong(MyHashTable(), 21) = 69"

    TEST_CHECK HashTable_IsKeyPresent(MyHashTable(), 42), "HashTable_IsKeyPresent(MyHashTable(), 42)"
    TEST_CHECK_FALSE HashTable_IsKeyPresent(MyHashTable(), 100), "HashTable_IsKeyPresent(MyHashTable(), 100)"

    HashTable_Insert MyHashTable(), 43, "grape"
    HashTable_Insert MyHashTable(), 8, "carrot"
    HashTable_Insert MyHashTable(), 22, "apple"

    TEST_CHECK HashTable_Lookup(MyHashTable(), 43) = "grape", "HashTable_Lookup(MyHashTable(), 43) = grape"
    TEST_CHECK HashTable_Lookup(MyHashTable(), 8) = "carrot", "HashTable_Lookup(MyHashTable(), 8) = carrot"
    TEST_CHECK HashTable_Lookup(MyHashTable(), 22) = "apple", "HashTable_Lookup(MyHashTable(), 22) = apple"
    TEST_CHECK HashTable_IsKeyPresent(MyHashTable(), 43), "HashTable_IsKeyPresent(MyHashTable(), 43)"

    HashTable_Remove MyHashTable(), 8
    TEST_CHECK_FALSE HashTable_IsKeyPresent(MyHashTable(), 8), "HashTable_IsKeyPresent(MyHashTable(), 8)"
    TEST_CASE_END
END SUB

SUB Test_Pathname
    TEST_CASE_BEGIN "Pathname"

    TEST_CHECK Pathname_IsAbsolute("C:/Windows"), "Pathname_IsAbsolute('C:/Windows')"
    TEST_CHECK Pathname_IsAbsolute("/Windows"), "Pathname_IsAbsolute('/Windows')"
    TEST_CHECK_FALSE Pathname_IsAbsolute("Windows"), "Pathname_IsAbsolute('Windows')"
    TEST_CHECK_FALSE Pathname_IsAbsolute(""), "Pathname_IsAbsolute('')"

    $IF WINDOWS THEN
        TEST_CHECK Pathname_AddDirectorySeparator("Windows") = "Windows\", "Pathname_AddDirectorySeparator('Windows')"
    $ELSE
        TEST_CHECK Pathname_AddDirectorySeparator("Windows") = "Windows/", "Pathname_AddDirectorySeparator('Windows')"
    $END IF

    TEST_CHECK Pathname_AddDirectorySeparator("Windows/") = "Windows/", "Pathname_AddDirectorySeparator('Windows/')"
    TEST_CHECK Pathname_AddDirectorySeparator("") = "", "Pathname_AddDirectorySeparator('')"

    $IF WINDOWS THEN
        TEST_CHECK Pathname_FixDirectorySeparators("C:/Windows\\") = "C:\Windows\\", "Pathname_FixDirectorySeparators('C:/Windows\\')"
    $ELSE
        TEST_CHECK Pathname_FixDirectorySeparators("C:/Windows\\") = "C:/Windows//", "Pathname_FixDirectorySeparators('C:/Windows\\')"
    $END IF

    TEST_CHECK Pathname_FixDirectorySeparators("Windows") = "Windows", "Pathname_FixDirectorySeparators('Windows')"
    TEST_CHECK Pathname_FixDirectorySeparators("") = "", "Pathname_FixDirectorySeparators('')"

    TEST_CHECK Pathname_GetFileName("C:\\foo/bar.ext") = "bar.ext", "Pathname_GetFileName('C:\\foo/bar.ext')"
    TEST_CHECK Pathname_GetFileName("bar.ext") = "bar.ext", "Pathname_GetFileName('bar.ext')"
    TEST_CHECK Pathname_GetFileName("") = "", "Pathname_GetFileName('')"

    TEST_CHECK Pathname_GetPath("C:\\foo/bar.ext") = "C:\\foo/", "Pathname_GetPath('C:\\foo/bar.ext')"
    TEST_CHECK Pathname_GetPath("\\bar.ext") = "\\", "Pathname_GetPath('\\bar.ext')"
    TEST_CHECK Pathname_GetPath("") = "", "Pathname_GetPath('')"

    TEST_CHECK Pathname_HasFileExtension("C:\\foo/bar.ext"), "Pathname_HasFileExtension('C:\\foo/bar.ext')"
    TEST_CHECK_FALSE Pathname_HasFileExtension("bar.ext/"), "Pathname_HasFileExtension('bar.ext/')"
    TEST_CHECK_FALSE Pathname_HasFileExtension(""), "Pathname_HasFileExtension('')"

    TEST_CHECK Pathname_GetFileExtension("C:\\foo/bar.ext") = ".ext", "Pathname_GetFileExtension('C:\\foo/bar.ext')"
    TEST_CHECK Pathname_GetFileExtension("bar.ext/") = "", "Pathname_GetFileExtension('bar.ext/')"
    TEST_CHECK Pathname_GetFileExtension("") = "", "Pathname_GetFileExtension('')"

    TEST_CHECK Pathname_RemoveFileExtension("C:\\foo/bar.ext") = "C:\\foo/bar", "Pathname_RemoveFileExtension('C:\\foo/bar.ext')"
    TEST_CHECK Pathname_RemoveFileExtension("bar.ext/") = "bar.ext/", "Pathname_RemoveFileExtension('bar.ext/')"
    TEST_CHECK Pathname_RemoveFileExtension("") = "", "Pathname_RemoveFileExtension('')"

    TEST_CHECK Pathname_GetDriveOrScheme("https://www.github.com/") = "https:", "Pathname_GetDriveOrScheme('https://www.github.com/')"
    TEST_CHECK Pathname_GetDriveOrScheme("C:\\Windows\\") = "C:", "Pathname_GetDriveOrScheme('C:\\Windows\\')"
    TEST_CHECK Pathname_GetDriveOrScheme("") = "", "Pathname_GetDriveOrScheme('')"

    TEST_CHECK Pathname_Sanitize("<abracadabra.txt/>") = "_abracadabra.txt__", "Pathname_Sanitize('<abracadabra.txt/>')"
    TEST_CHECK Pathname_Sanitize("") = "", "Pathname_Sanitize('')"

    TEST_CASE_END
END SUB

SUB Test_StringFile
    TEST_CASE_BEGIN "StringFile"

    DIM sf AS StringFileType
    StringFile_Create sf, "This_is_a_test_buffer."
    TEST_CHECK LEN(sf.buffer) = 22, "LEN(sf.buffer) = 22"
    TEST_CHECK sf.cursor = 0, "sf.cursor = 0"
    TEST_CHECK StringFile_GetPosition(sf) = 0, "StringFile_GetPosition(sf) = 0"
    TEST_CHECK StringFile_ReadString(sf, 22) = "This_is_a_test_buffer.", "StringFile_ReadString(sf, 22)"
    TEST_CHECK StringFile_GetPosition(sf) = 22, "StringFile_GetPosition(sf) = 22"
    TEST_CHECK StringFile_IsEOF(sf), "StringFile_IsEOF(sf)"
    TEST_CHECK LEN(sf.buffer) = 22, "LEN(sf.buffer) = 22"
    TEST_CHECK sf.cursor = 22, "sf.cursor = 22"
    StringFile_Seek sf, StringFile_GetPosition(sf) - 1
    StringFile_WriteString sf, "! Now adding some more text."
    TEST_CHECK StringFile_GetPosition(sf) = 49, "StringFile_GetPosition(sf) = 49"
    TEST_CHECK StringFile_IsEOF(sf), "StringFile_IsEOF(sf)"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 49, "sf.cursor = 49"
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_GetPosition(sf) = 0, "StringFile_GetPosition(sf) = 0"
    TEST_CHECK_FALSE StringFile_IsEOF(sf), "NOT StringFile_IsEOF(sf)"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 0, "sf.cursor = 0"
    TEST_CHECK StringFile_ReadString(sf, 49) = "This_is_a_test_buffer! Now adding some more text.", "StringFile_ReadString(sf, 49)"
    TEST_CHECK StringFile_GetPosition(sf) = 49, "StringFile_GetPosition(sf) = 49"
    TEST_CHECK StringFile_IsEOF(sf), "StringFile_IsEOF(sf)"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 49, "sf.cursor = 49"
    StringFile_Seek sf, 0
    TEST_CHECK CHR$(StringFile_ReadByte(sf)) = "T", "CHR$(StringFile_ReadByte(sf)) = T"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 1, "sf.cursor = 1"
    StringFile_WriteString sf, "XX"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 3, "sf.cursor = 3"
    TEST_CHECK CHR$(StringFile_ReadByte(sf)) = "s", "CHR$(StringFile_ReadByte(sf)) = s"
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadString(sf, 49) = "TXXs_is_a_test_buffer! Now adding some more text.", "StringFile_ReadString(sf, 49)"
    TEST_CHECK StringFile_GetPosition(sf) = 49, "StringFile_GetPosition(sf) = 49"
    TEST_CHECK StringFile_IsEOF(sf), "StringFile_IsEOF(sf)"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    TEST_CHECK sf.cursor = 49, "sf.cursor = 49"
    StringFile_Seek sf, 0
    StringFile_WriteInteger sf, 420
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadInteger(sf) = 420, "StringFile_ReadInteger(sf) = 420"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    StringFile_Seek sf, 0
    StringFile_WriteByte sf, 255
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadByte(sf) = 255, "StringFile_ReadByte(sf) = 255"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    StringFile_Seek sf, 0
    StringFile_WriteLong sf, 192000
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadLong(sf) = 192000, "StringFile_ReadLong(sf) = 192000"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    StringFile_Seek sf, 0
    StringFile_WriteSingle sf, 752.334
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadSingle(sf) = 752.334, "StringFile_ReadSingle(sf) = 752.334"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    StringFile_Seek sf, 0
    StringFile_WriteDouble sf, 23232323.242423424#
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadDouble(sf) = 23232323.242423424#, "StringFile_ReadDouble(sf) = 23232323.242423424#"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"
    StringFile_Seek sf, 0
    StringFile_WriteInteger64 sf, 9999999999999999&&
    StringFile_Seek sf, 0
    TEST_CHECK StringFile_ReadInteger64(sf) = 9999999999999999&&, "StringFile_ReadInteger64(sf) = 9999999999999999&&"
    TEST_CHECK LEN(sf.buffer) = 49, "LEN(sf.buffer) = 49"

    TEST_CASE_END
END SUB

SUB Test_InFormUIUtils
    TEST_CASE_BEGIN "InFormUIUtils: Darken"

    TEST_CHECK Darken(0, 0) = &HFF000000~&, "Darken(0, 0) = &HFF000000~&"
    TEST_CHECK Darken(&HFFFFFFFF~&, 0) = &HFF000000~&, "Darken(&HFFFFFFFF~&, 0) = &HFF000000~&"
    TEST_CHECK Darken(&HFFFFFFFF~&, 50) = &HFF808080~&, "Darken(&HFFFFFFFF~&, 50) = &HFF808080~&"
    TEST_CHECK Darken(&HFFFFFFFF~&, 100) = &HFFFFFFFF~&, "Darken(&HFFFFFFFF~&, 100) = &HFFFFFFFF~&"
    TEST_CHECK Darken(&HFF123456~&, 50) = &HFF091A2B~&, "Darken(&HFF123456~&, 50) = &HFF091A2B~&"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIUtils: IsNumber"

    TEST_CHECK IsNumber("123"), "IsNumber('123')"
    TEST_CHECK IsNumber("-123"), "IsNumber('-123')"
    TEST_CHECK IsNumber("123.123"), "IsNumber('123.123')"
    TEST_CHECK IsNumber("-123.123"), "IsNumber('-123.123')"
    TEST_CHECK IsNumber("0"), "IsNumber('0')"
    TEST_CHECK IsNumber("0.0"), "IsNumber('0.0')"
    TEST_CHECK IsNumber(".123"), "IsNumber('.123')"
    TEST_CHECK IsNumber("-.123"), "IsNumber('-.123')"
    TEST_CHECK_FALSE IsNumber("abc"), "IsNumber('abc')"
    TEST_CHECK_FALSE IsNumber("123abc"), "IsNumber('123abc')"
    TEST_CHECK_FALSE IsNumber(""), "IsNumber('')"
    TEST_CHECK_FALSE IsNumber("-"), "IsNumber('-')"
    TEST_CHECK_FALSE IsNumber("."), "IsNumber('.')"
    TEST_CHECK_FALSE IsNumber("192.168.1.1"), "IsNumber('192.168.1.1')"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIUtils: Replace"

    DIM changes AS LONG

    TEST_CHECK Replace("", "x", "y", _TRUE, changes) = "", "Empty source string"
    TEST_CHECK changes = 0, "No replacements expected"

    TEST_CHECK Replace("abc", "", "x", _TRUE, changes) = "abc", "Empty target string"
    TEST_CHECK changes = 0, "No replacements expected"

    TEST_CHECK Replace("abcabc", "b", "", _TRUE, changes) = "acac", "Remove 'b' from string"
    TEST_CHECK changes = 2, "Two replacements"

    TEST_CHECK Replace("Hello World", "world", "Universe", _TRUE, changes) = "Hello World", "No match due to case"
    TEST_CHECK changes = 0, "No replacements"

    TEST_CHECK Replace("Hello World", "xyz", "Universe", _FALSE, changes) = "Hello World", "No match at all"
    TEST_CHECK changes = 0, "No replacements"

    TEST_CHECK Replace("Hello World", "World", "Universe", _TRUE, changes) = "Hello Universe", "Single match"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("Hello World", "world", "Universe", _FALSE, changes) = "Hello Universe", "Single match (case-insensitive)"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abcabcabc", "abc", "x", _TRUE, changes) = "xxx", "Multiple matches"
    TEST_CHECK changes = 3, "Three replacements"

    TEST_CHECK Replace("aaaa", "aa", "x", _TRUE, changes) = "xx", "Overlapping match"
    TEST_CHECK changes = 2, "Two replacements"

    TEST_CHECK Replace("abc", "b", "BIGGER", _TRUE, changes) = "aBIGGERc", "Longer replacement"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abc", "bc", "x", _TRUE, changes) = "ax", "Shorter replacement"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("a\\b\\c", "\b", "X", _TRUE, changes) = "a\\b\\c", "Escape rule: skip replacement"
    TEST_CHECK changes = 0, "No replacements"

    TEST_CHECK Replace("a\b\c", "\b", "X", _TRUE, changes) = "aX\c", "Escape rule: single match"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abc", "abc", "xyz", _TRUE, changes) = "xyz", "Whole string replaced"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abcde", "abc", "X", _TRUE, changes) = "Xde", "Prefix match"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abcde", "de", "X", _TRUE, changes) = "abcX", "Suffix match"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abcde", "cd", "X", _TRUE, changes) = "abXe", "Middle match"
    TEST_CHECK changes = 1, "One replacement"

    TEST_CHECK Replace("abcABCabc", "abc", "X", _FALSE, changes) = "XXX", "Case-insensitive multiple"
    TEST_CHECK changes = 3, "Three replacements"

    TEST_CHECK Replace("abcABCabc", "abc", "X", _TRUE, changes) = "XABCX", "Case-sensitive partial"
    TEST_CHECK changes = 2, "Two replacements"

    TEST_CASE_END
END SUB

SUB Test_InFormUIHelpers
    TEST_CASE_BEGIN "InFormUIHelpers: __UI_CountLines"

    TEST_CHECK __UI_CountLines(0) = 0, "Empty string"
    Text(0) = _CHR_LF
    TEST_CHECK __UI_CountLines(0) = 1, "One line"
    Text(0) = "Line 1" + _CHR_LF + "Line 2" + _CHR_LF + "Line 3"
    TEST_CHECK __UI_CountLines(0) = 3, "Three lines"
    Text(0) = "Line 1" + _CHR_LF + "Line 2" + _CHR_LF + "Line 3" + _CHR_LF
    TEST_CHECK __UI_CountLines(0) = 3, "Three lines"
    Text(0) = _CHR_LF + "Line 1" + _CHR_LF + "Line 2" + _CHR_LF + "Line 3"
    TEST_CHECK __UI_CountLines(0) = 4, "Four lines"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: __UI_GetTextBoxLine"

    DIM startPos AS LONG

    Text(0) = _CHR_LF + "Line 1" + _CHR_LF + "Line 2" + _CHR_LF + "Line 3"

    TEST_CHECK __UI_GetTextBoxLine(0, 0, startPos) = "", "Empty string"
    TEST_CHECK startPos = 0, "Expected 0"

    TEST_CHECK __UI_GetTextBoxLine(0, 1, startPos) = Text(0), "Complete string"
    TEST_CHECK startPos = 1, "Expected 1"

    TEST_CHECK __UI_GetTextBoxLine(0, 2, startPos) = "", "Empty string"
    TEST_CHECK startPos = 0, "Expected 0"

    Control(0).Multiline = _TRUE

    TEST_CHECK __UI_GetTextBoxLine(0, 0, startPos) = "", "Empty string"
    TEST_CHECK startPos = 0, "Expected 0"

    TEST_CHECK __UI_GetTextBoxLine(0, 1, startPos) = "", "Empty line"
    TEST_CHECK startPos = 1, "Expected 1"

    TEST_CHECK __UI_GetTextBoxLine(0, 2, startPos) = "Line 1", "Line 1"
    TEST_CHECK startPos = 2, "Expected 2"

    TEST_CHECK __UI_GetTextBoxLine(0, 3, startPos) = "Line 2", "Line 2"
    TEST_CHECK startPos = 9, "Expected 9"

    TEST_CHECK __UI_GetTextBoxLine(0, 4, startPos) = "Line 3", "Line 3"
    TEST_CHECK startPos = 16, "Expected 16"

    TEST_CHECK __UI_GetTextBoxLine(0, 5, startPos) = "", "Empty string"
    TEST_CHECK startPos = 0, "Expected 0"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: __UI_TrimAt0"

    TEST_CHECK __UI_TrimAt0("hello" + _CHR_NUL + "world") = "hello", "Expected 'hello'"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: RawText$ and __UI_EmptyMask$"

    Mask(0) = ""
    Text(0) = "plaintext"
    TEST_CHECK RawText$(0) = "plaintext", "RawText$ returns full text when no mask"

    Mask(0) = "00-00"
    Text(0) = "12-34"
    TEST_CHECK RawText$(0) = "1234", "RawText$ should return placeholder characters concatenated"

    Mask(0) = "00-00"
    Text(0) = "__-5_"
    TEST_CHECK RawText$(0) = "  5 ", "RawText$ should convert underscores to spaces for empty placeholders"

    Mask(0) = "00-00"
    TEST_CHECK __UI_EmptyMask$(0) = "__-__", "__UI_EmptyMask$ should produce placeholder underscores"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: RawText$ additional cases"

    Mask(0) = "9#0#"
    Text(0) = "1a2b"
    TEST_CHECK RawText$(0) = "1a2b", "RawText$ should return characters for placeholder positions (including non-digits)"

    Mask(0) = "0000"
    Text(0) = "12"
    TEST_CHECK RawText$(0) = "12", "RawText$ should return only existing placeholder characters when Text is shorter than mask"

    Mask(0) = "(000) 000-0000"
    Text(0) = "(123) 456-7890"
    TEST_CHECK RawText$(0) = "1234567890", "RawText$ should extract digits into a contiguous string for phone mask"

    Mask(0) = "ABC"
    TEST_CHECK __UI_EmptyMask$(0) = "ABC", "__UI_EmptyMask$ should return literal mask when no placeholders"

    Mask(0) = ""
    TEST_CHECK __UI_EmptyMask$(0) = "", "__UI_EmptyMask$ should return empty string when mask is empty"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: 1-char RawText$ and __UI_EmptyMask$"

    Mask(0) = "0"
    Text(0) = "5"
    TEST_CHECK RawText$(0) = "5", "RawText$ should return single placeholder digit"

    Mask(0) = "0"
    Text(0) = "_"
    TEST_CHECK RawText$(0) = " ", "RawText$ should convert single underscore to space"

    Mask(0) = "0"
    TEST_CHECK __UI_EmptyMask$(0) = "_", "__UI_EmptyMask$ should return single underscore for single placeholder"

    Mask(0) = ""
    TEST_CHECK __UI_EmptyMask$(0) = "", "__UI_EmptyMask$ should return empty string for empty mask"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIHelpers: RestoreCHR$"

    TEST_CHECK RestoreCHR$("Hello\65;World") = "HelloAWorld", "RestoreCHR$ should convert \65; to 'A'"

    TEST_CHECK RestoreCHR$("\65;\66;\67;") = CHR$(65) + CHR$(66) + CHR$(67), "Multiple numeric escapes converted"

    TEST_CHECK RestoreCHR$("\\65;") = "\65;", "Double backslash should collapse to single backslash and leave number unprocessed"

    DIM tmp$: tmp$ = "X\6a;Y"
    TEST_CHECK RestoreCHR$(tmp$) = tmp$, "Malformed numeric escape should be left untouched"
    TEST_CHECK tmp$ = "X\6a;Y", "Malformed numeric escape should be left untouched"

    TEST_CHECK ASC(RestoreCHR$("\0;"), 1) = 0, "RestoreCHR$ should produce CHR$(0) for \0;"
    TEST_CHECK ASC(RestoreCHR$("\65;"), 1) = 65, "RestoreCHR$ should produce CHR$(65) for \65;"

    TEST_CASE_END
END SUB

SUB Test_InFormUIUnicodeUtils
    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP437"

    TEST_CHECK FromCP437("Hello, World!") = "Hello, World!", "Expected 'Hello, World!'"

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP1252"

    TEST_CHECK FromCP1252("Hello, world!") = "Hello, world!", "Expected 'Hello, world!'"

    TEST_CASE_END

    DIM textLen AS LONG: textLen = 64
    DIM iterations AS LONG: iterations = 65536

    DIM i AS LONG, text AS STRING, result AS STRING

    text = SPACE$(textLen)

    FOR i = 1 TO textLen
        ASC(text, i) = RND * 256
    NEXT i

    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP437 performance," + STR$(textLen) + " characters" + STR$(iterations) + " iterations"

    FOR i = 1 TO iterations
        result = FromCP437(text)
    NEXT i

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP1252 performance," + STR$(textLen) + " characters" + STR$(iterations) + " iterations"

    FOR i = 1 TO iterations
        result = FromCP1252(text)
    NEXT i

    TEST_CASE_END

    textLen = 65536
    iterations = 64

    text = SPACE$(textLen)

    FOR i = 1 TO textLen
        ASC(text, i) = RND * 256
    NEXT i

    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP437 performance," + STR$(textLen) + " characters" + STR$(iterations) + " iterations"

    FOR i = 1 TO iterations
        result = FromCP437(text)
    NEXT i

    TEST_CASE_END

    TEST_CASE_BEGIN "InFormUIUnicodeUtils: FromCP1252 performance," + STR$(textLen) + " characters" + STR$(iterations) + " iterations"

    FOR i = 1 TO iterations
        result = FromCP1252(text)
    NEXT i

    TEST_CASE_END
END SUB

SUB __UI_LoadForm: END SUB
SUB __UI_AssignIDs: END SUB
SUB __UI_OnLoad: END SUB
SUB __UI_BeforeUnload: END SUB
SUB __UI_BeforeUpdateDisplay: END SUB
SUB __UI_FormResized: END SUB
SUB __UI_ValueChanged (id AS LONG): id = id: END SUB
SUB __UI_TextChanged (id AS LONG): id = id: END SUB
SUB __UI_MouseEnter (id AS LONG): id = id: END SUB
SUB __UI_MouseLeave (id AS LONG): id = id: END SUB
SUB __UI_FocusIn (id AS LONG): id = id: END SUB
SUB __UI_FocusOut (id AS LONG): id = id: END SUB
SUB __UI_KeyPress (id AS LONG): id = id: END SUB
SUB __UI_MouseDown (id AS LONG): id = id: END SUB
SUB __UI_MouseUp (id AS LONG): id = id: END SUB
SUB __UI_Click (id AS LONG): id = id: END SUB

'$INCLUDE:'../InForm/InForm.ui'
'$INCLUDE:'../InForm/extensions/StringFile.bas'
'$INCLUDE:'../InForm/extensions/Pathname.bas'
'$INCLUDE:'../InForm/extensions/HashTable.bas'
'$INCLUDE:'../InForm/extensions/Algo.bas'
'$INCLUDE:'../InForm/extensions/Catch.bas'
