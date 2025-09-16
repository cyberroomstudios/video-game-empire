local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Server Modules
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Utility.BridgeNet2)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)

local function ConfigureMaxCCU()
	for _, gameInfo in Games do
		local min = gameInfo.Players.Min
		local maxCCU = workspace:GetAttribute("MAX_CCU_PERCENT_VAR")
		local max = min + (min * maxCCU)
		gameInfo.Players.Max = max
	end
end

local function ConfigureReplicatedStorage()
	local developerFolder: Folder = workspace.Developer
	local modelFolder = developerFolder.Models
	local devsFolder = modelFolder.Devs

	for _, value in devsFolder:GetChildren() do
		value.Parent = ReplicatedStorage.Model.Devs
	end
end

ConfigureMaxCCU()

ConfigureReplicatedStorage()

PlayerDataHandler:Init()

local function initializerBridge()
	local bridge = BridgeNet2.ReferenceBridge("Level")
end

initializerBridge()

local folder = ServerScriptService.Modules

for _, module in folder:GetChildren() do
	if module.Name == "Player" then
		continue
	end

	local file = require(module)

	-- If the module has an Init function, call it
	if file.Init then
		file:Init()
	end
end
