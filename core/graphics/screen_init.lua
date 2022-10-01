local object = require("core.object")
local t_util = require("common.table_util")

local clr = require("common.color_util")

local t_unpack,ceil = table.unpack,math.ceil

local methods = {__index=object.new{
    draw=function(this)
        local b = this.BUS.graphics
        for k,v in pairs(b.render) do
            b.display_source.setCursorPos(1,k)
            b.display_source.blit(t_unpack(v))
        end
    end,
    set_pixel=function(this,x,y,r,g,b,a)
        local bus = this.BUS.graphics
        if not (x < 1 or y < 1 or x > bus.w or y > bus.h) then
            local py = bus.buffer[y]
            py[x] = clr.blendf(this.BUS,py[x],{r,g,b,a})

            local sx = ceil(x/2)
            local sy = ceil(y/3)
            bus.updates[sy][sx] = true
        end
    end
},{__tostring=function() return "screen" end}}

return {new=function(BUS)
    local b = BUS.graphics
    local w,h = b.display_source.getSize()
    local vals = {BUS=BUS}
    vals.w,vals.h = w*2,h*3

    b.buffer  = t_util.createNDarray(1)
    b.updates = t_util.createNDarray(1)
    b.chars   = t_util.createNDarray(1)

    for y=1,h do
        for x=1,w do
            b.chars[y][x] = {" ","0","f"}
        end
    end

    return setmetatable(vals,methods):__build()
end}