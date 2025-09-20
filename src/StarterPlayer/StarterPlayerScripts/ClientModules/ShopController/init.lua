local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local ShopController = {}

local screen
local starterScreen
local opPackScreen

local buyStarterPack1
local buyStarterPack2
local buyStarterPack3

local buyOPPack1
local buyOPPack2
local buyOPPack3

local money1
local money2
local money3
local money4
local money5
local money6

function ShopController:Init()
	ShopController:CreateReferences()
	ShopController:InitButtonListerns()
	ShopController:InitPrices()
end

function ShopController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("SHOP_SCREEN")
	starterScreen = UIReferences:GetReference("STARTER_PACK")
	opPackScreen = UIReferences:GetReference("OP_PACK")

	buyStarterPack1 = UIReferences:GetReference("BUY_STARTER_PACK_1")
	buyStarterPack2 = UIReferences:GetReference("BUY_STARTER_PACK_2")
	buyStarterPack3 = UIReferences:GetReference("BUY_STARTER_PACK_3")

	buyOPPack1 = UIReferences:GetReference("BUY_OP_1")
	buyOPPack2 = UIReferences:GetReference("BUY_OP_2")
	buyOPPack3 = UIReferences:GetReference("BUY_OP_3")

	money1 = UIReferences:GetReference("BUY_MONEY_1")
	money2 = UIReferences:GetReference("BUY_MONEY_2")
	money3 = UIReferences:GetReference("BUY_MONEY_3")
	money4 = UIReferences:GetReference("BUY_MONEY_4")
	money5 = UIReferences:GetReference("BUY_MONEY_5")
	money6 = UIReferences:GetReference("BUY_MONEY_6")
end

function ShopController:InitButtonListerns()
	buyStarterPack1.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("STARTER_PACK_1")
	end)

	buyStarterPack2.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("STARTER_PACK_2")
	end)

	buyStarterPack3.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("STARTER_PACK_3")
	end)

	buyOPPack1.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("OP_PACK_1")
	end)

	buyOPPack2.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("OP_PACK_2")
	end)

	buyOPPack3.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("OP_PACK_3")
	end)

	money1.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_1")
	end)

	money2.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_2")
	end)

	money3.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_3")
	end)

	money4.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_4")
	end)

	money5.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_5")
	end)

	money6.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		DeveloperProductController:OpenPaymentRequestScreen("MONEY_6")
	end)
end

function ShopController:InitPrices()
	pcall(function()
		buyStarterPack1.Frame.TextLabel.Text = utf8.char(0xE002)
			.. DeveloperProductController:GetProductPrice("STARTER_PACK_1")
	end)

	pcall(function()
		buyStarterPack2.Frame.TextLabel.Text = utf8.char(0xE002)
			.. DeveloperProductController:GetProductPrice("STARTER_PACK_2")
	end)

	pcall(function()
		buyStarterPack3.Frame.TextLabel.Text = utf8.char(0xE002)
			.. DeveloperProductController:GetProductPrice("STARTER_PACK_3")
	end)

	pcall(function()
		buyOPPack1.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("OP_PACK_1")
	end)

	pcall(function()
		buyOPPack2.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("OP_PACK_2")
	end)

	pcall(function()
		buyOPPack3.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("OP_PACK_3")
	end)

	pcall(function()
		money1.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_1")
	end)

	pcall(function()
		money2.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_2")
	end)

	pcall(function()
		money3.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_3")
	end)

	pcall(function()
		money4.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_4")
	end)

	pcall(function()
		money5.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_5")
	end)

	pcall(function()
		money6.Frame.TextLabel.Text = utf8.char(0xE002) .. DeveloperProductController:GetProductPrice("MONEY_6")
	end)
end

function ShopController:Open()
	ShopController:BuildStarterPackScreen()
	ShopController:BuildOpPackScreen()
	screen.Visible = true
end

function ShopController:Close()
	screen.Visible = false
end

function ShopController:GetScreen()
	return screen
end

function ShopController:BuildStarterPackScreen()
	local prizes = starterScreen.Content.Prizes
	local devJunior = prizes:FindFirstChild("DevJunior")
	local midLevel = prizes:FindFirstChild("MidLevel")

	local devsFolder = ReplicatedStorage.GUI.ViewPorts.Devs
	local viewPort = devsFolder:FindFirstChild("2_JuniorDev"):Clone()
	viewPort.Size = UDim2.fromScale(1, 1)
	viewPort.Position = UDim2.fromScale(0.5, 0.5)
	viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
	viewPort.Parent = devJunior

	local viewPort2 = devsFolder:FindFirstChild("3_MidLevelDev"):Clone()
	viewPort2.Size = UDim2.fromScale(1, 1)
	viewPort2.Position = UDim2.fromScale(0.5, 0.5)
	viewPort2.AnchorPoint = Vector2.new(0.5, 0.5)
	viewPort2.Parent = midLevel
end

function ShopController:BuildOpPackScreen()
	local prizes = opPackScreen.Content.Prizes
	local TechLead = prizes:FindFirstChild("TechLead")
	local GameTester = prizes:FindFirstChild("GameTester")

	local devsFolder = ReplicatedStorage.GUI.ViewPorts.Devs
	local viewPort = devsFolder:FindFirstChild("6_TechLead"):Clone()
	viewPort.Size = UDim2.fromScale(1, 1)
	viewPort.Position = UDim2.fromScale(0.5, 0.5)
	viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
	viewPort.Parent = TechLead

	local viewPort2 = devsFolder:FindFirstChild("7_GameTester"):Clone()
	viewPort2.Size = UDim2.fromScale(1, 1)
	viewPort2.Position = UDim2.fromScale(0.5, 0.5)
	viewPort2.AnchorPoint = Vector2.new(0.5, 0.5)
	viewPort2.Parent = GameTester
end

return ShopController
