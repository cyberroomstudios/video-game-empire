local StorageController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

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
			print("Encontrou")
		end
	end
end
return StorageController
