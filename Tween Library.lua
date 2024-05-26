local Library = {}

function Library:Tween(Object, Property, Start, End, Duration)

    local Frames = Duration * 60
    local Step = (End - Start) / Frames
    local Current = Start

    if not Object or not Object[Property] then
        return
    end
    
    if Duration <= 0 then
        print("duration cannot be 0 or less than zero")
        return
    end

    coroutine.wrap(function()

        for i = 1, Frames do
            Current += Step

            if Object[Property] then
                Object[Property] = Current
            end

            task.wait(1 / 60)
        end

        if Object[Property] then
            Object[Property] = End
        end

    end)()

end

return Library
