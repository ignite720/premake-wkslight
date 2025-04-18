--
-- Name:        thismodule/_preload.lua
-- Purpose:     Define the `thismodule` APIs
-- Author:      ignite720
-- Copyright:   (c) 2002-2025 Jason Perkins and the Premake project
--

local p = premake
local api = p.api

--
-- Register the `thismodule` extension
--

--
-- Register the `thismodule` action
--
newaction({
    trigger = "clean",
    description = "Clean up all intermediate files",
    execute = function()
        if g_wkslight.clean.dirs_to_delete.enabled then
            for i, v in ipairs(g_wkslight.clean.dirs_to_delete.items) do
                os.rmdir(v)
            end
        end
        
        if g_wkslight.clean.files_to_delete.enabled then
            if os.istarget("windows") then
                for i, v in ipairs(g_wkslight.clean.files_to_delete.items) do
                    os.execute("del /F /S /Q " .. v)
                end
            else
                os.execute("find . -name .DS_Store -delete")
                for i, v in ipairs(g_wkslight.clean.files_to_delete.items) do
                    os.execute(string.format("find . -type f -name '%s' -exec rm -fv {} +", v))
                end
            end
        end
    end
})

--
-- Register `thismodule` properties
--

--
-- Decide when `thismodule` should be loaded
--
return function(cfg)
    return true
end