local SuperBaseService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local superBaseEvent = ReplicatedStorage.BindableEvent.SuperBaseEvent

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SuperBaseService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
function SuperBaseService:Init()
	SuperBaseService:InitListeners()
end

function SuperBaseService:LogEvent(player, eventType)
	superBaseEvent:Fire(player, eventType)
end

function SuperBaseService:InitListeners()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "logEvent" then
			SuperBaseService:LogEvent(player, data.data)
		end
	end
end
return SuperBaseService
