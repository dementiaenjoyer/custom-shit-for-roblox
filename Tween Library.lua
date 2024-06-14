--// Drawing library tweenservice made by @eldmonstret / dementia enjoyer
local TweenLibrary = {}
local Other = {}
TweenLibrary.__index = TweenLibrary
--// Rest
 
do --// Functions

    do --// Components

        function Other.Lerp(Start, End, Interp)
            return Start + (End - Start) * Interp
        end

        function Other.LerpColor(Color1, Color2, Interp)
            return {
                R = Other.Lerp(Color1.r, Color2.r, Interp),
                G = Other.Lerp(Color1.g, Color2.g, Interp),
                B = Other.Lerp(Color1.b, Color2.b, Interp)
            }
        end

        function Other.LerpTransparency(Transparency1, Transparency2, Interp)
            return Other.Lerp(Transparency1, Transparency2, Interp)
        end

    end

    function TweenLibrary:Tween(Object, Property, EndValue, Duration)
        local StartValue = Object[Property]
        local StartTime = tick()

        local function Update()
            local Progressed = tick() - StartTime
            local Progress = math.min(Progressed / Duration, 1)
            if Property:find("Color") then
                Object[Property] = Other.LerpColor(StartValue, EndValue, Progress)
            elseif Property:find("Transparency") then
                Object[Property] = Other.LerpTransparency(StartValue, EndValue, Progress)
            end
            if Progress < 1 then
                task.wait()
                Update()
            end
        end
        Update()
    end
end

return TweenLibrary
