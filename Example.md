# Usage

```lua

-- Services
local RunService = game:GetService("RunService")
local TweenService = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/custom-shit-for-roblox/main/Tween%20Library.lua"))()

-- Drawing
local MoveSquare = Drawing.new("Square") -- This will tween position
MoveSquare.Color = Color3.fromRGB(255, 255, 255)
MoveSquare.Transparency = 1
MoveSquare.Visible = true
MoveSquare.Size = Vector2.new(400,400)
MoveSquare.Filled = true

task.delay(2, function()
    local R, G, B = math.random(1,255), math.random(1,255), math.random(1,255) -- Incase you wanna test out the color property
    TweenService:Tween(MoveSquare, "Color", Color3.fromRGB(R, G, B), 2) -- Center square on the mouse
end)

RunService.Heartbeat:Connect(function()
    local MousePosition = game:GetService("UserInputService"):GetMouseLocation()
    local Center = Vector2.new(MousePosition.X - (MoveSquare.Size.X / 2), MousePosition.Y - (MoveSquare.Size.Y / 2))
    local R, G, B = math.random(1,255), math.random(1,255), math.random(1,255) -- Incase you wanna test out the color property

    --[[

    ARGUMENTS;
    1 - Drawing Object
    2 - Property // ( Color, Transparency, Position )
    3 - End value
    4 - Duration
    ]]

    TweenService:Tween(MoveSquare, "Position", Center, 0.05) -- Center square on the mouse
end)

```
