local ThreadService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)
local BaseService = require(ServerScriptService.Modules.BaseService)
local StorageService = require(ServerScriptService.Modules.StorageService)
local LeadboardService = require(ServerScriptService.Modules.LeadboardService)
local LeadStatsService = require(ServerScriptService.Modules.LeadStatsService)

local playerGames = {}

local animationCache = {} -- cache para evitar recarregar a cada vez

function ThreadService:Init() end

function ThreadService:PlayOrPauseWorkerAnimation(devModel: Model, shouldPlay: boolean)
	if not devModel or not devModel.Parent then
		return
	end

	-- Se não existir no cache, cria o AnimationTrack e guarda
	if not animationCache[devModel] then
		local animationController = devModel:FindFirstChild("Rig")
			and devModel.Rig:FindFirstChild("AnimationController")

		if animationController then
			local animator = animationController:FindFirstChild("Animator")
			local animation = animator and animator:FindFirstChild("Animation")
			if animator and animation then
				local track = animator:LoadAnimation(animation)
				animationCache[devModel] = track -- salva no cache

				-- Remove do cache quando o modelo for destruído
				devModel.Destroying:Connect(function()
					if track.IsPlaying then
						track:Stop()
					end
					animationCache[devModel] = nil
				end)
			end
		end
	end

	local animationTrack = animationCache[devModel]
	local monitor = devModel:FindFirstChild("Monitor")

	-- Função para mudar cores
	local function startColorLoop()
		if not monitor then
			return
		end
		local colors = {}
		for i = 1, 3 do
			local colorPart = monitor:FindFirstChild("Color" .. i)
			if colorPart then
				table.insert(colors, colorPart.Value)
			end
		end
		if #colors == 0 then
			return
		end

		task.spawn(function()
			while devModel.Parent and devModel:GetAttribute("PLAYING_ANIMATION") do
				monitor.Color = colors[math.random(1, #colors)]
				task.wait(1)
			end
		end)
	end

	-- Play/Pause
	if shouldPlay then
		if devModel:GetAttribute("PLAYING_ANIMATION") then
			return
		end
		devModel:SetAttribute("PLAYING_ANIMATION", true)
		startColorLoop()
		if animationTrack then
			animationTrack:Play()
			animationTrack:AdjustSpeed(1)
		end
	else
		devModel:SetAttribute("PLAYING_ANIMATION", false)
		if animationTrack then
			animationTrack:AdjustSpeed(0)
		end
	end
end

function ThreadService:PickRandomGame(games)
	-- Calculate the total chance
	local totalChance = 0
	for _, data in pairs(games) do
		totalChance = totalChance + data.Chance
	end

	local roll = math.random(1, totalChance)

	local accumulated = 0
	for name, data in pairs(games) do
		accumulated = accumulated + data.Chance
		if roll <= accumulated then
			return name
		end
	end
end

function ThreadService:CreateGame(player: Player, devName: string)
	local devEnum = Devs[devName]

	local gameName = ThreadService:PickRandomGame(devEnum.Games)

	local gameEnum = Games[gameName]

	local amountPlayers = math.random(gameEnum.Players.Min, gameEnum.Players.Max)

	return gameName, amountPlayers
end

function ThreadService:GetGameFromPlayerAndDev(player: Player, devId: number)
	if playerGames[player.UserId] then
		local games = playerGames[player.UserId][devId] or {}

		if games then
			playerGames[player.UserId][devId] = {}
		end

		return games
	end
end

function ThreadService:UpdateTotalCCU(player: Player, ccu: number)
	PlayerDataHandler:Update(player, "totalCCU", function(current)
		return current + ccu
	end)

	BaseService:UpdatePlayerCCU(player)
	LeadStatsService:UpdateCCU(player)
end
-- Cria uma thread, responsavel por rodar os trabalhadores para cada jogador
function ThreadService:CreateDevThread(player: Player)
	task.spawn(function()
		local playerFolder = workspace.Runtime[player.UserId]

		while player.Parent do
			local workersPlayer = PlayerDataHandler:Get(player, "workers")

			for _, worker in workersPlayer do
				local model = UtilService:GetDevModel(playerFolder, worker.Id)
				if model then
					-- Representa o tempo de produção do game atual
					local currentGameTime = model:GetAttribute("CURRENT_GAME_TIME") or 0

					-- Representa o tempo pra cada jogo ficar pronto
					local timeToProduceGame = model:GetAttribute("TIME_TO_PRODUCE_GAME")

					-- Representa a quantidade de jogos que estão salvos
					local numberOfGamesStored = model:GetAttribute("NUMBER_OF_GAMES_STORED") or 0

					-- Representa a quantidade de jogos que podem ser produzidos no máximo
					local capacityOfGamesProduced = model:GetAttribute("CAPACITY_OF_GAMES_PRODUCED")

					local gameName, playerAmount = ThreadService:CreateGame(player, model.Name)

					-- Significa que não tem mais espaço de produção
					if numberOfGamesStored >= capacityOfGamesProduced then
						-- Verifica se tem Storage com espaço disponivel
						local hasStorage = StorageService:HasAvailableSpace(player, playerAmount)

						if not hasStorage then
							-- Pausa a animação
							ThreadService:PlayOrPauseWorkerAnimation(model, false)
							model:SetAttribute("CURRENT_PERCENT_PRODUCED", 0)

							continue
						end
					end

					ThreadService:PlayOrPauseWorkerAnimation(model, true)

					-- Atualiza o Tempo que está produzindo o jogo
					currentGameTime = currentGameTime + 1

					-- Deve Produzir mais um jogo
					if timeToProduceGame and (currentGameTime >= timeToProduceGame) then
						-- Verifica se deve usar o Storage
						if numberOfGamesStored >= capacityOfGamesProduced then
							-- Indica que está utilizando o Storage
							model:SetAttribute("USED_STORAGE", true)
							model:SetAttribute("CURRENT_GAME_TIME", 0)
							currentGameTime = 0

							ThreadService:SetGameInStorage(player, gameName, playerAmount, model)

							continue
						end

						-- Indica que não está utilizando o Storage
						model:SetAttribute("USED_STORAGE", false)
						-- Zera o Contador do jogo Atual
						model:SetAttribute("CURRENT_GAME_TIME", 0)

						local spaceLeft = capacityOfGamesProduced - numberOfGamesStored

						-- Se ultrapassar, ajusta playerAmount para apenas o que cabe
						if playerAmount > spaceLeft then
							playerAmount = spaceLeft
						end

						if not playerGames[player.UserId] then
							playerGames[player.UserId] = {}
						end

						if not playerGames[player.UserId][worker.Id] then
							playerGames[player.UserId][worker.Id] = {}
						end

						ThreadService:UpdateTotalCCU(player, playerAmount)

						local storedGamesFromPlayerWorker = playerGames[player.UserId][worker.Id]
						storedGamesFromPlayerWorker[gameName] = (storedGamesFromPlayerWorker[gameName] or 0)
							+ playerAmount

						playerGames[player.UserId][worker.Id] = storedGamesFromPlayerWorker

						model:SetAttribute("STORED_GAME_" .. gameName, storedGamesFromPlayerWorker[gameName])

						model:SetAttribute("CURRENT_PERCENT_PRODUCED", 100)

						-- Incrementa a quantidade de jogodos produzidos
						model:SetAttribute("NUMBER_OF_GAMES_STORED", numberOfGamesStored + playerAmount)

						continue
					end

					model:SetAttribute("CURRENT_PERCENT_PRODUCED", (currentGameTime / timeToProduceGame) * 100)

					local currentPercentCapacity = (model:GetAttribute("NUMBER_OF_GAMES_STORED") or 0)
						/ capacityOfGamesProduced

					model:SetAttribute("CURRENT_PERCENT_CAPACITY", currentPercentCapacity * 100)

					model:SetAttribute("CURRENT_GAME_TIME", currentGameTime)
				end
			end

			task.wait(1)
		end
	end)
end

function ThreadService:SetGameInStorage(player: Player, gameName: string, playerAmount: number, devModel: model)
	local currentUsedStorage, limitedStorage = StorageService:GetCurrentUsedAndLimited(player)

	-- Calcula o espaço restante
	local spaceLeft = limitedStorage - currentUsedStorage

	-- Se ultrapassar, ajusta playerAmount para apenas o que cabe
	if playerAmount > spaceLeft then
		playerAmount = spaceLeft
	end

	local hasAvailableSpaceInStorage = StorageService:HasAvailableSpace(player, playerAmount)

	-- PlayerAmount = 0 Signofica que não tem mais espaço pra armazenar aquee jogo
	if not hasAvailableSpaceInStorage or playerAmount <= 0 then
		devModel:SetAttribute("CURRENT_PERCENT_PRODUCED", 0)
		devModel:SetAttribute("CURRENT_GAME_TIME", 0)
		return
	end

	StorageService:AddGame(player, gameName, playerAmount)

	return true
end

function ThreadService:SetGameInDev(
	player: Player,
	model: Model,
	devId: number,
	capacityOfGamesProduced: number,
	numberOfGamesStored: number,
	gameName: string,
	playerAmount: number
)
	-- Calcula o espaço restante
	local spaceLeft = capacityOfGamesProduced - numberOfGamesStored

	-- Se ultrapassar, ajusta playerAmount para apenas o que cabe
	if playerAmount > spaceLeft then
		playerAmount = spaceLeft
	end

	numberOfGamesStored = numberOfGamesStored + playerAmount
	-- Incrementa a quantidade de jogodos produzidos
	model:SetAttribute("NUMBER_OF_GAMES_STORED", numberOfGamesStored)

	if not playerGames[player.UserId] then
		playerGames[player.UserId] = {}
	end

	if not playerGames[player.UserId][devId] then
		playerGames[player.UserId][devId] = {}
	end

	ThreadService:UpdateTotalCCU(player, playerAmount)

	local storedGamesFromPlayerWorker = playerGames[player.UserId][devId]
	storedGamesFromPlayerWorker[gameName] = (storedGamesFromPlayerWorker[gameName] or 0) + playerAmount

	playerGames[player.UserId][devId] = storedGamesFromPlayerWorker

	model:SetAttribute("STORED_GAME_" .. gameName, storedGamesFromPlayerWorker[gameName])
end

function ThreadService:UpdateDevCurrentTime(model: Model, currentGameTime: number, timeToProduceGame: number)
	model:SetAttribute("CURRENT_GAME_TIME", currentGameTime)
	model:SetAttribute("CURRENT_PERCENT_PRODUCED", (currentGameTime / timeToProduceGame) * 100)
end

function ThreadService:UpdateCurrentPercentCapacity(model: Model, capacityOfGamesProduced: number)
	local currentPercentCapacity = (model:GetAttribute("NUMBER_OF_GAMES_STORED") or 0) / capacityOfGamesProduced
	model:SetAttribute("CURRENT_PERCENT_CAPACITY", currentPercentCapacity * 100)
end

function ThreadService:InitPlayerGames(player: Player)
	playerGames[player] = {}
end
return ThreadService
