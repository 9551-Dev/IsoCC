local draw = {to_blit={}}

local t_insert, t_unpack, t_sort, s_char, pairs = table.insert, table.unpack, table.sort, string.char, pairs

local logify = {}

local chars = "0123456789abcdef"
for i = 0, 15 do
    draw.to_blit[2^i] = chars:sub(i + 1, i + 1)
    logify [2^i] = i
end

function draw.respect_newlines(term,text)
    local sx,sy = term.getCursorPos()
    local lines = 0
    for c in text:gmatch("([^\n]+)") do
        lines = lines + 1
        term.setCursorPos(sx,sy)
        term.write(c)
        sy = sy + 1
    end
    return lines
end

local BUILDS = {}
local count_sort = function(a,b) return a.count > b.count end
function draw.build_drawing_char(arr)
    local cols,fin,char,visited = {},{},{},{}
    local entries = 0
    local build_id = ""
    for k = 1, 6 do
        build_id = build_id .. ("%x"):format(logify[arr[k]])
        if cols[arr[k]] == nil then
            entries = entries + 1
            cols[arr[k]] = {count=1,c=arr[k]}
        else cols[arr[k]] = {count=cols[arr[k]].count+1,c=cols[arr[k]].c}
        end
    end
    if not BUILDS[build_id] then
        for k,v in pairs(cols) do
            if not visited[v.c] then
                visited[v.c] = true
                if entries == 1 then t_insert(fin,v) end
                t_insert(fin,v)
            end
        end
        t_sort(fin, count_sort)
        local swap = true
        for k=1,6 do
            if arr[k] == fin[1].c then char[k] = 1
            elseif arr[k] == fin[2].c then char[k] = 0
            else
                swap = not swap
                char[k] = swap and 1 or 0
            end
        end
        if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end
        local n = 128
        for i = 0, 4 do n = n + char[i+1]*2^i end
        if char[6] == 1 then BUILDS[build_id] = {s_char(n), fin[2].c, fin[1].c}
        else BUILDS[build_id] = {s_char(n), fin[1].c, fin[2].c}
        end
    end
    return t_unpack(BUILDS[build_id])
end

return draw