# Usage

```lua
--// Import tween lib

local TweenService = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/custom-shit-for-roblox/main/Tween%20Library.lua"))()

--// Render drawing objects

local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Visible = true
Circle.Transparency = 1

--// Loop circle to mouse pos

coroutine.wrap(function()
    while task.wait() do
        Circle.Position = game:GetService("UserInputService"):GetMouseLocation()
    end
end)()

--// Perform first tween after 2 seconds

task.wait(2)
TweenService:Tween(Circle, "Color", Color3.fromRGB(0, 255, 0), 2) --// Tween color to green

--// Perform second tween after 2 seconds

task.wait(2)
TweenService:Tween(Circle, "Transparency", 0.2, 2) --// Tween transparency to 0.5
```
