local EndGameService = {}

local ServerScriptService = game:GetService("ServerScriptService")

function EndGameService:Init() end

function EndGameService:Apply(player: Player)
	EndGameService:DeleteAllRuntime(player)
	EndGameService:CleanBaseName(player)
	EndGameService:CleanCCU(player)
	EndGameService:ReleaseBase(player)
end

function EndGameService:DeleteAllRuntime(player: Player)
	local folder = workspace.Runtime:FindFirstChild(player.UserId)

	if folder then
		folder:Destroy()
	end
end

function EndGameService:CleanBaseName(player: Player)
	local base = EndGameService:GetBase(player)

	if base then
		local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.OwnerBillboard.NameBillboard
		billboard.SurfaceGui.PlayerName.Text = ""
	end
end

function EndGameService:CleanCCU(player: Player)
	local base = EndGameService:GetBase(player)

	if base then
		local billboard = base.mapa.ModuleBuilding.Mainbuilding.FloorBase.CCUBilboard.Billboard
		billboard.SurfaceGui.PlayerName.Text = ""
	end
end

function EndGameService:ReleaseBase(player: Player)
	local base = EndGameService:GetBase(player)

	base:SetAttribute("BUSY", false)
	base:SetAttribute("OWNER", "")
end

function EndGameService:GetBase(player: Player)
	local places = workspace.Map.BaseMaps:GetChildren()

	for _, value in places do
		if value.Name == player:GetAttribute("BASE") then
			return value
		end
	end
end

return EndGameService
