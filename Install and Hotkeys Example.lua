local defaultHotkey = "SHIFT + I"           -- Change to be what your default Hotkey for your tool will be

local profilePath = app:MapPath("Profile:") -- Should only be declared like this ONCE in an entire file
local UserPath = profilePath .. "User.fu"
local userTbl = bmd.readfile(UserPath)

local scriptsPath = app:MapPath("Scripts:")    -- Should only be declared like this ONCE in an entire file(if not, then it will choose the next MapPath under "Scripts", which isn't correct)
local newPath = "Utility/Hotkey Prototype.lua" -- Change to Where to Save this Script and the Script Name
local installPath = scriptsPath .. newPath
local currentPath = arg[0]

local key

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

-- Checks if Key uses the valid hotkey terminally for the keys
local function validateKey(key)
    local validKeys = {
        -- Control keys
        "BACKSPACE",
        "TAB",
        "CLEAR", -- (Optional: not present on every keyboard)
        "ENTER",
        "SHIFT",
        "CONTROL",
        "ALT",
        "PAUSE",
        "CAPSLOCK",
        "ESCAPE",
        "SPACE",
        "PAGEUP",
        "PAGEDOWN",
        "END",
        "HOME",
        "LEFT",  -- Left Arrow
        "UP",    -- Up Arrow
        "RIGHT", -- Right Arrow
        "DOWN",  -- Down Arrow
        "PRINTSCREEN",
        "INSERT",
        "DELETE",

        -- Alphanumeric keys
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

        -- Numeric keypad (if available)
        "NUMPAD0",
        "NUMPAD1",
        "NUMPAD2",
        "NUMPAD3",
        "NUMPAD4",
        "NUMPAD5",
        "NUMPAD6",
        "NUMPAD7",
        "NUMPAD8",
        "NUMPAD9",
        "MULTIPLY",
        "ADD",
        "SEPARATOR",
        "SUBTRACT",
        "DECIMAL",
        "DIVIDE",

        -- Function keys
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        "F13", "F14", "F15", "F16", "F17", "F18", "F19", "F20", "F21", "F22", "F23", "F24",

        "NUMLOCK",
        "SCROLLLOCK",

        -- Punctuation / OEM keys (US keyboard layout)
        "SEMICOLON",    -- ; :
        "EQUALS",       -- = +
        "COMMA",        -- , <
        "MINUS",        -- - _
        "PERIOD",       -- . >
        "SLASH",        -- / ?
        "BACKQUOTE",    -- ` ~
        "LEFTBRACKET",  -- [ {
        "BACKSLASH",    -- \ |
        "RIGHTBRACKET", -- ] }
        "APOSTROPHE"    -- ' "
    }

    local validKeyLookup = {}
    for _, keyName in ipairs(validKeys) do
        validKeyLookup[keyName] = true
    end


    local parts = {}
    for token in string.gmatch(key, "([^_]+)") do
        table.insert(parts, token)
    end

    for _, word in ipairs(parts) do
        if not validKeyLookup[word] then
            return false, word
        end
    end
    return true
end

-- Finds Key in existing file, returns true if key already exists, returns false if no match exists
-- Only checks FuFrame, all hotkeys added will go there
local function checkKey(newKey)
    local target = "FuFrame"
    local foundEntry = nil

    for _, entry in pairs(userTbl) do
        if type(entry) == "table" and entry.Target == target then
            foundEntry = entry
            if entry[newKey] then
                return true
            end
            break
        end
    end

    if not foundEntry then
        foundEntry = { Target = target, __ctor = "Hotkeys" }
        table.insert(userTbl, foundEntry)
        local isvalid = checkKey(newKey)
        if isvalid then
            return isvalid
        end
    end

    local isValidKey, word = validateKey(newKey)
    if not isValidKey then
        print(word .. " is not valid to assign.")
        return true
    end
    return false
end

-- Removes Spaces and Replaces the + sign with the _ then makes all letters capitalized to match the .fu file format
local function cleanKey(key)
    key = key:gsub(" ", "")
    key = key:gsub("+", "_")
    return key:upper()
end

-- Reusable Function to send Messages to user without the UI system, (ui system) removed in 19.1
local function askUser(customTitle, msg)
    local title
    local win = {}
    if not msg then
        title = customTitle or "Choose a New Hotkey:"
        win[1] = { "Hotkey", "Text", Name = "Type in your Hotkey", Default = "Shift + I (+ is required to combine keys)", Lines = 2 }
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
        return false
    end
    local contents = source_file:read("*a")
    source_file:close()

    local target_file = io.open(target, "w")
    print("Target File" .. target)
    if not target_file then
        print("Target Could Not Open")
        return false
    end
    target_file:write(contents)
    target_file:close()

    print("---------------------------------")
    return true
end

-- Adds new Hotkey to Hotkey Table
local function updateUserTbl()
    for _, hotkeySet in ipairs(userTbl) do
        if hotkeySet.Target == "FuFrame" then
            hotkeySet[key] = "RunScript{ filename = 'Scripts:/" .. newPath .. "'}"
            return userTbl
        end
    end
    return nil
end

-- checks if default key is valid, otherwise, get new valid key from user
local function getKey()
    key = cleanKey(defaultHotkey)
    local isKey = checkKey(key)
    if isKey then
        while true do
            local dialog = askUser()
            if dialog and dialog.Hotkey then
                key = cleanKey(dialog.Hotkey)
                local isKey = checkKey(key)
                if not isKey then
                    print(key)
                    return key
                end
            else
                return nil
            end
        end
    end
    return key
end

-- Writes new hotkey data to user.fu file
local function addHotkey()
    key = getKey()

    if key then
        local updatedUser = updateUserTbl()
        if updatedUser then
            print("---------------------------------")
            print(bmd.writestring(updatedUser))
            print("---------------------------------")
            local userFile = io.open(UserPath, "w")
            if userFile then
                local success = userFile:write(bmd.writestring(updatedUser))
                userFile:close()
                if not success then
                    return false
                end
                return true, key
            else
                return false
            end
        end
    end
end

-- Copies the script file and adds the hotkeys
local function installScript()
    if not bmd.fileexists(currentPath) then
        askUser("ERROR", "Failed to access Current File Location\n" .. currentPath)
        return
    end
    local copied = CopyFile(currentPath, installPath)
    if not copied then
        askUser("ERROR", "Failed to Copy Script to\n" .. installPath .. "\nFrom\n" .. currentPath)
        return
    end
    local added, key = addHotkey()
    if not added and key then
        askUser("ERROR", "Failed to Add Hotkey\n" .. key)
        return
    elseif not added then
        return
    end
    askUser("SUCCESS",
        [[Installed Script and Added Hotkey Successfully
----------------------------------------
Installed To: ]] .. installPath .. [[

----------------------------------------
Hotkey Added: ]] .. key .. [[

----------------------------------------
Please Restart Davinci]])
end

if not SCRIPT_INSTALLED then
    installScript()
end

print("Installed!")
print("Removing Installing Variables!")
key = nil
fu = nil
comp = nil
installPath = nil
currentPath = nil
userTbl = nil
defaultHotkey = nil
UserPath = nil
newPath = nil
SCRIPT_INSTALLED = nil
collectgarbage('collect')
