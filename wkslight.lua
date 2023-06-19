--
-- Create a 'thismodule' namespace to isolate the additions
--
local p = premake

p.modules.wkslight = {}

local m = p.modules.wkslight
m._VERSION = "0.0.1"

--
-- Local functions
--
local function s_Print(prj)
	print(prj.foobar)
end

--
-- Override vs2010 project creation functions
--
require("vstudio")

--
-- 'thismodule' variables and functions
--
m.workspacedir = "%{wks.location}/../build"
m.targetdir = "%{wks.location}/../bin/%{cfg.platform}/%{cfg.buildcfg}"

function m.foo()
end

include("_preload")
return m