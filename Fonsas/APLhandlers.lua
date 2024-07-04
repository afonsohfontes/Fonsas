addon,ns = ...
-- Not used as we are modifying nextTime from inside aura_env.Update()
--function Fonsas:NextTime()
--    local gcdStart, gcdDuration = GetSpellCooldown(61304)
--    return math.max(GetTime(), gcdStart + gcdDuration)
--end
-- TODO implement all these functions. check the database of trinkets->buffid. check if a trinket equipped, if so
function Fonsas:SpellLastCast()
    return Fonsas.lastCast and Fonsas.lastCast or 0
end


--- self:StanceIsActive(stance)
---@param stance integer
---@return boolean
function Fonsas:StanceIsActive(stance)
    local curStance = GetShapeshiftForm()
    return (curStance == stance)
end

---APLValueDistanceToTarget
---This returns ranges in 5 yds increments(maybe best we can get atm?)
---@return integer maxRange to target
function Fonsas:DistanceToTarget()
    local RC = LibStub("LibRangeCheck-2.0")
    local _, maxRange = RC:GetRange('target')
    if not  maxRange then
        return false
    else
        return maxRange
    end
    
end

--- Fonsas:PrePull()
---@param currentTime integer 
---@return any spellId for PrePull[currentTime]
function Fonsas:PrePull(currentTime)
    local next = Fonsas.Spells.Pacify
    --local next = nil
    currentTime = tonumber(currentTime)
    
    for time,spellId in pairs(Fonsas.prePull) do
        if currentTime <= -time and currentTime > -time -1 then
            
            next = spellId
        end
    end
    
    return next
end

--============================================================================
-- APLAction* from wowsims

--- Action to do nothing
---@return boolean true
function Fonsas:DoNothing()
    return true
end
--- self:SpellCast(spellId)
---@param spellId integer
---@return boolean
function Fonsas:SpellCast(spellId)

    if not spellId then return false end
    if not Fonsas:CheckEnabled() then return false end
    if Fonsas:SpellCanCast(spellId) then
        if Fonsas.majorCooldowns[spellId] then
            Fonsas:AddSecondarySpell(spellId)
            return false
        else
            Fonsas.nextSpell = spellId
            return true
        end
    end
    
    return false
end
Fonsas.CastSpell = Fonsas.SpellCast

--- self:SpellCastSucceeded(spellId)
---@param spellId integer
---@return nil
function Fonsas:SpellCastSucceeded(spellId)
    for name, spells in pairs(Fonsas.sequenceSpells) do
        local nextSpell = spells[Fonsas.sequencePosition[name]]
        if spellId == nextSpell then
            Fonsas.sequencePosition[name] = Fonsas.sequencePosition[name] + 1
            if #spells < Fonsas.sequencePosition[name] then
                if Fonsas.DEBUG then print("Sequence " .. name .. " completed") end
            else
                if Fonsas.DEBUG then print("Advanced to next spell in sequence: " .. name .. " " .. GetSpellInfo(nextSpell) .. " -> " .. GetSpellInfo(spells[Fonsa.sequencePosition[name]])) end
            end
        end
    end
end
--- self:AddSecondarySpell(spellId)
---@param spellId integer
---@return nil
function Fonsas:AddSecondarySpell(spellId)
    for i=1,#Fonsas.secondarySpells do
        if Fonsas.secondarySpells[i] == spellId then
            return
        end
    end
    table.insert(Fonsas.secondarySpells, spellId)
end
function Fonsas:AutoCastOtherCooldowns()
    return true
end
--[[
function Fonsas:ChannelSpell(?spellId, ?target) --TODO #8
    return true
end

--TODO rest of these most likely not needed
function Fonsas:MultiDot(?spellId, ?target) 
    return true
end
function Fonsas:MultiShield(?spellId, ?target)
    return true
end
function Fonsas:AutoCastOtherCooldowns()
    return true
end
function Fonsas:Wait(duration) --not needed?
    return true
end
function Fonsas:WaitUntil(condition) --not needed?
    return true
end
function Fonsas:Schedule(time) --not needed?
    return true
end
]]

--- self:Sequence(name)
---@param name any? of spellId's to cast
---@return boolean Fonsas:SpellCast(item)
function Fonsas:Sequence(name, ...)
    local index = Fonsas.sequencePosition[name] or 1
    if select('#',...) < index then
        return false
    end
    
    if not Fonsas.sequenceSpells[name] then
        Fonsas.sequenceSpells[name] = {...}
    end
    
    Fonsas.sequencePosition[name] = index
    
    local item = Fonsas.sequenceSpells[name][index]
    return Fonsas:SpellCast(item)
end

function Fonsas:ResetSequences()
    Fonsas.sequencePosition = {}
    Fonsas.sequenceSpells = {}
    return true
end

function Fonsas:ResetSequence(name)
    Fonsas.sequencePosition[name] = nil
    Fonsas.sequenceSpells[name] = nil
    return true
end

--[[
--TODO fix this(it don't work)
function Fonsas:StrictSequence(name, ...) 
    local index = Fonsas.SequencePosition[name] or 1
    if select('#',...) < index then
        return false
    end    
    if not Fonsas.SequenceSpells[name] then
        Fonsas.SequenceSpells[name] = {...}
    end
    --TODO need to go through while sequence and cast from here to ensure all cast before exiting?
    for i=1,#Fonsas.SequenceSpells[name] do
        print("StrictSequence("..name..")" ..Fonsas.SequenceSpells[name][i])
        
        Fonsas:SpellCast(Fonsas.SequenceSpells[name][i])    
    end    
    return
    -- Fonsas.SequencePosition[name] = index
    -- local item = Fonsas.SequenceSpells[name][index]
    -- return Fonsas:SpellCast(item)
end

function Fonsas:ChangeTarget(newTarget) -- not needed?
    return true
end

--TODO #9 find way to show a cancel'd aura icon
function Fonsas:CancelAura(auraId) --not needed? unless we can maybe show the aura icon with an X through it w/overlay?
    return true
end

function Fonsas:ActivateAura(auraId) --not needed?
    return true
end

function Fonsas:TriggerICD(auraId) --not needed    
    return true
end
--]]

--============================================================================
-- APLValue* from wowsims
-- Function to determine current Eclipse phase for a Balance Druid
-- TODO TEST
function CurrentEclipsePhase()
    local eclipsePower = UnitPower("player", SPELL_POWER_ECLIPSE)
    if eclipsePower > 0 then
        return "Solar"
    elseif eclipsePower < 0 then
        return "Lunar"
    else
        return "Neutral"
    end
end

-- =========================================
-- Encounter Values
function Fonsas:CurrentTime()
    local startTime = Fonsas.startTime
    local combatTime = startTime and GetTime() - startTime or 0
    return combatTime
end

function Fonsas:RemainingTime() 
    return Fonsas.TTD or 8888
end
--TODO #6 This needs some mathing. my brain melting lol
function Fonsas:RemainingTimePercent() 
    if not Fonsas.startTime then return 0 end
    local remainingPercent = CalculateRemainingTimePercent(Fonsas:RemainingTime(), Fonsas.startTime)
    --print(string.format("Remaining time: %.2f%%", remainingPercent))
    return remainingPercent and remainingPercent or 0
end

function CalculateRemainingTimePercent(timeToDie, startTime)
    local currentTime = Fonsas:CurrentTime() -- GetTime() -- Get the current time in seconds since the start of the fight
    local elapsedTime = currentTime - startTime -- Calculate how much time has passed since the fight started
    local remainingTime = timeToDie - elapsedTime -- Calculate the remaining time until the fight ends
    local totalTime = timeToDie - startTime -- Calculate the total time duration of the fight
    
    local remainingPercent = (remainingTime / totalTime) * 100 -- Calculate the remaining time as a percentage
    -- Ensure the percentage is within valid range (0-100)
    remainingPercent = math.max(0, math.min(100, remainingPercent))
    --print(elapsedTime, remainingTime, totalTime, remainingPercent)
    
    return remainingPercent
end
--[[ TODO
Fonsas:CurrentTimePercent() -- TODO    
]]
--- func desc
---@return integer Fonsas.mobCount or 0
function Fonsas:NumberTargets()
    return Fonsas.mobCount or 0
end

--- func desc
---@return integer # of mobs around us
function Fonsas:MobsAround()
    local count = 0
   for i = 1, 40 do
       local unit = "nameplate"..i
       if UnitCanAttack("player", unit)
       and CheckInteractDistance(unit, 3)
       then
           count = count + 1
       end
   end
    return count
end

--- func desc
---@return boolean (healthPerc <= threshold)
function Fonsas:IsExecutePhase(threshold)
    local healthPerc = (UnitHealth("target")/UnitHealthMax("target"))*100
    return (healthPerc <= threshold)
end

local function IsChanneling(unit, spellId)
    local spellName, _, _, _, _, _, _, currentSpellID = UnitChannelInfo(unit)
    if currentSpellID and currentSpellID == spellId then
        return true
    end
    return false


end
local function IsCasting(unit, spellId)
    local spellName, _, _, _, _, _, currentSpellID = UnitCastingInfo(unit)
    if currentSpellID and currentSpellID == spellId then
        return true
    end
    return false

end
--TODO test these out, need something casting something to test
---APLValueBossSpellIsCasting
---@param spellId any
---@return boolean
function Fonsas:BossSpellIsCasting(spellId)
    if IsCasting("target", spellId) or IsChanneling("target", spellId) then
        return true
    end
    return false
end

--TODO test these out, need something casting something to test
---APLValueBossSpellTimeToReady
---@param spellId any
---@return integer seconds till spell ready or 0
function Fonsas:BossSpellTimeToReady(spellId)
    local spellStart, spellDuration = GetSpellCooldown(spellId)

    -- Check if the spell's cooldown is active
    if spellStart > 0 and spellDuration > 0 then
        local currentTime = GetTime()
        local cooldownEnd = spellStart + spellDuration
        local timeToReady = cooldownEnd - currentTime
    
        -- Ensure timeToReady does not go negative
        timeToReady = math.max(0, timeToReady)
    
        return timeToReady
    end

    -- If spell is not on cooldown, return 0 (ready)
    return 0
end
--- APLValueUnitIsMoving
---@return boolean
function Fonsas:UnitIsMoving()
    speed, _ = GetUnitSpeed("player")
    return speed > 0
end

-- =========================================================================
-- Resource values
--- APLValueCurrentHealth
---@return integer UnitHealth("player")
function Fonsas:CurrentHealth()
    return UnitHealth("player")
end
function Fonsas:CurrentHealthPercent()
    local healthPerc = (UnitHealth("player")/UnitHealthMax("player"))*100
    return healthPerc
end
function Fonsas:CurrentMana()
    return UnitPower("player", Enum.PowerType.Mana)
end
function Fonsas:CurrentManaPercent()
    local healthPerc = (UnitPower("player", Enum.PowerType.Mana)/UnitPowerMax("player", Enum.PowerType.Mana))*100
    return healthPerc
end
function Fonsas:CurrentRage()
    return UnitPower("player",Enum.PowerType.Rage)
end
function Fonsas:CurrentEnergy()
    return UnitPower("player",Enum.PowerType.Energy)
end
function Fonsas:CurrentComboPoints()
    return UnitPower("player",Enum.PowerType.ComboPoints)
end
function Fonsas:CurrentRunicPower()
    return UnitPower("player",Enum.PowerType.RunicPower)
end
function Fonsas:CurrentFocus()
    return UnitPower("player",Enum.PowerType.Focus)
end
function Fonsas:CurrentSoulShards()
    return UnitPower("player",Enum.PowerType.SoulShards)
end
function Fonsas:CurrentLunarPower()
    return UnitPower("player",Enum.PowerType.LunarPower)
end
function Fonsas:CurrentHolyPower()
    return UnitPower("player",Enum.PowerType.HolyPower)
end
--New power type since Cataclysm. Known uses: sound level on Atramedes, corruption level on Cho'gall, consumption level while in Iso'rath.
function Fonsas:CurrentAlternate()
    return UnitPower("player",Enum.PowerType.Alternate)
end
function Fonsas:CurrentMaelstrom()
    return UnitPower("player",Enum.PowerType.Maelstrom)
end
function Fonsas:CurrentChi()
    return UnitPower("player",Enum.PowerType.Chi)
end

-- =========================================================================
-- Rune Resource values
function Fonsas:CurrentRuneCount(runeType)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local total = 0
    for i=1,6 do
        local rt = GetRuneType(i)
        if (rt == runeType or rt == Fonsas.RuneType.Death) and self:CurrentRuneActive(i) then
            total = total + 1
        end
    end
    return total
end
function Fonsas:NumNonDeathRunes(runeType)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local total = 0
    for i=1,6 do
        if GetRuneType(i) == runeType and self:RuneReady(i) then
            total = total + 1
        end
    end
    return total
end
Fonsas.CurrentNonDeathRuneCount = Fonsas.NumNonDeathRunes
function Fonsas:CurrentRuneDeath(runeSlot)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    return (GetRuneType(runeSlot) == "Death")
end
function Fonsas:CurrentRuneActive(runeSlot) 
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local _,_,active = GetRuneCooldown(runeSlot)
    return active
end
function Fonsas:RuneReady(index)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local start, duration = GetRuneCooldown(index);
    return start + duration <= Fonsas.nextTime
end
function Fonsas:NumRunes(runeType)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local total = 0
    for i=1,6 do
        local rt = GetRuneType(i)
        if (rt == runeType or rt == Fonsas.RuneType.Death) and self:RuneReady(i) then
            total = total + 1
        end
    end
    return total
end
--[[ 
function Fonsas:RuneCooldown()

end    
]]
function Fonsas:NextRuneCooldown(runeType)
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local cooldown = 10
    
    for i=1,6 do
        local rt = GetRuneType(i)
        if rt == runeType or rt == Fonsas.RuneType.Death then
            local start, duration = GetRuneCooldown(i)
            cooldown = math.min(cooldown, start + duration - Fonsas.nextTime)
        end
    end
    --print("cooldown: ", cooldown)
    return math.max(cooldown, 0)
end
function Fonsas:RuneSlotCooldown(runeSlot) 
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local runeOnCD = GetRuneCooldown(runeSlot)
    return runeOnCD
end
function Fonsas:RuneGrace(runeType) -- TODO
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local grace = 2.5
    for i=1,6 do
        local rt = GetRuneType(i)
        if rt == runeType or rt == Fonsas.RuneType.Death then
            local start, duration, runeReady = GetRuneCooldown(i)
            --print(runeType[i], start, duration, runeReady)
            if not runeReady and duration-(Fonsas.nextTime-start) < 2.5 then 
                grace = math.min(grace, duration - (Fonsas.nextTime-start) )              
            end
        end
    end
    return math.max(grace, 0)
end
function Fonsas:RuneSlotGrace(runeSlot) -- TODO 
    if UnitClassBase("player") ~= "DEATHKNIGHT" then return 0 end
    local grace = 2.5
    local start, duration, runeReady = GetRuneCooldown(runeSlot)
    --        print(runeType[i], start, duration, runeReady)
    if not runeReady and duration-(Fonsas.nextTime-start) < 2.5 then 
        grace = math.min(grace, duration - (Fonsas.nextTime-start) )       
    end
    return math.max(grace, 0)   
end

-- =========================================================================
-- GCD values
function Fonsas:GCDIsReady()
    if self:SpellCanCast(Fonsas.Spells.GCD) then
        return true
    end
    return false
end
function Fonsas:GCDTimeToReady()
    local start,duration = GetSpellCooldown(Fonsas.Spells.GCD)
    return (start + duration - GetTime())
end

-- =========================================================================
-- Autoattack values
function Fonsas:AutoTimeToNext() 
    local start,duration = GetSpellCooldown(Fonsas.Spells.AutoAttack)
    return (start + duration - GetTime())
end


-- =========================================================================
-- Spell values
--- APLValueSpellIsKnown
---@param spellId integer
---@return boolean IsKnownSpell(spellId)
function Fonsas:SpellIsKnown(spellId)
    if not spellId then return false end

    return IsKnownSpell(spellId)
end

--- APLValueSpellCanCast
---@param spellId integer
---@return boolean HasResource and SpellIsReady
function Fonsas:SpellCanCast(spellId)
    if not spellId then return false end
    local class = UnitClassBase("player")
    if class == "DEATHKNIGHT" then
        if not self:HasRunicPower(spellId) then
            return false
        end
        --TODO believe this can be removed?
        -- Rune Strike has no cooldown, it becomes usable after a dodge or parry
        if spellId == Fonsas.Spells.RuneStrike then
            local usable = IsUsableSpell(spellId)
            if not usable or IsCurrentSpell(Fonsas.Spells.RuneStrike) then
                return false
            end
        end
    elseif class == "WARRIOR" then
        if not HasRage(spellId) then
            return false
        end
    elseif class == "DRUID" then
        local formID = GetShapeshiftFormId()
        if formId == 1 or formId == 5 then 
            if not self:HasEnergy(spellId) or not self:HasComboPoints(spellId) then
                return false
            end
        end
    elseif class == "ROGUE" then
        if not self:HasEnergy(spellId) or not self:HasComboPoints(spellId) then
            return false
        end
    elseif class == "WARLOCK" then
        if not self:HasSoulShards(spellId) then
            return false
        end
    elseif class == "PALADIN" then
        if not self:HasMana(spellId) or not self:HasHolyPower(spellId) then
            return false
        end
    end
    return self:SpellIsReady(spellId)
end
--- APLValueSpellIsReady
---@param spellId integer
---@return boolean start + duration <= Fonsas.nextTime
function Fonsas:SpellIsReady(spellId)
    if not spellId then return false end
    local start, duration = GetSpellCooldown(spellId)
    return start + duration <= Fonsas.nextTime
end

--- APLValueSpellTimeToReady
---@param spellId integer
---@return boolean start + duration - Fonsas.nextTime
function Fonsas:SpellTimeToReady(spellId)
    if not spellId then return -1 end
    local start, duration = GetSpellCooldown(spellId)
    
    if start == 0 then
        return 0
    end
    
    return start + duration - Fonsas.nextTime
end

--- APLValueSpellCastTime
---@param spellId integer
---@return integer castTime
function Fonsas:SpellCastTime(spellId)
    if not spellId then return 0 end
    local _,_,_,castTime = GetSpellInfo(spellId)    
    return castTime
end

function Fonsas:ChannelClipDelay() --TODO
    return 0
end

--TODO don't think we can determine this w/o restricted code
function Fonsas:FrontOfTarget()
    return true
end

--- APLValueSpellTravelTime
---@param spellId integer
---@return number Fonsas.STT[spellId] and Fonsas.STT[spellId] or 0
function Fonsas:SpellTravelTime(spellId)
    if not spellId then return 0 end

    return Fonsas.STT[spellId] and Fonsas.STT[spellId] or 0
end
--[[
function Fonsas:SpellCPM(spellId)
end

]]
--- APLValueSpellIsChanneling
--- Returns if a specific spell is being channel, does it need to be just any spell being channeled?
---@param spellId integer
---@return boolean
function Fonsas:SpellIsChanneling(spellId) 
    local spell,_,_,_,_,_,_,_,Id = UnitCastingInfo("player")
    if spell == "CHANNELING" then
        if spellId == Id then
            return true
        end
    end
    return false
end

--TODO
function Fonsas:SpellChanneledTicks(spellId)
    return 0
end

--TODO Don't recall seeing any APL's use this yet
function Fonsas:SpellCurrentCost(spellId)
    return 0
end

function Fonsas:DotTickFrequency(spellId)
    --TODO maybe we can make handlers for each one instead so we only watch the spells we calling for? not sure possible sounds it
    if not spellId and Fonsas.TickTime[spellId] then return 0 end

    return Fonsas.TickTime[spellId]
end

----
--- APLValueSpellChannelTime
--- TODO: Not sure this is obtainable until spell is cast, so would only work after cast?
---@param spellId integer
---@return boolean
function Fonsas:SpellChannelTime()
    local _,_,_,_,endTimeMS = UnitChannelInfo("player")
    local finish = endTimeMS/1000 - GetTime()
    return finish
end

--- APLValueSpellIsQueued
---@param spellId integer
---@return boolean
function Fonsas:SpellIsQueued(spellId)
    if Fonsas.nextSpell == spellId then
        return true
    end    
    for i=1,#Fonsas.secondarySpells do
        if Fonsas.secondarySpells[i] == spellId then
            return true
        end
    end    
    return false
end

--- APLValueSpellHasRunicPower
---@param spellId integer
---@return boolean not cost or cost <= UnitPower("player", Enum.PowerType.RunicPower)
function Fonsas:HasRunicPower(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)
            if v.type == Enum.PowerType.RunicPower then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)
    
    return not cost or cost <= UnitPower("player", Enum.PowerType.RunicPower)
end
function Fonsas:HasRage(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)            
            if v.type == Enum.PowerType.Rage then
                return math.max(v.cost, 0) -- Negative is returned for spells that generate power
            end
    end)    
    return not cost or cost <= UnitPower("player", Enum.PowerType.Rage)
end
function Fonsas:HasMana(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)            
            if v.type == Enum.PowerType.Mana then
                return math.max(v.cost, 0) -- Negative is returned for spells that generate power
            end
    end)    
    return not cost or cost <= UnitPower("player", Enum.PowerType.Mana)
end
function Fonsas:HasEnergy(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)
            if v.type == Enum.PowerType.Energy then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)
    return not cost or cost <= UnitPower("player", Enum.PowerType.Energy)
end
--- APLValueSpellHasRunicPower
--- TODO costTable for rogue/druid abilities only returning ENERGY no COMBO_POINTS
---@param spellId integer
---@return boolean not cost or cost <= UnitPower("player", Enum.PowerType.ComboPoints)
function Fonsas:HasComboPoints(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)            
            if v.type == Enum.PowerType.ComboPoints then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)
    local class = UnitClassBase("player")

    if class == "ROGUE" and (
        spellId == Fonsas.Spells.SliceandDice  
        or spellId == Fonsas.Spells.Rupture
        or spellId == Fonsas.Spells.Envenom
        or spellId == Fonsas.Spells.Recuperate
        or spellId == Fonsas.Spells.KidneyShot
        or spellId == Fonsas.Spells.ExposeArmor
        or spellId == Fonsas.Spells.Eviscerate
        or spellId == Fonsas.Spells.DeadlyThrow
    ) then
        cost = 1

    end
    return not cost or cost <= UnitPower("player", Enum.PowerType.ComboPoints)
end
function Fonsas:HasSoulShards(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)
            if v.type == Enum.PowerType.SoulShards then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)    
    return not cost or cost <= UnitPower("player", Enum.PowerType.SoulShards)
end
function Fonsas:HasLunarPower(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)            
            if v.type == Enum.PowerType.LunarPower then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)    
    return not cost or cost <= UnitPower("player", Enum.PowerType.LunarPower)
end
function Fonsas:HasHolyPower(spellId)
    local costTable = GetSpellPowerCost(spellId);
    if costTable == nil then
        return 0
    end
    local cost = table.foreach(costTable, function(_, v)            
            if v.type == Enum.PowerType.HolyPower then
                return math.max(v.cost, 0); -- Negative is returned for spells that generate power
            end
    end)
    if spellId == Fonsas.Spells.Zealotry then
        cost = 3
    end
    return not cost or cost <= UnitPower("player", Enum.PowerType.HolyPower)
end

-- =========================================================================
-- Aura values

--- APLValueAuraIsKnown
--- TODO not sure if we need a seperate one and how to look them up(check by items?)
---@param spellId integer
---@return boolean self:SpellIsKnown(spellId)
function Fonsas:AuraIsKnown(spellId)
    return Fonsas:SpellIsKnown(spellId)
end

--- APLValueAuraIsActive
--- TODO cache the lookups maybe?
---@param spellId integer
---@return boolean
function Fonsas:AuraIsActive(spellId)
    local found = false
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return false
    end
    local spell,_ = self:FindAuraByName(spellName, "player")
    
    if not spell then
        return false
    end
    return true
end
Fonsas.AuraIsActiveWithReactionTime = Fonsas.AuraIsActive
-- TODO
--[[function Fonsas:AuraIsActiveWithReactionTime(auraId) --TODO? #3 
    return true
end
]]
function Fonsas:AuraRemainingTime(spellId)
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return 0
    end
    local _,_,_,_,_,expires = self:FindAuraByName(spellName, "player")
    
    if not expires then
        return 0
    end
    
    return expires - Fonsas.nextTime
end
function Fonsas:AuraNumStacks(spellId)
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return 0
    end
    local _,_,count = Fonsas:FindAuraByName(spellName, "player")
    if not count then
        return 0
    end
    return count
end

function Fonsas:AuraShouldRefresh(spellId, overlap)
    if self:AuraRemainingTime(spellId) < overlap then
        return true
    end
    return false
end

function Fonsas:FindAuraByName(name, unit)
    if unit == "player" then
        local a=0; while UnitAura("player", a+1, "HELPFUL") do a=a+1 end
        for i=1,a do
            local nameSearch, icon, count, debuffType, duration, expirationTime,
            unitCaster, isStealable, shouldConsolidate, spellId, foo = UnitAura("player", i, "HELPFUL")
            if nameSearch == name then
                return nameSearch, icon, count, debuffType, duration, expirationTime
            end
        end
    elseif unit == "target" then
        local a=0; while UnitAura(unit, a+1, "PLAYER|HARMFUL") do a=a+1 end
        for i=1,a do
            local nameSearch, icon, count, debuffType, duration, expirationTime,
            unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "PLAYER|HARMFUL")
            if nameSearch == name then
                return nameSearch, icon, count, debuffType, duration, expirationTime
            end
        end
    elseif unit == "pet" then
        local a=0; while UnitAura(unit, a+1, "HELPFUL") do a=a+1 end
        for i=1,a do
            local nameSearch, icon, count, debuffType, duration, expirationTime,
            unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HELPFUL")
            if nameSearch == name then
                return nameSearch, icon, count, debuffType, duration, expirationTime
            end
        end
    end
    return
end

function Fonsas:TrinketAura(itemId)
    for _, trinketInfo in ipairs(trinketBuffs) do
        if trinketInfo.itemId == itemId then
            return trinketInfo.buffId
        end
    end
end
function Fonsas:TrinketIsActive(itemId)
    for _, trinketInfo in ipairs(trinketBuffs) do
        if trinketInfo.itemId == itemId then
            return Fonsas:AuraIsActive(trinketInfo.buffId)
        end
    end
    return false
end
function Fonsas:TrinketIsReady(itemId)
    for _, trinketInfo in ipairs(trinketBuffs) do
        if trinketInfo.itemId == itemId then
            return Fonsas:TrinketTimeToReady(trinketInfo.buffId)
        end
    end
    return false
end

function Fonsas:TrinketTimeToReady(itemId)
    return false
end
function Fonsas:TrinketIsKnown(itemId)
    --check trinket slots if trinket equipped
    return trinketWorn(itemId)
end
local function trinketWorn(itemId, itemSlot)
    if not itemId then return false end
    
    return IsEquippedItem(itemId)
end

function Fonsas:GetICD(spellId)
    if spellId == Fonsas.Spells.UnholyMight then
        return 45
    end
    return Fonsas:GetICDTrinket(spellId)
end

function Fonsas:GetICDTrinket(buffId)
    for _, trinketInfo in ipairs(trinketBuffs) do
        if trinketInfo.buffId == buffId then
            return trinketInfo.ICD
        end
    end
end

function Fonsas:AuraRemainingICD(spellId)
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return 0
    end
    local _,_,_,_,duration,expires = Fonsas:FindAuraByName(spellName, "player")
    local key = 'icd_'..spellName

    local icdReady = 0
    if expires then
        icdReady = expires - duration + Fonsas:GetICD(spellId)
        Fonsas.icdReady[spellId] = icdReady
        Fonsas:SaveData(key, icdReady)
    else
        local a = Fonsas:LoadData(key)
        if Fonsas.icdReady[spellId] then
            icdReady = Fonsas.icdReady[spellId]
        elseif a then
            icdReady = a
        else
            return 0
        end
    end
    return icdReady - Fonsas.nextTime
end
Fonsas.AuraInternalCooldown = Fonsas.AuraRemainingICD

function Fonsas:AuraICDIsReady(spellId)
    local timeNow = GetTime()
    local remain = Fonsas:AuraRemainingICD(spellId)
    return remain <= Fonsas.nextTime - timeNow    
end
-- TODO Our next time already includes the .3 "reaction time" so should be good
Fonsas.AuraICDIsReadyWithReactionTime = Fonsas.AuraICDIsReady

-- =========================================================================
-- Dot values
--- APLValueDotIsActive
---@param spellId integer
---@return boolean 
function Fonsas:DotIsActive(spellId)
    local found = false
    local spell
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return false
    end
    local spell,_ = self:FindAuraByName(spellName, "target")

    if not spell then
        return false
    end
    return true
end
--- APLValueDotRemainingTime
---@param spellId integer
---@return number expires - Fonsas.nextTime
function Fonsas:DotRemainingTime(spellId)
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return 0
    end
    local _,_,_,_,_,expires = Fonsas:FindAuraByName(spellName, "target")
    
    if not expires then
        return 0
    end
    return expires - Fonsas.nextTime
end
--- APLValueDotNumStacks
---@param spellId integer
---@return integer # of stacks of DOT
function Fonsas:DotNumStacks(spellId)
    local spellName = GetSpellInfo(spellId)
    if not spellName then
        return 0
    end
    local _,_,count = Fonsas:FindAuraByName(spellName, "target")    
    if not count then
        return 0
    end
    return count
end
function Fonsas:DotShouldRefresh(spellId, overlap)
    if Fonsas:DotRemainingTime(spellId) < overlap then
        return true
    end
    return false
end

-- =========================================================================
-- Sequence values
--- APLValueSequenceIsComplete
---@param name any
---@return boolean all spells in sequence have been cast
function Fonsas:SequenceIsComplete(name)     
    if Fonsas.sequenceSpells[name] and #Fonsas.sequenceSpells[name] >= Fonsas.sequencePosition[name] then
        return false
    end
    return true
end

---APLValueSequenceIsReady
---@param name any
---@param ... any 
---@return boolean
function Fonsas:SequenceIsReady(name,...)
    local sequence = {...}
    for i=1,#sequence do
        if not Fonsas.SpellCanCast(sequence[i]) then return false end
    end
    return true
end

--- AplValueSequenceTimeToReady
---TODO-TEST(Add #4 check for greatest time to cast all spells in sequence)
---@return any ttr time to ready 
function Fonsas:SequenceTimeToReady(sequenceName, ...) 
    local sequence = {...}
    local maxttr = 0
    for i=1,#sequence do
        local ttr = Fonsas:SpellTimeToReady(sequence[i])
        if ttr > maxttr then ttr = maxttr end
    end
    return ttr
end

--[[
-- =========================================================================
-- Class or Spec-specific values maybe unused?
function Fonsas:CatExcessEnergy() 
    return 0
end
function Fonsas:FeralNewSavageRoarDuration() 
    return (Fonsas:CurrentComboPoints() * 5 + 9)
end
function Fonsas:TotemRemainingTime(totemType)
    return 0
end
function Fonsas:WarlockShouldRecastDrainSoul() 
    --if time to die is less than 5 and #soul shards < 5  return true
    return false
end
Fonsas:WarlockShouldRefreshCorruption(unit)
    --? if ttd < duration refresh?
    return true
end
--]]

--- APLValueInputDelay
--- enh shaman uses this
---@param spellId integer
---@return integer Fonsas.db.profile.InputDelay
function Fonsas:InputDelay()
    if not Fonsas.db.profile.InputDelay then return 300 end
    return Fonsas.db.profile.InputDelay
end

--- GetPlayerBuffs
--- creates array of buffs on player
---@return any buffs 
function Fonsas:GetPlayerBuffs()
	local buffs = {}
	ns.eating = false
	local eat = false
	for i = 1, 40 do
		local name, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", i)
		if not name then break end
		table.insert(buffs, {
			spellId = spellId,
			name = name,
			expirationTime = expirationTime
		})
		if expirationTime-GetTime()<31 and expirationTime-GetTime()>1 then eat = true end
	end
	if eat then ns.eating= true end
	return buffs
end

--- GetPlayerDebuffs
--- creates array of debuffs on player
---@return any buffs 
function Fonsas:GetPlayerDebuffs()
    local debuffs = {}
    for i = 1, 40 do
        local name, _, _, _, _, expirationTime, _, _, _, spellId = UnitDebuff("player", i)
        if not name then break end
        
        table.insert(debuffs, {
            spellId = spellId,
            name = name,
            expirationTime = expirationTime
        })
    end
    return debuffs
end

--- GetTargetDebuffs
--- creates array of debuffs on target
---@return any buffs 
function Fonsas:GetTargetDebuffs()
	local debuffs = {}
	for i = 1, 40 do
		local name, _, _, _, _, expirationTime, _, _, _, spellId = UnitDebuff("target", i)
		if not name then break end
		table.insert(debuffs, {
			spellId = spellId,
			name = name,
			expirationTime = expirationTime
		})

	end
	return debuffs
end

--- GetTargetBuffs
--- creates array of buffs on target
---@return any buffs 
function Fonsas:GetTargetBuffs()
	local buffs = {}
	for i = 1, 40 do
		local name, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("target", i)
		if not name then break end
		table.insert(buffs, {
			spellId = spellId,
			name = name,
			expirationTime = expirationTime
		})

	end
	return buffs
end

--- Time to die refresh 
function Fonsas:TTDRefresh_f()
    local currentTime = GetTime()
    local checkedUnits = {}
    local historyCount = 100
    local historyTime = 10
    
    for _, unit in ipairs(Fonsas.iterableUnits) do
        if UnitExists(unit) then
            local GUID = UnitGUID(unit)
            if not checkedUnits[GUID] then
                checkedUnits[GUID] = true
                local health = UnitHealth(unit)
                local maxHealth = UnitHealthMax(unit)
                local healthPercentage = health ~= -1 and maxHealth ~= -1 and health / maxHealth * 100
                -- Check if it's a valid unit
                if UnitCanAttack("player", unit) and healthPercentage < 100 then
                    local unitTable = Fonsas.ttdUnits[GUID]
                    -- Check if we have seen one time this unit, if we don't then initialize it.
                    if not unitTable or healthPercentage > unitTable[1][1][2] then
                        unitTable = { {}, currentTime }
                        Fonsas.ttdUnits[GUID] = unitTable
                    end
                    local values = unitTable[1]
                    local time = currentTime - unitTable[2]
                    -- Check if the % HP changed since the last check (or if there were none)
                    if #values == 0 or healthPercentage ~= values[1][2] then
                        local value
                        local lastIndex = #Fonsas.ttdCache
                        -- Check if we can re-use a table from the cache -- Buds: i have doubt on the value of reusing table, with the high cost of tinsert on 1st index
                        if lastIndex == 0 then
                            value = { time, healthPercentage }
                        else
                            value = Fonsas.ttdCache[lastIndex]
                            Fonsas.ttdCache[lastIndex] = nil
                            value[1] = time
                            value[2] = healthPercentage
                        end
                        table.insert(values, 1, value)
                        local n = #values
                        -- Delete values that are no longer valid
                        while (n > historyCount) or (time - values[n][1] > historyTime) do
                            Fonsas.ttdCache[#Fonsas.ttdCache + 1] = values[n]
                            values[n] = nil
                            n = n - 1
                        end
                    end
                end
            end
        end
    end
end

--- TimeToX_f
--- Calculates time to X health using data from TTDRefresh_f
---@param guid any
---@param percentage integer
---@param minSamples integer
---@return number seconds 
function Fonsas:TimeToX_f(guid, percentage, minSamples)
    --if self:IsDummy() then return 6666 end
    --if self:IsAPlayer() and Player:CanAttack(self) then return 25 end
    local seconds = 8888
    local unitTable = Fonsas.ttdUnits[guid]
    -- Simple linear regression
    -- ( E(x^2)  E(x) )  ( a )  ( E(xy) )
    -- ( E(x)     n  )  ( b ) = ( E(y)  )
    -- Format of the above: ( 2x2 Matrix ) * ( 2x1 Vector ) = ( 2x1 Vector )
    -- Solve to find a and b, satisfying y = a + bx
    -- Matrix arithmetic has been expanded and solved to make the following operation as fast as possible
    if unitTable then
        local values = unitTable[1]
        local n = #values
        if n > minSamples then
            local a, b = 0, 0
            local Ex2, Ex, Exy, Ey = 0, 0, 0, 0
            
            local value, x, y
            for i = 1, n do
                value = values[i]
                x, y = value[1], value[2]
                
                Ex2 = Ex2 + x * x
                Ex = Ex + x
                Exy = Exy + x * y
                Ey = Ey + y
            end
            -- invariant to find matrix inverse
            local invariant = 1 / (Ex2 * n - Ex * Ex)
            -- Solve for a and b
            a = (-Ex * Exy * invariant) + (Ex2 * Ey * invariant)
            b = (n * Exy * invariant) - (Ex * Ey * invariant)
            if b ~= 0 then
                -- Use best fit line to calculate estimated time to reach target health
                seconds = (percentage - a) / b
                -- Subtract current time to obtain "time remaining"
                seconds = math.min(7777, seconds - (GetTime() - unitTable[2]))
                if seconds < 0 then seconds = 9999 end
            end
        end
    end
    return seconds
end