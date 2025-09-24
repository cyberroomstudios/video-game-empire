local StockService = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Devs = require(ReplicatedStorage.Enums.Devs)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)

local ready = false
local globalStock = {}
local restockThisIntentFromPlayer = {}

local TIME_TO_RELOAD_STOCK = 10
local currentTimeToReload

function StockService:Init()
	StockService:InitBridgeListener()
	StockService:InitStockCounter()
end

function StockService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "SetRestockThisIntent" then
			local devName = data.data.DevName
			restockThisIntentFromPlayer[player] = devName
		end
	end
end

function StockService:InitStockCounter()
	currentTimeToReload = TIME_TO_RELOAD_STOCK
	task.spawn(function()
		while true do
			StockService:CreateStock()
			while currentTimeToReload > 0 do
				currentTimeToReload = currentTimeToReload - 1
				workspace:SetAttribute("TIME_TO_RELOAD_RESTOCK", currentTimeToReload)
				task.wait(1)
			end

			currentTimeToReload = TIME_TO_RELOAD_STOCK
			GameNotificationService:ShowStockNotification()
		end
	end)
end

function StockService:RestockAllFromRobux()
	currentTimeToReload = 0
end

function StockService:RestockThisFromRobux(player: Player)
	if restockThisIntentFromPlayer[player] then
		local devName = restockThisIntentFromPlayer[player]
		local devEnum = Devs[devName]
		local amount = math.random(devEnum.Stock.Min, devEnum.Stock.Max)

		globalStock[devName] = amount

		local globalStockCount = workspace:GetAttribute("GLOBAL_STOCK_COUNT") or 0
		workspace:SetAttribute("GLOBAL_STOCK_COUNT", globalStockCount + 1)

		StockService:UpdateAllPlayers()
		restockThisIntentFromPlayer[player] = nil
	end
end

function StockService:CreateStock()
	local devs = Devs

	for _, dev in devs do
		local stockChance = dev.Stock.Chance
		local randomNumber = math.random(1, 100)

		if randomNumber <= stockChance then
			local amount = math.random(dev.Stock.Min, dev.Stock.Max)

			globalStock[dev.Name] = amount
		else
			globalStock[dev.Name] = 0
		end
	end

	local globalStockCount = workspace:GetAttribute("GLOBAL_STOCK_COUNT") or 0
	workspace:SetAttribute("GLOBAL_STOCK_COUNT", globalStockCount + 1)

	ready = true
	StockService:UpdateAllPlayers()
end

function StockService:UpdateAllPlayers()
	for _, player in Players:GetPlayers() do
		StockService:AddPlayerStock(player)
	end
end

-- Responsavel por adicionar o stock de um player
function StockService:AddPlayerStock(player: Player)
	while not ready do
		task.wait(0.1)
	end

	for index, value in globalStock do
		player:SetAttribute(index, value)
	end
end

function StockService:HasStock(player: Player, devName: string)
	local stock = player:GetAttribute(devName) or 0
	return stock > 0
end

function StockService:ConsumeStock(player: Player, devName: string)
	local stock = player:GetAttribute(devName)
	player:SetAttribute(devName, stock - 1)

	bridge:Fire(player, {
		[actionIdentifier] = "UpdateStock",
		data = {
			DevName = devName,
			Amount = player:GetAttribute(devName),
		},
	})
end

return StockService
