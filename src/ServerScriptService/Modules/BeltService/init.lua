local BeltService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BaseService = require(ServerScriptService.Modules.BaseService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local Crates = require(ReplicatedStorage.Enums.Crates)
local UtilService = require(ServerScriptService.Modules.UtilService)

function BeltService:Init() end

function BeltService:Start(player)
	task.spawn(function()
		local attachments = BaseService:GetAttachmentsBeld(player)
		BaseService:GetAttachmentSlotsBeld(player)
		if not attachments then
			return
		end

		local startAttachment = attachments.Start
		local endAttachment = attachments.End

		local cratesFolder = ReplicatedStorage.Model.Crates

		local speed = 6
		local spawnDelay = 2 -- cria 1 caixa a cada 2 segundos

		-- Pasta onde as caixas devem ser colocadas
		local runtimeCratesFolder = workspace:WaitForChild("Runtime"):WaitForChild(player.UserId):WaitForChild("Crates")

		-- Pega posição de um Model (funciona mesmo sem PrimaryPart)
		local function getPosition(model)
			local primary = model.PrimaryPart
			if primary then
				return primary.Position
			end
			local cf = model:GetBoundingBox()
			return cf.Position
		end

		-- Move o modelo
		local function moveModel(model, vec)
			model:PivotTo(model:GetPivot() + vec)
		end

		-- Sorteia item da pasta
		local function getRandomItem()
			local list = cratesFolder:GetChildren()
			if #list == 0 then
				return nil
			end
			return list[math.random(1, #list)]
		end

		-- Spawna uma caixa na esteira
		local function spawnCrate()
			local ref = getRandomItem()
			if not ref then
				return
			end

			local clone = ref:Clone()
			clone.Parent = runtimeCratesFolder

			-- ancorar tudo
			for _, obj in ipairs(clone:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.Anchored = true
				end
			end

			local beltBillboardGui = clone.PrimaryPart:FindFirstChild("BeltBillboardGui")

			if beltBillboardGui then
				local enum = Crates[clone.Name]
				if enum then
					beltBillboardGui.Frame.PriceOrTime.Text = UtilService:FormatToUSD(enum.Price)
					beltBillboardGui.Frame.CrateName.Text = enum.GUI.Label
					beltBillboardGui.Frame.Rarity.Text = enum.Rarity
					beltBillboardGui.Frame.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors[enum.Rarity].Value
				end
			end
			clone:PivotTo(startAttachment.WorldCFrame)
			CrateService:ConfigureProximityPrompt(player, clone)

			return clone
		end

		-- Lista de caixas na esteira
		local crates = {}

		-- Loop principal
		while player.Parent do
			local dt = task.wait()

			-- Criar caixa nova a cada spawnDelay
			if tick() % spawnDelay < dt then
				local newCrate = spawnCrate()
				if newCrate then
					table.insert(crates, newCrate)
				end
			end

			-- Mover caixas existentes
			for i = #crates, 1, -1 do
				local crate = crates[i]

				if crate and crate.Parent then
					local pos = getPosition(crate)
					local target = endAttachment.WorldPosition
					local dir = (target - pos).Unit

					-- move
					moveModel(crate, dir * speed * dt)

					-- chegou no fim?
					if (getPosition(crate) - target).Magnitude < 1 then
						crate:Destroy()
						table.remove(crates, i)
					end
				else
					table.remove(crates, i)
				end
			end
		end
	end)
end

return BeltService
