local IndexController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("IndexService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local Games = require(ReplicatedStorage.Enums.Games)

local indexScreen
local scrollingIndex

function IndexController:Init()
	IndexController:CreateReferences()
end

function IndexController:Open()
	scrollingIndex.Visible = false
	indexScreen.Visible = true
	IndexController:BuildScreen()
	scrollingIndex.Visible = true
end

function IndexController:Close()
	indexScreen.Visible = false
end

function IndexController:GetScreen()
	return indexScreen
end

function IndexController:CreateReferences()
	-- Botões referentes aos Teleports
	indexScreen = UIReferences:GetReference("INDEX_SCREEN")
	scrollingIndex = UIReferences:GetReference("SCROLLING_INDEX")
end

function IndexController:BuildScreen()
	local function hasItem(list, item)
		for _, value in list do
			if value == item then
				return true
			end
		end

		return false
	end
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetIndex",
	})

	for _, value in scrollingIndex:GetChildren() do
		if value:GetAttribute("IS_GAME") then
			value:Destroy()
		end
	end

	for _, gameInfo in Games do
		local newItem = scrollingIndex:FindFirstChild("Item"):Clone()
		newItem.Visible = true
		newItem.LayoutOrder = gameInfo.GUI.Order or 1

		if hasItem(result, gameInfo.Name) then
			local viewPort = ReplicatedStorage.GUI.ViewPorts.Games[gameInfo.Name]:Clone()
			viewPort.Size = UDim2.fromScale(1, 1)
			viewPort.Position = UDim2.fromScale(0.5, 0.5)
			viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
			viewPort.Parent = newItem.Content

			newItem.Content.Icon:Destroy()

			newItem.Info.Genre.Text = gameInfo.GUI.Name
		end

		newItem:SetAttribute("IS_GAME", true)
		newItem.Parent = scrollingIndex
	end
end

return IndexController
