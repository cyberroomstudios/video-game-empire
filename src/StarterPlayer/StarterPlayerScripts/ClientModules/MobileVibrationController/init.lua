local MobileVibrationController = {}
local Players = game:GetService("Players")

local player = Players.LocalPlayer
function MobileVibrationController:Init() end

function MobileVibrationController:Start()
	if player:GetAttribute("SETTINGS_VIBRATION") then
		task.spawn(function()
			local Workspace = game:GetService("Workspace")

			local effect = Instance.new("HapticEffect")
			effect.Type = Enum.HapticEffectType.GameplayExplosion
			effect.Looped = true
			effect.Parent = Workspace

			effect:Play()
			task.wait(0.01)
			effect:Stop()
		end)
	end
end
return MobileVibrationController
