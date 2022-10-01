local CEIL = math.ceil

return {build=function(BUS)
    local d
    local function set(...)
        if not d then d = BUS.graphics.display end
        d:set_pixel(...)
    end
    return {draw=function(image,x,y,buffer,tile_x,tile_y,tile_z,sprite)
        for img_y=1,image.h do
            for img_x=1,image.w do
                local offset_x = CEIL(x + img_x - 0.5)
                local offset_y = CEIL(y + img_y - 0.5)
                local c = image[img_y][img_x]
                if c then
                    local screen_x = CEIL(offset_x/2)
                    local screen_y = CEIL(offset_y/3)
                    if not buffer[screen_y] then buffer[screen_y] = {} end
                    buffer[screen_y][screen_x] = {
                        x=tile_x,
                        y=tile_y,
                        z=tile_z,
                        tex_x = img_x,
                        tex_y = img_y,
                        tile = sprite
                    }
                    set(offset_x, offset_y, c[1], c[2], c[3], c[4])
                end
            end
        end
    end}
end}
