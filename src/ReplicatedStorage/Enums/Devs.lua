local Devs = table.freeze({

	["1_DevIntern"] = {
		Name = "1_DevIntern",
		TimeToProduceGame = 20,
		CapacityOfGamesProduced = 10,
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
			["Tycoon"] = {
				Chance = 70,
			},
			["Obby"] = {
				Chance = 30,
			},
		},
	},

	["2_JuniorDev"] = {
		Name = "2_JuniorDev",
		TimeToProduceGame = 20,
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
			["Tycoon"] = {
				Chance = 70,
			},
			["Obby"] = {
				Chance = 20,
			},

			["Simulator"] = {
				Chance = 30,
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
			["Roleplay"] = {
				Chance = 70,
			},
			["Adventure"] = {
				Chance = 30,
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
			["Tycoon"] = {
				Chance = 25,
			},
			["Obby"] = {
				Chance = 25,
			},
			["Roleplay"] = {
				Chance = 25,
			},
			["Adventure"] = {
				Chance = 25,
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
			["Tycoon"] = {
				Chance = 100,
			},
		},
	},
})

return Devs
