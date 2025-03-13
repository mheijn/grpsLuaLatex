require("mh.table")
local print = require("mh.print")
local _ = require("mh.gettext")
local util=require("gramps.util")

function printfun(f,n)
	print("\n"..n.."=")
	if f then
		for k,v in pairs(f) do print("data ",k,type(v)) end
		local m = getmetatable(f)
		if m then
			for k,v in pairs(m) do print("metadata ",k,type(v)) end
		end
	end
end

--------------------- DataContainer -----------------
local DataContainer={Container = {}}
DataContainer.__index = DataContainer

function DataContainer:new(data)
	if type(data) == "table" then

		if data.scheme_type then
			print.D("Creating class \""..data.scheme_type.title.."\"")

			printfun(self,"self in new container")
			local obj = setmetatable({},{__call = function(cls,d) return DataContainer.set(cls,d)end})
			obj.scheme = data
			obj.scheme_index = {}
			obj.Container = self.Container
			obj.set = self.set
	--		obj.get = self.get
			obj.VerifyData = self.VerifyData
			obj.__index = obj
			for k,v in pairs(data) do if v.index  then obj.scheme_index[v.index]=k end end
			printfun(obj,"obj in new container")
			return obj
		else
			print.D("unknown table")
		end

	end
end

function DataContainer:set(data)
	print("set")
	if self:VerifyData(data) then
	print("correct")
		local obj = setmetatable(self,{})
		obj.data = data
		obj.get = DataContainer.get
		return obj
	else
		exit(1)
	end
end

function DataContainer:get(name)
	local entry=self.scheme[name]
	if entry then
		i=entry.index
		if entry.type == "string" then  return self.data[i], entry.title end
		if entry.type == "integer" then  return tonumber(self.data[i]), entry.title end
		if entry.type == "array" then  return self.data[i], entry.title end
		if entry.class then
			return entry.class(self.data[i])
		end
		if entry.oneOf then
			for _,subentry in ipairs(entry.oneOf) do
				if self.data[i] == nil and subentry.type == "null" then return nil end
				if subentry.class then return subentry.class(self.data[i]) end
			end
		end
	end
	return  nil, string.format(_("%s not in scheme of %s"),name,self.name)
end


function DataContainer:VerifyData(data)
	local correct = true
	for i,n in ipairs(self.scheme_index) do
		local v=self.scheme[n]
		local error = false
		if  v.type then
			--print(v.type,type(data[i]))
			if v.type=="integer" and type(data[i])~="number" then error=true;correct=false
			elseif v.type=="string" and type(data[i])~="string" then error=true;correct=false
			elseif v.type=="array" and type(data[i])~="table" then error=true;correct=false
			end
			if error then
				print.e(string.format("Entry %d named %s must be %s and is %s",i,n,v.type,type(data[i])))
			end
		end
	end
	return correct
end

setmetatable(DataContainer, {
    __call = function(cls,s)
        return cls:new(s)
    end,
--    __index = function(_,handle)
--		return DataContainer(handle)
--	end
})

printfun(DataContainer,"DataContainer")

-----------------------------------------------------
local Scheme={
		calendar = {index=1 ,type= "integer", title= _("Calendar")},
		modifier = {index=2 ,type= "integer", title= _("Modifier")},
		quality =  {index=3 ,type= "integer",  title= _("Quality")},
		dateval =  {index=4 ,type= "array", title= _("Values"), items= {type= {"integer", "boolean"}}},
		text =     {index=5 ,type= "string", title= _("Text")},
		sortval =  {index=6 ,type= "integer", title= _("Sort value")},
		newyear =  {index=7 ,type= "integer", title= _("New year begins")},
		scheme_type = {class="Date", title="Date"}
		}

--local Date2 = DataContainer:new(Scheme)
local Date = DataContainer(Scheme)

printfun(Date,"Date")

--printfun(Date2,"Date2 ")

function  Date:long()
	print("long")
	print("get",self:get('text'))
end
--setmetatable(Date,{__call = function(cls,s) return cls:set(s) end})


-- Creates a dedicated scheme
--  Use s=Scheme(scheme)
-- then opendata by data=s(atatable)


local Scheme = {_TYPE='module', _NAME ='gramps.schema',_VERSION='0.28.2.2025'}
Scheme.__index = Scheme
function Scheme:new(s)
    local obj = setmetatable({},self)
	setmetatable(obj,{
		__call = function(cls,d) return cls:data(d) end
		})

    obj.scheme = s
    obj.rev = {}; for k,v in pairs(obj.scheme) do obj.rev[v.name]=k end
	obj.name = obj.scheme[obj.rev.scheme].title
	return obj
end
function Scheme:data(d)
	local give = setmetatable({},{
			__index = function(cls,d)return cls:get(d) end})
	--	local give = {}

	give.rev = self.rev
	give.name = self.name
	give.scheme = self.scheme
	give.values = d
	give.get = function(cls,t) return get(cls,t) end
	verify_data(give.values,give.scheme)
		--for k,
	return give
end

setmetatable(Scheme,{
	__call = function(cls,s) return cls:new(s) end
})


if arg ~= nil and arg[0] == string.sub(debug.getinfo(1,'S').source,2) then
    local d1=Date:set({0,0,0,{1,2,2025,0,2,3,2025},"datum 1",0,0})
	printfun(d1,"Datum d1")
    local d2=DataContainer.set(Date,{0,0,0,{1,2,2020,0,2,3,2025},"datum 2",0,0})
    local d2=Date({0,0,0,{1,2,2020,0,2,3,2025},"datum 2",0,0})
    printfun(d2,"DATUM d2")

	d1:long()
else
    return(Scheme)
end
