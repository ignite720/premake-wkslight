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
local function sStrTableToJsonishArray(tbl)
	return "'[\"" .. table.concat(tbl, "\", \"") .. "\"]'"
end

--
-- `thismodule` variables and functions
--
m.targetdouble = "%{cfg.platform}/%{cfg.buildcfg}"
m.targettriple = ("%{cfg.system}/" .. m.targetdouble)
m.targetquadra = "%{cfg.architecture}/vendor/%{cfg.system}/%{cfg.buildcfg}"

m.location = "%{wks.location}/.."
m.workspacedir = (m.location .. "/build")
m.targetdir = (m.location .. "/bin/" .. m.targetdouble)
m.librariesdir = (m.location .. "/libraries")

function m.uselibs(libnames)
	for i, v in ipairs(libnames) do
		local libmeta = m.workspace.libraries.projects[v]
		
		includedirs(libmeta.includedirs)
		libdirs(libmeta.libdirs)
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

function m.wasmlinkoptions(libnames)
	for i, v in ipairs(m.extras.wasm.libs) do
		linkoptions({ "-l" .. v })
	end
	
	if #m.extras.wasm.extra_exported_runtime_methods > 0 then
		linkoptions({ "-sEXTRA_EXPORTED_RUNTIME_METHODS=" .. sStrTableToJsonishArray(m.extras.wasm.extra_exported_runtime_methods) })
	end
	if #m.extras.wasm.exported_functions > 0 then
		linkoptions({ "-sEXPORTED_FUNCTIONS=" .. sStrTableToJsonishArray(m.extras.wasm.exported_functions) })
	end
	
	if m.extras.wasm.use_pthreads then
		linkoptions({ "-sUSE_PTHREADS=1" })
	end
	if m.extras.wasm.asyncify then
		linkoptions({ "-sASYNCIFY=1" })
	end
	if #m.extras.wasm.asyncify_whitelist > 0 then
		linkoptions({ "-sASYNCIFY_WHITELIST=" .. sStrTableToJsonishArray(m.extras.wasm.asyncify_whitelist) })
	end
	
	for i, v in ipairs(m.extras.wasm.preload_files) do
		linkoptions({ "--preload-file " .. v })
	end
	
	if m.extras.wasm.shell_file then
		linkoptions({ "--shell-file " .. m.extras.wasm.shell_file })
	end
	
	linkoptions({
		"-sUSE_SDL=2",
		"-sUSE_SDL_IMAGE=2",
		"-sUSE_SDL_MIXER=2",
		"-sUSE_SDL_NET=2",
		"-sUSE_SDL_TTF=2",
		"-sSDL2_IMAGE_FORMATS=" .. sStrTableToJsonishArray(m.extras.wasm.image_formats),
		"-sENVIRONMENT=web",
		"-sWASM=1",
		"-sEVAL_CTORS",
		"-sUSE_WEBGL2=1",
		"-sFULL_ES2=1",
		"-sFULL_ES3=1",
		"-sMIN_WEBGL_VERSION=2",
		"-sMAX_WEBGL_VERSION=2",
		"-sOFFSCREEN_FRAMEBUFFER=1",
		"-sALLOW_MEMORY_GROWTH=1",
		"--no-heap-copy",
		"-o " .. m.extras.wasm.output_file,
	})
end

include("_preload")
return m