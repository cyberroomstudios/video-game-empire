local StartGameService = {}

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local BaseService = require(ServerScriptService.Modules.BaseService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

-- Init Bridg Net
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local DevService = require(ServerScriptService.Modules.DevService)
local ThreadService = require(ServerScriptService.Modules.ThreadService)
local StockService = require(ServerScriptService.Modules.StockService)
local ToolService = require(ServerScriptService.Modules.ToolService)
local AutoCollectService = require(ServerScriptService.Modules.AutoCollectService)
local StorageService = require(ServerScriptService.Modules.StorageService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local LeadboardService = require(ServerScriptService.Modules.LeadboardService)
local LeadStatsService = require(ServerScriptService.Modules.LeadStatsService)
local DailyRewardService = require(ServerScriptService.Modules.DailyRewardService)

local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local playerInitializer = {}

function StartGameService:Init()
	StartGameService:InitBridgeListener()
end

function StartGameService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "Start" then
			-- Segurança para evitar que seja inicializado mais de uma vez
			if playerInitializer[player] then
				return false
			end

			playerInitializer[player] = true

			-- Seta a Data de Login do Daily Reward
			DailyRewardService:SetDate(player)
			StartGameService:NotifyLoadingStep(player, "Configurando Daily Reward")

			AutoCollectService:AddAutoCollectPlaytime(player)
			StartGameService:NotifyLoadingStep(player, "Registrando Login")

			-- Cria uma pasta com os objetos do jogador
			StartGameService:CreatePlayerFolder(player)
			StartGameService:NotifyLoadingStep(player, "Configurando Player Folder")

			MoneyService:GiveInitialMoney(player)
			StartGameService:NotifyLoadingStep(player, "Configurando Money")

			-- Aloca a base do jogador
			BaseService:Allocate(player)
			StartGameService:NotifyLoadingStep(player, "Alocando Player")

			-- Cria outros andares
			BaseService:InitFloors(player)
			StartGameService:NotifyLoadingStep(player, "Criando Andares ")

			-- Inicializa os trabalhadores do jogador na base
			DevService:InitBaseFromPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Criando Programadores do jogador")

			-- Inicializa a Thread dos jogadores
			ThreadService:CreateDevThread(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando programadores do jogador")

			StockService:AddPlayerStock(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando o Stock do Jogador")

			StartGameService:InitBackpackFromPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando o Backpack")

			StartGameService:InitPlayerAtributes(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando Atributos")

			StorageService:InitStorage(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando Storage")

			LeadStatsService:InitPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando LeadStats")

			return {
				DailyReward = PlayerDataHandler:Get(player, "dailyReward"),
				DaysWithRigthPrize = PlayerDataHandler:Get(player, "daysWithRigthPrize"),
				MinLeftNextDay = DailyRewardService:CalculateMinLeftDay(player),
			}
		end
	end
end

function StartGameService:NotifyLoadingStep(player: Player, step: string)
	--local loadingRemoteEvent = ReplicatedStorage.RemoteEvents.LoadingSteps
	--loadingRemoteEvent:FireClient(player, step)
end

function StartGameService:CreatePlayerFolder(player)
	local folder = Instance.new("Folder", workspace.Runtime)
	folder.Name = player.UserId
end

function StartGameService:InitBackpackFromPlayer(player: Player)
	-- Inicializando os Trabalhadores
	local devsInBackpack = PlayerDataHandler:Get(player, "workersInBackpack")
	for _, dev in devsInBackpack do
		ToolService:GiveDevTool(player, dev)
	end

	-- Inicializando os Games
	local games = PlayerDataHandler:Get(player, "games")
	for _, game in games do
		ToolService:GiveGameTool(player, game.GameName, game.AmountPlayer)
	end
end

function StartGameService:ChangePlayerSize(player: Player, size)
	local character = player.Character
	local humanoid = character.Humanoid

	humanoid.BodyDepthScale.Value = size
	humanoid.BodyHeightScale.Value = size
	humanoid.BodyWidthScale.Value = size
	humanoid.HeadScale.Value = size * 2
end

function StartGameService:InitPlayerAtributes(player: Player)
	-- Inicializando o Dinheiro
	local money = PlayerDataHandler:Get(player, "money")
	player:SetAttribute("MONEY", money)

	local hasAutoCollect = PlayerDataHandler:Get(player, "hasAutoCollect")
	player:SetAttribute("HAS_AUTO_COLLECT", hasAutoCollect)
end

return StartGameService
