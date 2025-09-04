local DeveloperProducts = {}

export type DeveloperProduct = {
	Name: string,
	Id: number,
}

DeveloperProducts.ENUM = {
	RESTOCK = {
		Name = "RESTOCK",
		Id = 3346973568,
	},

	SERVER_LUCK_2X = {
		Name = "SERVER_LUCK_2X",
		Id = 3361251955,
	},

	SERVER_LUCK_4X = {
		Name = "SERVER_LUCK_4X",
		Id = 3361251953,
	},

	SERVER_LUCK_8X = {
		Name = "SERVER_LUCK_8X",
		Id = 3361251950,
	},

	SERVER_LUCK_16X = {
		Name = "SERVER_LUCK_16X",
		Id = 3361251949,
	},

	SERVER_LUCK_32X = {
		Name = "SERVER_LUCK_32X",
		Id = 3361251952,
	},

	MORE_TIME_ROBUX_LUCK = {
		Name = "MORE_TIME_ROBUX_LUCK",
		Id = 3362441440,
	},
}

function DeveloperProducts:GetEnum(name: string): DeveloperProduct
	return self.ENUM[name]
end

return DeveloperProducts
