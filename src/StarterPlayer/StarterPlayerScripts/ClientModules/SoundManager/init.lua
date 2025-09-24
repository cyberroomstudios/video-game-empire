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
	BGM = "",
	UI_CLICK = "",
	UI_OPEN_SCREEN = "",
	MONEY_COMING_IN = "",
	MONEY_COMING_OUT = "",
	COLLECT_GAME = "",
	COLLECT_NEW_GAME = "",
	NOTIFICATION_ERROR = "",
	NOTIFICATION_SUCCESS = "",
	RESTOCK = "",
}

local soundLooped = {}

function SoundManager:Init()
	SoundManager:InitRef()
	SoundManager:InitBridgeListener()
end

function SoundManager:InitRef()
	sounds["BGM"] = SoundService.Game.BGM
	sounds["UI_CLICK"] = SoundService.GUI.Click
	sounds["UI_OPEN_SCREEN"] = SoundService.GUI.OpenScreen
	sounds["MONEY_COMING_IN"] = SoundService.GUI.MoneyComingIn
	sounds["MONEY_COMING_OUT"] = SoundService.GUI.MoneyComingOut
	sounds["COLLECT_GAME"] = SoundService.Game.CollectGame
	sounds["COLLECT_NEW_GAME"] = SoundService.Game.CollectNewGame
	sounds["NOTIFICATION_ERROR"] = SoundService.Notification.Error
	sounds["NOTIFICATION_SUCCESS"] = SoundService.Notification.Success
	sounds["RESTOCK"] = SoundService.Notification.Restock
end

function SoundManager:StartOrPauseBGM()
	local settingsMusicTheme = Players.LocalPlayer:GetAttribute("SETTINGS_MUSIC_THEME")
	if settingsMusicTheme then
		sounds["BGM"]:Play()
	else
		sounds["BGM"]:Stop()
	end
end
function SoundManager:Play(sondName: string)
	local settingsSoundEffect = Players.LocalPlayer:GetAttribute("SETTINGS_SOUND_EFFECT")

	if not settingsSoundEffect then
		return
	end
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
