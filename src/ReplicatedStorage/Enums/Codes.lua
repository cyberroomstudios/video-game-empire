local Codes = {}

Codes.ENUM = {
	WELCOME = "WELCOME",
}

function Codes:HasCode(key)
	return self.ENUM[key] ~= nil
end

return Codes
