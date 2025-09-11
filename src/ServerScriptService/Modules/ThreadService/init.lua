local ThreadService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)
local BaseService = require(ServerScriptService.Modules.BaseService)
local StorageService = require(ServerScriptService.Modules.StorageService)

local playerGames = {}

function ThreadService:Init() end

function ThreadService:PlayOrPauseWorkerAnimation(devModel: Model, shouldPlay: boolean)
	if shouldPlay and not devModel:GetAttribute("PLAYING_ANIMATION") then
		devModel:SetAttribute("PLAYING_ANIMATION", true)
		local monitor = devModel:FindFirstChild("Monitor")
		if monitor then
			task.spawn(function()
				local color1 = monitor.Color1
				local color2 = monitor.Color2
				local color3 = monitor.Color3
				local colors = { color1, color2, color3 }

				while shouldPlay do
					local randomColor = colors[math.random(1, #colors)]
					monitor.Color = randomColor.Value
					-- Pegar uma das 3 cores aleatorioas
					task.wait(1)
				end
			end)
		end

		local animationController = devModel.Rig:FindFirstChild("AnimationController")
		local animator = animationController:FindFirstChild("Animator")
		local animation = animator:FindFirstChild("Animation")
		-- Carregando no Animator
		local animationTrack = animator:LoadAnimation(animation)

		-- Tocando a animação
		animationTrack:Play()
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

					--	model.ExclamationBillboardGui.Enabled = false
					ThreadService:PlayOrPauseWorkerAnimation(model, true)

					-- Atualiza o Tempo que está produzindo o jogo
					currentGameTime = currentGameTime + 1

					-- Significa que deve produzir um jogo, pois já chegou

					-- Ao Tempo de Produção
					if timeToProduceGame and currentGameTime >= timeToProduceGame then
						-- Verificando se tem espaço disponivel
						-- ou armazena no storage

						-- Armazena no Dev
						print("Numero de Player Produzidos: " .. numberOfGamesStored)
						print("Capacidade " .. capacityOfGamesProduced)

						if numberOfGamesStored < capacityOfGamesProduced then
							model:SetAttribute("MAXIMUM_CAPACITY_REACHED", false)
							print("Armazenando em Dev")
							-- Indica que não está com a capacidade máxima atingida
							model:SetAttribute("MAXIMUM_CAPACITY_REACHED", false)

							-- Indica que não está utilizando o Storage
							model:SetAttribute("USED_STORAGE", false)

							-- Zera o Contador do jogo Atual
							model:SetAttribute("CURRENT_GAME_TIME", 0)

							-- Porcentagem do jogo vai para 100%
							model:SetAttribute("CURRENT_PERCENT_PRODUCED", 100)

							-- Insere um Game na memoria do dev
							ThreadService:SetGameInDev(
								player,
								model,
								worker.Id,
								capacityOfGamesProduced,
								numberOfGamesStored,
								gameName,
								playerAmount
							)

							continue
						end

						-- Armazena no Storage
						if numberOfGamesStored >= capacityOfGamesProduced then
							print("Armazenando No storage")

							model:SetAttribute("MAXIMUM_CAPACITY_REACHED", true)
							ThreadService:SetGameInStorage(player, gameName, playerAmount, model)
							continue
						end

						-- Significa que não possui mais espaço em nenhum local
						model:SetAttribute("MAXIMUM_CAPACITY_REACHED", true)
						continue
					end

					-- Significa que ainda está produzindo um jogo
					ThreadService:UpdateDevCurrentTime(model, currentGameTime, timeToProduceGame)

					-- Atualiza o percentual de uso do dev
					ThreadService:UpdateCurrentPercentCapacity(model, capacityOfGamesProduced)
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
	print("Limite:" .. tostring(hasAvailableSpaceInStorage))

	-- PlayerAmount = 0 Signofica que não tem mais espaço pra armazenar aquee jogo
	if not hasAvailableSpaceInStorage or playerAmount <= 0 then
		devModel:SetAttribute("CURRENT_PERCENT_PRODUCED", 0)
		devModel:SetAttribute("CURRENT_GAME_TIME", 0)
		return
	end

	StorageService:AddGame(player, gameName, playerAmount)
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
