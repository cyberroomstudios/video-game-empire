local MoneyController = {}

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local player = Players.LocalPlayer

local moneyLabel

function MoneyController:Init()
	MoneyController:CreateReferences()
	MoneyController:InitAttributeListener()
end

function MoneyController:CreateReferences()
	-- Botões referente as Tools
	moneyLabel = UIReferences:GetReference("MONEY")
end

function MoneyController:InitAttributeListener()
	player:GetAttributeChangedSignal("MONEY"):Connect(function()
		local money = player:GetAttribute("MONEY")
		moneyLabel.Text = ClientUtil:FormatToUSD(money)
	end)
end

return MoneyController
