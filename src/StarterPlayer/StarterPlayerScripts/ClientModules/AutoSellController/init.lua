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
local player = Players.LocalPlayer

local AutoCollectScreenController = require(Players.LocalPlayer.PlayerScripts.ClientModules.AutoCollectScreenController)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local GamepassController = require(Players.LocalPlayer.PlayerScripts.ClientModules.GamepassController)

local autoSellButton

function AutoSellController:Init()
	AutoSellController:CreateReferences()
	AutoCollectScreenController:InitAttributeListener()
end

function AutoSellController:CreateReferences()
	-- Botões referentes aos Teleports
	autoSellButton = UIReferences:GetReference("AUTO_SELL_BUTTON")
end

function AutoSellController:ActiveOrInactive()
	if not Players.LocalPlayer:GetAttribute("HAS_AUTO_SELL") then
		GamepassController:OpenPaymentRequestScreen("AUTO_SELL")
		return
	end

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

function AutoCollectScreenController:InitAttributeListener()
	player:GetAttributeChangedSignal("ACTIVE_AUTO_SELL"):Connect(function()
		local activedAutoSell = player:GetAttribute("ACTIVE_AUTO_SELL")

		if activedAutoSell then
			autoSellButton.Info.BackgroundColor3 = autoSellButton.Info.ActiveColor.Value
		else
			autoSellButton.Info.BackgroundColor3 = autoSellButton.Info.InactiveColor.Value
		end
	end)
end
return AutoSellController
