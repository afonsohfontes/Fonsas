addon,ns = ...
-- Initilize setup
Fonsas.kbTable_master = {}
local spamAura = ""
local spamCount = 0
local updated = false

-- Load custom options
local shiftMod = "S-"
local ctrlMod = "C-"
local altMod = "A-"
local btnMouse = "MB-"
local shiftMouse = "SM-"
local ctrlMouse = "CM-"
local altMouse = "AM-"
local crtog1 = true
local creplace1 = "NUMPAD"
local crwith1 = "N-"
local crtog2 = true
local creplace2 = "MOUSEWHEEL"
local crwith2 = "MW"
local crtog3 = false
local creplace3 
local crwith3 

-- Function to parse macros
local function macroParse(actionID, spellId)
    auraName = GetSpellInfo(spellId)
    -- check if valid Macro
    local _, _, body = GetMacroInfo(actionID)
    if not body then return false; end
    
    
    -- look for simple macros, prio on spell macros vs item macros
    local macroSpell = body:match("/cast (.*)%s")
    if macroSpell then
        local _,_,_,_,_,_,macroID = GetSpellInfo(macroSpell)
        if macroID then
            local type = "spell"
            return macroID, type
        end
    end
    
    -- try to brute force a spellID using the spell that triggered the refresh
    if auraName then
        local _,_,_,_,_,_,provSpellID = GetSpellInfo(auraName)
        if provSpellID then
            local searchString = "/cast.*"..auraName
            local macroSpellCheck = body:find(searchString)
            if macroSpellCheck then
                local type = "spell"
                return provSpellID, type
            end
        end
    end
    
    -- look for /use strings if no spells are found
    local macroItem = body:match("/use (.*)%s")
    if macroItem then
        
        --  check if the /use is an equipment slot
        local slotCheck = tonumber(macroItem)
        if slotCheck and slotCheck < 20 then
            local itemID = GetInventoryItemID("PLAYER", slotCheck)
            if itemID then 
                local type = "item"
                return itemID, type
            end
        end
        
        -- check if the /use string is a valid item
        local _, itemlink = GetItemInfo(macroItem)
        if itemLink then
            local itemID = GetItemInfoFromHyperlink(itemLink)
            if itemID then
                local type = "item"
                return itemID, type
            end
        end
    end
    
    -- if nothing extracted return false
    return false
end


-- Main Function for populating keybind table
function Fonsas:kbTable_refresh(spellId)
    dominos = IsAddOnLoaded("Dominos") or nil
    auraName = GetSpellInfo(spellId)
    -- checks if master table is created before running
    if not Fonsas.kbTable_master then return; end
        
    for slotID=1, 180 do --GetNumBindings() do
        local actionType, actionID, _ = GetActionInfo(slotID)
        local noMouse = true        
        
        -- check if button is a macro and get spell / item ID
        if actionType == "macro" then
            local macroID, macroType = macroParse(actionID, auraName)
            if macroID then 
                actionID = macroID
                actionType = macroType
            end
        end
        
        -- NIL check actionID then populate keybind table
        -- keybinds beyond #156 haven't been test yet
        if actionID then
            local action = slotID
            local modact = 1+(action-1)%12
            local bindstring = ""
            if dominos and (action < 25 and action > 12) then
                bindstring = 'CLICK DominosActionButton'..slotID..':HOTKEY'
            elseif dominos and (action < 132 and action > 72) then
                bindstring = 'CLICK DominosActionButton'..slotID..':HOTKEY'
            elseif (action < 25 or action > 72) and (action <145) then
                bindstring = 'ACTIONBUTTON'..modact
            elseif action < 73 and action > 60 then
                bindstring = 'MULTIACTIONBAR1BUTTON'..modact
            elseif action < 61 and action > 48 then
                bindstring = 'MULTIACTIONBAR2BUTTON'..modact
            elseif action < 37 and action > 24 then
                bindstring = 'MULTIACTIONBAR3BUTTON'..modact
            elseif action < 49 and action > 36 then
                bindstring = 'MULTIACTIONBAR4BUTTON'..modact
            elseif action < 157 and action > 144 then
                bindstring = 'MULTIACTIONBAR5BUTTON'..modact
            end
            local keyBind = GetBindingKey(bindstring)

            if keyBind then
                
                -- truncates mouse button keybinds
                local mouseMod, mouseBtn, btnNum = keyBind:match("(.*)(BUTTON)(.*)")
                if mouseBtn then
                    noMouse = false
                    if custMouse then
                        if mouseMod == 'SHIFT-' then
                            mouseMod = shiftMouse
                        elseif mouseMod == 'CTRL-' then
                            mouseMod = ctrlMouse
                        elseif mouseMod == 'ALT-'then
                            mouseMod = altMouse
                        end
                        keyBind = mouseMod..btnMouse..btnNum
                    end
                end
                
                
                -- truncates other modifier keys
                if custMod and noMouse then
                    local keyMod,_,keyNum = keyBind:match("(.*)(-)(.*)")
                    if keyMod then
                        if keyMod == 'SHIFT' then
                            keyMod = shiftMod
                        elseif keyMod == 'CTRL' then
                            keyMod = ctrlMod
                        elseif keyMod == 'ALT'then
                            keyMod = altMod
                        end 
                        keyBind = keyMod..keyNum
                    end
                end
                
                -- custom string replace for uncommon keybinds
                if crtog1 then
                    local creplace = keyBind:gsub(creplace1, crwith1)
                    keyBind = creplace
                end
                if crtog2 then
                    local creplace = keyBind:gsub(creplace2, crwith2)
                    keyBind = creplace
                end
                if crtog3 then
                    local creplace = keyBind:gsub(creplace3, crwith3)
                    keyBind = creplace
                end
                
                -- items are stored with item name as key to bypass inventory requirement
                if actionType == 'item' then
                    actionID = GetItemInfo(actionID)
                end
                
                -- check for nil, changed or empty keybinds before populating
                if keyBind and actionID and Fonsas.kbTable_master[actionID] ~= keyBind then
                    Fonsas.kbTable_master[actionID] = keyBind
                    updated = true                  
                end
            end
        end
    end
    -- clear spamcheck to allow WAs to check for updates
    if updated then 
        spamAura = ""
        spamCount = 0
    end
end

