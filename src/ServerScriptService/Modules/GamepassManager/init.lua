local GamepassManager = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductFunctions = require(script.ProductFunctions)
local GamepassEnum = require(ReplicatedStorage.Enums.Gamepass)

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Gamepass = require(ReplicatedStorage.Enums.Gamepass)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("GamepassService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function GamepassManager:Init()
	GamepassManager:StartListner()
	GamepassManager:InitBridgeListener()
end

function GamepassManager:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "HasGamePass" then
			local gamepassId = data.data.GamepassId
			return GamepassManager:HasGamePass(player, gamepassId)
		end
	end
end

function GamepassManager:StartListner()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassID, wasPurchased)
		if wasPurchased then
			local grantPurchaseHandler = ProductFunctions[purchasedPassID]
			grantPurchaseHandler(player)
		end
	end)
end

function GamepassManager:HasGamePass(player, gamepassId)
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)

	return success and hasPass
end

function GamepassManager:InitGamePassesFromPlayer(player: Player)
	local hasAutoSell = GamepassManager:HasGamePass(player, Gamepass.ENUM.AUTO_SELL)
	local hasAutoSellDataHandler = PlayerDataHandler:Get(player, "hasAutoSell")
	if hasAutoSell or hasAutoSellDataHandler then
		PlayerDataHandler:Set(player, "hasAutoSell", true)
		player:SetAttribute("HAS_AUTO_SELL", true)
	end
end
return GamepassManager
