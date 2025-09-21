local MoneyController = {}

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local player = Players.LocalPlayer

local moneyLabel
local oldMoney = nil
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

		if oldMoney and oldMoney < money then
			SoundManager:Play("MONEY_COMING_IN")
		end

		oldMoney = money
		moneyLabel.Text = ClientUtil:FormatToUSD(money)
	end)
end

return MoneyController
