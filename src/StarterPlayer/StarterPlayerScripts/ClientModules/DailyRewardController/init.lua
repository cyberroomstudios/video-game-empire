local DailyRewardController = {}
local Players = game:GetService("Players")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("DailyRewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local nextRewardFrame
local day1Button
local day2Button
local day3Button
local day4Button
local day5Button
local day6Button
local day7Button

function DailyRewardController:Init()
	DailyRewardController:CreateReferences()
	DailyRewardController:InitButtonListerns()
end

function DailyRewardController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("DAILY_REWARD")

	nextRewardFrame = UIReferences:GetReference("NEXT_REWARD")
	day1Button = UIReferences:GetReference("DAILY_REWARD_DAY_1")
	day2Button = UIReferences:GetReference("DAILY_REWARD_DAY_2")
	day3Button = UIReferences:GetReference("DAILY_REWARD_DAY_3")
	day4Button = UIReferences:GetReference("DAILY_REWARD_DAY_4")
	day5Button = UIReferences:GetReference("DAILY_REWARD_DAY_5")
	day6Button = UIReferences:GetReference("DAILY_REWARD_DAY_6")
	day7Button = UIReferences:GetReference("DAILY_REWARD_DAY_7")
end

function DailyRewardController:Open()
	screen.Visible = true
end

function DailyRewardController:Close()
	screen.Visible = false
end

function DailyRewardController:GetScreen()
	return screen
end

function DailyRewardController:InitButtonListerns()
	local daysButton = {
		[1] = day1Button,
		[2] = day2Button,
		[3] = day3Button,
		[4] = day4Button,
		[5] = day5Button,
		[6] = day6Button,
		[7] = day7Button,
	}

	local debounce = true
	for i = 1, 7 do
		daysButton[i].MouseButton1Click:Connect(function()
			SoundManager:Play("UI_CLICK")

			if debounce then
				debounce = false
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "GetDailyReward",
					data = {
						DayNumber = i,
					},
				})

				if result then
					local dailyReward = result.DailyReward
					local daysWithRigthPrize = result.DaysWithRigthPrize
					DailyRewardController:FillDailyClaimed(dailyReward, daysWithRigthPrize)
				end

				debounce = true
			end
		end)
	end
end

function DailyRewardController:UpdateNextReward(minLeftNextDay: number)
	task.spawn(function()
		while true do
			minLeftNextDay = minLeftNextDay - 1

			-- Conversão para horas, minutos e segundos
			local hours = math.floor(minLeftNextDay / 3600)
			local minutes = math.floor((minLeftNextDay % 3600) / 60)
			local seconds = minLeftNextDay % 60

			-- Formatação com zero à esquerda
			local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
			nextRewardFrame.Text = "NEXT REWARD IN: " .. formattedTime

			task.wait(1)

			if minLeftNextDay == 0 then
				-- 1 Dia
				minLeftNextDay = 86400
			end
		end
	end)
end

function DailyRewardController:FillDailyClaimed(dailyReward, daysWithRigthPrize: number)
	local daysButton = {
		[1] = day1Button,
		[2] = day2Button,
		[3] = day3Button,
		[4] = day4Button,
		[5] = day5Button,
		[6] = day6Button,
		[7] = day7Button,
	}

	for index, value in dailyReward do
		if value == true then
			local item = daysButton[index].Parent
			-- Pinta o Item de Verde

			item.Check.Visible = true
			item.Claim.Visible = false
		else
			if index <= daysWithRigthPrize then
				local item = daysButton[index].Parent

				item.Check.Visible = false
				item.Claim.Visible = true
			end
		end
	end
end

return DailyRewardController
