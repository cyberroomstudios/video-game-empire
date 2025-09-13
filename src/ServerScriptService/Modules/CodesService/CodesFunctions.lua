local CodesFunctions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Codes = require(ReplicatedStorage.Enums.Codes)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

CodesFunctions["WELCOME"] = function(player)
	
	MoneyService:GiveMoney(player, 10000)
	return true
end

return CodesFunctions
