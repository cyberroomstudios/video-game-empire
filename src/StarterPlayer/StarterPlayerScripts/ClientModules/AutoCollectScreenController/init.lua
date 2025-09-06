local AutoCollectScreenController = {}

local Players = game:GetService("Players")

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

local autoCollectScreen
local mainAutoCollect
local leftPlaytime
local autoCollectButton

function AutoCollectScreenController:Init()
	AutoCollectScreenController:CreateReferences()
end

function AutoCollectScreenController:CreateReferences()
	-- Botões referentes aos Teleports
	autoCollectButton = UIReferences:GetReference("AUTO_COLLECT_BUTTON")
	autoCollectScreen = UIReferences:GetReference("AUTO_COLLECT_SCREEN")
	mainAutoCollect = UIReferences:GetReference("MAIN_AUTO_COLLECT")
	leftPlaytime = UIReferences:GetReference("LEFT_PLAYTIME")
end

function AutoCollectScreenController:Open()
	mainAutoCollect.Visible = false
	AutoCollectScreenController:BuildScreen()
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

return AutoCollectScreenController
