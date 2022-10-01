local function build_run(iso,args)
    if not iso.run then
        function iso.run()
            if iso.load then iso.load(table.unpack(args,1,args.n)) end
            if iso.timer then iso.timer.step() end
            local dt = 0
            return function()
                if iso.event then
                    iso.event.pump()
                    for name, a,b,c,d,e,f in iso.event.poll() do
                        if name == "quit" then
                            if not iso.quit or not iso.quit() then
                                return a or 0
                            end
                        end
                        iso.handlers[name](a,b,c,d,e,f)
                    end
                end
                if iso.timer then dt = iso.timer.step() end
                if iso.update then iso.update(dt) end
                iso.graphics.clear_buffer(iso.graphics.get_bg())
                if iso.render then iso.render() end
                iso.graphics.render_frame()
                if iso.timer then iso.timer.sleep(0.001) end
            end
        end
    end
end

return build_run