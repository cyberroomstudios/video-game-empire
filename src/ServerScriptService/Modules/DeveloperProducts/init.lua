local DeveloperProducts = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ProductFunctions = require(ServerScriptService.Modules.DeveloperProducts.ProductFunctions)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

function DeveloperProducts:Init()
	DeveloperProducts:InitRecepeit()
end

function DeveloperProducts:InitRecepeit()
	local function processReceipt(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local grantPurchaseHandler = ProductFunctions[receiptInfo.ProductId]
		if not grantPurchaseHandler then
			warn(`No purchase handler defined for product ID '{receiptInfo.ProductId}'`)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local success, result = pcall(grantPurchaseHandler, receiptInfo, player)

		if not success or not result then
			warn(
				`Grant purchase handler errored while processing purchase from '{player.Name}' of product ID '{receiptInfo.ProductId}': {result}`
			)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if result == true then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	MarketplaceService.ProcessReceipt = processReceipt
end

return DeveloperProducts
