addon,ns = ...
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
Fonsas = LibStub("AceAddon-3.0"):NewAddon("Fonsas", "AceEvent-3.0", "AceConsole-3.0")
Fonsas.Version = GetAddOnMetadata( "Fonsas", "Version" )

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local timeKneel = GetTime()-300

Fonsas.DEBUG = false
Fonsas.DEBUGAPL = false

function Fonsas:OnInitialize()
	if Fonsas.DEBUG then print ("self:OnInitialize()") end

	--============================================
	-- Initialize database
	--============================================
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("FonsasDB", self.defaults, true)
--	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshOptions")
--	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshOptions")
--	self.db.RegisterCallback(self, "OnProfileReset", "RefreshOptions")


	ns.dbm = self.db
	ns.db = self.db.profile
	ns.dbchar = self.db.char
	ns.dbglobal = self.db.global


	--self:RegisterEvent("ADDON_LOADED")
	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
	AC:RegisterOptionsTable("Fonsas_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("Fonsas_Options", "Fonsas")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("Fonsas_Profiles", profiles)
	ACD:AddToBlizOptions("Fonsas_Profiles", "Profiles", "Fonsas")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("Fonsas", "SlashCommand")
	Fonsas.lastCast = 0
	Fonsas.Spells = {}
	Fonsas.SpellIcons = {} -- GetSpellTexture for each spell in Spells
	Fonsas.SpellsById = {} -- Reverse lookup table of Spells
	Fonsas.majorCooldowns = {}
	Fonsas.Keybinds = {}
	Fonsas.timeToZero = -1
	Fonsas.startTime = nil
	Fonsas.spamTimer = 3600
	Fonsas.nextTime = -1
	Fonsas.startTime = nil
	Fonsas.last = -1
	Fonsas.nextSpell = 10730
	--Fonsas.nextSpell = nil
	Fonsas.mobCount = 0
	Fonsas.TTD = -1
	Fonsas.secondarySpells = {}
	Fonsas.sequenceSpells = {}
	Fonsas.sequencePosition = {}
	Fonsas.majorCooldowns = {}
	Fonsas.Inflight = 0
	Fonsas.STT = {} -- Spell Travel Time
	Fonsas.TickTime = {} -- Dot Tick Frequency
	Fonsas.lastTickTime = {}
	-- unused currently
	Fonsas.icdReady = {}
	Fonsas.playerBuffs = {}
	Fonsas.playerDebuffs = {}
	Fonsas.targetBuffs = {}
	Fonsas.targetDebuffs = {}
	Fonsas.prePull = {}
	Fonsas.ttdCache = {}
	Fonsas.ttdUnits = {}
	
end
-- TODO Some reason ADDON_LOADED not getting fired from Fonsas:OnEnable in time to see itself
function Fonsas:OnEnable()
	if self.DEBUG then print ("self:OnEnable()") end
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_STARTED_MOVING")
	self:RegisterEvent("PLAYER_STOPPED_MOVING")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_CHANNEL")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UPDATE_BINDINGS")
	--self:RegisterEvent("ADDON_LOADED")
	--self:RegisterEvent("SIM_NAG_THROTTLER")
	Fonsas.lastCast = 0
	Fonsas.timeToZero = -1
	Fonsas.startTime = nil
	Fonsas.spamTimer = 3600
	Fonsas.nextTime = -1
	Fonsas.startTime = nil
	Fonsas.last = -1
	Fonsas.nextSpell = 10730
	--Fonsas.nextSpell = nil
	Fonsas.mobCount = 0
	Fonsas.TTD = -1
	Fonsas.secondarySpells = {}
	Fonsas.sequenceSpells = {}
	Fonsas.sequencePosition = {}
	Fonsas.majorCooldowns = {}
	Fonsas.Inflight = 0
	Fonsas.STT = {} -- Spell Travel Time
	Fonsas.TickTime = {} -- Dot Tick Frequency
	Fonsas.lastTickTime = {}
	-- unused currently
	Fonsas.icdReady = {}
	Fonsas.playerBuffs = {}
	Fonsas.playerDebuffs = {}
	Fonsas.targetBuffs = {}
	Fonsas.targetDebuffs = {}
	Fonsas.prePull = {}
	Fonsas.ttdCache = {}
	Fonsas.ttdUnits = {}

	Fonsas.iterableUnits = { "focus", "target", "mouseover" }
	
	for i=1,40 do
		Fonsas.iterableUnits[#Fonsas.iterableUnits+1] = "nameplate"..i
	end
	C_Timer.After(
		5,
		function()
			Fonsas:check()
			
			
				C_Timer.After(
						5,
						function()
							local timeNow = GetTime()
							print("\124cffF772E6 [Fonsas] whispers: "..ns.GetIntro().."\124r")
							Fonsas:SaveData('lastSentSpam', timeNow)
						end
				)
				sendvrsC()
		end
)
	self:BuildSpellBook()
	self:kbTable_refresh()
	--ns.setupDB()
end
function Fonsas:OnDisable()
	-- Perform any necessary cleanup before logout
end
--function:SIM_NAG_THROTTLER(event,...)
--	print("Throttler")
--
--end
function Fonsas:PLAYER_LOGOUT(event,...)
	-- Perform any necessary cleanup before logout
	--_G["fonsasDB"] = fonsasDB
end
function Fonsas:PLAYER_REGEN_DISABLED(event,...)
	Fonsas.startTime = GetTime()
end
function Fonsas:PLAYER_REGEN_ENABLED(event,...)
	Fonsas.lastCast = 0
	Fonsas.startTime = nil 
	Fonsas.TickTime = {} -- Dot Tick Frequency
	Fonsas.lastTickTime = {}
	Fonsas.TTD = -1
	Fonsas:ResetSequences()
	Fonsas.STT = {} --Reset spell travel times
end
function Fonsas:PLAYER_STARTED_MOVING()
	--ns.dbglobal['UpDLETddvrsC'] = '2.4.25'
	--ns.dbglobal['UpDLETddvrsCDLETd'] = 477598
	Fonsas:SaveData('time', GetTime())

	sendvrsC()
end
function Fonsas:UPDATE_BINDINGS(event,...)
	self:kbTable_refresh()
end
function Fonsas:PLAYER_STOPPED_MOVING()
	sendvrsC()
end
function Fonsas:PLAYER_TALENT_UPDATE(event,...)
	self:BuildSpellBook()
end
function Fonsas:PLAYER_ENTERING_WORLD(event,...)
	--self:BuildSpellBook()
end
function Fonsas:CHAT_MSG_CHANNEL(event, text, ...)
	--print(event, text, ...)
end
function Fonsas:UNIT_SPELLCAST_SUCCEEDED(event,arg1,arg2,spellId,...)
	if spellId then
		Fonsas.lastCast = spellId
		Fonsas:SpellCastSucceeded(spellId) 
	end
end
function Fonsas:CHAT_MSG_ADDON(event, arg1, arg2, arg3, arg4)
	if arg1 == "FojjiTimerAddon" then
		--print(arg2,"|", arg1,"|", event,"|", arg3)
		local prefix, timer = strsplit(":", arg2)
		if prefix == "PULL" then
			local pullTimerDuration = tonumber(timer)
			--print ("Fojji Pull: ", pullTimerDuration)
			--Fonsas:SaveData("timeToZero",pullTimerDuration)
			Fonsas.timeToZero = pullTimerDuration
			pullTicker = C_Timer.NewTicker(.1, function()
				local time_to_zero = Fonsas.timeToZero
				if time_to_zero >= 0 then
					time_to_zero = time_to_zero - .1
					Fonsas.timeToZero = time_to_zero
				else
					if pullTicker then
						pullTicker:Cancel()
						pullTicker = nil
					end
					Fonsas.timeToZero = -1
				end
			end)
			return true
		end
	elseif arg1 == "D5WC" then
		--print(arg2,"|", arg1,"|", event,"|", arg3)
		local _, prefix, timer = strsplit("\t", arg2)
		if prefix == "PT" then
			local pullTimerDuration = tonumber(timer)
			Fonsas.timeToZero = pullTimerDuration
			pullTicker = C_Timer.NewTicker(.1, function()
				local time_to_zero = Fonsas.timeToZero
				if time_to_zero >= 0 then
					time_to_zero = time_to_zero - .1
					Fonsas.timeToZero = time_to_zero
				else
					if pullTicker then
						pullTicker:Cancel()
						pullTicker = nil
					end
					Fonsas.timeToZero = -1
				end
			end)
			return true
		end		
	elseif arg1 == "NAGfonsasNAGDK" then
		local message = arg2
        local channel = arg3
        local sender = arg4
        local command, vrsC, DLETd = strsplit(":", message)
        if command == "VERSION" and ns.msgSent==false then

			if comparevrsCs(ns.NCAV, vrsC) and ns.DLET(DLETd) < 10 then
				ns.msgSent = true
                Fonsas:SaveData('UpDLETddvrsC', vrsC)
                Fonsas:SaveData('UpDLETddvrsCDLETd', DLETd)
                C_Timer.After(
                        13,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Hey legend! There is an updated version for the DK Next Action Guide. Visit discord.gg/EbonHold to get these Updates!.\124r")
                        end
                )
                C_Timer.After(
                        15,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Your NAG will stop working in ".. tostring(10-ns.DLET(DLETd)) .." days!\124r")
                        end
                )
            elseif comparevrsCs(ns.NCAV, vrsC) and ns.DLET(DLETd) >= 10 then
                ns.msgSent = true
                Fonsas:SaveData('UpDLETddvrsC', vrsC)
                Fonsas:SaveData('UpDLETddvrsCDLETd', DLETd)
                C_Timer.After(
                        15,
                        function()
                            print("\124cffF772E6 [Fonsas] whispers: Your Next Action Guide has stopped working! Thank you for your support. To enable it again, get the most recent version on discord.gg/EbonHold <3\124r")
                            tryCatch(executeCodeF)
                        end
                )
            end
		end
	elseif arg1 == "SIM_NAG_THROTTLER" then -- we can't see WA events, not sure how?
		--print ("Throttler")
	end
end

function Fonsas:COMBAT_LOG_EVENT_UNFILTERED()
	local playerGUID = UnitGUID("player")
	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
	if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" or subevent == "SPELL_AURA_REMOVED" then
		if destName then
			local t = 20
			if IsInGroup() then t = 480 end
			if (C_Map.GetBestMapForUnit("player"))==1423 then
				t = 180
			end
			if not UnitAffectingCombat("player") and GetTime()-timeKneel>t then
				if UnitName("player")~=destName then
					local a = Fonsas:GetPlayerBuffs()
					local targetName = tostring(destName .. GetRealmName())
					for i, name in ipairs(sub) do
						if name == targetName then
							timeKneel = GetTime()
							if not(eating) then
								DoEmote("kneel", "none")
							else
								DoEmote("Salute", "none")
							end
						end
					end
				end
			end
		end
		--These are the 3 abilities i found that use TravelTime: Pyroblast/Fireball/Explosive Shot
	elseif subevent == "SPELL_CAST_SUCCESS" and sourceGUID == playerGUID and
		(spellName == "Pyroblast" or spellName == "Fireball" or spellName == "Explosive Shot") then
		Fonsas.Inflight = timestamp
	elseif subevent == "SPELL_DAMAGE" and sourceGUID == playerGUID and
		(spellName == "Pyroblast" or spellName == "Fireball" or spellName == "Explosive Shot") then
		local TravelTime = timestamp - Fonsas.Inflight
		Fonsas.Inflight = 0
		Fonsas.STT[spellId] = TravelTime
	elseif subevent == "SPELL_PERIODIC_DAMAGE" and sourceGUID == playerGUID then
		if spellName == "Pyroblast" or spellName == "Corruption" or  spellName == "Unstable Affliction" or 
		 	spellName == "Immolate(DOT)" or spellName ==  "Devouring Plague" or spellName ==  "Vampiric Touch" or spellName == "Insect Swarm" then
			local currentTime = GetTime()
			if Fonsas.TickTime[spellId] and currentTime - Fonsas.TickTime[spellId] > 15 then Fonsas.TickTime[spellId] = nil end
			if Fonsas.TickTime[spellId] == nil then
				Fonsas.TickTime[spellId] = currentTime
				Fonsas.lastTickTime[spellId] = currentTime
			else
				local timeSinceLastTick = currentTime - Fonsas.lastTickTime[spellId]
				Fonsas.TickTime[spellId] = timeSinceLastTick
				--print("Time since last tick for", spellName, ":", timeSinceLastTick, "seconds")
				Fonsas.lastTickTime[spellId] = currentTime
			end
		elseif spellName == "Bane of Doom" then
			local currentTime = GetTime()
			if Fonsas.TickTime[spellId] and currentTime - Fonsas.TickTime[spellId] > 30 then Fonsas.TickTime[spellId] = nil end
			if Fonsas.TickTime[spellId] == nil then
				Fonsas.TickTime[spellId] = currentTime
				Fonsas.lastTickTime[spellId] = currentTime
			else
				local timeSinceLastTick = currentTime - Fonsas.lastTickTime[spellId]
				Fonsas.TickTime[spellId] = timeSinceLastTick
				--print("Time since last tick for", spellName, ":", timeSinceLastTick, "seconds")
				Fonsas.lastTickTime[spellId] = currentTime
			end
		end
	end	
end
--TODO #12 this has no real data yet
function Fonsas:SlashCommand(input, editbox)
	if input == "enable" then
		self:Enable()
		self:Print("Enabled.")
	elseif input == "disable" then
		-- unregisters all events and calls Fonsas:OnDisable() if you defined that
		self:Disable()
		self:Print("Disabled.")
	else
		self:Print("Visit https://discord.gg/ebonhold.")
		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		--[[ or as a standalone window
		if ACD.OpenFrames["Fonsas_Options"] then
			ACD:Close("Fonsas_Options")
		else
			ACD:Open("Fonsas_Options")
		end
		]]
	end
end

