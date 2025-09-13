local CodesService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Codes = require(ReplicatedStorage.Enums.Codes)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local CodesFunctions = require(script.CodesFunctions)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local Messages = require(ReplicatedStorage.Enums.Messages)
local bridge = BridgeNet2.ReferenceBridge("CodesService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function CodesService:Init()
	CodesService:InitBridgeListener()
end

function CodesService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetCodeAward" then
			CodesService:GiveAward(player, data.data.Text)
		end
	end
end

function CodesService:GiveAward(player: Player, codeText: string)
	local upperCode = string.upper(codeText)
	local code = Codes:HasCode(upperCode)

	if code then
		-- Verifica se o jogador ja utilizou o código
		local hasAlready = CodesService:PlayerHasAlreadyUsedCode(player, upperCode)
		if not hasAlready then
			-- Insere o código na base do jogador
			CodesService:InsertCodeToPlayer(player, upperCode)

			local action = CodesFunctions[upperCode]
			action(player)

			GameNotificationService:SendSuccessNotification(player, Messages.CODE_APPLIED)

			return true
		end

		GameNotificationService:SendErrorNotification(player, Messages.CODE_ALREADY_USES)
		return false
	end

	GameNotificationService:SendErrorNotification(player, Messages.CODE_DOES_NOT_EXIST)

	return false
end

function CodesService:PlayerHasAlreadyUsedCode(player: Player, code: string)
	local codesFromPlayer = PlayerDataHandler:Get(player, "codesUsed")

	for _, codePlayer in codesFromPlayer do
		if string.upper(codePlayer) == string.upper(code) then
			return true
		end
	end

	return false
end

function CodesService:InsertCodeToPlayer(player: Player, code: string)
	PlayerDataHandler:Update(player, "codesUsed", function(current)
		table.insert(current, code)
		return current
	end)
end

return CodesService
