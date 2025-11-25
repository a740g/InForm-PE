# HMap Library

The `HMap` library provides a generic hash map for QB64-PE. It allows you to store and retrieve values of different data types using string keys. The hash map automatically resizes itself as needed.

## Usage

To use the `HMap` library, include `HMap.bi` and `HMap.bas` in your project.

```vb
'$INCLUDE:'HMap.bi'

' Declare a dynamic array of HMap
REDIM myMap(0) AS HMap

' Initialize the map
HMap_Initialize myMap()

' Set and get values
HMap_SetString myMap(), "name", "John Doe"
HMap_SetInteger myMap(), "age", 30

PRINT HMap_GetString(myMap(), "name")
PRINT HMap_GetInteger(myMap(), "age")

' Free the map
HMap_Free myMap()

'$INCLUDE:'HMap.bas'
```

## API Reference

### Initialization and Management

```vb
SUB HMap_Initialize (map() AS HMap)
```

Initializes a new hash map.

```vb
SUB HMap_Clear (map() AS HMap)
```

Removes all entries from the hash map, but keeps the allocated memory.

```vb
SUB HMap_Free (map() AS HMap)
```

Frees all memory associated with the map.

```vb
FUNCTION HMap_IsInitialized%% (map() AS HMap)
```

Returns `_TRUE` if the map has been initialized.

***

### Capacity and Size

```vb
FUNCTION HMap_GetCapacity~%& (map() AS HMap)
```

Returns the current capacity of the map.

```vb
FUNCTION HMap_GetCount~%& (map() AS HMap)
```

Returns the number of entries in the map.

***

### Entry Management

```vb
FUNCTION HMap_Delete%% (map() AS HMap, k AS STRING)
```

Deletes a key-value pair from the map. Returns `_TRUE` if the key was found and deleted.

```vb
SUB HMap_Delete (map() AS HMap, k AS STRING)
```

Deletes a key-value pair from the map (SUB version, no return value).

```vb
FUNCTION HMap_Exists%% (map() AS HMap, k AS STRING)
```

Checks if a key exists in the map. Returns `_TRUE` if found.

```vb
FUNCTION HMap_GetDataType~%% (map() AS HMap, k AS STRING)
```

Returns the data type of the value associated with a key. See QBDS constants in `QBDS.bi`.

***

### Data Access

```vb
SUB HMap_SetString (map() AS HMap, k AS STRING, v AS STRING)
```

Sets a string value for a key.

```vb
FUNCTION HMap_GetString$ (map() AS HMap, k AS STRING)
```

Gets the string value for a key.

```vb
SUB HMap_SetByte (map() AS HMap, k AS STRING, v AS _BYTE)
```

Sets a `_BYTE` value for a key.

```vb
FUNCTION HMap_GetByte%% (map() AS HMap, k AS STRING)
```

Gets the `_BYTE` value for a key.

```vb
SUB HMap_SetInteger (map() AS HMap, k AS STRING, v AS INTEGER)
```

Sets an `INTEGER` value for a key.

```vb
FUNCTION HMap_GetInteger% (map() AS HMap, k AS STRING)
```

Gets the `INTEGER` value for a key.

```vb
SUB HMap_SetLong (map() AS HMap, k AS STRING, v AS LONG)
```

Sets a `LONG` value for a key.

```vb
FUNCTION HMap_GetLong& (map() AS HMap, k AS STRING)
```

Gets the `LONG` value for a key.

```vb
SUB HMap_SetInteger64 (map() AS HMap, k AS STRING, v AS _INTEGER64)
```

Sets an `_INTEGER64` value for a key.

```vb
FUNCTION HMap_GetInteger64&& (map() AS HMap, k AS STRING)
```

Gets the `_INTEGER64` value for a key.

```vb
SUB HMap_SetSingle (map() AS HMap, k AS STRING, v AS SINGLE)
```

Sets a `SINGLE` value for a key.

```vb
FUNCTION HMap_GetSingle! (map() AS HMap, k AS STRING)
```

Gets the `SINGLE` value for a key.

```vb
SUB HMap_SetDouble (map() AS HMap, k AS STRING, v AS DOUBLE)
```

Sets a `DOUBLE` value for a key.

```vb
FUNCTION HMap_GetDouble# (map() AS HMap, k AS STRING)
```

Gets the `DOUBLE` value for a key.
