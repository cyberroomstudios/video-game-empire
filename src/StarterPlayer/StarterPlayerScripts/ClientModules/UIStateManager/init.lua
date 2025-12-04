local UIStateManager = {}
local CollectionService = game:GetService("CollectionService")
local HapticService = game:GetService("HapticService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local AutoCollectScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoCollectScreenController)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DailyRewardController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DailyRewardController)
local CodesController = require(Players.LocalPlayer.PlayerScripts.ClientModules.CodesController)
local MobileVibrationController = require(Players.LocalPlayer.PlayerScripts.ClientModules.MobileVibrationController)
local GroupRewardController = require(Players.LocalPlayer.PlayerScripts.ClientModules.GroupRewardController)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local NewGameController = require(Players.LocalPlayer.PlayerScripts.ClientModules.NewGameController)
local SettingsController = require(Players.LocalPlayer.PlayerScripts.ClientModules.SettingsController)
local ShopController = require(Players.LocalPlayer.PlayerScripts.ClientModules.ShopController)
local bridge = BridgeNet2.ReferenceBridge("UIStateService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screens = {}
local originalSizeScreen = {}
local loadedModules = false
local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = camera

local currentScreen = ""
local backpackButtons

function UIStateManager:Init()
	UIStateManager:CreateReferences()
	UIStateManager:ConfigureCloseButton()
	UIStateManager:InitBackpackButtons()
	UIStateManager:InitGroupRewardProximity()
	UIStateManager:InitListeners()
end

function UIStateManager:CreateReferences()
	backpackButtons = UIReferences:GetReference("BACKPACK_BUTTONS")
end

function UIStateManager:LoadModules()
	if not loadedModules then
		loadedModules = true
		local clientModules = Players.LocalPlayer.PlayerScripts.ClientModules

		local IndexController = require(clientModules.IndexController)
		local SellShopScreenController = require(clientModules.SellShopScreenController)
		local RebirthController = require(clientModules.RebirthController)
		local AutoCollectScreenController = require(clientModules.AutoCollectScreenController)
		local BackpackController = require(clientModules.BackpackController)
		local FeedbackController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FeedbackController)

		screens = {
			["SELL"] = SellShopScreenController,
			["INDEX"] = IndexController,
			["REBIRTH"] = RebirthController,
			["AUTO_COLLECT"] = AutoCollectScreenController,
			["BACKPACK_EXPAND"] = BackpackController,
			["DAILY_REWARD"] = DailyRewardController,
			["CODE"] = CodesController,
			["GROUP_REWARD"] = GroupRewardController,
			["NEW_GAME"] = NewGameController,
			["SETTINGS"] = SettingsController,
			["SHOP"] = ShopController,
			["FEEDBACK"] = FeedbackController,
		}

		for screenName, screen in screens do
			originalSizeScreen[screenName] = screen:GetScreen().Size
		end
	end
end

function UIStateManager:Open(screenName: string)
	UIStateManager:LoadModules()
	for _, screen in screens do
		screen:Close()
	end

	if (currentScreen ~= "WORKERS" or currentScreen ~= "SELL") and screenName == currentScreen then
		UIStateManager:Close(screenName)
		currentScreen = ""
		return
	end

	UIStateManager:AddBluer()
	task.spawn(function()
		MobileVibrationController:Start()
		SoundManager:Play("UI_OPEN_SCREEN")
		screens[screenName]:Open()
	end)
	UIStateManager:ApplyTween(screenName, screens[screenName]:GetScreen())
	currentScreen = screenName
end

function UIStateManager:Close(screenName: string)
	UIStateManager:RemoveBluer()
	currentScreen = ""
	if screenName and screens[screenName] then
		
		screens[screenName]:Close()
	end
end

function UIStateManager:ApplyTween(screenName: string, screen: Frame)
	if screen.Name == "NewGame" then
		return
	end

	local originalSize = originalSizeScreen[screenName]

	local tweenInfo = TweenInfo.new(
		0.3, -- duração
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	if screen.Name == "Expand" then
		
		local tweenInfo = TweenInfo.new(
			0.1, -- duração
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		-- Apenas cresce no eixo Y
		local startSize = UDim2.new(originalSize.X.Scale, 0, originalSize.Y.Scale * 0.3, 0)
		local endSize = UDim2.new(originalSize.X.Scale, 0, originalSize.Y.Scale * 1.1, 0)

		screen.Size = startSize

		local growTween = TweenService:Create(screen, tweenInfo, { Size = endSize })
		local normalTween = TweenService:Create(screen, tweenInfo, { Size = originalSize })

		growTween:Play()
		growTween.Completed:Connect(function()
			normalTween:Play()
		end)

		return -- importante: para não executar o tween padrão
	end

	-- Tween padrão para outras telas
	local smallSize = UDim2.new(originalSize.X.Scale * 0.3, 0, originalSize.Y.Scale * 0.3, 0)
	local bigSize = UDim2.new(originalSize.X.Scale * 1.1, 0, originalSize.Y.Scale * 1.1, 0)

	screen.Size = smallSize

	local growTween = TweenService:Create(screen, tweenInfo, { Size = bigSize })
	local normalTween = TweenService:Create(screen, tweenInfo, { Size = originalSize })

	growTween:Play()
	growTween.Completed:Connect(function()
		normalTween:Play()
	end)
end

function UIStateManager:AddBluer()
	blur.Size = 24
end

function UIStateManager:RemoveBluer()
	blur.Size = 0
end

function UIStateManager:ConfigureCloseButton()
	local taggedObjects = CollectionService:GetTagged("CLOSE_FRAME")

	for _, button in taggedObjects do
		button.MouseButton1Click:Connect(function()
			SoundManager:Play("UI_CLICK")

			UIStateManager:Close(button:GetAttribute("Screen"))
		end)
	end
end

function UIStateManager:InitBackpackButtons()
	for _, value in backpackButtons:GetChildren() do
		if value:IsA("TextButton") and value.Name == "7" then
			value.MouseButton1Click:Connect(function()
				if value.Name == "7" then
					UIStateManager:Open("BACKPACK_EXPAND")
				end
			end)
		end
	end
end

function UIStateManager:InitGroupRewardProximity()
	local proximityPart = ClientUtil:WaitForDescendants(
		workspace,
		"Map",
		"CentralSquare",
		"CentralSquare",
		"GroupReward",
		"ProximityPart"
	)
	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("GROUP_REWARD")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("GROUP_REWARD")
	end)
end

function UIStateManager:InitListeners()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowNewGame" then
			for _, value in response.data.NewGames do
				NewGameController:AddNewGameName(value)
			end
			UIStateManager:Open("NEW_GAME")
			task.wait(2)
			UIStateManager:Close("NEW_GAME")
		end
	end)
end

return UIStateManager
