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

return UtilService
