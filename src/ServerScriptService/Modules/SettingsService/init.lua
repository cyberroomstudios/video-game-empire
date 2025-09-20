local SettingsService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("SettingsServices")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function SettingsService:Init()
	SettingsService:InitBridgeListener()
end

function SettingsService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "ToogleTheme" then
			SettingsService:ToogleMusicTheme(player)
		end

		if data[actionIdentifier] == "ToogleSoundEffect" then
			SettingsService:ToogleSoundEffect(player)
		end
		if data[actionIdentifier] == "ToogleVibration" then
			SettingsService:ToogleVibration(player)
		end
	end
end

function SettingsService:ToogleMusicTheme(player: Player)
	PlayerDataHandler:Update(player, "settingsMusicTheme", function(current)
		player:SetAttribute("SETTINGS_MUSIC_THEME", not current)
		return not current
	end)
end

function SettingsService:ToogleSoundEffect(player: Player)
	PlayerDataHandler:Update(player, "settingsSoundEffect", function(current)
		player:SetAttribute("SETTINGS_SOUND_EFFECT", not current)

		return not current
	end)
end

function SettingsService:ToogleVibration(player: Player)
	PlayerDataHandler:Update(player, "settingsVibration", function(current)
		player:SetAttribute("SETTINGS_VIBRATION", not current)
		return not current
	end)
end

function SettingsService:InitPlayer(player: Player)
	player:SetAttribute("SETTINGS_MUSIC_THEME", PlayerDataHandler:Get(player, "settingsMusicTheme"))
	player:SetAttribute("SETTINGS_SOUND_EFFECT", PlayerDataHandler:Get(player, "settingsSoundEffect"))
	player:SetAttribute("SETTINGS_VIBRATION", PlayerDataHandler:Get(player, "settingsVibration"))
end

return SettingsService
