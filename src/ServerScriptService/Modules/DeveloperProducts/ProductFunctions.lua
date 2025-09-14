local ProductFunctions = {}
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)
local StockService = require(ServerScriptService.Modules.StockService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local DevService = require(ServerScriptService.Modules.DevService)

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

ProductFunctions[DeveloperProducts:GetEnum("DEV_INTERN").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "1_DevIntern")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("DEV_INTERN").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("JUNIOR_DEVELOPER").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "2_JuniorDev")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("JUNIOR_DEVELOPER").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MID_LEVEL_DEVELOPER").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "3_MidLevelDev")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MID_LEVEL_DEVELOPER").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("SENIOR_DEVELOPER").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "4_SeniorDev")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("SENIOR_DEVELOPER").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("CONCEPET_ARTIST").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "5_ConceptArtist")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("CONCEPET_ARTIST").Id)
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
