local GamepassController = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gamepass = require(ReplicatedStorage.Enums.Gamepass)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GamepassService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function GamepassController:Init() end

function GamepassController:OpenPaymentRequestScreen(gamepassName: string)
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Gamepass.ENUM[gamepassName].Id)
end

return GamepassController
