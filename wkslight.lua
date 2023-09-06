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

--
-- `thismodule` variables and functions
--
m.duplet = "%{cfg.platform}/%{cfg.buildcfg}"
m.triplet = ("%{cfg.system}" .. m.duplet)
m.quadruplet = ("%{cfg.architecture}/vendor/%{cfg.system}/%{cfg.buildcfg}")

m.workspacedir = "%{wks.location}/../build"
m.targetdir = ("%{wks.location}/../bin/" .. m.duplet)

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
		local localdebugenvs = {}
		for i, v in ipairs(libnames) do
			local libmeta = m.workspace.libraries.projects[v]
			
			table.insert(localdebugenvs, libmeta.localdebugenv)
		end
		
		debugenvs({ "$(LocalDebuggerEnvironment)" .. table.concat(localdebugenvs, ";") })
	filter({})
end

include("_preload")
return m