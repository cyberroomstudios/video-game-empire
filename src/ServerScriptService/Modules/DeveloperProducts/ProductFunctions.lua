local ProductFunctions = {}
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)
local StockService = require(ServerScriptService.Modules.StockService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

ProductFunctions[DeveloperProducts:GetEnum("RESTOCK").Id] = function(receipt, player)
	StockService:RestockAllFromRobux()
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("RESTOCK").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("RESTOCK_THIS").Id] = function(receipt, player)
	StockService:RestockThisFromRobux(player)
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("RESTOCK_THIS").Id)
	return true
end

function ProductFunctions:AddRobuxSpent(player: Player, productId: number)
	local info = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
	if info then
		local priceInRobux = info.PriceInRobux

		PlayerDataHandler:Update(player, "robuxSpent", function(current)
			return current + priceInRobux
		end)
	end
end
return ProductFunctions
