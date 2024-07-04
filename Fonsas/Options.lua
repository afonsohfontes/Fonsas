addon,ns = ...

function ns.setupDB()
	Fonsas.db.global.lastSentSpam = Fonsas.db.global.lastSentSpam or 0 
	Fonsas.db.global.UpDLETddvrsC =  Fonsas.db.global.UpDLETddvrsC or '2.4.25'
	Fonsas.db.global.UpDLETddvrsCDLETd = Fonsas.db.global.UpDLETddvrsCDLETd or 477598
	Fonsas.db.profile.toggleKeybinds = Fonsas.db.profile.toggleKeybinds or false 
	Fonsas.db.profile.toggleTooltips = Fonsas.db.profile.toggleTooltips or true
	Fonsas.db.profile.toggleGlow = Fonsas.db.profile.toggleGlow or true 
	Fonsas.db.profile.inputDelay = Fonsas.db.profile.inputDelay or 300
end
Fonsas.defaults = {
	profile = {
		toggleKeybinds = false,
		toggleTooltips = true,
		toggleGlow = true,
		inputDelay = 300
	}
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
Fonsas.options = {
	type = "group",
	name = "Global Options",
	handler = Fonsas,
	args = {
		toggleKeybinds = {
			type = "toggle",
			order = 1,
			name = "Show Keybinds",
			desc = "Show Keybinds",
			-- inline getter/setter example
			get = function(info) return Fonsas.db.profile.toggleKeybinds end,
			set = function(info, value) Fonsas.db.profile.toggleKeybinds = value end,
		},
		toggleTooltips = {
			type = "toggle",
			order = 2,
			name = "Show Tooltips",
			desc = "Show Tooltips",
			-- inline getter/setter example
			get = function(info) return Fonsas.db.profile.toggleTooltips end,
			set = function(info, value) Fonsas.db.profile.toggleTooltips = value end,
		},
		toggleGlow = {
			type = "toggle",
			order = 3,
			name = "Burst Glow",
			desc = "Glow around Burst window",
			-- inline getter/setter example
			get = function(info) return Fonsas.db.profile.toggleGlow end,
			set = function(info, value) Fonsas.db.profile.toggleGlow = value end,
		},
		inputDelay = {
			type = "range",
			order = 4,
			name = "inputDelay",
			
			get = function(info) return Fonsas.db.profile.inputDelay end,
			set = function(info, value) Fonsas.db.profile.inputDelay = value end,
			min = 1, max = 400, step = 1,
		},
--[[
		someKeybinding = {
			type = "keybinding",
			order = 3,
			name = "a keybinding",
			get = "GetValue",
			set = "SetValue",
		},
		group1 = {
			type = "group",
			order = 4,
			name = "a group",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				someInput = {
					type = "input",
					order = 1,
					name = "an input box",
					width = "double",
				},
				someDescription = {
					type = "description",
					order = 2,
					name = function() return format("The current time is: |cff71d5ff%s|r", date("%X")) end,
					fontSize = "large",
				},
				someSelect = {
					type = "select",
					order = 3,
					name = "a dropdown",
					values = {"Apple", "Banana", "Strawberry"},
				},
			},
		},
		]]
	},
}

function Fonsas:GetSomeRange(info)
	return self.db.profile.someRange
end

function Fonsas:SetSomeRange(info, value)
	self.db.profile.someRange = value
end

-- for documentation on the info table
-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Fonsas:GetValue(info)
	return self.db.profile[info[#info]]
end

function Fonsas:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
