local Workers = table.freeze({
	["Become a Ninja"] = {
		Name = "Become a Ninja",
		GUI = {
			Order = 1,
			Name = "Become a Ninja",
		},

		-- Definie quantos jogadores vão jogar jogo
		Players = {
			Min = 500,
			Max = 500,
		},
	},
})

return Workers
