local StorageService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local UtilService = require(ServerScriptService.Modules.UtilService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local GameService = require(ServerScriptService.Modules.GameService)
local bridge = BridgeNet2.ReferenceBridge("StorageService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local storagePlayers = {}

function StorageService:Init()
	StorageService:InitBridgeListener()
end

function StorageService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetStorage" then
			local baseNumber = data.data.BaseNumber
			
			StorageService:GetStorage(player, baseNumber)
		end
	end
end

function StorageService:GetStorage(player: Player, baseNumber: number)
	if tonumber(baseNumber) ~= tonumber(player:GetAttribute("BASE")) then
		return
	end

	local storage = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"BaseMaps",
		player:GetAttribute("BASE"),
		"mapa",
		"ModuleBuilding",
		"Mainbuilding",
		"FloorBase",
		"Storage",
		"ProximityPart"
	)

	local gamesFromPlayerStorage = storagePlayers[player.UserId]

	if gamesFromPlayerStorage then
		player:SetAttribute("COLLETING", true)
		storage:SetAttribute("COLLETING", true)

		for gameName, amount in gamesFromPlayerStorage do
			GameService:GiveGame(player, gameName, amount)
			storage:SetAttribute("STORED_GAME_" .. gameName, 0)
		end

		storage:SetAttribute("CURRENT_USED", 0)

		storage:SetAttribute("COLLETING", false)
		player:SetAttribute("COLLETING", false)
	end
	storage:SetAttribute("CURRENT_PERCENT_USED", 0)

	storagePlayers[player.UserId] = {}

	
end

function StorageService:AddGame(player: Player, gameName: string, playerAmount: string)
	if not StorageService:HasAvailableSpace(player, playerAmount) then
		return
	end

	local storage = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"BaseMaps",
		player:GetAttribute("BASE"),
		"mapa",
		"ModuleBuilding",
		"Mainbuilding",
		"FloorBase",
		"Storage",
		"ProximityPart"
	)

	if storage:GetAttribute("COLLETING") then
		task.wait()
	end

	local oldGameValue = storage:GetAttribute("STORED_GAME_" .. gameName) or 0
	storage:SetAttribute("STORED_GAME_" .. gameName, oldGameValue + playerAmount)

	local oldValue = storage:GetAttribute("CURRENT_USED") or 0

	storage:SetAttribute("CURRENT_USED", oldValue + playerAmount)

	local currentPercentCapacity = (storage:GetAttribute("CURRENT_USED"))
		/ PlayerDataHandler:Get(player, "storageLimited")

	storage:SetAttribute("CURRENT_PERCENT_USED", currentPercentCapacity)

	local oldPlayerAmount = storagePlayers[player.UserId] or 0

	oldPlayerAmount = storagePlayers[player.UserId][gameName] or 0

	storagePlayers[player.UserId][gameName] = oldPlayerAmount + playerAmount
end

function StorageService:InitStorage(player: Player)
	local storage = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"BaseMaps",
		player:GetAttribute("BASE"),
		"mapa",
		"ModuleBuilding",
		"Mainbuilding",
		"FloorBase",
		"Storage",
		"ProximityPart"
	)

	local storageLimit = PlayerDataHandler:Get(player, "storageLimited")
	storage:SetAttribute("LIMITED", storageLimit)
	storagePlayers[player.UserId] = {}
end

function StorageService:HasAvailableSpace(player: Player, amount: number)
	local storage = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"BaseMaps",
		player:GetAttribute("BASE"),
		"mapa",
		"ModuleBuilding",
		"Mainbuilding",
		"FloorBase",
		"Storage",
		"ProximityPart"
	)

	local limited = storage:GetAttribute("LIMITED")
	local currentUsed = storage:GetAttribute("CURRENT_USED") or 0

	return currentUsed + amount <= limited
end

function StorageService:GetCurrentUsedAndLimited(player: Player)
	local storage = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"BaseMaps",
		player:GetAttribute("BASE"),
		"mapa",
		"ModuleBuilding",
		"Mainbuilding",
		"FloorBase",
		"Storage",
		"ProximityPart"
	)

	local currentUsed = storage:GetAttribute("CURRENT_USED") or 0
	local limited = storage:GetAttribute("LIMITED")

	return currentUsed, limited
end

return StorageService
