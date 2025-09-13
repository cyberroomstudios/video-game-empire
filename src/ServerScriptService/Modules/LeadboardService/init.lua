local LeadboardService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)

local playtimeLeadboardModule = require(script.playtimeLeadboard)
local ccuLeadboardModule = require(script.ccuLeadboard)
local moneyLeadboardModule = require(script.moneyLeadboard)
local robuxLeadboardModule = require(script.robuxLeadboard)

function LeadboardService:Init()
	task.spawn(function()
		print("Init")
		LeadboardService:UpdateEveryTime()
	end)
end

function LeadboardService:UpdateDataStore()
	for _, player in Players:GetPlayers() do
		local playtime = PlayerDataHandler:Get(player, "totalPlaytime")

		if playtime then
			playtimeLeadboardModule:RegisterEntry(player.UserId, playtime)
		end

		local ccu = PlayerDataHandler:Get(player, "totalCCU")

		if ccu then
			ccuLeadboardModule:RegisterEntry(player.UserId, ccu)
		end

		local money = PlayerDataHandler:Get(player, "money")

		if money then
			moneyLeadboardModule:RegisterEntry(player.UserId, money)
		end

		local robuxSpent = PlayerDataHandler:Get(player, "robuxSpent")

		if robuxSpent then
			robuxLeadboardModule:RegisterEntry(player.UserId, robuxSpent)
		end
	end
end

function LeadboardService:UpdateEveryTime()
	Players.PlayerAdded:Wait()

	while true do
		pcall(function()
			LeadboardService:UpdateDataStore()
		end)

		LeadboardService:UpdateLeadboard("PlaytimeLeadboard", playtimeLeadboardModule:GetLeaderboards())
		LeadboardService:UpdateLeadboard("CCULeaderboard", ccuLeadboardModule:GetLeaderboards())
		LeadboardService:UpdateLeadboard("MoneyLeaderboad", moneyLeadboardModule:GetLeaderboards())
		LeadboardService:UpdateLeadboard("RobuxLeadboard", robuxLeadboardModule:GetLeaderboards())

		task.wait(60 * 5)
	end
end

function LeadboardService:UpdateLeadboard(leadboardName, items)
	local formatters = {
		PlaytimeLeadboard = function(val)
			return LeadboardService:FormatTime(val)
		end,
		MoneyLeaderboad = function(val)
			return "$" .. LeadboardService:AbbreviateNumber(val)
		end,
		RobuxLeadboard = function(val)
			return "R$" .. LeadboardService:AbbreviateNumber(val)
		end,
		CCULeaderboard = function(val)
			return LeadboardService:AbbreviateNumber(val)
		end,
	}

	local scrollingFrame = UtilService:WaitForDescendants(
		workspace,
		"Map",
		"CentralSquare",
		"CentralSquare",
		"Leaderboard",
		leadboardName,
		"Billboard",
		"SurfaceGui",
		"ScrollingFrame"
	)

	-- Limpando todos os itens
	for _, value in scrollingFrame:GetChildren() do
		if value:GetAttribute("IS_ITEM") then
			value:Destroy()
		end
	end

	for index, value in items do
		local itemTemplate = index % 2 == 0 and scrollingFrame.RankPlayer1 or scrollingFrame.RankPlayer2
		pcall(function()
			local newItem = itemTemplate:Clone()
			newItem:SetAttribute("IS_ITEM")
			newItem.Visible = true
			newItem.RankFrame.Rank.Text = "#" .. index
			newItem.PlayerName.Text = LeadboardService:GetPlayerNameById(value.playerUserId)

			newItem.Quantity.Text = formatters[leadboardName](value.value)

			newItem.PlayerImage.ImageLabel.Image = LeadboardService:GetThumb(value.playerUserId)
			newItem.Parent = scrollingFrame
		end)
	end
end

--- UTIL ---
function LeadboardService:GetThumb(userId)
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	if content and isReady then
		return content
	end
end

function LeadboardService:AbbreviateNumber(num)
	local suffixes = { "", "k", "M", "B", "T", "Q" }
	local i = 1

	while num >= 1000 and i < #suffixes do
		num = num / 1000
		i = i + 1
	end

	local isInteger = math.floor(num * 10) % 10 == 0
	if isInteger then
		return string.format("%d%s", num, suffixes[i])
	else
		return string.format("%.1f%s", num, suffixes[i])
	end
end

function LeadboardService:GetPlayerNameById(playerId)
	local success, playerName = pcall(function()
		return Players:GetNameFromUserIdAsync(playerId)
	end)

	if success then
		return playerName
	end
end

function LeadboardService:FormatTime(totalTime)
	local days = math.floor(totalTime / 86400)
	totalTime = totalTime % 86400
	local hours = math.floor(totalTime / 3600)
	totalTime = totalTime % 3600
	local minutes = math.floor(totalTime / 60)
	local seconds = totalTime % 60

	return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
end

return LeadboardService
