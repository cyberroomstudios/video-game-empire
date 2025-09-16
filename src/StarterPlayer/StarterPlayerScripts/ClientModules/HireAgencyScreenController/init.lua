local HireAgencyScreenController = {}

-- Init Bridg Net
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local bridgeDevService = BridgeNet2.ReferenceBridge("DevService")

local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local Devs = require(ReplicatedStorage.Enums.Devs)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)
local FTUEController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FTUEController)

local player = Players.LocalPlayer

local screen
local scrollingFrame
local reestockLabel
local restockAllButton
local playerStock = {}

local devsBuyId = {
	["1_DevIntern"] = "DEV_INTERN",
	["2_JuniorDev"] = "JUNIOR_DEVELOPER",
	["3_MidLevelDev"] = "MID_LEVEL_DEVELOPER",
	["4_SeniorDev"] = "SENIOR_DEVELOPER",
	["5_ConceptArtist"] = "CONCEPET_ARTIST",
}
local devPrices = {
	["1_DevIntern"] = "-",
	["2_JuniorDev"] = "-",
	["3_MidLevelDev"] = "-",
	["4_SeniorDev"] = "-",
	["5_ConceptArtist"] = "-",
}

function HireAgencyScreenController:Init()
	HireAgencyScreenController:CreateReferences()
	HireAgencyScreenController:ConfigureProximity()

	HireAgencyScreenController:InitAttributeListener()
	HireAgencyScreenController:InitBridgeListener()
	HireAgencyScreenController:InitButtonListerns()
	HireAgencyScreenController:CreateDevPrices()
end

function HireAgencyScreenController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("HIRE_AGENCY")
	scrollingFrame = UIReferences:GetReference("HIRE_AGENCY_SCROLLING_FRAME")
	reestockLabel = UIReferences:GetReference("REESTOCK_LABEL")
	restockAllButton = UIReferences:GetReference("RESTOCK_ALL_BUTTON")
end

function HireAgencyScreenController:CreateDevPrices()
	task.spawn(function()
		for index, dev in devsBuyId do
			devPrices[index] = DeveloperProductController:GetProductPrice(dev)
		end
	end)
end
function HireAgencyScreenController:Open()
	HireAgencyScreenController:InitFTUE()
	screen.Visible = true
end

function HireAgencyScreenController:Close()
	screen.Visible = false
end

function HireAgencyScreenController:GetScreen()
	return screen
end

function HireAgencyScreenController:InitButtonListerns()
	restockAllButton.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("RESTOCK")
	end)
end

function HireAgencyScreenController:ConfigureProximity()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "HireAgency", "Agency", "ProximityPart")
	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("WORKERS")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("WORKERS")
	end)
end

function HireAgencyScreenController:CreateDevItems()
	local selectedItem = nil

	for _, dev in Devs do
		local newItem = ReplicatedStorage.GUI.HireAgency.HireAgencyItem:Clone()
		newItem.Name = dev.Name
		newItem.LayoutOrder = dev.GUI.Order

		local information = newItem.Information
		local labels = newItem.Labels

		-- Nome do Dev a venda
		information.DevName.Text = dev.GUI.Label

		-- Capacidade máxima do dev
		information.Capacity.Text = "Players Maximum Storage: " .. dev.CapacityOfGamesProduced

		-- Preço do dev
		labels.Price.Text = ClientUtil:FormatToUSD(dev.Price)

		-- Raridade do dev
		labels.Rarity.TextLabel.Text = dev.Rarity

		-- Stock
		labels.Stock.Text = "x" .. tostring(player:GetAttribute(dev.Name) or 0) .. " Stock"

		-- Games
		local games = Devs[dev.Name].Games

		for gameName, gameChance in games do
			local gameIcon = ReplicatedStorage.GUI.ViewPorts.Games[gameName]:Clone()
			local newGame = information.Games.Frame:Clone()
			gameIcon.Parent = newGame
			newGame.Visible = true
			newGame.GameChance.Text = gameChance["Chance"] .. "%"

			newGame.GameName.Text = gameName
			newGame.Parent = information.Games
		end

		newItem.Parent = scrollingFrame

		-- Buttons
		newItem.MouseButton1Click:Connect(function()
			local currentLayoutOrder = newItem.LayoutOrder

			for _, item in scrollingFrame:GetChildren() do
				if not item:IsA("UIListLayout") then
					if item.LayoutOrder > currentLayoutOrder then
						item.LayoutOrder = item.LayoutOrder + 1
					end
				end
			end
			local currentFTUE = FTUEController:GetCurrentState()

			if currentFTUE and currentFTUE == "SELECT_ITEM" then
				newItem.Image.FTUE.Visible = false
				scrollingFrame.Buttons.Buy.FTUE.Visible = true
				FTUEController:SetCurrentState("BUY_ITEM")
			else
				scrollingFrame.Buttons.Buy.FTUE.Visible = false
			end
			selectedItem = dev.Name

			scrollingFrame.Buttons.Buy.TextLabel.Text = ClientUtil:FormatToUSD(dev.Price)
			scrollingFrame.Buttons.Visible = true
			scrollingFrame.Buttons.LayoutOrder = currentLayoutOrder + 1
			scrollingFrame.Buttons.Robux.TextLabel.Text = utf8.char(0xE002) .. devPrices[dev.Name]
		end)
	end

	scrollingFrame.Buttons.Buy.MouseButton1Click:Connect(function()
		local result = bridgeDevService:InvokeServerAsync({
			[actionIdentifier] = "BuyDev",
			data = {
				DevName = selectedItem,
			},
		})
		local currentFTUE = FTUEController:GetCurrentState()
		if currentFTUE and currentFTUE == "BUY_ITEM" then
			scrollingFrame.Buttons.Buy.FTUE.Visible = false
			FTUEController:SetCurrentMyStudioFTUE()
		end
	end)

	scrollingFrame.Buttons.Restock.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "SetRestockThisIntent",
			data = {
				DevName = selectedItem,
			},
		})
		DeveloperProductController:OpenPaymentRequestScreen("RESTOCK_THIS")
	end)

	scrollingFrame.Buttons.Robux.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen(devsBuyId[selectedItem])
	end)
end

function HireAgencyScreenController:InitAttributeListener()
	workspace:GetAttributeChangedSignal("GLOBAL_STOCK_COUNT"):Connect(function()
		for _, dev in Devs do
			local item = scrollingFrame:FindFirstChild(dev.Name)
			local information = item.Information
			local labels = item.Labels
			labels.Stock.Text = "x" .. tostring(player:GetAttribute(dev.Name) or 0) .. " Stock"
		end
	end)

	workspace:GetAttributeChangedSignal("TIME_TO_RELOAD_RESTOCK"):Connect(function()
		local leftTime = workspace:GetAttribute("TIME_TO_RELOAD_RESTOCK")
		reestockLabel.Text = ClientUtil:FormatSecondsToMinutes(leftTime)
	end)
end

function HireAgencyScreenController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "UpdateStock" then
			local devName = response.data.DevName
			local amount = response.data.Amount

			local item = scrollingFrame:FindFirstChild(devName)
			local information = item.Information
			local labels = item.Labels

			labels.Stock.Text = "x" .. amount .. " Stock"
		end
	end)
end

function HireAgencyScreenController:InitFTUE()
	local currentFTUE = FTUEController:GetCurrentState()
	for _, value in scrollingFrame:GetChildren() do
		if value:IsA("TextButton") and value.LayoutOrder == 1 then
			if currentFTUE and currentFTUE == "SELECT_ITEM" then
				value.Image.FTUE.Visible = true
			else
				value.Image.FTUE.Visible = false
			end
		end
	end
end

return HireAgencyScreenController
