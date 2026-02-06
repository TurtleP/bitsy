# bitsy

bitsy is a small binary serialization and deserialization library for LÖVE.
It lets you describe binary file layouts using structured, declarative definitions—then read and write them safely and consistently.

Think of it as C-style structs, but in Lua, and without the footguns.

## Features

- 📦 Declarative binary Struct, Field, and Array definitions
- 🔢 Built-in primitive types (`uint8`, `int16`, `float`, `string`, etc.)
- 🧱 Nested structs and fixed-size arrays
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
local Type = bitsy.Types
local Field = bitsy.Field
local Struct = bitsy.Struct

local Player = Struct.new("Player", {
    Field.new(T.UInt32, "id"),
    Field.new(T.Float,  "x"),
    Field.new(T.Float,  "y"),
    Field.new(T.UInt16, "health"),
})
```

## Reading binary data

```lua
local data = love.filesystem.newFileData("player.bin")
local reader = bitsy.Reader(data)

local player = Player:default():read(reader)
print(player:get("health"):getValue())
```

## Writing binary data

```lua
local writer = bitsy.Writer(Player:getSize())

writer:writeUInt32(1)
writer:writeFloat(10.0, 5.0)
writer:writeUInt16(100)

love.filesystem.write("player.bin", writer:getData())
```

## Documentation & Editor Support

Bitsy includes a Lua Language Server definitions file:
`bitsy.d.lua`

To enable autocompletion, type hints, and documentation in editors like VS Code:

1. Place `bitsy.d`.lua somewhere in your workspace
2. Add it to your .luarc.json:

```json
{
  "workspace.library": [
    "path/to/bitsy.d.lua"
  ]
}
```
