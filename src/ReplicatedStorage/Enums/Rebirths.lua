local Rebirths = table.freeze({
	[1] = {
		Requirements = {
			{
				Type = "MONEY",
				Amount = 10,
			},

			{
				Type = "CCU",
				Amount = 100,
			},
		},
		Awards = {

			{
				Type = "FLOOR",
				Amount = 1,
				GUI = {
					Label = "+1 Floor",
				},
			},

			{
				Type = "MONEY",
				Amount = 1000,
				GUI = {
					Label = "1000 Money",
				},
			},
		},
	},

	[2] = {
		Requirements = {
			{
				Type = "MONEY",
				Amount = 20,
			},

			{
				Type = "CCU",
				Amount = 200,
			},
		},
		Awards = {

			{
				Type = "FLOOR",
				Amount = 1,
				GUI = {
					Label = "+1 Floor",
				},
			},

			{
				Type = "MONEY",
				Amount = 1000,
				GUI = {
					Label = "1000 Money",
				},
			},
		},
	},
})

return Rebirths
