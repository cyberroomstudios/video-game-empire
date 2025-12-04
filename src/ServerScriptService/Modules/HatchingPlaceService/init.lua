local HatchingPlaceService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local BaseService = require(ServerScriptService.Modules.BaseService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local bridge = BridgeNet2.ReferenceBridge("HatchingPlaceService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crates = require(ReplicatedStorage.Enums.Crates)
local UtilService = require(ServerScriptService.Modules.UtilService)

function HatchingPlaceService:Init()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "PlaceAll" then
			HatchingPlaceService:PlaceAll(player)
		end
	end
end

function HatchingPlaceService:GetSortedAttachments(attachments)
	local ordered = {}

	for _, attachment in ipairs(attachments) do
		local indexNumber = tonumber(attachment.Parent.Name)
		table.insert(ordered, {
			Index = indexNumber,
			Attachment = attachment,
		})
	end

	table.sort(ordered, function(a, b)
		return a.Index < b.Index
	end)

	return ordered
end

function HatchingPlaceService:GetNextSlot(player: Player)
	local attachments = BaseService:GetAttachmentSlotsBeld(player)
	local sortedAttachments = HatchingPlaceService:GetSortedAttachments(attachments)

	for _, value in sortedAttachments do
		if value.Attachment:GetAttribute("UNLOCKED") then
			if not value.Attachment:GetAttribute("BUSY") then
				return value.Attachment
			end
		end
	end
end

function HatchingPlaceService:ReleseAttachmentSlot(player: Player, slot: string)
	local attachments = BaseService:GetAttachmentSlotsBeld(player)

	for _, value in attachments do
		if tonumber(value.Parent.Name) == tonumber(slot) then
			value:SetAttribute("BUSY", false)
		end
	end
end

function HatchingPlaceService:PlaceAll(player: Player)
	local cratesInBackpack = PlayerDataHandler:Get(player, "cratesInBackpack")
	for _, value in cratesInBackpack do
		local attachmentSlot = HatchingPlaceService:GetNextSlot(player)

		if attachmentSlot then
			local crateModel = ReplicatedStorage.Model.Crates:FindFirstChild(value.Name)
			if crateModel then
				local newCrate = crateModel:Clone()
				newCrate:SetPrimaryPartCFrame(attachmentSlot.WorldCFrame)

				local buyCrateProximityPrompt = newCrate.PrimaryPart:FindFirstChild("BuyCrateProximityPrompt")

				if buyCrateProximityPrompt then
					buyCrateProximityPrompt:Destroy()
				end

				local beltBillboardGui = newCrate.PrimaryPart:FindFirstChild("BeltBillboardGui")

				if beltBillboardGui then
					local enum = Crates[newCrate.Name]
					if enum then
						beltBillboardGui.Frame.PriceOrTime.TextColor3 = Color3.new(170, 0, 0)
						beltBillboardGui.Frame.PriceOrTime.Text = UtilService:FormatTime(enum.TimeToOpen)
						beltBillboardGui.Frame.CrateName.Text = enum.GUI.Label
						beltBillboardGui.Frame.Rarity.Text = enum.Rarity
						beltBillboardGui.Frame.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors[enum.Rarity].Value
						newCrate:SetAttribute("TIME_TO_OPEN", enum.TimeToOpen)
						newCrate:SetAttribute("RARITY", enum.Rarity)
					end
				end

				newCrate:SetAttribute("READY", false)
				newCrate:SetAttribute("SLOT", attachmentSlot.Parent.Name)
				newCrate:SetAttribute("ID", value.Id)

				attachmentSlot:SetAttribute("BUSY", true)

				CrateService:Remove(player, value.Id)
				newCrate.Parent = workspace.Runtime[player.UserId].Hatching
			end
		end
	end
end

return HatchingPlaceService
