local FeedbackService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local bridge = BridgeNet2.ReferenceBridge("FeedbackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local feedbacks = {}

function FeedbackService:Init()
	FeedbackService:InitBridgeListener()
end

function FeedbackService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "SendFeedback" then
			local text = data.data.Text

			FeedbackService:AddFeedback(player, text)
		end
	end
end

function FeedbackService:AddFeedback(player, text)
	if feedbacks[player] then
		GameNotificationService:SendWarnNotification(player, "Only 1 Feedback Per Session!")
		return
	end

	feedbacks[player] = text
	player:SetAttribute("FEEDBACK_TEXT", text)
	GameNotificationService:SendSuccessNotification(player, "Thanks for your Feedback!💓")
end

function FeedbackService:ConsomeFeedback(player)
	if feedbacks[player] then
		local text = feedbacks[player]
		feedbacks[player] = nil
		return text
	end
end

return FeedbackService
