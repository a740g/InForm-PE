# LList Library

The `LList` library provides a generic doubly-linked list implementation for QB64-PE. It supports storing various data types and automatically resizes itself as needed.

## Usage

To use the `LList` library, you need to include `LList.bi` and `LList.bas` in your project.

```vb
'$INCLUDE:'LList.bi'

' Declare a dynamic array of LList
REDIM myList(0) AS LList

' Initialize the list
LList_Initialize myList()

' Add elements
LList_PushBackString myList(), "Hello"
LList_PushFrontString myList(), "World"

' Iterate through the list
DIM node AS _UNSIGNED _OFFSET: node = LList_GetFrontNode(myList())
WHILE node
    PRINT LList_GetString(myList(), node)

    node = LList_GetNextNode(myList(), node) ' Move to the next node
WEND

' Free the list
LList_Free myList()

'$INCLUDE:'LList.bas'
```

## API Reference

### Initialization and Management

```vb
SUB LList_Initialize (lst() AS LList)
```

Initializes a new list.

```vb
SUB LList_Clear (lst() AS LList)
```

Clears all entries from the list, but keeps its allocated capacity.

```vb
SUB LList_Free (lst() AS LList)
```

Frees all memory associated with the list.

```vb
FUNCTION LList_IsInitialized%% (lst() AS LList)
```

Returns `_TRUE` if the list has been initialized, `_FALSE` otherwise.

***

### Capacity and Size

```vb
FUNCTION LList_GetCapacity~%& (lst() AS LList)
```

Returns the current maximum number of entries the list can hold before resizing.

```vb
FUNCTION LList_GetCount~%& (lst() AS LList)
```

Returns the number of entries currently in the list.

***

### Node Management

```vb
FUNCTION LList_GetFrontNode~%& (lst() AS LList)
```

Returns the index of the first node in the list.

```vb
FUNCTION LList_GetBackNode~%& (lst() AS LList)
```

Returns the index of the last node in the list.

```vb
FUNCTION LList_GetNextNode~%& (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Returns the index of the node after the given node.

```vb
FUNCTION LList_GetPreviousNode~%& (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Returns the index of the node before the given node.

```vb
FUNCTION LList_Delete%% (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Deletes a node from the list. Returns `_TRUE` if the node was deleted, `_FALSE` otherwise.

```vb
SUB LList_Delete (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Deletes a node from the list (SUB version, no return value).

```vb
FUNCTION LList_Exists%% (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Checks if a node exists in the list. Returns `_TRUE` if the node exists, `_FALSE` otherwise.

```vb
FUNCTION LList_GetDataType~%% (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Returns the data type of the value associated with a node.

```vb
SUB LList_Swap (lst() AS LList, nodeA AS _UNSIGNED _OFFSET, nodeB AS _UNSIGNED _OFFSET)
```

Swaps the values of two nodes in the list.

### Circular List

```vb
FUNCTION LList_IsCircular%% (lst() AS LList)
```

Returns `_TRUE` if the list is circular, `_FALSE` otherwise.

```vb
SUB LList_MakeCircular (lst() AS LList, isCircular AS _BYTE)
```

Sets whether the list is circular.

### Data Access

```vb
SUB LList_InsertBeforeString (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS STRING)
```

Inserts a string value before the given node.

```vb
SUB LList_InsertAfterString (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS STRING)
```

Inserts a string value after the given node.

```vb
SUB LList_PushFrontString (lst() AS LList, v AS STRING)
```

Adds a string value to the beginning of the list.

```vb
SUB LList_PushBackString (lst() AS LList, v AS STRING)
```

Adds a string value to the end of the list.

```vb
FUNCTION LList_GetString$ (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the string value for a given node.

```vb
SUB LList_SetString (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS STRING)
```

Sets the string value for a given node.

```vb
FUNCTION LList_PopFrontString$ (lst() AS LList)
```

Retrieves and removes the string value from the front of the list.

```vb
FUNCTION LList_PopBackString$ (lst() AS LList)
```

Retrieves and removes the string value from the back of the list.

```vb
SUB LList_InsertBeforeByte (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _BYTE)
```

Inserts a `_BYTE` value before the given node.

```vb
SUB LList_InsertAfterByte (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _BYTE)
```

Inserts a `_BYTE` value after the given node.

```vb
SUB LList_PushFrontByte (lst() AS LList, v AS _BYTE)
```

Adds a `_BYTE` value to the beginning of the list.

```vb
SUB LList_PushBackByte (lst() AS LList, v AS _BYTE)
```

Adds a `_BYTE` value to the end of the list.

```vb
FUNCTION LList_GetByte%% (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `_BYTE` value for a given node.

```vb
SUB LList_SetByte (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _BYTE)
```

Sets the `_BYTE` value for a given node.

```vb
FUNCTION LList_PopFrontByte%% (lst() AS LList)
```

Retrieves and removes the `_BYTE` value from the front of the list.

```vb
FUNCTION LList_PopBackByte%% (lst() AS LList)
```

Retrieves and removes the `_BYTE` value from the back of the list.

```vb
SUB LList_InsertBeforeInteger (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS INTEGER)
```

Inserts an `INTEGER` value before the given node.

```vb
SUB LList_InsertAfterInteger (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS INTEGER)
```

Inserts an `INTEGER` value after the given node.

```vb
SUB LList_PushFrontInteger (lst() AS LList, v AS INTEGER)
```

Adds an `INTEGER` value to the beginning of the list.

```vb
SUB LList_PushBackInteger (lst() AS LList, v AS INTEGER)
```

Adds an `INTEGER` value to the end of the list.

```vb
FUNCTION LList_GetInteger% (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `INTEGER` value for a given node.

```vb
SUB LList_SetInteger (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS INTEGER)
```

Sets the `INTEGER` value for a given node.

```vb
FUNCTION LList_PopFrontInteger% (lst() AS LList)
```

Retrieves and removes the `INTEGER` value from the front of the list.

```vb
FUNCTION LList_PopBackInteger% (lst() AS LList)
```

Retrieves and removes the `INTEGER` value from the back of the list.

```vb
SUB LList_InsertBeforeLong (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS LONG)
```

Inserts a `LONG` value before the given node.

```vb
SUB LList_InsertAfterLong (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS LONG)
```

Inserts a `LONG` value after the given node.

```vb
SUB LList_PushFrontLong (lst() AS LList, v AS LONG)
```

Adds a `LONG` value to the beginning of the list.

```vb
SUB LList_PushBackLong (lst() AS LList, v AS LONG)
```

Adds a `LONG` value to the end of the list.

```vb
FUNCTION LList_GetLong& (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `LONG` value for a given node.

```vb
SUB LList_SetLong (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS LONG)
```

Sets the `LONG` value for a given node.

```vb
FUNCTION LList_PopFrontLong& (lst() AS LList)
```

Retrieves and removes the `LONG` value from the front of the list.

```vb
FUNCTION LList_PopBackLong& (lst() AS LList)
```

Retrieves and removes the `LONG` value from the back of the list.

```vb
SUB LList_InsertBeforeInteger64 (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _INTEGER64)
```

Inserts an `_INTEGER64` value before the given node.

```vb
SUB LList_InsertAfterInteger64 (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _INTEGER64)
```

Inserts an `_INTEGER64` value after the given node.

```vb
SUB LList_PushFrontInteger64 (lst() AS LList, v AS _INTEGER64)
```

Adds an `_INTEGER64` value to the beginning of the list.

```vb
SUB LList_PushBackInteger64 (lst() AS LList, v AS _INTEGER64)
```

Adds an `_INTEGER64` value to the end of the list.

```vb
FUNCTION LList_GetInteger64&& (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `_INTEGER64` value for a given node.

```vb
SUB LList_SetInteger64 (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS _INTEGER64)
```

Sets the `_INTEGER64` value for a given node.

```vb
FUNCTION LList_PopFrontInteger64&& (lst() AS LList)
```

Retrieves and removes the `_INTEGER64` value from the front of the list.

```vb
FUNCTION LList_PopBackInteger64&& (lst() AS LList)
```

Retrieves and removes the `_INTEGER64` value from the back of the list.

```vb
SUB LList_InsertBeforeSingle (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS SINGLE)
```

Inserts a `SINGLE` value before the given node.

```vb
SUB LList_InsertAfterSingle (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS SINGLE)
```

Inserts a `SINGLE` value after the given node.

```vb
SUB LList_PushFrontSingle (lst() AS LList, v AS SINGLE)
```

Adds a `SINGLE` value to the beginning of the list.

```vb
SUB LList_PushBackSingle (lst() AS LList, v AS SINGLE)
```

Adds a `SINGLE` value to the end of the list.

```vb
FUNCTION LList_GetSingle! (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `SINGLE` value for a given node.

```vb
SUB LList_SetSingle (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS SINGLE)
```

Sets the `SINGLE` value for a given node.

```vb
FUNCTION LList_PopFrontSingle! (lst() AS LList)
```

Retrieves and removes the `SINGLE` value from the front of the list.

```vb
FUNCTION LList_PopBackSingle! (lst() AS LList)
```

Retrieves and removes the `SINGLE` value from the back of the list.

```vb
SUB LList_InsertBeforeDouble (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS DOUBLE)
```

Inserts a `DOUBLE` value before the given node.

```vb
SUB LList_InsertAfterDouble (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS DOUBLE)
```

Inserts a `DOUBLE` value after the given node.

```vb
SUB LList_PushFrontDouble (lst() AS LList, v AS DOUBLE)
```

Adds a `DOUBLE` value to the beginning of the list.

```vb
SUB LList_PushBackDouble (lst() AS LList, v AS DOUBLE)
```

Adds a `DOUBLE` value to the end of the list.

```vb
FUNCTION LList_GetDouble# (lst() AS LList, node AS _UNSIGNED _OFFSET)
```

Retrieves the `DOUBLE` value for a given node.

```vb
SUB LList_SetDouble (lst() AS LList, node AS _UNSIGNED _OFFSET, v AS DOUBLE)
```

Sets the `DOUBLE` value for a given node.

```vb
FUNCTION LList_PopFrontDouble# (lst() AS LList)
```

Retrieves and removes the `DOUBLE` value from the front of the list.

```vb
FUNCTION LList_PopBackDouble# (lst() AS LList)
```

Retrieves and removes the `DOUBLE` value from the back of the list.
