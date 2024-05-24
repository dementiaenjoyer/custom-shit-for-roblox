# Usage

```lua
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/custom-shit-for-roblox/main/Custom%20Service%20Library.lua"))()
local game = Lib[2]

do --// Custom Service

    local functions = {}

    function functions.Lol()
        print("hi")
    end

    table.insert(Lib[1], { 
        name = "Dawg", logic = functions 
    })
    
end

game:GetService("Dawg"):Lol()
```
