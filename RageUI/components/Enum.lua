














local enums = {
    __index = function(table, key)
        if rawget(table.enums, key) then
            return key
        end
    end
}




function RageUI.Enum(t)
    local e = { enums = t }
    return setmetatable(e, enums)
end
