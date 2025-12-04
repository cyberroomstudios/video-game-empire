local UtilService = {}

function UtilService:Init() end

function UtilService:SerializeCFrame(cf)
	return {
		cf:GetComponents(),
	}
end

function UtilService:DeserializeCFrame(tbl)
	return CFrame.new(unpack(tbl))
end

function UtilService:GetDevModel(playerFolder: Folder, workerId: number)
	for _, value in playerFolder:GetChildren() do
		if value:GetAttribute("DEV") and tonumber(value:GetAttribute("ID")) == tonumber(workerId) then
			return value
		end
	end
end

function UtilService:formatCamelCase(word: string)
	local formatted = word:gsub("(%l)(%u)", "%1 %2")
	formatted = formatted:gsub("(%a)([%w_']*)", function(a, b)
		return string.upper(a) .. b
	end)
	return formatted
end

function UtilService:WaitForDescendants(root, ...)
	local names = { ... }
	local current = root

	for _, name in ipairs(names) do
		current = current:WaitForChild(name)

		while not current do
			current = current:WaitForChild(name)
		end
	end

	return current
end

function UtilService:GetPositionHeightReference(player: Player, floorNumber: number)
	local base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]

	for _, floor in base:GetChildren() do
		if floor:GetAttribute("IS_BASE") then
			if tonumber(floor.Name) == floorNumber then
				return floor.PositionHeightReference.Position.Y - floor.PositionHeightReference.Size.Y / 2
			end
		end
	end
end

function UtilService:FormatNumberToSuffixes(n)
	local suffixes = { "", "K", "M", "B", "T", "Q" } -- pode adicionar mais se quiser
	local i = 1

	while n >= 1000 and i < #suffixes do
		n = n / 1000
		i = i + 1
	end

	-- Limita para 1 casa decimal e remove .0 se for inteiro
	local formatted = string.format("%.1f", n)
	formatted = formatted:gsub("%.0$", "")

	return formatted .. suffixes[i]
end

function UtilService:FormatToUSD(number)
	-- Se for inteiro, formata sem casas decimais
	local formatted
	if number % 1 == 0 then
		formatted = string.format("%d", number)
	else
		formatted = string.format("%.2f", number)
	end

	local beforeDecimal, afterDecimal = formatted:match("^(%-?%d+)%.*(%d*)$")
	beforeDecimal = beforeDecimal:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if beforeDecimal:sub(1, 1) == "," then
		beforeDecimal = beforeDecimal:sub(2)
	end

	if afterDecimal ~= "" then
		return "$" .. beforeDecimal .. "." .. afterDecimal
	else
		return "$" .. beforeDecimal
	end
end

function UtilService:FormatTime(seconds)
	seconds = math.floor(seconds)

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

return UtilService
