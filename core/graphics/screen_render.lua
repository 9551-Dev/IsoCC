local tbl = require("common.table_util")
local chr = require("common.draw_util")
local tb = chr.to_blit

return {build=function(BUS,quant,dith,world)
    local clr = BUS.clr_instance
    return {make_frame=function()
        world.render()
        BUS.graphics.render = tbl.create_blit_array(BUS.graphics.h/3)
        local rend = BUS.graphics.render
        local upd  = BUS.graphics.updates
        local prev = BUS.graphics.chars
        local clred,pal = tbl.createNDarray(1)
        if BUS.sys.quantize then
            pal = clr.set_palette(BUS,quant.quantize())
        else
            clr.update_palette(BUS.graphics.display_source)
        end
        for x,y in tbl.map_iterator(BUS.graphics.w,BUS.graphics.h) do
            local rgb = BUS.graphics.buffer[y][x]
            local c,r,g,b = clr.find_closest_color(rgb[1],rgb[2],rgb[3])
            if BUS.sys.dither then dith.dither(rgb,r,g,b,x,y) end
            clred[y][x] = c

            if x%2 == 0 and y%3 == 0 then
                local BL = clred[y][x]

                local screen_x = x/2
                local screen_y = y/3

                local RENDER_Y = rend[screen_y]

                local block = {
                    clred[y-2][x-1],clred[y-2][x],
                    clred[y-1][x-1],clred[y-1][x],
                    clred[y]  [x-1],BL
                }

                local py = prev[screen_y]
                local px = py  [screen_x]

                if upd[screen_y][screen_x] or not px then
                    local char,fg,bg = " ",colors.black,BL
                    if not (block[1] == BL
                        and block[2] == BL
                        and block[3] == BL
                        and block[4] == BL
                        and block[5] == BL) then
                        char,fg,bg = chr.build_drawing_char(block)
                        py[screen_x] = {char,fg,bg}
                    end
                    rend[screen_y] = {
                        RENDER_Y[1]..char,
                        RENDER_Y[2]..tb[fg],
                        RENDER_Y[3]..tb[bg]
                    }
                else
                    rend[screen_y] = {
                        RENDER_Y[1]..px[1],
                        RENDER_Y[2]..px[2],
                        RENDER_Y[3]..px[3]
                    }
                end
            end
        end
        BUS.graphics.updates = tbl.createNDarray(1)
        if pal then pal.push(BUS.graphics.display_source) end
        BUS.graphics.display:draw()
    end}
end}