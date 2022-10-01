local cmgr     = require("core.cmgr")
local bus      = require("core.bus")
local handlers = require("core.handlers")

local screen_init = require("core.graphics.screen_init")

local update_thread = require("core.threads.update_thread")
local event_thread  = require("core.threads.event_thread")
local resize_thread = require("core.threads.resize_thread")
local key_thread    = require("core.threads.key_thread")
local tudp_thread   = require("core.threads.tupd_thread")

return function(ENV,libdir,...)
    local args = table.pack(...)
    local BUS = bus.register_bus(ENV)
    handlers.attach(ENV)
    BUS.instance.libdir = libdir

    local function start_execution(program,path,terminal,parent,ox,oy)

        local w,h = terminal.getSize()
        local ok = pcall(function()
            BUS.graphics.monitor = peripheral.getName(parent)
        end)
        if not ok then BUS.graphics.monitor = "term_object" end
        BUS.graphics.w,BUS.graphics.h = w*2,h*3
        BUS.graphics.display_source = terminal
        BUS.graphics.display = screen_init.new(BUS)
        BUS.graphics.event_offset = vector.new(ox,oy)
        BUS.clr_instance.update_palette(terminal)
        BUS.instance.gamedir = fs.getDir(path) or ""
        BUS.instance.gamepak = string.format(
            "/%s/modules/required/?.lua;/%s/?.lua;/rom/modules/main/?.lua",
            libdir,BUS.instance.gamedir
        )
        BUS.instance.libpak = string.format(
            "/%s/?.lua;/rom/modules/main/?.lua",
            libdir
        )
        for x,y in ENV.utils.table.map_iterator(BUS.graphics.w,BUS.graphics.h) do
            BUS.graphics.buffer[y][x] = {0,0,0,1}
        end
        if type(program[1]) == "function" then
            local old_path = package.path
            ENV.package.path = BUS.instance.gamepak
            setfenv(program[1],ENV)(table.unpack(args,1,args.n))
            ENV.package.path = old_path
        else
            error(program[2],0)
        end

        local main   = update_thread.make(ENV,BUS,args)
        local event  = event_thread .make(ENV,BUS,args)
        local resize = resize_thread.make(ENV,BUS,parent)
        local key_h  = key_thread   .make(ENV,BUS)
        local tudp   = tudp_thread  .make(ENV,BUS)

        local ok,err = cmgr.start(BUS,function()
            return BUS.running
        end,{},main,event,resize,key_h,tudp)

        if not ok and ENV.iso.errorhandler then
            if ENV.iso.errorhandler(err) then
                error(err,2)
            end
        elseif not ok then
            error(err,2)
        end
    end

    BUS.object.tile = require("core.objects.tile").add(BUS)

    ENV.iso.timer    = require("modules.timer")   (BUS)
    ENV.iso.event    = require("modules.event")   (BUS)
    ENV.iso.graphics = require("modules.graphics")(BUS)
    ENV.iso.keyboard = require("modules.keyboard")(BUS)
    ENV.iso.mouse    = require("modules.mouse")   (BUS)
    ENV.iso.thread   = require("modules.thread")  (BUS)
    ENV.iso.sys      = require("modules.sys")     (BUS)
    ENV.iso.map      = require("modules.map")     (BUS)

    require("modules.iso")(BUS)

    return start_execution
end