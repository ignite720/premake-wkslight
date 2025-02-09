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
        local dirs_to_delete = {
            "bin",
            "build",
            ".vs",
        }
        local files_to_delete = {
            "*.Makefile",
            "*.make",
            "*.db",
            "*.opendb",
            "*.vcxproj",
            "*.vcxproj.filters",
            "*.vcxproj.user",
            "*.sln",
            "*.xcodeproj",
            "*.xcworkspace",
        }
        
        for i, v in ipairs(dirs_to_delete) do
            os.rmdir(v)
        end
        
        if false then
            if os.istarget("windows") then
                for i, v in ipairs(files_to_delete) do
                    --os.remove(v)      -- This will only delete files in the current folder
                    os.execute("del /F /Q /S " .. v)
                end
            else
                os.execute("find . -name .DS_Store -delete")
                for i, v in ipairs(files_to_delete) do
                    os.execute("rm -rf " .. v)
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