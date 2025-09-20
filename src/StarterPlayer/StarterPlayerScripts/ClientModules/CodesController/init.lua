local CodesController = {}

local Players = game:GetService("Players")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("CodesService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local textBox
local sendButton

function CodesController:Init()
	CodesController:CreateReferences()
	CodesController:InitButtonListerns()
end

function CodesController:CreateReferences()
	screen = UIReferences:GetReference("CODES_FRAME")
	textBox = UIReferences:GetReference("CODES_TEXT_BOX")
	sendButton = UIReferences:GetReference("CODES_SEND_BUTTON")
end

function CodesController:Open()
	screen.Visible = true
end

function CodesController:Close()
	screen.Visible = false
end

function CodesController:GetScreen()
	return screen
end
function CodesController:SendCode()
	local text = textBox.Text
	local debounce = true

	if debounce then
		screen.Visible = false
		if workspace.CurrentCamera:FindFirstChild("Blur") then
			workspace.CurrentCamera.Blur.Size = 0
		end
		debounce = false
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetCodeAward",
			data = {
				Text = text,
			},
		})
		debounce = true
	end
end

function CodesController:InitButtonListerns()
	sendButton.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		CodesController:SendCode()
	end)
end
return CodesController
