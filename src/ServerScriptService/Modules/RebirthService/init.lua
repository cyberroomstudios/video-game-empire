local RebirthService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local BaseService = require(ServerScriptService.Modules.BaseService)
local Rebirths = require(ReplicatedStorage.Enums.Rebirths)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local DevService = require(ServerScriptService.Modules.DevService)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function RebirthService:Init()
	RebirthService:InitBridgeListener()
end

function RebirthService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetRebirth" then
			return RebirthService:GetRebirth(player)
		end

		if data[actionIdentifier] == "GetInfoRebirth" then
			return RebirthService:GetInfoRebirth(player)
		end
	end
end

function RebirthService:GetInfoRebirth(player: Player)
	local currentRebirth = PlayerDataHandler:Get(player, "rebirth")
	local nextRebirth = currentRebirth + 1

	local rebirth = Rebirths[nextRebirth]

	if rebirth then
		return rebirth
	end
end
function RebirthService:HasAllRequeriments(player: Player, rebirth)
	for _, requirement in rebirth.Requirements do
		if requirement.Type == "MONEY" then
			local currentMoney = PlayerDataHandler:Get(player, "money")
			if currentMoney < requirement.Amount then
				return false
			end
		end

		if requirement.Type == "CCU" then
			local currentGame = PlayerDataHandler:Get(player, "totalCCU")
			if currentGame < requirement.Amount then
				return false
			end
		end
	end

	return true
end

function RebirthService:GiveAllAwards(player: Player, rebirth)
	for _, award in rebirth.Awards do
		if award.Type == "FLOOR" then
			BaseService:GiveMoreFloor(player, 1)
			PlayerDataHandler:Update(player, "floors", function(current)
				return current + 1
			end)
		end

		if award.Type == "MONEY" then
			MoneyService:GiveMoney(player, award.Amount)
		end
	end
end

function RebirthService:ClearAllItems(player: Players)
	PlayerDataHandler:Update(player, "workers", function(current)
		for _, value in current do
			DevService:DeleteDevInMap(player, value.Id)
		end
		return {}
	end)

	PlayerDataHandler:Update(player, "workersInBackpack", function(current)
		return {}
	end)

	MoneyService:ConsumeAllMoney(player)
end

function RebirthService:UpdateRebirth(player: Player)
	PlayerDataHandler:Update(player, "rebirth", function(current)
		return current + 1
	end)
end

function RebirthService:GetRebirth(player: Player)
	local currentRebirthNumber = PlayerDataHandler:Get(player, "rebirth")

	local nextRebirth = Rebirths[currentRebirthNumber + 1]

	if nextRebirth then
		local hasAllRequeriments = RebirthService:HasAllRequeriments(player, nextRebirth)

		if hasAllRequeriments then
			-- Atualiza o Indicador de Rebirth do jogador
			RebirthService:UpdateRebirth(player)

			-- Limpa todos os dados do rebirth
			RebirthService:ClearAllItems(player)

			-- Da todos os premios pro jogador
			RebirthService:GiveAllAwards(player, nextRebirth)

			return PlayerDataHandler:Get(player, "rebirth")
		end
	end
end
return RebirthService
