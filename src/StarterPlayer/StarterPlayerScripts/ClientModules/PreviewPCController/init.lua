local PreviewPCController = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local currentRotation = 0
local base

local previewPcButtons

function PreviewPCController:Init()
	if UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then
		print("O jogador está no PC")
		PreviewPCController:CreateReferences()
		PreviewPCController:InitEquipToolListner()
	end
end

function PreviewPCController:CreateReferences()
	--	previewPcButtons = UIReferences:GetReference("PREVIEW_BUTTONS_PC")
end

function PreviewPCController:IsPartInside(partA, partB)
	local posA, sizeA = partA.Position, partA.Size
	local posB, sizeB = partB.Position, partB.Size

	-- Calcula os limites de cada parte no plano XZ
	local minA = Vector2.new(posA.X - sizeA.X / 2, posA.Z - sizeA.Z / 2)
	local maxA = Vector2.new(posA.X + sizeA.X / 2, posA.Z + sizeA.Z / 2)

	local minB = Vector2.new(posB.X - sizeB.X / 2, posB.Z - sizeB.Z / 2)
	local maxB = Vector2.new(posB.X + sizeB.X / 2, posB.Z + sizeB.Z / 2)

	-- Verifica se os limites de A estão dentro dos limites de B (apenas X e Z)
	return (minA.X >= minB.X and maxA.X <= maxB.X and minA.Y >= minB.Y and maxA.Y <= maxB.Y)
end

function PreviewPCController:GetCollidingModels(hitbox: BasePart)
	-- Certifique-se de que CanTouch está ativado
	hitbox.CanTouch = true

	-- Precisa esperar um frame para que a física atualize a colisão
	task.wait()

	local touchingParts = hitbox:GetTouchingParts()
	local collidingModels = {}

	for _, part in ipairs(touchingParts) do
		local parentModel = part:FindFirstAncestorOfClass("Model")
		if parentModel and parentModel ~= hitbox:FindFirstAncestorOfClass("Model") then
			collidingModels[parentModel] = true
		end
	end

	-- Converte em lista se preferir
	local result = {}
	for model in pairs(collidingModels) do
		table.insert(result, model)
	end

	return result
end

function PreviewPCController:GetModelTouchingParts(part: BasePart)
	-- Configuração do filtro
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { part } -- evita retornar a própria parte

	-- Retorna as partes encostando ou dentro da "part"
	return workspace:GetPartsInPart(part, overlapParams)
end

function PreviewPCController:InitPreview(itemName: string, toolType: string)
	-- Remove qualquer preview antigo
	if workspace:FindFirstChild("Preview") then
		workspace.Preview:Destroy()
	end

	-- Clona o modelo
	local clonedModel
	if toolType == "DEV" then
		clonedModel = ReplicatedStorage.Model.Devs[itemName]:Clone()
	elseif toolType == "STORAGE" then
		clonedModel = ReplicatedStorage.Model.Devs[itemName]:Clone()
	end

	if not clonedModel then
		return
	end

	-- Define altura base
	local fixedY = workspace:GetAttribute("DEV_Y_POSITION") + 0.3

	-- Aplica rotação inicial
	if player:GetAttribute("ROTATE_PREVIEW") then
		player:SetAttribute("ROTATE_PREVIEW", false)
		currentRotation += 90
	end

	-- Configura RaycastParams para ignorar player e preview
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { player.Character, clonedModel }

	-- Função auxiliar para pegar posição do mouse ignorando player e preview
	local function getMousePosition()
		local unitRay = mouse.UnitRay
		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)
		if raycastResult then
			return raycastResult.Position
		end
		return nil
	end

	local function snapToGrid(value, grid)
		return math.floor((value + grid / 2) / grid) * grid
	end

	-- Define posição inicial
	local startPos = getMousePosition()
	if startPos then
		local newPosition = Vector3.new(startPos.X, fixedY, startPos.Z)
		local rotation = CFrame.Angles(0, math.rad(currentRotation), 0)

		clonedModel:PivotTo(CFrame.new(newPosition) * rotation)
	end

	clonedModel.Name = "Preview"
	clonedModel.Parent = workspace

	-- Desconecta conexão antiga
	if self.previewConnection then
		self.previewConnection:Disconnect()
	end

	if not base then
		base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]
	end
	local gridSize = 1

	local function snapToGrid(value, grid)
		return math.floor((value + grid / 2) / grid) * grid
	end
	-- Atualiza posição a cada frame
	self.previewConnection = RunService.RenderStepped:Connect(function()
		if player:GetAttribute("TOOL_IN_HAND") == "" then
			return
		end

		local targetPosition = getMousePosition()
		if targetPosition then
			local floor = player:GetAttribute("CURRENT_FLOOR") or 0

			local yAxis = fixedY

			if floor > 0 then
				yAxis = base.mapa["FLOOR_" .. floor].Floor.Carpet.Part.Position.Y + 3
			end

			-- Posição ajustada para andar na grade
			local snappedX = snapToGrid(targetPosition.X, gridSize)
			local snappedZ = snapToGrid(targetPosition.Z, gridSize)
			local newPosition = Vector3.new(snappedX, yAxis, snappedZ)

			if player:GetAttribute("ROTATE_PREVIEW") then
				player:SetAttribute("ROTATE_PREVIEW", false)
				currentRotation += 90
			end

			local rotation = CFrame.Angles(math.rad(90), 0, math.rad(currentRotation))
			clonedModel:PivotTo(CFrame.new(newPosition) * rotation)

			-- Verifica se a hitbox está dentro da área base, incluindo partes com CanCollide = false
			local isInsideBase = PreviewPCController:IsPartInside(clonedModel["Primary"], base.WorkArea.WorkArea)

			if isInsideBase and #PreviewPCController:GetModelTouchingParts(clonedModel["Primary"]) == 0 then
				player:SetAttribute("CAN_SET", true)
				clonedModel["bounding_box"].Color = clonedModel["bounding_box"].CanSet.Value
			else
				clonedModel["bounding_box"].Color = clonedModel["bounding_box"].CanNotSet.Value
				player:SetAttribute("CAN_SET", false)
			end
		end
	end)
end

function PreviewPCController:InitEquipToolListner()
	player.Character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			--	previewPcButtons.Visible = true
			local toolType = child:GetAttribute("TOOL_TYPE")
			local childName = child:GetAttribute("ORIGINAL_NAME")

			PreviewPCController:InitPreview(childName, toolType)
			player:SetAttribute("TOOL_IN_HAND", childName)
			player:SetAttribute("TOOL_TYPE", toolType)
		end
	end)

	player.Character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			--previewPcButtons.Visible = false
			if workspace:FindFirstChild("Preview") then
				workspace.Preview:Destroy()
				player:SetAttribute("TOOL_IN_HAND", "")
				player:SetAttribute("TOOL_TYPE", "")
			end
		end
	end)
end

return PreviewPCController
