local RebirthController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local Devs = require(ReplicatedStorage.Enums.Devs)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local getRebirthButton
local mainRebirth

-- Informações da Tela
local rebirthReward
local moneyTarget
local ccuTarget

function RebirthController:Init()
	RebirthController:CreateReferences()
	RebirthController:InitButtonListerns()
end

function RebirthController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("REBIRTH_SCREEN")
	getRebirthButton = UIReferences:GetReference("GET_REBIRTH_BUTTON")
	mainRebirth = UIReferences:GetReference("MAIN_REBIRTH")

	rebirthReward = UIReferences:GetReference("REBIRTH_REWARDS")
	moneyTarget = UIReferences:GetReference("MONEY_TARGET")
	ccuTarget = UIReferences:GetReference("CCU_TARGET")
end

function RebirthController:Open()
	mainRebirth.Visible = false
	screen.Visible = true
	RebirthController:BuildScreen()
	--	mainRebirth.Visible = true
end

function RebirthController:Close()
	screen.Visible = false
end

function RebirthController:GetScreen()
	return screen
end

function RebirthController:BuildScreen()
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetInfoRebirth",
	})

	local targetMoneyValue = 0
	local targetCCUValue = 0

	local awards = result.Awards

	-- Limpa Os Itens
	for _, value in rebirthReward:GetChildren() do
		if value.Name == "NewItem" then
			value:Destroy()
		end
	end

	for _, award in awards do
		local newItem = rebirthReward.Item:Clone()
		newItem.Name = "NewItem"
		newItem.Visible = true
		newItem.ItemName.TextLabel.Text = award.GUI.Label
		newItem.Parent = rebirthReward
	end

	local requirements = result.Requirements

	for _, requirement in requirements do
		if requirement.Type == "MONEY" then
			targetMoneyValue = requirement.Amount
		end

		if requirement.Type == "CCU" then
			targetCCUValue = requirement.Amount
		end
	end

	local currentMoneyValeu = Players.LocalPlayer:GetAttribute("MONEY")
	local currentCCUValue = Players.LocalPlayer:GetAttribute("CCU")

	moneyTarget.Quantity.Text = string.format(
		"MONEY: %s / %s",
		ClientUtil:FormatToUSD(currentMoneyValeu),
		ClientUtil:FormatToUSD(targetMoneyValue)
	)

	ccuTarget.Quantity.Text = string.format(
		"CCU: %s / %s",
		ClientUtil:FormatNumberToSuffixes(currentCCUValue),
		ClientUtil:FormatNumberToSuffixes(targetCCUValue)
	)

	local moneyProgress = math.clamp(currentMoneyValeu / targetMoneyValue, 0, 1)
	local ccuProgress = math.clamp(currentCCUValue / targetCCUValue, 0, 1)

	moneyTarget.Progress.Size = UDim2.new(moneyProgress, 0, 1, 0)
	ccuTarget.Progress.Size = UDim2.new(ccuProgress, 0, 1, 0)
end

function RebirthController:InitButtonListerns()
	local canClick = true
	getRebirthButton.MouseButton1Click:Connect(function()
				SoundManager:Play("UI_CLICK")

		if canClick then
			canClick = false
			screen.Visible = false
			if workspace.CurrentCamera:FindFirstChild("Blur") then
				workspace.CurrentCamera.Blur.Size = 0
			end

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GetRebirth",
			})

			canClick = true
		end
	end)
end
return RebirthController
