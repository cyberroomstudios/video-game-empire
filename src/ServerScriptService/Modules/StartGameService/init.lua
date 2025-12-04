local StartGameService = {}

-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Modules
local BaseService = require(ServerScriptService.Modules.BaseService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

-- Init Bridg Net
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local DevService = require(ServerScriptService.Modules.DevService)
local ToolService = require(ServerScriptService.Modules.ToolService)
local AutoCollectService = require(ServerScriptService.Modules.AutoCollectService)
local StorageService = require(ServerScriptService.Modules.StorageService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local LeadboardService = require(ServerScriptService.Modules.LeadboardService)
local LeadStatsService = require(ServerScriptService.Modules.LeadStatsService)
local DailyRewardService = require(ServerScriptService.Modules.DailyRewardService)
local OfflineGameService = require(ServerScriptService.Modules.OfflineGameService)
local GamepassManager = require(ServerScriptService.Modules.GamepassManager)
local SettingsService = require(ServerScriptService.Modules.SettingsService)
local ThreadService = require(ServerScriptService.Modules.ThreadService)
local BeltService = require(ServerScriptService.Modules.BeltService)

local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local playerInitializer = {}

function StartGameService:Init()
	StartGameService:InitBridgeListener()

	Players.PlayerRemoving:Connect(function(player)
		StartGameService:Clear(player)
	end)
end

function StartGameService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "Start" then
			-- Segurança para evitar que seja inicializado mais de uma vez
			if playerInitializer[player] then
				return false
			end

			playerInitializer[player] = true

			-- Inicializa as Configurações
			SettingsService:InitPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Configurando Settings")

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
			--	BaseService:InitFloors(player)
			--	StartGameService:NotifyLoadingStep(player, "Criando Andares ")

			-- Inicializa os trabalhadores do jogador na base
			DevService:InitBaseFromPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Criando Programadores do jogador")

			-- Inicializa a Thread dos jogadores

			ThreadService:StartDev(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando programadores do jogador")

			StartGameService:InitBackpackFromPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando o Backpack")

			StartGameService:InitPlayerAtributes(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando Atributos")

			StorageService:InitStorage(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando Storage")

			StartGameService:NotifyLoadingStep(player, "Obtendo Trabalho Offline")

			LeadStatsService:InitPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando LeadStats")

			GamepassManager:InitGamePassesFromPlayer(player)
			StartGameService:NotifyLoadingStep(player, "Inicializando GamePasses")

			BeltService:Start(player)

			ThreadService:StartHatchingPlace(player)
			StorageService:InitAntAFK(player)
			return {
				DailyReward = PlayerDataHandler:Get(player, "dailyReward"),
				DaysWithRigthPrize = PlayerDataHandler:Get(player, "daysWithRigthPrize"),
				MinLeftNextDay = DailyRewardService:CalculateMinLeftDay(player),
			}
		end
	end
end

function StartGameService:Clear(player: Player)
	playerInitializer[player] = false
end

function StartGameService:NotifyLoadingStep(player: Player, step: string)
	--local loadingRemoteEvent = ReplicatedStorage.RemoteEvents.LoadingSteps
	--loadingRemoteEvent:FireClient(player, step)
end

function StartGameService:CreatePlayerFolder(player)
	local folder = Instance.new("Folder", workspace.Runtime)
	folder.Name = player.UserId

	local devs = Instance.new("Folder", folder)
	devs.Name = "Devs"

	local crates = Instance.new("Folder", folder)
	crates.Name = "Crates"

	local hatching = Instance.new("Folder", folder)
	hatching.Name = "Hatching"
end

function StartGameService:InitBackpackFromPlayer(player: Player)
	-- Inicializando os Trabalhadores
	local devsInBackpack = PlayerDataHandler:Get(player, "workersInBackpack")
	for _, dev in devsInBackpack do
		ToolService:GiveDevTool(player, dev)
	end

	-- Incializando as Crates
	local crates = PlayerDataHandler:Get(player, "cratesInBackpack")

	for _, value in crates do
		local crateName = value.Name
		ToolService:GiveCrateTool(player, crateName, value.Id)
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

	local x2OfflineCollect = PlayerDataHandler:Get(player, "x2OfflineCollect")
	player:SetAttribute("2X_OFFLINE_COLLECT", x2OfflineCollect)
end

function StorageService:InitAntAFK(player: Player)
	-- Caio
	if player.UserId == 6449479 or player.UserId == 95234395 or player.UserId == 4855409226 then
		task.delay(60 * 5, function()
			if player.Parent then
				TeleportService:Teleport(game.PlaceId, player)
			end
		end)
	end
end

return StartGameService
