local RobuxLeadboard = {}

local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetOrderedDataStore("RobuxLeadboard_1.0")

function RobuxLeadboard:Init() end

function RobuxLeadboard:RegisterEntry(playerUserId: string, value: number)
	local success, _ = pcall(function()
		local key = playerUserId
		local value = value

		store:SetAsync(key, value)
	end)

	return success
end

function RobuxLeadboard:GetLeaderboards()
	local leaderboards = {}
	local success, _ = pcall(function()
		local isAscending = false
		local pageSize = 100
		local pages = store:GetSortedAsync(isAscending, pageSize)
		local top = pages:GetCurrentPage()

		for rank, data in top do
			local key = data.key
			local value = data.value

			-- Split the key using , as the delimiter
			local playerUserId = key

			leaderboards[rank] = {
				playerUserId = playerUserId,
				value = value,
			}
		end

		return true
	end)

	if not success then
		warn("Failed to get leaderboards")
		return false
	end

	return leaderboards
end

return RobuxLeadboard
