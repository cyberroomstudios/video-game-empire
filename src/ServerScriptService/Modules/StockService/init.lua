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

local ready = false
local globalStock = {}

function StockService:Init()
	StockService:InitStockCounter()
end

function StockService:InitStockCounter()
	task.spawn(function()
		while true do
			StockService:CreateStock()
			task.wait(20)
		end
	end)
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
