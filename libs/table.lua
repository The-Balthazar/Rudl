array = {
    copy = function(a,new)
        new=new or {}
        for i, v in ipairs(a) do
            new[i]=v
        end
        return new
    end,
    find = function(a,f)
        for i, v in ipairs(a) do
            if v==f then
                return i
            end
        end
    end,
    findsubstring = function(a,f)
        for i, v in ipairs(a) do
            if v:find(f) then
                return i
            end
        end
    end,
    findtype = function(a,t)
        for i, v in ipairs(a) do
            if type(v)==t then
                return i
            end
        end
    end,
    hash = function(a, new)
        new=new or {}
        for i, v in ipairs(a) do
            new[v] = v
        end
        return new
    end,
}

function table.copy(t,new)
    new=new or {}
    for k, v in pairs(t) do
        new[k]=v
    end
    return new
end

function table.unhash(h, new)
    new=new or {}
    local i = 0
    for k, v in pairs(h) do
        i = i+1
        new[i]=k
    end
    return new
end
