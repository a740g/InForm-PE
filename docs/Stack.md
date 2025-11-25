# Stack Library

The `Stack` library provides a generic stack implementation for QB64-PE. It supports storing various data types and automatically resizes itself as needed.

## Usage

To use the `Stack` library, you need to include `Stack.bi` and `Stack.bas` in your project.

```vb
'$INCLUDE:'Stack.bi'

' Declare a dynamic array of Stack
REDIM myStack(0) AS Stack

' Initialize the stack
Stack_Initialize myStack()

' Push and pop values
Stack_PushString myStack(), "Hello"
Stack_PushString myStack(), "World"
Stack_PushInteger myStack(), 64

PRINT Stack_PopInteger(myStack()) ' Prints 64
PRINT Stack_PopString(myStack()) ' Prints "World"
PRINT Stack_PopString(myStack()) ' Prints "Hello"

' Free the stack
Stack_Free myStack()

'$INCLUDE:'Stack.bas'
```

## API Reference

### Initialization and Management

```vb
SUB Stack_Initialize (stack() AS Stack)
```

Initializes a new stack.

```vb
SUB Stack_Clear (stack() AS Stack)
```

Clears all entries from the stack, but keeps its allocated capacity.

```vb
SUB Stack_Free (stack() AS Stack)
```

Frees all memory associated with the stack.

```vb
FUNCTION Stack_IsInitialized%% (stack() AS Stack)
```

Returns `_TRUE` if the stack has been initialized, `_FALSE` otherwise.

***

### Capacity and Size

```vb
FUNCTION Stack_GetCapacity~%& (stack() AS Stack)
```

Returns the current maximum number of entries the stack can hold before resizing.

```vb
FUNCTION Stack_GetCount~%& (stack() AS Stack)
```

Returns the number of entries currently in the stack.

***

### Data Access

```vb
FUNCTION Stack_PeekDataType~%% (stack() AS Stack)
```

Returns the data type of the value at the top of the stack.

```vb
FUNCTION Stack_PeekString$ (stack() AS Stack)
```

Retrieves the string value from the top of the stack without removing it.

```vb
SUB Stack_PushString (stack() AS Stack, v AS STRING)
```

Pushes a string value onto the top of the stack.

```vb
FUNCTION Stack_PopString$ (stack() AS Stack)
```

Retrieves and removes the string value from the top of the stack.

```vb
FUNCTION Stack_PeekByte%% (stack() AS Stack)
```

Retrieves the `_BYTE` value from the top of the stack without removing it.

```vb
SUB Stack_PushByte (stack() AS Stack, v AS _BYTE)
```

Pushes a `_BYTE` value onto the top of the stack.

```vb
FUNCTION Stack_PopByte%% (stack() AS Stack)
```

Retrieves and removes the `_BYTE` value from the top of the stack.

```vb
FUNCTION Stack_PeekInteger% (stack() AS Stack)
```

Retrieves the `INTEGER` value from the top of the stack without removing it.

```vb
SUB Stack_PushInteger (stack() AS Stack, v AS INTEGER)
```

Pushes an `INTEGER` value onto the top of the stack.

```vb
FUNCTION Stack_PopInteger% (stack() AS Stack)
```

Retrieves and removes the `INTEGER` value from the top of the stack.

```vb
FUNCTION Stack_PeekLong& (stack() AS Stack)
```

Retrieves the `LONG` value from the top of the stack without removing it.

```vb
SUB Stack_PushLong (stack() AS Stack, v AS LONG)
```

Pushes a `LONG` value onto the top of the stack.

```vb
FUNCTION Stack_PopLong& (stack() AS Stack)
```

Retrieves and removes the `LONG` value from the top of the stack.

```vb
FUNCTION Stack_PeekInteger64&& (stack() AS Stack)
```

Retrieves the `_INTEGER64` value from the top of the stack without removing it.

```vb
SUB Stack_PushInteger64 (stack() AS Stack, v AS _INTEGER64)
```

Pushes an `_INTEGER64` value onto the top of the stack.

```vb
FUNCTION Stack_PopInteger64&& (stack() AS Stack)
```

Retrieves and removes the `_INTEGER64` value from the top of the stack.

```vb
FUNCTION Stack_PeekSingle! (stack() AS Stack)
```

Retrieves the `SINGLE` value from the top of the stack without removing it.

```vb
SUB Stack_PushSingle (stack() AS Stack, v AS SINGLE)
```

Pushes a `SINGLE` value onto the top of the stack.

```vb
FUNCTION Stack_PopSingle! (stack() AS Stack)
```

Retrieves and removes the `SINGLE` value from the top of the stack.

```vb
FUNCTION Stack_PeekDouble# (stack() AS Stack)
```

Retrieves the `DOUBLE` value from the top of the stack without removing it.

```vb
SUB Stack_PushDouble (stack() AS Stack, v AS DOUBLE)
```

Pushes a `DOUBLE` value onto the top of the stack.

```vb
FUNCTION Stack_PopDouble# (stack() AS Stack)
```

Retrieves and removes the `DOUBLE` value from the top of the stack.
