local Devs = table.freeze({

	["1_DevIntern"] = {
		Name = "1_DevIntern",
		TimeToProduceGame = 5,
		CapacityOfGamesProduced = 1000,
		Price = 100,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 1,
			Label = "Dev Intern",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 100,
			Min = 1,
			Max = 5,
		},
		Games = {
			["Become_a_Ninja"] = {
				Chance = 20,
			},

			["Be_a_Model"] = {
				Chance = 20,
			},

			["Build_a_City"] = {
				Chance = 20,
			},

			["Coin_Runner"] = {
				Chance = 20,
			},

			["Obby_World"] = {
				Chance = 20,
			},
		},
	},

	["2_JuniorDev"] = {
		Name = "2_JuniorDev",
		TimeToProduceGame = 5,
		CapacityOfGamesProduced = 10,
		Price = 10,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 2,
			Label = "Junior Developer",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 100,
			Min = 1,
			Max = 10,
		},
		Games = {
			["Become_a_Ninja"] = {
				Chance = 100,
			},
		},
	},

	["3_MidLevelDev"] = {
		Name = "3_MidLevelDev",
		TimeToProduceGame = 20,
		CapacityOfGamesProduced = 10,
		Price = 10,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 3,
			Label = "Mid Level Developer",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 100,
			Min = 1,
			Max = 10,
		},
		Games = {
			["Become_a_Ninja"] = {
				Chance = 100,
			},
		},
	},
	["4_SeniorDev"] = {
		Name = "4_SeniorDev",
		TimeToProduceGame = 20,
		CapacityOfGamesProduced = 10,
		Price = 10,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 4,
			Label = "Senior Developer",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 100,
			Min = 1,
			Max = 10,
		},
		Games = {
			["Become_a_Ninja"] = {
				Chance = 100,
			},
		},
	},

	["5_ConceptArtist"] = {
		Name = "5_ConceptArtist",
		TimeToProduceGame = 20,
		CapacityOfGamesProduced = 10,
		Price = 10,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 5,
			Label = "Concept Artist",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 100,
			Min = 1,
			Max = 10,
		},
		Games = {
			["Become_a_Ninja"] = {
				Chance = 100,
			},
		},
	},
})

return Devs
