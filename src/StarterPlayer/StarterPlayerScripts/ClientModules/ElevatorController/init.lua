local ElevatorController = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)

local player = Players.LocalPlayer

local elevatorScreen
local elevatorUp
local elevatorDown

function ElevatorController:Init()
	ElevatorController:CreateReferences()
	ElevatorController:InitCheckElevatorUI()
	ElevatorController:InitButtonListerns()
end

function ElevatorController:IsPlayerInsidePartXZ(part, hrp)
	local partPos = part.Position
	local partSize = part.Size

	local minX = partPos.X - partSize.X / 2
	local maxX = partPos.X + partSize.X / 2
	local minZ = partPos.Z - partSize.Z / 2
	local maxZ = partPos.Z + partSize.Z / 2

	local px, pz = hrp.Position.X, hrp.Position.Z

	return (px >= minX and px <= maxX) and (pz >= minZ and pz <= maxZ)
end

function ElevatorController:CreateReferences()
	-- Botões referentes aos Teleports
	elevatorScreen = UIReferences:GetReference("ELEVATOR")
	elevatorUp = UIReferences:GetReference("ELEVATOR_UP")
	elevatorDown = UIReferences:GetReference("ELEVATOR_DOWN")
end

function ElevatorController:InitButtonListerns()
	elevatorUp.MouseButton1Click:Connect(function()
		TeleportController:ToNextFloor()
	end)

	elevatorDown.MouseButton1Click:Connect(function()
		TeleportController:ToPreviousFloor()
	end)
end

function ElevatorController:InitCheckElevatorUI()
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local bases = {}

	for i = 1, 8 do
		table.insert(bases, ClientUtil:WaitForDescendants(workspace, "Map", "BaseMaps", i, "WorkArea", "WorkArea"))
	end

	RunService.Heartbeat:Connect(function()
		local insideInBabse = false
		local base = nil
		for _, part in bases do
			if ElevatorController:IsPlayerInsidePartXZ(part, hrp) then
				elevatorScreen.Visible = true
				insideInBabse = true
				base = part.Parent.Parent
				break
			else
				insideInBabse = false
			end
		end

		if insideInBabse then
			local baseFloor = base:GetAttribute("FLOOR") or 0

			if baseFloor > 0 then
				local character = player.Character
				ElevatorController:ChangeElevatorButtonColors(base)
				elevatorScreen.Visible = true
			else
				elevatorScreen.Visible = false
			end
		else
			elevatorScreen.Visible = false
		end
	end)
end

function ElevatorController:ChangeElevatorButtonColors(base)
	local currentFloor = player:GetAttribute("CURRENT_FLOOR") or 0

	if currentFloor == 0 then
		elevatorDown.BackgroundTransparency = 0.5
		elevatorDown.Interactable = false

		elevatorUp.BackgroundTransparency = 0
		elevatorUp.Interactable = true
		return
	end

	if currentFloor == base:GetAttribute("FLOOR") then
		elevatorDown.BackgroundTransparency = 0
		elevatorDown.Interactable = true

		elevatorUp.BackgroundTransparency = 0.5
		elevatorUp.Interactable = false
		return
	end

	elevatorDown.BackgroundTransparency = 0
	elevatorDown.Interactable = true

	elevatorUp.BackgroundTransparency = 0
	elevatorUp.Interactable = true
end

return ElevatorController
