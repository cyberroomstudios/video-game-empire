local PlayerDataHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)

local bridge = BridgeNet2.ReferenceBridge("PlayerLoaded")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")

local ServerScriptService = game:GetService("ServerScriptService")

local bridgePlayer = BridgeNet2.ReferenceBridge("Player")

bridgePlayer.OnServerInvoke = function(player, data)
	if data[actionIdentifier] == "getPlayerData" then
		local playerData = PlayerDataHandler:GetAll(player)
		return {
			[statusIdentifier] = "success",
			[messageIdentifier] = "Player data retrieved",
			playerData = playerData,
		}
	end
end

local cachedJoinTimestamps = {}
local dataTemplate = {
	totalPlaytime = 0, -- Tempo total de jogo
	workers = {}, -- Lista de Trabalhadores na base
	workerId = 1, -- Sequence PK
	games = {}, -- Lista de Jogos obtidos
	gameId = 1, -- Sequence PK,
	storages = {}, -- Lista de Storages na base
	storageId = 1, -- Sequence PK
	workersInBackpack = {}, -- Trabalhadores na mochila
	index = {}, -- Contem todos os tipos itens ja obtidos pelo jogador do jogador
	money = 0, -- Total de Dinheiro
	floors = 0, -- Quantidade de Andares Liberados
	totalNumberOfGamesProduced = 0, -- Total de Jogos Produzidos
	rebirth = 0, -- Quantidade de Rebirths
	hasAutoCollect = false, -- Indica se o jogador comprou o auto Collect
	hasAutoSell = false, -- Indica se o jogador comprou o auto Sell
	codesUsed = {}, -- Armazena todos os códigos de promoção utilizados
	upgrades = {}, -- Armazena os Upgrades que o jogador tem (Storages)
	upgradesInBackpack = {}, -- Upgrades que o jogador tem no packpack
	timeLeftGame = 0, -- Armazena a o time que o jogador saiu do jogo
	dailyReward = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
	},
	currentDayReward = 0, -- Armazena qual ultimo dia da semana que o jogador pegou o premio
	daysWithRigthPrize = 0, -- Armazena quantos dias o jogador tem direito a premio
	lastDateLogin = "",
	rebirthLuck = 0,
	limitDateRobuxLuck = 0,
	mapClaimed = false,
}

local ProfileService = require(ServerScriptService.libs.ProfileService)

local ProfileStore = ProfileService.GetProfileStore("PlayerProfile", dataTemplate)

local Profiles = {}

local function playerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player] = nil

			player:Kick()
		end)

		if not player:IsDescendantOf(Players) then
			profile:Release()
		else
			Profiles[player] = profile
		end

		profile:Reconcile()

		bridge:Fire(player, {
			[actionIdentifier] = "PlayerLoaded",
			[statusIdentifier] = "success",
			[messageIdentifier] = "Player data loaded",
			data = profile.Data,
		})
	else
		player:Kick()
	end
end

local function getProfile(player)
	-- Try waiting for the profile to load but don't wait too long
	local startTime = os.time()
	while not Profiles[player] and os.time() - startTime < 30 do
		task.wait()
	end

	assert(Profiles[player], "Profile not found for player " .. player.Name)

	return Profiles[player]
end

function PlayerDataHandler:Wipe(player)
	local success = ProfileStore:WipeProfileAsync("Player_" .. player.UserId)
	if success then
		player:Kick()
	end
end

-- Getter/Setter methods
function PlayerDataHandler:Get(player, key)
	local profile = getProfile(player)

	--assert(profile.Data[key]"Key not found in player data: " .. key)

	return profile.Data[key]
end

function PlayerDataHandler:Set(player, key, value)
	local profile = getProfile(player)

	-- Check if key exists
	-- assert(profile.Data[key], "Key not found in player data: " .. key)

	-- Check if there is a type mismatch
	assert(type(value) == type(profile.Data[key]), "Value type mismatch for key " .. key)

	profile.Data[key] = value
end

function PlayerDataHandler:Update(player, key, callback)
	-- local profile = getProfile(player)

	local oldData = self:Get(player, key)

	local newData = callback(oldData)

	self:Set(player, key, newData)
end

function PlayerDataHandler:GetAll(player)
	local profile = getProfile(player)

	return profile.Data
end

function PlayerDataHandler:Init()
	for _, player in Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end

	Players.PlayerAdded:Connect(function(player)
		playerAdded(player)

		local joinTimestamp = os.time()
		cachedJoinTimestamps[player] = joinTimestamp
		player:SetAttribute("JOIN_TIME_STAMP", joinTimestamp)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local joinTimestamp = cachedJoinTimestamps[player]
		local leaveTimestamp = os.time()
		local playtime = leaveTimestamp - joinTimestamp

		PlayerDataHandler:Update(player, "totalPlaytime", function(currentPlaytime)
			local totalPlaytime = currentPlaytime + playtime
			return totalPlaytime
		end)

		-- Guarda quanto Resta de Robux Luck
		PlayerDataHandler:Set(player, "limitDateRobuxLuck", player:GetAttribute("LIMIT_DATE_ROBUX_LUCK") or 0)

		-- Guarda a Hora que o jogador saiu do jogo
		PlayerDataHandler:Set(player, "timeLeftGame", os.time())

		if Profiles[player] then
			Profiles[player]:Release()
		end
	end)
end

return PlayerDataHandler
