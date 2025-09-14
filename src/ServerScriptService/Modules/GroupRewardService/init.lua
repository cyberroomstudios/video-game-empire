local GroupRewardService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local bridge = BridgeNet2.ReferenceBridge("GroupRewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function GroupRewardService:Init()
	GroupRewardService:InitBridgeListener()
end

function GroupRewardService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetGroupRewardService" then
			GroupRewardService:GetGroupReward(player)
		end
	end
end

function GroupRewardService:GetGroupReward(player: Player)
	if player:IsInGroup(720031173) then
		local groupRewardClaimed = PlayerDataHandler:Get(player, "groupRewardClaimed")

		if not groupRewardClaimed then
			PlayerDataHandler:Set(player, "groupRewardClaimed", true)
			GameNotificationService:SendSuccessNotification(player, "Prize Collected Successfully!")
			return
		end

		GameNotificationService:SendErrorNotification(player, "Prize already collected")
		return
	end

	GameNotificationService:SendErrorNotification(player, "You must join the group and like the game")
end
return GroupRewardService
