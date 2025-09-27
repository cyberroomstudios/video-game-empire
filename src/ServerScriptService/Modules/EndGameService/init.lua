local EndGameService = {}

local ServerScriptService = game:GetService("ServerScriptService")

function EndGameService:Init() end

function EndGameService:Apply(userId: number)
	EndGameService:ReleaseBase(userId)
	EndGameService:DeleteAllRuntime(userId)
	EndGameService:CleanBaseName(userId)
	EndGameService:CleanCCU(userId)
	
end

function EndGameService:DeleteAllRuntime(userId: number)
	local folder = workspace.Runtime:FindFirstChild(userId)

	if folder then
		folder:Destroy()
	end
end

function EndGameService:CleanBaseName(userId: number)
	local base = EndGameService:GetBase(userId)

	if base then
		local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.OwnerBillboard.NameBillboard
		billboard.SurfaceGui.PlayerName.Text = ""
	end
end

function EndGameService:CleanCCU(userId: number)
	local base = EndGameService:GetBase(userId)

	if base then
		local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.CCUBilboard.Billboard
		billboard.SurfaceGui.PlayerName.Text = ""
	end
end

function EndGameService:ReleaseBase(userId: number)
	local base = EndGameService:GetBase(userId)
	if not base then
		warn("Base not foun d in Release")
		return
	end
	base:SetAttribute("BUSY", false)
	base:SetAttribute("OWNER", "")
end

function EndGameService:GetBase(userId: number)
	local places = workspace.Map.BaseMaps:GetChildren()

	for _, value in places do
		if value:GetAttribute("OWNER") and value:GetAttribute("OWNER") == userId then
			return value
		end
	end
end

return EndGameService
