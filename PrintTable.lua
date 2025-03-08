local function print_table(p10, p11, p12, output)
    output = output or "";
    local var13 = p11 or tostring(p10);
    local var14 = p12 or 0;

    local function rep(...)
        local output_str = string.rep("    ", var14):gsub("^%s", "") .. table.concat({...}, " ");
        print(output_str);

        output = output .. output_str .. "\n";
        return output;
    end

    if p10 and next(p10) then
        output = rep(var13, "{");
        local var16 = var14 + 1;
        var14 = math.max(var16, 0);

        local var17 = var14;

        for var18, var19 in next, p10 do
            if type(var19) == "table" then
                output = print_table(var19, var18, var17, output);
            elseif type(var19) == "function" then
                output = rep(var18, "=", "FUNCTION()");
            else
                output = rep(var18, "=", var19);
            end
        end

        local var20 = var17 - 1;
        var14 = math.max(var20, 0);
        output = rep("}");
    else
        output = rep(var13, "{}");
    end

    return output;
end

--writefile("env_output.txt", print_table(getgenv(), "ENVIRONMENT"));

return print_table;
