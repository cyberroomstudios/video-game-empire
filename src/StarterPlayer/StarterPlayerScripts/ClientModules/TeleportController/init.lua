local TeleportController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

function TeleportController:Init() end

function TeleportController:ToWorkers()
	local spawnCFrame = player:GetAttribute("HIRE_AGENCY_CFRAME")

	if spawnCFrame then
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = spawnCFrame
		end
	end
end

function TeleportController:ToBase()
	local spawnCFrame = player:GetAttribute("SPAWN_CFRAME")

	if spawnCFrame then
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = spawnCFrame
		end
	end
end

function TeleportController:ToSell()
	local spawnCFrame = player:GetAttribute("SELL_CFRAME")

	if spawnCFrame then
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = spawnCFrame
		end
	end
end

function TeleportController:ToNextFloor()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = CFrame.new(
			character.HumanoidRootPart.CFrame.X,
			character.HumanoidRootPart.CFrame.Y + 26,
			character.HumanoidRootPart.CFrame.Z
		)
		local currentFloor = player:GetAttribute("CURRENT_FLOOR") or 0

		player:SetAttribute("CURRENT_FLOOR", currentFloor + 1)
	end
end

function TeleportController:ToPreviousFloor()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = CFrame.new(
			character.HumanoidRootPart.CFrame.X,
			character.HumanoidRootPart.CFrame.Y - 26,
			character.HumanoidRootPart.CFrame.Z
		)
		local currentFloor = player:GetAttribute("CURRENT_FLOOR")

		player:SetAttribute("CURRENT_FLOOR", currentFloor - 1)
	end
end

return TeleportController
