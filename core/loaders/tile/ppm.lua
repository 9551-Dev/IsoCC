local ppm = require("lib.luappm")

local tbl = require("common.table_util")

return {read=function(path_tex,path_transparency)
    local map_color = ppm(path_tex)
    local map_trans = ppm(path_transparency)

    local res = tbl.createNDarray(1,{
        w=map_color.w,
        h=map_color.h
    })

    for y=1,map_color.h do
        for x=1,map_color.w do
            local px = map_color[y][x]
            res[y][x] = {
                px[1],
                px[2],
                px[3],
                map_trans[y][x][4]
            }
        end
    end

    return res
end}
