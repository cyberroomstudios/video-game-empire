local StartGameController = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local HireAgencyScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.HireAgencyScreenController)
local DailyRewardController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DailyRewardController)
local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function StartGameController:Init(data)
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Start",
		data = {},
	})

	HireAgencyScreenController:CreateDevItems()

	if result then
		StartGameController:FillDailyReward(result)
	end
end

function StartGameController:FillDailyReward(result)
	local dailyReward = result.DailyReward
	local daysWithRigthPrize = result.DaysWithRigthPrize
	local minLeftNextDay = result.MinLeftNextDay

	if daysWithRigthPrize == 0 then
		daysWithRigthPrize = 1
	end

	DailyRewardController:UpdateNextReward(minLeftNextDay)
	DailyRewardController:FillDailyClaimed(dailyReward, daysWithRigthPrize)
end

return StartGameController
