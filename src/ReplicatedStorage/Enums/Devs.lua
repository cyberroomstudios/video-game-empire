local Devs = table.freeze({

	["1_DevIntern"] = {
		Name = "1_DevIntern",
		TimeToProduceGame = 8,
		CapacityOfGamesProduced = 100, --max CCU dev can produce
		Price = 20, --buy price
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
				Chance = 60,
			},

			["Island_Survival"] = {
				Chance = 30,
			},

			["Simulate_Everything"] = {
				Chance = 10,
			},
		},
	},

	["2_JuniorDev"] = {
		Name = "2_JuniorDev",
		TimeToProduceGame = 8,
		CapacityOfGamesProduced = 350,
		Price = 70,
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
			["Simulate_Everything"] = {
				Chance = 50,
			},
			["World_Destroyer"] = {
				Chance = 20,
			},
			["Run_a_Taqueria"] = {
				Chance = 20,
			},
			["School_of_Magic"] = {
				Chance = 10,
			},
		},
	},

	["3_MidLevelDev"] = {
		Name = "3_MidLevelDev",
		TimeToProduceGame = 7,
		CapacityOfGamesProduced = 1400,
		Price = 250,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 3,
			Label = "Mid Level Developer",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 80,
			Min = 1,
			Max = 10,
		},
		Games = {
			["School_of_Magic"] = {
				Chance = 33.3,
			},
			["Build_a_City"] = {
				Chance = 22.2,
			},
			["Racing_Tycoon"] = {
				Chance = 22.2,
			},
			["Mine_and_Craft"] = {
				Chance = 11.1,
			},
			["Hatch_a_Pet"] = {
				Chance = 11.1,
			},
		},
	},
	["4_SeniorDev"] = {
		Name = "4_SeniorDev",
		TimeToProduceGame = 4.5,
		CapacityOfGamesProduced = 3500,
		Price = 850,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 4,
			Label = "Senior Developer",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 65,
			Min = 1,
			Max = 10,
		},
		Games = {
			["Hatch_a_Pet"] = {
				Chance = 63,
			},
			["Zoo_Keeper"] = {
				Chance = 25,
			},
			["Forger"] = {
				Chance = 10,
			},
			["Tame_a_Dragon"] = {
				Chance = 1.5,
			},
			["Mansion_Tycoon"] = {
				Chance = 0.5,
			},
		},
	},

	["5_ConceptArtist"] = {
		Name = "5_ConceptArtist",
		TimeToProduceGame = 4,
		CapacityOfGamesProduced = 15 * 1000,
		Price = 2900,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 5,
			Label = "Concept Artist",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 55,
			Min = 1,
			Max = 10,
		},
		Games = {

			["Mansion_Tycoon"] = {
				Chance = 63,
			},
			["Obby_World"] = {
				Chance = 25,
			},
			["Cooking_Simulator"] = {
				Chance = 10,
			},
			["Star_Fighters"] = {
				Chance = 1.5,
			},
			["Dungeon_Crawler"] = {
				Chance = 0.5,
			},
		},
	},

	["6_TechLead"] = {
		Name = "6_TechLead",
		TimeToProduceGame = 4,
		CapacityOfGamesProduced = 60 * 1000,
		Price = 8000,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 6,
			Label = "Tech Lead",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 40,
			Min = 1,
			Max = 10,
		},
		Games = {

			["Dungeon_Crawler"] = {
				Chance = 63,
			},
			["Superhero_Stories"] = {
				Chance = 25,
			},
			["Jail_Breaking"] = {
				Chance = 10,
			},
			["Pirate_Island"] = {
				Chance = 1.5,
			},
			["Conquer_the_Galaxy"] = {
				Chance = 0.5,
			},
		},
	},

	["7_GameTester"] = {
		Name = "6_GameTester",
		TimeToProduceGame = 3.8,
		CapacityOfGamesProduced = 250 * 1000,
		Price = 2900,
		Rarity = "COMMON",
		RebirthRelease = 0,
		GUI = {
			Order = 7,
			Label = "Game Tester",
			Image = "rbxassetid://102177267097148",
		},
		Stock = {
			Chance = 20,
			Min = 1,
			Max = 10,
		},
		Games = {

			["Conquer_the_Galaxy"] = {
				Chance = 63,
			},
			["Be_a_Model"] = {
				Chance = 25,
			},
			["Expand_a_Garden"] = {
				Chance = 10,
			},
			["Cyberpunk_Shooter"] = {
				Chance = 1.5,
			},
			["Rivaled"] = {
				Chance = 0.5,
			},
		},
	},
})

return Devs
