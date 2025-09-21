local FeedbackController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("FeedbackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)
local NotificationController = require(Players.LocalPlayer.PlayerScripts.ClientModules.NotificationController)

local screen
local feedbackTextBox
local feedbackSubmitButton

function FeedbackController:Init()
	FeedbackController:CreateReferences()
	FeedbackController:InitButtonListerns()
end

function FeedbackController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("FEEDBACK_SCREEN")
	feedbackTextBox = UIReferences:GetReference("FEEDBACK_TEXT_BOX")
	feedbackSubmitButton = UIReferences:GetReference("FEEDBACK_SUBMIT")
end

function FeedbackController:Open()
	screen.Visible = true
end

function FeedbackController:Close()
	screen.Visible = false
end

function FeedbackController:GetScreen()
	return screen
end

function FeedbackController:InitButtonListerns()
	feedbackSubmitButton.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		if feedbackTextBox.Text == "" then
			NotificationController:ShowNotification("ERROR", "Type something...")
			return
		end

		screen.Visible = false
		if workspace.CurrentCamera:FindFirstChild("Blur") then
			workspace.CurrentCamera.Blur.Size = 0
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "SendFeedback",
			data = {
				Text = feedbackTextBox.Text,
			},
		})
	end)
end

return FeedbackController
