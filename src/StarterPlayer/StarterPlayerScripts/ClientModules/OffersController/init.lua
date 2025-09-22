local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local DeveloperProductController = require(Players.LocalPlayer.PlayerScripts.ClientModules.DeveloperProductController)

local OffersController = {}

local rotateOfferBackground
local rotateOfferContent

function OffersController:Init()
	OffersController:CreateReferences()
	OffersController:CreateRotateOffers()
	OffersController:InitButtonListerns()
end

function OffersController:CreateReferences()
	-- Botões referentes aos Teleports
	rotateOfferContent = UIReferences:GetReference("ROTATE_OFFER_CONTENT")
	rotateOfferBackground = UIReferences:GetReference("START_BURST")
end

function OffersController:InitButtonListerns()
	rotateOfferContent.MouseButton1Click:Connect(function()
		DeveloperProductController:OpenPaymentRequestScreen("SAHUR")
	end)
end

function OffersController:CreateRotateOffers()
	if UserInputService.TouchEnabled then
		rotateOfferBackground.Position = UDim2.fromScale(0.9, rotateOfferBackground.Position.Y.Scale)
		rotateOfferContent.Position = UDim2.fromScale(0.9, rotateOfferContent.Position.Y.Scale)
	end

	task.spawn(function()
		local function InitBackground()
			-- Configurando o Background
			local rotationSpeed = 30 -- Graus por segundo
			RunService.RenderStepped:Connect(function(deltaTime)
				rotateOfferBackground.Rotation = rotateOfferBackground.Rotation + rotationSpeed * deltaTime
				if rotateOfferBackground.Rotation >= 360 then
					rotateOfferBackground.Rotation = rotateOfferBackground.Rotation - 360
				end
			end)
		end

		local function InitContent()
			local frame = rotateOfferContent
			local speed = 1.8 -- Velocidade do pulso
			local baseSize = frame.Size -- Tamanho original
			local timeElapsed = 0

			-- Limites
			local minScale = 0.8 -- 50% do tamanho original
			local maxScale = 1.2 -- 120% do tamanho original

			RunService.RenderStepped:Connect(function(deltaTime)
				timeElapsed += deltaTime * speed
				-- Valor do seno varia de -1 a 1
				local sineValue = math.sin(timeElapsed * speed)

				-- Mapeando o valor do seno para o intervalo [minScale, maxScale]
				local scaleFactor = minScale + ((sineValue + 1) / 2) * (maxScale - minScale)

				frame.Size = UDim2.new(
					baseSize.X.Scale * scaleFactor,
					baseSize.X.Offset * scaleFactor,
					baseSize.Y.Scale * scaleFactor,
					baseSize.Y.Offset * scaleFactor
				)
			end)
		end

		InitBackground()
		InitContent()
	end)
end

return OffersController
