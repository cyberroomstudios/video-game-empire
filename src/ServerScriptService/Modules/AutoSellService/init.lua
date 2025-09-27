local AutoSellService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local GameService = require(ServerScriptService.Modules.GameService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("AutoSellService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
function AutoSellService:Init()
	AutoSellService:InitBridgeListener()
end

function AutoSellService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "ActiveAutoSell" then
			return AutoSellService:ActiveAutoSell(player)
		end

		if data[actionIdentifier] == "InactiveAutoCollect" then
			return AutoSellService:InactiveAutoSell(player)
		end
	end
end

function AutoSellService:ActiveAutoSell(player: Player)
	if PlayerDataHandler:Get(player, "hasAutoSell") then
		player:SetAttribute("ACTIVE_AUTO_SELL", true)
		task.spawn(function()
			while player and player.Parent and player:GetAttribute("ACTIVE_AUTO_SELL") do
				
				if not player:GetAttribute("COLLETING") then
					GameService:SellAllGame(player)
				end

				task.wait(3)
			end
		end)
	end
end

function AutoSellService:InactiveAutoSell(player: Player)
	player:SetAttribute("ACTIVE_AUTO_SELL", false)
end

function AutoSellService:BuyAutoSell(player: Player)
	PlayerDataHandler:Update(player, "hasAutoSell", function(current)
		return true
	end)
	player:SetAttribute("HAS_AUTO_SELL", true)

	AutoSellService:ActiveAutoSell(player)
end

return AutoSellService
