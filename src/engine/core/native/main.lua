local version = require('src/version')
local util_decorator = require('src/lib/util/decorator')
local zeebo_module = require('src/lib/common/module')
--
local engine_encoder = require('src/lib/engine/api/encoder')
local engine_game = require('src/lib/engine/api/app')
local engine_hash = require('src/lib/engine/api/hash')
local engine_http = require('src/lib/engine/api/http')
local engine_i18n = require('src/lib/engine/api/i18n')
local engine_media = require('src/lib/engine/api/media')
local engine_key = require('src/lib/engine/api/key')
local engine_math = require('src/lib/engine/api/math')
local engine_array = require('src/lib/engine/api/array')
local engine_draw_ui = require('src/lib/engine/draw/ui')
local engine_draw_fps = require('src/lib/engine/draw/fps')
local engine_draw_text = require('src/lib/engine/draw/text')
local engine_draw_poly = require('src/lib/engine/draw/poly')
local engine_raw_bus = require('src/lib/engine/raw/bus')
local engine_raw_node = require('src/lib/engine/raw/node')
local engine_raw_memory = require('src/lib/engine/raw/memory')
--
local application_default = require('src/lib/object/root')
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')
--
local application = application_default
local engine = {
    current = application_default,
    root = application_default,
    offset_x = 0,
    offset_y = 0
}

local cfg_system = {
    exit = native_system_exit,
    reset = native_system_reset,
    title = native_system_title,
    get_fps = native_system_get_fps,
    get_secret = native_system_get_secret,
    get_language = native_system_get_language
}

local cfg_media = {
    position=native_media_position,
    resize=native_media_resize,
    pause=native_media_pause,
    load=native_media_load,
    play=native_media_play
}

local cfg_poly = {
    repeats = {
        native_cfg_poly_repeat_0 or false,
        native_cfg_poly_repeat_1 or false,
        native_cfg_poly_repeat_2 or false
    },
    triangle = native_draw_triangle,
    poly2 = native_draw_poly2,
    poly = native_draw_poly,
    line = native_draw_line
}

local cfg_http = {
    ssl = native_http_has_ssl,
    handler = native_http_handler
}

local cfg_base64 = {
    decode = native_base64_decode,
    encode = native_base64_encode
}

local cfg_json = {
    decode = native_json_decode,
    encode = native_json_encode
}

local cfg_xml = {
    decode = native_xml_decode,
    encode = native_xml_encode
}

local cfg_text = {
    font_previous = native_text_font_previous
}

--! @defgroup std
--! @{
--! @defgroup draw
--! @{

--! @short std.draw.clear
local function clear(tint)
    local x, y = engine.offset_x, engine.offset_y
    local width, height = engine.current.data.width, engine.current.data.height
    native_draw_clear(tint, x, y, width, height)
end

--! @short std.draw.rect
--! @fakefunc rect(mode, pos_x, pos_y, width, height)

--! @short std.draw.line
--! @fakefunc line(x1, y1, y2, y1, y2)

--! @short std.draw.image
--! @fakefunc image(src, pos_x, pos_y)

--! @}
--! @}

function native_callback_loop(dt)
    std.milis = std.milis + dt
    std.delta = dt
    std.bus.emit('loop')
end

function native_callback_draw()
    native_draw_start()
    std.bus.emit('draw')
    native_draw_flush()
end

function native_callback_resize(width, height)
    engine.root.data.width = width
    engine.root.data.height = height
    std.app.width = width
    std.app.height = height
    std.bus.emit('resize', width, height)
end

function native_callback_keyboard(key, value)
    std.bus.emit('rkey', key, value)
end

function native_callback_init(width, height, game_lua)
    if std.bus then
        std.bus.emit('clear_all')
    end

    application = zeebo_module.loadgame(game_lua)

    if application then
        application.data.width = width
        application.data.height = height
        std.app.width = width
        std.app.height = height
    end

    std.draw.color=native_draw_color
    std.draw.clear=clear
    std.draw.rect=util_decorator.offset_xy2(engine, native_draw_rect)
    std.draw.line=util_decorator.offset_xyxy1(engine, native_draw_line)
    std.draw.image=util_decorator.offset_xy2(engine, native_draw_image)
    std.text.print = util_decorator.offset_xy1(engine, native_text_print)
    std.text.mensure=native_text_mensure
    std.text.font_size=native_text_font_size
    std.text.font_name=native_text_font_name
    std.text.font_default=native_text_font_default

    zeebo_module.require(std, application, engine)
        :package('@bus', engine_raw_bus)
        :package('@node', engine_raw_node)
        :package('@memory', engine_raw_memory)
        :package('@game', engine_game, cfg_system)
        :package('@math', engine_math)
        :package('@array', engine_array)
        :package('@key', engine_key, {})
        :package('@draw.ui', engine_draw_ui)
        :package('@draw.fps', engine_draw_fps)
        :package('@draw.text', engine_draw_text, cfg_text)
        :package('@draw.poly', engine_draw_poly, cfg_poly)
        :package('@color', color)
        :package('math', engine_math.clib)
        :package('math.random', engine_math.clib_random)
        :package('http', engine_http, cfg_http)
        :package('base64', engine_encoder, cfg_base64)
        :package('json', engine_encoder, cfg_json)
        :package('xml', engine_encoder, cfg_xml)
        :package('i18n', engine_i18n, cfg_system)
        :package('media', engine_media, cfg_media)
        :package('hash', engine_hash, cfg_system)
        :run()

    application.data.width, std.app.width = width, width
    application.data.height, std.app.height = height, height

    std.node.spawn(application)
    std.app.title(application.meta.title..' - '..application.meta.version)

    engine.root = application
    engine.current = application

    std.bus.emit_next('load')
    std.bus.emit_next('init')
end

local P = {
    meta={
        title='gly-engine',
        author='RodrigoDornelles',
        description='native core',
        version=version
    }
}

return P
