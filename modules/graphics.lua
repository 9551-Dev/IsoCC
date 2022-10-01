local graphics = {}

local clr = require("common.color_util")
local tbl = require("common.table_util")

local quantize = require("core.graphics.quantize")
local dither   = require("core.graphics.dither")

local txrender = require("core.graphics.tex_render")
local scrender = require("core.graphics.screen_render")

local world_renderer = require("core.world_renderer")

local u_unpack,ceil = table.unpack,math.ceil

return function(BUS)

    BUS.clr_instance = clr

    local quantizer   = quantize.build(BUS)
    local ditherer    = dither  .build(BUS)
    local sc_renderer = scrender.build(BUS,
        quantizer,ditherer,world_renderer.create(BUS,txrender.build(BUS))
    )

    function graphics.clear_buffer(r,g,b,a)
        BUS.map.grid = {n=0,start=1}
        local bg = BUS.graphics
        for x,y in tbl.map_iterator(BUS.graphics.w,BUS.graphics.h) do
            bg.buffer[y][x] = {r,g,b,a or 1}

            local sx = ceil(x/2)
            local sy = ceil(y/3)

            bg.updates[sy][sx] = true
        end
    end

    function graphics.render_frame()
        sc_renderer.make_frame()
    end

    function graphics.get_bg()
        return u_unpack(BUS.graphics.bg_col)
    end
    function graphics.set_bg(r,g,b,a)
        BUS.graphics.bg_col = {r,g,b,a or 1}
    end

    function graphics.blend_mode(mode,alphamode)
        BUS.graphics.blending.mode = mode or "alpha"
        BUS.graphics.blending.alphamode = alphamode or "alphamultiply"
    end

    function graphics.get_resolution()
        local b = BUS.graphics
        return b.w*2,b.h*3
    end

    function graphics.load_tile(...)
        return BUS.object.tile.new(...)
    end

    return graphics
end