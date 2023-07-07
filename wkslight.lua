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
m.workspacedir = "%{wks.location}/../build"
m.targetdir = "%{wks.location}/../bin/%{cfg.platform}/%{cfg.buildcfg}"

include("_preload")
return m