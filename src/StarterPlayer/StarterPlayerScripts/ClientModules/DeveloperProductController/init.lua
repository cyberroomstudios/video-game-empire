local DeveloperProductController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)

function DeveloperProductController:Init(data) end

function DeveloperProductController:OpenPaymentRequestScreen(developerProductName: string)
	local developerProduct = DeveloperProducts:GetEnum(developerProductName)

	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, developerProduct.Id)
end

function DeveloperProductController:GetProductPrice(developerProductName: string)
	local success, productInfo = pcall(function()
		local developerProduct = DeveloperProducts:GetEnum(developerProductName)

		return MarketplaceService:GetProductInfo(developerProduct.Id, Enum.InfoType.Product)
	end)
	if success and productInfo then
		return productInfo.PriceInRobux
	else
		warn("Não foi possível obter info do produto:", productInfo)
		return nil
	end
end

return DeveloperProductController
