return {attach=function(ENV)
    ENV.iso.handlers = setmetatable({},
        {__index=function()
            return function()
        end
    end})
end}