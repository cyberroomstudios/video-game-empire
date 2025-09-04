local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local UtilService = require(ServerScriptService.Modules.UtilService)

local ToolService = {}

function ToolService:Init() end

-- Da uma nova tool de Desenvolvedor ao jogador
function ToolService:GiveDevTool(player: Player, toolName: string)
	local tool = nil
	local amountTool = 0

	-- Procura um item existente do backpack
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == toolName then
			tool = item
			amountTool = item:GetAttribute("AMOUNT")
		end
	end

	-- Verifica se o item ta na mão
	if not tool then
		local character = player.Character
		if character then
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == toolName then
					tool = item
					amountTool = item:GetAttribute("AMOUNT")
				end
			end
		end
	end

	-- Se não encontrar nenhum, cria uma nova tool
	if not tool then
		local newToll = Instance.new("Tool")
		newToll:SetAttribute("ORIGINAL_NAME", toolName)
		newToll:SetAttribute("AMOUNT", 1)
		newToll:SetAttribute("TOOL_TYPE", "DEV")

		newToll.Name = UtilService:formatCamelCase(toolName)
		newToll.Parent = player.Backpack

		return newToll
	end

	tool:SetAttribute("AMOUNT", amountTool + 1)
	tool.Name = UtilService:formatCamelCase(toolName) .. "(" .. amountTool + 1 .. ")"
end

-- Da uma nova tool de jogo ao desenvolvedor ao jogador
function ToolService:GiveGameTool(player: Player, gameName: string, amountPlayer: number)
	local tool = nil
	local playerAmountTool = 0

	-- Procura um item existente do backpack
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == gameName then
			tool = item
			playerAmountTool = item:GetAttribute("PLAYER_AMOUNT")
		end
	end

	-- Verifica se o item ta na mão
	if not tool then
		local character = player.Character
		if character then
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == gameName then
					tool = item
					playerAmountTool = item:GetAttribute("PLAYER_AMOUNT")
				end
			end
		end
	end

	-- Se não encontrar nenhum, cria uma nova tool
	if not tool then
		local newToll = ServerStorage.Tools.Games:FindFirstChild(gameName)
		newToll:SetAttribute("ORIGINAL_NAME", gameName)
		newToll:SetAttribute("PLAYER_AMOUNT", amountPlayer)
		newToll:SetAttribute("TOOL_TYPE", "GAME")

		newToll.Name = UtilService:formatCamelCase(gameName) .. " " .. (playerAmountTool + (amountPlayer or 0))

		newToll.Parent = player.Backpack

		return newToll
	end

	tool:SetAttribute("PLAYER_AMOUNT", playerAmountTool + amountPlayer)
	tool.Name = UtilService:formatCamelCase(gameName) .. " " .. (playerAmountTool + (amountPlayer or 0))
end

function ToolService:ConsumeDevTool(player: Player, toolName: string)
	local tool = nil
	local amountTool = 0

	-- Procura um item existente do backpack
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if not tool and item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == toolName then
			tool = item
			amountTool = item:GetAttribute("AMOUNT")
		end
	end

	-- Verifica se o item ta na mão
	if not tool then
		local character = player.Character
		if character then
			for _, item in ipairs(character:GetChildren()) do
				if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == toolName then
					tool = item
					amountTool = item:GetAttribute("AMOUNT")
				end
			end
		end
	end

	if tool and amountTool then
		if amountTool == 1 then
			tool:Destroy()

			return
		end

		tool:SetAttribute("AMOUNT", amountTool - 1)
		tool.Name = UtilService:formatCamelCase(toolName)
	end
end

function ToolService:ConsumeGameTool(player: Player, gameName: string)
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == gameName then
			item:Destroy()
			return
		end
	end

	local character = player.Character
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == gameName then
				item:Destroy()
			end
		end
	end
end

function ToolService:ConsumeAllGameTool(player: Player)
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("TOOL_TYPE") == "GAME" then
			item:Destroy()
		end
	end

	local character = player.Character
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("TOOL_TYPE") == "GAME" then
				item:Destroy()
			end
		end
	end
end

return ToolService
