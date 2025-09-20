local ConfettiModule = {}

-- Configurações
local confettiColors = {
	Color3.fromRGB(255, 0, 0), -- Vermelho
	Color3.fromRGB(0, 255, 0), -- Verde
	Color3.fromRGB(0, 0, 255), -- Azul
	Color3.fromRGB(255, 255, 0), -- Amarelo
	Color3.fromRGB(255, 0, 255), -- Magenta
	Color3.fromRGB(0, 255, 255), -- Ciano
	Color3.fromRGB(255, 165, 0), -- Laranja
	Color3.fromRGB(128, 0, 128), -- Roxo
}

local confettiSettings = {
	amount = 50, -- Quantidade de confetes
	minSize = 9, -- Tamanho mínimo
	maxSize = 12, -- Tamanho máximo
	minFallSpeed = 1, -- Velocidade mínima de queda
	maxFallSpeed = 2, -- Velocidade máxima de queda
	minLifetime = 2, -- Tempo mínimo de vida (segundos)
	maxLifetime = 2, -- Tempo máximo de vida (segundos)
	rotationSpeed = 2, -- Velocidade de rotação
	fadeOutTime = 0.5, -- Tempo para desaparecer (segundos)
}

function ConfettiModule:Init() end

-- Função principal para criar confetes
function ConfettiModule:CreateConfetti()
	local parent = game.Players.LocalPlayer.PlayerGui

	-- Cria ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ConfettiEffect"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parent

	-- Cria confetes
	local confettiPieces = {}

	for i = 1, confettiSettings.amount do
		spawn(function()
			local sizeMultiplier = math.random(confettiSettings.minSize, confettiSettings.maxSize)
			local width = math.floor(2 * sizeMultiplier)
			local height = math.floor(5 * sizeMultiplier)

			local confetti = Instance.new("Frame")
			confetti.BorderSizePixel = 0
			-- Usa o tamanho baseado nas configurações
			confetti.Size = UDim2.new(0, width, 0, height)
			confetti.BackgroundColor3 = confettiColors[math.random(1, #confettiColors)]
			confetti.Rotation = math.random(0, 360)
			confetti.AnchorPoint = Vector2.new(0.5, 0.5)

			-- Posição inicial aleatória na tela
			local posX = math.random(0, 100) / 100
			local posY = -0.1 -- Começar um pouco acima da tela
			confetti.Position = UDim2.new(posX, 0, posY, 0)
			confetti.Parent = screenGui
			table.insert(confettiPieces, confetti)

			-- Propriedades para animação
			local fallSpeed = math.random(confettiSettings.minFallSpeed * 100, confettiSettings.maxFallSpeed * 100)
				/ 100
			local rotationDir = math.random(0, 1) == 1 and 1 or -1
			local rotationSpeed = math.random(50, 150) / 100 * confettiSettings.rotationSpeed * rotationDir
			local lifeTime = math.random(confettiSettings.minLifetime * 100, confettiSettings.maxLifetime * 100) / 100
			local horizontalDrift = (math.random(-50, 50) / 1000)

			local startTime = tick()
			local connection

			connection = game:GetService("RunService").RenderStepped:Connect(function(dt)
				local elapsed = tick() - startTime

				-- Atualiza posição
				local newPosY = posY + (fallSpeed * dt)
				local newPosX = posX + (horizontalDrift * dt)
				posY = newPosY
				posX = math.clamp(newPosX, 0, 1)

				confetti.Position = UDim2.new(posX, 0, posY, 0)

				-- Atualiza rotação
				confetti.Rotation = confetti.Rotation + (rotationSpeed * dt * 60)

				-- Desvanecimento ao final do tempo de vida
				if elapsed > lifeTime - confettiSettings.fadeOutTime then
					local alpha = math.max(
						0,
						1 - ((elapsed - (lifeTime - confettiSettings.fadeOutTime)) / confettiSettings.fadeOutTime)
					)
					confetti.BackgroundTransparency = 1 - alpha
				end

				-- Remove confete após o tempo de vida
				if elapsed >= lifeTime or posY > 1.2 then
					confetti:Destroy()
					connection:Disconnect()
				end
			end)
		end)

		-- Pequeno intervalo para não criar todos os confetes ao mesmo tempo
		wait(0.01)
	end

	-- Função para remover todos os confetes
	local function cleanup()
		for _, confetti in ipairs(confettiPieces) do
			if confetti and confetti.Parent then
				confetti:Destroy()
			end
		end
		screenGui:Destroy()
	end

	-- Limpa automaticamente após o tempo máximo de vida + buffer
	spawn(function()
		wait(confettiSettings.maxLifetime + 2)
		cleanup()
	end)

	return {
		ScreenGui = screenGui,
		Cleanup = cleanup,
	}
end

-- Função para ajustar configurações
function ConfettiModule:SetSettings(newSettings)
	for key, value in pairs(newSettings) do
		if confettiSettings[key] ~= nil then
			confettiSettings[key] = value
		end
	end
end

return ConfettiModule
