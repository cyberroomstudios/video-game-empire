local BaseService = {}

local ServerScriptService = game:GetService("ServerScriptService")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local UtilService = require(ServerScriptService.Modules.UtilService)
local bridge = BridgeNet2.ReferenceBridge("ElevatorService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local positionYFloor = 26

local allocating = false

function BaseService:Init() end

function BaseService:Allocate(player: Player)
	if allocating then
		return false
	end

	allocating = true

	-- Obtem todas as places
	local places = workspace.Map.BaseMaps:GetChildren()

	-- Embaralha a tabela
	for i = #places, 2, -1 do
		local j = math.random(i)
		places[i], places[j] = places[j], places[i]
	end

	-- Procura uma base não ocupada
	for _, place in ipairs(places) do
		if not place:GetAttribute("BUSY") then
			-- Inicializa os atributos da base
			place:SetAttribute("BUSY", true)
			place:SetAttribute("OWNER", player.UserId)

			player:SetAttribute("BASE", place.Name)
			player:SetAttribute("FLOOR", 1)
			BaseService:MoveToBase(player, place.Spawn)
			break
		end
	end

	allocating = false
	BaseService:AddPlayerName(player)
	BaseService:UpdatePlayerCCU(player)

	return true
end

-- Leva o Jogador para o Spawn da Base
function BaseService:MoveToBase(player, baseSpawn)
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = baseSpawn.CFrame
	end
end

function BaseService:GetBase(player: Player)
	local places = workspace.Map.BaseMaps:GetChildren()

	for _, value in places do
		if value.Name == player:GetAttribute("BASE") then
			return value
		end
	end
end

function BaseService:InitFloors(player: Player)
	local floor = PlayerDataHandler:Get(player, "floors")
	for i = 1, floor, 1 do
		BaseService:GiveMoreFloor(player, 1)
	end
end

function BaseService:GiveMoreFloor(player: Player, amount)
	local base = BaseService:GetBase(player)

	for i = 1, amount do
		local newFloor = ReplicatedStorage.Model.FloorModule:Clone()

		newFloor.Name = "FLOOR_" .. player:GetAttribute("FLOOR") or 1
		local newY = 6.15 + player:GetAttribute("FLOOR") * positionYFloor

		newFloor:SetPrimaryPartCFrame(
			CFrame.new(Vector3.new(base.PrimaryPart.Position.X, newY, base.PrimaryPart.Position.Z))
		)

		base:SetAttribute("FLOOR", (base:GetAttribute("FLOOR") or 0) + 1)

		player:SetAttribute("FLOOR", player:GetAttribute("FLOOR") + 1)
		newFloor.Parent = base.mapa
	end
end

function BaseService:AddPlayerName(player: Player)
	local base = BaseService:GetBase(player)
	local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.OwnerBillboard.NameBillboard
	billboard.SurfaceGui.PlayerName.Text = player.Name .. "'s Game Studio"
end

function BaseService:UpdatePlayerCCU(player: Player)
	local totalCCU = PlayerDataHandler:Get(player, "totalCCU")
	local base = BaseService:GetBase(player)
	local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.CCUBilboard.Billboard
	billboard.SurfaceGui.PlayerName.Text = UtilService:FormatNumberToSuffixes(totalCCU) .. " CCU"
	player:SetAttribute("CCU", totalCCU)
end

return BaseService
