local HatchingPlaceController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("HatchingPlaceService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local player = Players.LocalPlayer
local placeAllButton

function HatchingPlaceController:Init()
	HatchingPlaceController:CreateReferences()
	HatchingPlaceController:InitButtonListerns()
end

function HatchingPlaceController:CreateReferences()
	-- Botões referentes aos Teleports
	placeAllButton = UIReferences:GetReference("PLACE_ALL_BUTTON")
end

function HatchingPlaceController:InitButtonListerns()
	placeAllButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "PlaceAll",
			data = {},
		})
	end)
end

function HatchingPlaceController:ConfigureProximities()
	local baseNumber = player:GetAttribute("BASE")

	if baseNumber then
		local base = ClientUtil:WaitForDescendants(workspace, "Map", "BaseMaps", baseNumber)
		local proximitiesFolder =
			ClientUtil:WaitForDescendants(base, "mapa", "ModuleBuilding", "Hatching", "HatchingPlace", "Proximities")
		for _, value in proximitiesFolder:GetChildren() do
			local proximty = value:WaitForChild("ProximityPrompt")

			proximty.PromptShown:Connect(function()
				placeAllButton.Visible = true
			end)

			proximty.PromptHidden:Connect(function()
				placeAllButton.Visible = false
			end)
		end
	end
end

return HatchingPlaceController
