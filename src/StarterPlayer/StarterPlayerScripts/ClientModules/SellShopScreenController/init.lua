local SellShopScreenController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")
local Games = require(ReplicatedStorage.Enums.Games)

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local scrollingGames
local totalPriceAllGames
local sellAllGames
local sum = 0

function SellShopScreenController:Init()
	SellShopScreenController:CreateReferences()
	SellShopScreenController:ConfigureProximity()
	SellShopScreenController:InitButtonListerns()
end

function SellShopScreenController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("SELL_SHOP_SCREEN")
	scrollingGames = UIReferences:GetReference("SCROLLING_GAMES")
	totalPriceAllGames = UIReferences:GetReference("TOTAL_PRICE_ALL_GAMES")
	sellAllGames = UIReferences:GetReference("SELL_ALL_GAMES")
end

function SellShopScreenController:InitButtonListerns()
	local clicked = false
	sellAllGames.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")
		if sum > 0 then
			if not clicked then
				clicked = true
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "SellAll",
				})
				for _, value in scrollingGames:GetChildren() do
					if value:IsA("Frame") and not (value.Name == "Product") then
						value:Destroy()
					end
				end

				totalPriceAllGames.Text = ClientUtil:FormatToUSD(0)
				clicked = false
			end
		end
	end)
end

function SellShopScreenController:Open()
	screen.Visible = true
	scrollingGames.Visible = false
	SellShopScreenController:BuildScreen()
	scrollingGames.Visible = true
end

function SellShopScreenController:Close()
	screen.Visible = false
end

function SellShopScreenController:GetScreen()
	return screen
end

function SellShopScreenController:ConfigureProximity()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "SellShop", "SellShop", "ProximityPart")
	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("SELL")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("SELL")
	end)
end

function SellShopScreenController:BuildScreen()
	sum = 0
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetGames",
		data = {},
	})

	for _, value in scrollingGames:GetChildren() do
		if value:IsA("Frame") and not (value.Name == "Product") then
			value:Destroy()
		end
	end

	for _, value in result do
		sum = sum + value.Price
		local newItem = scrollingGames.Product:Clone()
		newItem.Name = value.GameName
		newItem.Content.Informations.ProductName.Text = Games[value.GameName].GUI.Name
		newItem.Content.Informations.ProductPlayers.Text = value.AmountPlayer .. " Players"
		newItem.Content.Informations.ProductAmountPrice.Text = ClientUtil:FormatToUSD(value.Price)
		newItem.Visible = true
		newItem.Parent = scrollingGames

		local gameIcon = ReplicatedStorage.GUI.ViewPorts.Games[value.GameName]:Clone()
		gameIcon.Size = UDim2.fromScale(1, 1)
		gameIcon.Position = UDim2.fromScale(0.5, 0.5)
		gameIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		gameIcon.Parent = newItem.Content.ProductImage

		local clicked = false
		newItem.Sell.Sell.MouseButton1Click:Connect(function()
			SoundManager:Play("UI_CLICK")

			if not clicked then
				clicked = true
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "SellItem",
					data = {
						GameName = value.GameName,
					},
				})

				newItem:Destroy()
				sum = sum - value.Price
				totalPriceAllGames.Text = ClientUtil:FormatToUSD(sum)
			end
		end)
	end

	totalPriceAllGames.Text = ClientUtil:FormatToUSD(sum)
end

return SellShopScreenController
