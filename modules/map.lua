local map = {}

local gen = require("common.generic")

return function(BUS)
    local map_conf = BUS.map
    local map_grid = map_conf.grid

    function map.set(x,y,z,name)
        gen.init_grid_point(map_grid,x,y,z)
        map_grid[y][z][x] = name
    end

    function map.compression_level(n)
        map_conf.compress_amount = n
    end

    return map
end