local SettingsController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SettingsServices")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local screen
local theme
local soundEffect
local vibration

function SettingsController:Init()
	SettingsController:CreateReferences()
	SettingsController:InitButtonListerns()
end

function SettingsController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("SETTINGS_FRAME")
	theme = UIReferences:GetReference("SETTINGS_THEME")
	soundEffect = UIReferences:GetReference("SETTINGS_SOUND_EFFECT")
	vibration = UIReferences:GetReference("SETTINGS_VIBRATION")
end

function SettingsController:InitButtonListerns()
	local function setupToggle(toggle, onEnable, onDisable)
		local offBtn = toggle.OFF
		local onBtn = toggle.ON
		local statusLabel = toggle.Status

		local function setState(isOn)
			offBtn.Visible = not isOn
			onBtn.Visible = isOn
			statusLabel.Text = isOn and "ON" or "OFF"

			if isOn and onEnable then
				onEnable()
			elseif not isOn and onDisable then
				onDisable()
			end
		end

		offBtn.MouseButton1Click:Connect(function()
			setState(true)
		end)

		onBtn.MouseButton1Click:Connect(function()
			setState(false)
		end)
	end

	setupToggle(theme.Toggle, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleTheme",
			data = {},
		})
	end, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleTheme",
			data = {},
		})
	end)

	setupToggle(soundEffect.Toggle, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleSoundEffect",
			data = {},
		})
	end, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleSoundEffect",
			data = {},
		})
	end)

	setupToggle(vibration.Toggle, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleVibration",
			data = {},
		})
	end, function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ToogleVibration",
			data = {},
		})
	end)
end

function SettingsController:Open()
	SettingsController:BuildScreen()
	screen.Visible = true
end

function SettingsController:Close()
	screen.Visible = false
end

function SettingsController:GetScreen()
	return screen
end

function SettingsController:BuildScreen()
	local settingsMusicTheme = player:GetAttribute("SETTINGS_MUSIC_THEME")
	local settingsSoundEffect = player:GetAttribute("SETTINGS_SOUND_EFFECT")
	local settingsVibration = player:GetAttribute("SETTINGS_VIBRATION")

	if settingsMusicTheme then
		theme.Toggle.OFF.Visible = false
		theme.Toggle.ON.Visible = true
		theme.Toggle.Status.Text = "ON"
	else
		theme.Toggle.OFF.Visible = true
		theme.Toggle.ON.Visible = false
		theme.Toggle.Status.Text = "OFF"
	end

	if settingsSoundEffect then
		soundEffect.Toggle.OFF.Visible = false
		soundEffect.Toggle.ON.Visible = true
		soundEffect.Toggle.Status.Text = "ON"
	else
		soundEffect.Toggle.OFF.Visible = true
		soundEffect.Toggle.ON.Visible = false
		soundEffect.Toggle.Status.Text = "OFF"
	end

	if settingsVibration then
		vibration.Toggle.OFF.Visible = false
		vibration.Toggle.ON.Visible = true
		vibration.Toggle.Status.Text = "ON"
	else
		vibration.Toggle.OFF.Visible = true
		vibration.Toggle.ON.Visible = false
		vibration.Toggle.Status.Text = "OFF"
	end
end

return SettingsController
