local Players = game:GetService("Players")
local BaseController = {}

local player = Players.LocalPlayer

function BaseController:GetBase()
	local places = workspace.Map.BaseMaps:GetChildren()

	for _, value in places do
		if value.Name == player:GetAttribute("BASE") then
			return value
		end
	end
end

function BaseController:GetAttachmentSlotsBeld()

	local base = BaseController:GetBase()
	local attachments = {}

	while not next(attachments) do
		if not player.Parent then
			return
		end

		for _, value in base:GetDescendants() do
			if value:GetAttribute("ATTACHMENT_TYPE") and value:GetAttribute("ATTACHMENT_TYPE") == "SLOT" then
				table.insert(attachments, value)
			end
		end
		
		task.wait(1)
	end

	
	return attachments
end

return BaseController