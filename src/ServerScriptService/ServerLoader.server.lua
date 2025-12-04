local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Server Modules
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BridgeNet2 = require(ReplicatedStorage.Utility.BridgeNet2)
local Devs = require(ReplicatedStorage.Enums.Devs)
local Games = require(ReplicatedStorage.Enums.Games)

local function ConfigureViewPort()
	local references = {
		["DISK"] = workspace.Developer.ViewPorts.Games.References.DISK.DISK,
		["DISKET"] = workspace.Developer.ViewPorts.Games.References.DISKET.DISKET,
		["FITA"] = workspace.Developer.ViewPorts.Games.References.FITA.FITA,
		["FITA_2"] = workspace.Developer.ViewPorts.Games.References.FITA_2.FITA_2,
		["PENDRIVE"] = workspace.Developer.ViewPorts.Games.References.PENDRIVE.PENDRIVE,
	}

	local gamesTools = ServerStorage.Tools.Games:GetChildren()
	local viewPortFolder = ReplicatedStorage.GUI.ViewPorts.Games
	for _, gameTool in gamesTools do
		-- Criando o View Port

		-- Verificando tags de forma dinâmica
		for tagName in references do
			if CollectionService:HasTag(gameTool, tagName) then
				local reference = references[tagName]
				if reference then
					local viewPort = reference.Parent:Clone()
					viewPort.Visible = true
					viewPort[viewPort.Name]:Destroy()
					viewPort.Name = gameTool.Name

					-- Criando a Tool do ViewPort
					local newGameTool = gameTool:Clone()
					newGameTool.Parent = viewPort
					newGameTool:PivotTo(reference:GetPivot())

					newGameTool:ScaleTo(reference:GetScale())
					viewPort.Parent = viewPortFolder
				end

				break -- Se só uma tag é esperada, para aqui
			end
		end
	end
end


local function ConfigureMaxCCU()
	for _, gameInfo in Games do
		local min = gameInfo.Players.Min
		local maxCCU = workspace:GetAttribute("MAX_CCU_PERCENT_VAR")
		local max = min + (min * maxCCU / 100)

		gameInfo.Players.Max = max
	end
end

local function ConfigureReplicatedStorage()
	local developerFolder: Folder = workspace.Developer
	local modelFolder = developerFolder.Models
	local devsFolder = modelFolder.Devs
	local crateFolder = modelFolder.Crates

	for _, value in devsFolder:GetChildren() do
		local devEnum = Devs[value.Name]
		if not devEnum then
			warn("DevEnum not found:" .. value.Name)
			continue
		end

		if not value:FindFirstChild("Primary") then
			warn("Primary not found:" .. value.Name)
			continue
		end

		if not value:FindFirstChild("Primary"):FindFirstChild("BillboardGui") then
			warn("BillboardGui not found:" .. value.Name)
			continue
		end

		local devName = devEnum.GUI.Label
		local moneyPerSecound = devEnum.MoneyPerSecond

		value.Primary.BillboardGui.Frame.DevName.Text = devEnum.GUI.Label
		value.Primary.BillboardGui.Frame.MoneyPerSecond.Text = "$" .. devEnum.MoneyPerSecond .. "/s"

		value.Parent = ReplicatedStorage.Model.Devs
	end

	for _, value in crateFolder:GetChildren() do
		value.Parent = ReplicatedStorage.Model.Crates

		
	end
end

ConfigureViewPort()

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
