local SoundManager = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SoundManager")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local sounds = {
	TO_TYPE = "",
}

local soundLooped = {}

function SoundManager:Init()
	SoundManager:InitRef()
	SoundManager:InitBridgeListener()

end

function SoundManager:InitRef()
	sounds["TO_TYPE"] = SoundService.Game.ToType
end

function SoundManager:Play(sondName: string)
	local sound = sounds[sondName]:Clone()
	sound.Parent = script.Parent
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function SoundManager:PlayWithLooped(sondName: string)
	if not soundLooped[sondName] then
		local sound = sounds[sondName]:Clone()
		sound.Parent = script.Parent
		sound:Play()
		soundLooped[sondName] = sound

		return
	end

	soundLooped[sondName]:Play()
end

function SoundManager:StopWithLooped(sondName: string)
	if soundLooped[sondName] then
		soundLooped[sondName]:Stop()
	end
end

function SoundManager:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "Play" then
			SoundManager:Play(response.data)
		end
	end)
end

return SoundManager
