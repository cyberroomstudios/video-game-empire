local DevService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)
local Devs = require(ReplicatedStorage.Enums.Devs)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local StockService = require(ServerScriptService.Modules.StockService)
local ToolService = require(ServerScriptService.Modules.ToolService)
local ThreadService = require(ServerScriptService.Modules.ThreadService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

local GameService = require(ServerScriptService.Modules.GameService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)

local bridge = BridgeNet2.ReferenceBridge("DevService")
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

		if data[actionIdentifier] == "GetGames" then
			local devId = data.data.DevId
			return DevService:GetGamesFromDev(player, devId)
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
		model.Parent = workspace.Runtime[player.UserId]

		-- Cria o Proximity
		DevService:CreateDevProximityPrompt(player, devId)

		return
	end

	warn("Dev not found")
end

function DevService:CreateDevProximityPrompt(player: Player, devId: number)
	bridge:Fire(player, {
		[actionIdentifier] = "CreateProximity",
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

function DevService:GetGamesFromDev(player: Player, devId: number)
	local games = ThreadService:GetGameFromPlayerAndDev(player, devId)

	if games then
		player:SetAttribute("COLLETING", true)
		local model = DevService:GetModel(player, devId)

		for gameName, amount in games do
			GameService:GiveGame(player, gameName, amount)
			model:SetAttribute("STORED_GAME_" .. gameName, 0)
		end
		model:SetAttribute("NUMBER_OF_GAMES_STORED", 0)

		player:SetAttribute("COLLETING", false)
		return games
	end
end

function DevService:GetModel(player: Player, devId: number)
	local runtimeFolder = workspace.Runtime
	local playerFolder = runtimeFolder[player.UserId]

	for _, value in playerFolder:GetChildren() do
		if value:GetAttribute("DEV") and value:GetAttribute("ID") == devId then
			return value
		end
	end
end

function DevService:BuyDev(player: Player, devName: string)
	local devEnum = Devs[devName]

	if not devEnum then
		warn("Dev Enum not found")
		return
	end

	-- Verifica se existe o item no stock do jogador
	local hasStock = StockService:HasStock(player, devName)

	if not hasStock then
		GameNotificationService:SendErrorNotification(player, "No Stock!")
		return false
	end

	-- Verifica se tem Dinheiro
	if not MoneyService:HasMoney(player, devEnum.Price) then
		GameNotificationService:SendErrorNotification(player, "Not Enough Money!")
		return false
	end

	-- Consume o Dinheiro
	MoneyService:ConsumeMoney(player, devEnum.Price)
	-- Consume o Stock
	StockService:ConsumeStock(player, devName)

	-- Salva no banco de dados
	DevService:GiveDev(player, devName)

	-- Da uma tool ao jogador
	ToolService:GiveDevTool(player, devName)

	return true
end

function DevService:DeleteDevInMap(player: Player, devId: number)
	for _, value in game.Workspace.Runtime[player.UserId]:GetChildren() do
		if value:GetAttribute("DEV") and value:GetAttribute("ID") == devId then
			value:Destroy()
		end
	end
end

return DevService
