# HMap64 Library

The `HMap64` library provides a simple hash map implementation for QB64-PE, using `_UNSIGNED _INTEGER64` keys. It supports storing various data types and automatically resizes itself as needed.

## Usage

To use the `HMap64` library, you need to include `HMap64.bi` and `HMap64.bas` in your project.

```vb
'$INCLUDE:'HMap64.bi'

' Declare a dynamic array of HMap64
REDIM myMap(0) AS HMap64

' Initialize the map
HMap64_Initialize myMap()

' Set and get values
HMap64_SetString myMap(), 25, "Apple"
HMap64_SetInteger myMap(), 100, 10

PRINT HMap64_GetString(myMap(), 25)
PRINT HMap64_GetInteger(myMap(), 100)

' Free the map
HMap64_Free myMap()

'$INCLUDE:'HMap64.bas'
```

## API Reference

### Initialization and Management

```vb
SUB HMap64_Initialize (map() AS HMap64)
```

Initializes a new hash map.

```vb
SUB HMap64_Clear (map() AS HMap64)
```

Clears all entries from the hash map, but keeps its allocated capacity.

```vb
SUB HMap64_Free (map() AS HMap64)
```

Frees all memory associated with the hash map.

```vb
FUNCTION HMap64_IsInitialized%% (map() AS HMap64)
```

Returns `_TRUE` if the hash map has been initialized, `_FALSE` otherwise.

***

### Capacity and Size

```vb
FUNCTION HMap64_GetCapacity~%& (map() AS HMap64)
```

Returns the current maximum number of entries the hash map can hold before resizing.

```vb
FUNCTION HMap64_GetCount~%& (map() AS HMap64)
```

Returns the number of entries currently in the hash map.

***

### Entry Management

```vb
FUNCTION HMap64_Delete%% (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Deletes an entry by its key. Returns `_TRUE` if the key was found and deleted, `_FALSE` otherwise.

```vb
SUB HMap64_Delete (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Deletes an entry by its key (SUB version, no return value).

```vb
FUNCTION HMap64_Exists%% (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Checks if a key exists in the hash map. Returns `_TRUE` if the key exists, `_FALSE` otherwise.

```vb
FUNCTION HMap64_GetDataType~%% (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Returns the data type of the value associated with a key.

***

### Data Access

```vb
FUNCTION HMap64_GetString$ (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the string value for a given key.

```vb
SUB HMap64_SetString (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS STRING)
```

Sets the string value for a given key.

```vb
FUNCTION HMap64_GetByte%% (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `_BYTE` value for a given key.

```vb
SUB HMap64_SetByte (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS _BYTE)
```

Sets the `_BYTE` value for a given key.

```vb
FUNCTION HMap64_GetInteger% (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `INTEGER` value for a given key.

```vb
SUB HMap64_SetInteger (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS INTEGER)
```

Sets the `INTEGER` value for a given key.

```vb
FUNCTION HMap64_GetLong& (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `LONG` value for a given key.

```vb
SUB HMap64_SetLong (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS LONG)
```

Sets the `LONG` value for a given key.

```vb
FUNCTION HMap64_GetInteger64&& (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `_INTEGER64` value for a given key.

```vb
SUB HMap64_SetInteger64 (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS _INTEGER64)
```

Sets the `_INTEGER64` value for a given key.

```vb
FUNCTION HMap64_GetSingle! (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `SINGLE` value for a given key.

```vb
SUB HMap64_SetSingle (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS SINGLE)
```

Sets the `SINGLE` value for a given key.

```vb
FUNCTION HMap64_GetDouble# (map() AS HMap64, k AS _UNSIGNED _INTEGER64)
```

Retrieves the `DOUBLE` value for a given key.

```vb
SUB HMap64_SetDouble (map() AS HMap64, k AS _UNSIGNED _INTEGER64, v AS DOUBLE)
```

Sets the `DOUBLE` value for a given key.
