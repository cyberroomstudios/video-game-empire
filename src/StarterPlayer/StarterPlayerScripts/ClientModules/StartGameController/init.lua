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

local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)
local FastPlayerController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FastPlayerController)

function StartGameController:Init(data)
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Start",
		data = {},
	})

	SoundManager:StartOrPauseBGM()
	Players.LocalPlayer:SetAttribute("LOADED_END_SCREEN", true)

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = playerGui:WaitForChild("LoadingScreen")

	screenGui.Enabled = false
	HireAgencyScreenController:CreateDevItems()
	FastPlayerController:InitPartVerify()

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
