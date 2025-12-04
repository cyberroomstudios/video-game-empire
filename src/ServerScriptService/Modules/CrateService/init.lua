local CrateService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("CrateService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")

local ToolService = require(ServerScriptService.Modules.ToolService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local DevService = require(ServerScriptService.Modules.DevService)

local cratesRewards = {}

function CrateService:Init()
	CrateService:InitBridgeListener()
end

function CrateService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GiveCrateReward" then
			local crateId = data.data.CrateId
			CrateService:GiveCrateReward(player, crateId)
		end
	end
end

function CrateService:ConfigureProximityPrompt(player: Player, base: Model)
	local primaryPart = base.PrimaryPart

	if not primaryPart then
		warn("Primary Part Not found")
		return
	end

	local buyCrateProximityPrompt = primaryPart:FindFirstChild("BuyCrateProximityPrompt")

	if not buyCrateProximityPrompt then
		warn("BuyCrateProximityPrmpt not found")
		return
	end

	buyCrateProximityPrompt.Triggered:Connect(function(playerTriggered)
		if player ~= playerTriggered then
			return
		end

		local name = base.Name
		CrateService:Give(playerTriggered, name)
		base:Destroy()
	end)
end

function CrateService:Give(player: Player, crateName: string)
	local currentId = PlayerDataHandler:Get(player, "crateInBackpackId") or 1
	PlayerDataHandler:Update(player, "cratesInBackpack", function(current)
		local data = {
			Id = currentId + 1,
			Name = crateName,
		}
		table.insert(current, data)
		return current
	end)

	PlayerDataHandler:Set(player, "crateInBackpackId", currentId + 1)
	ToolService:GiveCrateTool(player, crateName, currentId + 1)
end

function CrateService:Remove(player: Player, crateId: number)
	PlayerDataHandler:Update(player, "cratesInBackpack", function(current)
		local newCurrent = {}
		for _, value in current do
			if value.Id ~= crateId then
				table.insert(newCurrent, value)
			end
		end
		return newCurrent
	end)

	ToolService:ConsumeCrateTool(player, crateId)
end

function CrateService:Open(player: Player, crate: Model, slot: string)
	local crateRarity = crate:GetAttribute("RARITY")
	local crateId = crate:GetAttribute("ID")

	local selectedDev = DevService:DrawDevFromRarity(player, crateRarity)

	local devs = DevService:GetRandomDev(player, 3)

	if not cratesRewards[player] then
		cratesRewards[player] = {}
	end

	cratesRewards[player][crateId] = selectedDev

	bridge:Fire(player, {
		[actionIdentifier] = "Open",
		data = {
			CrateId = crateId,
			Devs = devs,
			SelectedDev = selectedDev,
			Slot = slot,
		},
	})
end

-- Da o dev quando abre a caixa
function CrateService:GiveCrateReward(player: Player, crateId: number)
	if not cratesRewards[player] then
		return
	end

	if not cratesRewards[player][crateId] then
		return
	end

	local devReward = cratesRewards[player][crateId]
	DevService:GiveDevFromCrate(player, devReward)
end
return CrateService
