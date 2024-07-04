addon,ns = ...
local f1 = CreateFrame("Frame",nil,UIParent)
f1:SetWidth(1) 
f1:SetHeight(1) 
f1:SetAlpha(.90);
f1:SetPoint("TOPLEFT",100,-200)
f1.text = f1:CreateFontString(nil,"ARTWORK") 
f1.text:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
f1.text:SetPoint("LEFT",0,0)
f1:Hide()
local f2 = CreateFrame("Frame",nil,UIParent)
f2:SetWidth(1) 
f2:SetHeight(1) 
f2:SetAlpha(.90);
f2:SetPoint("TOPLEFT",100,-233)
f2.text = f2:CreateFontString(nil,"ARTWORK") 
f2.text:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
f2.text:SetPoint("LEFT",0,0)
f2:Hide()
local f3 = CreateFrame("Frame",nil,UIParent)
f3:SetWidth(1) 
f3:SetHeight(1) 
f3:SetAlpha(.90);
f3:SetPoint("TOPLEFT",100,-266)
f3.text = f3:CreateFontString(nil,"ARTWORK") 
f3.text:SetFont("Fonts\\ARIALN.ttf", 16, "OUTLINE")
f3.text:SetPoint("LEFT",0,0)
f3:Hide()
function Fonsas:Displayupdate(show, message)
    if show == 1 then
        f1.text:SetText(message)
        f1:Show()
      elseif show == 2 then
        f2.text:SetText(message)
        f2:Show()
    elseif show == 3 then
        f3.text:SetText(message)
        f3:Show()
    else
        f1:Hide()
        f2:Hide()
		f3:Hide()
    end
end
function Fonsas:PrintState()
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("Spells",string.format("%s:%30s:%s", key, value, color)) end

end

function Fonsas:PrintStateDruid()
-- output energy/combo points
if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("Spells",string.format("%s:%30s:%s", key, value, color)) end

end
function Fonsas:PrintStateRogue()
	-- output energy/combo points/next spell/cooldowns of main spells/AurasActive
	output = string.format("%s:%30s:%s", Fonsas:CurrentEnergy(), Fonsas:CurrentComboPoints(),Fonsas.nextSpell)
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("Rogue", output) end
end
	
function Fonsas:PrintStatePaladin()
	local s = Fonsas.Spells
	local auraArray = {}
	local spellArray = {s.Judgement, s.CrusaderStrike, s.GuardianofAncientKings, s.AvengingWrath, s.Inquisition, s.TemplarsVerdict, s.Exorcism, s.HammerofWrath, s.HolyWrath, s.Consecration, s.DivinePlea}
	local output = ''
	for _, spellId in ipairs(spellArray) do
		if spellId then
			local cooldown = -1
			local start, duration, enabled = GetSpellCooldown(spellId)
			if enabled == 0 then
				cooldown = duration
			elseif start > 0 and duration > 0 then 
				cooldown = start + duration - GetTime()
			end
			local name = GetSpellInfo(spellId)
			if cooldown and cooldown >0 then  name = string.format("|cffff6060%s|r",name) end
			output = output..(string.format("%s( %i ) | ", name,cooldown,enabled))
		end
	end
	--print (output)
	Fonsas:Displayupdate(1,output) 
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("APL",output) end

	output = ''
	a = self:GetPlayerBuffs()
	for _, buff in ipairs(a) do

        if buff.spellId then
			local name = buff.name
			local expire = buff.expirationTime
			if expire <0 or expire>100000 then 
				expire = -1 
			else
				expire = expire-GetTime()
			end

			output = output..(string.format("%s( %i ) | ", name,expire))
			--output = output..name.."( "..expire-GetTime().." )| "
		end
    end 
	--print(output)
	Fonsas:Displayupdate(2,output) 
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("APL",output) end
--	str = str:gsub("[\n\r]", " ")
	output = string.format("%s:%30s:%s", self:CurrentMana(), self:CurrentHolyPower(),GetSpellInfo(Fonsas.nextSpell))
	--print(output)
	Fonsas:Displayupdate(3,output) 
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("APL",output) end
	if DLAPI and Fonsas.DEBUGAPL then DLAPI.DebugLog("APL","=======================") end
	--print("=======================")
end

function Fonsas:VerifyAPL(APL)
	-- TODO go through APL and make sure all spells exist and all functions? exist
	print(APL)
end
