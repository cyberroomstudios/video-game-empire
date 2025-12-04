local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)

-- Verifica se todos os games do doc estão com uma tool que representa
local function VerifyAllGameTools()
	local success = true
	local gameFolder = ServerStorage.Tools.Games
	for _, value in Games do
		if not gameFolder:FindFirstChild(value.Name) then
			warn("[HEALTH CHECK] Game Tool Not Found:" .. value.Name)
			success = false
		end
	end

	if success then
		warn("[HEALTH CHECK] Game Tool Sucess")
	end
end

-- Verifica se todos os jogos produzidos por um programador estão definidas também no doc de game

VerifyAllGameTools()
