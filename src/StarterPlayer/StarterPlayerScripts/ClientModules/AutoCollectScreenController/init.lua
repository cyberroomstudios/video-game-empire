local AutoCollectScreenController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("AutoCollectService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local autoCollectScreen
local mainAutoCollect
local leftPlaytime
local autoCollectButton
local unlockNowButton

function AutoCollectScreenController:Init()
	AutoCollectScreenController:CreateReferences()
	AutoCollectScreenController:InitButtonListerns()
	AutoCollectScreenController:InitAttributeListener()
end

function AutoCollectScreenController:CreateReferences()
	autoCollectButton = UIReferences:GetReference("AUTO_COLLECT_BUTTON_HUD")
	autoCollectScreen = UIReferences:GetReference("AUTO_COLLECT_SCREEN")
	mainAutoCollect = UIReferences:GetReference("MAIN_AUTO_COLLECT")
	leftPlaytime = UIReferences:GetReference("LEFT_PLAYTIME")
	unlockNowButton = UIReferences:GetReference("UNLOCK_AUTO_COLLECT_BUTTON")
end

function AutoCollectScreenController:Open()
	mainAutoCollect.Visible = false
	AutoCollectScreenController:BuildScreen()
end

function AutoCollectScreenController:InitButtonListerns()
	unlockNowButton.MouseButton1Click:Connect(function()
		autoCollectScreen.Visible = false
		DeveloperProductController:OpenPaymentRequestScreen("UNLOCK_AUTO_COLLECT")
		workspace.CurrentCamera.Blur.Size = 0
	end)
end

function AutoCollectScreenController:ActiveOrInactive()
	if autoCollectButton.Info.BackgroundColor3 == autoCollectButton.Info.ActiveColor.Value then
		autoCollectButton.Info.BackgroundColor3 = autoCollectButton.Info.InactiveColor.Value

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "InactiveAutoCollect",
		})
	else
		autoCollectButton.Info.BackgroundColor3 = autoCollectButton.Info.ActiveColor.Value

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ActiveAutoCollect",
		})
	end
end

function AutoCollectScreenController:BuildScreen()
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetPlaytime",
	})

	if result > 0 then
		autoCollectScreen.Visible = true
		mainAutoCollect.Visible = true
		local leftTime = result

		while mainAutoCollect.Visible and leftTime >= 0 do
			local minutes = math.floor(leftTime / 60)
			local secs = leftTime % 60

			leftPlaytime.Text = string.format("%02d:%02d", minutes, secs)
			leftTime = leftTime - 1
			task.wait(1)
		end
	end

	autoCollectButton.Info.BackgroundColor3 = autoCollectButton.Info.ActiveColor.Value

	autoCollectScreen.Visible = false
	workspace.CurrentCamera.Blur.Size = 0

	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "ActiveAutoCollect",
	})
end

function AutoCollectScreenController:Close()
	autoCollectScreen.Visible = false
end

function AutoCollectScreenController:GetScreen()
	return autoCollectScreen
end

function AutoCollectScreenController:InitAttributeListener()
	player:GetAttributeChangedSignal("ACTIVED_AUTO_COLLECT"):Connect(function()
		local activedAutoCollect = player:GetAttribute("ACTIVED_AUTO_COLLECT")

		if activedAutoCollect then
			autoCollectButton.Info.BackgroundColor3 = autoCollectButton.Info.ActiveColor.Value
		else
			autoCollectButton.Info.BackgroundColor3 = autoCollectButton.Info.InactiveColor.Value
		end
	end)
end

return AutoCollectScreenController
