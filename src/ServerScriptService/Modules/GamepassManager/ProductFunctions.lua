local ProductFunctions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Gamepass = require(ReplicatedStorage.Enums.Gamepass)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local AutoSellService = require(ServerScriptService.Modules.AutoSellService)
local OfflineGameService = require(ServerScriptService.Modules.OfflineGameService)

ProductFunctions[Gamepass:GetEnum("VIP").Id] = function(player)
	PlayerDataHandler:Set(player, "isVip", true)
	return true
end

ProductFunctions[Gamepass:GetEnum("AUTO_SELL").Id] = function(player)
	AutoSellService:BuyAutoCollect(player)
	return true
end

ProductFunctions[Gamepass:GetEnum("x2_COLLECT").Id] = function(player)
	OfflineGameService:Buy2XCollect(player)

	return true
end

return ProductFunctions
