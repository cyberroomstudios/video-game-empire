local MobileScreenController = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local PreviewPCController = require(Players.LocalPlayer.PlayerScripts.ClientModules.PreviewPCController)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local currentRotation = 0
local base

local previewButton

function MobileScreenController:Init()
	if UserInputService.TouchEnabled then
		MobileScreenController:CreateReferences()
		MobileScreenController:InitEquipToolListner()
	end
end

function MobileScreenController:CreateReferences()
	previewButton = UIReferences:GetReference("PREVIEW_MOBILE_BUTTON")
end

function MobileScreenController:IsPartInside(partA, partB)
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

function MobileScreenController:GetCollidingModels(hitbox: BasePart)
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

function MobileScreenController:GetModelTouchingParts(part: BasePart)
	-- Configuração do filtro
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { part } -- evita retornar a própria parte

	-- Retorna as partes encostando ou dentro da "part"
	return workspace:GetPartsInPart(part, overlapParams)
end

function MobileScreenController:InitPreview(itemName: string, toolType: string)
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

	local function snapToGrid(value, grid)
		return math.floor((value + grid / 2) / grid) * grid
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

	local smoothFactor = 0.4 -- Quanto menor, mais suave e lento será o movimento
	local currentPosition = clonedModel:GetPivot().Position

	local camera = workspace.CurrentCamera
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { clonedModel }
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	-- Distância à frente do jogador
	local forwardDistance = 8 -- ajuste para aumentar/diminuir a distância

	-- Atualiza posição a cada frame
	self.previewConnection = RunService.RenderStepped:Connect(function()
		if player:GetAttribute("TOOL_IN_HAND") == "" then
			return
		end

		local cameraCF = camera.CFrame
		local playerPos = player.Character
			and player.Character:FindFirstChild("HumanoidRootPart")
			and player.Character.HumanoidRootPart.Position
		if not playerPos then
			return
		end

		-- Direção da câmera apenas no plano XZ
		local lookDir = cameraCF.LookVector
		lookDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit -- zera Y e normaliza

		-- Origem 15 studs à frente no plano XZ
		local rayOrigin = playerPos + lookDir * forwardDistance
		local rayDirection = Vector3.new(lookDir.X, -1, lookDir.Z) * 1000 -- projeta o raio para baixo
		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		if raycastResult then
			local targetPosition = raycastResult.Position

			local floor = player:GetAttribute("CURRENT_FLOOR") or 0
			local yAxis = fixedY

			if floor > 0 then
				yAxis = base.mapa["FLOOR_" .. floor].Floor.Carpet.Part.Position.Y + 3
			end

			local snappedX = snapToGrid(targetPosition.X, gridSize)
			local snappedZ = snapToGrid(targetPosition.Z, gridSize)
			local newPosition = Vector3.new(snappedX, yAxis, snappedZ)

			-- Suaviza transição
			currentPosition = currentPosition:Lerp(newPosition, smoothFactor)

			-- Rotação
			if player:GetAttribute("ROTATE_LEFT_PREVIEW") then
				player:SetAttribute("ROTATE_LEFT_PREVIEW", false)
				currentRotation -= 90
			end

			if player:GetAttribute("ROTATE_RIGHT_PREVIEW") then
				player:SetAttribute("ROTATE_RIGHT_PREVIEW", false)
				currentRotation += 90
			end

			local rotation = CFrame.Angles(math.rad(90), 0, math.rad(currentRotation))
			clonedModel:PivotTo(CFrame.new(currentPosition) * rotation)

			-- Verifica colisão
			local isInsideBase = MobileScreenController:IsPartInside(clonedModel["Primary"], base.WorkArea.WorkArea)
			if isInsideBase and #MobileScreenController:GetModelTouchingParts(clonedModel["Primary"]) == 0 then
				player:SetAttribute("CAN_SET", true)
				clonedModel["bounding_box"].Color = clonedModel["bounding_box"].CanSet.Value
			else
				clonedModel["bounding_box"].Color = clonedModel["bounding_box"].CanNotSet.Value
				player:SetAttribute("CAN_SET", false)
			end
		end
	end)
end

function MobileScreenController:InitEquipToolListner()
	player.Character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			--	previewPcButtons.Visible = true
			local toolType = child:GetAttribute("TOOL_TYPE")
			local childName = child:GetAttribute("ORIGINAL_NAME")
			if toolType == "DEV" then
				MobileScreenController:InitPreview(childName, toolType)
				player:SetAttribute("TOOL_IN_HAND", childName)
				player:SetAttribute("TOOL_TYPE", toolType)
				previewButton.Visible = true
			end
		end
	end)

	player.Character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			--previewPcButtons.Visible = false
			if workspace:FindFirstChild("Preview") then
				workspace.Preview:Destroy()
				player:SetAttribute("TOOL_IN_HAND", "")
				player:SetAttribute("TOOL_TYPE", "")
				previewButton.Visible = false
			end
		end
	end)
end

return MobileScreenController
