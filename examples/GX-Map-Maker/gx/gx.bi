' GX - A BASIC Game Engine for QB64
' 2021 boxgaming - https://github.com/boxgaming/gx
'
$IF GXBI = UNDEFINED THEN
    'OPTION _EXPLICIT

    ' GX System Constants
    ' ------------------------------------------------------------------------
    CONST GX_FALSE = 0
    CONST GX_TRUE = NOT GX_FALSE

    CONST GXEVENT_INIT = 1
    CONST GXEVENT_UPDATE = 2
    CONST GXEVENT_DRAWBG = 3
    CONST GXEVENT_DRAWMAP = 4
    CONST GXEVENT_DRAWSCREEN = 5
    CONST GXEVENT_MOUSEINPUT = 6
    CONST GXEVENT_PAINTBEFORE = 7
    CONST GXEVENT_PAINTAFTER = 8
    CONST GXEVENT_COLLISION_TILE = 9
    CONST GXEVENT_COLLISION_ENTITY = 10
    CONST GXEVENT_PLAYER_ACTION = 11
    CONST GXEVENT_ANIMATE_COMPLETE = 12

    CONST GXANIMATE_LOOP = 0
    CONST GXANIMATE_SINGLE = 1

    CONST GXBG_STRETCH = 1
    CONST GXBG_SCROLL = 2
    CONST GXBG_WRAP = 3

    CONST GXKEY_ESC = 2
    CONST GXKEY_1 = 3
    CONST GXKEY_2 = 4
    CONST GXKEY_3 = 5
    CONST GXKEY_4 = 6
    CONST GXKEY_5 = 7
    CONST GXKEY_6 = 8
    CONST GXKEY_7 = 9
    CONST GXKEY_8 = 10
    CONST GXKEY_9 = 11
    CONST GXKEY_0 = 12
    CONST GXKEY_DASH = 13
    CONST GXKEY_EQUALS = 14
    CONST GXKEY_BACKSPACE = 15
    CONST GXKEY_TAB = 16
    CONST GXKEY_Q = 17
    CONST GXKEY_W = 18
    CONST GXKEY_E = 19
    CONST GXKEY_R = 20
    CONST GXKEY_T = 21
    CONST GXKEY_Y = 22
    CONST GXKEY_U = 23
    CONST GXKEY_I = 24
    CONST GXKEY_O = 25
    CONST GXKEY_P = 26
    CONST GXKEY_LBRACKET = 27
    CONST GXKEY_RBRACKET = 28
    CONST GXKEY_ENTER = 29
    CONST GXKEY_LCTRL = 30
    CONST GXKEY_A = 31
    CONST GXKEY_S = 32
    CONST GXKEY_D = 33
    CONST GXKEY_F = 34
    CONST GXKEY_G = 35
    CONST GXKEY_H = 36
    CONST GXKEY_J = 37
    CONST GXKEY_K = 38
    CONST GXKEY_L = 39
    CONST GXKEY_SEMICOLON = 40
    CONST GXKEY_QUOTE = 41
    CONST GXKEY_BACKQUOTE = 42
    CONST GXKEY_LSHIFT = 43
    CONST GXKEY_BACKSLASH = 44
    CONST GXKEY_Z = 45
    CONST GXKEY_X = 46
    CONST GXKEY_C = 47
    CONST GXKEY_V = 48
    CONST GXKEY_B = 49
    CONST GXKEY_N = 50
    CONST GXKEY_M = 51
    CONST GXKEY_COMMA = 52
    CONST GXKEY_PERIOD = 53
    CONST GXKEY_SLASH = 54
    CONST GXKEY_RSHIFT = 55
    CONST GXKEY_NUMPAD_MULTIPLY = 56
    CONST GXKEY_SPACEBAR = 58
    CONST GXKEY_CAPSLOCK = 59
    CONST GXKEY_F1 = 60
    CONST GXKEY_F2 = 61
    CONST GXKEY_F3 = 62
    CONST GXKEY_F4 = 63
    CONST GXKEY_F5 = 64
    CONST GXKEY_F6 = 65
    CONST GXKEY_F7 = 66
    CONST GXKEY_F8 = 67
    CONST GXKEY_F9 = 68
    CONST GXKEY_PAUSE = 70
    CONST GXKEY_SCRLK = 71
    CONST GXKEY_NUMPAD_7 = 72
    CONST GXKEY_NUMPAD_8 = 73
    CONST GXKEY_NUMPAD_9 = 74
    CONST GXKEY_NUMPAD_MINUS = 75
    CONST GXKEY_NUMPAD_4 = 76
    CONST GXKEY_NUMPAD_5 = 77
    CONST GXKEY_NUMPAD_6 = 78
    CONST GXKEY_NUMPAD_PLUS = 79
    CONST GXKEY_NUMPAD_1 = 80
    CONST GXKEY_NUMPAD_2 = 81
    CONST GXKEY_NUMPAD_3 = 82
    CONST GXKEY_NUMPAD_0 = 83
    CONST GXKEY_NUMPAD_PERIOD = 84
    CONST GXKEY_F11 = 88
    CONST GXKEY_F12 = 89
    CONST GXKEY_NUMPAD_ENTER = 285
    CONST GXKEY_RCTRL = 286
    CONST GXKEY_NUMPAD_DIVIDE = 310
    CONST GXKEY_NUMLOCK = 326
    CONST GXKEY_HOME = 328
    CONST GXKEY_UP = 329
    CONST GXKEY_PAGEUP = 330
    CONST GXKEY_LEFT = 332
    CONST GXKEY_RIGHT = 334
    CONST GXKEY_END = 336
    CONST GXKEY_DOWN = 337
    CONST GXKEY_PAGEDOWN = 338
    CONST GXKEY_INSERT = 339
    CONST GXKEY_DELETE = 340
    CONST GXKEY_LWIN = 348
    CONST GXKEY_RWIN = 349
    CONST GXKEY_MENU = 350




    CONST GXACTION_MOVE_LEFT = 1
    CONST GXACTION_MOVE_RIGHT = 2
    CONST GXACTION_MOVE_UP = 3
    CONST GXACTION_MOVE_DOWN = 4
    CONST GXACTION_JUMP = 5
    CONST GXACTION_JUMP_RIGHT = 6
    CONST GXACTION_JUMP_LEFT = 7

    CONST GXSCENE_FOLLOW_NONE = 0 '                no automatic scene positioning (default)
    CONST GXSCENE_FOLLOW_ENTITY_CENTER = 1 '       center the view on a specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X = 2 '     center the x axis of the scene on the specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_Y = 3 '     center the y axis of the scene on the specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X_POS = 4 ' center the x axis of the scene only when moving to the right
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X_NEG = 5 ' center the x axis of the scene only when moving to the left

    CONST GXSCENE_CONSTRAIN_NONE = 0 '   no checking on scene position: can be negative, can exceed map size (default)
    CONST GXSCENE_CONSTRAIN_TO_MAP = 1 ' do not allow screen position outside the bounds of the map size

    CONST GXFONT_DEFAULT = 1 '       default bitmap font (white)
    CONST GXFONT_DEFAULT_BLACK = 2 ' default bitmap font (black)

    CONST GXDEVICE_KEYBOARD = 1
    CONST GXDEVICE_MOUSE = 2
    CONST GXDEVICE_CONTROLLER = 3
    CONST GXDEVICE_BUTTON = 4
    CONST GXDEVICE_AXIS = 5
    CONST GXDEVICE_WHEEL = 6

    CONST GXTYPE_ENTITY = 1
    CONST GXTYPE_FONT = 2

    ' GX System Types
    ' ------------------------------------------------------------------------
    TYPE GXPosition
        x AS LONG '              x position - unit may vary based on context
        y AS LONG '              y position - unit may vary based on context
    END TYPE

    TYPE GXImage
        id AS LONG '             the image handle
        filename AS STRING '     the name of the file from which the image was loaded
    END TYPE

    TYPE GXFont
        eid AS INTEGER '         id of the entity defining the font sprite
        charSpacing AS INTEGER ' defines amount of (in pixels) between characters
        lineSpacing AS INTEGER ' defines amount of space (in pixels) between lines
    END TYPE

    TYPE GXDeviceInput
        deviceId AS INTEGER '    id of the input device
        deviceType AS INTEGER '  type of input device (keyboard, mouse, or game controller)
        inputType AS INTEGER '   type of input (button, axis, or wheel)
        inputId AS INTEGER '     id of the input
        inputValue AS INTEGER '  the value of the input - varies based on input type: (-1 or 0 for buttons, -1, 0 or 1 for wheel)
    END TYPE '                       - button: 0 or -1
    '                                - wheel:  -1, 0, or 1
    '                                - axis:   decimal value between -1 and 1
    TYPE GXScene
        x AS INTEGER '           x position in pixels
        y AS INTEGER '           y position in pixels
        width AS INTEGER '       scene width in pixels
        height AS INTEGER '      scene height in pixels
        columns AS INTEGER '     number of tiled map columns viewable in the scene (0 if no map loaded)
        rows AS INTEGER '        number of tiled map rows viewable in the scene (0 if no map loaded)
        image AS LONG
        active AS INTEGER
        embedded AS INTEGER
        followMode AS INTEGER
        followEntity AS INTEGER
        constrainMode AS INTEGER
        frame AS _UNSIGNED LONG
        fullscreen AS INTEGER
        scaleX AS SINGLE
        scaleY AS SINGLE
    END TYPE

    TYPE GXEvent
        event AS INTEGER
        action AS INTEGER
        player AS INTEGER
        entity AS INTEGER
        collisionEntity AS INTEGER
        collisionTileX AS INTEGER
        collisionTileY AS INTEGER
        collisionResult AS INTEGER
    END TYPE

    TYPE GXObject
        uid AS STRING * 10 ' the object's unique identifier
        id AS INTEGER '      the object's index in the type-specific array
        type AS INTEGER '    the object type
    END TYPE

    TYPE GXEntity
        x AS DOUBLE '             the entity's x position in the world (or scene if screen==true)
        y AS DOUBLE '             the entity's y position in the world (or scene if screen==true)
        height AS INTEGER '       the entity's sprite height
        width AS INTEGER '        the entity's sprite width
        image AS LONG '           the entity's spritesheet image handle
        spriteSeq AS INTEGER '    the entity's current sprite sequence
        spriteFrame AS INTEGER '  the entity's current sprite animation frame
        prevFrame AS INTEGER '    the entity's previous frame
        seqFrames AS INTEGER '    the number of frames in the current sequence
        animate AS INTEGER '      the animation speed in FPS, 0 = no animation
        animateMode AS INTEGER '  animation mode (loop vs single play)
        screen AS INTEGER '       if true entity is rendered with screen coordinates on topmost layer
        hidden AS INTEGER '       if true, disables rendering (TODO: and collision detection?)
        type AS INTEGER '         user-defined type id
        coLeft AS INTEGER '       left collision offset
        coTop AS INTEGER '        top collision offset
        coRight AS INTEGER '      right collision offset
        coBottom AS INTEGER '     bottom collision offset
        applyGravity AS INTEGER ' used for applying gravity
        ' TODO: some clarification may be needed here as the following
        '       two variables are used both falling and jumping
        jumping AS INTEGER '      used for applying gravity
        jumpstart AS INTEGER '    used for applying gravity
        vx AS DOUBLE '            move vector x
        vy AS DOUBLE '            move vector y
        mapLayer AS INTEGER '     optional map layer to enable rendering entities under map tiles
    END TYPE

    TYPE GXBackground
        image AS LONG
        mode AS INTEGER
        x AS INTEGER
        y AS INTEGER
        width AS INTEGER
        height AS INTEGER
        wrapFactor AS DOUBLE
    END TYPE

    TYPE GXTileset
        width AS INTEGER
        height AS INTEGER
        columns AS INTEGER
        rows AS INTEGER
        image AS LONG
        filename AS STRING
    END TYPE

    TYPE GXTile
        id AS INTEGER
        animationId AS INTEGER
        animationSpeed AS INTEGER
        animationFrame AS INTEGER
    END TYPE

    TYPE GXTileFrame
        tileId AS INTEGER
        firstFrame AS INTEGER
        nextFrame AS INTEGER
    END TYPE

    TYPE GXMap
        rows AS INTEGER
        columns AS INTEGER
        layers AS INTEGER
        isometric AS INTEGER
        version AS INTEGER
    END TYPE

    TYPE GXMapTile
        tile AS INTEGER
    END TYPE

    TYPE GXMapLayer
        id AS INTEGER
        hidden AS INTEGER
    END TYPE

    'Type GXPlayer
    '    eid As Integer
    '    jumpSpeed As Integer
    '    walkSpeed As Integer
    '    runSpeed As Integer
    'End Type

    TYPE GXAction
        type AS INTEGER
        diDeviceId AS INTEGER
        diDeviceType AS INTEGER
        diInputType AS INTEGER
        diInputId AS INTEGER
        diInputValue AS INTEGER
        animationSeq AS INTEGER
        animationFrame AS INTEGER
        animationMode AS INTEGER
        animationSpeed AS INTEGER
        disabled AS INTEGER
    END TYPE

    TYPE GXDebug
        enabled AS INTEGER
        screenEntities AS INTEGER
        tileBorderColor AS _UNSIGNED LONG
        entityBorderColor AS _UNSIGNED LONG
        entityCollisionColor AS _UNSIGNED LONG
        font AS INTEGER
    END TYPE


    ' System Private Globals
    ' ------------------------------------------------------------------------
    DIM SHARED __gx_framerate AS INTEGER
    __gx_framerate = 60

    DIM SHARED __gx_tileset AS GXTileset
    REDIM SHARED __gx_tileset_tiles(0) AS GXTile
    REDIM SHARED __gx_tileset_animations(0) AS GXTileFrame

    DIM SHARED __gx_map AS GXMap
    REDIM SHARED __gx_map_layer_info(0) AS GXMapLayer
    REDIM SHARED __gx_map_layers(0, 0) AS GXMapTile
    DIM SHARED __gx_map_loading AS INTEGER

    REDIM SHARED __gx_images(0) AS GXImage
    DIM SHARED __gx_image_count AS INTEGER

    DIM SHARED __gx_scene AS GXScene
    DIM SHARED __gx_img_blank AS LONG
    DIM SHARED __gx_img_blank_s AS LONG

    REDIM SHARED __gx_bg(0) AS GXBackground
    DIM SHARED __gx_bg_count AS INTEGER

    DIM SHARED __gx_entity_count AS INTEGER
    REDIM SHARED __gx_entities(0) AS GXEntity
    REDIM SHARED __gx_entities_active(0) AS INTEGER

    REDIM SHARED __gx_fonts(2) AS GXFont
    REDIM SHARED __gx_font_charmap(256, 2) AS GXPosition
    DIM SHARED __gx_font_count AS INTEGER
    __gx_font_count = 2

    'ReDim Shared __gx_players(0) As GXPlayer
    REDIM SHARED __gx_player_keymap(0, 10) AS GXAction
    DIM SHARED __gx_player_count AS INTEGER

    REDIM SHARED __gx_objects(0) AS GXObject

    DIM SHARED __gx_sound_muted AS INTEGER

    DIM SHARED __gx_gravity AS SINGLE
    __gx_gravity = 9.8 * 8
    DIM SHARED __gx_terminal_velocity AS INTEGER
    __gx_terminal_velocity = 300

    DIM SHARED __gx_debug AS GXDebug
    __gx_debug.font = GXFONT_DEFAULT
    __gx_debug.tileBorderColor = _RGB32(255, 255, 255)
    __gx_debug.entityBorderColor = _RGB32(255, 255, 255)
    __gx_debug.entityCollisionColor = _RGB32(255, 255, 0)

    DIM SHARED __gx_draw_events(GXEVENT_DRAWBG TO GXEVENT_DRAWSCREEN) AS INTEGER

    DIM SHARED __gx_hardware_acceleration

    ' Remove this section if keyboard device input fixed for linux and macos
    $IF LINUX OR MAC THEN
        Type KeyEntry
            value As Long
            shift As Long
        End Type
        Dim Shared __gx_keymap(350) As KeyEntry
        __gx_keymap(GXKEY_ESC).value = 27
        __gx_keymap(GXKEY_1).value = 49
        __gx_keymap(GXKEY_1).shift = 33
        __gx_keymap(GXKEY_2).value = 50
        __gx_keymap(GXKEY_2).shift = 64
        __gx_keymap(GXKEY_3).value = 51
        __gx_keymap(GXKEY_3).shift = 35
        __gx_keymap(GXKEY_4).value = 52
        __gx_keymap(GXKEY_4).shift = 36
        __gx_keymap(GXKEY_5).value = 53
        __gx_keymap(GXKEY_5).shift = 37
        __gx_keymap(GXKEY_6).value = 54
        __gx_keymap(GXKEY_6).shift = 94
        __gx_keymap(GXKEY_7).value = 55
        __gx_keymap(GXKEY_7).shift = 38
        __gx_keymap(GXKEY_8).value = 56
        __gx_keymap(GXKEY_8).shift = 42
        __gx_keymap(GXKEY_9).value = 57
        __gx_keymap(GXKEY_9).shift = 40
        __gx_keymap(GXKEY_0).value = 48
        __gx_keymap(GXKEY_0).shift = 41
        __gx_keymap(GXKEY_DASH).value = 45
        __gx_keymap(GXKEY_DASH).shift = 95
        __gx_keymap(GXKEY_EQUALS).value = 61
        __gx_keymap(GXKEY_EQUALS).shift = 43
        __gx_keymap(GXKEY_BACKSPACE).value = 8
        __gx_keymap(GXKEY_TAB).value = 9
        __gx_keymap(GXKEY_Q).value = 113
        __gx_keymap(GXKEY_Q).shift = 81
        __gx_keymap(GXKEY_W).value = 119
        __gx_keymap(GXKEY_W).shift = 87
        __gx_keymap(GXKEY_E).value = 101
        __gx_keymap(GXKEY_E).shift = 69
        __gx_keymap(GXKEY_R).value = 114
        __gx_keymap(GXKEY_R).shift = 82
        __gx_keymap(GXKEY_T).value = 116
        __gx_keymap(GXKEY_T).shift = 84
        __gx_keymap(GXKEY_Y).value = 121
        __gx_keymap(GXKEY_Y).shift = 89
        __gx_keymap(GXKEY_U).value = 117
        __gx_keymap(GXKEY_U).shift = 85
        __gx_keymap(GXKEY_I).value = 105
        __gx_keymap(GXKEY_I).shift = 73
        __gx_keymap(GXKEY_O).value = 111
        __gx_keymap(GXKEY_O).shift = 79
        __gx_keymap(GXKEY_P).value = 112
        __gx_keymap(GXKEY_P).shift = 80
        __gx_keymap(GXKEY_LBRACKET).value = 91
        __gx_keymap(GXKEY_LBRACKET).shift = 123
        __gx_keymap(GXKEY_RBRACKET).value = 93
        __gx_keymap(GXKEY_RBRACKET).shift = 125
        __gx_keymap(GXKEY_ENTER).value = 13
        __gx_keymap(GXKEY_LCTRL).value = 100306
        __gx_keymap(GXKEY_A).value = 97
        __gx_keymap(GXKEY_A).shift = 65
        __gx_keymap(GXKEY_S).value = 115
        __gx_keymap(GXKEY_S).shift = 83
        __gx_keymap(GXKEY_D).value = 100
        __gx_keymap(GXKEY_D).shift = 68
        __gx_keymap(GXKEY_F).value = 102
        __gx_keymap(GXKEY_F).shift = 70
        __gx_keymap(GXKEY_G).value = 103
        __gx_keymap(GXKEY_G).shift = 71
        __gx_keymap(GXKEY_H).value = 104
        __gx_keymap(GXKEY_H).shift = 72
        __gx_keymap(GXKEY_J).value = 106
        __gx_keymap(GXKEY_J).shift = 74
        __gx_keymap(GXKEY_K).value = 107
        __gx_keymap(GXKEY_K).shift = 75
        __gx_keymap(GXKEY_L).value = 108
        __gx_keymap(GXKEY_L).shift = 76
        __gx_keymap(GXKEY_SEMICOLON).value = 59
        __gx_keymap(GXKEY_SEMICOLON).shift = 58
        __gx_keymap(GXKEY_QUOTE).value = 39
        __gx_keymap(GXKEY_QUOTE).shift = 34
        __gx_keymap(GXKEY_BACKQUOTE).value = 96
        __gx_keymap(GXKEY_BACKQUOTE).shift = 126
        __gx_keymap(GXKEY_LSHIFT).value = 100304
        __gx_keymap(GXKEY_BACKSLASH).value = 92
        __gx_keymap(GXKEY_BACKSLASH).shift = 124
        __gx_keymap(GXKEY_Z).value = 122
        __gx_keymap(GXKEY_Z).shift = 90
        __gx_keymap(GXKEY_X).value = 120
        __gx_keymap(GXKEY_X).shift = 88
        __gx_keymap(GXKEY_C).value = 99
        __gx_keymap(GXKEY_C).shift = 67
        __gx_keymap(GXKEY_V).value = 118
        __gx_keymap(GXKEY_V).shift = 86
        __gx_keymap(GXKEY_B).value = 98
        __gx_keymap(GXKEY_B).shift = 66
        __gx_keymap(GXKEY_N).value = 110
        __gx_keymap(GXKEY_N).shift = 78
        __gx_keymap(GXKEY_M).value = 109
        __gx_keymap(GXKEY_M).shift = 77
        __gx_keymap(GXKEY_COMMA).value = 44
        __gx_keymap(GXKEY_COMMA).shift = 60
        __gx_keymap(GXKEY_PERIOD).value = 46
        __gx_keymap(GXKEY_PERIOD).shift = 62
        __gx_keymap(GXKEY_SLASH).value = 47
        __gx_keymap(GXKEY_SLASH).shift = 63
        __gx_keymap(GXKEY_RSHIFT).value = 100303
        __gx_keymap(GXKEY_NUMPAD_MULTIPLY).value = 100268
        __gx_keymap(GXKEY_SPACEBAR).value = 32
        __gx_keymap(GXKEY_CAPSLOCK).value = 100301
        __gx_keymap(GXKEY_F1).value = 15104
        __gx_keymap(GXKEY_F2).value = 15360
        __gx_keymap(GXKEY_F3).value = 15616
        __gx_keymap(GXKEY_F4).value = 15872
        __gx_keymap(GXKEY_F5).value = 16128
        __gx_keymap(GXKEY_F6).value = 16384
        __gx_keymap(GXKEY_F7).value = 16640
        __gx_keymap(GXKEY_F8).value = 16896
        __gx_keymap(GXKEY_F9).value = 17152
        __gx_keymap(GXKEY_PAUSE).value = 100019
        __gx_keymap(GXKEY_SCRLK).value = 100302
        __gx_keymap(GXKEY_NUMPAD_7).value = 100263
        __gx_keymap(GXKEY_NUMPAD_7).shift = 200007
        __gx_keymap(GXKEY_NUMPAD_8).value = 100264
        __gx_keymap(GXKEY_NUMPAD_8).shift = 200008
        __gx_keymap(GXKEY_NUMPAD_9).value = 100265
        __gx_keymap(GXKEY_NUMPAD_9).value = 200009
        __gx_keymap(GXKEY_NUMPAD_MINUS).value = 100269
        __gx_keymap(GXKEY_NUMPAD_4).value = 100260
        __gx_keymap(GXKEY_NUMPAD_4).shift = 200004
        __gx_keymap(GXKEY_NUMPAD_5).value = 100261
        __gx_keymap(GXKEY_NUMPAD_6).value = 100262
        __gx_keymap(GXKEY_NUMPAD_6).shift = 200006
        __gx_keymap(GXKEY_NUMPAD_PLUS).value = 100270
        __gx_keymap(GXKEY_NUMPAD_1).value = 100257
        __gx_keymap(GXKEY_NUMPAD_1).shift = 200001
        __gx_keymap(GXKEY_NUMPAD_2).value = 100258
        __gx_keymap(GXKEY_NUMPAD_2).shift = 200002
        __gx_keymap(GXKEY_NUMPAD_3).value = 100259
        __gx_keymap(GXKEY_NUMPAD_3).shift = 200003
        __gx_keymap(GXKEY_NUMPAD_0).value = 100256
        __gx_keymap(GXKEY_NUMPAD_0).shift = 200000
        __gx_keymap(GXKEY_NUMPAD_PERIOD).value = 100266
        __gx_keymap(GXKEY_NUMPAD_PERIOD).shift = 200010
        __gx_keymap(GXKEY_F11).value = 34048
        __gx_keymap(GXKEY_F12).value = 34304
        __gx_keymap(GXKEY_NUMPAD_ENTER).value = 100271
        __gx_keymap(GXKEY_RCTRL).value = 100305
        __gx_keymap(GXKEY_NUMPAD_DIVIDE).value = 100267
        __gx_keymap(GXKEY_NUMLOCK).value = 100300
        __gx_keymap(GXKEY_HOME).value = 18176
        __gx_keymap(GXKEY_UP).value = 18432
        __gx_keymap(GXKEY_PAGEUP).value = 18688
        __gx_keymap(GXKEY_LEFT).value = 19200
        __gx_keymap(GXKEY_RIGHT).value = 19712
        __gx_keymap(GXKEY_END).value = 20224
        __gx_keymap(GXKEY_DOWN).value = 20480
        __gx_keymap(GXKEY_PAGEDOWN).value = 20736
        __gx_keymap(GXKEY_INSERT).value = 20992
        __gx_keymap(GXKEY_DELETE).value = 21248
        __gx_keymap(GXKEY_LWIN).value = 100311
        __gx_keymap(GXKEY_RWIN).value = 100312
        __gx_keymap(GXKEY_MENU).value = 100319
    $END IF

    $LET GXBI = TRUE
$END IF
