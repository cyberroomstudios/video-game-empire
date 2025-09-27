local GameVersionService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameVersion")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local gameVersionBase = workspace:GetAttribute("GAME_VERSION")
local placeVersionBase = 2122

function GameVersionService:Init()
	GameVersionService:InitBridgeListener()
end

function GameVersionService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		
		if data[actionIdentifier] == "GetVersion" then
			return gameVersionBase .. "." .. tostring(game.PlaceVersion - placeVersionBase)
		end
	end
end

return GameVersionService
