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
local UserInputService = game:GetService("UserInputService")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local backpackButtons
local backpackExpand
local backpackGrid

local workersFrame
local gamesFrame
local backpack

local showWorkesBackpackButton
local showGamesBackpackButton

local MAX_SLOTS = 7
local currentExpandedTool = 7
local tools = {}
local currenTool
function BackpackController:Init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	BackpackController:CreateReferences()
	BackpackController:InitButtonListerns()
	BackpackController:InitBridgeListener()
	backpack = player:WaitForChild("Backpack")
end

function BackpackController:CreateReferences()
	backpackButtons = UIReferences:GetReference("BACKPACK_BUTTONS")
	backpackExpand = UIReferences:GetReference("BACKPACK_EXPAND")
	backpackGrid = UIReferences:GetReference("BACKPACK_GRID")
	workersFrame = UIReferences:GetReference("BACKPACK_WORKES")
	gamesFrame = UIReferences:GetReference("BACKPACK_GAMES")
	showWorkesBackpackButton = UIReferences:GetReference("SHOW_WORKERS_BACKPACK")
	showGamesBackpackButton = UIReferences:GetReference("SHOW_GAME_BACKPACK")
end

function BackpackController:InitButtonListerns()
	local keyToIndex = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
	}

	for i = 1, MAX_SLOTS - 1 do
		local slot = backpackButtons[i]
		slot.MouseButton1Click:Connect(function()
			local tool = tools[i]
			if tool then
				if currenTool == tool then
					currenTool = nil
					player.Character.Humanoid:UnequipTools()

					return
				end

				currenTool = tool
				player.Character.Humanoid:EquipTool(tool)
			end
		end)
	end

	showWorkesBackpackButton.MouseButton1Click:Connect(function()
		workersFrame.Visible = true
		gamesFrame.Visible = false
	end)

	showGamesBackpackButton.MouseButton1Click:Connect(function()
		workersFrame.Visible = false
		gamesFrame.Visible = true
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local index = keyToIndex[input.KeyCode]
		if index and not gameProcessed then
			local tool = tools[index]
			if tool then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					if currenTool == tool then
						currenTool = nil
						humanoid:UnequipTools()
						return
					end

					currenTool = tool
					humanoid:EquipTool(tool)
				end
			end
		end
	end)
end
function BackpackController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "UpdateBackpack" then
			BackpackController:UpdateBackpack()
		end
	end)
end

function BackpackController:UpdateGrid(gridLayout, maxItemsPerRow, padding, minCellSize)
	maxItemsPerRow = maxItemsPerRow or 6
	padding = padding or 5
	minCellSize = minCellSize or 50

	local scrollingFrame = gridLayout.Parent
	if not scrollingFrame then
		return
	end

	-- Pega apenas os itens que serão exibidos
	local children = {}
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") or child:IsA("ImageLabel") then
			table.insert(children, child)
		end
	end

	local totalItems = #children
	if totalItems == 0 then
		return
	end

	-- Calcula o número de colunas (máx 6)
	local columns = math.min(totalItems, maxItemsPerRow)
	local frameWidth = scrollingFrame.AbsoluteSize.X

	-- Calcula tamanho da célula
	local totalPadding = (columns - 1) * padding
	local cellWidth = (frameWidth - totalPadding) / columns
	cellWidth = math.max(cellWidth, minCellSize)

	-- Atualiza GridLayout
	gridLayout.CellSize = UDim2.new(0, cellWidth, 0, cellWidth)
	gridLayout.CellPadding = UDim2.new(0, padding, 0, padding)
end

function BackpackController:UpdateBackpack()
	local toolsNames = {}

	for index, tool in backpack:GetChildren() do
		local toolName = tool:GetAttribute("ORIGINAL_NAME")
		local toolType = tool:GetAttribute("TOOL_TYPE")

		toolsNames[toolName] = true

		-- Tenta Atualizar
		local slot = BackpackController:GetSlotFromNameTool(toolName, toolType)

		if slot then
			slot:SetAttribute("ORIGINAL_NAME", toolName)
			if toolType == "DEV" then
				slot.Amount.Visible = true
				slot.Amount.Text = "X" .. tool:GetAttribute("AMOUNT")
			end

			if toolType == "GAME" then
				slot.Content.TextLabel.Visible = true
				slot.Content.TextLabel.Text = tool:GetAttribute("PLAYER_AMOUNT")
			end
			tools[tonumber(slot.Name)] = tool
			continue
		end

		-- Se não encontrou nenhum, cria um novo
		local nextSlot = BackpackController:GetNextSlotTool(toolType)

		if nextSlot then
			nextSlot:SetAttribute("ORIGINAL_NAME", toolName)

			nextSlot:SetAttribute("BUSY", true)
			if toolType == "DEV" then
				local devsFolder = ReplicatedStorage.GUI.ViewPorts.Devs
				local viewPort = devsFolder:FindFirstChild(toolName)
				local newViewPort = viewPort:Clone()

				newViewPort.Parent = nextSlot.Content
				newViewPort.Name = "ViewPort"
				newViewPort:SetAttribute("VIEW_PORT", true)

				nextSlot.Amount.Visible = true
				nextSlot.Amount.Text = "X" .. tool:GetAttribute("AMOUNT")
				nextSlot:SetAttribute("BUSY", true)
			end

			if toolType == "GAME" then
				local gamesFolder = ReplicatedStorage.GUI.ViewPorts.Games
				local viewPort = gamesFolder:FindFirstChild(tool:GetAttribute("ORIGINAL_NAME") or "")

				local newViewPort = viewPort:Clone()
				newViewPort:SetAttribute("VIEW_PORT", true)
				newViewPort.Size = UDim2.fromScale(0.7, 0.7)
				newViewPort.Parent = nextSlot.Content
				newViewPort.Name = "ViewPort"

				nextSlot.Content.TextLabel.Visible = true
				nextSlot.Content.TextLabel.Text = ClientUtil:FormatNumberToSuffixes(tool:GetAttribute("PLAYER_AMOUNT"))

				nextSlot:SetAttribute("BUSY", true)
			end
			tools[tonumber(nextSlot.Name)] = tool

			continue
		end
	end

	BackpackController:DeleteSlots(toolsNames)
end

function BackpackController:GetSlotFromNameTool(toolName: string, toolType: string)
	for i = 1, MAX_SLOTS - 1 do
		local slot = backpackButtons[i]
		if slot:GetAttribute("ORIGINAL_NAME") == toolName then
			return slot
		end
	end

	if toolType == "DEV" then
		local scrollingFrame = workersFrame.ScrollingFrame
		for _, slot in scrollingFrame:GetChildren() do
			if slot:GetAttribute("ORIGINAL_NAME") == toolName then
				return slot
			end
		end
	end

	if toolType == "GAME" then
		local scrollingFrame = gamesFrame.ScrollingFrame
		for _, slot in scrollingFrame:GetChildren() do
			if slot:GetAttribute("ORIGINAL_NAME") == toolName then
				return slot
			end
		end
	end
end

function BackpackController:GetNextSlotTool(toolType: string)
	local function updateGrid(gridLayout: UIGridLayout, scrollingFrame: ScrollingFrame, maxColumns: number)
		-- Largura total disponível no ScrollingFrame
		local frameWidth = scrollingFrame.AbsoluteSize.X

		-- Calcula o tamanho de cada célula para caber no máximo "maxColumns" por linha
		local cellSize = math.floor(frameWidth / maxColumns)

		-- Ajusta o GridLayout para células quadradas
		gridLayout.CellSize = UDim2.new(0, cellSize, 0, cellSize)

		-- Define um espaçamento proporcional (opcional)
		local padding = math.floor(cellSize * 0.05) -- 5% do tamanho como espaçamento
		gridLayout.CellPadding = UDim2.new(0, padding, 0, padding)
	end

	local scrolling = {
		["DEV"] = workersFrame.ScrollingFrame,
		["GAME"] = gamesFrame.ScrollingFrame,
	}
	for i = 1, MAX_SLOTS - 1 do
		if not backpackButtons[i]:GetAttribute("BUSY") then
			return backpackButtons[i]
		end
	end

	currentExpandedTool = currentExpandedTool + 1

	local item = ReplicatedStorage.GUI.Backpack.ExpandedItem:Clone()
	item.Name = currentExpandedTool
	item.Parent = scrolling[toolType]

	item.MouseButton1Click:Connect(function()
		local tool = tools[currentExpandedTool]
		if tool then
			player.Character.Humanoid:EquipTool(tool)
		end
	end)

	updateGrid(scrolling[toolType].UIGridLayout, scrolling[toolType], 6)

	return item
end

function BackpackController:DeleteSlots(toolNameList)
	for i = 1, MAX_SLOTS - 1 do
		local slot = backpackButtons[i]

		local slotName = slot:GetAttribute("ORIGINAL_NAME")
		-- VERIFICAR SE O NOME NÃO ESTÁ NA LISTA
		if not toolNameList[slotName] then
			slot:SetAttribute("BUSY", false)
			local viewPortDev = slot:FindFirstChild("ViewPort")

			if viewPortDev then
				viewPortDev:Destroy()
			end

			local viewPortGame = slot.Content:FindFirstChild("ViewPort")

			if viewPortGame then
				viewPortGame:Destroy()
			end

			slot.Amount.Visible = false
			slot.Content.TextLabel.Visible = false
			tools[tonumber(slot.Name)] = nil
		end
	end

	for _, value in workersFrame.ScrollingFrame:GetChildren() do
		if not value:IsA("UIGridLayout") then
			local originalName = value:GetAttribute("ORIGINAL_NAME")
			if not toolNameList[originalName] then
				value:Destroy()
			end
		end
	end

	for _, value in gamesFrame.ScrollingFrame:GetChildren() do
		if not value:IsA("UIGridLayout") then
			local originalName = value:GetAttribute("ORIGINAL_NAME")
			if not toolNameList[originalName] then
				value:Destroy()
			end
		end
	end
end

function BackpackController:Open()
	backpackExpand.Visible = true
end

function BackpackController:Close()
	backpackExpand.Visible = false
end

function BackpackController:GetScreen()
	return backpackExpand
end

return BackpackController
