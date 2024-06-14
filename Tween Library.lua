--// Drawing library tweenservice made by @eldmonstret / dementia enjoyer
local TweenLibrary = {}
local Other = {}
TweenLibrary.__index = TweenLibrary

--// Functions

do --// Components

    function Other.Lerp(Start, End, Interp)
        return Start + (End - Start) * Interp
    end

    function Other.LerpColor(Color1, Color2, Interp)
        return Color3.new(
            Other.Lerp(Color1.R, Color2.R, Interp),
            Other.Lerp(Color1.G, Color2.G, Interp),
            Other.Lerp(Color1.B, Color2.B, Interp)
        )
    end

    function Other.LerpTransparency(Transparency1, Transparency2, Interp)
        return Other.Lerp(Transparency1, Transparency2, Interp)
    end

    function Other.LerpVector2(Vector1, Vector2, Interp)
        return Vector2.new(
            Other.Lerp(Vector1.X, Vector2.X, Interp),
            Other.Lerp(Vector1.Y, Vector2.Y, Interp)
        )
    end

end

function TweenLibrary:Tween(Object, Property, EndValue, Duration)
    local StartValue = Object[Property]
    local StartTime = tick()

    local function Update()
        local ElapsedTime = tick() - StartTime
        local Progress = math.min(ElapsedTime / Duration, 1)

        if Property:find("Color") then
            Object[Property] = Other.LerpColor(StartValue, EndValue, Progress)
        elseif Property:find("Transparency") then
            Object[Property] = Other.LerpTransparency(StartValue, EndValue, Progress)
        elseif Property:find("Position") then
            Object.Position = Other.LerpVector2(StartValue, EndValue, Progress)
        end

        if Progress < 1 then
            task.wait()
            Update()
        end
    end

    Update()
end

return TweenLibrary
