local DeveloperProducts = {}

export type DeveloperProduct = {
	Name: string,
	Id: number,
}

DeveloperProducts.ENUM = {
	RESTOCK = {
		Name = "RESTOCK",
		Id = 3403471358,
	},

	RESTOCK_THIS = {
		Name = "RESTOCK_THIS",
		Id = 3403482621,
	},

	DEV_INTERN = {
		Name = "DEV_INTERN",
		Id = 3404259538,
	},

	JUNIOR_DEVELOPER = {
		Name = "JUNIOR_DEVELOPER",
		Id = 3404259535,
	},

	MID_LEVEL_DEVELOPER = {
		Name = "MID_LEVEL_DEVELOPER",
		Id = 3404259540,
	},

	SENIOR_DEVELOPER = {
		Name = "SENIOR_DEVELOPER",
		Id = 3404259537,
	},

	CONCEPET_ARTIST = {
		Name = "CONCEPET_ARTIST",
		Id = 3404259539,
	},
}

function DeveloperProducts:GetEnum(name: string): DeveloperProduct
	return self.ENUM[name]
end

return DeveloperProducts
