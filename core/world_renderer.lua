return {create=function(BUS,tex_renderer)
    local grid = BUS.map.grid
    local map  = BUS.map
    local function draw_grid()
        local grid_offset_x = map.grid_offset_x
        local grid_offset_y = map.grid_offset_y
        local grid_offset_z = map.grid_offset_z

        local tile_update_scripts   = map.tile_scripts
        local grid_offset_scripts   = map.grid_scripts
        local screen_offset_scripts = map.screen_scripts

        local press_amount = map.compress_amount
        local i,j = map.ihat,map.jhat

        local screen_offset_x = map.screen_offset_x
        local screen_offset_y = map.screen_offset_y

        local loaded_tiles = map.tiles
        
        local screen_width    = BUS.graphics.w
        
        local coordinate_grid = {}
        for y=grid.start or 1,grid.n do
            local layer = grid[y]
            for z=(layer or {start=1}).start,(layer or {n=0}).n or 0 do
                local row = layer[z]
                for x=(row or {start=1}).start,(row or {n=0}).n do
                    local sprite_name = row[x]
                    local sprites = {}
                    if type(sprite_name) == "string" then sprites = {sprite_name}
                    elseif type(sprite_name) == "table" then sprites = sprite_name end
                    for k,sprite in ipairs(sprites or {}) do
                        local sprite = loaded_tiles[sprite]
                        local has_offset_script = false
                        if sprite then
                            local offset_x = grid_offset_x
                            local offset_y = grid_offset_y
                            local offset_z = grid_offset_z
                            if tile_update_scripts[x] and tile_update_scripts[x][y] and type(tile_update_scripts[x][y][z]) == "function" then
                                tile_update_scripts[x][y][z](sprite,x,y,z)
                            end
                            if grid_offset_scripts[x] and grid_offset_scripts[x][y] and type(grid_offset_scripts[x][y][z]) == "function" then
                                has_offset_script = true
                                local ox,oy,oz = grid_offset_scripts[x][y][z](x,y,z)
                                if ox then offset_x = offset_x + ox end
                                if oy then offset_y = offset_y + oy end
                                if oz then offset_z = offset_z + oz end
                            end
                            local screen_x = (x + offset_x)*i + (z + offset_z)*j
                            local screen_y = (x + offset_x)*press_amount + (z + offset_z)*press_amount - (y + offset_y) + 1
                            if screen_offset_scripts[x] and screen_offset_scripts[x][y] and type(screen_offset_scripts[x][y][z]) == "function" then
                                has_offset_script = true
                                screen_x,screen_y = screen_offset_scripts[x][y][z](screen_x,screen_y)
                            end
                            local tex_x = (screen_x + screen_offset_x)*sprite.w/2 - sprite.w/2 + screen_width/2 - 1
                            local tex_y = (screen_y + screen_offset_y)*sprite.h/2
                            if not (grid[y+1] and grid[y+1][z] and grid[y+1][z][x] and layer[z+1] and layer[z+1][x] and row[x+1]) or has_offset_script then
                                tex_renderer.draw(sprite,tex_x,tex_y,coordinate_grid,x,y,z,sprite)
                            end
                        end
                    end
                end
            end
        end
        return coordinate_grid
    end
    return {render=function()
        draw_grid()
    end}
end}