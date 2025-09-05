local TeleportController = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

function TeleportController:Init() end

function TeleportController:ToWorkers()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = Workspace.Map.HireAgency.Agency.Spawn.CFrame
	end
end

function TeleportController:ToBase()
	local base = Workspace.Map.BaseMaps[player:GetAttribute("BASE")]
	local character = player.Character

	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = base.Spawn.CFrame
	end
end

function TeleportController:ToSell()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = Workspace.Map.SellShop.SellShop.Spawn.CFrame
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
