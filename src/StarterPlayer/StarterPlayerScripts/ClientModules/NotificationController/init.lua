local NotificationController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("NotificationService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local notificationScreen
local stockNotification
local notificationsTemplate

function NotificationController:Init()
	NotificationController:CreateReferences()
	NotificationController:InitListeners()
end

function NotificationController:CreateReferences()
	notificationScreen = UIReferences:GetReference("SYSTEM_NOTIFICATION")
	stockNotification = UIReferences:GetReference("STOCK_NOTIFICATION")

	notificationsTemplate = {
		["WARN"] = ReplicatedStorage.GUI.Notifications.WarnNotification,
		["ERROR"] = ReplicatedStorage.GUI.Notifications.ErrorNotification,
		["SUCCESS"] = ReplicatedStorage.GUI.Notifications.SuccessNotification,
	}
end

function NotificationController:InitListeners()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowWarnNotification" then
			SoundManager:Play("NOTIFICATION_ERROR")
			NotificationController:ShowNotification("WARN", response.data.Message)
		end

		if response[actionIdentifier] == "ShowErrorNotification" then
			SoundManager:Play("NOTIFICATION_ERROR")

			NotificationController:ShowNotification("ERROR", response.data.Message)
		end

		if response[actionIdentifier] == "ShowSuccessNotificaion" then
			SoundManager:Play("NOTIFICATION_SUCCESS")

			NotificationController:ShowNotification("SUCCESS", response.data.Message)
		end

		if response[actionIdentifier] == "ShowStockNotification" then
			SoundManager:Play("RESTOCK")

			NotificationController:ShowStockNotification()
		end
	end)
end

function NotificationController:ShowNotification(notificationType: string, message: string)
	if not notificationsTemplate[notificationType] then
		return
	end

	local template = notificationsTemplate[notificationType]:Clone()
	template.Message.NotificationsText.Text = message
	template.Parent = notificationScreen

	task.delay(1.5, function()
		template:Destroy()
	end)
end

function NotificationController:ShowStockNotification()
	stockNotification.Visible = true
	task.delay(2, function()
		stockNotification.Visible = false
	end)
end

return NotificationController
