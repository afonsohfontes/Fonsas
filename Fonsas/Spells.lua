addon,ns = ...
function Fonsas:IsMajorCooldown(spellId)
    return spellId == Fonsas.Spells.SynapseSprings or
	spellId == Fonsas.Spells.RaiseDead or
	spellId == Fonsas.Spells.WilltoSurvive or

    spellId == Fonsas.Spells.EmpowerRuneWeapon or
    spellId == Fonsas.Spells.UnbreakableArmor or
    spellId == Fonsas.Spells.BloodTap or
    spellId == Fonsas.Spells.ArmyOfTheDead or
    spellId == Fonsas.Spells.SummonGargoyle or
    spellId == Fonsas.Spells.Gloves or
    spellId == Fonsas.Spells.SaroniteBomb or
    spellId == Fonsas.Spells.Sapper or
    spellId == Fonsas.Spells.PotionOfSpeed or
    spellId == Fonsas.Spells.IndestructiblePotion or
    --  spellId == Fonsas.Spells.FrostPresence or
    spellId == Fonsas.Spells.UnholyFrenzy or
    spellId == Fonsas.Spells.HeroicStrike or
    spellId == Fonsas.Spells.Cleave or
    spellId == Fonsas.Spells.ShatteringThrow or
    --  spellId == Fonsas.Spells.BattleStance or
    spellId == Fonsas.Spells.Rend or
    spellId == Fonsas.Spells.Recklessness or
    spellId == Fonsas.Spells.Retaliation or
    --  spellId == Fonsas.Spells.Bloodrage or
    spellId == Fonsas.Spells.DeathWish or
    spellId == Fonsas.Spells.ColdBlood or
    spellId == Fonsas.Spells.Vanish or
	-- Paladin
	spellId == Fonsas.Spells.GuardianofAncientKings or
	spellId == Fonsas.Spells.LayonHands or
	spellId == Fonsas.Spells.HandofProtection or
	spellId == Fonsas.Spells.HammerofJustice or
	spellId == Fonsas.Spells.HandofSacrifice or
	spellId == Fonsas.Spells.AvengingWrath or
	spellId == Fonsas.Spells.DivineProtection or
	spellId == Fonsas.Spells.Zealotry or
	spellId == Fonsas.Spells.Indestructible or
	spellId == Fonsas.Spells.HandofSalvation or
	spellId == Fonsas.Spells.DivineShield

end
function Fonsas:BuildSpellBook()
	local i = 1
	if Fonsas.DEBUG then print ("Building Spellbook") end
	while true do        
		local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end
		-- can add more to clean up the Spells table if it matters
		if ( spellName~="Axe Specialization" and  spellName~="Basic Campfire" and  spellName~="Cold Weather Flying"
			and spellName ~= "Cooking" and spellName ~= "Dual Wield" and  spellName ~= "Engineering" 
			and spellName ~= "Find Fish" and spellName ~= "First Aid" and  spellName ~= "Fishing" 
			and spellName ~= "Goblin Engineer" and spellName ~= "Jewelcrafting" and  spellName ~= "Tailoring" 
			and spellName ~= "Mining" and spellName ~= "Prospecting" and  spellName ~= "Shoot"
			and spellName ~= "Stance Mastery" and spellName ~= "Throw" and spellName ~= "Hardiness"
			and spellName ~= "Command" and spellName ~= "Rampage" and spellName ~= "Parry" and spellName ~= "Dodge"
			and spellName ~= "Block" and spellName ~= "Enchanting" and spellName ~= "Disenchant" 
			and spellName ~= "Armor Skills" and spellName ~= "Bartering" and spellName ~= "Bountiful Bags"
			and spellName ~= "Fast Track" and spellName ~= "Flight Master's License" and spellName ~= "For Great Justice"
			and spellName ~= "Honorable Mention" and spellName ~= "Languages" and spellName ~= "Mastery" 
			and spellName ~= "Mr. Popularity" and spellName ~= "Master Riding" and spellName ~= "Reinforce" 
			and spellName ~= "The Human Spirit" and spellName ~= "Weapon Skills" and spellName ~= "Working Overtime" 
			and spellName ~= "Cooking Fire" and not string.find(spellName, "Specialization")

		) then
			local _, spellId = GetSpellBookItemInfo(spellName)
			if spellId then 
				spellName = string.gsub(spellName, "%s+", "")
				spellName = string.gsub(spellName, "%p+", "")
				
				if not Fonsas.Spells[spellName] then                
					Fonsas.Spells[spellName] = spellId
		
				end
			--print(spellName, spellId, Fonsas.Spells[spellName])
			end
		end
		i = i + 1
	end
	
	--TODO #13 Add more here for other classes abilities
	-- Add auras/potions/items here
	--Common   
	Fonsas.Spells["AutoAttack"] = 6603
	Fonsas.Spells["GCD"] = 61304
	Fonsas.Spells["Pacify"] = 10730

	Fonsas.Spells["PotionOfSpeed"] = 40211
	Fonsas.Spells["Speed"] = 53908       --the aura from PotionOfSpeed
	Fonsas.Spells["IndestructiblePotion"] = 40093
	Fonsas.Spells["Indestructible"] = 53762  --the aura from IndestructiblePotion
-- Cata Potions
	Fonsas.Spells["GolembloodPotion"] = 58146
	Fonsas.Spells["GolemsStrength"] = 79634
	Fonsas.Spells["PotionoftheTolvir"] = 80495
	Fonsas.Spells["TolvirAgility"] = 79633
	Fonsas.Spells["VolcanicPotion"] = 80481
	Fonsas.Spells["VolcanicPower"] = 80495
	Fonsas.Spells["EarthenPotion"] = 80478
	Fonsas.Spells["EarthenArmor"] = 79475

	Fonsas.Spells["SynapseSprings"] = 82174
	Fonsas.Spells["Heartened"] = 91634
	Fonsas.Spells["Berserking"] = 26297
	Fonsas.Spells["Gloves"] = 54758
	Fonsas.Spells["SaroniteBomb"] = 56350
	Fonsas.Spells["Sapper"] = 56488
	Fonsas.Spells["HyperspeedAcceleration"] = 54758
	--DK
	Fonsas.Spells["KillingMachine"] = 51124
	Fonsas.Spells["FreezingFog"] = 59052
	Fonsas.Spells["UnholyForce"] = 67383
	Fonsas.Spells["UnholyMight"] = 67117
	Fonsas.Spells["UnholyFrenzy"] = 55975
	
	--Warrior
	Fonsas.Spells["SlamProc"] = 46916
	Fonsas.Spells["OverpowerReady"] = 68051

	-- Paladin
	Fonsas.Spells["JudgementsofthePure"] = 53657
	Fonsas.Spells["DivinePurpose"] = 90174
	Fonsas.Spells["TheArtofWar"] = 59578
	--Zealotry, Inquisition, 
	
	-- Druid
	Fonsas.Spells["Clearcasting"] = 16870
	-- Rogue
	Fonsas.Spells["Overkill"] = 58427

	Fonsas.SpellsByID = {}
	Fonsas.SpellIcons = {}

	--if removing automated spellbook, move this chunk somewhere below to create the Icons lookup table
	for name, id in pairs(Fonsas.Spells) do

		Fonsas.SpellIcons[id] = GetSpellTexture(id)
		if Fonsas.SpellsById[name] then
			table.insert(Fonsas.SpellsById[name], id)
		else
			Fonsas.SpellsById[id] = name
		end
		cooldownMS, gcdMS = GetSpellBaseCooldown(id)
		-- track spells with cooldown >0 to add to side bars
		if Fonsas:IsMajorCooldown(id) then -- cooldownMS and cooldownMS > 30000  then 
			Fonsas.majorCooldowns[id] = name
		end	

		if DLAPI and Fonsas.DEBUG then DLAPI.DebugLog("Spells",id) end
		if DLAPI and Fonsas.DEBUG then DLAPI.DebugLog("Cooldowns",name, id, cooldownMS) end
		
		
	end
end
