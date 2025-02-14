--[[
    The Script Installer -- USE IN ALL YOUR DAVINCI RESOLVE FREE VERSION SCRIPTS! 🎉
    Created By: Asher Roland
    Created: Feb 2025

    This Script is designed to be the header of your finished Lua Scripts for Davinci Resolve. This script acts as an Installer for the script it's in

    This code is also 100% accessible to Free Davinci Resolve Users, even with popups in the script in the "askUser" function

    You are free to use this code in any projects
    If you use Python, a python version is coming soon.
]] --


local scriptsPath = app:MapPath("Scripts:")   -- Should only be declared like this ONCE in an entire file(if not, then it will choose the next MapPath under "Scripts", which isn't correct)
local newPath = "Utility/Install Example.lua" -- DEVELOPER: Change to Where to Save this Script and the Script Name
local installPath = scriptsPath .. newPath
local currentPath = arg[0]

local fu = fu or Fusion()
local comp = comp or fu.CurrentComp
if not comp then
    print("Please Install With a Fusion Comp Open")
    return
end

-- Checks if the install path is in any part of the current path to see if it's installed
local function ScriptIsInstalled()
    local script_path = currentPath
    local match = script_path:find(scriptsPath)
    return match ~= nil
end

local SCRIPT_INSTALLED = ScriptIsInstalled()

-- Reusable Function to send Messages to user without the UI system, (ui system) removed in 19.1
local function askUser(customTitle, msg)
    local title
    local win = {}
    if not msg then
        title = customTitle or "Hotkey In Use.\nChoose a New Hotkey:"
        win[1] = {
            "Hotkey",
            "Text",
            Name = "Type in your Hotkey",
            Default =
            "Shift + I (+ is required to combine keys)",
            Lines = 2
        }
    else
        title = customTitle or "WARNING"
        win[1] = { "Msg", "Text", Name = "Message: ", ReadOnly = true, Lines = 5, Wrap = true, Default = msg }
    end
    local dialog = comp:AskUser(title, win)
    if not dialog then
        return nil
    else
        return dialog
    end
end

-- Copies basic text based files from a source to a target
local function CopyFile(source, target)
    print("---------------------------------")
    print("Starting File Copy")
    if not source then
        print("No Source")
        return false
    end
    local source_file = io.open(source, "r")
    print("Source File: " .. source)
    if not source_file then
        print("Source Could Not Open")
        print("---------------------------------")
        return false
    end
    local contents = source_file:read("*a")
    source_file:close()

    local target_file = io.open(target, "w")
    print("Target File" .. target)
    if not target_file then
        print("Target Could Not Open")
        print("---------------------------------")
        return false
    end
    target_file:write(contents)
    target_file:close()

    print("---------------------------------")
    return true
end

-- Copies the script file and adds the hotkeys
local function installScript()
    if not bmd.fileexists(currentPath) then
        askUser("ERROR", "Failed to access Current File Location\n" .. currentPath)
        return
    end
    local copied = CopyFile(currentPath, installPath)
    if not copied then
        askUser("ERROR", "Failed to Copy Script to\n" .. installPath .. "\nFrom\n" .. currentPath .. "\nNo Hotkey Added.")
        return
    end
    askUser("SUCCESS",
        [[Installed Script Successfully
----------------------------------------
Installed To: ]] .. installPath .. [[

----------------------------------------
Please Restart Davinci]])
end

if not SCRIPT_INSTALLED then
    installScript()
end

print("Installed!")
print("Removing Installing Variables!")
fu = nil
comp = nil
installPath = nil
currentPath = nil
UserPath = nil
newPath = nil
SCRIPT_INSTALLED = nil
collectgarbage('collect')
