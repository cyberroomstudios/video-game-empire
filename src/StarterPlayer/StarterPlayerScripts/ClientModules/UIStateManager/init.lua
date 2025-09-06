local UIStateManager = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local AutoCollectScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoCollectScreenController)

local screens = {}
local loadedModules = false
local camera = workspace.CurrentCamera

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = camera

local currentScreen = ""

function UIStateManager:Init()
	UIStateManager:ConfigureCloseButton()
end

function UIStateManager:LoadModules()
	if not loadedModules then
		loadedModules = true
		local clientModules = Players.LocalPlayer.PlayerScripts.ClientModules

		local HireAgencyScreenController = require(clientModules.HireAgencyScreenController)
		local IndexController = require(clientModules.IndexController)
		local SellShopScreenController = require(clientModules.SellShopScreenController)
		local RebirthController = require(clientModules.RebirthController)
		local AutoCollectScreenController = require(clientModules.AutoCollectScreenController)

		screens = {
			["WORKERS"] = HireAgencyScreenController,
			["SELL"] = SellShopScreenController,
			["INDEX"] = IndexController,
			["REBIRTH"] = RebirthController,
			["AUTO_COLLECT"] = AutoCollectScreenController,
		}
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
		screens[screenName]:Open()
	end)
	UIStateManager:ApplyTween(screens[screenName]:GetScreen())
	currentScreen = screenName
end

function UIStateManager:Close(screenName: string)
	UIStateManager:RemoveBluer()
	currentScreen = ""
	screens[screenName]:Close()
end

function UIStateManager:ApplyTween(screen: Frame)
	-- Tamanhos para o efeito

	-- Sizes for the effect
	local originalSize = screen.Size
	local smallSize = UDim2.new(originalSize.X.Scale * 0.3, 0, originalSize.Y.Scale * 0.3, 0)
	local bigSize = UDim2.new(originalSize.X.Scale * 1.1, 0, originalSize.Y.Scale * 1.1, 0)

	-- Tween settings
	local tweenInfo = TweenInfo.new(
		0.3, -- Duration
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	-- Start small
	screen.Size = smallSize

	-- Create the tweens
	local growTween = TweenService:Create(screen, tweenInfo, { Size = bigSize })
	local normalTween = TweenService:Create(screen, tweenInfo, { Size = originalSize })

	-- Play in sequence
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
			UIStateManager:Close(button:GetAttribute("Screen"))
		end)
	end
end

return UIStateManager
