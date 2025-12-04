local ThreadService = {}
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Devs = require(ReplicatedStorage.Enums.Devs)
local UtilService = require(ServerScriptService.Modules.UtilService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local HatchingPlaceService = require(ServerScriptService.Modules.HatchingPlaceService)

function ThreadService:Init() end

function ThreadService:ValidateDev(devModel: Model)
	local devEnum = Devs[devModel.Name]
	if not devEnum then
		warn("DevEnum not found:" .. devModel.Name)
		return false
	end

	if not devModel:FindFirstChild("Primary") then
		warn("Primary not found:" .. devModel.Name)
		return false
	end

	if not devModel:FindFirstChild("Primary"):FindFirstChild("BillboardGui") then
		warn("BillboardGui not found:" .. devModel.Name)
		return false
	end

	return true
end

function ThreadService:UpdadeBillboardGui(devModel: Model)
	local billboardGui = devModel:FindFirstChild("Primary"):FindFirstChild("BillboardGui")
	local totalMoney = devModel:GetAttribute("TOTAL_MONEY")
	billboardGui.Frame.TotalMoney.Text = UtilService:FormatToUSD(totalMoney)
end

function ThreadService:StartDev(player: Player)
	task.spawn(function()
		while player.Parent do
			local playerFolder = workspace.Runtime[player.UserId]
			local devs = playerFolder.Devs:GetChildren()

			for _, value in devs do
				-- Validando o Modelo
				local isValidate = ThreadService:ValidateDev(value)
				if not isValidate then
					continue
				end
				local moneyPerSecound = Devs[value.Name].MoneyPerSecond
				local oldMoney = value:GetAttribute("TOTAL_MONEY") or 0
				local newMoney = oldMoney + moneyPerSecound

				value:SetAttribute("TOTAL_MONEY", newMoney)
				ThreadService:UpdadeBillboardGui(value)
			end

			task.wait(1)
		end
	end)
end

function ThreadService:StartHatchingPlace(player: Player)
	task.spawn(function()
		while player.Parent do
			local hatchingFolder = workspace.Runtime[player.UserId]["Hatching"]

			for _, value in hatchingFolder:GetChildren() do
				if not value:GetAttribute("READY") then
					local oldTime = value:GetAttribute("TIME_TO_OPEN") or 0

					if oldTime <= 0 then
						local beltBillboardGui = value.PrimaryPart:FindFirstChild("BeltBillboardGui")
						beltBillboardGui.Frame.PriceOrTime.TextColor3 = Color3.new(0.03, 1, 0)
						beltBillboardGui.Frame.PriceOrTime.Text = "READY"

						value:SetAttribute("READY", true)

						local openCrateProximityPrompt = value.PrimaryPart:FindFirstChild("OpenCrateProximityPrompt")

						if openCrateProximityPrompt then
							openCrateProximityPrompt.Enabled = true

							openCrateProximityPrompt.Triggered:Connect(function(playerTriggered)
								if player ~= playerTriggered then
									return
								end

								local slot = value:GetAttribute("SLOT")
								CrateService:Open(player, value, slot)
								HatchingPlaceService:ReleseAttachmentSlot(player, slot)
								value:Destroy()
							end)
						end
						continue
					end

					oldTime = oldTime - 1
					value:SetAttribute("TIME_TO_OPEN", oldTime)

					local beltBillboardGui = value.PrimaryPart:FindFirstChild("BeltBillboardGui")
					beltBillboardGui.Frame.PriceOrTime.Text = UtilService:FormatTime(oldTime)
				end
			end

			task.wait(1)
		end
	end)
end

return ThreadService
