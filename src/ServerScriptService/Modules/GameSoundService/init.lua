local GameSoundService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SoundManager")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

function GameSoundService:Init() end

function GameSoundService:Play(player, sound)
	bridge:Fire(player, {
		[actionIdentifier] = "Play",
		data = sound,
	})
end

function GameSoundService:PlayAllPlayers(sound)
	task.spawn(function()
		for _, player in Players:GetPlayers() do
			bridge:Fire(player, {
				[actionIdentifier] = "Play",
				data = sound,
			})
		end
	end)
end

return GameSoundService
