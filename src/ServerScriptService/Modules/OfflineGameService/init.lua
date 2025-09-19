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
local ThreadService = require(ServerScriptService.Modules.ThreadService)
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

	if games then
		for _, gameInfo in games do
			local name = gameInfo.Name
			local playerAmount = gameInfo.PlayerAmount
			GameService:GiveGame(player, name, playerAmount)
		end
	end
end

function OfflineGameService:Generate(player: Player)
	local timeLeftGame = PlayerDataHandler:Get(player, "timeLeftGame")

	if timeLeftGame > 0 then
		-- Tempo que se passou desde o ultimo login
		local now = os.time()
		local secondsPassed = now - timeLeftGame

		-- Obtem todos os programadores
		local workers = PlayerDataHandler:Get(player, "workers")

		-- Lista de Jogos para armazenar no Storage
		local gamesForStorages = {}
		local allGames = {}

		-- Gera os Jogos para os trabalhadores
		for _, dev in workers do
			local devEnum = Devs[dev.Name]

			-- Obtem a quantidade de jogos produzidos no periodo
			local amountGames = math.floor(secondsPassed / devEnum.TimeToProduceGame)

			-- Capacidade do dev
			local devCapacity = devEnum.CapacityOfGamesProduced

			-- Total ja Produzido pelo dev
			local totalAmount = 0

			for i = 1, amountGames do
				local gameName, playerAmount = ThreadService:CreateGame(player, dev.Name)

				-- Verifica se ainda tem espaço disponivel no programador para produzir o jogo
				if totalAmount + playerAmount <= devEnum.CapacityOfGamesProduced then
					local newGame = {
						Name = gameName,
						PlayerAmount = playerAmount,
					}
					table.insert(allGames, newGame)
					totalAmount = totalAmount + playerAmount
				end
			end
		end

		for _, dev in workers do
			local devEnum = Devs[dev.Name]

			local gameName, playerAmount = ThreadService:CreateGame(player, dev.Name)

			local hasSpace = OfflineGameService:HasOfflineStorageSpace(player, playerAmount)

			if hasSpace then
				OfflineGameService:AddOfflineGameInStorage(player, playerAmount)

				local newGame = {
					Name = gameName,
					PlayerAmount = playerAmount,
				}
				table.insert(allGames, newGame)
			end
		end

		offlineGamesPlayer[player.UserId] = allGames

		if #allGames > 0 then
			bridge:Fire(player, {
				[actionIdentifier] = "ShowOffilineGames",
				data = {
					OfflineGmes = offlineGamesPlayer[player.UserId],
				},
			})
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

return OfflineGameService
