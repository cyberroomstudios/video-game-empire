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

local player = Players.LocalPlayer

-- Botões referentes aos Teleports
local workesButton
local myStudioButton
local sellButton

-- Botões da Esquerda
local indexButton
local rebirthButton

function HudController:Init()
	HudController:CreateReferences()
	HudController:InitButtonListerns()
	HudController:InitUserInputService()
end

function HudController:CreateReferences()
	-- Botões referentes aos Teleports
	workesButton = UIReferences:GetReference("WORKERS_BUTTON")
	myStudioButton = UIReferences:GetReference("MY_STUDIO_BUTTON")
	sellButton = UIReferences:GetReference("SELL_BUTTON")
	indexButton = UIReferences:GetReference("INDEX_BUTTON_HUD")
	rebirthButton = UIReferences:GetReference("REBIRTH_BUTTON_HUD")
end

function HudController:InitButtonListerns()
	workesButton.MouseButton1Click:Connect(function()
		TeleportController:ToWorkers()
	end)

	myStudioButton.MouseButton1Click:Connect(function()
		TeleportController:ToBase()
	end)

	sellButton.MouseButton1Click:Connect(function()
		TeleportController:ToSell()
	end)

	rebirthButton.MouseButton1Click:Connect(function()
		RebirthController:Open()
	end)

	indexButton.MouseButton1Click:Connect(function()
		IndexController:Open()
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
						},
					})
					return
				end
			end
		end
	end)
end

return HudController
