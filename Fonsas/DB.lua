addon,ns = ...

local time = _G.time

local i = 26

local flag = 4
-- Event frame to handle events
local frame = CreateFrame("Frame")
local var1 = 2
--local timeKneel = GetTime()-300
ns.eating = false
ns.NCAV = tostring(var1)..'.'..tostring(flag)..'.'..tostring(i)
local c = 477766

function ns.DLET(DLETd)
    return floor((floor(time() / 3600) - tonumber(DLETd))/24)
end

ns.msgSent = false
ns.msgSentTime = GetTime() -30

local ADDON_PREFIX = "NAGfonsasNAGDK"
if not C_ChatInfo.IsAddonMessagePrefixRegistered(ADDON_PREFIX) then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
end

function sendvrsC()
    if GetTime() - ns.msgSentTime >= 59 then
        local vrsC = Fonsas:LoadData('UpDLETddvrsC')
        local message = ''
        if comparevrsCs(ns.NCAV, vrsC) then
            message = 'VERSION:'..vrsC..":"..tostring(c)
        else
            message = 'VERSION:'..ns.NCAV..":"..tostring(c)
        end
        local inInstance, instanceType = IsInInstance()

        if GetGuildInfo('player') then
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, "GUILD") end
        if UnitInRaid("player") and instanceType=='none' then
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, "RAID") end
        if UnitInParty("player") and instanceType=='none' then
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, "PARTY") end
        if inInstance then
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, "INSTANCE_CHAT")
        end
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, "YELL")
        ns.msgSentTime = GetTime()
    end
end

function comparevrsCs(currentvrsC, receivedvrsC)
    if currentvrsC and receivedvrsC then
        local currentMajor, currentMinor, currentPatch = strsplit(".", currentvrsC)
        local receivedMajor, receivedMinor, receivedPatch = strsplit(".", receivedvrsC)

        return tonumber(receivedMajor) > tonumber(currentMajor) or
                tonumber(receivedMinor) > tonumber(currentMinor) or
                tonumber(receivedPatch) > tonumber(currentPatch)
    else
        return false
    end
end

--[[function OUTDLETdDvrsC(currentvrsC, receivedvrsC)
    local currentMajor, currentMinor, currentPatch = strsplit(".", currentvrsC)
    local receivedMajor, receivedMinor, receivedPatch = strsplit(".", receivedvrsC)

    return tonumber(receivedMajor) < tonumber(currentMajor) or
    tonumber(receivedMinor) < tonumber(currentMinor) or
    tonumber(receivedPatch) < tonumber(currentPatch)
end]]


local thingsToHide = {
    "You kneel down.",
    "You stand at attention and salute.",
}
ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", function(frame, event, message, sender, ...)
    for i, v in ipairs(thingsToHide) do
        if message:find(v) then
            return true -- hide this message
        end
    end
end)

--local a = Fonsas:GetPlayerBuffs()

local function tryCatch(func)
    local status, err = pcall(func)
    if not status then
        print("\124cffF772E6 [Fonsas] whispers: Hey there. You also need the WA addon installed and the Next Action Guides WA Pack! You can find those (or look for help) on discord.gg/ebonhold\124r")
    end
end
local function executeCode()
    WeakAuras.ScanEvents("fonsas_alive1", false)
end
local function tryCatchF(func)
    local status, err = pcall(func)
    if not status then
        print("\124cffF772E6 [Fonsas] whispers: Hey there. You also need the WA addon installed and the Next Action Guides WA Pack! You can find those (or look for help) on discord.gg/ebonhold\124r")
    end
end
local function executeCodeF()
    WeakAuras.ScanEvents("fonsas_alive1", true)
end

local flagEn = true
function Fonsas:check()
    if Fonsas:LoadData('UpDLETddvrsC') then
		if comparevrsCs(ns.NCAV, Fonsas:LoadData('UpDLETddvrsC')) and not ns.msgSent then
            local vrsC = Fonsas:LoadData('UpDLETddvrsC')
            local DLETd = Fonsas:LoadData('UpDLETddvrsCDLETd')
            if comparevrsCs(ns.NCAV, vrsC) and ns.DLET(DLETd) < 10 then
                ns.msgSent = true
                Fonsas:SaveData('UpDLETddvrsC', vrsC)
                Fonsas:SaveData('UpDLETddvrsCDLETd', DLETd)
                tryCatch(executeCode)
                C_Timer.After(
                        18,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Hey legend! There is an updated version for the DK Next Action Guide. Visit discord.gg/EbonHold to get these Updates!.\124r")
                        end
                )
                C_Timer.After(
                        20,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Your NAG will stop working in ".. tostring(10-ns.DLET(DLETd)) .." days!\124r")
                        end
                )
            elseif comparevrsCs(ns.NCAV, vrsC) and ns.DLET(DLETd) >= 10 then
				ns.msgSent = true
                Fonsas:SaveData('UpDLETddvrsC', vrsC)
                Fonsas:SaveData('UpDLETddvrsCDLETd', DLETd)
                C_Timer.After(
                        20,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Your Next Action Guide has stopped working! Thank you for your support. To enable it again, get the most recent version on discord.gg/EbonHold <3\124r")
                            tryCatch(executeCodeF)
                            flagEn = false
                        end
                )
            end
        end
    end
	if flagEn then
		tryCatch(executeCode)
	end
end

function Fonsas:CheckEnabled()
    Fonsas:check()
    return flagEn
end