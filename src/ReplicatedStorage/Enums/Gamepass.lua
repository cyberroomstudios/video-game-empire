local Gamepass = {}

export type Gamepass = {
	Name: string,
	Id: number,
}

Gamepass.ENUM = {
	VIP = {
		Name = "VIP",
		Id = 1356645137,
	},

	AUTO_COLLECT = {
		Name = "AUTO_COLLECT",
		Id = 1358998345,
	},

	AUTO_SELL = {
		Name = "AUTO_SELL",
		Id = 1357296902,
	},
}

function Gamepass:GetEnum(name: string): Gamepass
	return self.ENUM[name]
end

return Gamepass
