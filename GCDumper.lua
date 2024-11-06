local dump = {};
local gco = getgc(true);

for index, value in gco do
    if typeof(value) == "function" then
        local info = getinfo(value);
        
        if (info and info.name) then
            table.insert(dump, `index: {index}, name: {info.name}, what: {info.what}, source: {info.source}`);
        end
    end
end

writefile("gc_dump.txt", table.concat(dump, "\n"));
