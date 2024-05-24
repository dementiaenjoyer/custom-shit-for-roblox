local Table = {
    Old = {
        old = game,
    },
}

local game = {}
local services = {}

do --// Example

    --[[

    local functions = {}

    function functions.Lol()
        print("hi")
    end

    table.insert(services, { 
        name = "Dawg", logic = functions 
    })

    Use service by doing:

    game:GetService("Dawg"):Lol()

    ]]
    
end

do --// Init
    do --// Overwrite
        game.GetService = function(self, service)
            for i = 1, #services do
                local index = services[i]
                if tostring(service) == index.name then
                    return index.logic
                end
            end
            return Table.Old.old:GetService(service)
        end
    end
end

return {services, game, Table.Old.old}
