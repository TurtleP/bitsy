# bitsy

bitsy is a small binary serialization and deserialization library for LÖVE.
It lets you describe binary file layouts using structured, declarative definitions - then read and write them safely and consistently.

Think of it as C-style structs, but in Lua, and without the footguns.

## Features

- 📦 Declarative binary Struct, Field, and Array definitions
- 🔢 Built-in primitive types (`uint8`, `int16`, `float`, `char`, etc.)
- 🧱 Nested structs and fixed-size arrays
- 📝 String type for UTF-8 and UTF-16 encoded text
- 🪄 Magic value validation (file headers, version checks)
- 📖 Binary Reader and Writer built on love.Data
- 🎮 Designed specifically for LÖVE

## Install

Simply copy the `bitsy` folder into your project, then:

```lua
local bitsy = require("bitsy")
```

## Defining a Struct

```lua
local PlayerStruct = bitsy.Struct("Player", {
    bitsy.Field("name", bitsy.String(256)),
    bitsy.Field("rank", bitsy.Type.UInt8),
    bitsy.Field("score", bitsy.Type.UInt32)
})
```

## Reading binary data

```lua
-- Use bitsy.Reader(data) for existing love.Data!
local reader = bitsy.Reader.open("player.bin")

local player = PlayerStruct:read(reader)
print(player.name, player.rank, player.score)
--> "SuperCoolName" 1 42069
```

## Writing binary data

```lua
--- Use bitsy.Writer.from(data) for existing love.Data!
local writer = bitsy.Writer(PlayerStruct:getSize())
--- Each table index represents the field in the Struct.
PlayerStruct:write(writer, { "SuperCoolPerson", 100, 0 })

love.filesystem.write("player.bin", writer:getData())
--> "SuperCoolPerson" 100 0
```

## Documentation & Editor Support

Bitsy includes a Lua Language Server definitions file:
`bitsy.d.lua`

To enable autocompletion, type hints, and documentation in editors like VS Code:

1. Place `bitsy.d`.lua somewhere in your workspace
2. Add it to your .luarc.json:

```json
{
    "workspace.library": ["path/to/bitsy.d.lua"]
}
```
