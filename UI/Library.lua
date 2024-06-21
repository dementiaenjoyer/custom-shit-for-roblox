--// Init

local Library = {
    Functions = {
        Input = {},
        UI = {},
        Debugging = {},
    }
}
local Connections = {
    MB1 = {}
}
local Storage = {
    Input = {
        MouseButton1 = false,
        MouseButton2 = false,
    }
}

--// Services

local TweenService = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/custom-shit-for-roblox/main/Tween%20Library.lua"))()
local UserInputService = game:GetService("UserInputService")

--// Rest

do --// Logic

    do --// Functions

        do --// UI

            function Library.Functions.UI.IsHovering(Object)

                local MousePosition = UserInputService:GetMouseLocation()
                local ElementPosX, ElementPosY = Object.Position.X, Object.Position.Y
                local ElementSizeX, ElementSizeY = Object.Size.X, Object.Size.Y
            
                local HoveringX = MousePosition.X >= ElementPosX and MousePosition.X <= ElementPosX + ElementSizeX
                local HoveringY = MousePosition.Y >= ElementPosY and MousePosition.Y <= ElementPosY + ElementSizeY
            
                return HoveringX and HoveringY

            end
            
        end

        do --// Input

            function Library.Functions.Input.MouseButton1Click(Element, Callback)
                table.insert(Connections.MB1, {Element = Element, Callback = Callback})
            end
            
        end

        do --// Debug

            function Library.Functions.Debugging.Writeline(Depth, Message)

                local OutputValues = {
                    [1] = print,
                    [2] = warn,
                    [3] = error,
                }

                return OutputValues[Depth](" [ Dementia's UI Lib ] : " .. Message)

            end
            
        end
        
    end

    do --// Connections

        UserInputService.InputBegan:Connect(function(Input)
            
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                
                do --// Call connections

                    for i, Connection in Connections.MB1 do
                        if Library.Functions.UI.IsHovering(Connection.Element) then
                            Connection.Callback()
                        end
                    end
                    
                end

            end
            
        end)
        
    end
    
end

--[[ 

# Usage

local Square = Drawing.new("Square")
Square.Size = Vector3.new(100,100)
Square.Transparency = 1
Square.Visible = true
Square.Filled = true

Library.Functions.Input.MouseButton1Click(
    Square, function()
        print("Button clicked")
    end
)

]]

return Library
