local ToolService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("BackpackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local UtilService = require(ServerScriptService.Modules.UtilService)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)

local minSizeTool = 1
local maxSizeTool = 50
local maxPlayerGame = 100000

local toolIdFromPlayer = {}

function ToolService:Init()
	ToolService:GetMaxPlayerFromGames()
end

function ToolService:UpdateBackpack(player: Player)
	bridge:Fire(player, {
		[actionIdentifier] = "UpdateBackpack",
	})
end

function ToolService:GetMaxPlayerFromGames()
	maxPlayerGame = 100000
end

function ToolService:GetScaleTool(amountPlayer: number)
	if amountPlayer <= 10 then
		return minSizeTool
	elseif amountPlayer > maxPlayerGame then
		return maxSizeTool
	else
		-- Calcula proporcionalmente entre 1 e 50
		local proporcao = (amountPlayer - 10) / (maxPlayerGame - 10)
		return minSizeTool + proporcao * (maxSizeTool - minSizeTool)
	end
end

function ToolService:GiveCrateTool(player: Player, toolName: string, toolId: number)
	local newToll = Instance.new("Tool")
	newToll:SetAttribute("ORIGINAL_NAME", toolName)
	newToll:SetAttribute("AMOUNT", 1)
	newToll:SetAttribute("TOOL_TYPE", "CRATE")
	newToll:SetAttribute("ID", toolId)

	newToll.Name = toolName
	newToll.Parent = player.Backpack
	ToolService:UpdateBackpack(player)
end

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
		ToolService:UpdateBackpack(player)
		return newToll
	end

	tool:SetAttribute("AMOUNT", amountTool + 1)
	tool.Name = UtilService:formatCamelCase(toolName) .. "(" .. amountTool + 1 .. ")"
	ToolService:UpdateBackpack(player)
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
		local newToll = ServerStorage.Tools.Games:FindFirstChild(gameName):Clone()
		newToll:SetAttribute("ORIGINAL_NAME", gameName)
		newToll:SetAttribute("PLAYER_AMOUNT", amountPlayer)
		newToll:SetAttribute("TOOL_TYPE", "GAME")
		newToll:ScaleTo(ToolService:GetScaleTool(amountPlayer))

		newToll.Name = UtilService:formatCamelCase(gameName) .. " " .. (playerAmountTool + (amountPlayer or 0))

		newToll.Parent = player.Backpack
		ToolService:UpdateBackpack(player)
		return newToll
	end

	tool:SetAttribute("PLAYER_AMOUNT", playerAmountTool + amountPlayer)
	tool.Name = UtilService:formatCamelCase(gameName) .. " " .. (playerAmountTool + (amountPlayer or 0))
	tool:ScaleTo(ToolService:GetScaleTool(playerAmountTool + amountPlayer))
	ToolService:UpdateBackpack(player)
end

function ToolService:ConsumeCrateTool(player: Player, toolId: number)
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("TOOL_TYPE") == "CRATE" and item:GetAttribute("ID") == toolId then
			item:Destroy()
			ToolService:UpdateBackpack(player)
			return
		end
	end

	local character = player.Character
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("TOOL_TYPE") == "CRATE" and item:GetAttribute("ID") == toolId then
				item:Destroy()
				ToolService:UpdateBackpack(player)
				return
			end
		end
	end
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
			ToolService:UpdateBackpack(player)
			return
		end

		tool:SetAttribute("AMOUNT", amountTool - 1)
		tool.Name = UtilService:formatCamelCase(toolName)
		ToolService:UpdateBackpack(player)
	end
end

function ToolService:ConsumeGameTool(player: Player, gameName: string)
	for _, item in player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if item:IsA("Tool") and item:GetAttribute("ORIGINAL_NAME") == gameName then
			item:Destroy()
			ToolService:UpdateBackpack(player)
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

	ToolService:UpdateBackpack(player)
end

return ToolService
