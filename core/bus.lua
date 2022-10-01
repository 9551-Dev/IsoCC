return {register_bus=function(ENV)
    return {
        timer={last_delta=0,temp_delta=0},
        iso=ENV.iso,
        ENV=ENV,
        frames={},
        events={},
        running=true,
        graphics={
            buffer=ENV.utils.table.createNDarray(1),
            bg_col={0,0,0,1},
            blending={mode="alpha",alphamode="alphamultiply"},
        },
        thread={
            channel={},
            coro={}
        },
        mouse={
            last_x=0,
            last_y=0,
            relative_mode=false,
            grabbed=false,
            visible=true,
            held={}
        },
        keyboard={
            key_reapeat=false,
            pressed_keys={},
            textinput=true
        },
        instance={},
        object={},
        sys={
            quantize=false,
            dither=false,
            frame_time_min=1/20,
            reserved_colors={},
            reserved_spots={}
        },
        map={
            tiles={},
            grid={n=0,start=1},

            grid_offset_x=0,
            grid_offset_y=0,
            grid_offset_z=0,

            tile_scripts  =ENV.utils.table.createNDarray(2),
            grid_scripts  =ENV.utils.table.createNDarray(2),
            screen_scripts=ENV.utils.table.createNDarray(2),

            compress_amount=0.5,
            ihat           =1,
            jhat           =-1,

            screen_offset_x=0,
            screen_offset_y=0
        }
    }
end}