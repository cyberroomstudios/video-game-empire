local Gamepass = {}

export type Gamepass = {
	Name: string,
	Id: number,
}

Gamepass.ENUM = {
	VIP = {
		Name = "VIP",
		Id = 1463571489,
	},

	AUTO_SELL = {
		Name = "AUTO_SELL",
		Id = 1463553528,
	},
}

function Gamepass:GetEnum(name: string): Gamepass
	return self.ENUM[name]
end

return Gamepass
