local ProductFunctions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Gamepass = require(ReplicatedStorage.Enums.Gamepass)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local AutoSellService = require(ServerScriptService.Modules.AutoSellService)

ProductFunctions[Gamepass:GetEnum("VIP").Id] = function(player)
	PlayerDataHandler:Set(player, "isVip", true)
	return true
end
ProductFunctions[Gamepass:GetEnum("AUTO_SELL").Id] = function(player)
	print("Comprou")
	AutoSellService:BuyAutoCollect(player)
	return true
end

return ProductFunctions
