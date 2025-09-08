local BackpackController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("BackpackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local StarterGui = game:GetService("StarterGui")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local backpackButtons
local backpackExpand
local backpackGrid

local workersFrame
local gamesFrame
local backpack

local MAX_SLOTS = 7

function BackpackController:Init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	BackpackController:CreateReferences()

	BackpackController:InitBridgeListener()
	backpack = player:WaitForChild("Backpack")
end

function BackpackController:CreateReferences()
	backpackButtons = UIReferences:GetReference("BACKPACK_BUTTONS")
	backpackExpand = UIReferences:GetReference("BACKPACK_EXPAND")
	backpackGrid = UIReferences:GetReference("BACKPACK_GRID")

	workersFrame = UIReferences:GetReference("BACKPACK_WORKES")

	gamesFrame = UIReferences:GetReference("BACKPACK_GAMES")
end

function BackpackController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "UpdateBackpack" then
			BackpackController:UpdateBackpack()
		end
	end)
end

function BackpackController:UpdateBackpack()
	local parentsFrame = {
		["WORKER"] = workersFrame,
		["GAME"] = gamesFrame,
	}

	for _, tool in backpack:GetChildren() do
		print(tool)
	end
end

function BackpackController:Open()
	backpackExpand.Visible = true

	-- Remove itens antigos
	for _, value in backpackGrid:GetChildren() do
		if value:GetAttribute("DELETE") then
			value:Destroy()
		end
	end

	-- Cria novos itens
	local totalItems = 50
	for i = 1, totalItems do
		local newItem = backpackGrid.Item:Clone()
		newItem.Visible = true
		newItem:SetAttribute("DELETE", true)
		newItem.Parent = backpackGrid
	end

	local grid = backpackGrid:FindFirstChildOfClass("UIGridLayout")
	local spacing = 0.02 -- Espaçamento em escala (horizontal)

	local function updateGrid()
		local containerWidth = backpackGrid.AbsoluteSize.X
		local containerHeight = backpackGrid.AbsoluteSize.Y

		-- Calcula número de colunas para não estourar a altura
		local columns = 6 -- mínimo de 100px por célula
		if columns < 1 then
			columns = 1
		end

		-- Espaçamento em pixels
		local spacingPixels = spacing * containerWidth

		-- Tamanho da célula para caber no número de colunas
		local totalSpacing = spacingPixels * (columns - 1)
		local cellWidth = (containerWidth - totalSpacing) / columns

		-- Atualiza CellSize e CellPadding
		grid.CellSize = UDim2.new(0, cellWidth, 0, cellWidth)
		grid.CellPadding = UDim2.new(0, spacingPixels, 0, spacingPixels)
	end

	backpackGrid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGrid)
	updateGrid()
end

function BackpackController:Close()
	backpackExpand.Visible = false
end

function BackpackController:GetScreen()
	return backpackExpand
end

return BackpackController
