local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local FTUEController = {}

local workersButton
local myStudioButton
local sellButton
local sellAllGames

local backpackButtons

local currentFTUE
local canProximityWorkers = false
function FTUEController:Init(data)
	FTUEController:CreateReferences()
	FTUEController:InitButtonListerns()

	if data.totalPlaytime == 0 then
		currentFTUE = "WORKERS"
		FTUEController:SetFTUE(workersButton, true)
		return
	end

	canProximityWorkers = true
end

function FTUEController:CreateReferences()
	workersButton = UIReferences:GetReference("WORKERS_BUTTON")
	myStudioButton = UIReferences:GetReference("MY_STUDIO_BUTTON")
	sellButton = UIReferences:GetReference("SELL_BUTTON")
	backpackButtons = UIReferences:GetReference("BACKPACK_BUTTONS")
	sellAllGames = UIReferences:GetReference("SELL_ALL_GAMES")
end

function FTUEController:SetFTUE(button, state)
	if button and button:FindFirstChild("FTUE") then
		button.FTUE.Visible = state
	end
end

function FTUEController:SetCanProximityWorker(state)
	
	canProximityWorkers = state
end

function FTUEController:GetCanProximityWorker()
	return canProximityWorkers
end

function FTUEController:InitButtonListerns()
	workersButton.MouseButton1Click:Connect(function()
		if currentFTUE == "WORKERS" then
			currentFTUE = "SELECT_ITEM"
			FTUEController:SetFTUE(workersButton, false)
		end
	end)

	myStudioButton.MouseButton1Click:Connect(function()
		if currentFTUE == "MY_STUDIO" then
			currentFTUE = "SELECT_ITEM_BACKPACK"
			FTUEController:SetFTUE(myStudioButton, false)
			FTUEController:SetFTUE(backpackButtons["1"], true)
		end
	end)

	sellButton.MouseButton1Click:Connect(function()
		if currentFTUE == "SELL" then
			currentFTUE = "SELL_ALL"
			FTUEController:SetFTUE(sellButton, false)
			FTUEController:SetFTUE(sellAllGames, true)
		end
	end)

	sellAllGames.MouseButton1Click:Connect(function()
		if currentFTUE == "SELL_ALL" then
			currentFTUE = "END"
			FTUEController:SetFTUE(sellAllGames, false)
		end
	end)

	backpackButtons["1"].MouseButton1Click:Connect(function()
		if currentFTUE == "SELECT_ITEM_BACKPACK" then
			local baseNumber = Players.LocalPlayer:GetAttribute("BASE")
			local base = Workspace.Map.BaseMaps:FindFirstChild(baseNumber)

			if base then
				local ftueTarget = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.Ftue.FTUETarget
				FTUEController:CreateBeam(ftueTarget)
				currentFTUE = "SET_DEV"
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local inputOne = Enum.KeyCode.One

		if input.KeyCode == inputOne and not gameProcessed then
			if currentFTUE == "SELECT_ITEM_BACKPACK" then
				
				local baseNumber = Players.LocalPlayer:GetAttribute("BASE")
				local base = Workspace.Map.BaseMaps:FindFirstChild(baseNumber)

				if base then
					local ftueTarget = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.Ftue.FTUETarget
					FTUEController:CreateBeam(ftueTarget)
					currentFTUE = "SET_DEV"
				end
			end
		end
	end)
end

function FTUEController:SetCurrentMyStudioFTUE()
	FTUEController:SetFTUE(myStudioButton, true)
	currentFTUE = "MY_STUDIO"
end

function FTUEController:SetCurrentGetGameFTUE()
	if currentFTUE == "SET_DEV" then
		if workspace:FindFirstChild("beam") then
			local beam = workspace:FindFirstChild("beam")
			FTUEController:SetFTUE(backpackButtons["1"], false)

			beam:Destroy()
			currentFTUE = "COLLECT_GAME"
		end
	end
end

function FTUEController:SetCurrentSellFTUE()
	if currentFTUE == "COLLECT_GAME" then
		FTUEController:SetFTUE(sellButton, true)
		currentFTUE = "SELL"
	end
end

function FTUEController:GetCurrentState()
	return currentFTUE
end

function FTUEController:SetCurrentState(newCurrent)
	currentFTUE = newCurrent
end

function FTUEController:CreateBeam(target)
	local beam = Instance.new("Beam")
	if not target then
		return
	end

	local targetAtt0

	if target:IsA("Model") then
		local att0 = target:FindFirstChild("Att0")
		if not att0 then
			att0 = Instance.new("Attachment")
			att0.Name = "Att0"
			att0.Parent = target.PrimaryPart

			targetAtt0 = att0
		end
	end

	if target:IsA("Part") then
		local att0 = target:FindFirstChild("Att0")
		if not att0 then
			att0 = Instance.new("Attachment")
			att0.Name = "Att0"
			att0.Parent = target

			targetAtt0 = att0
		end
	end

	local player = Players.LocalPlayer

	local char = player.Character or player.CharacterAdded:Wait()
	beam.Attachment0 = targetAtt0
	beam.Attachment1 = char:FindFirstChild("Torso").WaistBackAttachment

	beam.Brightness = 3
	beam.Color = ColorSequence.new(Color3.fromRGB(42, 202, 255))
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Texture = "rbxassetid://6798365555"
	beam.TextureLength = 4
	beam.TextureMode = Enum.TextureMode.Static
	beam.TextureSpeed = -2
	beam.Segments = 15
	beam.Width0 = 3
	beam.Width1 = 3
	beam.FaceCamera = true
	beam.Name = "beam"
	beam.Parent = workspace
end
return FTUEController
