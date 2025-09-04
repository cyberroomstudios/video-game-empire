local RebirthController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local screen
local getRebirthButton

function RebirthController:Init()
	RebirthController:CreateReferences()
	RebirthController:InitButtonListerns()
end

function RebirthController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("REBIRTH_SCREEN")
	getRebirthButton = UIReferences:GetReference("GET_REBIRTH_BUTTON")
end

function RebirthController:Open()
	screen.Visible = not screen.Visible
end

function RebirthController:InitButtonListerns()
	local canClick = true
	getRebirthButton.MouseButton1Click:Connect(function()
		if canClick then
			canClick = false
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GetRebirth",
			})
			canClick = true
		end
	end)
end
return RebirthController
