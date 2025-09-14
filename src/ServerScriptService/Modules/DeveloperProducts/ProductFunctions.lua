local ProductFunctions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DeveloperProducts = require(ReplicatedStorage.Enums.DeveloperProducts)

ProductFunctions[DeveloperProducts:GetEnum("RESTOCK").Id] = function(receipt, player)
	return true
end

return ProductFunctions
