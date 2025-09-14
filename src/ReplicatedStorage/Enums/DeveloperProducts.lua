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
}

function DeveloperProducts:GetEnum(name: string): DeveloperProduct
	return self.ENUM[name]
end

return DeveloperProducts
