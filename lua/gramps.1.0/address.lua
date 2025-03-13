local util=require("gramps.util")
local _     =require("gramps.language")
local print=require("gramps.output")
local Address={}
Address.__index = Address

local Date={}
function Date.get_schema() end

local scheme={
    private=       {type="boolean",title= _("Private")},
    citation_list= {type="array", title= _("Citations"), items= {type="string",maxLength= 50}},
    note_list=     {type= "array", title= _("Notes"), items= {type="string", maxLength= 50}},
    date=          {oneOf= {{type="null"}, Date.get_schema() },title= _("Date")},
    address=       {type="array",title=_(Adddress),items={
		street= {type="string",title= _("Street")},
		locality= {type="string",title= _("Locality")},
		city= {type="string",title= _("City")},
		county= {type="string",title= _("County")},
		state= {type="string",title= _("State")},
		country= {type="string",title= _("Country")},
		postal= {type="string",title= _("Postal Code")},
		phone= {type="string",title= _("Phone")}
		}}
}
Address.scheme=scheme
--------------------------------------------------------------------------------------
local Scheme={}
Scheme.__index = Scheme
function Scheme.new(scheme)
    local self = setmetatable({}, Scheme)
    self.scheme=scheme
    return self
end

function Scheme:value(data,name)
	i=0
	for key,entry in pairs(self.scheme) do
		i=i+1
		if key == name then 
			if entry.type == "string" then  return data[i], entry.title end
		end
	end
	return nil
end

function Scheme:entry(data,nr)
	i=0
	for key,entry in pairs(self.scheme) do
		i=i+1
		if i == nr then 
			if entry.type == "string" then return data[i], entry.title end
		end
	end
	return nil
end

setmetatable(Scheme,{
   __call = function(cls,s) return cls.new(s) end
})
--------------------------------------------------------------------------------------
local addressscheme = Scheme(scheme)

function Address.new(adr)
	local self = setmetatable({}, Address)
	self.data = adr
	local l=#adr
	if l < 4 then print.e("Adres niet correct (Address.lua)");return self end
	self.street  =adr[l][1]
	self.locality=adr[l][2]
	self.city    =adr[l][3]
	self.county  =adr[l][4]
	self.state   =adr[l][5]
	self.country =adr[l][6]
	self.postal  =adr[l][7]
	self.phone   =adr[l][8]
	return self
end


function Address:string()
	if _.addressform() == 1 then --NL
		local s = self.street
		if 0<#self.postal then s=s.." "..self.postal end
		if 0<#self.locality then s=s.." "..self.locality end
		if 0<#self.city then s=s.." "..self.city end
		if 0<#self.county then s=s.." "..self.county end
		if 0<#self.state then s=s.." "..self.state end
		if 0<#self.country then s=s.." "..self.country end
		if 0<#self.phone then s=s.." ("..self.phone..")" end
		return s
	end
	if _.addressform() == 2 then --US
		local s = self.street
		if 0<#self.locality then s=s.." "..self.locality end
		if 0<#self.city then s=s.." "..self.city end
		if 0<#self.county then s=s.." "..self.county end
		if 0<#self.state then s=s.." "..self.state end
		if 0<#self.country then s=s.." "..self.country end
		if 0<#self.postal then s=s.." "..self.postal end
		if 0<#self.phone then s=s.." ("..self.phone..")" end
		return s
	end
end

setmetatable(Address,{
	__call = function(cls,grps_addr)
		return cls.new(grps_addr)
	end
	
})

if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then

	local date = {
	[1] = false,
	[2] = {},
	[3] = {},
	[4] = {
		[1] = "dr.Allard Piersonstraat",
		[2] = "",
		[3] = "Amstelveen",
		[4] = "",
		[5] = "",
		[6] = "Nederland",
		[7] = "1185 PE",
		[8] = ""}
	}
	
	local a = Address(date)
	print(a:string())
else
	return Address
end
