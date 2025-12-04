local OfflineGameService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local Storages = require(ReplicatedStorage.Enums.Storages)
local GameService = require(ServerScriptService.Modules.GameService)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Devs = require(ReplicatedStorage.Enums.Devs)
local bridge = BridgeNet2.ReferenceBridge("OfflineGrowthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local offlineGamesPlayer = {}

function OfflineGameService:Init()
	OfflineGameService:InitBridgeListener()
end

function OfflineGameService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetOfflineGames" then
			OfflineGameService:GetOfflineGames(player)
		end
	end
end

function OfflineGameService:GetOfflineGames(player: Player)
	local games = offlineGamesPlayer[player.UserId]

	local x2Collect = PlayerDataHandler:Get(player, "x2OfflineCollect")

	if games then
		for _, gameInfo in games do
			local name = gameInfo.Name
			local playerAmount = gameInfo.PlayerAmount
			if x2Collect then
				GameService:GiveGame(player, name, playerAmount)
				GameService:GiveGame(player, name, playerAmount)
			else
				GameService:GiveGame(player, name, playerAmount)
			end
		end
	end
end


function OfflineGameService:HasOfflineStorageSpace(player: Player, playerAmount: number)
	if not player:GetAttribute("LIMIT_OFFLINE_STORAGE") then
		player:SetAttribute("LIMIT_OFFLINE_STORAGE", PlayerDataHandler:Get(player, "storageLimited"))
	end

	local amount = player:GetAttribute("USED_OFFLINE_STORAGE") or 0
	local limit = player:GetAttribute("LIMIT_OFFLINE_STORAGE")

	return (amount + playerAmount) <= limit
end

function OfflineGameService:AddOfflineGameInStorage(player: Player, amount: number)
	if not player:GetAttribute("LIMIT_OFFLINE_STORAGE") then
		player:SetAttribute("LIMIT_OFFLINE_STORAGE", PlayerDataHandler:Get(player, "storageLimited"))
	end

	local oldAmount = player:GetAttribute("USED_OFFLINE_STORAGE") or 0

	player:SetAttribute("USED_OFFLINE_STORAGE", oldAmount + amount)
end

function OfflineGameService:GetShuffledListFromStorage(gamesForStorages)
	local result = {}

	-- Converte os dados para uma lista sequencial repetindo os nomes pela quantidade
	for gameType, amount in pairs(gamesForStorages) do
		for i = 1, amount do
			table.insert(result, gameType)
		end
	end

	-- Embaralha a lista
	for i = #result, 2, -1 do
		local j = math.random(i)
		result[i], result[j] = result[j], result[i]
	end

	return result
end

function OfflineGameService:Buy2XCollect(player: Player)
	player:SetAttribute("2X_OFFLINE_COLLECT", true)
	PlayerDataHandler:Update(player, "x2OfflineCollect", function(current)
		return true
	end)

	local games = offlineGamesPlayer[player.UserId]

	if games then
		for _, gameInfo in games do
			local name = gameInfo.Name
			local playerAmount = gameInfo.PlayerAmount
			GameService:GiveGame(player, name, playerAmount)
			GameService:GiveGame(player, name, playerAmount)
		end
	end
end
return OfflineGameService
