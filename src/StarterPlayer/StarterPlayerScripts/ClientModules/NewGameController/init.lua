local NewGameController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Players = game:GetService("Players")
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local Games = require(ReplicatedStorage.Enums.Games)
local ConfettiController = require(Players.LocalPlayer.PlayerScripts.ClientModules.ConfettiController)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen
local newGameNames = {}

function NewGameController:Init()
	NewGameController:CreateReferences()
end

function NewGameController:CreateReferences()
	-- Botões referentes aos Teleports
	screen = UIReferences:GetReference("NEW_GAME")
end

function NewGameController:Open()
	SoundManager:Play("COLLECT_NEW_GAME")
	screen.Visible = true
	NewGameController:PlayTween()
end

function NewGameController:Close()
	screen.Visible = false
end

function NewGameController:GetScreen()
	return screen
end

function NewGameController:AddNewGameName(newGameName: string)
	table.insert(newGameNames, newGameName)
end

function NewGameController:BuildGameNames(content: Frame)
	local names = {}
	for _, value in content.Images:GetChildren() do
		if value:GetAttribute("DELETED") then
			value:Destroy()
		end
	end

	for _, value in newGameNames do
		local guiName = Games[value].GUI.Name
		if guiName then
			table.insert(names, guiName)
		end

		local newItem = content.Images.ImageContent:Clone()

		local viewPort = ReplicatedStorage.GUI.ViewPorts.Games[value]:Clone()
		viewPort.Size = UDim2.fromScale(1, 1)
		viewPort.Position = UDim2.fromScale(0.5, 0.5)
		viewPort.AnchorPoint = Vector2.new(0.5, 0.5)
		viewPort.Parent = newItem
		viewPort.Visible = true

		newItem:SetAttribute("DELETED", true)
		newItem.Visible = true
		newItem.Parent = content.Images
	end

	content.Folder.GameGenre.Text = table.concat(names, ",")
end
function NewGameController:PlayTween()
	local frame = screen
	frame.Content.Visible = false
	NewGameController:BuildGameNames(screen.Content)

	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0.1, 0, 0.176, 0) -- só altura definida

	-- Configurações do tween
	local tweenInfo = TweenInfo.new(
		0.3, -- duração em segundos
		Enum.EasingStyle.Quad, -- estilo da animação
		Enum.EasingDirection.Out, -- direção da animação
		0, -- quantas vezes repetir
		false, -- reverso?
		0 -- delay
	)

	-- Tamanho final: largura cheia no eixo X
	local goal = { Size = UDim2.new(1, 0, 0.176, 0) }

	task.spawn(function()
		ConfettiController:CreateConfetti()
	end)

	-- Criar e tocar o tween
	local tween = TweenService:Create(frame, tweenInfo, goal)

	tween:Play()
	task.wait(0.3)
	frame.Content.Visible = true

	newGameNames = {}
end

return NewGameController
