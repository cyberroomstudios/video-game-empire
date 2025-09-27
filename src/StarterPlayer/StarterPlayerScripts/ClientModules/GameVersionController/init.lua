local Players = game:GetService("Players")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameVersion")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local GameVersionController = {}

local gameVersionText
function GameVersionController:Init()
	GameVersionController:CreateReferences()
	GameVersionController:Apply()
end

function GameVersionController:Apply()
	task.spawn(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetVersion",
		})
		gameVersionText.Text = "Grow a Game Studio:" .. result
	end)
end

function GameVersionController:CreateReferences()
	-- Botões referentes aos Teleports
	gameVersionText = UIReferences:GetReference("GAME_VERSION")
end

return GameVersionController
