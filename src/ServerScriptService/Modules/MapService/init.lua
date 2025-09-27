local MapService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local DevService = require(ServerScriptService.Modules.DevService)
local ToolService = require(ServerScriptService.Modules.ToolService)
local bridge = BridgeNet2.ReferenceBridge("MapService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function MapService:Init()
	MapService:InitBridgeListener()
end

function MapService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "SetDev" then
			local cFrame = data.data.CFrame
			local dev = data.data.Dev
			local floor = data.data.Floor

			if floor and (floor > player:GetAttribute("FLOOR")) then
				return false
			end

			MapService:SetDevToMap(player, cFrame, dev, floor)
			return true
		end
	end
end

function MapService:SetDevToMap(player: Player, CFrame: CFrame, devName: string, floor: number)
	local devFolder = ReplicatedStorage.Model.Devs

	if CFrame and devName and devFolder:FindFirstChild(devName) then
		-- Verifica se o jogador possui um dev disponivel
		local hasDev = DevService:HasDevInPlayerData(player, devName)

		if not hasDev then
			--return
		end

		local devClone = devFolder:FindFirstChild(devName):Clone()

		devClone["bounding_box"].Transparency = 1
		devClone:SetPrimaryPartCFrame(CFrame)
		devClone.Parent = workspace

		local base = workspace.Map.BaseMaps[player:GetAttribute("BASE")]

		-- Verifica se a hitbox está dentro da área base,
		-- Incluindo partes com CanCollide = false
		local isInsideBase = MapService:IsPartInside(devClone["Primary"], base.WorkArea.WorkArea)

		if not isInsideBase then
			devClone:Destroy()
			return
		end

		if #MapService:GetModelTouchingParts(devClone["Primary"]) > 0 then
			devClone:Destroy()
			return
		end

		devClone:Destroy()

		-- Consume um dev da base do jogador
		DevService:ConsumeDev(player, devName)

		-- Consume a tool
		ToolService:ConsumeDevTool(player, devName)

		-- Salva na base de dados do jogador
		local devId = DevService:SaveDevInDataHandler(player, devName, CFrame, floor)

		-- Seta no mapa
		DevService:SetDevInMap(player, devId, devName, CFrame, floor)
	end
end

function MapService:GetModelTouchingParts(part: BasePart)
	-- Configuração do filtro
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { part } -- evita retornar a própria parte

	-- Retorna as partes encostando ou dentro da "part"
	return workspace:GetPartsInPart(part, overlapParams)
end

-- Verifica se uma parte está contida em outra apenas no eixo X e Z
function MapService:IsPartInside(partA, partB)
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

return MapService
