local HudController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("MapService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)
local RebirthController = require(Players.LocalPlayer.PlayerScripts.ClientModules.RebirthController)
local IndexController = require(Players.LocalPlayer.PlayerScripts.ClientModules.IndexController)
local AutoCollectScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoCollectScreenController)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local AutoSellController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoSellController)
local FTUEController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FTUEController)

local player = Players.LocalPlayer

-- Botões referentes aos Teleports
local workesButton
local myStudioButton
local sellButton

-- Botões da Esquerda
local shopButton
local indexButton
local rebirthButton
local dailyRewardButton
local codeButton

-- Botões da Direta
local autoCollectButton
local autoSellButton

-- Botões do Preview do Mobile
local leftPreviewButton
local setPreviewButton
local rightPreviewButton

function HudController:Init()
	HudController:CreateReferences()
	HudController:InitButtonListerns()
	HudController:InitUserInputService()
	HudController:InitButtonEffects()
end

function HudController:CreateReferences()
	-- Botões referentes aos Teleports
	workesButton = UIReferences:GetReference("WORKERS_BUTTON")
	myStudioButton = UIReferences:GetReference("MY_STUDIO_BUTTON")
	sellButton = UIReferences:GetReference("SELL_BUTTON")
	shopButton = UIReferences:GetReference("SHOP_HUD")
	indexButton = UIReferences:GetReference("INDEX_BUTTON_HUD")
	rebirthButton = UIReferences:GetReference("REBIRTH_BUTTON_HUD")
	autoCollectButton = UIReferences:GetReference("AUTO_COLLECT_BUTTON_HUD")
	autoSellButton = UIReferences:GetReference("AUTO_SELL_BUTTON")
	dailyRewardButton = UIReferences:GetReference("DAILY_REWARD_HUD")
	codeButton = UIReferences:GetReference("CODE_BUTTON_HUD")

	leftPreviewButton = UIReferences:GetReference("LEFT_PREVIEW_BUTTON")
	setPreviewButton = UIReferences:GetReference("SET_PREVIEW_BUTTON")
	rightPreviewButton = UIReferences:GetReference("RIGHT_PREVIEW_BUTTON")
end

function HudController:InitButtonListerns()
	workesButton.MouseButton1Click:Connect(function()
		TeleportController:ToWorkers()
	end)

	myStudioButton.MouseButton1Click:Connect(function()
		TeleportController:ToBase()
		UIStateManager:Close("WORKERS")
		UIStateManager:Close("SELL")
	end)

	sellButton.MouseButton1Click:Connect(function()
		TeleportController:ToSell()
		--UIStateManager:Open("SELL")
	end)

	rebirthButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("REBIRTH")
	end)

	indexButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("INDEX")
	end)

	dailyRewardButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("DAILY_REWARD")
	end)

	codeButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("CODE")
	end)

	autoCollectButton.MouseButton1Click:Connect(function()
		if Players.LocalPlayer:GetAttribute("HAS_AUTO_COLLECT") then
			AutoCollectScreenController:ActiveOrInactive()
			return
		end
		UIStateManager:Open("AUTO_COLLECT")
	end)

	autoSellButton.MouseButton1Click:Connect(function()
		AutoSellController:ActiveOrInactive()
	end)

	leftPreviewButton.MouseButton1Click:Connect(function()
		Players.LocalPlayer:SetAttribute("ROTATE_LEFT_PREVIEW", true)
	end)

	rightPreviewButton.MouseButton1Click:Connect(function()
		Players.LocalPlayer:SetAttribute("ROTATE_RIGHT_PREVIEW", true)
	end)

	setPreviewButton.MouseButton1Click:Connect(function()
		if player:GetAttribute("CAN_SET") then
			player:SetAttribute("CAN_SET", false)
			local toolName = player:GetAttribute("TOOL_IN_HAND")
			local toolType = player:GetAttribute("TOOL_TYPE")

			local tool = player.Character:FindFirstChildOfClass("Tool")

			if tool then
				tool.Parent = player:FindFirstChild("Backpack")
			end

			if toolType == "DEV" then
				player:SetAttribute("CAN_SET", false)
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "SetDev",
					data = {
						CFrame = workspace.Preview.PrimaryPart.CFrame,
						Dev = toolName,
						Floor = player:GetAttribute("CURRENT_FLOOR"),
					},
				})

				if result then
					FTUEController:SetCurrentGetGameFTUE()
				end
				return
			end
		end
	end)
end

function HudController:InitButtonEffects()
	shopButton.MouseEnter:Connect(function()
		shopButton.UIScale.Scale = 1.1
	end)

	shopButton.MouseLeave:Connect(function()
		shopButton.UIScale.Scale = 1
	end)

	indexButton.MouseEnter:Connect(function()
		indexButton.UIScale.Scale = 1.1
	end)

	indexButton.MouseLeave:Connect(function()
		indexButton.UIScale.Scale = 1
	end)

	rebirthButton.MouseEnter:Connect(function()
		rebirthButton.UIScale.Scale = 1.1
	end)

	rebirthButton.MouseLeave:Connect(function()
		rebirthButton.UIScale.Scale = 1
	end)

	workesButton.MouseEnter:Connect(function()
		workesButton.UIScale.Scale = 1.1
	end)

	workesButton.MouseLeave:Connect(function()
		workesButton.UIScale.Scale = 1
	end)

	myStudioButton.MouseEnter:Connect(function()
		myStudioButton.UIScale.Scale = 1.1
	end)

	myStudioButton.MouseLeave:Connect(function()
		myStudioButton.UIScale.Scale = 1
	end)

	sellButton.MouseEnter:Connect(function()
		sellButton.UIScale.Scale = 1.1
	end)

	sellButton.MouseLeave:Connect(function()
		sellButton.UIScale.Scale = 1
	end)

	autoCollectButton.MouseEnter:Connect(function()
		autoCollectButton.UIScale.Scale = 1.1
	end)

	autoCollectButton.MouseLeave:Connect(function()
		autoCollectButton.UIScale.Scale = 1
	end)

	autoSellButton.MouseEnter:Connect(function()
		autoSellButton.UIScale.Scale = 1.1
	end)

	autoSellButton.MouseLeave:Connect(function()
		autoSellButton.UIScale.Scale = 1
	end)
end

function HudController:InitUserInputService()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.R then
			Players.LocalPlayer:SetAttribute("ROTATE_PREVIEW", true)
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if player:GetAttribute("CAN_SET") then
				player:SetAttribute("CAN_SET", false)
				local toolName = player:GetAttribute("TOOL_IN_HAND")
				local toolType = player:GetAttribute("TOOL_TYPE")

				local tool = player.Character:FindFirstChildOfClass("Tool")

				if tool then
					tool.Parent = player:FindFirstChild("Backpack")
				end

				if toolType == "DEV" then
					player:SetAttribute("CAN_SET", false)
					local result = bridge:InvokeServerAsync({
						[actionIdentifier] = "SetDev",
						data = {
							CFrame = workspace.Preview.PrimaryPart.CFrame,
							Dev = toolName,
							Floor = player:GetAttribute("CURRENT_FLOOR"),
						},
					})

					if result then
						FTUEController:SetCurrentGetGameFTUE()
					end

					return
				end
			end
		end
	end)
end

return HudController
