local Researcher{}

function Researcher.new(source)
    if source then
        self.name = source.name
        self.addr = source.addr
        self.email = source.email
    else
        self.name = ""
        self.addr = ""
        self.email = ""
    end
    return self
end

setmetatable(Researcher, {
    __call = function(cls,v)
        return cls.new(v)
    end,
})
