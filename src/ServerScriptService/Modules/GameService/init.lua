local GameService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")
local ToolService = require(ServerScriptService.Modules.ToolService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

function GameService:Init()
	GameService:InitBridgeListener()
end

function GameService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetGames" then
			return GameService:GetGamesFromPlayer(player)
		end

		if data[actionIdentifier] == "SellItem" then
			GameService:SellGame(player, data.data.GameName)
		end

		if data[actionIdentifier] == "SellAll" then
			GameService:SellAllGame(player)
		end
	end
end

function GameService:GiveGame(player: Player, gameName: string, amountPlayer: number)
	local id = PlayerDataHandler:Get(player, "gameId")

	PlayerDataHandler:Update(player, "games", function(current)
		for _, game in current do
			if game.GameName == gameName then
				-- se já existe, apenas atualiza o valor
				game.AmountPlayer = amountPlayer
				return current
			end
		end

		-- se não encontrou, insere um novo
		table.insert(current, {
			GameName = gameName,
			AmountPlayer = amountPlayer,
		})

		return current
	end)

	GameService:AddGameIndex(player, gameName)
	ToolService:GiveGameTool(player, gameName, amountPlayer)
end

function GameService:AddGameIndex(player: Player, gameName: string)
	PlayerDataHandler:Update(player, "index", function(current)
		for _, value in current do
			if value == gameName then
				return current
			end
		end

		table.insert(current, gameName)
		return current
	end)
end

function GameService:GetGamesFromPlayer(player: Player)
	local games = PlayerDataHandler:Get(player, "games")

	for _, game in games do
		game["Price"] = GameService:GetGamePrice(game.AmountPlayer)
	end

	return games
end

function GameService:ConsumeGame(player: Player, gameName: string)
	PlayerDataHandler:Update(player, "games", function(current)
		local newGames = {}

		for _, value in current do
			if value.GameName ~= gameName then
				table.insert(newGames, value)
			end
		end

		return newGames
	end)
end

function GameService:GetGamePrice(amountPlayers: number)
	return math.floor(amountPlayers * 0.5)
end

function GameService:SellGame(player: Player, gameName: string)
	local games = PlayerDataHandler:Get(player, "games")
	local hasGame = false
	local price = 0

	for _, value in games do
		if value.GameName == gameName then
			hasGame = true
			price = GameService:GetGamePrice(value.AmountPlayer)
			break
		end
	end

	if hasGame then
		-- Consome o Game do banco de dados
		GameService:ConsumeGame(player, gameName)

		-- Consome a Tool
		ToolService:ConsumeGameTool(player, gameName)

		-- Da o Dinheiro pro Jogadore
		MoneyService:GiveMoney(player, price)
	end
end

function GameService:SellAllGame(player: Player)
	local games = PlayerDataHandler:Get(player, "games")
	local totalPrice = 0
	for _, value in games do
		totalPrice = totalPrice + GameService:GetGamePrice(value.AmountPlayer)
	end

	PlayerDataHandler:Set(player, "games", {})

	-- Consome Todas as Tools
	ToolService:ConsumeAllGameTool(player)

	-- Da o Dinheiro pro Jogadore
	MoneyService:GiveMoney(player, totalPrice)
end

return GameService
