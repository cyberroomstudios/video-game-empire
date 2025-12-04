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
		if response[actionIdentifier] == "StartDevSound" then
			local devId = response.data.DevId
			DevController:InitProgrammerSound(devId)
		end
	end)
end

function DevController:CreateAllProximityDev()
	local playerFolder = workspace.Runtime:FindFirstChild(player.UserId)

	for _, value in playerFolder.Devs:GetChildren() do
		DevController:CreateProximity(value)
	end
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

function DevController:EnableGetMoneyEffect(model: Model)
	-- Ativa um Highliter
	local effectsFolder = model:FindFirstChild("Effects")
	if effectsFolder then
		local hightlight = effectsFolder:FindFirstChild("HighlightGetMoney")
		local moneyParticleAttachment = effectsFolder:FindFirstChild("MoneyParticleAttachment")

		if moneyParticleAttachment then
			local moneyParticleEmitter = moneyParticleAttachment:FindFirstChild("MoneyParticleEmitter")

			if moneyParticleEmitter then
				moneyParticleEmitter:Emit(40)
			end
		end

		if hightlight then
			hightlight.Enabled = true
			task.delay(0.1, function()
				hightlight.Enabled = false
			end)
		end
	end
end

function DevController:CreateProximity(model: Model)
	local playerFolder = workspace.Runtime[player.UserId]
	local primary = ClientUtil:WaitForDescendants(model, "Primary")

	if not primary then
		warn("Primary not found in Dev Model")
		return
	end

	local getMoneyProximityPrompt = primary:FindFirstChild("GetMoneyProximityPrompt")

	if not getMoneyProximityPrompt then
		warn("Get Money Proximity Prompt not found in Dev Model")
		return
	end

	local getMoneyBillboardGui = primary:FindFirstChild("GetMoneyBillboardGui")

	getMoneyProximityPrompt.PromptShown:Connect(function()
		local oldMoney = model:GetAttribute("TOTAL_MONEY") or 0

		if oldMoney > 0 then
			DevController:EnableGetMoneyEffect(model)
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GetMoney",
				data = {
					DevId = model:GetAttribute("ID"),
				},
			})
		end

		
	end)

	getMoneyProximityPrompt.PromptHidden:Connect(function()
		getMoneyBillboardGui.Enabled = false
	end)
end

function DevController:GetDevModel(playerFolder: Folder, devId: number)
	for _, value in playerFolder.Devs:GetChildren() do
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
