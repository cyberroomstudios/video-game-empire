local FastPlayerController = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SPEED_BOOST = 80 -- Velocidade quando está na área
local NORMAL_SPEED = 25 -- Velocidade padrão

function FastPlayerController:Init() end

function FastPlayerController:InitPartVerify()
	local function isInsidePart(part, position)
		-- Converte a posição do jogador para o espaço local da parte
		local localPos = part.CFrame:PointToObjectSpace(position)
		local halfSize = part.Size * 0.5

		-- Agora é só comparar com a metade do tamanho da parte
		return math.abs(localPos.X) <= halfSize.X
			and math.abs(localPos.Y) <= halfSize.Y
			and math.abs(localPos.Z) <= halfSize.Z
	end

	local function isPlayerInsideAnyPart(player)
		local character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return false
		end

		local pos = character.HumanoidRootPart.Position
		for _, part in pairs(CollectionService:GetTagged("FAST_PLAYER")) do
			if isInsidePart(part, pos) then
				return true
			end
		end
		return false
	end

	task.spawn(function()
		local player = Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local humanoid = char:WaitForChild("Humanoid")

		RunService.Heartbeat:Connect(function()
			if isPlayerInsideAnyPart(player) then
				humanoid.WalkSpeed = SPEED_BOOST
			else
				humanoid.WalkSpeed = NORMAL_SPEED
			end
		end)
	end)
end

return FastPlayerController
