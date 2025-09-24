local ServerScriptService = game:GetService("ServerScriptService")

local DailyRewardService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local BridgeNet2 = require(Utility.BridgeNet2)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local Messages = require(ReplicatedStorage.Enums.Messages)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local DevService = require(ServerScriptService.Modules.DevService)
local bridge = BridgeNet2.ReferenceBridge("DailyRewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function DailyRewardService:Init()
	DailyRewardService:InitBridgeListener()
end

function DailyRewardService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetDailyReward" then
			local dayNumber = data.data.DayNumber
			local success = DailyRewardService:GetDailyReward(player, dayNumber)

			if success then
				return {
					DailyReward = PlayerDataHandler:Get(player, "dailyReward"),
					DaysWithRigthPrize = PlayerDataHandler:Get(player, "daysWithRigthPrize"),
				}
			end
		end
	end
end

function DailyRewardService:GetDailyReward(player: Player, dayNumber: number)
	local dailyReward = PlayerDataHandler:Get(player, "dailyReward")
	local success = false
	PlayerDataHandler:Update(player, "dailyReward", function(current)
		-- Ultimo dia da semana que o jogador pegou o premio
		local currentDayReward = PlayerDataHandler:Get(player, "currentDayReward")

		-- Quantidade de dias da semana premiado
		local daysWithRigthPrize = PlayerDataHandler:Get(player, "daysWithRigthPrize")

		if ((currentDayReward + 1) <= daysWithRigthPrize) and currentDayReward + 1 == dayNumber then
			if not current[currentDayReward + 1] then
				-- Dá o premio
				current[currentDayReward + 1] = true
				DailyRewardService:GivePrize(player, dayNumber)
				success = true

				PlayerDataHandler:Set(player, "currentDayReward", currentDayReward + 1)
			end
		end

		return current
	end)

	return success
end

function DailyRewardService:GivePrize(player: Player, dayNumber: number)
	if dayNumber == 1 then
		MoneyService:GiveMoney(player, 100)
	end

	if dayNumber == 2 then
		MoneyService:GiveMoney(player, 3000)
	end

	if dayNumber == 3 then
		DevService:GiveDevFromRobux(player, "4_SeniorDev")
	end

	if dayNumber == 4 then
		MoneyService:GiveMoney(player, 10000)
	end

	if dayNumber == 5 then
		MoneyService:GiveMoney(player, 50000)
	end

	if dayNumber == 6 then
		DevService:GiveDevFromRobux(player, "6_TechLead")
	end

	if dayNumber == 7 then
		DevService:GiveDevFromRobux(player, "SahurDev")
	end
end

function DailyRewardService:GetDayDifference(player: Player)
	local lastDateLogin = PlayerDataHandler:Get(player, "lastDateLogin")

	if lastDateLogin == "" then
		return -1
	end

	-- Extrai dia, mês e ano da string "dd/mm/yyyy"
	local day, month, year = string.match(lastDateLogin, "(%d+)%/(%d+)%/(%d+)")
	day = tonumber(day)
	month = tonumber(month)
	year = tonumber(year)

	-- Converte para timestamp à meia-noite
	local lastTime = os.time({ day = day, month = month, year = year, hour = 0, min = 0, sec = 0 })

	-- Pega data atual à meia-noite
	local now = os.date("*t")
	local currentTime = os.time({ day = now.day, month = now.month, year = now.year, hour = 0, min = 0, sec = 0 })

	-- DATA FIXA PARA TESTES (substitua aqui pelo que quiser testar)
	--local fakeNow = { day = 20, month = 8, year = 2025, hour = 0, min = 0, sec = 0 }
	--local currentTime = os.time(fakeNow)

	-- Calcula diferença em segundos e converte para dias
	local secondsDifference = os.difftime(currentTime, lastTime)
	local daysDifference = math.floor(secondsDifference / (60 * 60 * 24))

	return daysDifference
end

function DailyRewardService:CalculateMinLeftDay(player: Player)
	local now = os.date("*t")

	-- Timestamp do momento atual
	local currentTimestamp = os.time(now)

	-- Timestamp do próximo dia à meia-noite
	local nextDayTimestamp = os.time({
		year = now.year,
		month = now.month,
		day = now.day + 1,
		hour = 0,
		min = 0,
		sec = 0,
	})

	-- Diferença em segundos
	local secondsUntilNextDay = nextDayTimestamp - currentTimestamp
	return secondsUntilNextDay
end

function DailyRewardService:UpdateData(player: Player)
	local now = os.time() -- obtém o timestamp atual
	local date = os.date("*t", now) -- converte o timestamp para tabela
	local formattedDate = string.format("%02d/%02d/%04d", date.day, date.month, date.year)

	--	formattedDate = "20/08/2025"

	PlayerDataHandler:Set(player, "lastDateLogin", formattedDate)
end

function DailyRewardService:ResetDailyReward(player: Player)
	-- Zera tudo
	PlayerDataHandler:Update(player, "dailyReward", function(current)
		local newDaily = current
		for index, value in current do
			newDaily[index] = false
		end

		return newDaily
	end)

	PlayerDataHandler:Set(player, "currentDayReward", 0)

	PlayerDataHandler:Update(player, "daysWithRigthPrize", function(current)
		current = 1
		return current
	end)
end

function DailyRewardService:SetDate(player: Player)
	local lastDateLogin = PlayerDataHandler:Get(player, "lastDateLogin")

	if lastDateLogin == "" then
		PlayerDataHandler:Update(player, "daysWithRigthPrize", function(current)
			current = 1
			return current
		end)

		DailyRewardService:UpdateData(player)
		return
	end

	local differenceDay = DailyRewardService:GetDayDifference(player)
	if differenceDay == 1 then
		local daysWithRigthPrize = PlayerDataHandler:Get(player, "daysWithRigthPrize")

		if daysWithRigthPrize == 7 then
			DailyRewardService:UpdateData(player)
			DailyRewardService:ResetDailyReward(player)
			return
		end

		PlayerDataHandler:Update(player, "daysWithRigthPrize", function(current)
			current = current + 1
			return current
		end)

		DailyRewardService:UpdateData(player)
		return
	end

	if differenceDay > 1 then
		DailyRewardService:ResetDailyReward(player)
	end

	DailyRewardService:UpdateData(player)
end

return DailyRewardService
