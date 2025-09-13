local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local LeadStatsService = {}

function LeadStatsService:Init() end

function LeadStatsService:InitPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = math.floor(PlayerDataHandler:Get(player, "money"))
	money.Parent = leaderstats

	local totalCCU = Instance.new("IntValue")
	totalCCU.Name = "CCU"
	totalCCU.Value = math.floor(PlayerDataHandler:Get(player, "totalCCU"))
	totalCCU.Parent = leaderstats
end

function LeadStatsService:UpdateMoney(player: Player)
	pcall(function()
		local money = PlayerDataHandler:Get(player, "money")

		local leaderstats = player and player:FindFirstChild("leaderstats")
		local moneyStats = leaderstats and leaderstats:FindFirstChild("Money")
		if moneyStats then
			moneyStats.Value = money
		end
	end)
end

function LeadStatsService:UpdateCCU(player: Player)
	pcall(function()
		local totalCCU = PlayerDataHandler:Get(player, "totalCCU")

		local leaderstats = player and player:FindFirstChild("leaderstats")
		local ccuStats = leaderstats and leaderstats:FindFirstChild("CCU")
		if ccuStats then
			ccuStats.Value = totalCCU
		end
	end)
end
return LeadStatsService
