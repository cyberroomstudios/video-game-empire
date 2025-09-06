local AutoSellController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("AutoSellService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local AutoCollectScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoCollectScreenController)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local autoSellButton

function AutoSellController:Init()
	AutoSellController:CreateReferences()
end

function AutoSellController:CreateReferences()
	-- Botões referentes aos Teleports
	autoSellButton = UIReferences:GetReference("AUTO_SELL_BUTTON")
end

function AutoSellController:ActiveOrInactive()
	if autoSellButton.Info.BackgroundColor3 == autoSellButton.Info.ActiveColor.Value then
		autoSellButton.Info.BackgroundColor3 = autoSellButton.Info.InactiveColor.Value
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "InactiveAutoCollect",
		})
	else
		autoSellButton.Info.BackgroundColor3 = autoSellButton.Info.ActiveColor.Value
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "ActiveAutoSell",
		})
	end
end
return AutoSellController
