	local GameRarity = table.freeze({
		["COMMON"] = {
			Name = "Common",
			Rarity = 70,
		},

		["SILVER"] = {
			Name = "Silver",
			Rarity = 15,
			PricePercentagemIncrement = 20, -- adicionar 20% ao valor original
		},

		["GOLD"] = {
			Name = "Gold",
			Rarity = 10,
			PricePercentagemIncrement = 30,
		},

		["RAINBOW"] = {
			Name = "Rainbow",
			Rarity = 5,
			PricePercentagemIncrement = 100,
		},
	})

	return GameRarity
