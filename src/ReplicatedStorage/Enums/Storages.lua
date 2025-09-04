local Storages = table.freeze({
	["Storage1"] = {
		Name = "Storage1",
		GUI = {
			Order = 1,
			Label = "Storage 1",
			Description = "Programmers Stores games after reaching capacity (Capacity: 100)",
			Image = "rbxassetid://109561129534290",
		},
		Capacity = 100,
		Price = 10,
		RebirthRelease = 0,
	},
	["Storage2"] = {
		Name = "Storage2",
		GUI = {
			Order = 2,
			Label = "Storage 2",
			Description = "Programmers Stores games after reaching capacity (Capacity: 200)",
			Image = "rbxassetid://98942978910575",
		},
		Capacity = 200,
		Price = 200,
		RebirthRelease = 0,
	},
})

return Storages
