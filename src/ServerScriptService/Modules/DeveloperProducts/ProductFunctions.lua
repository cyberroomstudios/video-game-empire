local ProductFunctions = {}
local MarketplaceService = game:GetService("MarketplaceService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)
local StockService = require(ServerScriptService.Modules.StockService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local DevService = require(ServerScriptService.Modules.DevService)
local AutoCollectService = require(ServerScriptService.Modules.AutoCollectService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

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

ProductFunctions[DeveloperProducts:GetEnum("UNLOCK_AUTO_COLLECT").Id] = function(receipt, player)
	AutoCollectService:BuyAutoCollect(player)
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("UNLOCK_AUTO_COLLECT").Id)
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

ProductFunctions[DeveloperProducts:GetEnum("CONCEPET_ARTIST").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "5_ConceptArtist")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("CONCEPET_ARTIST").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("TECH_LEAD").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "6_TechLead")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("TECH_LEAD").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("GAME_TESTER").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "7_GameTester")
	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("GAME_TESTER").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("STARTER_PACK_1").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "2_JuniorDev")
	DevService:GiveDevFromRobux(player, "3_MidLevelDev")
	MoneyService:GiveMoney(player, 500)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("STARTER_PACK_1").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("STARTER_PACK_2").Id] = function(receipt, player)
	for i = 1, 3 do
		DevService:GiveDevFromRobux(player, "2_JuniorDev")
		DevService:GiveDevFromRobux(player, "3_MidLevelDev")
		MoneyService:GiveMoney(player, 500)
	end

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("STARTER_PACK_2").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("STARTER_PACK_3").Id] = function(receipt, player)
	for i = 1, 10 do
		DevService:GiveDevFromRobux(player, "2_JuniorDev")
		DevService:GiveDevFromRobux(player, "3_MidLevelDev")
		MoneyService:GiveMoney(player, 500)
	end

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("STARTER_PACK_3").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("OP_PACK_1").Id] = function(receipt, player)
	DevService:GiveDevFromRobux(player, "6_TechLead")
	DevService:GiveDevFromRobux(player, "7_GameTester")
	MoneyService:GiveMoney(player, 1000)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("CONCEPET_ARTIST").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("OP_PACK_2").Id] = function(receipt, player)
	for i = 1, 3 do
		DevService:GiveDevFromRobux(player, "6_TechLead")
		DevService:GiveDevFromRobux(player, "7_GameTester")
		MoneyService:GiveMoney(player, 1000)
	end

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("OP_PACK_2").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("OP_PACK_3").Id] = function(receipt, player)
	for i = 1, 10 do
		DevService:GiveDevFromRobux(player, "6_TechLead")
		DevService:GiveDevFromRobux(player, "7_GameTester")
		MoneyService:GiveMoney(player, 1000)
	end

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("OP_PACK_3").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_1").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 100)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_1").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_2").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 300)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_2").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_3").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 500)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_3").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_4").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 700)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_4").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_5").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 900)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_5").Id)
	return true
end

ProductFunctions[DeveloperProducts:GetEnum("MONEY_6").Id] = function(receipt, player)
	MoneyService:GiveMoney(player, 2000)

	ProductFunctions:AddRobuxSpent(player, DeveloperProducts:GetEnum("MONEY_6").Id)
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
