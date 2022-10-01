local object = require("core.object")

local tile_object = {
    __index = object.new{
        push_map=function(this,as)
            this.BUS.map.tiles[as] = this
        end
    },__tostring=function() return "Tile" end
}

return {add=function(BUS)
    return {new=function(path,load_settings,arg2)
        local transp
        if type(load_settings) == "string" then
            transp = load_settings
            load_settings = arg2
        end
        local extension = path:match("^.+(%..+)$")
        local file_path = fs.combine(BUS.instance.gamedir,path)

        local tmap_path
        local t  = type(transp) == "string"
        local t2 = type(arg2) == "string"
        if t or t2 then
            tmap_path = fs.combine(BUS.instance.gamedir,t and transp or (t2 and arg2))
        end

        package.path = BUS.instance.libpak
        local parser = require("core.loaders.tile" .. extension)
        package.path = BUS.instance.gamepak

        local data = parser.read(file_path,tmap_path)

        data.BUS = BUS

        return setmetatable(data,tile_object):__build()
    end}
end}