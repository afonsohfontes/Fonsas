addon,ns = ...

 function ns.GetIntro()
	local lastLogin = Fonsas:LoadData('lastSentSpam') or GetTime() - 3600
	local timeNow = GetTime()
	local timeDifference = timeNow - lastLogin
    if timeDifference > 60000 then
        return messages.longTime[math.random(#messages.longTime)]
    elseif timeDifference > 3600 then
        return messages.mediumTime[math.random(#messages.mediumTime)]
    elseif timeDifference > 60 then
        return messages.shortTime[math.random(#messages.shortTime)]
    elseif timeDifference > 30 then
            return messages.veryShortTime[math.random(#messages.veryShortTime)]
    else
            return messages.veryVeryShortTime[math.random(#messages.veryVeryShortTime)]
    end
end

function Fonsas:PrintTable(t, indent)
	indent = indent or 0
	for key, value in pairs(t) do
		local formatting = string.rep("  ", indent) .. key .. ": "
		if type(value) == "table" then
			print(formatting)
			self:PrintTable(value, indent + 1)
		else
			print(formatting .. tostring(value))
		end
	end
end
local function SetContains(set, key)
    return set[key] ~= nil
end
function Fonsas:SaveData(key, value)
    ns.dbglobal[key] = value
end
-- Function to load data
function Fonsas:LoadData(key)
    local value = ns.dbglobal[key]
	return value
end
function ns.formatUpToX(s, x, indent)
	x = x or 79
	indent = indent or ""
	local t = {""}
	local function cleanse(s) return s:gsub("@x%d%d%d",""):gsub("@r","") end
	for prefix, word, suffix, newline in s:gmatch("([ \t]*)(%S*)([ \t]*)(\n?)") do
	  if #(cleanse(t[#t])) + #prefix + #cleanse(word) > x and #t > 0 then
		table.insert(t, word..suffix) -- add new element
	  else -- add to the last element
		t[#t] = t[#t]..prefix..word..suffix
	  end
	  if #newline > 0 then table.insert(t, "") end
	end
	return indent..table.concat(t, "\n"..indent)
  end