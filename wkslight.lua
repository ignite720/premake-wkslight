--
-- Create a `thismodule` namespace to isolate the additions
--
local p = premake

p.modules.wkslight = {}

local m = p.modules.wkslight
m._VERSION = "0.0.1"

--
-- Local functions
--
local function __table_print(v, indent)
    local variable_name = tostring(v)
    if type(v) == "table" then
        for k, v in pairs(v) do
            if type(v) == "table" then
                print(indent .. "[" .. k .. "] => " .. variable_name .. " {")
                
                __table_print(v, indent .. "    ")
            elseif type(v) == "string" then
                print(indent .. "[" .. k .. '] => "' .. v  .. '"')
            else
                print(indent .. "[" .. k .. "] => " .. tostring(v))
            end
        end
    else
        print(indent .. variable_name)
    end
end

local function __table_to_jsonish_array(tbl)
    return "'[\"" .. table.concat(tbl, "\", \"") .. "\"]'"
end

--
-- `thismodule` variables and functions
--
function m.hasattr(object_, name_)
    return object_[name_] ~= nil
end

m.makereadonlytbl = (function()
    local proxies = setmetatable({}, { __mode = "k" })
    return function(v)
        if type(v) == "table" then
            local proxy = proxies[v]
            if not proxy then
                proxy = setmetatable({}, {
                    __index = function(tbl, key)
                        return m.makereadonlytbl(v[key])
                    end,
                    __newindex = function(tbl, key, value)
                        error(string.format("Attempt to update a read-only table: [%s].%s", tbl, key), 2)
                    end,
                    __metatable = false,
                })
                proxies[v] = proxy
            end
            return proxy
        else
            return v
        end
    end
end)()

-- table.tostring
function m.tableprint(tbl)
    assert(type(tbl) == "table")
    
    print(tostring(tbl) .. " {")
    __table_print(tbl, "  ")
    print("}\n")
end

function m.tableflatten(tbl)
    assert(type(tbl) == "table")

    local result = {}
    local __tableflatten = function(t)
        for k, v in pairs(t) do
            if type(v) == "table" then
                __tableflatten(v)
            else
                if k ~= "n" then
                    table.insert(result, v)
                end
            end
        end
    end

    __tableflatten(tbl)
    return result
end

function m.tablemerge(tbl, tbl2)
    for _, v in ipairs(tbl2) do
        table.insert(tbl, v)
    end
end

function m.table2jsonisharray(tbl)
    return __table_to_jsonish_array(tbl)
end

function m.bitmaskset(bmask, flag)
    return bmask | flag
end

function m.bitmaskreset(bmask, flag)
    return bmask & ~flag
end

function m.bitmaskflip(bmask, flag)
    return bmask ~ flag
end

function m.bitmasktestany(bmask, flag)
    return (bmask & flag) ~= 0
end

function m.bitmasktestall(bmask, flag)
    return (bmask & flag) == flag
end

function m.libs(libnames)
    for i, v in ipairs(libnames) do
        local libmeta = m.workspace.libraries.projects[v]
        local include_dirs, lib_dirs = libmeta.includedirs, libmeta.libdirs
        if type(libmeta.additionalincludedirs) == "function" then
            include_dirs = table.join(include_dirs, libmeta.additionalincludedirs())
        end
        if type(libmeta.additionallibdirs) == "function" then
            lib_dirs = table.join(lib_dirs, libmeta.additionallibdirs())
        end

        includedirs(include_dirs)
        libdirs(lib_dirs)
        links(libmeta.links)
        defines(libmeta.defines)
        debugenvs(libmeta.debugenvs)
    end
    
    filter("action:vs*")
        local vslocaldebugenvs = {}
        for i, v in ipairs(libnames) do
            local libmeta = m.workspace.libraries.projects[v]
            
            table.insert(vslocaldebugenvs, libmeta.vslocaldebugenv)
        end
        
        debugenvs({ "$(LocalDebuggerEnvironment)" .. table.concat(vslocaldebugenvs, ";") })
    filter({})
end

function m.wasmlinkoptions(opts)
    if opts.em_config then
        linkoptions({ "--em-config " .. opts.em_config })
    end

    for i, v in ipairs(opts.libs) do
        linkoptions({ "-l" .. v })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_ZLIB) then
        linkoptions({ "-sUSE_ZLIB=1" })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_SDL2) then
        linkoptions({ "-sUSE_SDL=2" })
    end 
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_SDL_IMAGE) then
        linkoptions({
            "-sUSE_SDL_IMAGE=2",
            "-sSDL2_IMAGE_FORMATS=" .. __table_to_jsonish_array(opts.image_formats),
        })
    end
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_SDL_MIXER) then
        linkoptions({ "-sUSE_SDL_MIXER=2" })
    end
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_SDL_NET) then
        linkoptions({ "-sUSE_SDL_NET=2" })
    end
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_SDL_TTF) then
        linkoptions({ "-sUSE_SDL_TTF=2" })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.USE_WEBGL2) then
        linkoptions({
            "-sUSE_WEBGL2=1",
            "-sFULL_ES2=1",
            "-sFULL_ES3=1",
            "-sMIN_WEBGL_VERSION=2",
            "-sMAX_WEBGL_VERSION=2",
        })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.EXPLICIT_SWAP_CONTROL) then
        linkoptions({
            "-sOFFSCREENCANVAS_SUPPORT",
        })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.ASYNCIFY) then
        linkoptions({ "-sASYNCIFY=1" })
    else
        --linkoptions({ "-sEVAL_CTORS" })
    end
    if #opts.asyncify_whitelist > 0 then
        linkoptions({ "-sASYNCIFY_WHITELIST=" .. __table_to_jsonish_array(opts.asyncify_whitelist) })
    end
    
    if m.bitmasktestany(opts.flags, m.EWasmFlag.LINK_OPENAL) then
        linkoptions({
            "-lopenal",
        })
    end
    
    if #opts.exported_runtime_methods > 0 then
        linkoptions({ "-sEXPORTED_RUNTIME_METHODS=" .. __table_to_jsonish_array(opts.exported_runtime_methods) })
    end
    if #opts.exported_functions > 0 then
        linkoptions({ "-sEXPORTED_FUNCTIONS=" .. __table_to_jsonish_array(opts.exported_functions) })
    end
    
    for i, v in ipairs(opts.preload_files) do
        linkoptions({ "--preload-file " .. v })
    end

    for i, v in ipairs(opts.embed_files) do
        linkoptions({ "--embed-file " .. v })
    end
    
    if opts.shell_file then
        linkoptions({ "--shell-file " .. opts.shell_file })
    end
    
    linkoptions({
        "-sWASM=1",
        "-sFETCH",
        "-sALLOW_MEMORY_GROWTH=1",
        "--no-heap-copy",
        "-o " .. opts.output_file,
    })
end

m.EWasmFlag = m.makereadonlytbl({
    NONE = 0,
    USE_ZLIB = 1 << 0,
    USE_SDL2 = 1 << 1,
    USE_SDL_IMAGE = 1 << 2,
    USE_SDL_MIXER = 1 << 3,
    USE_SDL_NET = 1 << 4,
    USE_SDL_TTF = 1 << 5,
    USE_WEBGL2 = 1 << 6,
    EXPLICIT_SWAP_CONTROL = 1 << 7,
    ASYNCIFY = 1 << 8,
    LINK_OPENAL = 1 << 9,
})

-- built-in variables composed from `Value Tokens`
m.targetdouble = "%{cfg.platform}/%{cfg.buildcfg}"
m.targettriple = ("%{cfg.system}/" .. m.targetdouble)
m.targetquadra = "%{cfg.architecture}/vendor/%{cfg.system}/%{cfg.buildcfg}"

-- wks.location(location where the workspace/solution is written, not the premake-wks.lua file)
m.location = "%{wks.location}/.."
m.workspacedir = (m.location .. "/build")
m.targetdir = (m.location .. "/bin/target/" .. m.targetdouble)
m.baseobjdir = (m.targetdir .. "/objs")
m.baseobjdirs = {
    m.baseobjdir .. "/projects",
    m.baseobjdir .. "/libraries",
    m.baseobjdir .. "/foo",
    m.baseobjdir .. "/bar",
    m.baseobjdir .. "/baz",
    m.baseobjdir .. "/qux",
    m.baseobjdir .. "/quux",
    m.baseobjdir .. "/corge",
    m.baseobjdir .. "/grault",
    m.baseobjdir .. "/garply",
    m.baseobjdir .. "/waldo",
    m.baseobjdir .. "/fred",
}
m.librariesdir = (m.location .. "/libraries")

include("_preload")
return m