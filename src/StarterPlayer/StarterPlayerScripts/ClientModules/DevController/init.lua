local DevController = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local FTUEController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FTUEController)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local bridge = BridgeNet2.ReferenceBridge("DevService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local player = Players.LocalPlayer

local deleteDevFrame
local deleteDevYesButton
local deleteDevNoButton

local currentDevId

function DevController:Init()
	DevController:CreateReferences()
	DevController:InitButtonListerns()
	DevController:InitBridgeListener()
end

function DevController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "CreateProximity" then
			local devId = response.data.DevId
			DevController:CreateProximity(devId)
		end

		if response[actionIdentifier] == "StartDevSound" then
			local devId = response.data.DevId
			DevController:InitProgrammerSound(devId)
		end
	end)
end

function DevController:CreateReferences()
	-- Botões referentes aos Teleports
	deleteDevFrame = UIReferences:GetReference("DELETE_DEV_FRAME")
	deleteDevNoButton = UIReferences:GetReference("DELETE_DEV_NO_BUTTON")
	deleteDevYesButton = UIReferences:GetReference("DELETE_DEV_YES_BUTTON")
end

function DevController:InitProgrammerSound(devId: number)
	local playerFolder = workspace.Runtime[player.UserId]

	local model = DevController:GetDevModel(playerFolder, devId)

	if model.Name == "7_GameTester" then
		--SoundManager:PlayProgrammerSound("GAME_SPACE", model)
		SoundManager:PlayProgrammerSound("CONSOLE_CONTROLLER", model)
		return
	end

	if model.Name == "8-SahurDev" then
		SoundManager:PlayProgrammerSound("SAHUR", model)
		return
	end

	local indexRandom = math.random(1, 3)
	SoundManager:PlayProgrammerSound("KEYBOARD_" .. indexRandom, model)
end

function DevController:InitButtonListerns()
	deleteDevYesButton.MouseButton1Click:Connect(function()
		
		deleteDevFrame.Visible = false
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "DeleteDev",
			data = {
				DevId = currentDevId,
			},
		})
		currentDevId = nil
	end)

	deleteDevNoButton.MouseButton1Click:Connect(function()
		
		deleteDevFrame.Visible = false

		currentDevId = nil
	end)
end

function DevController:CreateProximity(devId: number)
	local playerGui = player:WaitForChild("PlayerGui")
	local screenGui = playerGui:WaitForChild("Main")

	local playerFolder = workspace.Runtime[player.UserId]

	local model = DevController:GetDevModel(playerFolder, devId)
	local prompt = model.Rig:WaitForChild("Head").ProximityPrompt
	prompt.HoldDuration = 0 -- 0 = clique instantâneo
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.UIOffset = Vector2.new(20, 0)
	prompt.Parent = model
	prompt.Style = Enum.ProximityPromptStyle.Custom

	local billboard = ReplicatedStorage.GUI.DevProgress.BillboardGui:Clone()
	billboard.Adornee = model.Rig.BillboardAdornee

	billboard.Enabled = false
	billboard.Name = "DEV_PROGRESS_" .. devId
	billboard.Parent = screenGui

	billboard.Content.Buttons.Delete.MouseButton1Click:Connect(function()
		deleteDevFrame.Visible = true
		billboard.Enabled = false
		currentDevId = devId
	end)
	billboard.Content.Buttons.Collect.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetGames",
			data = {
				DevId = devId,
			},
		})

		if result and next(result) ~= nil then
			SoundManager:Play("COLLECT_GAME")
			for _, value in billboard.Content.Unlocked:GetChildren() do
				if value:GetAttribute("IS_GAME") then
					value:Destroy()
				end
			end

			local currentFTUE = FTUEController:GetCurrentState()

			if currentFTUE and currentFTUE == "COLLECT_GAME" then
				FTUEController:SetCurrentSellFTUE()
			end
		end
	end)

	prompt.PromptShown:Connect(function()
		model:SetAttribute("UPDATE_INFORMATION", true)
		DevController:UpdateDevInformations(model)
		billboard.Enabled = true

		billboard.Content.AnchorPoint = Vector2.new(0.5, 0.5) -- deixa o ponto de ancoragem no centro
		billboard.Content.Position = UDim2.fromScale(0.5, 0.5) -- centraliza na tela
		billboard.Content.Size = UDim2.fromScale(0, 0) -- começa invisível

		-- Configuração do tween
		local tweenInfo = TweenInfo.new(
			0.1, -- duração (meio segundo)
			Enum.EasingStyle.Back, -- estilo com "esticadinha" no final
			Enum.EasingDirection.Out
		)

		local goal = {}
		goal.Size = UDim2.fromScale(1, 1) -- tamanho final do frame

		-- Criar e executar o tween
		local tween = TweenService:Create(billboard.Content, tweenInfo, goal)
		tween:Play()
	end)

	prompt.PromptHidden:Connect(function()
		model:SetAttribute("UPDATE_INFORMATION", false)
		billboard.Content.AnchorPoint = Vector2.new(0.5, 0.5) -- deixa o ponto de ancoragem no centro
		billboard.Content.Position = UDim2.fromScale(0.5, 0.5) -- centraliza na tela

		-- Configuração do tween
		local tweenInfo = TweenInfo.new(
			0.1, -- duração (meio segundo)
			Enum.EasingStyle.Back, -- estilo com "esticadinha" no final
			Enum.EasingDirection.In
		)

		local goal = {}
		goal.Size = UDim2.fromScale(0, 0) -- tamanho final do frame

		-- Criar e executar o tween
		local tween = TweenService:Create(billboard.Content, tweenInfo, goal)
		tween:Play()

		tween.Completed:Connect(function()
			billboard.Enabled = false
		end)
	end)

	prompt.Triggered:Connect(function(playerTriggered)
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetGames",
			data = {
				DevId = devId,
			},
		})

		if result and next(result) ~= nil then
			SoundManager:Play("COLLECT_GAME")
			for _, value in billboard.Content.Unlocked:GetChildren() do
				if value:GetAttribute("IS_GAME") then
					value:Destroy()
				end
			end

			local currentFTUE = FTUEController:GetCurrentState()

			if currentFTUE and currentFTUE == "COLLECT_GAME" then
				FTUEController:SetCurrentSellFTUE()
			end
		end
	end)
end

function DevController:GetDevModel(playerFolder: Folder, devId: number)
	for _, value in playerFolder:GetChildren() do
		if value:GetAttribute("DEV") and value:GetAttribute("ID") == devId then
			return value
		end
	end
end

function DevController:UpdateDevInformations(model: Model)
	task.spawn(function()
		local dots = ""
		local playerGui = player:WaitForChild("PlayerGui")
		local screenGui = playerGui:WaitForChild("Main")

		local billboard = screenGui:WaitForChild("DEV_PROGRESS_" .. model:GetAttribute("ID"))

		for _, value in billboard.Content.Unlocked:GetChildren() do
			if value:GetAttribute("IS_GAME") then
				value:Destroy()
			end
		end

		while model:GetAttribute("UPDATE_INFORMATION") do
			local currentFTUE = FTUEController:GetCurrentState()

			billboard.Content.Buttons.Collect.FTUE.Visible = currentFTUE and currentFTUE == "COLLECT_GAME"

			local developingText = billboard.Content.ProgressBar.Developing.Title.TextLabel

			if model:GetAttribute("MAXIMUM_CAPACITY_REACHED") then
				developingText.Text = "Full... "
				task.wait(0.5)
				continue
			end

			dots = dots .. "."

			-- se passou de 3 pontos, volta para vazio
			if dots == "...." then
				dots = "."
			end

			developingText.Text = "Developing " .. dots
			task.wait(0.5)
		end
	end)

	task.spawn(function()
		local dots = ""
		local playerGui = player:WaitForChild("PlayerGui")
		local screenGui = playerGui:WaitForChild("Main")

		local billboard = screenGui:WaitForChild("DEV_PROGRESS_" .. model:GetAttribute("ID"))
		local developingBar = billboard.Content.ProgressBar.Developing.Progress.Bar

		while model:GetAttribute("UPDATE_INFORMATION") do
			local currentPercent = model:GetAttribute("CURRENT_PERCENT_PRODUCED") or 0

			-- Configuração do Tween
			local goal = { Size = UDim2.fromScale(currentPercent / 100, 1) }
			local tweenInfo = TweenInfo.new(
				0.1, -- duração da animação
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)

			-- Cria e toca o tween
			local tween = TweenService:Create(developingBar, tweenInfo, goal)
			tween:Play()

			local gameDeveloping = billboard.Content.ProgressBar.Developing.Progress.GameDeveloping

			gameDeveloping.Text = math.floor(currentPercent) .. "%"

			local attributes = model:GetAttributes()

			-- REMOVE itens que não existem mais ou cujo valor é 0
			for _, child in pairs(billboard.Content.Unlocked:GetChildren()) do
				if child:GetAttribute("IS_GAME") then
					local attrName = "STORED_GAME_" .. child.Name
					if not attributes[attrName] or attributes[attrName] <= 0 then
						child:Destroy()
					end
				end
			end

			for name, value in attributes do
				if string.find(name, "STORED_GAME_") and value > 0 then
					local gameName = string.gsub(name, "STORED_GAME_", "")

					if not billboard.Content.Unlocked:FindFirstChild(gameName) then
						local newItem = billboard.Content.Unlocked.Frame:Clone()
						newItem.Name = gameName
						newItem.Visible = true
						newItem.Parent = billboard.Content.Unlocked
						newItem:SetAttribute("IS_GAME", true)

						local viewPort = ReplicatedStorage.GUI.ViewPorts.Games:FindFirstChild(gameName):Clone()
						viewPort.Size = UDim2.fromScale(1, 1)
						viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
						viewPort.Position = UDim2.fromScale(0.5, 0.5)
						viewPort.Parent = newItem
					end

					local item = billboard.Content.Unlocked:FindFirstChild(gameName)

					item.GameCCU.Text = ClientUtil:FormatNumberToSuffixes(value) .. " CCU"
				end
			end

			-- Espera antes de atualizar de novo
			task.wait(0.1)
		end
	end)

	task.spawn(function()
		local playerGui = player:WaitForChild("PlayerGui")
		local screenGui = playerGui:WaitForChild("Main")

		local billboard = screenGui:WaitForChild("DEV_PROGRESS_" .. model:GetAttribute("ID"))

		while model:GetAttribute("UPDATE_INFORMATION") do
			local currentPercent = model:GetAttribute("CURRENT_PERCENT_CAPACITY") or 0

			local developingBar = billboard.Content.ProgressBar.Capacity.Progress.Bar
			-- Configuração do Tween
			local goal = { Size = UDim2.fromScale(currentPercent / 100, 1) }
			local tweenInfo = TweenInfo.new(
				0.1, -- duração da animação
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)

			-- Cria e toca o tween
			local tween = TweenService:Create(developingBar, tweenInfo, goal)
			tween:Play()

			local gameCapacity = billboard.Content.ProgressBar.Capacity.Progress.GameCapacity

			local numberOfGameStored = model:GetAttribute("NUMBER_OF_GAMES_STORED") or 0
			local capacityOfGameProduced = model:GetAttribute("CAPACITY_OF_GAMES_PRODUCED") or 0
			gameCapacity.Text = numberOfGameStored .. "/" .. capacityOfGameProduced

			-- Espera antes de atualizar de novo
			task.wait()
		end
	end)
end

return DevController
