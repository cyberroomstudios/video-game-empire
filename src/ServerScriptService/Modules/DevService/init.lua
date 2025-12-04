local DevService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local ToolService = require(ServerScriptService.Modules.ToolService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

local GameService = require(ServerScriptService.Modules.GameService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)

local bridge = BridgeNet2.ReferenceBridge("DevService")
local bridgeUIStateService = BridgeNet2.ReferenceBridge("UIStateService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function DevService:Init()
	DevService:InitBridgeListener()
end

function DevService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "BuyDev" then
			local devName = data.data.DevName
			DevService:BuyDev(player, devName)
		end

		if data[actionIdentifier] == "GetMoney" then
			local devId = data.data.DevId
			DevService:GetMoney(player, devId)
		end
		if data[actionIdentifier] == "DeleteDev" then
			local devId = data.data.DevId
			DevService:DeleteDevInMap(player, devId)
			DevService:DeleteInDataBase(player, devId)
		end
	end
end

function DevService:HasDevInPlayerData(player: Player, devName: string)
	local workers = PlayerDataHandler:Get(player, "workersInBackpack")

	for _, worker in workers do
		if worker == devName then
			return true
		end
	end

	return false
end

function DevService:ConsumeDev(player: Player, devName: string)
	PlayerDataHandler:Update(player, "workersInBackpack", function(current)
		local newData = {}
		local deleted = false

		for _, dev in current do
			if dev == devName and not deleted then
				deleted = true
				continue
			end

			table.insert(newData, dev)
		end

		return newData
	end)
end

function DevService:SaveDevInDataHandler(player: Player, devName: string, cFrame: CFrame, floor: number)
	local devFolder = ReplicatedStorage.Model.Devs
	local model = devFolder:FindFirstChild(devName):Clone()

	local devId = nil

	local base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]
	model:PivotTo(cFrame)

	local relativeCFrame = base["WorkArea"].WorkArea.CFrame:ToObjectSpace(model.PrimaryPart.CFrame)

	-- Monta o objeto a ser salvo
	local data = {
		Id = PlayerDataHandler:Get(player, "workerId"),
		Name = devName,
		RelativeCFrame = UtilService:SerializeCFrame(relativeCFrame),
		Floor = floor,
	}

	PlayerDataHandler:Update(player, "workers", function(current)
		table.insert(current, data)
		return current
	end)

	PlayerDataHandler:Update(player, "workerId", function(current)
		devId = current
		return devId + 1
	end)

	return devId
end

function DevService:GetMoney(player: Player, devId: number)
	local playerFolder = workspace.Runtime:FindFirstChild(player.UserId)
	local devFolder = playerFolder.Devs
	for _, value in devFolder:GetChildren() do
		if value:GetAttribute("ID") == devId then
			local money = value:GetAttribute("TOTAL_MONEY") or 0

			if money > 0 then
				MoneyService:GiveMoney(player, money)
				value:SetAttribute("TOTAL_MONEY", 0)
			end
		end
	end
end

function DevService:InitBaseFromPlayer(player: Player)
	local devs = PlayerDataHandler:Get(player, "workers")

	for _, dev in devs do
		local devName = dev.Name
		local devId = dev.Id
		local relativeCFrame = UtilService:DeserializeCFrame(dev.RelativeCFrame)
		local floor = dev.Floor
		local base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]

		local worldCFrame = base.WorkArea.WorkArea.CFrame:ToWorldSpace(relativeCFrame)

		DevService:SetDevInMap(player, devId, devName, worldCFrame, floor)
	end
end

function DevService:SetDevInMap(player: Player, devId: number, devName: string, cFrame: CFrame, floor: number)
	local devFolder = ReplicatedStorage.Model.Devs

	if devFolder:FindFirstChild(devName) then
		local model = devFolder:FindFirstChild(devName):Clone()

		local hightlight = Instance.new("Highlight")
		hightlight.FillColor = Color3.new(255, 255, 255)
		hightlight.FillTransparency = 0
		hightlight.Parent = model

		local devEnum = Devs[devName]

		if not devEnum then
			warn("Dev Enum not found")
			return
		end

		-- Obtem a referencia do eixo Y com base no andar que o worker está instalado
		local base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]

		local yPosition = workspace:GetAttribute("DEV_Y_POSITION")

		if floor > 0 then
			yPosition = base.mapa["FLOOR_" .. floor].Floor.Carpet.Part.Position.Y + 3
		end

		-- Calcula a altura da base da PrimaryPart
		local primaryPart = model.PrimaryPart
		local halfHeight = primaryPart.Size.Y / 2

		-- Cria um novo CFrame com a base da PrimaryPart em yPosition
		local newPosition = Vector3.new(cFrame.Position.X, yPosition + halfHeight, cFrame.Position.Z)
		local newCFrame = CFrame.new(newPosition) * CFrame.Angles(select(1, cFrame:ToEulerAnglesXYZ()))

		-- Cria um novo CFrame, mudando apenas a altura do andar
		local newCFrame = CFrame.new(cFrame.Position.X, yPosition, cFrame.Position.Z) * cFrame - cFrame.Position

		model["bounding_box"].Transparency = 1

		model:SetAttribute("ID", devId)
		model:SetAttribute("DEV", true)
		model:SetAttribute("TIME_TO_PRODUCE_GAME", devEnum.TimeToProduceGame)
		model:SetAttribute("CAPACITY_OF_GAMES_PRODUCED", devEnum.CapacityOfGamesProduced)

		model:SetPrimaryPartCFrame(newCFrame)
		model.Parent = workspace.Runtime[player.UserId].Devs

		task.delay(0.2, function()
			if model:FindFirstChild("Highlight") then
				model.Highlight:Destroy()
			end
		end)

		-- Cria o Som
		DevService:StartDevSound(player, devId)
		return
	end

	warn("Dev not found")
end

function DevService:GetMoneyFromDev(player: Player, model: Model)
	local money = model:GetAttribute("TOTAL_MONEY") or 0
	if money > 0 then
		DevService:EnableGetMoneyEffect(model)
		model:SetAttribute("TOTAL_MONEY", 0)
		MoneyService:GiveMoney(player, money)
	end
end

function DevService:StartDevSound(player: Player, devId: number)
	bridge:Fire(player, {
		[actionIdentifier] = "StartDevSound",
		data = {
			DevId = devId,
		},
	})
end

function DevService:GiveDev(player: Player, devName: string)
	PlayerDataHandler:Update(player, "workersInBackpack", function(current)
		table.insert(current, devName)
		return current
	end)
end

function DevService:GiveDevFromRobux(player: Player, devName: string)
	-- Salva no banco de dados
	DevService:GiveDev(player, devName)

	-- Da uma tool ao jogador
	ToolService:GiveDevTool(player, devName)
end

function DevService:GiveDevFromCrate(player: Player, devName: string)
	-- Salva no banco de dados
	DevService:GiveDev(player, devName)

	-- Da uma tool ao jogador
	ToolService:GiveDevTool(player, devName)
end

function DevService:VerifyNewGames(player: Player, collectGames)
	local index = PlayerDataHandler:Get(player, "index")

	local indexLookup = {}
	for _, indexGame in ipairs(index) do
		indexLookup[indexGame] = true
	end

	local newGames = {}
	for gameName, gameAmount in collectGames do
		if not indexLookup[gameName] then
			table.insert(newGames, gameName)
		end
	end

	if #newGames > 0 then
		bridgeUIStateService:Fire(player, {
			[actionIdentifier] = "ShowNewGame",
			data = {
				NewGames = newGames,
			},
		})
	end

	--
end

function DevService:GetModel(player: Player, devId: number)
	local runtimeFolder = workspace.Runtime
	local playerFolder = runtimeFolder[player.UserId]
	local devFolder = playerFolder:FindFirstChild("Dev")

	for _, value in devFolder:GetChildren() do
		if value:GetAttribute("DEV") and value:GetAttribute("ID") == devId then
			return value
		end
	end
end

function DevService:DeleteInDataBase(player: Player, devId: number)
	PlayerDataHandler:Update(player, "workers", function(current)
		local newDevs = {}
		for _, value in current do
			if value.Id == devId then
				continue
			end
			table.insert(newDevs, value)
		end
		return newDevs
	end)
end

function DevService:DeleteDevInMap(player: Player, devId: number)
	for _, value in game.Workspace.Runtime.Devs[player.UserId]:GetChildren() do
		if value:GetAttribute("DEV") and value:GetAttribute("ID") == devId then
			value:Destroy()
		end
	end
end

function DevService:DrawDevFromRarity(player: Player, rarity: string)
	local devs = Devs
	local devsFromRarity = {}

	for _, value in devs do
		if value.Rarity == rarity then
			table.insert(devsFromRarity, value)
		end
	end

	-- Caso não exista nenhum dev dessa raridade
	if #devsFromRarity == 0 then
		warn("Nenhum Dev encontrado com a raridade:", rarity)
		return nil
	end

	-- Sorteia 1 entre os filtrados
	local randomIndex = Random.new():NextInteger(1, #devsFromRarity)
	local selectedDev = devsFromRarity[randomIndex]

	return selectedDev.Name
end

function DevService:GetRandomDev(player: Player, amount: number)
	local devs = Devs
	local total = #devs

	-- Faz uma cópia da lista
	local devsCopy = table.clone(devs)

	-- Embaralhar usando Fisher–Yates
	for i = #devsCopy, 2, -1 do
		local j = math.random(1, i)
		devsCopy[i], devsCopy[j] = devsCopy[j], devsCopy[i]
	end

	-- Se pedirem mais do que existe, retorna todos os Names embaralhados
	if amount >= total then
		local names = {}
		for i, dev in devsCopy do
			names[i] = dev.Name
		end
		return names
	end

	-- Pegar apenas os X primeiros e retornar somente o Name
	local result = {}

	for i = 1, amount do
		result[i] = devsCopy[i].Name
	end

	return result
end

return DevService
