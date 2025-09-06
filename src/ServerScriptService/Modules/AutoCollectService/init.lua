local AutoCollectService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local DevService = require(ServerScriptService.Modules.DevService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local bridge = BridgeNet2.ReferenceBridge("AutoCollectService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local TARGET_PLAYTIME = 10 -- 10 minutos

function AutoCollectService:Init()
	AutoCollectService:InitBridgeListener()
end

function AutoCollectService:AddAutoCollectPlaytime(player: Player)
	player:SetAttribute("LOGIN_TIME", os.time())
end

function AutoCollectService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetPlaytime" then
			return AutoCollectService:GetPlaytime(player)
		end

		if data[actionIdentifier] == "ActiveAutoCollect" then
			return AutoCollectService:ActiveAutoCollect(player)
		end

		if data[actionIdentifier] == "InactiveAutoCollect" then
			return AutoCollectService:InactiveAutoCollect(player)
		end
	end
end

function AutoCollectService:InactiveAutoCollect(player: Player)
	player:SetAttribute("ACTIVED_AUTO_COLLECT", false)
end

function AutoCollectService:ActiveAutoCollect(player: Player)
	local hasAutoCollect = PlayerDataHandler:Get(player, "hasAutoCollect")

	if hasAutoCollect then
		player:SetAttribute("HAS_AUTO_COLLECT", true)
		player:SetAttribute("ACTIVED_AUTO_COLLECT", true)
		AutoCollectService:ActiveAutoCollectThread(player)
		return true
	end

	if AutoCollectService:GetPlaytime(player) == 0 then
		player:SetAttribute("HAS_AUTO_COLLECT", true)
		PlayerDataHandler:Set(player, "hasAutoCollect", true)
		player:SetAttribute("ACTIVED_AUTO_COLLECT", true)
		AutoCollectService:ActiveAutoCollectThread(player)
		return true
	end
end

function AutoCollectService:GetPlaytime(player: Player)
	local now = os.time()
	local loginTime = player:GetAttribute("LOGIN_TIME")

	-- se o loginTime não existir, evita erro
	if not loginTime then
		return TARGET_PLAYTIME -- ainda falta tudo
	end

	-- calcula quanto tempo já passou
	local elapsed = now - loginTime
	local remaining = TARGET_PLAYTIME - elapsed

	-- não deixa negativo
	if remaining < 0 then
		remaining = 0
	end

	return remaining -- retorna segundos faltando
end

function AutoCollectService:ActiveAutoCollectThread(player: Player)
	task.spawn(function()
		while player and player.Parent and player:GetAttribute("ACTIVED_AUTO_COLLECT") do
			if not player:GetAttribute("SELLING") then
				local collect = false
				local devs = PlayerDataHandler:Get(player, "workers")
				for _, dev in devs do
					local games = DevService:GetGamesFromDev(player, dev.Id)

					if games then
						collect = true
					end
				end

				if collect then
					GameNotificationService:SendSuccessNotification(player, "Game Collect")
				end
			end

			task.wait(3)
		end
	end)
end
return AutoCollectService
