'-----------------------------------------------------------------------------------------------------------------------
' General algorithm library
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

'-----------------------------------------------------------------------------------------------------------------------
' Test code for debugging the library
'-----------------------------------------------------------------------------------------------------------------------
'_DEFINE A-Z AS LONG
'OPTION _EXPLICIT

'DIM strArr(0 TO 4) AS STRING
'strArr(0) = "banana"
'strArr(1) = "apple"
'strArr(2) = "orange"
'strArr(3) = "pear"
'strArr(4) = "kiwi"

'Algo_SortStringArray strArr()

'DIM i AS LONG
'FOR i = LBOUND(strArr) TO UBOUND(strArr)
'    PRINT strArr(i)
'NEXT

'END
'-----------------------------------------------------------------------------------------------------------------------

''' @brief Sorts a string array.
''' @param strArr The array of strings to sort.
''' @param l The lower index of the array.
''' @param u The upper index of the array.
''' @return Whether the array was changed or not.
FUNCTION Algo_SortStringArrayRange%% (strArr() AS STRING, l AS _UNSIGNED LONG, u AS _UNSIGNED LONG)
    DIM i AS _UNSIGNED LONG: i = l
    DIM j AS _UNSIGNED LONG: j = u
    DIM pivot AS STRING: pivot = strArr((l + u) \ 2)
    DIM changed AS _BYTE

    WHILE i <= j
        WHILE _STRCMP(strArr(i), pivot) < 0
            i = i + 1
        WEND

        WHILE _STRCMP(strArr(j), pivot) > 0
            j = j - 1
        WEND

        IF i <= j THEN
            IF _STRCMP(strArr(i), strArr(j)) <> 0 THEN
                SWAP strArr(i), strArr(j)
                changed = _TRUE
            END IF
            i = i + 1
            j = j - 1
        END IF
    WEND

    IF l < j THEN
        IF Algo_SortStringArrayRange(strArr(), l, j) THEN changed = _TRUE
    END IF

    IF i < u THEN
        IF Algo_SortStringArrayRange(strArr(), i, u) THEN changed = _TRUE
    END IF

    Algo_SortStringArrayRange = changed
END FUNCTION

''' @brief Sorts a string array.
''' @param strArr The array of strings to sort.
''' @return Whether the array was changed or not.
FUNCTION Algo_SortStringArray%% (strArr() AS STRING)
    Algo_SortStringArray = Algo_SortStringArrayRange(strArr(), LBOUND(strArr), UBOUND(strArr))
END FUNCTION

''' @brief Sorts a string array.
''' @param strArr The array of strings to sort.
SUB Algo_SortStringArray (strArr() AS STRING)
    DIM ignored AS _BYTE: ignored = Algo_SortStringArrayRange(strArr(), LBOUND(strArr), UBOUND(strArr))
END SUB
