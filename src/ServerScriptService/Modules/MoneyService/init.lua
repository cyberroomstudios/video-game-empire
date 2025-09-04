local MoneyService = {}

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

function MoneyService:GiveMoney(player: Player, amount: number)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current + amount

		player:SetAttribute("MONEY", newMoney)

		return newMoney
	end)
end

function MoneyService:ConsumeMoney(player: Player, amount: number)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current - amount

		player:SetAttribute("MONEY", newMoney)

		return newMoney
	end)
end

function MoneyService:ConsumeAllMoney(player: Player)
	PlayerDataHandler:Set(player, "money", 0)
	player:SetAttribute("MONEY", 0)
end
return MoneyService
