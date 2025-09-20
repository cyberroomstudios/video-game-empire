local GroupRewardController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GroupRewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local getGroupRewardButton

function GroupRewardController:Init()
	GroupRewardController:CreateReferences()
	GroupRewardController:InitButtonListerns()
end

function GroupRewardController:CreateReferences()
	screen = UIReferences:GetReference("GROUP_REWARD_FRAME")
	getGroupRewardButton = UIReferences:GetReference("GET_GROUP_REWARD_BUTTON")
end

function GroupRewardController:Open()
	screen.Visible = true
end

function GroupRewardController:Close()
	screen.Visible = false
end

function GroupRewardController:GetScreen()
	return screen
end

function GroupRewardController:InitButtonListerns()
	getGroupRewardButton.MouseButton1Click:Connect(function()
					SoundManager:Play("UI_CLICK")

		GroupRewardController:Close()
		if workspace.CurrentCamera:FindFirstChild("Blur") then
			workspace.CurrentCamera.Blur.Size = 0
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetGroupRewardService",
		})
	end)
end

return GroupRewardController
