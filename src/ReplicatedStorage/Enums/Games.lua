local Workers = table.freeze({
	["Tycoon"] = {
		Name = "Tycoon",
		GUI = {
			Order = 1,
			Name = "Tycoon",
		},

		-- Definie quantos jogadores vão jogar jogo
		Players = {
			Min = 500,
			Max = 500,
		},
	},

	["Obby"] = {
		Name = "Obby",
		GUI = {
			Order = 2,
			Name = "Obby",
		},
		Players = {
			Min = 100,
			Max = 500,
		},
	},

	["Simulator"] = {
		Name = "Simulator",
		GUI = {
			Order = 3,
			Name = "Simulator",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},

	["Roleplay"] = {
		Name = "Roleplay",
		GUI = {
			Order = 4,
			Name = "Roleplay",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},

	["Adventure"] = {
		Name = "Adventure",
		GUI = {
			Order = 5,
			Name = "Adventure",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},

	["TowerDefense"] = {
		Name = "TowerDefense",
		GUI = {
			Order = 6,
			Name = "Tower Defense",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},
	["Horror"] = {
		Name = "Horror",
		GUI = {
			Order = 7,
			Name = "Horror",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},
	["BattlerRoyale"] = {
		Name = "BattlerRoyale",
		GUI = {
			Order = 8,
			Name = "Battler Royale",
		},
		Players = {
			Min = 1000,
			Max = 10000,
		},
	},
})

return Workers
