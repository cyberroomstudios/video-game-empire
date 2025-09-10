local StorageController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StorageService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
function StorageController:Init()
	StorageController:InitGUI()
end

function StorageController:InitGUI()
	for i = 1, 8 do
		local proximity = ClientUtil:WaitForDescendants(
			workspace,
			"Map",
			"BaseMaps",
			i,
			"mapa",
			"ModuleBuilding",
			"Mainbuilding",
			"FloorBase",
			"Storage",
			"Part",
			"ProximityPrompt"
		)

		if proximity then
			local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
			local screenGui = playerGui:WaitForChild("Main")
			-- Cria a Billboard
			local billboard = ReplicatedStorage.GUI.StorageProgress.BillboardGui:Clone()
			billboard.Adornee = proximity.Parent
			billboard.Enabled = false
			billboard.Parent = screenGui

			proximity.PromptShown:Connect(function()
				proximity.Parent:SetAttribute("UPDATE_INFORMATION", true)
				StorageController:UpdateInformations(proximity.Parent, billboard)

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

			proximity.PromptHidden:Connect(function()
				proximity.Parent:SetAttribute("UPDATE_INFORMATION", false)
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

			proximity.Triggered:Connect(function(playerTriggered)
				local result = bridge:InvokeServerAsync({
					[actionIdentifier] = "GetStorage",
					data = {
						BaseNumber = i,
					},
				})
			end)
		end
	end
end

function StorageController:UpdateInformations(storage: Part, billboard: BillboardGui)
	task.spawn(function()
		while storage:GetAttribute("UPDATE_INFORMATION") do
			local attributes = storage:GetAttributes()

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
						newItem.GameName.Text = gameName

						local viewPort = ReplicatedStorage.GUI.ViewPorts.Games:FindFirstChild(gameName):Clone()
						viewPort.Parent = newItem
					end

					local item = billboard.Content.Unlocked:FindFirstChild(gameName)

					item.GameCCU.Text = ClientUtil:FormatNumberToSuffixes(value) .. " CCU"
				end
			end

			local currentPercent = storage:GetAttribute("CURRENT_PERCENT_USED") or 0

			local developingBar = billboard.Content.ProgressBar.Capacity.Progress.Bar
			-- Configuração do Tween
			local goal = { Size = UDim2.fromScale(currentPercent, 1) }
			local tweenInfo = TweenInfo.new(
				0.1, -- duração da animação
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)

			-- Cria e toca o tween
			local tween = TweenService:Create(developingBar, tweenInfo, goal)
			tween:Play()

			local gameCapacity = billboard.Content.ProgressBar.Capacity.Progress.GameCapacity

			local numberOfGameStored = storage:GetAttribute("CURRENT_USED") or 0
			local capacityOfGameProduced = storage:GetAttribute("LIMITED") or 0
			gameCapacity.Text = numberOfGameStored .. "/" .. capacityOfGameProduced

			-- Espera antes de atualizar de novo
			task.wait(0.1)
		end
	end)
end
return StorageController
