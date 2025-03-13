local Researcher={}

function Researcher.new(source)
	local  self = setmetatable({},Researcher)

    if source then
        self.name = source.name
        self.addr = source.addr
        self.email = source.email
        --from locationbase
        self.street = source.street
        self.locality = source.locality
        self.city = source.city
        self.county = source.county
        self.state = source.state
        self.country = source.country
        self.postal = source.postal
        self.phone = source.phone

    else
        self.name = ""
        self.addr = ""
        self.email = ""
        --from locationbase
        self.street = ""
        self.locality = ""
        self.city = ""
        self.county = ""
        self.state = ""
        self.country = ""
        self.postal = ""
        self.phone = ""

    end
    return self
end

setmetatable(Researcher, {
    __call = function(cls,v)
        return cls.new(v)
    end,
})

return Researcher
