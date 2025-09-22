local OfflineScreenController = {}

local Players = game:GetService("Players")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("OfflineGrowthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)
local GamepassController = require(Players.LocalPlayer.PlayerScripts.ClientModules.GamepassController)

local screen
local getButton
local getVipButton
local offlineItems

function OfflineScreenController:Init()
	OfflineScreenController:CreateReferences()
	OfflineScreenController:InitButtonListerns()
	OfflineScreenController:InitListeners()
end

function OfflineScreenController:CreateReferences()
	screen = UIReferences:GetReference("OFFLINE_SCREEN")
	getButton = UIReferences:GetReference("GET_OFFLINE")
	getVipButton = UIReferences:GetReference("GET_VIP_OFFLINE")
	offlineItems = UIReferences:GetReference("OFFLINE_ITEMS")
end

function OfflineScreenController:Open()
	screen.Visible = true
end

function OfflineScreenController:Close()
	screen.Visible = false
end

function OfflineScreenController:InitButtonListerns()
	getButton.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")

		OfflineScreenController:Close()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetOfflineGames",
		})
	end)

	getVipButton.MouseButton1Click:Connect(function()
		SoundManager:Play("UI_CLICK")
		OfflineScreenController:Close()

		if Players.LocalPlayer:GetAttribute("2X_OFFLINE_COLLECT") then
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GetOfflineGames",
			})
		else
			GamepassController:OpenPaymentRequestScreen("x2_COLLECT")
		end
	end)
end

function OfflineScreenController:InitListeners()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowOffilineGames" then
			OfflineScreenController:BuilScreen(response.data.OfflineGmes)
			OfflineScreenController:Open()
		end
	end)
end

function OfflineScreenController:BuilScreen(offLineGames)
	if Players.LocalPlayer:GetAttribute("2X_OFFLINE_COLLECT") then
		getButton.Parent.Visible = false
	end

	for _, value in offLineGames do
		local gameName = value.Name
		local playerAmount = value.PlayerAmount

		if not offlineItems:FindFirstChild(gameName) then
			local viewPort = ReplicatedStorage.GUI.ViewPorts.Games:FindFirstChild(gameName)

			if viewPort then
				local newItem = viewPort:Clone()
				newItem.Parent = offlineItems

				local newPlayerInfo = offlineItems.PlayerInfo:Clone()
				newPlayerInfo.Parent = newItem
				newPlayerInfo.Visible = true
				newPlayerInfo.Text = ClientUtil:FormatNumberToSuffixes(playerAmount)
				newItem:SetAttribute("PLAYER_AMOUNT", playerAmount)
			end

			continue
		end

		local item = offlineItems:FindFirstChild(gameName)

		if item then
			local oldPlayerAmount = item:GetAttribute("PLAYER_AMOUNT") or 0
			local newPlayerAmount = oldPlayerAmount + playerAmount
			item:SetAttribute("PLAYER_AMOUNT", newPlayerAmount)
			item.PlayerInfo.Text = ClientUtil:FormatNumberToSuffixes(newPlayerAmount)
		end
	end
end

return OfflineScreenController
