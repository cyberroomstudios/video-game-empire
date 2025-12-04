local CrateController = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local BaseController = require(Players.LocalPlayer.PlayerScripts.ClientModules.BaseController)
local bridge = BridgeNet2.ReferenceBridge("CrateService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function CrateController:Init()
	CrateController:InitBridgeListener()
end

function CrateController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "Open" then
			local crateId = response.data.CrateId
			local selectedDev = response.data.SelectedDev
			local slot = response.data.Slot
			local devs = response.data.Devs
			CrateController:CreateDevs(slot, selectedDev, crateId, devs)
		end
	end)
end

function CrateController:CreateDevs(slot, selectedDev, crateId, devs)
	-- Cache para não ficar clonando várias vezes
	local devCache = {}

	local rotationCFrame = CFrame.Angles(math.rad(90), 0, 0)

	local function addBlackHighlight(model)
		if model:FindFirstChild("DevHighlight") then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "DevHighlight"
		highlight.Adornee = model
		highlight.FillColor = Color3.fromRGB(0, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
		highlight.FillTransparency = 0 -- Ajuste se quiser mais/menos opaco
		highlight.OutlineTransparency = 1
		highlight.Parent = model
	end

	-- Pré-carrega os modelos (apenas 1 clone para cada nome)
	local function getDevModel(name)
		if not devCache[name] then
			local original = ReplicatedStorage.Model.Devs:FindFirstChild(name)
			if not original then
				return nil
			end

			local clone = original:Clone()

			-- remove a bounding_box apenas uma vez
			local box = clone:FindFirstChild("bounding_box")
			if box then
				box:Destroy()
			end

			original:ScaleTo(0.7)

			-- Adiciona Highlight preto no clone "base"
			addBlackHighlight(clone)

			-- deixa guardado no cache
			devCache[name] = clone
		end

		return devCache[name]
	end

	local attachments = BaseController:GetAttachmentSlotsBeld()

	-- Código otimizado
	for _, attachment in attachments do
		if tonumber(attachment.Parent.Name) == tonumber(slot) then
			for i = 1, 2 do
				for _, name in devs do
					local devModel = getDevModel(name)
					if devModel then
						-- Criamos um clone leve do modelo já preparado
						local instance = devModel:Clone()

						instance:SetPrimaryPartCFrame(attachment.WorldCFrame * rotationCFrame)
						instance.Parent = workspace

						local scaleValue = Instance.new("NumberValue")
						scaleValue.Value = 0.7
						local tweenInfo = TweenInfo.new(
							0.45, -- duração do tween
							Enum.EasingStyle.Back, -- estilo
							Enum.EasingDirection.Out
						)
						local tween = TweenService:Create(scaleValue, tweenInfo, { Value = 1 })

						-- Sempre que o Value mudar, reescala o model
						scaleValue:GetPropertyChangedSignal("Value"):Connect(function()
							instance:ScaleTo(scaleValue.Value)
						end)

						tween:Play()
						tween.Completed:Wait()

						instance:Destroy()
					end
				end
			end

			local original = ReplicatedStorage.Model.Devs:FindFirstChild(selectedDev)
			local clone = original:Clone()

			clone:SetPrimaryPartCFrame(attachment.WorldCFrame * rotationCFrame)

			local box = clone:FindFirstChild("bounding_box")
			if box then
				box:Destroy()
			end

			clone.Parent = workspace

			local scaleValue = Instance.new("NumberValue")
			scaleValue.Value = 0.7
			local tweenInfo = TweenInfo.new(
				0.45, -- duração do tween
				Enum.EasingStyle.Back, -- estilo
				Enum.EasingDirection.Out
			)
			local tween = TweenService:Create(scaleValue, tweenInfo, { Value = 1 })

			-- Sempre que o Value mudar, reescala o model
			scaleValue:GetPropertyChangedSignal("Value"):Connect(function()
				clone:ScaleTo(scaleValue.Value)
			end)

			tween:Play()

			task.wait(2)
			clone:Destroy()

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "GiveCrateReward",
				data = {
					CrateId = crateId,
				},
			})
		end
	end
end

-- 90, 0, 0
return CrateController
